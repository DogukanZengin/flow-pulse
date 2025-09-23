import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/creature.dart';

/// Simplified creature rendering focused on biome-specific visual authenticity
/// No database complexity - just pure visual distinction between biomes
class SimpleBiomeCreatures {
  /// Paint a biome-appropriate creature with simple, recognizable shapes
  static void paintBiomeCreature(Canvas canvas, Size size, BiomeType biome,
      int creatureIndex, double animationValue, double depth) {

    final center = Offset(size.width / 2, size.height / 2);
    final scale = _getBiomeScale(biome, depth);

    switch (biome) {
      case BiomeType.shallowWaters:
        _paintShallowWaterCreature(canvas, center, creatureIndex, animationValue, scale);
        break;
      case BiomeType.coralGarden:
        _paintCoralGardenCreature(canvas, center, creatureIndex, animationValue, scale);
        break;
      case BiomeType.deepOcean:
        _paintDeepOceanCreature(canvas, center, creatureIndex, animationValue, scale);
        break;
      case BiomeType.abyssalZone:
        _paintAbyssalCreature(canvas, center, creatureIndex, animationValue, scale);
        break;
    }
  }

  // SHALLOW WATERS: Bright, small, energetic fish
  static void _paintShallowWaterCreature(Canvas canvas, Offset center,
      int creatureIndex, double animationValue, double scale) {

    final bodySize = 12.0 * scale;
    final colors = _getShallowWaterColors(creatureIndex);
    final tailWag = math.sin(animationValue * 8) * 3; // Fast, energetic movement

    // Small, round body for tropical fish
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: [colors.body, colors.body.withValues(alpha: 0.8)],
      ).createShader(Rect.fromCenter(center: center, width: bodySize * 2, height: bodySize));

    canvas.drawOval(
      Rect.fromCenter(center: center, width: bodySize * 2, height: bodySize),
      bodyPaint,
    );

    // Bright, fan-shaped tail
    final tailPaint = Paint()..color = colors.accent;
    final tailPath = Path();
    final tailCenter = center.translate(-bodySize * 0.8, tailWag);

    tailPath.moveTo(tailCenter.dx, tailCenter.dy - bodySize * 0.4);
    tailPath.lineTo(tailCenter.dx - bodySize * 0.6, tailCenter.dy - bodySize * 0.2);
    tailPath.lineTo(tailCenter.dx - bodySize * 0.6, tailCenter.dy + bodySize * 0.2);
    tailPath.lineTo(tailCenter.dx, tailCenter.dy + bodySize * 0.4);
    tailPath.close();
    canvas.drawPath(tailPath, tailPaint);

    // Bright eye for tropical fish
    canvas.drawCircle(
      center.translate(bodySize * 0.3, -bodySize * 0.2),
      bodySize * 0.15,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      center.translate(bodySize * 0.3, -bodySize * 0.2),
      bodySize * 0.08,
      Paint()..color = Colors.black,
    );

