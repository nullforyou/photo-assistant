// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Photo Assistant';

  @override
  String get welcomeSubtitle => 'Welcome to Photo Assistant';

  @override
  String get welcomeTagline => 'Pose guidance · strike a pose, snap in one tap';

  @override
  String get startShooting => 'Start Shooting';

  @override
  String get cameraNotDetected => 'No available camera detected';

  @override
  String cameraInitFailed(String error) {
    return 'Camera init failed: $error';
  }

  @override
  String captureFailed(String error) {
    return 'Capture failed: $error';
  }

  @override
  String get poseGuideTitle => 'Pose along the outline';

  @override
  String get noPoses => 'No poses available';

  @override
  String get cameraUnavailable => 'Camera unavailable';

  @override
  String get retry => 'Retry';

  @override
  String get back => 'Back';

  @override
  String get photoPreview => 'Photo Preview';

  @override
  String get retake => 'Retake';

  @override
  String get save => 'Save';

  @override
  String get savedToDownloads => 'Saved to Downloads (viewable in album)';

  @override
  String get savedToAlbum => 'Saved to album';

  @override
  String saveFailed(String error) {
    return 'Save failed: $error';
  }
}
