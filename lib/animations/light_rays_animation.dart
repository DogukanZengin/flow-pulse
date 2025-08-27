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
  
  late final Paint _rayPaint;
  late final Paint _godRayPaint;
  late final Path _rayPath;
  
  LightRaysPainter({
    required this.animationValue,
    required this.isStudySession,
    required this.intensity,
    required this.rayCount,
  }) {
    _rayPaint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.overlay;
    
    _godRayPaint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.lighten;
    
    _rayPath = Path();
  }
  
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;
    
    
    // Create animated light rays from top
    for (int i = 0; i < rayCount; i++) {
      final rayProgress = (animationValue + i / rayCount) % 1.0;
      final rayX = (i / rayCount) * size.width + (math.sin(animationValue * 2 * math.pi + i) * 50);
      final rayWidth = 30 + (math.sin(rayProgress * math.pi) * 20);
      
      // Create dynamic gradient with current progress
      final dynamicGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          (isStudySession 
              ? Colors.yellow.withValues(alpha: 0.1 * intensity * rayProgress)
              : Colors.cyan.withValues(alpha: 0.08 * intensity * rayProgress)),
          Colors.transparent,
        ],
      );
      
      _rayPaint.shader = dynamicGradient.createShader(
        Rect.fromLTWH(rayX - rayWidth/2, 0, rayWidth, size.height * 0.7),
      );
      
      // Reuse path object
      _rayPath.reset();
      _rayPath.moveTo(rayX - rayWidth/2, 0);
      _rayPath.lineTo(rayX + rayWidth/2, 0);
      _rayPath.lineTo(rayX + rayWidth/3, size.height * 0.7);
      _rayPath.lineTo(rayX - rayWidth/3, size.height * 0.7);
      _rayPath.close();
      
      canvas.drawPath(_rayPath, _rayPaint);
    }
    
    // Add subtle god rays effect using cached gradient
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
    
    _godRayPaint.shader = godRayGradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.5),
    );
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.5),
      _godRayPaint,
    );
  }
  
  @override
  bool shouldRepaint(LightRaysPainter oldDelegate) {
    // Only repaint when animation value changes, since other properties rarely change
    return oldDelegate.animationValue != animationValue;
  }
}