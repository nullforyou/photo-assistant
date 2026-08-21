# 拍照助手 · 项目长期备忘

## 本机已有环境（用户预装，勿重复安装）
- **Flutter SDK**: `D:\Program Files\flutter\flutter_windows_3.47.1-stable`（stable 3.47.1 / Dart 3.13.1）。这是用户已有的，已验证可用，**不要再克隆第二份**。
- **IntelliJ IDEA**: `D:\Program Files\JetBrains\IntelliJ IDEA 2025.2.6.1`（Flutter 官方支持 IDE，装 Flutter 插件即可）。
- **Git**: `D:\Program Files\Git`。
- **项目目录**: `D:\work\photo-assistant`（Dart 包名 `photo_assistant`），欢迎页在 `lib/main.dart`。已从中文路径 `D:\work\拍照助手\photo-assistant` 迁至纯英文路径（中文父目录会搞崩 `flutter analyze` 的 LSP 服务器）。

## 重要坑：中文路径会搞崩 `flutter analyze`
- 项目父目录含中文 `拍照助手`，导致 `flutter analyze` 的 LSP 分析服务器解析路径 JSON 时崩溃（exit 255，报 `FormatException: Unexpected end of input`，卡在 `%E6%89%8B`=“拍”的 URL 编码）。
- **代码本身没问题**：用 `dart analyze`（`D:\Program Files\flutter\flutter_windows_3.47.1-stable\bin\cache\dart-sdk\bin\dart.exe analyze`）验证通过，No issues found!
- 建议：把项目移到**纯英文路径**（如 `D:\work\photo-assistant`），可避免 analyze 崩溃及后续 Android/Gradle 对非 ASCII 路径的兼容问题。

## 运行前置（尚未完成）
- 需安装 **Android Studio** 并配置 Android SDK + 模拟器，才能在设备上 `flutter run` 看到欢迎页。
- IDEA 里 Flutter SDK 路径指向 `D:\Program Files\flutter\flutter_windows_3.47.1-stable`。
