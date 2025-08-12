import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class GradientMeshBackground extends StatefulWidget {
  final bool isStudySession;
  final bool isEnabled;
  
  const GradientMeshBackground({
    super.key,
    required this.isStudySession,
    this.isEnabled = true,
  });

  @override
  State<GradientMeshBackground> createState() => _GradientMeshBackgroundState();
}

class _GradientMeshBackgroundState extends State<GradientMeshBackground>
    with TickerProviderStateMixin {
  
  late AnimationController _meshController;
  late AnimationController _colorController;
  late Animation<double> _meshAnimation;
  late Animation<double> _colorAnimation;
  
  final List<MeshPoint> _meshPoints = [];
  final math.Random _random = math.Random();
  
  @override
  void initState() {
    super.initState();
    
    _meshController = AnimationController(
      duration: const Duration(seconds: 30), // Slower for better performance
      vsync: this,
    )..repeat();
    
    _colorController = AnimationController(
      duration: const Duration(seconds: 20), // Slower for better performance
      vsync: this,
    )..repeat(reverse: true);
    
    _meshAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _meshController,
      curve: Curves.linear,
    ));
    
    _colorAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    ));
    
    _initializeMeshPoints();
  }
  
  void _initializeMeshPoints() {
    const gridSize = 4;
    
    for (int i = 0; i <= gridSize; i++) {
      for (int j = 0; j <= gridSize; j++) {
        _meshPoints.add(MeshPoint(
          baseX: i / gridSize,
          baseY: j / gridSize,
          offsetX: (_random.nextDouble() - 0.5) * 0.1,
          offsetY: (_random.nextDouble() - 0.5) * 0.1,
          phase: _random.nextDouble() * 2 * math.pi,
          amplitude: _random.nextDouble() * 0.05 + 0.02,
        ));
      }
    }
  }
  
  @override
  void dispose() {
    _meshController.dispose();
    _colorController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) {
      return const SizedBox.shrink();
    }
    
    return AnimatedBuilder(
      animation: Listenable.merge([_meshAnimation, _colorAnimation]),
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: GradientMeshPainter(
            meshPoints: _meshPoints,
            animationValue: _meshAnimation.value,
            colorValue: _colorAnimation.value,
            isStudySession: widget.isStudySession,
          ),
        );
      },
    );
  }
}

class MeshPoint {
  final double baseX;
  final double baseY;
  final double offsetX;
  final double offsetY;
  final double phase;
  final double amplitude;
  
  MeshPoint({
    required this.baseX,
    required this.baseY,
    required this.offsetX,
    required this.offsetY,
    required this.phase,
    required this.amplitude,
  });
  
  Offset getAnimatedPosition(Size size, double animationValue) {
    final x = baseX + offsetX + math.sin(animationValue + phase) * amplitude;
    final y = baseY + offsetY + math.cos(animationValue + phase) * amplitude;
    
    return Offset(
      x.clamp(0.0, 1.0) * size.width,
      y.clamp(0.0, 1.0) * size.height,
    );
  }
}

class GradientMeshPainter extends CustomPainter {
  final List<MeshPoint> meshPoints;
  final double animationValue;
  final double colorValue;
  final bool isStudySession;
  
  GradientMeshPainter({
    required this.meshPoints,
    required this.animationValue,
    required this.colorValue,
    required this.isStudySession,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Create gradient colors based on session type
    final List<Color> baseColors = isStudySession
        ? [
            Color.lerp(
              const Color(0xFF6B5B95),
              const Color(0xFF8B7BB5),
              colorValue,
            )!,
            Color.lerp(
              const Color(0xFF88B0D3),
              const Color(0xFF68A0C3),
              colorValue,
            )!,
            Color.lerp(
              const Color(0xFF7C6BA0),
              const Color(0xFF9C8BC0),
              colorValue,
            )!,
          ]
        : [
            Color.lerp(
              const Color(0xFFFF6B6B),
              const Color(0xFFFF8B8B),
              colorValue,
            )!,
            Color.lerp(
              const Color(0xFFFECA57),
              const Color(0xFFFFDA77),
              colorValue,
            )!,
            Color.lerp(
              const Color(0xFFFF9A9A),
              const Color(0xFFFFBABA),
              colorValue,
            )!,
          ];
    
    // Draw multiple gradient layers for depth
    for (int layer = 0; layer < 3; layer++) {
      final layerOpacity = 0.15 - (layer * 0.05);
      final layerScale = 1.0 + (layer * 0.2);
      
      for (int i = 0; i < meshPoints.length - 5; i += 5) {
        if (i + 10 >= meshPoints.length) continue;
        
        final p1 = meshPoints[i].getAnimatedPosition(size, animationValue);
        final p2 = meshPoints[i + 5].getAnimatedPosition(size, animationValue);
        final p3 = meshPoints[i + 10].getAnimatedPosition(size, animationValue);
        
        // Scale points for layering effect
        final center = Offset(size.width / 2, size.height / 2);
        final sp1 = _scalePoint(p1, center, layerScale);
        final sp2 = _scalePoint(p2, center, layerScale);
        final sp3 = _scalePoint(p3, center, layerScale);
        
        // Create gradient paint
        final paint = Paint()
          ..shader = ui.Gradient.radial(
            sp1,
            (sp1 - sp2).distance,
            [
              baseColors[i % baseColors.length].withOpacity(layerOpacity),
              baseColors[(i + 1) % baseColors.length].withOpacity(layerOpacity * 0.5),
              Colors.transparent,
            ],
            [0.0, 0.5, 1.0],
          )
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
        
        // Draw triangular mesh
        final path = Path()
          ..moveTo(sp1.dx, sp1.dy)
          ..lineTo(sp2.dx, sp2.dy)
          ..lineTo(sp3.dx, sp3.dy)
          ..close();
        
        canvas.drawPath(path, paint);
      }
    }
    
    // Add subtle noise overlay for texture
    final noisePaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 50; i++) {
      final x = (math.sin(animationValue + i) * 0.5 + 0.5) * size.width;
      final y = (math.cos(animationValue + i * 1.5) * 0.5 + 0.5) * size.height;
      canvas.drawCircle(Offset(x, y), 1, noisePaint);
    }
  }
  
  Offset _scalePoint(Offset point, Offset center, double scale) {
    final dx = center.dx + (point.dx - center.dx) * scale;
    final dy = center.dy + (point.dy - center.dy) * scale;
    return Offset(dx, dy);
  }
  
  @override
  bool shouldRepaint(GradientMeshPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.colorValue != colorValue ||
           oldDelegate.isStudySession != isStudySession;
  }
}