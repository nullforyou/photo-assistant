# 第 2 次拒审应对：权限请求与应用本地化语言不一致

> 拒审要点：**"该应用包含的权限请求与应用本地化语言不一致"**（Guideline 4.0 Design / 2.1 UI 一致性口径）。
> 已定位根因并在工程侧修复，需**出新包**（1.0.0 build 3）后回复 + 重提。

---

## 一、根因（已确认）

| 现象 | 事实 | 后果 |
|---|---|---|
| `ios/Runner/<lang>.lproj/InfoPlist.strings` 存在 7 个 | 但**只有 `CFBundleDisplayName` 一行**，三个权限说明全缺 | 任何语言下系统权限弹窗都回落到 `Info.plist` 的**中文**原文 |
| App 界面支持 11 种语言 | 英文设备上界面是英文 | 审核员看到 **英文界面 + 中文权限弹窗** → 判 UI 不一致 |
| 本地化语言不齐 | 只有 7 种（en/zh-Hans/ja/ko/fr/de/es） | 缺 zh-Hant / th / pt / tr，这 4 种语言的用户同样会看到中文弹窗 |
| `Info.plist` 兜底文案为中文 | 而工程 `developmentRegion = en` | 非 11 种语言（如意大利语）设备：界面与弹窗兜底还可能不一致 |

## 二、本轮已改的内容（均已写入仓库）

| 文件 | 改动 |
|---|---|
| `ios/Runner/{en,zh-Hans,ja,ko,fr,de,es}.lproj/InfoPlist.strings` | 补齐 3 条权限说明（原文保留在各自的 `NSCameraUsageDescription` / `NSPhotoLibraryAddUsageDescription` / `NSPhotoLibraryUsageDescription`） |
| `ios/Runner/{zh-Hant,pt,th,tr}.lproj/InfoPlist.strings` | **新增** 4 个语言文件，含显示名 + 3 条权限说明 |
| `ios/Runner.xcodeproj/project.pbxproj` | 新增 4 个 `PBXFileReference` + 加入 `InfoPlist.strings` 变体组（PBXVariantGroup）+ `knownRegions` 补齐 11 语言（否则文件不会被拷进 App 包） |
| `ios/Runner/Info.plist` | 3 条权限文案的**兜底值从中文改为英文**（与 `developmentRegion = en` 一致） |
| `lib/main.dart` | `supportedLocales` 把 `Locale('en')` 提到首位 —— 设备语言不在 11 种内时 Flutter 回退到**第一项**，这样"界面兜底"与"弹窗兜底"都是英文 |
| `pubspec.yaml` | 版本号 1.0.0+1 → 1.0.0+**3**（CI 会用 `--build-number=3` 出包） |

**覆盖矩阵（修复后）**：11 种语言各自有对应弹窗文案；其余语言界面与弹窗统一走英文兜底。任何设备语言下，界面语言 = 权限弹窗语言。

---

## 三、你要做的事

### 第 1 步：出新包（GitHub Actions）
仓库 → Actions → **iOS Release Upload** → Run workflow：
- `version` = `1.0.0`
- `build` = `3`

跑完等 TestFlight 出现 `1.0.0 (3)`（约 10~20 分钟构建 + 几分钟处理）。

### 第 2 步：版本页换 Build
Distribution → iOS App 1.0.0 版本页 → **Build** 区 → 点 `+`/选择 → 选 **1.0.0 (3)**（替换掉被拒的 (2)）。

### 第 3 步：Resolution Center 回复（英文，可直接粘）

```
Hello,

Thank you for the review. We have fixed the inconsistency between the
app's localization and its permission requests.

Root cause: the camera and photo library usage descriptions
(NSCameraUsageDescription, NSPhotoLibraryAddUsageDescription,
NSPhotoLibraryUsageDescription) were only provided in Chinese, while the
app's interface is localized into 11 languages. As a result, the system
permission dialogs fell back to Chinese on devices set to other
languages, producing Chinese permission prompts on an English (or other
language) interface.

Fix implemented in build 1.0.0 (3):
1. Localized usage descriptions were added for all 11 supported
   languages (English, Simplified Chinese, Traditional Chinese, Japanese,
   Korean, French, German, Spanish, Portuguese, Thai, Turkish) via
   localized InfoPlist.strings files.
2. The base (fallback) values in Info.plist are now in English, matching
   the project's development region.
3. The app's fallback locale is now English, so for any device language
   outside the 11 supported languages the interface and the permission
   dialogs are both displayed in English.

The interface language and the permission request language are now always
consistent. Please review build 1.0.0 (3).

Thank you.
```

### 第 4 步：Notes 字段同步
版本页 → App Review Information → **Notes** 也贴一份上面这段（同样内容），保持两处一致。

### 第 5 步：重提
右上角 `Resubmit to App Review` → 提交。审核期间**不要动元数据/价格/build**。

---

## 四、验收小抄（自己先验一遍更稳）

在 iPhone 上把系统语言切到 **English** → 删掉 App 重新安装 → 首次进相机页，权限弹窗应当是**英文**；再切到 **日本語** 验证一次；最后切回中文确认是中文。改动前英文设备会弹中文，这就是审核员看到的问题。

> 注意：切系统语言后要**重装 App**（或至少重启）才会重新请求权限；权限已授权时不会再弹窗，可先在 设置 → 隐私与安全性 → 相机 里关掉本 App 的权限再进 App。
