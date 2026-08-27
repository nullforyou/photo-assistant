import 'dart:ui';

/// 一套光影渲染风格（由接口下发，客户端不写死）。
/// 描述双层描边、发光、填充、关键点圆点与提示开关。
class PoseStyle {
  const PoseStyle({
    required this.id,
    required this.name,
    required this.outerColor,
    required this.outerWidth,
    required this.innerColor,
    required this.innerWidth,
    required this.glow,
    required this.glowColor,
    required this.glowBlur,
    required this.fillColor,
    required this.fillOpacity,
    required this.showKeyPoints,
    required this.keyPointColor,
    required this.keyPointRadius,
    required this.keyPointGlow,
    required this.showTips,
  });

  final String id;
  final String name;
  final Color outerColor;
  final double outerWidth;
  final Color innerColor;
  final double innerWidth;
  final bool glow;
  final Color glowColor;
  final double glowBlur;
  final Color fillColor;
  final double fillOpacity;
  final bool showKeyPoints;
  final Color keyPointColor;
  final double keyPointRadius;
  final bool keyPointGlow;
  final bool showTips;

  static Color _color(dynamic value, Color fallback) {
    if (value is! String) return fallback;
    var hex = value.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    final n = int.tryParse(hex, radix: 16);
    return n == null ? fallback : Color(n);
  }

  factory PoseStyle.fromJson(Map<String, dynamic> json, {String id = ''}) {
    return PoseStyle(
      id: (json['id'] as String?) ?? id,
      name: (json['name'] as String?) ?? '\u9ed8\u8ba4\u98ce\u683c',
      outerColor: _color(json['outerColor'], const Color(0xFF0A0E14)),
      outerWidth: (json['outerWidth'] as num?)?.toDouble() ?? 6.0,
      innerColor: _color(json['innerColor'], const Color(0xFF00E5FF)),
      innerWidth: (json['innerWidth'] as num?)?.toDouble() ?? 2.5,
      glow: (json['glow'] as bool?) ?? true,
      glowColor: _color(json['glowColor'], const Color(0xFF00E5FF)),
      glowBlur: (json['glowBlur'] as num?)?.toDouble() ?? 10.0,
      fillColor: _color(json['fillColor'], const Color(0xFF10243A)),
      fillOpacity: (json['fillOpacity'] as num?)?.toDouble() ?? 0.18,
      showKeyPoints: (json['showKeyPoints'] as bool?) ?? true,
      keyPointColor: _color(json['keyPointColor'], const Color(0xFF00E5FF)),
      keyPointRadius: (json['keyPointRadius'] as num?)?.toDouble() ?? 4.0,
      keyPointGlow: (json['keyPointGlow'] as bool?) ?? true,
      showTips: (json['showTips'] as bool?) ?? true,
    );
  }
}

/// 一个拍照姿势 = 头部圆形 + 若干条闭环轮廓路径 + 关键点 + 文字提示。
/// 所有坐标基于 240 x 380 的设计空间，绘制时按预览区等比缩放。
class Pose {
  const Pose({
    required this.name,
    required this.headRect,
    required this.paths,
    this.id = '',
    this.keyPoints = const <Offset>[],
    this.tips = const <String>[],
    this.styleOverride,
  });

  final String id;
  final String name;
  final Rect headRect;
  final List<String> paths;
  final List<Offset> keyPoints;
  final List<String> tips;

  /// 单姿势覆盖风格 id；为 null 时由当前 activeStyle 决定。
  final String? styleOverride;

  static const double designWidth = 240;
  static const double designHeight = 380;

  /// 从头部中心与每条 path 的 M 起点自动推导关键点。
  static List<Offset> deriveKeyPoints(Rect head, List<String> paths) {
    final points = <Offset>[
      Offset(head.left + head.width / 2, head.top + head.height / 2),
    ];
    final mReg = RegExp(r'M\s*(-?\d+(?:\.\d+)?)\s+(-?\d+(?:\.\d+)?)');
    for (final d in paths) {
      final m = mReg.firstMatch(d);
      if (m != null) {
        points.add(Offset(
          double.parse(m.group(1)!),
          double.parse(m.group(2)!),
        ));
      }
    }
    return points;
  }

