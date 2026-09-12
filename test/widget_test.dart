// 冒烟测试：验证 App 能正常构建欢迎页（取代 Flutter 模板自带的计数器测试，
// 该 App 是相机/姿势引导应用，没有计数器，原测试必然失败）。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:photo_assistant/main.dart';

void main() {
  testWidgets('App 能正常构建欢迎页', (WidgetTester tester) async {
    // 构建整个 App 树，确保 MaterialApp 与欢迎页无异常
    await tester.pumpWidget(const MyApp());

    // 根 MaterialApp 已渲染
    expect(find.byType(MaterialApp), findsOneWidget);

    // 再走一帧，确认欢迎页（含品牌图标与本地化文案）构建不抛错
    await tester.pump();
    expect(find.byType(WelcomePage), findsOneWidget);
  });
}
