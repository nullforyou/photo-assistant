import 'package:flutter/material.dart';

import '../poses/pose_library.dart';

/// 按接口下发的 [PoseStyle] 把闭环轮廓姿势画成发光人形，叠加在相机预览之上。
///
/// 渲染顺序：填充 → 外层深色描边 → 内层亮色描边（可发光）→ 关键点发光圆点。
class PosePainter extends CustomPainter {
  PosePainter({
    required this.pose,
    required this.style,
    this.fillRatio = 0.5,
    this.showKeyPoints = true,
    this.showFill = true,
  });

  final Pose pose;
  final PoseStyle style;
  final double fillRatio;
  final bool showKeyPoints;
  final bool showFill;

  /// 设计空间（240x380）到绘制区域的 缩放+平移 矩阵，供页面定位提示气泡复用。
  static Matrix4 transformFor(Size size, double fillRatio) {
    final scale = (size.height * fillRatio) / Pose.designHeight;
    final dx = (size.width - Pose.designWidth * scale) / 2;
    final dy = (size.height - Pose.designHeight * scale) / 2;
    final matrix = Matrix4.identity();
    matrix[0] = scale;
    matrix[5] = scale;
    matrix[12] = dx;
    matrix[13] = dy;
    return matrix;
  }

  /// 用缩放+平移矩阵把设计空间坐标变换到屏幕坐标。
  static Offset transformPoint(Matrix4 m, Offset p) {
    final v = m.storage;
    return Offset(
      v[0] * p.dx + v[4] * p.dy + v[12],
      v[1] * p.dx + v[5] * p.dy + v[13],
    );
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

  @override
  void paint(Canvas canvas, Size size) {
    final matrix = transformFor(size, fillRatio);

    // 组装完整姿势路径（设计空间 240x380）：头部 + 各身体 path
    final source = Path()..addOval(pose.headRect);
    for (final d in pose.paths) {
      source.addPath(parseSvgPath(d), Offset.zero);
    }
    final scaled = source.transform(matrix.storage);

    // 1) 身体填充
    if (showFill && style.fillOpacity > 0) {
      canvas.drawPath(
        scaled,
        Paint()
          ..style = PaintingStyle.fill
          ..color = style.innerColor
              .withValues(alpha: (style.fillOpacity * 2.5).clamp(0.0, 0.25)),
      );
    }

    // 2) 外层描边：用 innerColor 半透明绘制，确保在任何背景下都可见
    canvas.drawPath(
      scaled,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = style.innerColor.withValues(alpha: 0.35)
        ..strokeWidth = style.outerWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // 3) 内层亮色描边（先画带模糊的发光层，再叠清晰实线）
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

    // 4) 关键点发光圆点（设计空间坐标 → 屏幕坐标）
    if (showKeyPoints && style.showKeyPoints) {
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
  }

  @override
  bool shouldRepaint(PosePainter oldDelegate) =>
      oldDelegate.pose != pose ||
      oldDelegate.style != style ||
      oldDelegate.fillRatio != fillRatio ||
      oldDelegate.showKeyPoints != showKeyPoints ||
      oldDelegate.showFill != showFill;
}
