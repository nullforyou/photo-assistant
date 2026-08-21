import 'dart:html' as html;
import 'dart:typed_data';

/// Web 端：浏览器没有「写入相册」权限，退而求其次触发图片下载。
/// 手机浏览器下载后图片会进入「下载」目录，相册中即可看到。
Future<String> savePhotoToGallery(Uint8List bytes) async {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..download = '拍照助手_${DateTime.now().millisecondsSinceEpoch}.jpg'
    ..click();
  html.Url.revokeObjectUrl(url);
  return '已保存到下载（可在相册中查看）';
}
