import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:photo_assistant/l10n/generated/app_localizations.dart';

import 'shoot/shoot_page.dart';

// 与应用图标一致的品牌配色
const Color kBrandPink = Color(0xFFFDADAD); // 图标底色
const Color kBrandPinkDeep = Color(0xFFEE8188); // 图标描边 / 主强调色
const Color kCream = Color(0xFFFDF6F2); // 奶油白
const Color kInkPlum = Color(0xFF6B3A42); // 暖调深字色
const Color kMutedPlum = Color(0xFFB07A82); // 次要字色

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 跟随系统语言；supportedLocales 决定 App 内可切换的语言集合
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh'),
        Locale('zh', 'Hant'),
        Locale('en'),
        Locale('ja'),
        Locale('ko'),
        Locale('fr'),
        Locale('de'),
        Locale('th'),
        Locale('pt'),
        Locale('es'),
        Locale('tr'),
      ],
      title: 'Photo Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // 整 App 调性跟随图标：以品牌粉为主色（原为 teal，与图标粉调不符）
        colorScheme: ColorScheme.fromSeed(
          seedColor: kBrandPinkDeep,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: kCream,
      ),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kCream, Color(0xFFFCE4E6)],
          ),
        ),
        child: Stack(
          children: [
            // 装饰层：星芒点缀，呼应图标视觉语言
            const Positioned.fill(child: _WelcomeDecor()),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 主视觉：应用图标 + 环绕虚线圆环
                      // 圆环与图标放在同一 Stack 内居中，任何屏幕尺寸都必然套准
                      SizedBox(
                        width: 300,
                        height: 300,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _DashedCirclePainter(
                                  color: kBrandPinkDeep.withValues(alpha: 0.35),
                                  strokeWidth: 2,
                                  dash: 11,
                                  gap: 9,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(46),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        kBrandPinkDeep.withValues(alpha: 0.28),
                                    blurRadius: 28,
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(46),
                                child: Image.asset(
                                  'assets/branding/app_icon_round.png',
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        s.appName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: kInkPlum,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        s.welcomeSubtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: kMutedPlum,
                        ),
                      ),
                      const SizedBox(height: 18),
                      // 标语徽章
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: kBrandPink.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Text(
                          s.welcomeTagline,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: kInkPlum,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: kBrandPinkDeep,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 46,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ShootPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.camera_alt_rounded),
                        label: Text(s.startShooting),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 首页背景装饰：几枚星芒，位置落在不遮挡文字与按钮的安全区。
class _WelcomeDecor extends StatelessWidget {
  const _WelcomeDecor();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned(
          top: size.height * 0.12,
          left: size.width * 0.12,
          child: _sparkle(24, kBrandPinkDeep.withValues(alpha: 0.50)),
        ),
        Positioned(
          top: size.height * 0.21,
          right: size.width * 0.13,
          child: _sparkle(17, kBrandPinkDeep.withValues(alpha: 0.42)),
        ),
        Positioned(
          bottom: size.height * 0.13,
          left: size.width * 0.16,
          child: _sparkle(21, kBrandPink.withValues(alpha: 0.85)),
        ),
        Positioned(
          bottom: size.height * 0.06,
          right: size.width * 0.20,
          child: _sparkle(13, kBrandPinkDeep.withValues(alpha: 0.38)),
        ),
      ],
    );
  }

  Widget _sparkle(double size, Color color) {
    return Transform.rotate(
      angle: 0.4,
      child: Icon(
        Icons.auto_awesome_rounded,
        size: size,
        color: color,
      ),
    );
  }
}

/// 虚线圆环画笔（图标里的虚线圈同款视觉）。
class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dash;
  final double gap;

  const _DashedCirclePainter({
    required this.color,
    this.strokeWidth = 2,
    this.dash = 10,
    this.gap = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..addOval(Offset.zero & size);
    final metric = path.computeMetrics().first;
    final len = metric.length;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    var pos = 0.0;
    while (pos < len) {
      final next = pos + dash;
      canvas.drawPath(metric.extractPath(pos, next), paint);
      pos += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.dash != dash ||
      old.gap != gap;
}
