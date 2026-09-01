import 'package:flutter_test/flutter_test.dart';

import 'package:photo_assistant/poses/pose_data.dart';

void main() {
  test('内置兜底数据可用', () {
    final result = parseDefaultPoseResult();
    expect(result.poses, isNotEmpty);
    expect(result.poses.single.imageAsset, 'assets/poses/pose_side_smile_kick.png');
    expect(result.styles, isNotEmpty);
  });
}