import 'dart:ui';

/// 免费版可使用的姿势数量上限；超出部分需通过 pro_unlock 内购解锁。
/// 前 [kFreePoseLimit] 个姿势（pose_001 起）始终免费可用。
const int kFreePoseLimit = 5;

/// 按 [lang] 从 i18n 映射取文案；缺失则返回默认字段（中文 name）。
String _i18nName(Map<String, dynamic> json, String field, String i18nField, String lang) {
  final i18n = json[i18nField];
  if (i18n is Map && i18n[lang] is String) return i18n[lang] as String;
  return (json[field] as String?) ?? '';
}

/// 按 [lang] 取 tips 列表；缺失则返回默认 tips 列表。
List<dynamic> _i18nTips(Map<String, dynamic> json, String lang) {
  final i18n = json['tipsI18n'];
  if (i18n is Map && i18n[lang] is List) return i18n[lang] as List;
  final def = json['tips'];
  return def is List ? def : const <dynamic>[];
}

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
    this.singleLayer = false,
    this.tint,
  });

  final String id;
  final String name;

  /// 外层深色描边（压住背景、制造轮廓）
  final Color outerColor;
  final double outerWidth;

  /// 内层亮色描边（贴边、可发光）
  final Color innerColor;
  final double innerWidth;

  /// 是否对内层亮线做发光
  final bool glow;
  final Color glowColor;
  final double glowBlur;

  /// 身体填充
  final Color fillColor;
  final double fillOpacity;

  /// 是否绘制关键点圆点
  final bool showKeyPoints;
  final Color keyPointColor;
  final double keyPointRadius;
  final bool keyPointGlow;

  /// 是否在页面上渲染文字提示气泡
  final bool showTips;

  /// true=只绘制内层亮线（单层）；false=先画外层深色描边再画内层（双层）。
  /// 用于「蓝调/霓虹/柔光」等希望线条更干净、不叠暗边的风格。
  final bool singleLayer;

  /// 图片姿势的染色颜色；为 null 表示不染色（原图/黑线直接显示，即「无光影」）。
  /// 仅对 imageAsset 类型的姿势生效。
  final Color? tint;

  static Color _color(dynamic value, Color fallback) {
    if (value is! String) return fallback;
    var hex = value.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    final n = int.tryParse(hex, radix: 16);
    return n == null ? fallback : Color(n);
  }

  /// 解析可选颜色；字段缺失或 null 时返回 null（用于 tint 表示「无光影」）。
  static Color? _colorOrNull(dynamic value) {
    if (value is! String) return null;
    var hex = value.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    final n = int.tryParse(hex, radix: 16);
    return n == null ? null : Color(n);
  }

  factory PoseStyle.fromJson(Map<String, dynamic> json,
      {String id = '', String lang = 'zh'}) {
    final name = _i18nName(json, 'name', 'nameI18n', lang);
    return PoseStyle(
      id: (json['id'] as String?) ?? id,
      name: name.isNotEmpty ? name : '默认风格',
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
      singleLayer: (json['singleLayer'] as bool?) ?? false,
      tint: _colorOrNull(json['tint']),
    );
  }
}

/// 姿势的一个「部位」：如头、头发、脸、颈、躯干、手臂、腿、鞋。
/// 渲染时按 [type] 决定线宽/填充/颜色，从而把人物拆成有结构的线条人形，
/// 而不是一团剪影。每个部位可单独覆盖描边色/填充色/线宽/发光。
class PosePart {
  const PosePart({
    required this.type,
    required this.path,
    this.stroke,
    this.fill,
    this.width,
    this.glow = false,
    this.filled = false,
  });

  /// head | hair | face | neck | torso | arm | leg | shoe | hand | detail
  final String type;
  final String path;
  final String? stroke; // 覆盖描边色 (#RRGGBB)
  final String? fill; // 覆盖填充色 (#RRGGBB 或 rgba())
  final double? width; // 覆盖描边宽（屏幕像素）
  final bool glow; // 是否对该部位施加发光
  final bool filled; // true=填充模式，false=描边模式

