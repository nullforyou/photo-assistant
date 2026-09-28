// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class SZh extends S {
  SZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '拍照助手';

  @override
  String get welcomeSubtitle => '欢迎使用 Photo Assistant';

  @override
  String get welcomeTagline => '姿势引导 · 摆好 pose 一键出片';

  @override
  String get startShooting => '开始拍照';

  @override
  String get cameraNotDetected => '未检测到可用摄像头';

  @override
  String cameraInitFailed(String error) {
    return '摄像头初始化失败：$error';
  }

  @override
  String captureFailed(String error) {
    return '拍照失败：$error';
  }

  @override
  String get poseGuideTitle => '按轮廓摆好姿势';

  @override
  String get noPoses => '无可用姿势';

  @override
  String get cameraUnavailable => '摄像头不可用';

  @override
  String get retry => '重试';

  @override
  String get back => '返回';

  @override
  String get unlockAllPoses => '解锁全部姿势';

  @override
  String unlockAllPosesBody(String count) {
    return '再解锁 $count 个姿势，包含每种风格。一次购买，永久使用。';
  }

  @override
  String buyForPrice(String price) {
    return '解锁 — $price';
  }

  @override
  String get restorePurchase => '恢复购买';

  @override
  String get purchasePending => '购买处理中…';

  @override
  String get purchaseSuccess => '已全部解锁';

  @override
  String get purchaseRestored => '购买已恢复';

  @override
  String purchaseFailed(String error) {
    return '购买失败：$error';
  }

  @override
  String get storeUnavailable => '商店暂不可用，请稍后再试。';

  @override
  String get iapProductMissing =>
      '未找到内购商品：请在 App Store Connect 把 pro_unlock 关联到本版本并提交审核。';

  @override
  String get photoPreview => '照片预览';

  @override
  String get retake => '重拍';

  @override
  String get save => '保存';

  @override
  String get savedToDownloads => '已保存到下载（可在相册中查看）';

  @override
  String get savedToAlbum => '已保存到相册';

  @override
  String saveFailed(String error) {
    return '保存失败：$error';
  }

  @override
  String get photoPermissionTitle => '需要相册权限';

  @override
  String get photoPermissionBody => '保存照片需要访问相册。请在「设置」中允许本 App 访问相册后重试。';

  @override
  String get openSettings => '去设置';

  @override
  String get cancel => '取消';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class SZhHant extends SZh {
  SZhHant() : super('zh_Hant');

  @override
  String get appName => '拍照助手';

  @override
  String get welcomeSubtitle => '歡迎使用 Photo Assistant';

  @override
  String get welcomeTagline => '姿勢引導 · 擺好 pose 一鍵出片';

  @override
  String get startShooting => '開始拍照';

  @override
  String get cameraNotDetected => '未檢測到可用攝像頭';

  @override
  String cameraInitFailed(String error) {
    return '攝像頭初始化失敗：$error';
  }

  @override
  String captureFailed(String error) {
    return '拍照失敗：$error';
  }

  @override
  String get poseGuideTitle => '按輪廓擺好姿勢';

  @override
  String get noPoses => '無可用姿勢';

  @override
  String get cameraUnavailable => '攝像頭不可用';

  @override
  String get retry => '重試';

  @override
  String get back => '返回';

  @override
  String get unlockAllPoses => '解鎖全部姿勢';

  @override
  String unlockAllPosesBody(String count) {
    return '再解鎖 $count 個姿勢，包含每種風格。一次購買，永久使用。';
  }

  @override
  String buyForPrice(String price) {
    return '解鎖 — $price';
  }

  @override
  String get restorePurchase => '恢復購買';

  @override
  String get purchasePending => '購買處理中…';

  @override
  String get purchaseSuccess => '已全部解鎖';

  @override
  String get purchaseRestored => '購買已恢復';

  @override
  String purchaseFailed(String error) {
    return '購買失敗：$error';
  }

  @override
  String get storeUnavailable => '商店暫不可用，請稍後再試。';

  @override
  String get iapProductMissing =>
      '未找到內購商品：請在 App Store Connect 把 pro_unlock 關聯到本版本並提交審核。';

  @override
  String get photoPreview => '照片預覽';

  @override
  String get retake => '重拍';

  @override
  String get save => '保存';

  @override
  String get savedToDownloads => '已保存到下載（可在相冊中查看）';

  @override
  String get savedToAlbum => '已保存到相冊';

  @override
  String saveFailed(String error) {
    return '保存失敗：$error';
  }

  @override
  String get photoPermissionTitle => '需要相冊權限';

  @override
  String get photoPermissionBody => '儲存照片需要存取相冊。請在「設定」中允許本 App 存取相冊後重試。';

  @override
  String get openSettings => '前往設定';

  @override
  String get cancel => '取消';
}
