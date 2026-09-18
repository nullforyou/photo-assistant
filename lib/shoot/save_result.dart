/// 保存结果。
/// - [ok]：是否成功。
/// - [settingsRequired]：权限被系统永久拒绝（用户曾在系统设置里关掉），
///   此时无法再弹系统授权框，必须由 UI 弹窗引导用户去「设置」里手动开启。
/// - [message]：给用户的提示文案。
class PhotoSaveResult {
  const PhotoSaveResult({
    required this.ok,
    required this.message,
    this.settingsRequired = false,
  });

  final bool ok;
  final String message;
  final bool settingsRequired;
}
