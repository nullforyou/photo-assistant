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

## 资源处理：素描图→透明 PNG（抠白底，非 AI 抠图）
- 源图 `image/NNN_姿势名.png`（1728×2304 RGB 白底线稿）→ 产物 `assets/poses/pose_NNN.png`（900×1200 RGBA，约 98% 透明）+ `pose_NNN_preview.png`（叠深色底便于肉眼查）。
- 技术=**亮度阈值抠图**：`min(R,G,B)>=243` 的像素置 α=0（兼容纯白底 255 与浅灰底如 005≈248，保留抗锯齿灰边防断线）；右下角"豆包AI"水印用 scipy 连通域定位、只删落在该区域且为灰字(平均亮度 208~252、非深色线条)的小连通域。降采样时**颜色与掩码分开 LANCZOS 再合成**，避免 RGBA 直接缩放产生椒盐噪点。
- 两个脚本：`scripts/make_one_pose.py`（单张/保守版，**最终用**——只去白底+右下角水印，保留所有灰线稿，是修"线条断断续续"后的版本）与 `scripts/make_poses_transparent.py`（批量/激进版——还去浅色字幕框、四角水印、浅色背景噪点，易误删浅灰线导致断线，是前者的反面教材）。
- 复刻依赖：Python + Pillow + numpy + scipy（venv `C:/Users/81215/.workbuddy/binaries/python/envs/default` 已装）。单张：`python scripts/make_one_pose.py <源图> [输出目录]`；批量：直接跑 `make_poses_transparent.py`（路径写死在项目内）。调参：背景阈值 243、水印区比例 `WM_X0_RATIO/WM_Y0_RATIO`、输出宽 `MAKE_ONE_MAXW`（默认 900）。
- **适用性边界**：仅对"白底/浅底线稿"有效（亮暗双峰分布）；**照片/实景人像不适用**，需用 rembg(U2Net) 或 Photoshop。彩底、极浅灰线、投影需另调阈值或加 pale-colored 检测（见批量脚本）。

## App 图标（全平台）
- 当前图标：2026-09-11 二次更换为粉底人物设计稿（726×732，圆角≈139，底色深粉 **#FDADAD**，人物描边 **#EE8888 系**），已安装到 android/ios/web/macos/windows 全部 41 个文件；旧图标的备份在 `icon/_original_backup/`（仅首次安装时生成，不会被覆盖）。
- **换图标只需一条命令**（脚本已泛化，自动补边成正方形、自动抠主体、自动检测自适应底色）：
  `C:/Users/81215/.workbuddy/binaries/python/envs/default/Scripts/python.exe scripts/make_app_icons.py --src "<设计稿.png>" --out "D:/work/photo-assistant/icon" --project "D:/work/photo-assistant" --install`
- 验收看两张图：`icon/preview.png`（母版 + 各尺寸辨识度）、`icon/android/adaptive_preview.png`（圆形遮罩下内容没被裁掉）。
- 踩坑细节（外沿假色环、描边同色系必须用连通性判背景）见 `2026-09-11.md`，并已沉淀进用户级技能 `app-icon-kit` v1.1.0。

## 品牌配色与首页（UI 规范）
- **品牌色常量定义在 `lib/main.dart` 顶部，全 App 复用**：`kBrandPink #FDADAD`（图标底色）、`kBrandPinkDeep #EE8188`（描边/主强调色）、`kCream #FDF6F2`（奶油白背景）、`kInkPlum #6B3A42`（暖调深字）、`kMutedPlum #B07A82`（次要字色）。改配色只改这几处。
- **`ThemeData.seedColor` 已从 `Colors.teal` 改为 `kBrandPinkDeep`**（2026-09-11）——**不要再改回 teal**，否则整 App 冷色强调与图标粉调再次冲突。
- 首页 `WelcomePage`（`lib/main.dart`）= 图标主视觉 + 虚线圆环 + 星芒 + 胶囊按钮，复刻图标视觉语言。**圆环必须与图标同 `Stack(alignment: center)` 居中，不能按屏幕居中**（会套偏）。详见 `2026-09-11.md`。
- 首屏用到 `assets/branding/app_icon_round.png`（圆角透明版），`pubspec.yaml` 已注册 `assets/branding/`。换图标后如要同步首屏，需重新拷贝该文件。
- ⚠️ **品牌化的漏网之鱼（未修）**：`lib/shoot/photo_preview_page.dart:53` 保存按钮仍是 `Colors.teal`；`lib/shoot/shoot_page.dart:454` 缩略图选中边框 `Colors.tealAccent`、`:498` 加载指示器 `Colors.teal`。要统一粉调需抽 `lib/theme/brand.dart` 再引用。

