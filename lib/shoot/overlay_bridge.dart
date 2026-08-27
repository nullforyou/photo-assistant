import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import '../poses/pose_library.dart';
import 'pose_painter.dart';

/// 把一个姿势的闭合轮廓（含头部椭圆）flatten 成归一化折线，
/// 用于传给原生悬浮窗绘制虚线人形。坐标按设计空间 240x380 归一化到 0..1。
List<List<double>> poseToPolylines(Pose pose, {double step = 3.0}) {
  final full = ui.Path()..addOval(pose.headRect);
  for (final d in pose.paths) {
    full.addPath(PosePainter.parseSvgPath(d), ui.Offset.zero);
  }
  final out = <List<double>>[];
  for (final metric in full.computeMetrics()) {
    final pts = <double>[];
    var dist = 0.0;
    while (dist < metric.length) {
      final pos = metric.getTangentForOffset(dist)?.position;
      if (pos != null) {
        pts.add(pos.dx / Pose.designWidth);
        pts.add(pos.dy / Pose.designHeight);
      }
      dist += step;
    }
    final last = metric.getTangentForOffset(metric.length)?.position;
    if (last != null) {
      pts.add(last.dx / Pose.designWidth);
      pts.add(last.dy / Pose.designHeight);
    }
    if (pts.length >= 4) out.add(pts);
  }
  return out;
}

/// Flutter 与原生悬浮蒙版(OverlayService)之间的桥接：
/// - 启动/停止透明蒙版
/// - 传递全部姿势的折线数据
/// - 接收原生“切换姿势”按钮的回调
class OverlayBridge {
  static const MethodChannel _channel =
      MethodChannel('com.example.photo_assistant/overlay');

  static void Function(int)? _onPoseChanged;

  /// 在 App 启动时调用一次，注册来自原生蒙版“切换姿势”的回调。
  static void init() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onPoseChanged') {
        final idx = call.arguments as int;
        _onPoseChanged?.call(idx);
      }
      return null;
    });
  }

  static Future<bool> checkPermission() async {
    final r = await _channel.invokeMethod<bool>('checkOverlayPermission');
    return r ?? false;
  }

  static Future<void> requestPermission() async {
    await _channel.invokeMethod<void>('requestOverlayPermission');
  }

  static Future<void> start(
    int poseIndex,
    List<String> names,
    List<List<List<double>>> allPolylines,
  ) async {
    await _channel.invokeMethod<void>('startOverlay', {
      'pose': poseIndex,
      'names': names,
      'allPolylines': allPolylines,
    });
  }

  static Future<void> updatePose(
    int poseIndex,
    List<List<List<double>>> allPolylines,
  ) async {
    await _channel.invokeMethod<void>('updatePose', {
      'pose': poseIndex,
      'allPolylines': allPolylines,
    });
  }

  static Future<void> stop() async {
    await _channel.invokeMethod<void>('stopOverlay');
  }

  static void setPoseChangedHandler(void Function(int) handler) {
    _onPoseChanged = handler;
  }
}
