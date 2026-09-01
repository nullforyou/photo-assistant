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
}
