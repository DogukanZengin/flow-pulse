import 'dart:math';
import 'package:flutter/material.dart';
import '../models/creature.dart';

class AdvancedCreatureRenderer {
  static const double commonScale = 1.0;
  static const double uncommonScale = 1.2;
  static const double rareScale = 1.5;
  static const double legendaryScale = 2.0;

  static void paintCreature(Canvas canvas, Size size, Creature creature, 
      double animationValue, double depth) {
    
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    
    // Scale based on rarity
    double scale = _getScaleForRarity(creature.rarity);
    scale *= _getDepthScale(depth);
    
    // Apply rarity-specific rendering
    switch (creature.rarity) {
      case CreatureRarity.common:
        _paintCommonCreature(canvas, center, creature, paint, scale, animationValue);
        break;
      case CreatureRarity.uncommon:
        _paintUncommonCreature(canvas, center, creature, paint, scale, animationValue);
        break;
      case CreatureRarity.rare:
        _paintRareCreature(canvas, center, creature, paint, scale, animationValue);
        break;
      case CreatureRarity.legendary:
        _paintLegendaryCreature(canvas, center, creature, paint, scale, animationValue);
        break;
    }
    
    // Add depth-based effects
    _addDepthEffects(canvas, center, creature, scale, depth, animationValue);
  }

  static double _getScaleForRarity(CreatureRarity rarity) {
    switch (rarity) {
      case CreatureRarity.common:
        return commonScale;
      case CreatureRarity.uncommon:
        return uncommonScale;
      case CreatureRarity.rare:
        return rareScale;
      case CreatureRarity.legendary:
        return legendaryScale;
    }
  }

  static double _getDepthScale(double depth) {
    // Deeper creatures appear larger due to pressure adaptation
    if (depth <= 10) return 1.0;
    if (depth <= 20) return 1.1;
    if (depth <= 40) return 1.3;
    return 1.5; // Abyssal zone
  }

