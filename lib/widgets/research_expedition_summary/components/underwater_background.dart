import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/creature.dart';
import '../models/celebration_config.dart';
import '../models/expedition_result.dart';
import '../constants/animation_constants.dart';

/// Enhanced underwater background with dynamic biome scenes
class UnderwaterBackground extends StatefulWidget {
  final BiomeVisualConfig biomeConfig;
  final AnimationController depthProgress;
  final CelebrationIntensity celebrationIntensity;

  const UnderwaterBackground({
    super.key,
    required this.biomeConfig,
    required this.depthProgress,
    required this.celebrationIntensity,
  });

  @override
  State<UnderwaterBackground> createState() => _UnderwaterBackgroundState();
}

class _UnderwaterBackgroundState extends State<UnderwaterBackground>
    with TickerProviderStateMixin {
  AnimationController? _waveController;
  AnimationController? _coralGrowthController;
  AnimationController? _particleController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _waveController = AnimationController(
      duration: AnimationConstants.waveControllerDuration,
      vsync: this,
    )..repeat();
    
    _coralGrowthController = AnimationController(
      duration: AnimationConstants.coralGrowthDuration,
      vsync: this,
    )..forward();
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    try {
      _waveController?.dispose();
      _coralGrowthController?.dispose();
      _particleController?.dispose();
    } catch (e) {
      debugPrint('Error disposing underwater background controllers: $e');
    } finally {
      _waveController = null;
      _coralGrowthController = null;
      _particleController = null;
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    try {
      // Return a simple container if controllers aren't initialized yet
      if (_waveController == null || _coralGrowthController == null || _particleController == null) {
        return Container(
          decoration: BoxDecoration(
            gradient: _buildDepthAwareGradient(),
          ),
        );
      }
      
      // Safety check for animation values
      if (!widget.depthProgress.value.isFinite ||
          !_waveController!.value.isFinite ||
          !_coralGrowthController!.value.isFinite ||
          !_particleController!.value.isFinite) {
        return Container(
          decoration: BoxDecoration(
            gradient: _buildDepthAwareGradient(),
          ),
        );
      }
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.depthProgress,
        _waveController!,
        _coralGrowthController!,
        _particleController!,
      ]),
      builder: (context, child) {
        return Stack(
          children: [
            // Layer 1: Dynamic gradient background
            Container(
              decoration: BoxDecoration(
                gradient: _buildDepthAwareGradient(),
              ),
            ),
            // Layer 2: Biome-specific environment
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _BiomeEnvironmentPainter(
                biomeType: widget.biomeConfig.biome,
                depthProgress: widget.depthProgress.value,
                waveAnimation: _waveController?.value ?? 0.0,
                coralGrowth: _coralGrowthController?.value ?? 0.0,
                intensity: widget.celebrationIntensity,
              ),
            ),
            // Layer 3: Caustic light patterns
            _buildCausticOverlay(),
            // Layer 4: Floating particles
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _FloatingParticlesPainter(
                particleAnimation: _particleController?.value ?? 0.0,
                biomeColors: widget.biomeConfig.particleColors,
                intensity: widget.celebrationIntensity.index / 3.0,
              ),
            ),
          ],
        );
      },
    );
    } catch (e) {
      // Return fallback gradient background
      debugPrint('Error in underwater background: $e');
      return Container(
        decoration: BoxDecoration(
          gradient: widget.biomeConfig.backgroundGradient,
        ),
      );
    }
  }

  LinearGradient _buildDepthAwareGradient() {
    final progress = widget.depthProgress.value;
    
    // Transition from deep biome colors to surface colors
    return LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: widget.biomeConfig.backgroundGradient.colors
          .map((color) => Color.lerp(
                color,
                const Color(0xFF87CEEB), // Surface blue
                progress * 0.3,
              )!)
          .toList(),
    );
  }

  Widget _buildCausticOverlay() {
    return AnimatedBuilder(
      animation: widget.depthProgress,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _CausticOverlayPainter(
            progress: widget.depthProgress.value,
            intensity: widget.celebrationIntensity.index / 3.0,
            lightColor: widget.biomeConfig.dominantColor,
          ),
        );
      },
    );
  }
}

/// Enhanced painter for underwater caustic light effects
class _CausticOverlayPainter extends CustomPainter {
  final double progress;
  final double intensity;
  final Color lightColor;

