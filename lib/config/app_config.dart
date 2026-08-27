/// 全局配置：把易变参数集中在这里，方便后期统一修改。
///
/// 例如更换后端域名时，只需修改 [apiBaseUrl] 这一行，
/// 各接口代码无需改动（接口统一在 lib/api/api.dart 中基于本配置拼装地址）。
class AppConfig {
  /// 后端接口域名（不含路径、不含末尾斜杠）。
  /// 换域名 / 换环境（测试/生产）只改此处。
  static const String apiBaseUrl = 'https://api.genopen.top';

  /// 接口请求超时时间。网络不佳时避免长时间阻塞 UI。
  static const Duration apiTimeout = Duration(seconds: 8);
}
