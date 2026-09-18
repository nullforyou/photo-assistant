import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:photo_assistant/l10n/generated/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';

import 'save_result.dart';

/// 原生端（Android/iOS/HarmonyOS）：直接写入系统相册。
///
/// 关键修复（用户反馈"没给权限就保存不起、还没提示"）：
/// 1. 保存前先查相册权限。被系统永久拒绝时（用户在设置里关掉过），
///    系统不会再弹授权框，直接返回 [PhotoSaveResult.settingsRequired]，由 UI 弹窗
///    引导去「设置」开启——避免静默失败。
/// 2. iOS 上若用户只给了「仅添加」权限，saver_gallery 用 albumPath 建自定义
///    相册会失败；此时自动退化为不带 albumPath 保存到「最近项目」，提高成功率。
Future<PhotoSaveResult> savePhotoToGallery(Uint8List bytes, BuildContext context) async {
  final s = S.of(context);

  // 1) 权限预检（非 Android/iOS 平台 permission_handler 可能不支持，吞掉异常直接保存）
  try {
    final status = await Permission.photos.status;
    if (status.isPermanentlyDenied) {
      return PhotoSaveResult(ok: false, settingsRequired: true, message: s.photoPermissionBody);
    }
    if (status.isDenied) {
      final requested = await Permission.photos.request();
      if (requested.isPermanentlyDenied) {
        return PhotoSaveResult(ok: false, settingsRequired: true, message: s.photoPermissionBody);
      }
      if (!requested.isGranted && !requested.isLimited) {
        return PhotoSaveResult(ok: false, message: s.photoPermissionBody);
      }
    }
  } catch (_) {
    // 不支持的平台：跳过预检，交给 saver_gallery 处理
  }

  // 2) 保存：先带自定义相册；失败再退化到「最近项目」
  final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
  var result = await SaverGallery.saveImage(
    bytes,
    quality: 100,
    fileName: fileName,
    albumPath: 'photo_assistant',
    skipIfExists: false,
  );
  if (!result.isSuccess) {
    result = await SaverGallery.saveImage(
      bytes,
      quality: 100,
      fileName: fileName,
      skipIfExists: false,
    );
  }

  if (result.isSuccess) {
    return PhotoSaveResult(ok: true, message: s.savedToAlbum);
  }
  return PhotoSaveResult(ok: false, message: s.saveFailed(result.errorMessage ?? ''));
}
