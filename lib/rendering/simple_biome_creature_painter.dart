import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/creature.dart';
import '../models/biome_creature.dart';

/// Simplified, high-performance creature painter for biome-specific creatures
/// Focuses on visual authenticity with minimal computational overhead
class SimpleBiomeCreaturePainter extends CustomPainter {
  final BiomeType biome;
  final int creatureIndex;
  final int swimDirection;
  final double animationValue;
  final double depth;

  // Cached paint objects for performance
  static final Map<String, Paint> _paintCache = {};

  SimpleBiomeCreaturePainter({
    required this.biome,
    required this.creatureIndex,
    required this.swimDirection,
    required this.animationValue,
    required this.depth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    canvas.save();

    // Apply horizontal flip based on swim direction
    if (swimDirection < 0) {
      canvas.scale(-1, 1);
      canvas.translate(-size.width, 0);
    }

    // Get creature data for this biome and index
    final creature = BiomeCreature.forBiome(biome, creatureIndex);

    // Apply scaling and breathing animation
    final baseScale = creature.size.scale;
    final breathingScale = 1.0 + (math.sin(animationValue * 6) * 0.08);
    final totalScale = baseScale * breathingScale;

    canvas.translate(center.dx, center.dy);
    canvas.scale(totalScale);
    canvas.translate(-center.dx, -center.dy);

    // Render creature based on biome with performance optimizations
    _renderCreatureForBiome(canvas, size, creature);

    canvas.restore();
  }

  void _renderCreatureForBiome(Canvas canvas, Size size, BiomeCreature creature) {
    final creatureSize = _getCreatureSizeForBiome(creature.biome);
    final center = Offset(size.width / 2, size.height / 2);

    // Get cached paints for performance
    final bodyPaint = _getCachedPaint(
      '${creature.species}_body',
      creature.primaryColor.withValues(alpha: _getOpacityForDepth()),
    );

    final accentPaint = _getCachedPaint(
      '${creature.species}_accent',
      creature.secondaryColor.withValues(alpha: _getOpacityForDepth() * 0.8),
    );

    switch (creature.biome) {
      case BiomeType.shallowWaters:
        _renderShallowWaterCreature(canvas, center, creatureSize, bodyPaint, accentPaint);
        break;
      case BiomeType.coralGarden:
        _renderCoralGardenCreature(canvas, center, creatureSize, bodyPaint, accentPaint);
        break;
      case BiomeType.deepOcean:
        _renderDeepOceanCreature(canvas, center, creatureSize, bodyPaint, accentPaint);
        break;
      case BiomeType.abyssalZone:
        _renderAbyssalCreature(canvas, center, creatureSize, bodyPaint, accentPaint);
        break;
    }
  }

  Paint _getCachedPaint(String key, Color color) {
    if (!_paintCache.containsKey(key)) {
      _paintCache[key] = Paint()..style = PaintingStyle.fill;
    }
    _paintCache[key]!.color = color;
    return _paintCache[key]!;
  }

  double _getCreatureSizeForBiome(BiomeType biome) {
    switch (biome) {
      case BiomeType.shallowWaters:
        return 18.0; // Small, energetic fish
      case BiomeType.coralGarden:
        return 22.0; // Medium reef fish
      case BiomeType.deepOcean:
        return 28.0; // Large pelagic creatures
      case BiomeType.abyssalZone:
        return 26.0; // Mysterious deep creatures
    }
  }

  double _getOpacityForDepth() {
    switch (biome) {
      case BiomeType.shallowWaters:
        return 0.95;
      case BiomeType.coralGarden:
        return 0.9;
      case BiomeType.deepOcean:
        return 0.8;
      case BiomeType.abyssalZone:
        return 0.7;
    }
  }

  // Shallow Waters: Small, darting fish with schooling behavior
  void _renderShallowWaterCreature(Canvas canvas, Offset center, double size, Paint bodyPaint, Paint accentPaint) {
    final bodyWidth = size * 1.6;
    final bodyHeight = size * 0.7;

    // Main body - streamlined for speed
    canvas.drawOval(
      Rect.fromCenter(center: center, width: bodyWidth, height: bodyHeight),
      bodyPaint,
    );

    // Fast-swimming tail
    final tailPath = Path();
    final tailBase = center.translate(-bodyWidth * 0.4, 0);
    tailPath.moveTo(tailBase.dx, tailBase.dy - bodyHeight * 0.25);
    tailPath.lineTo(tailBase.dx - bodyWidth * 0.5, tailBase.dy);
    tailPath.lineTo(tailBase.dx, tailBase.dy + bodyHeight * 0.25);
    tailPath.close();
    canvas.drawPath(tailPath, bodyPaint);

    // Simple stripe pattern for schooling fish
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(bodyWidth * 0.1, 0),
        width: bodyWidth * 0.5,
        height: bodyHeight * 0.3
      ),
      accentPaint,
    );

