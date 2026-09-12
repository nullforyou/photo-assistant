# App Store 上架文案（拍照助手 / Photo Assistant）

> 把下面内容填进 App Store Connect 对应字段即可。占位项需替换为真实值。

## 基本信息
- **App 名称**：拍照助手
- **副标题（Subtitle）**：姿势引导 · 一键出片
- **主语言**：简体中文
- **类别**：摄影与录像（Photography）
- **年龄分级**：4+（无不良内容）
- **Bundle ID**：`com.chunyanyang.photoassistant`
- **版本号**：1.0.0 / Build 1
- **加密出口合规（Export Compliance）**：否（App 不含加密功能）— App Store Connect 中勾选 "No"

## 中文描述（Description）
拍照助手是一款帮你摆好姿势、轻松拍出好照片的工具。

- 内置多种姿势模板，拍摄时以半透明轮廓叠加在取景画面上，实时对照摆姿
- 支持 11 种界面语言（简/繁中文、英、日、韩、法、德、泰、葡、西、土）
- 拍完一键保存到相册，全程在本地完成，照片不上传、不收集
- 清新粉调界面，所见即所得

无论你是想拍出更自然的自拍、还是记录生活瞬间，拍照助手都能让"摆姿"这件事变得简单。

## 英文描述（Description）
Photo Assistant helps you pose and capture great shots with ease.

- Built-in pose templates overlaid as translucent outlines on the live camera preview for real-time guidance
- 11 interface languages (Simplified/Traditional Chinese, English, Japanese, Korean, French, German, Thai, Portuguese, Spanish, Turkish)
- One-tap save to your photo library; everything runs on-device — no uploads, no data collection
- Clean, friendly pink-themed UI

Whether you want more natural selfies or simply better everyday photos, Photo Assistant makes posing effortless.

## 关键词（Keywords，逗号分隔）
姿势引导,摆姿,拍照辅助,摄影,自拍,pose,camera,photography,selfie,guide

## 宣传文本 / 推广文案（Promotional Text）
摆姿不再靠想象——透明轮廓实时叠加，拍出你想要的每一张。

## 隐私政策网址（Privacy Policy URL）← 必填
- 本仓库的 GitHub Pages：`https://<你的用户名>.github.io/photo-assistant/privacy_policy.html`
- 或任意可公开访问的网址（部署后替换）

## 支持网址（Support URL）
- 同上 GitHub Pages 或开发者站点

## 截图（已生成，位于 `store_screenshots/`）

| 尺寸 | 目录 | 张数 | 说明 |
|---|---|---|---|
| 6.7" 1290×2796 | `store_screenshots/6.7/` | 4 | iPhone 15/14 Pro Max，**主提交尺寸** |
| 6.5" 1242×2688 | `store_screenshots/6.5/` | 4 | iPhone 11 Pro Max 等 |

内容（顺序即上传顺序）：
1. `01_home` — 首页
2. `02_shoot_pose1` — 拍照引导（姿势轮廓 + 提示气泡 + 光影方案条）
3. `03_shoot_pose2` — 拍照引导（换姿势 / 换光影方案）
4. `04_preview` — 照片预览（重拍 / 保存 +「已保存到相册」）

- `_contact_sheet.png` 是 4 张总览，仅供预览，**不要上传**。
- **5.5"（1242×2208）不必单独做**：App Store Connect 上传 6.7" 后可勾选"用于较小尺寸"自动复用。
- 生成脚本：`scripts/make_appstore_screenshots.py`，改文案/姿势后重跑即可。
- ⚠️ 这是依据真实设计与资源的**渲染图**，非真机抓屏；拿到 Mac 能真机运行后建议替换为真实截图。

## 审核备注（可选填 App Review Information）
- 无需登录账号
- 无需特殊演示环境
- 联系邮箱填你的开发者邮箱
