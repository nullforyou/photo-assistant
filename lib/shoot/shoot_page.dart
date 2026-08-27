import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../api/api.dart';
import '../poses/pose_data.dart';
import '../poses/pose_library.dart';
import 'photo_preview_page.dart';
import 'pose_painter.dart';

/// 拍照页：后置摄像头预览 + 发光人形姿势引导 + 底部姿势切换 + 快门。
///
/// 姿势与光影方案由接口下发（[Api]），默认跟随接口 activeStyle；
/// 顶部风格条可在本地临时预览/对比不同方案，不影响接口控制。
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

  /// 接口下发的完整数据包（默认先用内置兜底，加载完成后替换为接口数据）。
  PoseResult _result = defaultPoseResult;
  List<Pose> _poses = defaultPoseResult.poses;

  /// 本地预览覆盖的风格 id；为 null 时跟随接口 activeStyle。
  String? _styleOverride;

  int get _safeIndex =>
      _poses.isEmpty ? 0 : _selectedPose.clamp(0, _poses.length - 1);
  Pose get _currentPose => _poses[_safeIndex];

  String get _effectiveStyleId => _styleOverride ?? _result.activeStyle;
  PoseStyle get _effectiveStyle =>
      _result.styles[_effectiveStyleId] ??
      _result.styles[_result.activeStyle] ??
      _result.styles.values.first;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPoses();
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
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _controller?.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      if (_controller == null) _initCamera();
    }
  }

  Future<void> _loadPoses() async {
    final result = await Api.fetchPoseData();
    if (!mounted) return;
    setState(() {
      _result = result;
      _poses = result.poses;
      if (_selectedPose >= _poses.length) _selectedPose = 0;
    });
  }

  Future<void> _initCamera() async {
    try {
      final status = await Permission.camera.status;
      if (!status.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          if (result.isPermanentlyDenied) {
            setState(() =>
                _cameraError = '摄像头权限被永久拒绝，请在系统设置中开启后重试');
          } else {
            setState(() => _cameraError = '未授予摄像头权限，无法拍照');
          }
          return;
        }
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _cameraError = '未检测到可用摄像头');
        return;
      }
      final back =
          cameras.where((c) => c.lensDirection == CameraLensDirection.back).toList();
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

    final pose = _currentPose;
    final style = _effectiveStyle;

    // 相机预览比例
    final previewSize = controller.value.previewSize;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final boxRatio = (previewSize != null)
        ? (isPortrait
            ? previewSize.height / previewSize.width
            : previewSize.width / previewSize.height)
        : controller.value.aspectRatio;

    return SafeArea(
      child: Stack(
        children: [
          // 相机预览
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: boxRatio,
                height: 1,
                child: CameraPreview(controller),
              ),
            ),
          ),
          // 发光人形姿势引导层
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: PosePainter(
                        pose: pose,
                        style: style,
                        fillRatio: 0.5,
                      ),
                    ),
                  ),
                  if (style.showTips && pose.tips.isNotEmpty)
                    _buildTipsOverlay(style, pose),
                ],
              ),
            ),
          ),
          // 顶部：姿势信息 + 风格状态 + 风格条
          Positioned(
            top: 44,
            left: 8,
            right: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '姿势 ${_safeIndex + 1}/${_poses.length} · ${pose.name} · 按轮廓摆好姿势',
                    style:
                        const TextStyle(color: Colors.tealAccent, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _result.fromServer
                      ? '● 接口生效 · ${_result.activeStyle}'
                      : '○ 离线兜底 · ${_result.activeStyle}',
                  style: TextStyle(
                    fontSize: 10,
                    color: _result.fromServer
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStyleBar(),
              ],
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
          // 底部控制区
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomControls(style),
          ),
        ],
      ),
    );
  }

  /// 顶部光影方案条：默认跟随接口 activeStyle，点击可本地临时预览其它方案。
  Widget _buildStyleBar() {
    final ids = _result.styles.keys.toList();
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final id in ids)
          GestureDetector(
            onTap: () => setState(
                () => _styleOverride = (_styleOverride == id ? null : id)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _effectiveStyleId == id
                      ? _effectiveStyle.innerColor
                      : Colors.white24,
                  width: _effectiveStyleId == id ? 2 : 1,
                ),
              ),
              child: Text(
                _result.styles[id]?.name ?? id,
                style: TextStyle(
                  color: _effectiveStyleId == id
                      ? _effectiveStyle.innerColor
                      : Colors.white70,
                  fontSize: 11,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 提示气泡：按关键点定位到屏幕坐标。
  Widget _buildTipsOverlay(PoseStyle style, Pose pose) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final matrix = PosePainter.transformFor(size, 0.5);
        final bubbles = <Widget>[];
        for (var i = 0; i < pose.tips.length; i++) {
          final pos = i < pose.keyPoints.length
              ? PosePainter.transformPoint(matrix, pose.keyPoints[i])
              : null;
          final left = (pos?.dx ?? size.width / 2) + 12;
          final top = (pos?.dy ?? 40) - 28;
          bubbles.add(
            Positioned(
              left: left.clamp(8.0, size.width - 130),
              top: top.clamp(8.0, size.height - 48),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 130),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: style.innerColor.withValues(alpha: 0.85),
                    width: 1,
                  ),
                ),
                child: Text(
                  pose.tips[i],
                  style: TextStyle(
                    color: style.innerColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        }
        return Stack(children: bubbles);
      },
    );
  }

  Widget _buildBottomControls(PoseStyle style) {
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
            height: _result.thumbnail.listHeight,
            child: _poses.isEmpty
                ? const Center(
                    child: Text('无可用姿势',
                        style: TextStyle(color: Colors.white54)))
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _poses.length,
                    separatorBuilder: (_, _) => SizedBox(
                        width: _result.thumbnail.itemSpacing),
                    itemBuilder: (context, index) {
                      final selected = index == _safeIndex;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedPose = index),
                        child: Container(
                          width: _result.thumbnail.itemWidth,
                          height: _result.thumbnail.itemHeight,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? Colors.tealAccent
                                  : Colors.white24,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: CustomPaint(
                              painter: PosePainter(
                                pose: _poses[index],
                                style: style,
                                fillRatio: 0.9,
                                showKeyPoints: false,
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
            if (_cameraError != null &&
                _cameraError!.contains('永久拒绝'))
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: FilledButton.icon(
                  onPressed: () => openAppSettings(),
                  icon: const Icon(Icons.settings_rounded),
                  label: const Text('去系统设置开启'),
                ),
              ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child:
                  const Text('返回', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }
}
