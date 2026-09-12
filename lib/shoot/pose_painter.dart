import 'package:flutter/material.dart';

import 'dart:ui' as ui;

import '../poses/pose_library.dart';

/// 把姿势画在相机预览之上。
///
/// 新格式（[Pose.parts] 非空）：按部位分层渲染成「线条人形」——
/// 头/发/脸/颈/躯干/四肢/鞋各自独立绘制，结构清晰，发光只点关节不糊轮廓。
/// 旧格式（仅有 [Pose.paths]）：沿用双层描边发光剪影，保证兼容未升级的姿势。
class PosePainter extends CustomPainter {
  PosePainter({
    required this.pose,
    required this.style,
    this.fillRatio = 0.5,
    this.showKeyPoints = true,
    this.showFill = true,
    this.overlayImage,
    this.userScale = 1.0,
    this.userOffset = Offset.zero,
  });

  final Pose pose;
  final PoseStyle style;
  final double fillRatio;
  final bool showKeyPoints;
  final bool showFill;

  /// 透明 PNG 姿势图（已解码的 ui.Image）。非空时优先按图片渲染。
  final ui.Image? overlayImage;

  /// 用户手势施加的额外缩放（1.0=原比例）与位移（屏幕像素），
  /// 用于预览中的姿势放大/缩小与拖动。
  final double userScale;
  final Offset userOffset;

  /// 图片姿势发光的“淡化”参数：透明度与模糊半径都锁在一个不产生重影的区间。
  static const double kImageGlowOpacity = 0.4;
  static const double kImageGlowBlurMin = 4.0;
  static const double kImageGlowBlurMax = 8.0;

  /// 设计空间到绘制区域的 缩放+平移 矩阵，供页面定位提示气泡复用。
  static Matrix4 transformFor(Size size, double fillRatio,
      {double designWidth = 240, double designHeight = 380}) {
    final scale = (size.height * fillRatio) / designHeight;
    final dx = (size.width - designWidth * scale) / 2;
    final dy = (size.height - designHeight * scale) / 2;
    final matrix = Matrix4.identity();
    matrix[0] = scale; // scaleX
    matrix[5] = scale; // scaleY
    matrix[12] = dx; // translateX
    matrix[13] = dy; // translateY
    return matrix;
  }

  /// 用 缩放+平移 矩阵把设计空间坐标变换到屏幕坐标（矩阵为列主序 4x4，z=0）。
  static Offset transformPoint(Matrix4 m, Offset p) {
    final v = m.storage;
    return Offset(
      v[0] * p.dx + v[4] * p.dy + v[12],
      v[1] * p.dx + v[5] * p.dy + v[13],
    );
  }

  /// 在基础变换（设计空间→屏幕）之上叠加用户的缩放/位移，
  /// 让姿势可在预览中任意放大缩小与拖动。无变换时直接返回 base。
  Matrix4 _compose(Matrix4 base, Size size) {
    if (userScale == 1.0 && userOffset == Offset.zero) return base;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final m = Matrix4.identity()
      ..translateByDouble(userOffset.dx, userOffset.dy, 0.0, 1.0)
      ..translateByDouble(cx, cy, 0.0, 1.0)
      ..scaleByDouble(userScale, userScale, 1.0, 1.0)
      ..translateByDouble(-cx, -cy, 0.0, 1.0);
    m.multiply(base);
    return m;
  }

  /// 轻量 SVG path 解析：支持绝对坐标的 M / L / C / Q / Z
  static Path parseSvgPath(String d) {
    final path = Path();
    final cmdRegExp = RegExp(r'([MLQCZ])');
    final numRegExp = RegExp(r'-?\d+(?:\.\d+)?');
    final matches = cmdRegExp.allMatches(d).toList();
    for (var i = 0; i < matches.length; i++) {
      final cmd = matches[i].group(1)!;
      final segment = d.substring(
        matches[i].end,
        i + 1 < matches.length ? matches[i + 1].start : d.length,
      );
      final nums = numRegExp
          .allMatches(segment)
          .map((m) => double.parse(m.group(0)!))
          .toList();
      switch (cmd) {
        case 'M':
          path.moveTo(nums[0], nums[1]);
        case 'L':
          path.lineTo(nums[0], nums[1]);
        case 'C':
          path.cubicTo(nums[0], nums[1], nums[2], nums[3], nums[4], nums[5]);
        case 'Q':
          path.quadraticBezierTo(nums[0], nums[1], nums[2], nums[3]);
        case 'Z':
          path.close();
      }
    }
    return path;
  }