  factory PosePart.fromJson(Map<String, dynamic> json) {
    return PosePart(
      type: (json['type'] as String?) ?? 'detail',
      path: (json['path'] as String?) ?? '',
      stroke: json['stroke'] as String?,
      fill: json['fill'] as String?,
      width: (json['width'] as num?)?.toDouble(),
      glow: (json['glow'] as bool?) ?? false,
      filled: (json['filled'] as bool?) ?? false,
    );
  }
}

/// 单条摆姿文字提示。可选携带一个设计空间坐标（与 pose.designWidth/designHeight 一致），
/// 让气泡在渲染时定位到姿势的指定部位；为 null 时使用默认位置（顶部居中）。
class Tip {
  const Tip({required this.text, this.pos});

  /// 提示文字
  final String text;

  /// 该 tip 在设计空间中的锚点。null = 使用默认位置。
  final Offset? pos;

  factory Tip.fromJson(dynamic e) {
    if (e is String) return Tip(text: e);
    if (e is Map) {
      final m = e as Map<String, dynamic>;
      final x = (m['x'] as num?)?.toDouble();
      final y = (m['y'] as num?)?.toDouble();
      return Tip(
        text: m['text'] as String? ?? '',
        pos: (x != null && y != null) ? Offset(x, y) : null,
      );
    }
    return Tip(text: e?.toString() ?? '');
  }
}

/// 一个拍照姿势 = 头部圆形 + 若干条闭环轮廓路径 + 关键点 + 文字提示。
/// 所有坐标基于 240 x 380 的设计空间，绘制时按预览区等比缩放。
class Pose {
  const Pose({
    required this.id,
    required this.name,
    this.headRect = Rect.zero,
    this.paths = const <String>[],
    this.parts = const <PosePart>[],
    this.keyPoints = const <Offset>[],
    this.tips = const <Tip>[],
    this.styleOverride,
    this.imageAsset,
    this.designWidth = 240,
    this.designHeight = 380,
  });

  final String id;
  final String name;

  /// 头部圆形（设计空间坐标）。旧格式使用；新格式用 parts 表达头部。
  final Rect headRect;

  /// 身体闭环轮廓路径（SVG path 语法的绝对坐标子集：M/L/C/Q/Z）。旧格式。
  final List<String> paths;

  /// 部位化结构（新格式，优先于 paths 渲染）。
  final List<PosePart> parts;

  /// 关键点（设计空间坐标）：头部中心 + 每个 path 的首个 M 点
  final List<Offset> keyPoints;

  /// 给用户的摆姿文字提示
  final List<Tip> tips;

  /// 单姿势覆盖风格 id；为 null 时由当前 activeStyle 决定
  final String? styleOverride;

  /// 透明 PNG 姿势图（本地 asset 路径，如 assets/poses/xxx.png）。
  /// 非空时优先以图片方式渲染（按设计空间缩放叠加），比 SVG path 更贴近真人。
  final String? imageAsset;

  /// 该姿势自己的设计空间尺寸（不同姿势可不同分辨率）。
  final double designWidth;
  final double designHeight;

  /// 当接口未下发 keyPoints 时，从头部中心与每条 path 的 M 起点自动推导，
  /// 保证任何姿势都有可渲染的关键点。
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

