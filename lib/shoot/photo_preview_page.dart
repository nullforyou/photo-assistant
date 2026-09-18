import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_assistant/l10n/generated/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

import 'photo_saver.dart';

/// 拍照结果预览：查看 / 重拍 / 保存
class PhotoPreviewPage extends StatelessWidget {
  const PhotoPreviewPage({super.key, required this.imageBytes});

  final Uint8List imageBytes;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(s.photoPreview),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              maxScale: 4,
              child: Center(child: Image.memory(imageBytes)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.replay_rounded),
                      label: Text(s.retake),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final res = await savePhotoToGallery(imageBytes, context);
                        if (!context.mounted) return;
                        // 权限被永久拒绝：弹窗引导去系统设置开启（iOS 不会二次弹授权框）
                        if (res.settingsRequired) {
                          final goSettings = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(s.photoPermissionTitle),
                              content: Text(s.photoPermissionBody),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: Text(s.cancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: Text(s.openSettings),
                                ),
                              ],
                            ),
                          );
                          if (goSettings == true) {
                            await openAppSettings();
                          }
                          return;
                        }
                        messenger.showSnackBar(SnackBar(content: Text(res.message)));
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: Text(s.save),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
