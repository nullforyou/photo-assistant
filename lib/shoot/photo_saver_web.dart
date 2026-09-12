import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:photo_assistant/l10n/generated/app_localizations.dart';
import 'package:web/web.dart' as web;

/// Web 端：浏览器没有「写入相册」权限，退而求其次触发图片下载。
/// 手机浏览器下载后图片会进入「下载」目录，相册中即可看到。
Future<String> savePhotoToGallery(Uint8List bytes, BuildContext context) async {
  final s = S.of(context);
  final blob = web.Blob(<JSAny>[bytes.toJS].toJS);
  final url = web.URL.createObjectURL(blob);
  web.HTMLAnchorElement()
    ..href = url
    ..download = '${s.appName}_${DateTime.now().millisecondsSinceEpoch}.jpg'
    ..click();
  web.URL.revokeObjectURL(url);
  return s.savedToDownloads;
}
