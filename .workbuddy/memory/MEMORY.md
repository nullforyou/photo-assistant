# 拍照助手 · 项目长期备忘

## 项目位置（重要变更 —— 反复踩坑，务必锁定）
- **唯一活动项目目录：`D:\work\photo-assistant`。用户已于 2026-08-27 把项目从 C 盘整体移到 D 盘，此后所有读写只认 D 盘。**
- ⚠️ **C:\work\photo-assistant 已不再是项目（已被移走/弃用），绝对不要往 C 盘写任何代码或资源，否则用户看不到。**
- ⚠️ 历史教训：上一轮曾误把代码写进 C 盘旧副本，导致用户在 IDEA 里什么都看不到。本机所有文件操作前先确认路径是 `D:\work\photo-assistant` 开头。
- Flutter SDK: `D:\Program Files\flutter\flutter_windows_3.47.1-stable`（stable 3.47.1 / Dart 3.13.1，用户预装勿重复装）。
- 包名 `photo_assistant`，欢迎页 `lib/main.dart`，拍照页 `lib/shoot/shoot_page.dart`。

## 构建 release APK 的必做前置（Windows 本机）
1. `unset HTTP_PROXY HTTPS_PROXY`（系统 Clash 代理 127.0.0.1:7897 会掐 Gradle 下载）。
2. `export JAVA_TOOL_OPTIONS="-Djava.net.useSystemProxies=false -Dhttp.nonProxyHosts=* -Dhttps.nonProxyHosts=*"`。
3. 已修的 `android/build.gradle.kts`：给 `camera_android_camerax` 模块 `dependencies.add("implementation","androidx.concurrent:concurrent-futures:1.2.0")`（用 `plugins.withId("com.android.library")`，非 afterEvaluate）。
4. 装手机：`"$LOCALAPPDATA/Android/Sdk/platform-tools/adb.exe" -s YSE0222628002738 install -r build/app/outputs/flutter-apk/app-release.apk`（设备 ID: YSE0222628002738）。

## 注意事项
- `kotlin.incremental=false`（曾加在 gradle.properties）无效，可删。
- 火绒实时防护曾被怀疑锁 `.tab` 缓存，但真凶是跨盘符，加白名单非必需。
- **相机预览黑屏（Android）已修**：`CameraController` 不要指定 `imageFormatGroup: jpeg`（部分机型预览整片黑，拍照正常）；`CameraPreview` 不要用 `FittedBox` 包裹，直接 `Positioned.fill(child: CameraPreview(...))` 最稳。`AndroidManifest.xml` 已显式声明 `CAMERA` 权限。`PosePainter.paint` 已加 try/catch 防崩兜底。改清单/权限后必须「彻底停止再 flutter run」重装，热重载不生效。

## 语言本地化状态（2026-08-29 落地）
- **Track A UI 文案**：Flutter gen-l10n，11 语言（zh/zh_Hant/en/ja/ko/fr/de/th/pt/es/tr），`S.of(context)` 已在 main/shoot/photo_preview/saver 接入。
- **Track B 本地数据（单机版）**：姿势名/tips/风格名走**客户端按需选语言**——`PoseApi._i18nLangKey()` 取短码，解析层 `PoseResult/Pose/PoseStyle.fromJson(lang:)` 按 `nameI18n[lang]??name`、`tipsI18n[lang]??tips` 选取。数据来自内置打包的 `lib/poses/pose_data.dart`（`kDefaultPoseJson`），由 `scripts/generate_poses_json.py` 生成。**2026-09-01 起 App 改为纯单机版、彻底移除接口/签名/加密**：删 `lib/api/crypto.dart`、`lib/config/app_config.dart`，并从 pubspec 移出 `http`/`crypto`/`encrypt` 依赖，`fetchPoseData()` 现在直接返回本地打包数据、不再有任何网络请求。**
- **`_i18nLangKey()` 的繁/简区分（关键）**：方法现位于 `lib/api/api.dart`（`PoseApi._i18nLangKey()`，原在已删除的 crypto.dart）。中文必须区分 `zh_hant`（繁体）与 `zh`（简体，回退到默认 `name`）。逻辑：取系统首选 locale，languageCode=='zh' 时看 scriptCode——`hant`→`'zh_hant'`，否则→`'zh'`；其余语言直接返回 languageCode 短码。原 `languageCode.toLowerCase()` 会把繁体也当 `zh`，导致繁体回退简体（用户"设繁体仍显示简体"的根因）。
- **数据键约定**：`nameI18n`/`tipsI18n`/风格`nameI18n` 用短码键（en/zh_Hant/ja/ko/fr/de/th/pt/es/tr）。**关键：姿势名(Pose.name) 不在界面渲染（grep 确认仅 `style.name` 与 tips 可见），故未翻译姿势名，只翻了「风格名 + 提示气泡」**。各语言数据来源：`en`/`zh_Hant` 由 `scripts/generate_poses_json.py` 生成（zh_Hant 用 OpenCC s2twp 简→繁，tips 保留 `{text,x,y}` 坐标）；`ja/ko/fr/de/th/pt/es/tr` 的 tips（37 个去重短语，坐标原样继承）与风格名（5 个）由 `scripts/pose_i18n_extra.py` 提供（AI 初稿，待母语校对）。重跑生成器即同步 WSL / `_generated_poses.json` / `pose_data.dart` 三处。
- **生成器跑法（重要）**：必须在含 `opencc-python-reimplemented` 的隔离 venv 下运行才会真正转繁体——`C:/Users/81215/.workbuddy/binaries/python/envs/default/Scripts/python.exe scripts/generate_poses_json.py`。用系统 python 跑会打印警告且 zh_Hant 回退为简体。跑完同步 WSL / `_generated_poses.json` / `pose_data.dart` 三处。
- **WSL poses.json**：含 5 风格（minimal/dual_outline/neon/soft_glow/none），`activeStyle:'none'`（无光影=默认双层、tint:null）。`none` 曾整块丢失，已由 `scripts/generate_poses_json.py` 兜底补回（重跑即修复三处：WSL/_generated_poses.json/pose_data.dart）。
- 改本地化或离线数据后必须 `flutter run` 重装验收（热重载不生效）。
