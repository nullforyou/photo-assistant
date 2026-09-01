import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:photo_assistant/l10n/generated/app_localizations.dart';

/// Web 端：浏览器没有「写入相册」权限，退而求其次触发图片下载。
/// 手机浏览器下载后图片会进入「下载」目录，相册中即可看到。
Future<String> savePhotoToGallery(Uint8List bytes, BuildContext context) async {
  final s = S.of(context);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..download = '${s.appName}_${DateTime.now().millisecondsSinceEpoch}.jpg'
    ..click();
  html.Url.revokeObjectUrl(url);
  return s.savedToDownloads;
}
