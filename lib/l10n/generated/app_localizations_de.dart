// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class SDe extends S {
  SDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Foto-Assistent';

  @override
  String get welcomeSubtitle => 'Willkommen bei Photo Assistant';

  @override
  String get welcomeTagline =>
      'Posenführung · Pose einnehmen, mit einem Tipp aufnehmen';

  @override
  String get startShooting => 'Aufnahme starten';

  @override
  String get cameraNotDetected => 'Keine Kamera verfügbar';

  @override
  String cameraInitFailed(String error) {
    return 'Kamera-Initialisierung fehlgeschlagen: $error';
  }

  @override
  String captureFailed(String error) {
    return 'Aufnahme fehlgeschlagen: $error';
  }

  @override
  String get poseGuideTitle => 'Pose entlang der Umrisslinie';

  @override
  String get noPoses => 'Keine Posen verfügbar';

  @override
  String get cameraUnavailable => 'Kamera nicht verfügbar';

  @override
  String get retry => 'Wiederholen';

  @override
  String get back => 'Zurück';

  @override
  String get unlockAllPoses => 'Alle Posen freischalten';

  @override
  String unlockAllPosesBody(String count) {
    return 'Schaltet $count weitere Posen in jedem Stil frei. Einmalige Zahlung, für immer.';
  }

  @override
  String buyForPrice(String price) {
    return 'Freischalten — $price';
  }

  @override
  String get restorePurchase => 'Kauf wiederherstellen';

  @override
  String get purchasePending => 'Kauf läuft…';

  @override
  String get purchaseSuccess => 'Alle Posen freigeschaltet';

  @override
  String get purchaseRestored => 'Kauf wiederhergestellt';

  @override
  String purchaseFailed(String error) {
    return 'Kauf fehlgeschlagen: $error';
  }

  @override
  String get storeUnavailable =>
      'Store ist nicht verfügbar. Bitte versuchen Sie es später erneut.';

  @override
  String get photoPreview => 'Foto-Vorschau';

  @override
  String get retake => 'Neu aufnehmen';

  @override
  String get save => 'Speichern';

  @override
  String get savedToDownloads => 'In Downloads gespeichert (im Album sichtbar)';

  @override
  String get savedToAlbum => 'In Album gespeichert';

  @override
  String saveFailed(String error) {
    return 'Speichern fehlgeschlagen: $error';
  }

  @override
  String get photoPermissionTitle => 'Foto-Zugriff nötig';

  @override
  String get photoPermissionBody =>
      'Zum Speichern von Fotos ist der Zugriff auf die Fotobibliothek nötig. Bitte in Einstellungen erlauben.';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get cancel => 'Abbrechen';
}