  _CausticOverlayPainter({
    required this.progress,
    required this.intensity,
    required this.lightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    try {
      if (intensity < 0.1) return;
    
    final paint = Paint()
      ..blendMode = BlendMode.overlay
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    // Enhanced caustic pattern with wave-like movement
    for (int i = 0; i < AnimationConstants.causticGridWidth; i++) {
      for (int j = 0; j < AnimationConstants.causticGridHeight; j++) {
        final waveOffset = math.sin(progress * math.pi * 2 + i * 0.5) * 20;
        final offset = Offset(
          (i * size.width / 15) + waveOffset,
          (j * size.height / 8) + math.cos(progress * math.pi * 2 + j * 0.3) * 10,
        );
        
        paint.shader = RadialGradient(
          colors: [
            lightColor.withValues(alpha: 0.2 * intensity),
            lightColor.withValues(alpha: 0.05 * intensity),
          ],
        ).createShader(Rect.fromCircle(center: offset, radius: 30));
        
        canvas.drawCircle(offset, 25 + (math.sin(progress * math.pi * 4) * 5), paint);
      }
    }
    } catch (e) {
      // Silently handle painting errors
      debugPrint('Error in caustic overlay painting: $e');
    }
  }

  @override
  bool shouldRepaint(covariant _CausticOverlayPainter oldDelegate) {
    return progress != oldDelegate.progress || intensity != oldDelegate.intensity;
  }
}

/// Painter for biome-specific environmental elements
class _BiomeEnvironmentPainter extends CustomPainter {
  final BiomeType biomeType;
  final double depthProgress;
  final double waveAnimation;
  final double coralGrowth;
  final CelebrationIntensity intensity;

  _BiomeEnvironmentPainter({
    required this.biomeType,
    required this.depthProgress,
    required this.waveAnimation,
    required this.coralGrowth,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (biomeType) {
      case BiomeType.shallowWaters:
        _drawShallowWatersScene(canvas, size);
        break;
      case BiomeType.coralGarden:
        _drawCoralGardenScene(canvas, size);
        break;
      case BiomeType.deepOcean:
        _drawDeepOceanScene(canvas, size);
        break;
      case BiomeType.abyssalZone:
        _drawAbyssalZoneScene(canvas, size);
        break;
    }
  }

  void _drawShallowWatersScene(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Sandy bottom with ripples
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.yellow.shade100.withValues(alpha: 0.3),
        Colors.amber.shade200.withValues(alpha: 0.5),
      ],
    ).createShader(Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3));
    
    for (int i = 0; i < 5; i++) {
      final y = size.height * 0.8 + (i * 15) + math.sin(waveAnimation * math.pi * 2 + i) * 5;
      final path = Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(
          size.width * 0.25, y - 10,
          size.width * 0.5, y,
        )
        ..quadraticBezierTo(
          size.width * 0.75, y + 10,
          size.width, y,
        );
      canvas.drawPath(path, paint);
    }
    