    // Small eye
    final eyePaint = _getCachedPaint('eye_black', Colors.black);
    canvas.drawCircle(center.translate(bodyWidth * 0.15, -bodyHeight * 0.1), size * 0.12, eyePaint);
  }

  // Coral Garden: Medium fish with territorial, weaving movement
  void _renderCoralGardenCreature(Canvas canvas, Offset center, double size, Paint bodyPaint, Paint accentPaint) {
    final bodyWidth = size * 1.8;
    final bodyHeight = size * 1.0;

    // Rounded reef fish body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: bodyWidth, height: bodyHeight),
        Radius.circular(size * 0.25),
      ),
      bodyPaint,
    );

    // Dorsal fin
    final dorsalPath = Path();
    final dorsalBase = center.translate(bodyWidth * 0.1, -bodyHeight * 0.5);
    dorsalPath.moveTo(dorsalBase.dx - bodyWidth * 0.15, dorsalBase.dy);
    dorsalPath.lineTo(dorsalBase.dx, dorsalBase.dy - bodyHeight * 0.4);
    dorsalPath.lineTo(dorsalBase.dx + bodyWidth * 0.15, dorsalBase.dy);
    dorsalPath.close();
    canvas.drawPath(dorsalPath, accentPaint);

    // Pectoral fin
    final pectoralPath = Path();
    final pectoralBase = center.translate(bodyWidth * 0.3, bodyHeight * 0.1);
    pectoralPath.moveTo(pectoralBase.dx, pectoralBase.dy - bodyHeight * 0.2);
    pectoralPath.lineTo(pectoralBase.dx + bodyWidth * 0.3, pectoralBase.dy - bodyHeight * 0.15);
    pectoralPath.lineTo(pectoralBase.dx + bodyWidth * 0.25, pectoralBase.dy + bodyHeight * 0.1);
    pectoralPath.close();
    canvas.drawPath(pectoralPath, accentPaint);

    // Curved tail for agile maneuvering
    final tailPath = Path();
    final tailBase = center.translate(-bodyWidth * 0.4, 0);
    tailPath.moveTo(tailBase.dx, tailBase.dy - bodyHeight * 0.3);
    tailPath.quadraticBezierTo(
      tailBase.dx - bodyWidth * 0.3, tailBase.dy - bodyHeight * 0.2,
      tailBase.dx - bodyWidth * 0.5, tailBase.dy - bodyHeight * 0.1,
    );
    tailPath.quadraticBezierTo(
      tailBase.dx - bodyWidth * 0.3, tailBase.dy + bodyHeight * 0.2,
      tailBase.dx, tailBase.dy + bodyHeight * 0.3,
    );
    tailPath.close();
    canvas.drawPath(tailPath, accentPaint);

    // Prominent eye
    final eyeWhitePaint = _getCachedPaint('eye_white', Colors.white);
    canvas.drawCircle(center.translate(bodyWidth * 0.2, -bodyHeight * 0.12), size * 0.18, eyeWhitePaint);
    final eyeBlackPaint = _getCachedPaint('eye_black', Colors.black);
    canvas.drawCircle(center.translate(bodyWidth * 0.2, -bodyHeight * 0.12), size * 0.09, eyeBlackPaint);
  }

  // Deep Ocean: Large, graceful creatures with flowing movement
  void _renderDeepOceanCreature(Canvas canvas, Offset center, double size, Paint bodyPaint, Paint accentPaint) {
    final bodyWidth = size * 2.2;
    final bodyHeight = size * 1.3;

    // Streamlined pelagic body
    final bodyPath = Path();
    bodyPath.moveTo(center.dx + bodyWidth * 0.35, center.dy);
    bodyPath.quadraticBezierTo(
      center.dx + bodyWidth * 0.1, center.dy - bodyHeight * 0.6,
      center.dx - bodyWidth * 0.25, center.dy - bodyHeight * 0.25,
    );
    bodyPath.quadraticBezierTo(
      center.dx - bodyWidth * 0.35, center.dy,
      center.dx - bodyWidth * 0.25, center.dy + bodyHeight * 0.25,
    );
    bodyPath.quadraticBezierTo(
      center.dx + bodyWidth * 0.1, center.dy + bodyHeight * 0.6,
      center.dx + bodyWidth * 0.35, center.dy,
    );
    bodyPath.close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Large pectoral fin for gliding
    final pectoralPath = Path();
    final pectoralBase = center.translate(bodyWidth * 0.05, -bodyHeight * 0.1);
    pectoralPath.moveTo(pectoralBase.dx, pectoralBase.dy);
    pectoralPath.quadraticBezierTo(
      pectoralBase.dx + bodyWidth * 0.25, pectoralBase.dy - bodyHeight * 0.4,
      pectoralBase.dx + bodyWidth * 0.45, pectoralBase.dy - bodyHeight * 0.25,
    );
    pectoralPath.quadraticBezierTo(
      pectoralBase.dx + bodyWidth * 0.3, pectoralBase.dy - bodyHeight * 0.05,
      pectoralBase.dx, pectoralBase.dy,
    );
    canvas.drawPath(pectoralPath, accentPaint);

    // Powerful caudal fin
    final tailPath = Path();
    final tailBase = center.translate(-bodyWidth * 0.35, 0);
    tailPath.moveTo(tailBase.dx, tailBase.dy - bodyHeight * 0.4);
    tailPath.lineTo(tailBase.dx - bodyWidth * 0.4, tailBase.dy - bodyHeight * 0.6);
    tailPath.lineTo(tailBase.dx - bodyWidth * 0.35, tailBase.dy);
    tailPath.lineTo(tailBase.dx - bodyWidth * 0.4, tailBase.dy + bodyHeight * 0.6);
    tailPath.lineTo(tailBase.dx, tailBase.dy + bodyHeight * 0.4);
    tailPath.close();
    canvas.drawPath(tailPath, bodyPaint);

    // Large eye adapted for deep water
    final eyePaint = _getCachedPaint('eye_silver', Colors.grey.shade300);
    canvas.drawCircle(center.translate(bodyWidth * 0.12, -bodyHeight * 0.15), size * 0.22, eyePaint);
  }

  // Abyssal Zone: Mysterious creatures with bioluminescent effects
  void _renderAbyssalCreature(Canvas canvas, Offset center, double size, Paint bodyPaint, Paint accentPaint) {
    final bodyWidth = size * 2.0;
    final bodyHeight = size * 1.6;

    // Elongated, alien-like body
    final bodyPath = Path();
    bodyPath.moveTo(center.dx + bodyWidth * 0.3, center.dy);
    bodyPath.quadraticBezierTo(
      center.dx, center.dy - bodyHeight * 0.7,
      center.dx - bodyWidth * 0.5, center.dy,
    );
    bodyPath.quadraticBezierTo(
      center.dx, center.dy + bodyHeight * 0.7,
      center.dx + bodyWidth * 0.3, center.dy,
    );
    bodyPath.close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Bioluminescent spots with pulsing effect
    final glowIntensity = 0.6 + (math.sin(animationValue * 4) * 0.4);
    final glowPaint = _getCachedPaint(
      'glow_${creatureIndex}',
      accentPaint.color.withValues(alpha: glowIntensity),
    );
    glowPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Multiple bioluminescent spots
    for (int i = 0; i < 4; i++) {
      final spotX = center.dx + bodyWidth * (0.1 - i * 0.15);
      final spotY = center.dy + (i - 1.5) * bodyHeight * 0.25;
      canvas.drawCircle(Offset(spotX, spotY), size * 0.08, glowPaint);
    }

    // Translucent, flowing fins
    final finPaint = _getCachedPaint(
      'abyssal_fin_${creatureIndex}',
      accentPaint.color.withValues(alpha: 0.4),
    );

    final dorsalFinPath = Path();
    dorsalFinPath.moveTo(center.dx - bodyWidth * 0.1, center.dy - bodyHeight * 0.5);
    dorsalFinPath.quadraticBezierTo(
      center.dx - bodyWidth * 0.25, center.dy - bodyHeight * 0.9,
      center.dx - bodyWidth * 0.15, center.dy - bodyHeight * 0.3,
    );
    dorsalFinPath.close();
    canvas.drawPath(dorsalFinPath, finPaint);

    // Large, adapted eye with subtle glow
    final eyePaint = _getCachedPaint('abyssal_eye', Colors.yellow.shade200);
    canvas.drawCircle(center.translate(bodyWidth * 0.15, -bodyHeight * 0.08), size * 0.28, eyePaint);

    // Eye glow effect
    final eyeGlowPaint = _getCachedPaint(
      'eye_glow_${creatureIndex}',
      Colors.yellow.withValues(alpha: 0.3 * glowIntensity),
    );
    eyeGlowPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(center.translate(bodyWidth * 0.15, -bodyHeight * 0.08), size * 0.35, eyeGlowPaint);

    // Lure for anglerfish-like creatures (only for some indices)
    if (creatureIndex % 3 == 0) {
      final lurePaint = _getCachedPaint(
        'lure_${creatureIndex}',
        Colors.yellow.withValues(alpha: glowIntensity),
      );
      lurePaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

      final lurePos = center.translate(bodyWidth * 0.25, -bodyHeight * 0.4);
      canvas.drawCircle(lurePos, size * 0.06, lurePaint);

      // Lure stalk
      final stalkPaint = _getCachedPaint('lure_stalk', bodyPaint.color.withValues(alpha: 0.8));
      canvas.drawLine(
        center.translate(bodyWidth * 0.2, -bodyHeight * 0.3),
        lurePos,
        stalkPaint..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SimpleBiomeCreaturePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.biome != biome ||
           oldDelegate.creatureIndex != creatureIndex ||
           oldDelegate.swimDirection != swimDirection;
  }

  /// Clear paint cache when no longer needed (call this when disposing)
  static void clearCache() {
    _paintCache.clear();
  }
}