  static Color _parseColor(String? value, Color fallback) {
    if (value == null) return fallback;
    var hex = value.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length == 8) {
      final n = int.tryParse(hex, radix: 16);
      if (n != null) return Color(n);
    }
    return fallback;
  }

  /// 各部位默认线宽（屏幕像素），按类型给不同粗细，营造层次。
  static double _baseWidthFor(String type, PoseStyle s) {
    switch (type) {
      case 'face':
        return 1.6;
      case 'hair':
        return s.innerWidth * 0.6;
      case 'head':
        return s.innerWidth * 0.8;
      case 'neck':
        return s.innerWidth * 0.7;
      case 'torso':
        return s.innerWidth;
      case 'arm':
        return s.innerWidth * 0.8;
      case 'leg':
        return s.innerWidth * 0.9;
      case 'shoe':
        return s.innerWidth * 1.1;
      case 'hand':
        return s.innerWidth * 0.7;
      default:
        return s.innerWidth * 0.6;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 防御：绘制姿势层若抛异常（如图片解码异常），只跳过本层，
    // 绝不让整页黑屏或崩溃。
    try {
      // 图片姿势：有图就画图片；加载中或资源缺失则留空，绝不回退到 SVG path
      // （该姿势自带的 parts 是旧版矢量兜底，观感远差于真实素描图）。
      if (pose.imageAsset != null) {
        if (overlayImage != null) _paintImage(canvas, size);
        return;
      }
      if (pose.parts.isNotEmpty) {
        _paintParts(canvas, size);
      } else {
        _paintLegacy(canvas, size);
      }
    } catch (e) {
      debugPrint('[PosePainter] 绘制姿势失败（已跳过）：$e');
    }
  }

  /// 图片姿势：把透明 PNG 按设计空间等比铺满并居中叠加。
  /// - tint 非 null：用 ColorFilter.srcIn 把图染成风格色（保留透明度）
  /// - glow：在实线之下先画一层模糊同色，形成外发光
  void _paintImage(Canvas canvas, Size size) {
    final img = overlayImage!;
    final iw = img.width.toDouble();
    final ih = img.height.toDouble();
    final matrix = _compose(
        transformFor(size, fillRatio,
            designWidth: pose.designWidth, designHeight: pose.designHeight),
        size);

    // 在设计空间内「contain」居中，保留图片原始宽高比，避免拉伸变形
    final imgAspect = iw / ih;
    final designAspect = pose.designWidth / pose.designHeight;
    double drawW, drawH;
    if (imgAspect > designAspect) {
      drawW = pose.designWidth;
      drawH = pose.designWidth / imgAspect;
    } else {
      drawH = pose.designHeight;
      drawW = pose.designHeight * imgAspect;
    }
    final offX = (pose.designWidth - drawW) / 2;
    final offY = (pose.designHeight - drawH) / 2;
    final tl = transformPoint(matrix, Offset(offX, offY));
    final br = transformPoint(matrix, Offset(offX + drawW, offY + drawH));
    final dst = Rect.fromPoints(tl, br);
    final src = Rect.fromLTWH(0, 0, iw, ih);

    final tint = style.tint;
    final basePaint = Paint();
    if (tint != null) {
      basePaint.colorFilter = ColorFilter.mode(tint, BlendMode.srcIn);
    }

    if (style.glow && style.glowBlur > 0) {
      // 图片姿势的发光不能像矢量线那样「整图再垫一层」：对满幅的线条人，
      // 把整张素描图整幅高斯模糊再叠一次，等于在清晰的线条身后又印出一个
      // 同形彩色虚影，视觉上就是「重影」（蓝调/霓虹/柔光三套均中招）。
      // 这里只保留一层很淡、半径收窄的光晕：压低透明度 + 收紧模糊半径。
      final glowTint = tint ?? style.glowColor;
      final glowPaint = Paint()
        ..colorFilter = ColorFilter.mode(
            glowTint.withValues(alpha: kImageGlowOpacity), BlendMode.srcIn)
        ..maskFilter = MaskFilter.blur(
            BlurStyle.normal, style.glowBlur.clamp(kImageGlowBlurMin, kImageGlowBlurMax));
      canvas.drawImageRect(img, src, dst, glowPaint);
    }
    canvas.drawImageRect(img, src, dst, basePaint);
  }

  /// 新格式：按部位分层渲染成线条人形。
  void _paintParts(Canvas canvas, Size size) {
    final matrix = _compose(
        transformFor(size, fillRatio,
            designWidth: pose.designWidth, designHeight: pose.designHeight),
        size);

    final lineColor = style.innerColor;
    final fillColor = style.fillColor;
    final accent = style.keyPointColor;

    for (final part in pose.parts) {
      if (part.path.isEmpty) continue;
      final p = parseSvgPath(part.path).transform(matrix.storage);

      final isFace = part.type == 'face';
      final isTorso = part.type == 'torso';
      final isShoe = part.type == 'shoe';

      final stroke = _parseColor(part.stroke, isFace ? accent : lineColor);
      final fill = _parseColor(part.fill, fillColor);
      final width = part.width ?? _baseWidthFor(part.type, style);

      final filled = part.filled || isShoe;

      // 1) 填充（躯干/鞋等实心部位）
      if (filled && showFill) {
        canvas.drawPath(
          p,
          Paint()
            ..style = PaintingStyle.fill
            ..color = fill.withValues(
                alpha: isShoe ? 1.0 : (style.fillOpacity > 0 ? style.fillOpacity : 1.0)),
        );
      } else if (isTorso && showFill && style.fillOpacity > 0) {
        canvas.drawPath(
          p,
          Paint()
            ..style = PaintingStyle.fill
            ..color = fillColor.withValues(alpha: style.fillOpacity),
        );
      }

      // 2) 发光层（仅当该部位显式要求，或风格全局发光且为头/躯干/四肢）
      final wantGlow = part.glow ||
          (style.glow && (isTorso || part.type == 'head' || part.type == 'arm' || part.type == 'leg'));
      if (wantGlow) {
        canvas.drawPath(
          p,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = stroke
            ..strokeWidth = width
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, style.glowBlur),
        );
      }

      // 3) 清晰描边
      canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    _paintKeyPoints(canvas, matrix);
  }

  /// 旧格式：双层描边发光剪影（兼容未升级的姿势）。
  void _paintLegacy(Canvas canvas, Size size) {
    final matrix = _compose(
        transformFor(size, fillRatio,
            designWidth: pose.designWidth, designHeight: pose.designHeight),
        size);

    final source = Path()..addOval(pose.headRect);
    for (final d in pose.paths) {
      source.addPath(parseSvgPath(d), Offset.zero);
    }
    final scaled = source.transform(matrix.storage);

    if (showFill && style.fillOpacity > 0) {
      canvas.drawPath(
        scaled,
        Paint()
          ..style = PaintingStyle.fill
          ..color = style.fillColor.withValues(alpha: style.fillOpacity),
      );
    }

    if (!style.singleLayer) {
      canvas.drawPath(
        scaled,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = style.outerColor
          ..strokeWidth = style.outerWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = style.innerColor
      ..strokeWidth = style.innerWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (style.glow) {
      innerPaint.maskFilter =
          MaskFilter.blur(BlurStyle.normal, style.glowBlur);
      canvas.drawPath(scaled, innerPaint);
    }
    canvas.drawPath(
      scaled,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = style.innerColor
        ..strokeWidth = style.innerWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    _paintKeyPoints(canvas, matrix);
  }

  void _paintKeyPoints(Canvas canvas, Matrix4 matrix) {
    if (!showKeyPoints || !style.showKeyPoints) return;
    for (final kp in pose.keyPoints) {
      final p = PosePainter.transformPoint(matrix, kp);
      if (style.keyPointGlow) {
        canvas.drawCircle(
          p,
          style.keyPointRadius,
          Paint()
            ..style = PaintingStyle.fill
            ..color = style.keyPointColor
            ..maskFilter =
                MaskFilter.blur(BlurStyle.normal, style.keyPointRadius),
        );
      }
      canvas.drawCircle(
        p,
        style.keyPointRadius,
        Paint()
          ..style = PaintingStyle.fill
          ..color = style.keyPointColor,
      );
    }
  }

  @override
  bool shouldRepaint(PosePainter oldDelegate) =>
      oldDelegate.pose != pose ||
      oldDelegate.style != style ||
      oldDelegate.fillRatio != fillRatio ||
      oldDelegate.showKeyPoints != showKeyPoints ||
      oldDelegate.showFill != showFill ||
      oldDelegate.overlayImage != overlayImage ||
      oldDelegate.userScale != userScale ||
      oldDelegate.userOffset != userOffset;
}
