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
  String get unlockAllPoses => '모든 포즈 잠금 해제';

  @override
  String unlockAllPosesBody(String count) {
    return '모든 스타일의 포즈 $count개를 추가로 잠금 해제합니다. 한 번 구매하면 영구적으로 사용할 수 있습니다.';
  }

  @override
  String buyForPrice(String price) {
    return '잠금 해제 — $price';
  }

  @override
  String get restorePurchase => '구매 복원';

  @override
  String get purchasePending => '구매 처리 중…';

  @override
  String get purchaseSuccess => '모든 포즈 잠금 해제됨';

  @override
  String get purchaseRestored => '구매가 복원되었습니다';

  @override
  String purchaseFailed(String error) {
    return '구매 실패: $error';
  }

  @override
  String get storeUnavailable => '스토어를 사용할 수 없습니다. 나중에 다시 시도해 주세요.';

  @override
  String get iapProductMissing =>
      '인앱 결제를 찾을 수 없습니다. App Store Connect에서 pro_unlock을 이 버전에 연결하고 심사에 제출하세요.';

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

  @override
  String get photoPermissionTitle => '사진 접근 권한 필요';

  @override
  String get photoPermissionBody =>
      '사진을 저장하려면 사진 라이브러리 접근 권한이 필요합니다. 설정에서 허용해 주세요.';

  @override
  String get openSettings => '설정 열기';

  @override
  String get cancel => '취소';
}
