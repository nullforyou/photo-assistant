// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class SPt extends S {
  SPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Assistente de Foto';

  @override
  String get welcomeSubtitle => 'Bem-vindo ao Photo Assistant';

  @override
  String get welcomeTagline =>
      'Guia de pose · faça uma pose, capture com um toque';

  @override
  String get startShooting => 'Começar';

  @override
  String get cameraNotDetected => 'Nenhuma câmera disponível';

  @override
  String cameraInitFailed(String error) {
    return 'Falha ao iniciar a câmera: $error';
  }

  @override
  String captureFailed(String error) {
    return 'Falha na captura: $error';
  }

  @override
  String get poseGuideTitle => 'Posicione-se conforme o contorno';

  @override
  String get noPoses => 'Nenhuma pose disponível';

  @override
  String get cameraUnavailable => 'Câmera indisponível';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get back => 'Voltar';

  @override
  String get unlockAllPoses => 'Desbloquear todas as poses';

  @override
  String unlockAllPosesBody(String count) {
    return 'Desbloqueia mais $count poses em cada estilo. Compra única, para sempre.';
  }

  @override
  String buyForPrice(String price) {
    return 'Desbloquear — $price';
  }

  @override
  String get restorePurchase => 'Restaurar compra';

  @override
  String get purchasePending => 'Compra em andamento…';

  @override
  String get purchaseSuccess => 'Todas as poses desbloqueadas';

  @override
  String get purchaseRestored => 'Compra restaurada';

  @override
  String purchaseFailed(String error) {
    return 'Falha na compra: $error';
  }

  @override
  String get storeUnavailable =>
      'A loja está indisponível. Tente novamente mais tarde.';

  @override
  String get iapProductMissing =>
      'Compra integrada não encontrada. No App Store Connect, associe o „pro_unlock“ a esta versão e envie para revisão.';

  @override
  String get photoPreview => 'Pré-visualização';

  @override
  String get retake => 'Refazer';

  @override
  String get save => 'Salvar';

  @override
  String get savedToDownloads => 'Salvo em Downloads (visível no álbum)';

  @override
  String get savedToAlbum => 'Salvo no álbum';

  @override
  String saveFailed(String error) {
    return 'Falha ao salvar: $error';
  }

  @override
  String get photoPermissionTitle => 'Acesso às fotos necessário';

  @override
  String get photoPermissionBody =>
      'Salvar fotos exige acesso à biblioteca de fotos. Permita em Configurações.';

  @override
  String get openSettings => 'Abrir Configurações';

  @override
  String get cancel => 'Cancelar';
}
