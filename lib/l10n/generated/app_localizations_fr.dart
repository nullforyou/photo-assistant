// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class SFr extends S {
  SFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Assistant Photo';

  @override
  String get welcomeSubtitle => 'Bienvenue sur Photo Assistant';

  @override
  String get welcomeTagline =>
      'Guide de pose · strikez une pose, capturez en un toucher';

  @override
  String get startShooting => 'Commencer';

  @override
  String get cameraNotDetected => 'Aucune caméra disponible';

  @override
  String cameraInitFailed(String error) {
    return 'Échec d\'initialisation de la caméra : $error';
  }

  @override
  String captureFailed(String error) {
    return 'Échec de la capture : $error';
  }

  @override
  String get poseGuideTitle => 'Posez selon le contour';

  @override
  String get noPoses => 'Aucune pose disponible';

  @override
  String get cameraUnavailable => 'Caméra indisponible';

  @override
  String get retry => 'Réessayer';

  @override
  String get back => 'Retour';

  @override
  String get unlockAllPoses => 'Débloquer toutes les poses';

  @override
  String unlockAllPosesBody(String count) {
    return 'Débloque $count poses supplémentaires dans chaque style. Achat unique, à jamais.';
  }

  @override
  String buyForPrice(String price) {
    return 'Débloquer — $price';
  }

  @override
  String get restorePurchase => 'Restaurer l\'achat';

  @override
  String get purchasePending => 'Achat en cours…';

  @override
  String get purchaseSuccess => 'Toutes les poses sont débloquées';

  @override
  String get purchaseRestored => 'Achat restauré';

  @override
  String purchaseFailed(String error) {
    return 'Échec de l\'achat : $error';
  }

  @override
  String get storeUnavailable =>
      'Le store est indisponible. Veuillez réessayer plus tard.';

  @override
  String get iapProductMissing =>
      'Achat intégré introuvable. Dans App Store Connect, associez « pro_unlock » à cette version et soumettez-la pour révision.';

  @override
  String get photoPreview => 'Aperçu photo';

  @override
  String get retake => 'Reprendre';

  @override
  String get save => 'Enregistrer';

  @override
  String get savedToDownloads =>
      'Enregistré dans Téléchargements (visible dans l\'album)';

  @override
  String get savedToAlbum => 'Enregistré dans l\'album';

  @override
  String saveFailed(String error) {
    return 'Échec de l\'enregistrement : $error';
  }

  @override
  String get photoPermissionTitle => 'Accès aux photos requis';

  @override
  String get photoPermissionBody =>
      'L\'enregistrement des photos nécessite l\'accès à la photothèque. Veuillez l\'autoriser dans Réglages.';

  @override
  String get openSettings => 'Ouvrir Réglages';

  @override
  String get cancel => 'Annuler';
}
