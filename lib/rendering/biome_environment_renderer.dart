import 'dart:math';
import 'package:flutter/material.dart';
import '../models/creature.dart';

class BiomeEnvironmentRenderer {
  
  // Helper function to create smooth continuous oscillation (for sine waves)
  static double _getOscillation(double continuousTime, double frequency) {
    return sin(continuousTime * frequency * 2 * pi);
  }
  
  // Helper function for continuous linear motion (no resetting)
  static double _getLinearFlow(double continuousTime, double speed) {
    return continuousTime * speed;
  }
  
  static void paintBiomeEnvironment(Canvas canvas, Size size, BiomeType biome,
      double depth, double sessionProgress, double animationValue) {
    
    // Paint background gradient
    _paintBackgroundGradient(canvas, size, biome, depth);
    
    // Paint dynamic lighting
    _paintDynamicLighting(canvas, size, biome, depth, animationValue);
    
    // Paint biome-specific features
    _paintBiomeFeatures(canvas, size, biome, depth, sessionProgress, animationValue);
    
    // Paint particle systems
    _paintParticleSystems(canvas, size, biome, depth, animationValue);
    
    // Paint depth transition effects
    _paintDepthTransitionEffects(canvas, size, depth, animationValue);
  }

  static void _paintBackgroundGradient(Canvas canvas, Size size, BiomeType biome, double depth) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    late LinearGradient gradient;
    
