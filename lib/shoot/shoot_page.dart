import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../poses/pose_library.dart';
import 'photo_preview_page.dart';
import 'pose_painter.dart';

/// 拍照页：后置摄像头预览 + 闭环虚线姿势引导 + 底部姿势切换 + 快门
class ShootPage extends StatefulWidget {
  const ShootPage({super.key});

  @override
  State<ShootPage> createState() => _ShootPageState();
}

class _ShootPageState extends State<ShootPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraController? _controller;
  String? _cameraError;
  bool _isCapturing = false;
  int _selectedPose = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _cameraError = '未检测到可用摄像头');
        return;
      }
      // 优先选后置摄像头
      final back = cameras.where((c) {
        return c.lensDirection == CameraLensDirection.back;
      }).toList();
      final camera = back.isNotEmpty ? back.first : cameras.first;

      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _cameraError = null;
      });
    } on CameraException catch (e) {
      setState(() => _cameraError = '摄像头初始化失败：${e.description ?? e.code}');
    } catch (e) {
      setState(() => _cameraError = '摄像头初始化失败：$e');
    }
  }

  Future<void> _takePhoto() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }
    setState(() => _isCapturing = true);
    try {
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PhotoPreviewPage(imageBytes: bytes),
      ));
    } on CameraException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('拍照失败：${e.description ?? e.code}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final controller = _controller;
    if (_cameraError != null) {
      return _buildErrorView();
    }
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.tealAccent),
      );
    }

    final pose = kPoseLibrary[_selectedPose];

    return SafeArea(
      child: Stack(
        children: [
          // 相机预览（全屏铺满，像手机相机一样 cover 裁剪，无黑边）
          Positioned.fill(
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: CameraPreview(controller),
              ),
            ),
          ),
          // 闭环虚线姿势引导层（不会拍进照片）
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: PosePainter(pose: pose, fillRatio: 0.5),
              ),
            ),
          ),
          // 顶部提示
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '姿势 ${_selectedPose + 1}/${kPoseLibrary.length} · ${pose.name} · 按虚线摆好姿势',
                  style: const TextStyle(color: Colors.tealAccent, fontSize: 13),
                ),
              ),
            ),
          ),
          // 顶部返回
          Positioned(
            top: 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white70),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          // 底部控制区：快门 + 姿势切换条
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.6),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 姿势缩略图切换条
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kPoseLibrary.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final selected = index == _selectedPose;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPose = index),
                  child: Container(
                    width: 60,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? Colors.tealAccent : Colors.white24,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: CustomPaint(
                        painter: PosePainter(
                          pose: kPoseLibrary[index],
                          fillRatio: 0.9,
                          lineOpacity: selected ? 0.95 : 0.5,
                          showFill: false,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // 快门按钮
          GestureDetector(
            onTap: _takePhoto,
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: _isCapturing
                      ? const Padding(
                          padding: EdgeInsets.all(18),
                          child: CircularProgressIndicator(
                              color: Colors.teal, strokeWidth: 2),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_rounded,
                size: 64, color: Colors.white38),
            const SizedBox(height: 16),
            Text(
              _cameraError ?? '摄像头不可用',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _initCamera,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('重试'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('返回', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }
}
