import 'package:flutter/material.dart';

import '../poses/pose_library.dart';

/// 把闭环轮廓姿势画成半透明虚线人形，叠加在相机预览之上。
class PosePainter extends CustomPainter {
  PosePainter({
    required this.pose,
    this.fillRatio = 0.5,
    this.lineOpacity = 0.9,
    this.fillOpacity = 0.06,
    this.showFill = true,
  });

  final Pose pose;
  final double fillRatio;
  final double lineOpacity;
  final double fillOpacity;
  final bool showFill;

  /// 轻量 SVG path 解析：支持绝对坐标的 M / L / C / Q / Z
  static Path parseSvgPath(String d) {
    final path = Path();
    final cmdRegExp = RegExp(r'([MLQCZ])');
    final numRegExp = RegExp(r'-?\d+(?:\.\d+)?');
    final matches = cmdRegExp.allMatches(d).toList();
    for (var i = 0; i < matches.length; i++) {
      final cmd = matches[i].group(1)!;
      final segment = d.substring(matches[i].end,
          i + 1 < matches.length ? matches[i + 1].start : d.length);
      final nums =
          numRegExp.allMatches(segment).map((m) => double.parse(m.group(0)!)).toList();
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

  /// 沿路径度量生成虚线（Dash 效果）
  static Path dashPath(Path source, double dashWidth, double dashGap) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final len = draw ? dashWidth : dashGap;
        if (draw) {
          dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 组装完整姿势路径（设计空间 240x380）
    final source = Path()..addOval(pose.headRect);
    for (final d in pose.paths) {
      source.addPath(parseSvgPath(d), Offset.zero);
    }

    // 等比缩放到绘制区域：高度占 fillRatio（默认半屏），水平+垂直居中
    final scale = (size.height * fillRatio) / Pose.designHeight;
    final dx = (size.width - Pose.designWidth * scale) / 2;
    final dy = (size.height - Pose.designHeight * scale) / 2;
    // 手工构造 缩放+平移 矩阵（列主序），避免使用已废弃的 API
    final matrix = Matrix4.identity();
    matrix[0] = scale; // scaleX
    matrix[5] = scale; // scaleY
    matrix[12] = dx; // translateX
    matrix[13] = dy; // translateY
    final scaled = source.transform(matrix.storage);

    if (showFill) {
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white.withValues(alpha: fillOpacity);
      canvas.drawPath(scaled, fillPaint);
    }

    final dashed = dashPath(scaled, 8 * scale, 7 * scale);
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withValues(alpha: lineOpacity)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(dashed, strokePaint);
  }

  @override
  bool shouldRepaint(PosePainter oldDelegate) =>
      oldDelegate.pose != pose ||
      oldDelegate.lineOpacity != lineOpacity ||
      oldDelegate.fillOpacity != fillOpacity ||
      oldDelegate.showFill != showFill;
}
