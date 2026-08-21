import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'photo_saver.dart';

/// 拍照结果预览：查看 / 重拍 / 保存
class PhotoPreviewPage extends StatelessWidget {
  const PhotoPreviewPage({super.key, required this.imageBytes});

  final Uint8List imageBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('照片预览'),
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
                      label: const Text('重拍'),
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
                        final msg = await savePhotoToGallery(imageBytes);
                        if (!context.mounted) return;
                        messenger.showSnackBar(SnackBar(content: Text(msg)));
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('保存'),
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
