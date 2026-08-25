import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryColor = Color(0xFF0C3468);
  static const Color secondaryColor = Color(0xFF1857A5);

  static const SystemUiOverlayStyle overlayStyle =
  SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
  );

  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    SystemChrome.setSystemUIOverlayStyle(
      overlayStyle,
    );

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 3600,
      ),
    )..addStatusListener(
      _handleAnimationStatus,
    );

    animationController.forward();
  }

  Future<void> _handleAnimationStatus(
      AnimationStatus status,
      ) async {
    if (status != AnimationStatus.completed) {
      return;
    }

    await Future<void>.delayed(
      const Duration(milliseconds: 450),
    );

    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (
            context,
            animation,
            secondaryAnimation,
            ) {
          return const LoginScreen();
        },
        transitionDuration: const Duration(
          milliseconds: 450,
        ),
        transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
            ) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    animationController
      ..removeStatusListener(
        _handleAnimationStatus,
      )
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: primaryColor,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                primaryColor,
                secondaryColor,
              ],
            ),
          ),
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              alignment: Alignment.center,
              child: SizedBox(
                width: 440,
                height: 956,
                child: AnimatedBuilder(
                  animation: animationController,
                  builder: (
                      context,
                      child,
                      ) {
                    return _SplashDesign(
                      progress:
                      animationController.value,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashDesign extends StatelessWidget {
  final double progress;

  const _SplashDesign({
    required this.progress,
  });

  double _part(
      double begin,
      double end,
      ) {
    final double value =
    ((progress - begin) / (end - begin))
        .clamp(0.0, 1.0);

    return Curves.easeInOutCubic.transform(
      value,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ظهور خلفية المفتاح.
    final double patternProgress =
    _part(0.00, 0.14);

    // ظهور كلمة حكيم بشكل متواصل من اليمين.
    final double wordProgress =
    _part(0.12, 0.72);

    // يبدأ الخط بعد اكتمال ظهور كلمة حكيم.
    final double underlineProgress =
    _part(0.72, 1.00);

    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: patternProgress,
            child: const CustomPaint(
              painter:
              _BackgroundPatternPainter(),
            ),
          ),
        ),
        Positioned(
          left: 70,
          top: 400,
          width: 300,
          height: 170,
          child: Semantics(
            // الكلمة: حكيم
            label:
            '\u062D\u0643\u064A\u0645',
            child: CustomPaint(
              painter: _HakimLogoPainter(
                wordProgress: wordProgress,
                underlineProgress:
                underlineProgress,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BackgroundPatternPainter
    extends CustomPainter {
  const _BackgroundPatternPainter();

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final Paint patternPaint = Paint()
      ..color = const Color(0xFF082B59)
          .withOpacity(0.36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    const Offset center = Offset(
      -28,
      458,
    );

    const double radius = 315;

    canvas.drawCircle(
      center,
      radius,
      patternPaint,
    );

    final Path handle = Path()
      ..moveTo(
        194,
        680,
      )
      ..lineTo(
        346,
        833,
      );

    canvas.drawPath(
      handle,
      patternPaint,
    );

    final Paint innerPaint = Paint()
      ..color = const Color(0xFF082B59)
          .withOpacity(0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path innerShape = Path()
      ..moveTo(
        -25,
        343,
      )
      ..cubicTo(
        32,
        319,
        83,
        335,
        113,
        379,
      )
      ..cubicTo(
        145,
        426,
        131,
        481,
        88,
        517,
      )
      ..lineTo(
        45,
        556,
      );

    canvas.drawPath(
      innerShape,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant _BackgroundPatternPainter oldDelegate,
      ) {
    return false;
  }
}

class _HakimLogoPainter extends CustomPainter {
  final double wordProgress;
  final double underlineProgress;

  const _HakimLogoPainter({
    required this.wordProgress,
    required this.underlineProgress,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    _paintWord(
      canvas,
      size,
    );

    _paintUnderline(
      canvas,
    );
  }

  void _paintWord(
      Canvas canvas,
      Size size,
      ) {
    if (wordProgress <= 0) {
      return;
    }

    final TextPainter wordPainter =
    TextPainter(
      text: const TextSpan(
        /*
          Unicode:

          ح = 062D
          ك = 0643
          ي = 064A
          م = 0645
        */
        text:
        '\u062D\u0643\u064A\u0645',
        style: TextStyle(
          fontFamily:
          'ThmanyahSerifDisplay',
          fontFamilyFallback: [
            'Arial',
          ],
          color: Colors.white,
          fontSize: 82,
          fontWeight: FontWeight.w500,
          height: 1,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    )..layout(
      maxWidth: size.width,
    );

    final Offset wordOffset = Offset(
      (size.width - wordPainter.width) / 2,
      7,
    );

    final Rect wordBounds = Rect.fromLTWH(
      wordOffset.dx,
      wordOffset.dy,
      wordPainter.width,
      wordPainter.height,
    );

    canvas.save();

    /*
      الأنيميشن الأول:
      تظهر كلمة حكيم بشكل متواصل
      من اليمين إلى اليسار.
    */
    canvas.clipRect(
      Rect.fromLTRB(
        ui.lerpDouble(
          wordBounds.right,
          wordBounds.left,
          wordProgress,
        )!,
        wordBounds.top,
        wordBounds.right,
        wordBounds.bottom,
      ),
    );

    wordPainter.paint(
      canvas,
      wordOffset,
    );

    canvas.restore();
  }

  void _paintUnderline(
      Canvas canvas,
      ) {
    if (underlineProgress <= 0) {
      return;
    }

    final Paint linePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    /*
      يبدأ من النقطة اليمنى x = 280
      وينتهي في الجهة اليسرى x = 20.
    */
    final Path underline = Path()
      ..moveTo(
        280,
        132,
      )
      ..cubicTo(
        251,
        115,
        211,
        116,
        163,
        132,
      )
      ..cubicTo(
        113,
        148,
        67,
        155,
        20,
        126,
      );

    for (final ui.PathMetric metric
    in underline.computeMetrics()) {
      final Path visiblePath =
      metric.extractPath(
        0,
        metric.length *
            underlineProgress,
      );

      canvas.drawPath(
        visiblePath,
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant _HakimLogoPainter oldDelegate,
      ) {
    return oldDelegate.wordProgress !=
        wordProgress ||
        oldDelegate.underlineProgress !=
            underlineProgress;
  }
}