    // Colorful stripes for tropical authenticity
    _paintTropicalStripes(canvas, center, bodySize, colors.accent);
  }

  // CORAL GARDEN: Medium-sized, varied shapes, territorial behavior
  static void _paintCoralGardenCreature(Canvas canvas, Offset center,
      int creatureIndex, double animationValue, double scale) {

    final bodySize = 18.0 * scale;
    final colors = _getCoralGardenColors(creatureIndex);
    final bodyWave = math.sin(animationValue * 5) * 2; // Moderate movement
    final territorialMotion = math.sin(animationValue * 3) * 4;

    // More angular body for reef fish
    final bodyPaint = Paint()..color = colors.body;
    final bodyPath = Path();

    // Diamond-shaped body typical of reef fish
    bodyPath.moveTo(center.dx - bodySize, center.dy);
    bodyPath.lineTo(center.dx, center.dy - bodySize * 0.6);
    bodyPath.lineTo(center.dx + bodySize, center.dy);
    bodyPath.lineTo(center.dx, center.dy + bodySize * 0.6);
    bodyPath.close();

    canvas.drawPath(bodyPath, bodyPaint);

    // Elaborate fins for reef fish
    final finPaint = Paint()..color = colors.accent;

    // Dorsal fin with territorial display
    final dorsalPath = Path();
    final dorsalHeight = bodySize * 0.8 + territorialMotion;
    dorsalPath.moveTo(center.dx - bodySize * 0.3, center.dy - bodySize * 0.6);
    dorsalPath.lineTo(center.dx, center.dy - dorsalHeight);
    dorsalPath.lineTo(center.dx + bodySize * 0.3, center.dy - bodySize * 0.6);
    canvas.drawPath(dorsalPath, finPaint);

    // Pectoral fins
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(bodySize * 0.7, bodyWave),
        width: bodySize * 0.8, height: bodySize * 0.4,
      ),
      finPaint,
    );

    // Detailed eye for alertness
    canvas.drawCircle(
      center.translate(bodySize * 0.4, -bodySize * 0.1),
      bodySize * 0.2,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      center.translate(bodySize * 0.4, -bodySize * 0.1),
      bodySize * 0.12,
      Paint()..color = Colors.black,
    );
  }

  // DEEP OCEAN: Large, streamlined, darker colors
  static void _paintDeepOceanCreature(Canvas canvas, Offset center,
      int creatureIndex, double animationValue, double scale) {

    final bodySize = 28.0 * scale;
    final colors = _getDeepOceanColors(creatureIndex);
    final slowWave = math.sin(animationValue * 2) * 1.5; // Slow, efficient movement

    // Streamlined, torpedo-shaped body
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          colors.body,
          colors.body.withValues(alpha: 0.9),
          colors.body.withValues(alpha: 0.7),
        ],
      ).createShader(Rect.fromCenter(center: center, width: bodySize * 3, height: bodySize));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: bodySize * 3, height: bodySize),
        Radius.circular(bodySize * 0.5),
      ),
      bodyPaint,
    );

    // Powerful, crescent tail for deep ocean swimming
    final tailPaint = Paint()..color = colors.accent;
    final tailPath = Path();
    final tailBase = center.translate(-bodySize * 1.2, slowWave);

    tailPath.moveTo(tailBase.dx, tailBase.dy - bodySize * 0.6);
    tailPath.quadraticBezierTo(
      tailBase.dx - bodySize * 0.8, tailBase.dy - bodySize * 0.4,
      tailBase.dx - bodySize * 1.2, tailBase.dy - bodySize * 0.2,
    );
    tailPath.quadraticBezierTo(
      tailBase.dx - bodySize * 0.8, tailBase.dy,
      tailBase.dx - bodySize * 1.2, tailBase.dy + bodySize * 0.2,
    );
    tailPath.quadraticBezierTo(
      tailBase.dx - bodySize * 0.8, tailBase.dy + bodySize * 0.4,
      tailBase.dx, tailBase.dy + bodySize * 0.6,
    );
    tailPath.close();
    canvas.drawPath(tailPath, tailPaint);

    // Large eye for deep ocean vision
    canvas.drawCircle(
      center.translate(bodySize * 0.8, -bodySize * 0.1),
      bodySize * 0.25,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      center.translate(bodySize * 0.8, -bodySize * 0.1),
      bodySize * 0.18,
      Paint()..color = Colors.black,
    );

    // Subtle bioluminescent dots
    _paintBioluminescentDots(canvas, center, bodySize, animationValue, colors.accent);
  }

  // ABYSSAL ZONE: Bioluminescent, mysterious shapes
  static void _paintAbyssalCreature(Canvas canvas, Offset center,
      int creatureIndex, double animationValue, double scale) {

    final bodySize = 22.0 * scale;
    final colors = _getAbyssalColors(creatureIndex);
    final mysterySway = math.sin(animationValue * 1.5) * 2; // Very slow, hypnotic movement
    final biolumPulse = (math.sin(animationValue * 4) + 1) / 2;

    // Alien, elongated body shapes
    final bodyPaint = Paint()..color = colors.body;

    if (creatureIndex % 3 == 0) {
      // Anglerfish-style
      _paintAnglerfish(canvas, center, bodySize, mysterySway, bodyPaint, colors.accent, biolumPulse);
    } else if (creatureIndex % 3 == 1) {
      // Jellyfish-style
      _paintAbyssalJellyfish(canvas, center, bodySize, mysterySway, bodyPaint, colors.accent, biolumPulse);
    } else {
      // Serpentine deep-sea creature
      _paintSerpentine(canvas, center, bodySize, animationValue, bodyPaint, colors.accent, biolumPulse);
    }
  }

  // Helper methods for specific abyssal creatures
  static void _paintAnglerfish(Canvas canvas, Offset center, double bodySize,
      double sway, Paint bodyPaint, Color biolumColor, double pulse) {

    // Large head, small body
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(sway, 0),
        width: bodySize * 2.5, height: bodySize * 1.8,
      ),
      bodyPaint,
    );

    // Bioluminescent lure
    final lurePaint = Paint()
      ..color = biolumColor.withValues(alpha: pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(
      center.translate(bodySize * 1.8 + sway, -bodySize * 1.2),
      bodySize * 0.3,
      lurePaint,
    );

    // Menacing teeth
    final teethPaint = Paint()..color = Colors.white;
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        center.translate(bodySize * (0.5 + i * 0.2) + sway, bodySize * 0.3),
        bodySize * 0.1,
        teethPaint,
      );
    }
  }

  static void _paintAbyssalJellyfish(Canvas canvas, Offset center, double bodySize,
      double sway, Paint bodyPaint, Color biolumColor, double pulse) {

    // Bell-shaped body
    final bellPath = Path();
    bellPath.addArc(
      Rect.fromCenter(center: center, width: bodySize * 2, height: bodySize * 1.5),
      0, math.pi,
    );
    canvas.drawPath(bellPath, bodyPaint);

    // Flowing tentacles
    final tentaclePaint = Paint()
      ..color = biolumColor.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 4; i++) {
      final tentaclePath = Path();
      final startX = center.dx - bodySize + (i * bodySize * 0.5);
      tentaclePath.moveTo(startX, center.dy + bodySize * 0.3);

      for (double t = 0; t <= 1; t += 0.1) {
        final y = center.dy + bodySize * (0.3 + t * 2);
        final x = startX + math.sin(t * math.pi * 3 + sway + i) * bodySize * 0.3;
        tentaclePath.lineTo(x, y);
      }
      canvas.drawPath(tentaclePath, tentaclePaint);
    }

    // Bioluminescent pulsing rim
    final rimPaint = Paint()
      ..color = biolumColor.withValues(alpha: pulse * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawArc(
      Rect.fromCenter(center: center, width: bodySize * 2, height: bodySize * 1.5),
      0, math.pi, false, rimPaint,
    );
  }

  static void _paintSerpentine(Canvas canvas, Offset center, double bodySize,
      double animationValue, Paint bodyPaint, Color biolumColor, double pulse) {

    // Snake-like body with undulating segments
    final segmentPaint = Paint()..color = bodyPaint.color;

    for (int i = 0; i < 8; i++) {
      final t = i / 7.0;
      final segmentCenter = Offset(
        center.dx + (t - 0.5) * bodySize * 3,
        center.dy + math.sin(animationValue * 2 + t * math.pi * 2) * bodySize * 0.5,
      );

      final segmentSize = bodySize * (1.2 - t * 0.4); // Tapering body
      canvas.drawCircle(segmentCenter, segmentSize * 0.4, segmentPaint);

      // Bioluminescent spots along the body
      if (i % 2 == 0) {
        final spotPaint = Paint()
          ..color = biolumColor.withValues(alpha: pulse * 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        canvas.drawCircle(segmentCenter, segmentSize * 0.2, spotPaint);
      }
    }
  }

  // Color schemes for each biome
  static BiomeColors _getShallowWaterColors(int index) {
    final colors = [
      BiomeColors(
        body: const Color(0xFFFF8C00), // Orange clownfish
        accent: const Color(0xFFFFFFFF), // White stripes
      ),
      BiomeColors(
        body: const Color(0xFFFFD700), // Yellow tang
        accent: const Color(0xFF0000FF), // Blue accents
      ),
      BiomeColors(
        body: const Color(0xFF00BFFF), // Blue damselfish
        accent: const Color(0xFFFFFFFF), // White fins
      ),
      BiomeColors(
        body: const Color(0xFF9370DB), // Purple angelfish
        accent: const Color(0xFFFFD700), // Gold stripes
      ),
    ];
    return colors[index % colors.length];
  }

  static BiomeColors _getCoralGardenColors(int index) {
    final colors = [
      BiomeColors(
        body: const Color(0xFF20B2AA), // Teal parrotfish
        accent: const Color(0xFF00FF7F), // Spring green
      ),
      BiomeColors(
        body: const Color(0xFFFF6347), // Tomato butterflyfish
        accent: const Color(0xFFFFFFFF), // White patterns
      ),
      BiomeColors(
        body: const Color(0xFF4169E1), // Royal blue wrasse
        accent: const Color(0xFFFFD700), // Gold highlights
      ),
      BiomeColors(
        body: const Color(0xFF8B4513), // Brown triggerfish
        accent: const Color(0xFFFF4500), // Orange red fins
      ),
    ];
    return colors[index % colors.length];
  }

  static BiomeColors _getDeepOceanColors(int index) {
    final colors = [
      BiomeColors(
        body: const Color(0xFF2F4F4F), // Dark slate gray shark
        accent: const Color(0xFF87CEEB), // Sky blue
      ),
      BiomeColors(
        body: const Color(0xFF696969), // Dim gray ray
        accent: const Color(0xFFB0C4DE), // Light steel blue
      ),
      BiomeColors(
        body: const Color(0xFF191970), // Midnight blue tuna
        accent: const Color(0xFF4682B4), // Steel blue
      ),
      BiomeColors(
        body: const Color(0xFF708090), // Slate gray barracuda
        accent: const Color(0xFFE6E6FA), // Lavender
      ),
    ];
    return colors[index % colors.length];
  }

  static BiomeColors _getAbyssalColors(int index) {
    final colors = [
      BiomeColors(
        body: const Color(0xFF000000), // Black anglerfish
        accent: const Color(0xFF00FFFF), // Cyan bioluminescence
      ),
      BiomeColors(
        body: const Color(0xFF2F2F4F), // Dark gray jellyfish
        accent: const Color(0xFF9370DB), // Purple glow
      ),
      BiomeColors(
        body: const Color(0xFF483D8B), // Dark slate blue
        accent: const Color(0xFF00FF00), // Lime green lights
      ),
      BiomeColors(
        body: const Color(0xFF8B008B), // Dark magenta
        accent: const Color(0xFFFF1493), // Deep pink glow
      ),
    ];
    return colors[index % colors.length];
  }

  // Helper methods for visual effects
  static void _paintTropicalStripes(Canvas canvas, Offset center, double bodySize, Color stripeColor) {
    final stripePaint = Paint()
      ..color = stripeColor.withValues(alpha: 0.8)
      ..strokeWidth = bodySize * 0.1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(center.dx - bodySize * 0.5, center.dy + (i - 1) * bodySize * 0.3),
        Offset(center.dx + bodySize * 0.5, center.dy + (i - 1) * bodySize * 0.3),
        stripePaint,
      );
    }
  }

  static void _paintBioluminescentDots(Canvas canvas, Offset center, double bodySize,
      double animationValue, Color glowColor) {
    final dotPaint = Paint()
      ..color = glowColor.withValues(alpha: (math.sin(animationValue * 6) + 1) / 4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    for (int i = 0; i < 6; i++) {
      final dotPos = Offset(
        center.dx + (i - 2.5) * bodySize * 0.3,
        center.dy + math.sin(i.toDouble()) * bodySize * 0.2,
      );
      canvas.drawCircle(dotPos, bodySize * 0.08, dotPaint);
    }
  }

  static double _getBiomeScale(BiomeType biome, double depth) {
    switch (biome) {
      case BiomeType.shallowWaters:
        return 0.8; // Small, agile fish
      case BiomeType.coralGarden:
        return 1.0; // Medium-sized reef fish
      case BiomeType.deepOcean:
        return 1.4; // Large pelagic species
      case BiomeType.abyssalZone:
        return 1.1; // Varied sizes, often smaller due to energy conservation
    }
  }
}

/// Simple color data class for biome creatures
class BiomeColors {
  final Color body;
  final Color accent;

  const BiomeColors({
    required this.body,
    required this.accent,
  });
}