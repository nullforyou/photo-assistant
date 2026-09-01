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
}