    switch (biome) {
      case BiomeType.shallowWaters:
        gradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF87CEEB), // Sky blue
            const Color(0xFF00BFFF), // Deep sky blue
            Color.lerp(const Color(0xFF00A6D6), const Color(0xFF0077BE), depth / 10) ?? const Color(0xFF00A6D6),
          ],
        );
        break;
      case BiomeType.coralGarden:
        gradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF40E0D0), // Turquoise
            const Color(0xFF20B2AA), // Light sea green
            Color.lerp(const Color(0xFF008B8B), const Color(0xFF006666), depth / 20) ?? const Color(0xFF008B8B),
          ],
        );
        break;
      case BiomeType.deepOcean:
        gradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF000080), // Navy blue
            const Color(0xFF003366), // Dark blue
            Color.lerp(const Color(0xFF001155), const Color(0xFF000033), depth / 40) ?? const Color(0xFF001155),
          ],
        );
        break;
      case BiomeType.abyssalZone:
        gradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF191970), // Midnight blue
            const Color(0xFF0D1B2A), // Very dark blue
            Color.lerp(const Color(0xFF000000), const Color(0xFF1A0033), depth / 50) ?? const Color(0xFF000000),
          ],
        );
        break;
    }
    
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  static void _paintDynamicLighting(Canvas canvas, Size size, BiomeType biome,
      double depth, double animationValue) {
    
    switch (biome) {
      case BiomeType.shallowWaters:
        _paintSurfaceLighting(canvas, size, depth, animationValue);
        break;
      case BiomeType.coralGarden:
        _paintFilteredLighting(canvas, size, depth, animationValue);
        break;
      case BiomeType.deepOcean:
        _paintArtificialLighting(canvas, size, depth, animationValue);
        break;
      case BiomeType.abyssalZone:
        _paintBioluminescentLighting(canvas, size, depth, animationValue);
        break;
    }
  }

  static void _paintSurfaceLighting(Canvas canvas, Size size, double depth, double animationValue) {
    // Rippling caustics patterns from surface light
    final causticsIntensity = max(0.0, 1.0 - depth / 15);
    
    if (causticsIntensity > 0) {
      for (int i = 0; i < 8; i++) {
        // animationValue is now continuous time in seconds
        final causticsPath = Path();
        
        // Create gentle flowing motion like real ocean currents
        final baseFlow = _getLinearFlow(animationValue, 1.5); // 1.5 pixels per second horizontal drift
        final baseX = (i * size.width / 8) + (baseFlow % (size.width / 8));
        final waveOffset = _getOscillation(animationValue, 0.15) * 20; // Much slower wave motion
        
        final startX = baseX + waveOffset;
        final startY = size.height * 0.2;
        final endY = size.height * 0.8;
        
        causticsPath.moveTo(startX, startY);
        causticsPath.quadraticBezierTo(
          startX + _getOscillation(animationValue, 0.08) * 30, // Slower caustic undulation
          (startY + endY) / 2,
          startX + _getOscillation(animationValue, 0.12) * 15,
          endY,
        );
        
        final causticsGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: causticsIntensity * 0.3),
            Colors.white.withValues(alpha: causticsIntensity * 0.1),
            Colors.transparent,
          ],
        );
        
        final paint = Paint()
          ..shader = causticsGradient.createShader(Rect.fromLTWH(startX - 20, startY, 40, endY - startY))
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;
        
        canvas.drawPath(causticsPath, paint);
      }
    }
  }

  static void _paintFilteredLighting(Canvas canvas, Size size, double depth, double animationValue) {
    // Blue-green filtered light with dancing shadows
    final filterIntensity = max(0.0, 1.0 - depth / 25);
    
    if (filterIntensity > 0) {
      // Create dancing light patterns
      for (int i = 0; i < 5; i++) {
        final lightBeam = Path();
        // Add gentle underwater light movement
        final baseFlow = _getLinearFlow(animationValue, 0.8); // 0.8 pixels per second drift
        final baseX = size.width * (i / 5) + (baseFlow % (size.width / 5));
        final beamX = baseX + _getOscillation(animationValue, 0.1) * 40; // Slower light dancing
        
        lightBeam.moveTo(beamX, 0);
        lightBeam.lineTo(beamX + _getOscillation(animationValue, 0.07) * 50, size.height * 0.3);
        lightBeam.lineTo(beamX - _getOscillation(animationValue, 0.05) * 30, size.height * 0.6);
        lightBeam.lineTo(beamX + _getOscillation(animationValue, 0.09) * 20, size.height);
        
        final beamGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF40E0D0).withValues(alpha: filterIntensity * 0.2),
            const Color(0xFF20B2AA).withValues(alpha: filterIntensity * 0.1),
            Colors.transparent,
          ],
        );
        
        final paint = Paint()
          ..shader = beamGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..strokeWidth = 20
          ..style = PaintingStyle.stroke;
        
        canvas.drawPath(lightBeam, paint);
      }
    }
  }

  static void _paintArtificialLighting(Canvas canvas, Size size, double depth, double animationValue) {
    // Focused beam lighting for deep water exploration
    final lightIntensity = 0.8 + sin(_getOscillation(animationValue, 0.3)) * 0.2; // Gentle flickering
    
    // Main diving light beam
    final centerX = size.width / 2;
    final beamTop = size.height * 0.1;
    final beamBottom = size.height * 0.9;
    
    final beamGradient = RadialGradient(
      center: Alignment.topCenter,
      radius: 0.8,
      colors: [
        Colors.white.withValues(alpha: lightIntensity * 0.4),
        Colors.white.withValues(alpha: lightIntensity * 0.2),
        Colors.white.withValues(alpha: lightIntensity * 0.05),
        Colors.transparent,
      ],
    );
    
    final beamRect = Rect.fromLTWH(centerX - 100, beamTop, 200, beamBottom - beamTop);
    final paint = Paint()..shader = beamGradient.createShader(beamRect);
    canvas.drawRect(beamRect, paint);
    
    // Additional scattered light sources
    for (int i = 0; i < 3; i++) {
      final lightX = size.width * (0.2 + i * 0.3) + sin(_getOscillation(animationValue, 0.2) + i) * 30;
      final lightY = size.height * (0.3 + i * 0.2);
      
      final spotGradient = RadialGradient(
        colors: [
          Colors.yellow.withValues(alpha: lightIntensity * 0.3),
          Colors.yellow.withValues(alpha: lightIntensity * 0.1),
          Colors.transparent,
        ],
      );
      
      final spotRect = Rect.fromCenter(
        center: Offset(lightX, lightY),
        width: 80,
        height: 80,
      );
      
      final spotPaint = Paint()..shader = spotGradient.createShader(spotRect);
      canvas.drawRect(spotRect, spotPaint);
    }
  }

  static void _paintBioluminescentLighting(Canvas canvas, Size size, double depth, double animationValue) {
    // Mysterious bioluminescent effects
    final bioIntensity = (sin(_getOscillation(animationValue, 0.15)) + 1) / 2; // Very slow pulsing
    
    // Floating bioluminescent orbs
    for (int i = 0; i < 12; i++) {
      final orbX = size.width * (i / 12) + sin(_getOscillation(animationValue, 0.08) + i * 0.5) * 80; // Slow floating
      final orbY = size.height * (0.2 + (i % 3) * 0.3) + cos(_getOscillation(animationValue, 0.06) + i) * 60;
      
      final orbSize = 8 + sin(_getOscillation(animationValue, 0.25) + i) * 4; // Slow size pulsing
      final orbAlpha = bioIntensity * (0.6 + sin(_getOscillation(animationValue, 0.2) + i) * 0.4);
      
      final orbGradient = RadialGradient(
        colors: [
          Color.fromARGB(255, 0, 255, 255).withValues(alpha: orbAlpha),
          Color.fromARGB(255, 0, 200, 255).withValues(alpha: orbAlpha * 0.6),
          Colors.transparent,
        ],
      );
      
      final orbRect = Rect.fromCenter(
        center: Offset(orbX, orbY),
        width: orbSize * 6,
        height: orbSize * 6,
      );
      
      final paint = Paint()..shader = orbGradient.createShader(orbRect);
      canvas.drawCircle(Offset(orbX, orbY), orbSize, paint);
    }
    
    // Mysterious energy wisps
    for (int i = 0; i < 6; i++) {
      final wispPath = Path();
      final startX = size.width * (i / 6);
      final startY = size.height * 0.8;
      
      wispPath.moveTo(startX, startY);
      
      for (double t = 0; t <= 1; t += 0.1) {
        final x = startX + sin(_getOscillation(animationValue, 0.2) + i + t * 4) * 100 * t;
        final y = startY - (size.height * 0.6 * t) + cos(_getOscillation(animationValue, 0.12) + i + t * 3) * 40;
        wispPath.lineTo(x, y);
      }
      
      final wispPaint = Paint()
        ..color = Color.fromARGB(255, 147, 0, 211).withValues(alpha: bioIntensity * 0.4)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      canvas.drawPath(wispPath, wispPaint);
    }
  }

  static void _paintBiomeFeatures(Canvas canvas, Size size, BiomeType biome,
      double depth, double sessionProgress, double animationValue) {
    
    switch (biome) {
      case BiomeType.shallowWaters:
        _paintShallowFeatures(canvas, size, depth, sessionProgress, animationValue);
        break;
      case BiomeType.coralGarden:
        _paintCoralFeatures(canvas, size, depth, sessionProgress, animationValue);
        break;
      case BiomeType.deepOcean:
        _paintDeepFeatures(canvas, size, depth, sessionProgress, animationValue);
        break;
      case BiomeType.abyssalZone:
        _paintAbyssalFeatures(canvas, size, depth, sessionProgress, animationValue);
        break;
    }
  }

  static void _paintShallowFeatures(Canvas canvas, Size size, double depth,
      double sessionProgress, double animationValue) {
    
    // Sandy bottom with ripples
    final sandGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        const Color(0xFFF5DEB3).withValues(alpha: 0.3),
        const Color(0xFFD2B48C).withValues(alpha: 0.6),
      ],
    );
    
    final sandRect = Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3);
    final sandPaint = Paint()..shader = sandGradient.createShader(sandRect);
    canvas.drawRect(sandRect, sandPaint);
    
    // Sand ripples
    for (int i = 0; i < 8; i++) {
      final ripplePath = Path();
      final y = size.height * 0.8 + i * 20;
      final waveOffset = sin(_getOscillation(animationValue, 0.2) + i * 0.3) * 5;
      
      ripplePath.moveTo(0, y + waveOffset);
      for (double x = 0; x <= size.width; x += 20) {
        final rippleY = y + sin(x / 30 + _getOscillation(animationValue, 0.2) + i) * 3 + waveOffset;
        ripplePath.lineTo(x, rippleY);
      }
      
      final ripplePaint = Paint()
        ..color = Colors.brown.withValues(alpha: 0.2)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      
      canvas.drawPath(ripplePath, ripplePaint);
    }
    
    // Small coral polyps growing
    _paintGrowingPolyps(canvas, size, sessionProgress, animationValue);
  }

  static void _paintCoralFeatures(Canvas canvas, Size size, double depth,
      double sessionProgress, double animationValue) {
    
    // Branching coral structures
    _paintBranchingCoral(canvas, size, sessionProgress, animationValue);
    
    // Sea anemones swaying
    _paintSwayingAnemones(canvas, size, animationValue);
    
    // Coral garden floor
    final gardenGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        const Color(0xFFFF7F7F).withValues(alpha: 0.2),
        const Color(0xFFFF8C00).withValues(alpha: 0.3),
      ],
    );
    
    final gardenRect = Rect.fromLTWH(0, size.height * 0.8, size.width, size.height * 0.2);
    final gardenPaint = Paint()..shader = gardenGradient.createShader(gardenRect);
    canvas.drawRect(gardenRect, gardenPaint);
  }

  static void _paintDeepFeatures(Canvas canvas, Size size, double depth,
      double sessionProgress, double animationValue) {
    
    // Massive coral formations
    _paintMassiveCorals(canvas, size, sessionProgress, animationValue);
    
    // Deep water vegetation
    _paintDeepVegetation(canvas, size, animationValue);
    
    // Rocky outcrops
    _paintRockyOutcrops(canvas, size, animationValue);
  }

  static void _paintAbyssalFeatures(Canvas canvas, Size size, double depth,
      double sessionProgress, double animationValue) {
    
    // Ancient coral cities
    _paintAncientCorals(canvas, size, sessionProgress, animationValue);
    
    // Mysterious structures
    _paintMysteriousStructures(canvas, size, animationValue);
    
    // Abyssal plain
    final abyssalGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        const Color(0xFF1A0033).withValues(alpha: 0.4),
        const Color(0xFF2D1B4E).withValues(alpha: 0.7),
      ],
    );
    
    final abyssalRect = Rect.fromLTWH(0, size.height * 0.85, size.width, size.height * 0.15);
    final abyssalPaint = Paint()..shader = abyssalGradient.createShader(abyssalRect);
    canvas.drawRect(abyssalRect, abyssalPaint);
  }

  static void _paintParticleSystems(Canvas canvas, Size size, BiomeType biome,
      double depth, double animationValue) {
    
    switch (biome) {
      case BiomeType.shallowWaters:
        _paintPlanktonParticles(canvas, size, animationValue);
        break;
      case BiomeType.coralGarden:
        _paintMarineSnow(canvas, size, animationValue);
        break;
      case BiomeType.deepOcean:
        _paintDeepParticles(canvas, size, animationValue);
        break;
      case BiomeType.abyssalZone:
        _paintBioluminescentParticles(canvas, size, animationValue);
        break;
    }
  }

  static void _paintPlanktonParticles(Canvas canvas, Size size, double animationValue) {
    final planktonPaint = Paint()..color = Colors.white.withValues(alpha: 0.6);
    
    for (int i = 0; i < 30; i++) {
      final x = (size.width / 30 * i + sin(_getOscillation(animationValue, 0.15) + i) * 50) % size.width;
      final y = (size.height / 20 * (i % 20) + cos(_getOscillation(animationValue, 0.12) + i) * 30) % size.height;
      final particleSize = 1 + sin(_getOscillation(animationValue, 0.25) + i) * 0.5;
      
      canvas.drawCircle(Offset(x, y), particleSize, planktonPaint);
    }
  }

  static void _paintMarineSnow(Canvas canvas, Size size, double animationValue) {
    final snowPaint = Paint()..color = Colors.white.withValues(alpha: 0.4);
    
    for (int i = 0; i < 40; i++) {
      // Create truly continuous falling motion
      final baseX = size.width * (i / 40);
      final driftX = sin(_getOscillation(animationValue, 0.08) + i) * 20;
      final x = (baseX + driftX + size.width) % size.width;
      
      // Slow gentle falling motion like real marine snow
      final fallSpeed = _getLinearFlow(animationValue, 15); // 15 pixels per second - much slower
      final startY = (i * size.height / 40) - size.height; // Start above screen
      final y = (startY + fallSpeed) % (size.height + 100); // Buffer zone for smooth loop
      final particleSize = 0.8 + sin(_getOscillation(animationValue, 0.2) + i) * 0.3;
      
      canvas.drawCircle(Offset(x, y), particleSize, snowPaint);
    }
  }

  static void _paintDeepParticles(Canvas canvas, Size size, double animationValue) {
    final particlePaint = Paint()..color = Colors.blue.withValues(alpha: 0.3);
    
    for (int i = 0; i < 25; i++) {
      final x = (size.width / 25 * i + sin(_getOscillation(animationValue, 0.12) + i) * 60) % size.width;
      final y = (size.height / 15 * (i % 15) + cos(_getOscillation(animationValue, 0.5) + i) * 40) % size.height;
      final particleSize = 1.2 + sin(_getOscillation(animationValue, 0.25) + i) * 0.6;
      
      canvas.drawCircle(Offset(x, y), particleSize, particlePaint);
    }
  }

  static void _paintBioluminescentParticles(Canvas canvas, Size size, double animationValue) {
    for (int i = 0; i < 20; i++) {
      final x = (size.width / 20 * i + sin(_getOscillation(animationValue, 0.4) + i) * 80) % size.width;
      final y = (size.height / 12 * (i % 12) + cos(_getOscillation(animationValue, 0.3) + i) * 50) % size.height;
      final intensity = (sin(_getOscillation(animationValue, 0.3) + i) + 1) / 2;
      final particleSize = 1.5 + intensity * 1.5;
      
      final glowPaint = Paint()
        ..color = Color.fromARGB(255, 0, 255, 255).withValues(alpha: intensity * 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      canvas.drawCircle(Offset(x, y), particleSize, glowPaint);
    }
  }

  static void _paintDepthTransitionEffects(Canvas canvas, Size size, double depth, double animationValue) {
    // Pressure wave effects at depth transitions
    if (depth % 10 < 1 && depth > 5) {
      final waveIntensity = 1 - (depth % 10);
      
      for (int i = 0; i < 3; i++) {
        final waveY = size.height * (0.3 + i * 0.2) + sin(_getOscillation(animationValue, 0.2) + i) * 20;
        
        final wavePaint = Paint()
          ..color = Colors.white.withValues(alpha: waveIntensity * 0.2)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        
        canvas.drawLine(
          Offset(0, waveY),
          Offset(size.width, waveY),
          wavePaint,
        );
      }
    }
  }

  // Helper methods for coral and vegetation
  static void _paintGrowingPolyps(Canvas canvas, Size size, double progress, double animationValue) {
    final polypPaint = Paint()..color = Colors.pink.withValues(alpha: 0.6);
    final growthFactor = progress * 2; // Grows during session
    
    for (int i = 0; i < 15; i++) {
      final x = size.width * (i / 15) + sin(_getOscillation(animationValue, 0.2) + i) * 10;
      final y = size.height * 0.9 - growthFactor * 20;
      final polypSize = growthFactor * (3 + sin(_getOscillation(animationValue, 0.2) + i) * 1);
      
      if (polypSize > 0) {
        canvas.drawCircle(Offset(x, y), polypSize, polypPaint);
      }
    }
  }

  static void _paintBranchingCoral(Canvas canvas, Size size, double progress, double animationValue) {
    final coralPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final growthFactor = progress * 1.5;
    
    for (int i = 0; i < 8; i++) {
      final baseX = size.width * (i / 8) + sin(_getOscillation(animationValue, 0.25) + i) * 15;
      final baseY = size.height * 0.85;
      
      final branchPath = Path();
      branchPath.moveTo(baseX, baseY);
      
      for (int j = 1; j <= 5; j++) {
        final branchX = baseX + sin(_getOscillation(animationValue, 0.15) + i + j) * (j * 8 * growthFactor);
        final branchY = baseY - (j * 15 * growthFactor);
        
        if (growthFactor > j * 0.2) {
          branchPath.lineTo(branchX, branchY);
        }
      }
      
      canvas.drawPath(branchPath, coralPaint);
    }
  }

  static void _paintSwayingAnemones(Canvas canvas, Size size, double animationValue) {
    final anemonePaint = Paint()
      ..color = Colors.purple.withValues(alpha: 0.6)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < 6; i++) {
      final baseX = size.width * (0.1 + i * 0.15);
      final baseY = size.height * 0.88;
      final swayAmount = sin(_getOscillation(animationValue, 0.2) + i * 0.5) * 20;
      
      final anemonePath = Path();
      anemonePath.moveTo(baseX, baseY);
      anemonePath.quadraticBezierTo(
        baseX + swayAmount,
        baseY - 30,
        baseX + swayAmount * 0.7,
        baseY - 50,
      );
      
      canvas.drawPath(anemonePath, anemonePaint);
      
      // Tentacles
      for (int j = 0; j < 8; j++) {
        final tentacleAngle = (j / 8) * 2 * pi;
        final tentacleLength = 15 + sin(_getOscillation(animationValue, 0.3) + i + j) * 5;
        final tentacleEndX = baseX + swayAmount * 0.7 + cos(tentacleAngle) * tentacleLength;
        final tentacleEndY = baseY - 50 + sin(tentacleAngle) * tentacleLength;
        
        canvas.drawLine(
          Offset(baseX + swayAmount * 0.7, baseY - 50),
          Offset(tentacleEndX, tentacleEndY),
          anemonePaint,
        );
      }
    }
  }

  static void _paintMassiveCorals(Canvas canvas, Size size, double progress, double animationValue) {
    final massivePaint = Paint()..color = Colors.red.withValues(alpha: 0.5);
    final growthFactor = progress * 3;
    
    for (int i = 0; i < 4; i++) {
      final centerX = size.width * (0.2 + i * 0.2);
      final centerY = size.height * 0.8;
      final coralSize = growthFactor * (60 + sin(_getOscillation(animationValue, 0.2) + i) * 10);
      
      if (coralSize > 10) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(centerX, centerY),
            width: coralSize,
            height: coralSize * 0.7,
          ),
          massivePaint,
        );
      }
    }
  }

  static void _paintDeepVegetation(Canvas canvas, Size size, double animationValue) {
    final vegPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < 12; i++) {
      final baseX = size.width * (i / 12);
      final baseY = size.height * 0.9;
      final swayAmount = sin(_getOscillation(animationValue, 0.15) + i) * 30;
      
      final vegPath = Path();
      vegPath.moveTo(baseX, baseY);
      
      for (int j = 1; j <= 6; j++) {
        final segmentX = baseX + swayAmount * (j / 6);
        final segmentY = baseY - (j * 20);
        vegPath.lineTo(segmentX, segmentY);
      }
      
      canvas.drawPath(vegPath, vegPaint);
    }
  }

  static void _paintRockyOutcrops(Canvas canvas, Size size, double animationValue) {
    final rockPaint = Paint()..color = Colors.grey.withValues(alpha: 0.6);
    
    for (int i = 0; i < 5; i++) {
      final rockX = size.width * (0.1 + i * 0.2);
      final rockY = size.height * 0.85;
      final rockWidth = 40 + sin(_getOscillation(animationValue, 0.1) + i) * 10;
      final rockHeight = 60 + cos(_getOscillation(animationValue, 0.15) + i) * 15;
      
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(rockX, rockY),
          width: rockWidth,
          height: rockHeight,
        ),
        rockPaint,
      );
    }
  }

  static void _paintAncientCorals(Canvas canvas, Size size, double progress, double animationValue) {
    final ancientPaint = Paint()..color = Colors.deepPurple.withValues(alpha: 0.4);
    final mysticalGlow = (sin(_getOscillation(animationValue, 0.2)) + 1) / 2;
    
    for (int i = 0; i < 3; i++) {
      final centerX = size.width * (0.25 + i * 0.25);
      final centerY = size.height * 0.8;
      final ancientSize = progress * (100 + mysticalGlow * 20);
      
      if (ancientSize > 20) {
        final glowPaint = Paint()
          ..color = Colors.purple.withValues(alpha: mysticalGlow * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        
        canvas.drawCircle(Offset(centerX, centerY), ancientSize * 1.5, glowPaint);
        canvas.drawCircle(Offset(centerX, centerY), ancientSize, ancientPaint);
      }
    }
  }

  static void _paintMysteriousStructures(Canvas canvas, Size size, double animationValue) {
    final structurePaint = Paint()
      ..color = Colors.indigo.withValues(alpha: 0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final mysteryIntensity = (sin(_getOscillation(animationValue, 0.12)) + 1) / 2;
    
    for (int i = 0; i < 4; i++) {
      final structureX = size.width * (0.2 + i * 0.2);
      final structureY = size.height * 0.85;
      
      final structurePath = Path();
      structurePath.moveTo(structureX - 20, structureY);
      structurePath.lineTo(structureX, structureY - 80 * mysteryIntensity);
      structurePath.lineTo(structureX + 20, structureY);
      
      // Add mysterious energy
      final energyPaint = Paint()
        ..color = Colors.cyan.withValues(alpha: mysteryIntensity * 0.6)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      
      for (int j = 0; j < 3; j++) {
        final energyY = structureY - (j * 25);
        final energyRadius = 5 + mysteryIntensity * 10;
        
        canvas.drawCircle(Offset(structureX, energyY), energyRadius, energyPaint);
      }
      
      canvas.drawPath(structurePath, structurePaint);
    }
  }
}