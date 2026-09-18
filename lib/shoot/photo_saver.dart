// 平台条件导出：原生（Android/iOS/HarmonyOS）走 saver_gallery 直接写入相册；
// Web 端（无 dart:io）走浏览器下载。
export 'photo_saver_web.dart' if (dart.library.io) 'photo_saver_native.dart';

export 'save_result.dart';