  factory Pose.fromJson(Map<String, dynamic> json) {
    final head = json['headRect'] as Map<String, dynamic>;
    final headRect = Rect.fromLTWH(
      (head['x'] as num).toDouble(),
      (head['y'] as num).toDouble(),
      (head['w'] as num).toDouble(),
      (head['h'] as num).toDouble(),
    );
    final paths = (json['paths'] as List).map((e) => e as String).toList();

    List<Offset> keyPoints;
    if (json['keyPoints'] is List) {
      keyPoints = (json['keyPoints'] as List).map((p) {
        final arr = p as List;
        return Offset(
          (arr[0] as num).toDouble(),
          (arr[1] as num).toDouble(),
        );
      }).toList();
    } else {
      keyPoints = deriveKeyPoints(headRect, paths);
    }

    final tips = json['tips'] is List
        ? (json['tips'] as List).map((e) => e as String).toList()
        : const <String>[];

    return Pose(
      id: (json['id'] as String?) ?? (json['name'] as String? ?? 'pose'),
      name: (json['name'] as String?) ?? '',
      headRect: headRect,
      paths: paths,
      keyPoints: keyPoints,
      tips: tips,
      styleOverride: json['style'] as String?,
    );
  }
}

/// 底部姿势缩略图列表的尺寸配置，由接口下发，不传则用默认值。
class ThumbnailConfig {
  const ThumbnailConfig({
    this.listHeight = 84,
    this.itemWidth = 60,
    this.itemHeight = 84,
    this.itemSpacing = 10,
  });

  final double listHeight;
  final double itemWidth;
  final double itemHeight;
  final double itemSpacing;

  factory ThumbnailConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ThumbnailConfig();
    return ThumbnailConfig(
      listHeight: (json['listHeight'] as num?)?.toDouble() ?? 84,
      itemWidth: (json['itemWidth'] as num?)?.toDouble() ?? 60,
      itemHeight: (json['itemHeight'] as num?)?.toDouble() ?? 84,
      itemSpacing: (json['itemSpacing'] as num?)?.toDouble() ?? 10,
    );
  }
}

/// 接口下发的完整姿势数据包：风格表 + 当前生效风格 + 姿势列表。
class PoseResult {
  const PoseResult({
    required this.poses,
    required this.styles,
    required this.activeStyle,
    this.fromServer = false,
    this.thumbnail = const ThumbnailConfig(),
  });

  final List<Pose> poses;
  final Map<String, PoseStyle> styles;
  final String activeStyle;
  final bool fromServer;
  final ThumbnailConfig thumbnail;

  /// 返回某姿势应使用的风格：优先单姿势覆盖，否则用全局 activeStyle。
  PoseStyle styleFor(Pose pose) {
    final id = pose.styleOverride ?? activeStyle;
    return styles[id] ?? styles[activeStyle] ?? styles.values.first;
  }

  factory PoseResult.fromJson(Map<String, dynamic> json,
      {bool fromServer = false}) {
    final stylesMap = <String, PoseStyle>{};
    final stylesRaw =
        (json['styles'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    stylesRaw.forEach((key, value) {
      stylesMap[key] =
          PoseStyle.fromJson(value as Map<String, dynamic>, id: key);
    });

    final poses = (json['poses'] as List)
        .map((e) => Pose.fromJson(e as Map<String, dynamic>))
        .toList();

    return PoseResult(
      poses: poses,
      styles: stylesMap,
      activeStyle: (json['activeStyle'] as String?) ?? 'dual_outline',
      fromServer: fromServer,
      thumbnail: ThumbnailConfig.fromJson(
        json['thumbnail'] as Map<String, dynamic>?,
      ),
    );
  }
}


