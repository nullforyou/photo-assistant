import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:photo_assistant/l10n/generated/app_localizations.dart';
import 'package:saver_gallery/saver_gallery.dart';

/// 原生端（Android/iOS/HarmonyOS）：直接写入系统相册（Pictures/photo_assistant）。
Future<String> savePhotoToGallery(Uint8List bytes, BuildContext context) async {
  final s = S.of(context);
  final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final result = await SaverGallery.saveImage(
    bytes,
    quality: 100,
    fileName: fileName,
    albumPath: 'photo_assistant',
    skipIfExists: false,
  );
  return result.isSuccess ? s.savedToAlbum : s.saveFailed(result.toString());
}
