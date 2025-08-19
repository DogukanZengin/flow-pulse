import 'package:flutter/material.dart';
import 'dart:math' as math;

class LightRaysAnimation extends StatefulWidget {
  final bool isStudySession;
  final double intensity;
  final int rayCount;
  final Duration animationDuration;
  
  const LightRaysAnimation({
    super.key,
    required this.isStudySession,
    this.intensity = 0.3,
    this.rayCount = 5,
    this.animationDuration = const Duration(seconds: 15),
  });

  @override
  State<LightRaysAnimation> createState() => _LightRaysAnimationState();
}

class _LightRaysAnimationState extends State<LightRaysAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _lightAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat(reverse: true);
    
    _lightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _lightAnimation,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: LightRaysPainter(
              animationValue: _lightAnimation.value,
              isStudySession: widget.isStudySession,
              intensity: widget.intensity,
              rayCount: widget.rayCount,
            ),
          );
        },
      ),
    );
  }
}

class LightRaysPainter extends CustomPainter {
  final double animationValue;
  final bool isStudySession;
  final double intensity;
  final int rayCount;
  
  LightRaysPainter({
    required this.animationValue,
    required this.isStudySession,
    required this.intensity,
    required this.rayCount,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;
    
    // Light ray colors based on session type
    final rayColor = isStudySession 
        ? Colors.yellow.withValues(alpha: 0.1 * intensity)
        : Colors.cyan.withValues(alpha: 0.08 * intensity);
    
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.overlay;
    
    // Create animated light rays from top
    for (int i = 0; i < rayCount; i++) {
      final rayProgress = (animationValue + i / rayCount) % 1.0;
      final rayX = (i / rayCount) * size.width + (math.sin(animationValue * 2 * math.pi + i) * 50);
      final rayWidth = 30 + (math.sin(rayProgress * math.pi) * 20);
      
      // Create gradient for each ray
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          rayColor.withValues(alpha: rayColor.a * rayProgress),
          rayColor.withValues(alpha: 0.0),
        ],
      );
      
      paint.shader = gradient.createShader(
        Rect.fromLTWH(rayX - rayWidth/2, 0, rayWidth, size.height * 0.7),
      );
      
      // Draw ray path
      final rayPath = Path();
      rayPath.moveTo(rayX - rayWidth/2, 0);
      rayPath.lineTo(rayX + rayWidth/2, 0);
      rayPath.lineTo(rayX + rayWidth/3, size.height * 0.7);
      rayPath.lineTo(rayX - rayWidth/3, size.height * 0.7);
      rayPath.close();
      
      canvas.drawPath(rayPath, paint);
    }
    
    // Add subtle god rays effect
    final godRayPaint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.lighten;
    
    final godRayGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.center,
      colors: [
        isStudySession 
            ? Colors.yellow.withValues(alpha: 0.05 * intensity * animationValue)
            : Colors.cyan.withValues(alpha: 0.03 * intensity * animationValue),
        Colors.transparent,
      ],
    );
    
    godRayPaint.shader = godRayGradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.5),
    );
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.5),
      godRayPaint,
    );
  }
  
  @override
  bool shouldRepaint(LightRaysPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.isStudySession != isStudySession ||
           oldDelegate.intensity != intensity;
  }
}