    // Growing coral polyps
    _drawCoralPolyps(canvas, size, Colors.pink.shade300, coralGrowth);
  }

  void _drawCoralGardenScene(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Branching corals
    for (int i = 0; i < 8; i++) {
      final x = (i + 1) * size.width / 9;
      final baseY = size.height * 0.7;
      final height = 100 + (i * 20);
      
      paint.color = [
        Colors.pink.shade400,
        Colors.orange.shade400,
        Colors.purple.shade400,
        Colors.red.shade400,
      ][i % 4].withValues(alpha: 0.7);
      
      _drawBranchingCoral(canvas, Offset(x, baseY), height * coralGrowth, paint);
    }
    
    // Swaying anemones
    _drawAnemones(canvas, size, waveAnimation);
  }

  void _drawDeepOceanScene(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Massive rock formations
    paint.color = Colors.blueGrey.shade900.withValues(alpha: 0.6);
    for (int i = 0; i < 3; i++) {
      final rect = Rect.fromLTWH(
        i * size.width / 3 + size.width * 0.1,
        size.height * 0.6,
        size.width * 0.2,
        size.height * 0.4,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(20)),
        paint,
      );
    }
    
    // Artificial dive lights
    _drawDiveLights(canvas, size, depthProgress);
  }

  void _drawAbyssalZoneScene(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Ancient coral cities
    paint.shader = RadialGradient(
      colors: [
        Colors.purple.shade900.withValues(alpha: 0.5),
        Colors.black.withValues(alpha: 0.8),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    // Mysterious structures
    for (int i = 0; i < 5; i++) {
      final x = (i + 1) * size.width / 6;
      final y = size.height * 0.5 + math.sin(i + waveAnimation) * 30;
      
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, y),
          width: 40,
          height: 150 * coralGrowth,
        ),
        paint,
      );
    }
    
    // Bioluminescent orbs
    _drawBioluminescentOrbs(canvas, size, waveAnimation);
  }

  void _drawCoralPolyps(Canvas canvas, Size size, Color color, double growth) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 20; i++) {
      final x = math.Random(i).nextDouble() * size.width;
      final y = size.height * 0.75 + math.Random(i * 2).nextDouble() * 50;
      final radius = 3 + growth * 5;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _drawBranchingCoral(Canvas canvas, Offset base, double height, Paint paint) {
    final path = Path()
      ..moveTo(base.dx, base.dy)
      ..lineTo(base.dx - 10, base.dy - height * 0.3)
      ..moveTo(base.dx, base.dy)
      ..lineTo(base.dx, base.dy - height)
      ..moveTo(base.dx, base.dy)
      ..lineTo(base.dx + 10, base.dy - height * 0.3);
    
    canvas.drawPath(path, paint..style = PaintingStyle.stroke..strokeWidth = 4);
  }

  void _drawAnemones(Canvas canvas, Size size, double wave) {
    final paint = Paint();
    
    for (int i = 0; i < 6; i++) {
      final x = (i + 1) * size.width / 7;
      final y = size.height * 0.65;
      
      paint.shader = RadialGradient(
        colors: [
          Colors.teal.shade300.withValues(alpha: 0.7),
          Colors.teal.shade700.withValues(alpha: 0.3),
        ],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: 30));
      
      for (int j = 0; j < 12; j++) {
        final angle = j * math.pi * 2 / 12;
        final tentacleEnd = Offset(
          x + math.cos(angle + wave) * 25,
          y + math.sin(angle + wave) * 25 - 10,
        );
        
        canvas.drawLine(Offset(x, y), tentacleEnd, paint..strokeWidth = 2);
      }
    }
  }

  void _drawDiveLights(Canvas canvas, Size size, double progress) {
    final paint = Paint();
    
    for (int i = 0; i < 2; i++) {
      final x = size.width * (0.3 + i * 0.4);
      final y = size.height * 0.2;
      
      paint.shader = RadialGradient(
        colors: [
          Colors.yellow.withValues(alpha: 0.6),
          Colors.yellow.withValues(alpha: 0.1),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(x, y + progress * 100),
        radius: 80,
      ));
      
      canvas.drawCircle(Offset(x, y + progress * 100), 80, paint);
    }
  }

  void _drawBioluminescentOrbs(Canvas canvas, Size size, double wave) {
    final paint = Paint();
    
    for (int i = 0; i < 8; i++) {
      final x = size.width * 0.2 + (i * size.width * 0.1);
      final y = size.height * 0.4 + math.sin(wave * 2 + i) * 50;
      
      paint.shader = RadialGradient(
        colors: [
          Colors.cyanAccent.withValues(alpha: 0.8),
          Colors.cyanAccent.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: 15));
      
      canvas.drawCircle(Offset(x, y), 15 + math.sin(wave * 3) * 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BiomeEnvironmentPainter oldDelegate) {
    return depthProgress != oldDelegate.depthProgress ||
           waveAnimation != oldDelegate.waveAnimation ||
           coralGrowth != oldDelegate.coralGrowth;
  }
}

/// Painter for floating marine particles
class _FloatingParticlesPainter extends CustomPainter {
  final double particleAnimation;
  final List<Color> biomeColors;
  final double intensity;

  _FloatingParticlesPainter({
    required this.particleAnimation,
    required this.biomeColors,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity < 0.1) return;
    
    final paint = Paint();
    final random = math.Random(42); // Fixed seed for consistent particles
    
    final effectiveParticleCount = (AnimationConstants.maxFloatingParticleIntensity * intensity).round();
    for (int i = 0; i < effectiveParticleCount; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final y = (baseY + particleAnimation * size.height) % size.height;
      final radius = 1 + random.nextDouble() * 3;
      final colorIndex = i % biomeColors.length;
      
      paint.color = biomeColors[colorIndex].withValues(alpha: 0.3 + random.nextDouble() * 0.3);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingParticlesPainter oldDelegate) {
    return particleAnimation != oldDelegate.particleAnimation ||
           intensity != oldDelegate.intensity;
  }
}