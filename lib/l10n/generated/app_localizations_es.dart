// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SEs extends S {
  SEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Asistente de Fotos';

  @override
  String get welcomeSubtitle => 'Bienvenido a Photo Assistant';

  @override
  String get welcomeTagline =>
      'Guía de poses · haz una pose y captura con un toque';

  @override
  String get startShooting => 'Empezar';

  @override
  String get cameraNotDetected => 'No hay cámara disponible';

  @override
  String cameraInitFailed(String error) {
    return 'Error al iniciar la cámara: $error';
  }

  @override
  String captureFailed(String error) {
    return 'Error al capturar: $error';
  }

  @override
  String get poseGuideTitle => 'Posa según el contorno';

  @override
  String get noPoses => 'No hay poses disponibles';

  @override
  String get cameraUnavailable => 'Cámara no disponible';

  @override
  String get retry => 'Reintentar';

  @override
  String get back => 'Atrás';

  @override
  String get unlockAllPoses => 'Desbloquear todas las poses';

  @override
  String unlockAllPosesBody(String count) {
    return 'Desbloquea $count poses más de cada estilo. Compra única, para siempre.';
  }

  @override
  String buyForPrice(String price) {
    return 'Desbloquear — $price';
  }

  @override
  String get restorePurchase => 'Restaurar compra';

  @override
  String get purchasePending => 'Compra en curso…';

  @override
  String get purchaseSuccess => 'Todas las poses desbloqueadas';

  @override
  String get purchaseRestored => 'Compra restaurada';

  @override
  String purchaseFailed(String error) {
    return 'Error en la compra: $error';
  }

  @override
  String get storeUnavailable =>
      'La tienda no está disponible. Inténtalo de nuevo más tarde.';

  @override
  String get photoPreview => 'Vista previa';

  @override
  String get retake => 'Volver a sacar';

  @override
  String get save => 'Guardar';

  @override
  String get savedToDownloads => 'Guardado en Descargas (visible en el álbum)';

  @override
  String get savedToAlbum => 'Guardado en el álbum';

  @override
  String saveFailed(String error) {
    return 'Error al guardar: $error';
  }

  @override
  String get photoPermissionTitle => 'Se necesita acceso a Fotos';

  @override
  String get photoPermissionBody =>
      'Guardar fotos requiere acceso a la fototeca. Permítelo en Ajustes e inténtalo de nuevo.';

  @override
  String get openSettings => 'Abrir Ajustes';

  @override
  String get cancel => 'Cancelar';
}
