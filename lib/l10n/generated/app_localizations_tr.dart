// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class STr extends S {
  STr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Foto Asistanı';

  @override
  String get welcomeSubtitle => 'Photo Assistant\'a Hoş Geldiniz';

  @override
  String get welcomeTagline => 'Poz rehberi · poz ver, tek dokunuşla çek';

  @override
  String get startShooting => 'Çekime Başla';

  @override
  String get cameraNotDetected => 'Kullanılabilir kamera yok';

  @override
  String cameraInitFailed(String error) {
    return 'Kamera başlatılamadı: $error';
  }

  @override
  String captureFailed(String error) {
    return 'Çekim başarısız: $error';
  }

  @override
  String get poseGuideTitle => 'Ana hatta göre poz ver';

  @override
  String get noPoses => 'Kullanılabilir poz yok';

  @override
  String get cameraUnavailable => 'Kamera kullanılamıyor';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get back => 'Geri';

  @override
  String get unlockAllPoses => 'Tüm Pozların Kilidini Aç';

  @override
  String unlockAllPosesBody(String count) {
    return 'Her stilde $count poz daha kilidini açar. Tek seferlik alım, sonsuza kadar.';
  }

  @override
  String buyForPrice(String price) {
    return 'Kilidi Aç — $price';
  }

  @override
  String get restorePurchase => 'Satın Almayı Geri Yükle';

  @override
  String get purchasePending => 'Satın alma sürüyor…';

  @override
  String get purchaseSuccess => 'Tüm pozların kilidi açıldı';

  @override
  String get purchaseRestored => 'Satın alma geri yüklendi';

  @override
  String purchaseFailed(String error) {
    return 'Satın alma başarısız: $error';
  }

  @override
  String get storeUnavailable =>
      'Mağaza kullanılamıyor. Lütfen daha sonra tekrar deneyin.';

  @override
  String get iapProductMissing =>
      'Uygulama içi satın alma bulunamadı. App Store Connect\'te pro_unlock ürününü bu sürüme bağlayıp incelemeye gönderin.';

  @override
  String get photoPreview => 'Foto Önizleme';

  @override
  String get retake => 'Yeniden çek';

  @override
  String get save => 'Kaydet';

  @override
  String get savedToDownloads =>
      'İndirilenlere kaydedildi (albümde görülebilir)';

  @override
  String get savedToAlbum => 'Albüme kaydedildi';

  @override
  String saveFailed(String error) {
    return 'Kaydetme başarısız: $error';
  }

  @override
  String get photoPermissionTitle => 'Foto erişimi gerekli';

  @override
  String get photoPermissionBody =>
      'Fotoğrafları kaydetmek için Foto Kitaplığı erişimi gerekir. Lütfen Ayarlar\'dan izin verin.';

  @override
  String get openSettings => 'Ayarları Aç';

  @override
  String get cancel => 'İptal';
}
