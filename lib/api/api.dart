import 'dart:ui' as ui;

import '../poses/pose_data.dart';
import '../poses/pose_library.dart';

/// 姿势数据层（单机版，不再走接口）。
///
/// 数据来自内置打包的本地资源 [kDefaultPoseJson]（lib/poses/pose_data.dart），
/// 由 scripts/generate_poses_json.py 从仓库 poses.json 生成，三处（WSL 源 /
/// scripts/_generated_poses.json / 本地打包）保持同步。包含 styles、poses、
/// 以及 nameI18n / tipsI18n / 风格 nameI18n 多语言文案。
///
/// 多语言选取：按系统语言短码（en / zh / zh_Hant / ja / ...）从本地数据中
/// 就近选取，缺失时回退默认中文。
class PoseApi {
  /// 本地打包数据包（单机版唯一数据源，等效原服务端契约）。
  static PoseResult get defaultResult =>
      parseDefaultPoseResult(lang: _i18nLangKey());

  /// 读取本地打包的姿势数据。
  ///
  /// 保留 Future 返回值仅为兼容调用方已有的 `await` 写法；实际为同步返回，
  /// 不再有任何网络请求。
  static Future<PoseResult> fetchPoseData() async {
    return parseDefaultPoseResult(lang: _i18nLangKey());
  }

  /// 多语言选取用的语言 key（如 en / zh / zh_Hant / ja / ko ...）。
  ///
  /// 取系统首选 locale：中文区分繁体（zh_Hant）与简体（zh），其余语言直接用
  /// languageCode 短码，与本地数据中 nameI18n / tipsI18n / 风格 nameI18n 的
  /// 键对齐。缺失时由解析层回退默认中文 name。
  static String _i18nLangKey() {
    final locales = ui.PlatformDispatcher.instance.locales;
    if (locales.isEmpty) return 'zh';
    final l = locales.first;
    final lang = l.languageCode.toLowerCase();
    if (lang == 'zh') {
      final script = l.scriptCode?.toLowerCase();
      return script == 'hant' ? 'zh_hant' : 'zh';
    }
    return lang;
  }
}