  factory Pose.fromJson(Map<String, dynamic> json, {String lang = 'zh'}) {
    final headRaw = json['headRect'] as Map<String, dynamic>?;
    final headRect = headRaw == null
        ? Rect.zero
        : Rect.fromLTWH(
            (headRaw['x'] as num).toDouble(),
            (headRaw['y'] as num).toDouble(),
            (headRaw['w'] as num).toDouble(),
            (headRaw['h'] as num).toDouble(),
          );
    final paths = (json['paths'] as List?)?.map((e) => e as String).toList() ??
        const <String>[];

    final parts = (json['parts'] as List?)
            ?.map((e) => PosePart.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const <PosePart>[];

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

    final name = _i18nName(json, 'name', 'nameI18n', lang);
    final rawTips = _i18nTips(json, lang);
    final tips = rawTips.map((e) => Tip.fromJson(e)).toList();

    return Pose(
      id: (json['id'] as String?) ?? (json['name'] as String? ?? 'pose'),
      name: name.isNotEmpty ? name : '姿势',
      headRect: headRect,
      paths: paths,
      parts: parts,
      keyPoints: keyPoints,
      tips: tips,
      styleOverride: json['style'] as String?,
      imageAsset: json['imageAsset'] as String?,
      designWidth: (json['designWidth'] as num?)?.toDouble() ?? 240,
      designHeight: (json['designHeight'] as num?)?.toDouble() ?? 380,
    );
  }
}

/// 姿势缩略图列表的尺寸配置（由接口下发，客户端不写死）。
/// 仅影响底部姿势切换条的外观，不参与相机预览里的姿势渲染。
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

  static double _num(dynamic v, double fallback) =>
      (v is num) ? v.toDouble() : fallback;

  factory ThumbnailConfig.fromJson(Map<String, dynamic>? json,
      {ThumbnailConfig fallback = const ThumbnailConfig()}) {
    if (json == null) return fallback;
    return ThumbnailConfig(
      listHeight: _num(json['listHeight'], fallback.listHeight),
      itemWidth: _num(json['itemWidth'], fallback.itemWidth),
      itemHeight: _num(json['itemHeight'], fallback.itemHeight),
      itemSpacing: _num(json['itemSpacing'], fallback.itemSpacing),
    );
  }
}

/// 接口下发的完整姿势数据包：风格表 + 当前生效风格 + 姿势列表。
class PoseResult {
  const PoseResult({
    required this.poses,
    required this.styles,
    required this.activeStyle,
    this.designWidth = 240,
    this.designHeight = 380,
    this.thumbnail = const ThumbnailConfig(),
    this.fromServer = false,
  });

  final List<Pose> poses;
  final Map<String, PoseStyle> styles;
  final String activeStyle;
  final double designWidth;
  final double designHeight;

  /// 底部姿势缩略图列表的尺寸配置（来自接口 thumbnail 字段）。
  final ThumbnailConfig thumbnail;

  /// 数据是否来自服务端（false 表示使用了离线兜底）
  final bool fromServer;

  /// 返回某姿势应使用的风格：优先单姿势覆盖，否则用全局 activeStyle。
  PoseStyle styleFor(Pose pose) {
    final id = pose.styleOverride ?? activeStyle;
    return styles[id] ?? styles[activeStyle] ?? styles.values.first;
  }

  factory PoseResult.fromJson(Map<String, dynamic> json,
      {bool fromServer = false, String lang = 'zh'}) {
    final stylesMap = <String, PoseStyle>{};
    final stylesRaw =
        (json['styles'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
    stylesRaw.forEach((key, value) {
      stylesMap[key] =
          PoseStyle.fromJson(value as Map<String, dynamic>, id: key, lang: lang);
    });

    final poses = (json['poses'] as List)
        .map((e) => Pose.fromJson(e as Map<String, dynamic>, lang: lang))
        .toList();

    return PoseResult(
      poses: poses,
      styles: stylesMap,
      activeStyle: (json['activeStyle'] as String?) ?? 'dual_outline',
      designWidth: (json['designWidth'] as num?)?.toDouble() ?? 240,
      designHeight: (json['designHeight'] as num?)?.toDouble() ?? 380,
      thumbnail: ThumbnailConfig.fromJson(
          json['thumbnail'] as Map<String, dynamic>?),
      fromServer: fromServer,
    );
  }
}
