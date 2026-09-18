# Guideline 2.1 拒审应对材料（Photo Assistant 1.0.0 (2)）

> 拒审原因：账号审核历史有限，Apple 要求补充信息（Guideline 2.1 - Information Needed）。
> **不需要改代码、不需要新 build。** 做三件事：① 录一段真机录屏 ② 把下面英文回复稿粘贴到 Resolution Center 并附上录屏 ③ 同样的内容也贴到 App Review Information → Notes 字段。之后点 `Resubmit to App Review`。

---

## 一、录屏脚本（最重要，先做这个）

**录制要求（Apple 原文要求）：**
- 用**真机 iPhone** 录（不能用模拟器/录屏软件录 AirPlay 画面）
- 手机系统升到**最新 iOS**（拒信明确写了 "running the latest operating system"，太老的系统版本可能被打回）
- **从主屏幕点开 App 开始录**（先开始录屏，再点图标，不要已经在 App 里才开始录）

**准备（可选但强烈推荐）：**
- 先把手机上的 App **删掉**，去 TestFlight 重新安装 1.0.0 (2) —— 这样录屏里能拍到**首次启动时的相机/照片权限弹窗**，审核员最爱看这个
- 若不想重装：设置 → 隐私与安全性 → 相机 → 关掉本 App 的权限，也能让弹窗重新出现

**拍摄脚本（60~120 秒，竖屏）：**

| 序号 | 操作 | 让审核员看到什么 |
|---|---|---|
| 1 | 控制中心 → 开始屏幕录制 | 从 iPhone 主屏幕开始 |
| 2 | 点 App 图标启动 | 启动画面 → 欢迎页（图标+标语+开始拍摄按钮） |
| 3 | 停留 2 秒展示欢迎页 | App 主界面完整 |
| 4 | 点「开始拍摄」 | **相机权限弹窗 → 点允许**（若已授权则跳过） |
| 5 | 相机页停留 3 秒 | 实时预览 + 发光姿势轮廓 + 提示气泡 |
| 6 | 点底部缩略图换 2~3 个姿势 | 轮廓和气泡跟着变 |
| 7 | 双指缩放/拖动轮廓，再双击复位 | 轮廓可调整 |
| 8 | 点顶部风格条切换一个风格（如霓虹） | 轮廓视觉风格切换 |
| 9 | 点快门 → 预览页 → 点保存 | 拍照 + 保存成功提示（照片权限弹窗若出现就允许） |
| 10 | 退出到系统「照片」App 晃一下 | 照片确实存进了相册 |
| 11 | 回主屏幕，控制中心停止录制 | 结束 |

**格式与传输：**
- iPhone 自带录屏生成 .MOV，存在照片 App 里
- 传到 Windows：数据线连电脑 → 文件资源管理器 → `Apple iPhone` → `Internal Storage\DCIM` → 拷出视频
- **导出文件太大时**：设置 → 相机 → 录制视频，改成 1080p/30fps 再录一遍（文件小一半以上）

---

## 二、Resolution Center 英文回复稿（直接整段复制粘贴）

> 粘贴位置：Distribution → 左侧 App Review → Messages 里 Apple 那条消息 → Reply → 粘贴以下文字 → 点附件（回形针）上传录屏视频 → Send。

```
Re: Guideline 2.1 - Information Needed (iOS App 1.0.0 (2))

Thank you for your message. The requested information is below, and a
screen recording captured on a physical iPhone running the latest iOS
version is attached to this reply. The recording begins with launching
the app from the Home Screen and demonstrates the complete typical user
flow, including the camera permission prompt, pose selection, style
switching, capturing a photo, and saving it to the Photo Library.

2. Purpose and target audience
Photo Assistant is an offline camera app that helps people pose for
photos. Many people feel awkward in front of the camera because they do
not know how to pose. The app overlays a translucent outline of a
selected pose on the live camera preview, so the person being
photographed can simply match their body to the outline. It is designed
for everyday users - travelers, couples, friends and social-media
content creators - who want better photos without professional
photography knowledge. It solves the "I never know how to pose" problem
and saves time on directing and retakes.

3. How to set up and access the main features
No account, sign-in, or sample files are required. Steps:
1. Launch the app.
2. Tap the shutter button on the welcome screen to open the camera;
   grant Camera and Photo Library access when prompted.
3. Select any pose from the thumbnail strip at the bottom - a
   translucent glowing outline of the pose appears on the live preview.
   The outline can be dragged, pinched to scale, and double-tapped to
   reset.
4. Optionally tap a style chip at the top to change the outline's
   visual style.
5. Tap the shutter to capture, then tap Save on the preview screen;
   the photo is written to the system Photo Library.
The attached screen recording demonstrates this complete flow.

4. External services, tools, or platforms
None. The app makes no network requests at runtime and uses no
analytics, advertising, authentication, payment, AI, or data-provider
services. All pose templates are bundled inside the app. The only
third-party components are standard open-source Flutter plugins
(camera, path_provider, saver_gallery) used to display the camera
preview and save photos locally.

5. Regional differences
There are none. The app is fully self-contained and functions
identically in all regions and countries. The interface supports 11
languages (English, Simplified Chinese, Traditional Chinese, Japanese,
Korean, French, German, Thai, Portuguese, Spanish, Turkish) and follows
the device language automatically.

6. Regulated industry / protected third-party material
Neither applies. The app does not operate in a regulated industry. All
pose outline artwork was originally created by us for this app; no
third-party, licensed, or protected material is included.

Additional notes: The app has no user accounts, so there are no
registration, login, or account-deletion flows to demonstrate. Users'
photos are saved only to their own device's Photo Library via the
system API; nothing is uploaded or shared. There are no in-app
purchases or subscriptions.
```

---

## 三、Notes 字段（同样内容，再贴一份）

> 位置：版本页 → App Review Information（App 审核信息）→ **Notes** 栏。
> Apple 原文要求 "also add this information to the Notes field ... for reference on future submissions"。
> 直接把上面第二节的文字**原样**粘贴进去即可（附件传不进 Notes，只贴文字）。

---

## 四、提交步骤清单

1. [ ] iPhone 升到最新 iOS，删除旧装、从 TestFlight 装 1.0.0 (2)
2. [ ] 按脚本录屏（60~120 秒），确认拍到了权限弹窗
3. [ ] 数据线把 .MOV 拷到电脑
4. [ ] App Store Connect → App Review → Messages → Reply：贴第二节文字 + 附件传视频 → Send
5. [ ] 版本页 → App Review Information → Notes：贴同一段文字
6. [ ] 回到 iOS Submission 页，点右上 `Resubmit to App Review`（回复后应会亮起；若仍灰，检查是否还有别的 Unresolved 项）
7. [ ] 等审核（一般 1~2 天；新账号首次被 2.1 追问后再审可能稍慢，属正常）

**审核期间纪律不变**：不改元数据、不动价格、不删 build。

---

## 五、常见疑问

**Q：需要重新出包/改代码吗？**
不需要。这是"补充信息"型驳回（2.1），同一 build 直接回复即可重新进队列。

**Q：为什么会被 2.1 追问？**
拒信原文写了 "developer account that has a limited App Review history" —— 新开发者账号第一次提消费类 App 的常规盘问，和 App 本身质量无关。回复充分即可，大部分一次过。

**Q：如果录屏文件太大传不上去？**
录制前把「设置 → 相机 → 录制视频」改为 1080p 30fps；或用格式工厂/剪映压缩到 200MB 以内再传。
