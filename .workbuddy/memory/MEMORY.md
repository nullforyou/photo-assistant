# 拍照助手 · 项目长期备忘

## 项目位置与构建
- **唯一项目目录：`D:\work\photo-assistant`**。用户 2026-08-27 从 C 盘迁移至此，此后只写 D 盘。
- Flutter SDK：`D:\Program Files\flutter\flutter_windows_3.47.1-stable`（stable 3.47.1 / Dart 3.13.1），勿重复安装。
- 包名 `com.chunyanyang.photoassistant`；欢迎页 `lib/main.dart`；拍照页 `lib/shoot/shoot_page.dart`。
- 构建 release APK 前：**`unset HTTP_PROXY HTTPS_PROXY`**，并设 `JAVA_TOOL_OPTIONS="-Djava.net.useSystemProxies=false -Dhttp.nonProxyHosts=* -Dhttps.nonProxyHosts=*"`。
- Android 安装：`"$LOCALAPPDATA/Android/Sdk/platform-tools/adb.exe" -s YSE0222628002738 install -r build/app/outputs/flutter-apk/app-release.apk`。

## 已修复的关键问题
- **Android 相机预览黑屏**：`CameraController` 不指定 `imageFormatGroup: jpeg`；`CameraPreview` 直接 `Positioned.fill` 不用 `FittedBox`；`PosePainter.paint` 已加 try/catch。清单/权限改动后必须「彻底停止再 flutter run」重装，热重载不生效。
- **保存图片无权限时静默失败**（2026-09-18）：新增 `permission_handler`，保存前预检 `Permission.photos`，永久拒绝时弹对话框引导 `openAppSettings()`；`albumPath` 失败自动退化为保存到「最近项目」。已出新 build 资格。

## 本地化与离线数据
- UI 文案：Flutter gen-l10n，11 语言（zh/zh_Hant/en/ja/ko/fr/de/th/pt/es/tr），`S.of(context)` 已接入 main/shoot/photo_preview/saver。
- 姿势名/tips/风格名按 `PoseApi._i18nLangKey()` 取短码，从内置 `lib/poses/pose_data.dart` 选取。中文繁简区分：`zh`→简体，`zh_hant`→繁体。其余按 languageCode 短码。
- 2026-09-01 起 App 为纯单机版：删除 `lib/api/crypto.dart`、`lib/config/app_config.dart`，移除 `http`/`crypto`/`encrypt` 依赖，`fetchPoseData()` 直接返回本地数据。
- 资源透明化：`scripts/make_one_pose.py` 处理白底线稿；照片/实景人像不适用，需 rembg/Photoshop。

## 品牌与图标
- 品牌色：`kBrandPink #FDADAD`、`kBrandPinkDeep #EE8188`、`kCream #FDF6F2`、`kInkPlum #6B3A42`、`kMutedPlum #B07A82`，全在 `lib/main.dart` 顶部。
- `ThemeData.seedColor` 已固定为 `kBrandPinkDeep`，不要再改回 teal。
- 换图标脚本：`C:/Users/81215/.workbuddy/binaries/python/envs/default/Scripts/python.exe scripts/make_app_icons.py --src "<设计稿.png>" --out "D:/work/photo-assistant/icon" --project "D:/work/photo-assistant" --install`。
- 品牌化漏网：保存按钮、缩略图选中边框、加载指示器仍有 teal，后续统一需抽 `lib/theme/brand.dart`。

## iOS 上架（2026-09-22 最新）
- Build 2 因「权限弹窗与界面语言不一致」被拒；Build 3 已修复 11 语言 `InfoPlist.strings` 并提交。
- **1.0.0 (3) 已于 2026-09-22 13:07 GMT+8 自动发布上线**；App Store Connect 显示 `Ready for Distribution`，这是新版 UI 对“已上架”的称呼。
- 公开链接：https://apps.apple.com/cn/app/photo-assistant-studio/id6811480568（iTunes Lookup 验证 175 国/地区均可查）。
- 商务/协议/税务/银行/国务院令 810 合规/地区可用性 175 国均正常。
- 收款：连连美国虚拟账户（Deutsche Bank Trust Company Americas，ABA `021001033`），Apple 打 USD → 连连换汇人民币 → 招行储蓄卡，不占 5 万美元结汇额度。
- 税表 W-8BEN + Certificate of Foreign Status 已提交；DSA 已申报为 Trader。
- TARGETED_DEVICE_FAMILY 已改为 `1`（仅 iPhone），出相应 build 才生效；截图用真机图经 `scripts/resize_store_screenshots.py` 处理。
