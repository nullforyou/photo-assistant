// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class SJa extends S {
  SJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'フォトアシスタント';

  @override
  String get welcomeSubtitle => 'Photo Assistant へようこそ';

  @override
  String get welcomeTagline => 'ポーズガイド · ポーズをとってワンタップで撮影';

  @override
  String get startShooting => '撮影を始める';

  @override
  String get cameraNotDetected => '利用可能なカメラが見つかりません';

  @override
  String cameraInitFailed(String error) {
    return 'カメラの初期化に失敗しました：$error';
  }

  @override
  String captureFailed(String error) {
    return '撮影に失敗しました：$error';
  }

  @override
  String get poseGuideTitle => '輪郭に合わせてポーズ';

  @override
  String get noPoses => '利用可能なポーズがありません';

  @override
  String get cameraUnavailable => 'カメラは使用できません';

  @override
  String get retry => '再試行';

  @override
  String get back => '戻る';

  @override
  String get unlockAllPoses => 'すべてのポーズのロックを解除';

  @override
  String unlockAllPosesBody(String count) {
    return 'すべてのスタイルのポーズがあと $count 種類ロック解除できます。一度の購入で永久にご利用いただけます。';
  }

  @override
  String buyForPrice(String price) {
    return 'ロック解除 — $price';
  }

  @override
  String get restorePurchase => '購入を復元';

  @override
  String get purchasePending => '購入処理中…';

  @override
  String get purchaseSuccess => 'すべてのポーズが解除されました';

  @override
  String get purchaseRestored => '購入を復元しました';

  @override
  String purchaseFailed(String error) {
    return '購入に失敗しました：$error';
  }

  @override
  String get storeUnavailable => 'ストアは利用できません。後ほど再度お試しください。';

  @override
  String get iapProductMissing =>
      'アプリ内購入が見つかりません。App Store Connect で pro_unlock をこのバージョンに紐づけ、審査に提出してください。';

  @override
  String get photoPreview => '写真プレビュー';

  @override
  String get retake => '撮り直し';

  @override
  String get save => '保存';

  @override
  String get savedToDownloads => 'ダウンロードに保存しました（アルバムで確認可）';

  @override
  String get savedToAlbum => 'アルバムに保存しました';

  @override
  String saveFailed(String error) {
    return '保存に失敗しました：$error';
  }

  @override
  String get photoPermissionTitle => '写真へのアクセスが必要';

  @override
  String get photoPermissionBody => '写真を保存するには「写真」へのアクセス許可が必要です。設定で許可してください。';

  @override
  String get openSettings => '設定を開く';

  @override
  String get cancel => 'キャンセル';
}