  static void _paintCommonCreature(Canvas canvas, Offset center, Creature creature, 
      Paint paint, double scale, double animationValue) {
    
    // Simple fish shape with basic animation
    final bodySize = 20.0 * scale;
    final tailOffset = sin(animationValue * 4) * 3;
    
    // Body
    paint.color = _getCreatureColor(creature).withValues(alpha: 0.9);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: bodySize * 1.8, height: bodySize),
      paint,
    );
    
    // Tail
    final tailPath = Path();
    final tailCenter = center.translate(-bodySize * 0.9, tailOffset);
    tailPath.moveTo(tailCenter.dx, tailCenter.dy - bodySize * 0.3);
    tailPath.lineTo(tailCenter.dx - bodySize * 0.5, tailCenter.dy);
    tailPath.lineTo(tailCenter.dx, tailCenter.dy + bodySize * 0.3);
    tailPath.close();
    canvas.drawPath(tailPath, paint);
    
    // Simple fin animation
    _paintBasicFins(canvas, center, bodySize, scale, animationValue, paint);
  }

  static void _paintUncommonCreature(Canvas canvas, Offset center, Creature creature,
      Paint paint, double scale, double animationValue) {
    
    final bodySize = 25.0 * scale;
    final tailWave = sin(animationValue * 5) * 4;
    final finWave = sin(animationValue * 6) * 2;
    
    // Enhanced body with gradient effect
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          _getCreatureColor(creature),
          _getCreatureColor(creature).withValues(alpha: 0.6),
        ],
      ).createShader(Rect.fromCenter(center: center, width: bodySize * 2, height: bodySize * 1.2));
    
    canvas.drawOval(
      Rect.fromCenter(center: center, width: bodySize * 2, height: bodySize * 1.2),
      gradientPaint,
    );
    
    // Enhanced tail with wave motion
    final tailPath = Path();
    final tailCenter = center.translate(-bodySize * 0.9, tailWave);
    tailPath.moveTo(tailCenter.dx, tailCenter.dy - bodySize * 0.4);
    tailPath.quadraticBezierTo(
      tailCenter.dx - bodySize * 0.3, tailCenter.dy - tailWave,
      tailCenter.dx - bodySize * 0.6, tailCenter.dy,
    );
    tailPath.quadraticBezierTo(
      tailCenter.dx - bodySize * 0.3, tailCenter.dy + tailWave,
      tailCenter.dx, tailCenter.dy + bodySize * 0.4,
    );
    tailPath.close();
    canvas.drawPath(tailPath, gradientPaint);
    
    // Enhanced fins with animation
    _paintEnhancedFins(canvas, center, bodySize, scale, finWave, gradientPaint);
    
    // Small particle effects
    _paintSmallParticles(canvas, center, bodySize, animationValue, 3);
  }

  static void _paintRareCreature(Canvas canvas, Offset center, Creature creature,
      Paint paint, double scale, double animationValue) {
    
    final bodySize = 30.0 * scale;
    final complexMotion = sin(animationValue * 4) * 5;
    final shimmerEffect = (sin(animationValue * 8) + 1) / 2;
    
    // Complex body with shimmer effect
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          _getCreatureColor(creature),
          _getCreatureColor(creature).withValues(alpha: 0.8),
          Colors.white.withValues(alpha: shimmerEffect * 0.3),
          _getCreatureColor(creature).withValues(alpha: 0.8),
        ],
        stops: const [0.0, 0.3, 0.5, 1.0],
      ).createShader(Rect.fromCenter(center: center, width: bodySize * 2.5, height: bodySize * 1.4));
    
    // Main body with detailed shape
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: bodySize * 2.5, height: bodySize * 1.4),
        const Radius.circular(8),
      ),
      shimmerPaint,
    );
    
    // Complex tail with multiple segments
    _paintComplexTail(canvas, center, bodySize, scale, complexMotion, shimmerPaint);
    
    // Detailed fins with individual animation
    _paintDetailedFins(canvas, center, bodySize, scale, animationValue, shimmerPaint);
    
    // Glowing effects
    _paintGlowingEffects(canvas, center, bodySize, animationValue, _getCreatureColor(creature));
    
    // Medium particle effects
    _paintSmallParticles(canvas, center, bodySize, animationValue, 6);
  }

  static void _paintLegendaryCreature(Canvas canvas, Offset center, Creature creature,
      Paint paint, double scale, double animationValue) {
    
    final bodySize = 40.0 * scale;
    final epicMotion = sin(animationValue * 3) * 8;
    final pulseEffect = (sin(animationValue * 6) + 1) / 2;
    final auraEffect = (sin(animationValue * 2) + 1) / 2;
    
    // Epic aura effect
    _paintEpicAura(canvas, center, bodySize * 3, auraEffect, _getCreatureColor(creature));
    
    // Master-quality body with complex shader
    final epicPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.2),
          _getCreatureColor(creature),
          _getCreatureColor(creature).withValues(alpha: 0.9),
          Colors.black.withValues(alpha: 0.3),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromCenter(center: center, width: bodySize * 3, height: bodySize * 2));
    
    // Main body with epic proportions
    final bodyPath = Path();
    bodyPath.addOval(Rect.fromCenter(center: center, width: bodySize * 3, height: bodySize * 2));
    canvas.drawPath(bodyPath, epicPaint);
    
    // Epic tail with flowing animation
    _paintEpicTail(canvas, center, bodySize, scale, epicMotion, epicPaint);
    
    // Majestic fins with complex animation
    _paintMajesticFins(canvas, center, bodySize, scale, animationValue, epicPaint);
    
    // Screen-wide special effects
    _paintScreenWideEffects(canvas, center, bodySize, animationValue, pulseEffect, _getCreatureColor(creature));
    
    // Abundant particle effects
    _paintSmallParticles(canvas, center, bodySize * 2, animationValue, 12);
  }

  static Color _getCreatureColor(Creature creature) {
    // Enhanced color system based on biome and species
    switch (creature.habitat) {
      case BiomeType.shallowWaters:
        return _getShallowWaterColors(creature.species);
      case BiomeType.coralGarden:
        return _getCoralGardenColors(creature.species);
      case BiomeType.deepOcean:
        return _getDeepOceanColors(creature.species);
      case BiomeType.abyssalZone:
        return _getAbyssalZoneColors(creature.species);
    }
  }

  static Color _getShallowWaterColors(String species) {
    if (species.contains('Clownfish')) return Colors.orange.shade600;
    if (species.contains('Tang')) return Colors.yellow.shade500;
    if (species.contains('Damselfish')) return Colors.blue.shade400;
    if (species.contains('Chromis')) return Colors.lightGreen.shade400;
    if (species.contains('Mandarin')) return Colors.purple.shade400;
    if (species.contains('Angelfish')) return Colors.pink.shade400;
    return Colors.cyan.shade300;
  }

  static Color _getCoralGardenColors(String species) {
    if (species.contains('Parrotfish')) return Colors.teal.shade500;
    if (species.contains('Butterflyfish')) return Colors.amber.shade400;
    if (species.contains('Wrasse')) return Colors.indigo.shade400;
    if (species.contains('Triggerfish')) return Colors.brown.shade500;
    if (species.contains('Grouper')) return Colors.grey.shade600;
    if (species.contains('Sweetlips')) return Colors.red.shade400;
    return Colors.lightBlue.shade400;
  }

  static Color _getDeepOceanColors(String species) {
    if (species.contains('Shark')) return Colors.blueGrey.shade700;
    if (species.contains('Ray')) return Colors.grey.shade500;
    if (species.contains('Tuna')) return Colors.blue.shade800;
    if (species.contains('Barracuda')) return Colors.grey.shade300;
    if (species.contains('Dolphin')) return Colors.grey.shade400;
    if (species.contains('Whale')) return Colors.blueGrey.shade600;
    return Colors.deepPurple.shade600;
  }

  static Color _getAbyssalZoneColors(String species) {
    if (species.contains('Anglerfish')) return Colors.black87;
    if (species.contains('Lanternfish')) return Colors.yellow.shade300;
    if (species.contains('Squid')) return Colors.purple.shade900;
    if (species.contains('Jellyfish')) return Colors.cyan.shade200;
    if (species.contains('Kraken')) return Colors.deepPurple.shade900;
    if (species.contains('Leviathan')) return Colors.red.shade900;
    return Colors.indigo.shade900;
  }

  static void _addDepthEffects(Canvas canvas, Offset center, Creature creature,
      double scale, double depth, double animationValue) {
    
    if (depth > 20) {
      // Add bioluminescent effects for deep creatures
      final glowPaint = Paint()
        ..color = Colors.cyan.withValues(alpha: 0.3 * (sin(animationValue * 4) + 1) / 2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      
      canvas.drawCircle(center, 15 * scale, glowPaint);
    }
    
    if (depth > 40) {
      // Add mysterious effects for abyssal creatures
      final mysteryPaint = Paint()
        ..color = Colors.purple.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      
      canvas.drawCircle(center, 25 * scale, mysteryPaint);
    }
  }

  // Helper methods for fin painting
  static void _paintBasicFins(Canvas canvas, Offset center, double bodySize,
      double scale, double animationValue, Paint paint) {
    
    final finSize = bodySize * 0.6;
    final finMovement = sin(animationValue * 8) * 2;
    
    // Top fin
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, -bodySize * 0.4 + finMovement),
        width: finSize, height: finSize * 0.5,
      ),
      paint,
    );
    
    // Bottom fin
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, bodySize * 0.4 - finMovement),
        width: finSize, height: finSize * 0.5,
      ),
      paint,
    );
  }

  static void _paintEnhancedFins(Canvas canvas, Offset center, double bodySize,
      double scale, double finWave, Paint paint) {
    
    final finPath = Path();
    
    // Dorsal fin
    final dorsalStart = center.translate(bodySize * 0.3, -bodySize * 0.6);
    finPath.moveTo(dorsalStart.dx, dorsalStart.dy);
    finPath.quadraticBezierTo(
      dorsalStart.dx + bodySize * 0.2, dorsalStart.dy - bodySize * 0.3 + finWave,
      dorsalStart.dx + bodySize * 0.5, dorsalStart.dy,
    );
    finPath.lineTo(dorsalStart.dx + bodySize * 0.3, dorsalStart.dy + bodySize * 0.2);
    finPath.close();
    canvas.drawPath(finPath, paint);
    
    // Pectoral fins
    final pectoralPath = Path();
    final pectoralStart = center.translate(bodySize * 0.5, 0);
    pectoralPath.moveTo(pectoralStart.dx, pectoralStart.dy);
    pectoralPath.quadraticBezierTo(
      pectoralStart.dx + bodySize * 0.4 + finWave, pectoralStart.dy - bodySize * 0.3,
      pectoralStart.dx + bodySize * 0.2, pectoralStart.dy - bodySize * 0.5,
    );
    canvas.drawPath(pectoralPath, paint);
  }

  static void _paintDetailedFins(Canvas canvas, Offset center, double bodySize,
      double scale, double animationValue, Paint paint) {
    
    final finDetail1 = sin(animationValue * 6) * 3;
    final finDetail2 = sin(animationValue * 7 + 1) * 2;
    
    // Multiple fin layers for complex movement
    _paintEnhancedFins(canvas, center, bodySize, scale, finDetail1, paint);
    
    // Secondary fin details
    final detailPaint = Paint()..color = paint.color.withValues(alpha: 0.6);
    _paintEnhancedFins(canvas, center.translate(2, 0), bodySize * 0.8, scale, finDetail2, detailPaint);
  }

  static void _paintMajesticFins(Canvas canvas, Offset center, double bodySize,
      double scale, double animationValue, Paint paint) {
    
    final majesty1 = sin(animationValue * 4) * 5;
    final majesty2 = sin(animationValue * 5 + 0.5) * 4;
    final majesty3 = sin(animationValue * 6 + 1) * 3;
    
    // Multiple layers of majestic fins
    _paintDetailedFins(canvas, center, bodySize, scale, majesty1, paint);
    
    final layer2Paint = Paint()..color = paint.color.withValues(alpha: 0.7);
    _paintDetailedFins(canvas, center.translate(3, 1), bodySize * 0.9, scale, majesty2, layer2Paint);
    
    final layer3Paint = Paint()..color = Colors.white.withValues(alpha: 0.3);
    _paintDetailedFins(canvas, center.translate(-2, -1), bodySize * 1.1, scale, majesty3, layer3Paint);
  }

  // Helper methods for tail painting
  static void _paintComplexTail(Canvas canvas, Offset center, double bodySize,
      double scale, double motion, Paint paint) {
    
    final tailPath = Path();
    final tailBase = center.translate(-bodySize * 1.2, motion);
    
    // Multi-segment tail
    tailPath.moveTo(tailBase.dx, tailBase.dy - bodySize * 0.5);
    tailPath.quadraticBezierTo(
      tailBase.dx - bodySize * 0.4, tailBase.dy - motion * 0.5,
      tailBase.dx - bodySize * 0.8, tailBase.dy - bodySize * 0.2,
    );
    tailPath.quadraticBezierTo(
      tailBase.dx - bodySize * 1.2, tailBase.dy + motion,
      tailBase.dx - bodySize * 0.8, tailBase.dy + bodySize * 0.2,
    );
    tailPath.quadraticBezierTo(
      tailBase.dx - bodySize * 0.4, tailBase.dy + motion * 0.5,
      tailBase.dx, tailBase.dy + bodySize * 0.5,
    );
    tailPath.close();
    
    canvas.drawPath(tailPath, paint);
  }

  static void _paintEpicTail(Canvas canvas, Offset center, double bodySize,
      double scale, double motion, Paint paint) {
    
    // Multiple flowing tail segments
    _paintComplexTail(canvas, center, bodySize, scale, motion, paint);
    
    // Additional flowing elements
    final flowPaint = Paint()..color = paint.color.withValues(alpha: 0.6);
    _paintComplexTail(canvas, center.translate(-5, motion * 0.5), bodySize * 1.1, scale, motion * 1.2, flowPaint);
    
    final trailPaint = Paint()..color = Colors.white.withValues(alpha: 0.2);
    _paintComplexTail(canvas, center.translate(-8, motion * 0.3), bodySize * 1.2, scale, motion * 0.8, trailPaint);
  }

  // Helper methods for particle effects
  static void _paintSmallParticles(Canvas canvas, Offset center, double range,
      double animationValue, int count) {
    
    final particlePaint = Paint()..color = Colors.white.withValues(alpha: 0.6);
    
    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi + animationValue;
      final distance = range * (0.5 + 0.5 * sin(animationValue * 3 + i));
      final particlePos = center.translate(
        cos(angle) * distance,
        sin(angle) * distance,
      );
      
      final size = 1.0 + sin(animationValue * 5 + i) * 0.5;
      canvas.drawCircle(particlePos, size, particlePaint);
    }
  }

  static void _paintGlowingEffects(Canvas canvas, Offset center, double bodySize,
      double animationValue, Color baseColor) {
    
    final glowPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.3 * (sin(animationValue * 6) + 1) / 2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawCircle(center, bodySize * 0.8, glowPaint);
  }

  static void _paintEpicAura(Canvas canvas, Offset center, double radius,
      double auraEffect, Color baseColor) {
    
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          baseColor.withValues(alpha: 0.1 * auraEffect),
          baseColor.withValues(alpha: 0.2 * auraEffect),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromCenter(center: center, width: radius * 2, height: radius * 2));
    
    canvas.drawCircle(center, radius, auraPaint);
  }

  static void _paintScreenWideEffects(Canvas canvas, Offset center, double bodySize,
      double animationValue, double pulseEffect, Color baseColor) {
    
    // Screen-wide ripple effects
    final ripplePaint = Paint()
      ..color = baseColor.withValues(alpha: 0.1 * pulseEffect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    for (int i = 0; i < 3; i++) {
      final rippleRadius = bodySize * (2 + i) * pulseEffect;
      canvas.drawCircle(center, rippleRadius, ripplePaint);
    }
  }
}