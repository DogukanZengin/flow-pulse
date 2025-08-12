import 'package:flutter/material.dart';
import 'dart:math' as math;

class LiquidBackground extends StatefulWidget {
  final bool isStudySession;
  final Widget child;

  const LiquidBackground({
    super.key,
    required this.isStudySession,
    required this.child,
  });

  @override
  State<LiquidBackground> createState() => _LiquidBackgroundState();
}

class _LiquidBackgroundState extends State<LiquidBackground>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _colorController;
  late Animation<double> _waveAnimation;
  late Animation<double> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _colorController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _waveAnimation = Tween<double>(
      begin: 0,
      end: math.pi * 2,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    ));

    _colorAnimation = CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(LiquidBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isStudySession != widget.isStudySession) {
      _colorController.forward().then((_) {
        _colorController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_waveAnimation, _colorAnimation]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isStudySession
                  ? [
                      const Color(0xFF6B5B95), // Deep Purple
                      const Color(0xFF88B0D3), // Sky Blue
                    ]
                  : [
                      const Color(0xFFFF6B6B), // Coral
                      const Color(0xFFFECA57), // Golden Yellow
                    ],
            ),
          ),
          child: CustomPaint(
            painter: LiquidWavePainter(
              waveAnimation: _waveAnimation.value,
              colorTransition: _colorAnimation.value,
              isStudySession: widget.isStudySession,
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class LiquidWavePainter extends CustomPainter {
  final double waveAnimation;
  final double colorTransition;
  final bool isStudySession;

  LiquidWavePainter({
    required this.waveAnimation,
    required this.colorTransition,
    required this.isStudySession,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create subtle wave overlay for liquid effect
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.03 + 0.02 * colorTransition);

    final path = Path();
    final waveHeight = 15.0 + 10.0 * colorTransition;
    final waveLength = size.width / 2;

    path.moveTo(0, size.height * 0.7);

    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height * 0.7 +
          waveHeight * math.sin((x / waveLength * math.pi * 2) + waveAnimation) +
          waveHeight * 0.5 * math.sin((x / waveLength * math.pi * 4) + waveAnimation * 1.5);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave for more depth
    final paint2 = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.02 + 0.015 * colorTransition);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.8);

    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height * 0.8 +
          waveHeight * 0.7 * math.sin((x / waveLength * math.pi * 3) - waveAnimation * 0.8) +
          waveHeight * 0.3 * math.sin((x / waveLength * math.pi * 6) - waveAnimation * 1.2);
      path2.lineTo(x, y);
    }

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(LiquidWavePainter oldDelegate) {
    return oldDelegate.waveAnimation != waveAnimation ||
        oldDelegate.colorTransition != colorTransition ||
        oldDelegate.isStudySession != isStudySession;
  }
}