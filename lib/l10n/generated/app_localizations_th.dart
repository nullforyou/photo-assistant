// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class STh extends S {
  STh([String locale = 'th']) : super(locale);

  @override
  String get appName => 'ผู้ช่วยถ่ายภาพ';

  @override
  String get welcomeSubtitle => 'ยินดีต้อนรับสู่ Photo Assistant';

  @override
  String get welcomeTagline => 'คู่มือท่าทาง · ถ่ายในหนึ่งแตะ';

  @override
  String get startShooting => 'เริ่มถ่าย';

  @override
  String get cameraNotDetected => 'ไม่พบกล้องที่ใช้งานได้';

  @override
  String cameraInitFailed(String error) {
    return 'การเริ่มต้นกล้องล้มเหลว: $error';
  }

  @override
  String captureFailed(String error) {
    return 'การถ่ายภาพล้มเหลว: $error';
  }

  @override
  String get poseGuideTitle => 'จัดท่าตามเส้นกรอบ';

  @override
  String get noPoses => 'ไม่มีท่าทางที่ใช้งานได้';

  @override
  String get cameraUnavailable => 'กล้องไม่พร้อมใช้งาน';

  @override
  String get retry => 'ลองอีกครั้ง';

  @override
  String get back => 'กลับ';

  @override
  String get photoPreview => 'ตัวอย่างรูปภาพ';

  @override
  String get retake => 'ถ่ายใหม่';

  @override
  String get save => 'บันทึก';

  @override
  String get savedToDownloads => 'บันทึกไปยังดาวน์โหลด (ดูในอัลบั้มได้)';

  @override
  String get savedToAlbum => 'บันทึกไปยังอัลบั้มแล้ว';

  @override
  String saveFailed(String error) {
    return 'การบันทึกล้มเหลว: $error';
  }

  @override
  String get photoPermissionTitle => 'ต้องการสิทธิเข้าถึงรูปภาพ';

  @override
  String get photoPermissionBody =>
      'การบันทึกรูปภาพต้องได้รับสิทธิเข้าถึงคลังรูปภาพ กรุณาอนุญาตในการตั้งค่า';

  @override
  String get openSettings => 'เปิดการตั้งค่า';

  @override
  String get cancel => 'ยกเลิก';
}