## iOS 上架（App Store）
- 用户已激活付费 Developer Program（$99/年），但**没有 Mac**。上传两条路：借/租 Mac 走 Xcode 标准流程；或走 `/.github/workflows/ios_release.yml`（GitHub Actions 云端 macos runner，需填 7 个 secret）。
- **Windows 侧已全部就绪**：`ios/Runner/Info.plist` 三个权限串 + 11 语言；`ios/Podfile`（手写标准模板，platform iOS 15.0）；`ios/ExportOptions.plist`（teamId 占位 YOUR_TEAM_ID / Bundle ID 已改为 `com.chunyanyang.photoassistant`）；`privacy_policy.html`；`store_listing.md`；`Bundle ID` 已从 `com.example.photoAssistant` 改为 **`com.chunyanyang.photoassistant`**（pbxproj 主 3 处 + 测试 3 处、macOS 4 处、ExportOptions、store_listing 均同步）。
- **上架进度（2026-09-14，最新）**：CI 全链路已跑通（**纯 SPM、已 `git rm ios/Podfile`**——不要再手写 Podfile 修 podhelper）；Fastlane 自动上传 TestFlight 可用。收款走 **连连美国虚拟账户**（Deutsche Bank Trust Company Americas，ABA `021001033` / 账号 00374475001065517）：Apple 打 USD → 连连换汇人民币 → 提现招行储蓄卡，**不需要双币卡、不占 5 万美元结汇额度**。两张美国税表（Certificate of Foreign Status + W-8BEN，Part II 主张中美协定 Article 12 / 10% 预扣）已提交。**DSA 已申报为 Trader**（联系信息用身份证住址，欧盟 27 国产品页会公开地址/电话/邮箱，不可隐藏）。**1.0.0 已于 2026-09-14 17:11 提交审核**。
- **上架待办（未完成项）**：① 付费 App 协议 Active 后 → Pricing and Availability 设付费档位（价格变更单独审核，不需重提版本）② 商务 → 协议 → Compliance → **国务院令810号 `Add Info`**（填居民身份证号码 + 身份证上的姓名，季度报送，不填影响打款）③ 过审后需**手动 Release**（当初选的是 Manually release this version）。⚠️ 商店名 `Photo Assistant Studio`（ASC）与桌面名 `Photo Assistant`（Info.plist `CFBundleDisplayName`）不同，**属正常、不影响审核**。
- 商店截图：`scripts/make_appstore_screenshots.py` 生成 6.7"(1290×2796) + 6.5"(1242×2688)；现用真机截图经 `scripts/resize_store_screenshots.py` 换算替换（旧渲染图在 `store_screenshots/_archive/`）。**`TARGETED_DEVICE_FAMILY` 已改为 `1`（仅 iPhone），免 iPad 截图**，但需出新 build 才生效。
- ⚠️ **权限弹窗文案本地化（2026-09-18 修复，勿回退）**：`ios/Runner/<lang>.lproj/InfoPlist.strings` 必须同时含 `CFBundleDisplayName` + **3 条权限说明**（`NSCameraUsageDescription` / `NSPhotoLibraryAddUsageDescription` / `NSPhotoLibraryUsageDescription`），共 **11 语言**（en/zh-Hans/zh-Hant/ja/ko/fr/de/es/pt/th/tr）。新增语言必须同步改 `project.pbxproj` 三处：`PBXFileReference` + `PBXVariantGroup(InfoPlist.strings).children` + `knownRegions`，**少一处文件就不会打进 App 包**。`Info.plist` 三条权限文案的兜底值保持**英文**（对齐 `developmentRegion = en`）。`lib/main.dart` 的 `supportedLocales` **`Locale('en')` 必须放首位**——Flutter 对不在清单内的设备语言回退取列表**第一项**，曾把 zh 放首位，造成"界面中文 + 弹窗英文"（或反之）被 App Review 判「权限请求与应用本地化语言不一致」。
- **App Review 两次被驳**：① 09-15 Guideline 2.1 信息不足（新账号常规盘问，要真机录屏+6 项说明，见 `app_review_reply_2.1.md`）② 09-18 UI 语言不一致（权限文案未本地化，见 `app_review_reply_localization.md`）。两次都不需要改功能，但第二次必须出新 build。中文回复稿与录屏脚本模板可直接复用。

