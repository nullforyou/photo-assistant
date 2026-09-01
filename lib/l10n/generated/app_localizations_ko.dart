// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class SKo extends S {
  SKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => '포토 어시스턴트';

  @override
  String get welcomeSubtitle => 'Photo Assistant에 오신 것을 환영합니다';

  @override
  String get welcomeTagline => '포즈 가이드 · 포즈를 취하고 한 번에 촬영';

  @override
  String get startShooting => '촬영 시작';

  @override
  String get cameraNotDetected => '사용 가능한 카메라를 찾을 수 없습니다';

  @override
  String cameraInitFailed(String error) {
    return '카메라 초기화 실패: $error';
  }

  @override
  String captureFailed(String error) {
    return '촬영 실패: $error';
  }

  @override
  String get poseGuideTitle => '윤곽에 맞춰 포즈';

  @override
  String get noPoses => '사용 가능한 포즈 없음';

  @override
  String get cameraUnavailable => '카메라를 사용할 수 없습니다';

  @override
  String get retry => '다시 시도';

  @override
  String get back => '뒤로';

  @override
  String get photoPreview => '사진 미리보기';

  @override
  String get retake => '다시 찍기';

  @override
  String get save => '저장';

  @override
  String get savedToDownloads => '다운로드에 저장됨 (앨범에서 확인)';

  @override
  String get savedToAlbum => '앨범에 저장됨';

  @override
  String saveFailed(String error) {
    return '저장 실패: $error';
  }
}
