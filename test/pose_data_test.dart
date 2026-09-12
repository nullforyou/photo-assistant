import 'package:flutter_test/flutter_test.dart';

import 'package:photo_assistant/poses/pose_data.dart';

void main() {
  test('内置兜底数据可用', () {
    final result = parseDefaultPoseResult();

    // 默认数据包含多套姿势（非单一），首页首图资产应存在
    expect(result.poses, isNotEmpty);
    expect(
      result.poses.any((p) => p.imageAsset == 'assets/poses/pose_001.png'),
      isTrue,
    );

    // 4 套光影风格齐全
    expect(result.styles, isNotEmpty);
    for (final key in const [
      'minimal',
      'dual_outline',
      'neon',
      'soft_glow',
    ]) {
      expect(result.styles.containsKey(key), isTrue, reason: '缺少风格 $key');
    }

    // 默认关闭光影（双层无光影）
    expect(result.activeStyle, 'none');
  });
}
