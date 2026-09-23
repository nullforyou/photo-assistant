import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_assistant/l10n/generated/app_localizations.dart';

import '../api/api.dart';
import '../poses/pose_library.dart';
import '../store/paywall.dart';
import '../theme/brand.dart';
import '../store/purchase_service.dart';
import 'photo_preview_page.dart';
import 'pose_painter.dart';

/// 拍照页：后置摄像头预览 + 发光人形姿势引导 + 底部姿势切换 + 快门。
///
/// 姿势与光影方案来自本地打包数据（[PoseApi]，单机版唯一数据源），
/// 默认跟随数据 activeStyle；顶部风格条可在本地临时预览/对比不同方案。
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
  bool _cameraInitializing = false;

  /// 本地打包的完整数据包（单机版唯一数据源）。
  PoseResult _result = PoseApi.defaultResult;
  List<Pose> _poses = PoseApi.defaultResult.poses;

  /// 内购服务（单例）。
  final PurchaseService _purchase = PurchaseService.instance;

  /// 本地数据是否已加载完成。未加载完成前不渲染 tips，
  /// 避免加载瞬间闪出一个“默认 tip”。
  bool _posesLoaded = false;

  /// 本地预览覆盖的风格 id；为 null 时跟随数据 activeStyle。
  String? _styleOverride;

  /// 姿势层的用户手势变换：缩放比例与位移（屏幕像素）。0.3~4 倍可缩放，位移可拖动。
  double _poseScale = 1.0;
  Offset _poseOffset = Offset.zero;
  double _gestureBaseScale = 1.0;
  Offset _gestureBaseOffset = Offset.zero;
  Offset _gestureStartFocal = Offset.zero;

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
    _initCamera();
    _loadPoses();
    _initPurchase();
  }

  void _initPurchase() {
    _purchase.init();
    _purchase.unlocked.addListener(_onPurchaseUnlocked);
  }

  void _onPurchaseUnlocked() => setState(() {});

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _purchase.unlocked.removeListener(_onPurchaseUnlocked);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 息屏 / 切后台 / 失去焦点时释放摄像头，回到前台时重建。
    // 注意：resumed 分支绝不能加「_controller==null 就 return」的前置判断——
    // inactive 已把 _controller 置空，若 resumed 直接返回，重建永远不执行，
    // 页面就会停在黑屏转圈。这里只要没有「已初始化」的控制器就必须重建。
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _controller?.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      if (_controller == null || !_controller!.value.isInitialized) {
        _initCamera();
      }
    }
  }

  Future<void> _loadPoses() async {
    final result = await PoseApi.fetchPoseData();
    if (!mounted) return;
    setState(() {
      _result = result;
      _poses = result.poses;
      if (_selectedPose >= _poses.length) _selectedPose = 0;
      _posesLoaded = true;
    });
  }

  Future<void> _initCamera() async {
    if (_cameraInitializing) return;
    _cameraInitializing = true;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _cameraError = S.of(context).cameraNotDetected);
        return;
      }
      final back = cameras
          .where((c) => c.lensDirection == CameraLensDirection.back)
          .toList();
      final camera = back.isNotEmpty ? back.first : cameras.first;

      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        // 注意：不要指定 imageFormatGroup=jpeg。部分 Android 机型在 jpeg
        // 格式组下预览纹理会整片黑（但拍照正常）。用默认 yuv420 兼容性最好。
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
      setState(() => _cameraError = S.of(context).cameraInitFailed(e.description ?? e.code));
    } catch (e) {
      setState(() => _cameraError = S.of(context).cameraInitFailed(e.toString()));
    } finally {
      _cameraInitializing = false;
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
          SnackBar(content: Text(S.of(context).captureFailed(e.description ?? e.code))),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  void _onScaleStart(ScaleStartDetails d) {
    _gestureBaseScale = _poseScale;
    _gestureBaseOffset = _poseOffset;
    _gestureStartFocal = d.localFocalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    setState(() {
      _poseScale = (_gestureBaseScale * d.scale).clamp(0.3, 4.0);
      _poseOffset = _gestureBaseOffset + (d.localFocalPoint - _gestureStartFocal);
    });
  }

  void _resetPoseTransform() {
    setState(() {
      _poseScale = 1.0;
      _poseOffset = Offset.zero;
    });
  }

  /// 当前姿势在预览中的完整变换矩阵（基础变换 + 用户缩放/位移），
  /// 供姿势层与提示气泡对齐使用。
  Matrix4 _poseMatrix(Size size) {
    final base = PosePainter.transformFor(size, 0.5,
        designWidth: _currentPose.designWidth,
        designHeight: _currentPose.designHeight);
    if (_poseScale == 1.0 && _poseOffset == Offset.zero) return base;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final m = Matrix4.identity()
      ..translateByDouble(_poseOffset.dx, _poseOffset.dy, 0.0, 1.0)
      ..translateByDouble(cx, cy, 0.0, 1.0)
      ..scaleByDouble(_poseScale, _poseScale, 1.0, 1.0)
      ..translateByDouble(-cx, -cy, 0.0, 1.0);
    m.multiply(base);
    return m;
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

    return SafeArea(
      child: Stack(
        children: [
          // 相机预览（全屏铺满；CameraPreview 自身按父容器尺寸做 cover 裁剪）
          Positioned.fill(
            child: CameraPreview(controller),
          ),
          // 发光人形姿势引导层（不会拍进照片）——支持双指缩放/拖动，双击复位
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              onDoubleTap: _resetPoseTransform,
              child: Stack(
                children: [
                  _PoseLayer(
                    pose: pose,
                    style: style,
                    fillRatio: 0.5,
                    userScale: _poseScale,
                    userOffset: _poseOffset,
                  ),
                  if (_posesLoaded && style.showTips && pose.tips.isNotEmpty)
                    _buildTipsOverlay(style, pose),
                ],
              ),
            ),
          ),
          // 顶部：姿势信息 + 光影方案本地预览条
          Positioned(
            top: 44,
            left: 8,
            right: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildStyleBar(),
              ],
            ),
          ),
          // 顶部行：返回键 + 居中文字「按轮廓摆好姿势」
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white70),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      S.of(context).poseGuideTitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        shadows: const [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 6,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // 与返回键等宽，保证文字相对居中
                const SizedBox(width: 48),
              ],
            ),
          ),
          // 底部控制区：快门 + 姿势切换条
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

  /// 顶部光影方案条：默认跟随接口 activeStyle（高亮项），点击可本地临时预览其它方案。
  Widget _buildStyleBar() {
    final ids = _result.styles.keys.toList();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
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
      ),
    );
  }

  /// 提示气泡：按设计空间坐标（tip.pos）经与主预览相同的变换定位到屏幕坐标，
  /// 因此会随姿势层的拖动 / 缩放一起移动，包括被拖出屏幕外。
  /// 无坐标的 tip 锚到姿势顶部居中（设计空间），同样随图像一起变换，
  /// 而不是固定钉在屏幕某处。这里不做 clamp，保证 tip 与身体部位同步（可移出屏幕）。
  Widget _buildTipsOverlay(PoseStyle style, Pose pose) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final matrix = _poseMatrix(size);
        final bubbles = <Widget>[];
        for (var i = 0; i < pose.tips.length; i++) {
          final tip = pose.tips[i];
          // 有坐标锚到该点；无坐标锚到姿势顶部居中（设计空间），二者都随图像变换
          final anchor = tip.pos ?? Offset(pose.designWidth / 2, 40);
          final p = PosePainter.transformPoint(matrix, anchor);
          final left = p.dx + 12;
          final top = p.dy - 28;
          bubbles.add(
            Positioned(
              left: left,
              top: top,
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
                  tip.text,
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
                ? Center(
                    child: Text(S.of(context).noPoses,
                        style: const TextStyle(color: Colors.white54)))
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _poses.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(width: _result.thumbnail.itemSpacing),
                    itemBuilder: (context, index) {
                      final selected = index == _safeIndex;
                      // 免费版仅开放前 kFreePoseLimit 个姿势；其余加锁。
                      final locked = !_purchase.unlocked.value &&
                          index >= kFreePoseLimit;
                      return GestureDetector(
                        onTap: locked
                            ? () => showPaywall(context)
                            : () => setState(() {
                                _selectedPose = index;
                                _poseScale = 1.0;
                                _poseOffset = Offset.zero;
                              }),
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
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: _PoseLayer(
                                  pose: _poses[index],
                                  style: style,
                                  fillRatio: 0.9,
                                  showKeyPoints: false,
                                  showFill: false,
                                  userScale: 1.0,
                                  userOffset: Offset.zero,
                                ),
                              ),
                              if (locked)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.lock_rounded,
                                          color: Colors.white70, size: 20),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // 免费版：在缩略图条上方放一个「解锁全部」入口
          if (!_purchase.unlocked.value) ...[
            const SizedBox(height: 10),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => showPaywall(context),
                icon: const Icon(Icons.lock_open_rounded, size: 16),
                label: Text(S.of(context).unlockAllPoses),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kBrandPinkDeep,
                  side: const BorderSide(color: kBrandPinkDeep),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
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
              _cameraError ?? S.of(context).cameraUnavailable,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _initCamera,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(S.of(context).retry),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(S.of(context).back,
                  style: const TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }
}

/// 把姿势画到预览上：若姿势带 imageAsset，则异步加载透明 PNG 并交给
/// [PosePainter] 以图片方式渲染；否则直接走 SVG path 渲染。
class _PoseLayer extends StatelessWidget {
  const _PoseLayer({
    required this.pose,
    required this.style,
    this.fillRatio = 0.5,
    this.showKeyPoints = true,
    this.showFill = true,
    this.userScale = 1.0,
    this.userOffset = Offset.zero,
  });

  final Pose pose;
  final PoseStyle style;
  final double fillRatio;
  final bool showKeyPoints;
  final bool showFill;
  final double userScale;
  final Offset userOffset;

  /// 按 asset 路径缓存解码后的 ui.Image，避免每次重建都重新解码。
  static final Map<String, Future<ui.Image?>> _imageCache = {};

  Future<ui.Image?> _loadImage(String asset) {
    return _imageCache.putIfAbsent(asset, () async {
      try {
        final data = await rootBundle.load(asset);
        final codec =
            await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        return frame.image;
      } catch (e) {
        debugPrint('[PoseLayer] 加载姿势图失败 $asset: $e');
        return null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 关键修复：CustomPaint 在无 child、无显式 size 时默认 Size.zero，
    // 放在 Stack/宽松约束下会被约束成 0 尺寸，导致 paint() 拿到 size=(0,0)、
    // 缩放比 0、整张姿势看不见（且不报错、不黑屏）。用 SizedBox.expand 撑满。
    final noImagePainter = PosePainter(
      pose: pose,
      style: style,
      fillRatio: fillRatio,
      showKeyPoints: showKeyPoints,
      showFill: showFill,
      userScale: userScale,
      userOffset: userOffset,
    );
    return SizedBox.expand(
      child: pose.imageAsset == null
          ? CustomPaint(painter: noImagePainter)
          : FutureBuilder<ui.Image?>(
              future: _loadImage(pose.imageAsset!),
              builder: (context, snap) {
                return CustomPaint(
                  painter: PosePainter(
                    pose: pose,
                    style: style,
                    fillRatio: fillRatio,
                    showKeyPoints: showKeyPoints,
                    showFill: showFill,
                    overlayImage: snap.data,
                    userScale: userScale,
                    userOffset: userOffset,
                  ),
                );
              },
            ),
    );
  }
}
