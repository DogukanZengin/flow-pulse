import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/creature.dart';
import 'simple_biome_creatures.dart';

/// Advanced shader effects for biome creatures
/// These enhance the simplified system with modern Flutter graphics capabilities
class BiomeCreatureShaders {

  /// Create a bioluminescent glow shader for deep-sea creatures
  static ui.FragmentShader? createBioluminescentShader() {
    // This would be implemented when fragment shaders are needed
    // For now, we'll use gradient-based effects
    return null;
  }

  /// Create water distortion effect for swimming motion
  static Paint createSwimmingDistortionPaint(Color baseColor, double animationValue) {
    return Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          baseColor,
          baseColor.withValues(alpha: 0.8),
          baseColor.withValues(alpha: 0.6),
        ],
        stops: [0.0, 0.7, 1.0],
        transform: GradientRotation(animationValue * 2),
      ).createShader(const Rect.fromLTWH(0, 0, 100, 100));
  }

  /// Create depth-based lighting effect
  static Paint createDepthLightingPaint(Color baseColor, double depth) {
    final lightIntensity = (1.0 - (depth / 50.0)).clamp(0.2, 1.0);

    return Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseColor.withValues(alpha: lightIntensity),
          baseColor.withValues(alpha: lightIntensity * 0.7),
          baseColor.withValues(alpha: lightIntensity * 0.5),
        ],
      ).createShader(const Rect.fromLTWH(0, 0, 100, 100));
  }

  /// Create coral reflection effect for garden biome
  static Paint createCoralReflectionPaint(Color baseColor) {
    return Paint()
      ..shader = LinearGradient(
        colors: [
          baseColor,
          Colors.pink.withValues(alpha: 0.3),
          Colors.orange.withValues(alpha: 0.2),
          baseColor,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(const Rect.fromLTWH(0, 0, 100, 100));
  }

  /// Create surface light rays for shallow water
  static void paintLightRays(Canvas canvas, Size size, double animationValue) {
    final rayPaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.1)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      final rayOffset = (animationValue + i * 0.2) % 1.0;
      final startX = size.width * (0.1 + i * 0.2);
      final endX = startX + (rayOffset * 20);

      canvas.drawLine(
        Offset(startX, 0),
        Offset(endX, size.height),
        rayPaint,
      );
    }
  }
}

/// Extension methods for enhanced biome rendering
extension BiomeEnhancedRendering on SimpleBiomeCreatures {

  /// Add modern visual enhancements to basic creature rendering
  static void paintEnhancedBiomeCreature(Canvas canvas, Size size, BiomeType biome,
      int creatureIndex, double animationValue, double depth) {

    // First paint the basic creature
    SimpleBiomeCreatures.paintBiomeCreature(
      canvas, size, biome, creatureIndex, animationValue, depth);

    // Add biome-specific enhancements
    switch (biome) {
      case BiomeType.shallowWaters:
        BiomeCreatureShaders.paintLightRays(canvas, size, animationValue);
        break;
      case BiomeType.coralGarden:
        _addCoralReflections(canvas, size, animationValue);
        break;
      case BiomeType.deepOcean:
        _addDepthEffects(canvas, size, depth, animationValue);
        break;
      case BiomeType.abyssalZone:
        _addBioluminescentEffects(canvas, size, animationValue);
        break;
    }
  }

  static void _addCoralReflections(Canvas canvas, Size size, double animationValue) {
    final reflectionPaint = Paint()
      ..color = Colors.pink.withValues(alpha: 0.1 * (math.sin(animationValue * 4) + 1) / 2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.6,
      reflectionPaint,
    );
  }

  static void _addDepthEffects(Canvas canvas, Size size, double depth, double animationValue) {
    final pressureEffect = (depth / 50.0).clamp(0.0, 1.0);
    final effectPaint = Paint()
      ..color = Colors.blue.withValues(alpha: pressureEffect * 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * (1.0 + pressureEffect * 0.3),
        height: size.height * (1.0 + pressureEffect * 0.2),
      ),
      effectPaint,
    );
  }

  static void _addBioluminescentEffects(Canvas canvas, Size size, double animationValue) {
    final glowIntensity = (math.sin(animationValue * 3) + 1) / 2;
    final glowPaint = Paint()
      ..color = Colors.cyan.withValues(alpha: glowIntensity * 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Multiple glow rings for mysterious effect
    for (int i = 0; i < 3; i++) {
      final ringRadius = size.width * (0.3 + i * 0.2) * glowIntensity;
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        ringRadius,
        glowPaint,
      );
    }
  }
}