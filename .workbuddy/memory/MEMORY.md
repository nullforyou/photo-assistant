# 拍照助手 · 项目长期备忘

## 项目位置（重要变更）
- **活动项目目录已迁到 `C:\work\photo-assistant`**（与 Flutter Pub 缓存同盘，避免跨盘符 Kotlin 构建 bug）。原 `D:\work\photo-assistant` 副本保留但建议弃用。
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
