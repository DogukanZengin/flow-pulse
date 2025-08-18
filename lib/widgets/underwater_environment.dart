import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/aquarium.dart';
import '../models/creature.dart';

class UnderwaterEnvironment extends StatefulWidget {
  final bool isStudySession;
  final bool isEnabled;
  final Aquarium? aquarium;
  final List<Creature>? visibleCreatures;
  
  const UnderwaterEnvironment({
    super.key,
    required this.isStudySession,
    this.isEnabled = true,
    this.aquarium,
    this.visibleCreatures,
  });

  @override
  State<UnderwaterEnvironment> createState() => _UnderwaterEnvironmentState();
}

class _UnderwaterEnvironmentState extends State<UnderwaterEnvironment>
    with TickerProviderStateMixin {
  
  // Animation controllers for different elements
  late AnimationController _waveController;
  late AnimationController _lightRayController;
  late AnimationController _particleController;
  late AnimationController _kelp1Controller;
  late AnimationController _kelp2Controller;
  late AnimationController _kelp3Controller;
  
  // Animations
  late Animation<double> _waveAnimation;
  late Animation<double> _lightRayAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _kelp1Animation;
  late Animation<double> _kelp2Animation;
  late Animation<double> _kelp3Animation;
  
  // Time of day for dynamic lighting
  double _timeOfDay = 0.5; // 0.0 = dawn, 0.5 = noon, 1.0 = dusk
  
  @override
  void initState() {
    super.initState();
    
    // Wave animation for water surface
    _waveController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    ));
    
    // Light ray animation
    _lightRayController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);
    
    _lightRayAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _lightRayController,
      curve: Curves.easeInOut,
    ));
    
    // Particle animation for floating plankton
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _particleAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));
    
    // Kelp swaying animations
    _kelp1Controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
    
    _kelp1Animation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _kelp1Controller,
      curve: Curves.easeInOut,
    ));
    
    _kelp2Controller = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    )..repeat(reverse: true);
    
    _kelp2Animation = Tween<double>(
      begin: -0.04,
      end: 0.04,
    ).animate(CurvedAnimation(
      parent: _kelp2Controller,
      curve: Curves.easeInOut,
    ));
    
    _kelp3Controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
    
    _kelp3Animation = Tween<double>(
      begin: -0.06,
      end: 0.06,
    ).animate(CurvedAnimation(
      parent: _kelp3Controller,
      curve: Curves.easeInOut,
    ));
    
    // Update time of day based on actual time
    _updateTimeOfDay();
  }
  
  void _updateTimeOfDay() {
    final now = DateTime.now();
    final hour = now.hour;
    
    // Map 24 hours to 0.0 - 1.0
    // 6am = 0.0 (dawn), 12pm = 0.5 (noon), 6pm = 1.0 (dusk)
    if (hour >= 6 && hour < 18) {
      _timeOfDay = (hour - 6) / 12.0;
    } else if (hour >= 18) {
      _timeOfDay = 1.0 - ((hour - 18) / 12.0) * 0.3; // Evening gets darker
    } else {
      _timeOfDay = 0.0 + (hour / 6.0) * 0.2; // Early morning is darker
    }
  }
  
  @override
  void dispose() {
    _waveController.dispose();
    _lightRayController.dispose();
    _particleController.dispose();
    _kelp1Controller.dispose();
    _kelp2Controller.dispose();
    _kelp3Controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) {
      return const SizedBox.shrink();
    }
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _waveAnimation,
        _lightRayAnimation,
        _particleAnimation,
        _kelp1Animation,
        _kelp2Animation,
        _kelp3Animation,
      ]),
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: UnderwaterPainter(
            waveValue: _waveAnimation.value,
            lightRayValue: _lightRayAnimation.value,
            particleValue: _particleAnimation.value,
            kelp1Value: _kelp1Animation.value,
            kelp2Value: _kelp2Animation.value,
            kelp3Value: _kelp3Animation.value,
            isStudySession: widget.isStudySession,
            biome: widget.aquarium?.currentBiome ?? BiomeType.shallowWaters,
            timeOfDay: _timeOfDay,
            visibleCreatures: widget.visibleCreatures,
          ),
        );
      },
    );
  }
}

class UnderwaterPainter extends CustomPainter {
  final double waveValue;
  final double lightRayValue;
  final double particleValue;
  final double kelp1Value;
  final double kelp2Value;
  final double kelp3Value;
  final bool isStudySession;
  final BiomeType biome;
  final double timeOfDay;
  final List<Creature>? visibleCreatures;
  
  UnderwaterPainter({
    required this.waveValue,
    required this.lightRayValue,
    required this.particleValue,
    required this.kelp1Value,
    required this.kelp2Value,
    required this.kelp3Value,
    required this.isStudySession,
    required this.biome,
    required this.timeOfDay,
    this.visibleCreatures,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw background gradient based on biome and time of day
    _drawOceanGradient(canvas, size);
    
    // Draw far background layer (Layer 3) - Slowest parallax
    _drawDistantReef(canvas, size, 0.3);
    
    // Draw light rays
    _drawLightRays(canvas, size);
    
    // Draw middle layer (Layer 2) - Medium parallax
    _drawKelpForest(canvas, size, 0.6);
    
    // Draw floating particles (plankton)
    _drawFloatingParticles(canvas, size);
    
    // Draw foreground layer (Layer 1) - Fastest parallax
    _drawForegroundElements(canvas, size, 1.0);
    
    // Draw water surface caustics
    _drawWaterCaustics(canvas, size);
    
    // Draw swimming background creatures
    _drawBackgroundCreatures(canvas, size);
  }
  
  void _drawOceanGradient(Canvas canvas, Size size) {
    final List<Color> colors;
    final List<double> stops;
    
    // Adjust colors based on biome and time of day
    final brightness = 0.3 + (timeOfDay * 0.7); // Darker at dawn/dusk
    
    switch (biome) {
      case BiomeType.shallowWaters:
        colors = [
          Color.lerp(const Color(0xFF87CEEB), const Color(0xFF5BA3C9), 1 - brightness)!,
          Color.lerp(const Color(0xFF4A90E2), const Color(0xFF2E5D8B), 1 - brightness)!,
          Color.lerp(const Color(0xFF2C5F8D), const Color(0xFF1A3A5A), 1 - brightness)!,
        ];
        stops = [0.0, 0.5, 1.0];
        break;
      case BiomeType.coralGarden:
        colors = [
          Color.lerp(const Color(0xFF40E0D0), const Color(0xFF2BA69A), 1 - brightness)!,
          Color.lerp(const Color(0xFF20B2AA), const Color(0xFF147A73), 1 - brightness)!,
          Color.lerp(const Color(0xFF008B8B), const Color(0xFF005757), 1 - brightness)!,
        ];
        stops = [0.0, 0.6, 1.0];
        break;
      case BiomeType.deepOcean:
        colors = [
          Color.lerp(const Color(0xFF1E3A8A), const Color(0xFF0F1E44), 1 - brightness)!,
          Color.lerp(const Color(0xFF0F2557), const Color(0xFF071229), 1 - brightness)!,
          Color.lerp(const Color(0xFF051224), const Color(0xFF020812), 1 - brightness)!,
        ];
        stops = [0.0, 0.7, 1.0];
        break;
      case BiomeType.abyssalZone:
        colors = [
          const Color(0xFF0A0E27),
          const Color(0xFF03061A),
          const Color(0xFF000000),
        ];
        stops = [0.0, 0.8, 1.0];
        break;
    }
    
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
      stops: stops,
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }
  
  void _drawLightRays(Canvas canvas, Size size) {
    if (biome == BiomeType.abyssalZone) return; // No light in abyss
    
    final rayCount = 5;
    final rayOpacity = biome == BiomeType.deepOcean 
        ? 0.02 * timeOfDay 
        : 0.08 * timeOfDay;
    
    for (int i = 0; i < rayCount; i++) {
      final xOffset = (i - rayCount / 2) * size.width / rayCount;
      final swayOffset = math.sin(lightRayValue * 2 + i) * 20;
      
      final path = Path();
      path.moveTo(size.width / 2 + xOffset + swayOffset, 0);
      path.lineTo(size.width / 2 + xOffset + swayOffset - 50, size.height);
      path.lineTo(size.width / 2 + xOffset + swayOffset + 50, size.height);
      path.close();
      
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: rayOpacity),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      
      canvas.drawPath(path, paint);
    }
  }
  
  void _drawDistantReef(Canvas canvas, Size size, double parallaxSpeed) {
    final paint = Paint()
      ..color = biome == BiomeType.abyssalZone 
          ? const Color(0xFF0A0A1A)
          : const Color(0xFF1A4A6A).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    // Draw distant rock formations
    for (int i = 0; i < 3; i++) {
      final xPos = size.width * (0.2 + i * 0.3) + math.sin(waveValue * parallaxSpeed) * 10;
      final yPos = size.height * 0.7;
      
      final path = Path();
      path.moveTo(xPos - 60, size.height);
      path.quadraticBezierTo(xPos - 30, yPos, xPos, yPos - 20);
      path.quadraticBezierTo(xPos + 30, yPos, xPos + 60, size.height);
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }
  
  void _drawKelpForest(Canvas canvas, Size size, double parallaxSpeed) {
    if (biome == BiomeType.abyssalZone || biome == BiomeType.deepOcean) return;
    
    final kelpColors = [
      const Color(0xFF2D5016).withValues(alpha: 0.6),
      const Color(0xFF3A6B1E).withValues(alpha: 0.5),
      const Color(0xFF4A7C2E).withValues(alpha: 0.4),
    ];
    
    final swayValues = [kelp1Value, kelp2Value, kelp3Value];
    
    for (int layer = 0; layer < 3; layer++) {
      for (int i = 0; i < 5; i++) {
        final xPos = size.width * (0.1 + i * 0.2 + layer * 0.05);
        final height = size.height * (0.4 + layer * 0.1);
        final sway = swayValues[layer] * size.width * (1 + layer * 0.5);
        
        _drawKelpStrand(
          canvas, 
          Offset(xPos + math.sin(waveValue * parallaxSpeed) * 5, size.height),
          height,
          sway,
          kelpColors[layer],
        );
      }
    }
  }
  
  void _drawKelpStrand(Canvas canvas, Offset base, double height, double sway, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(base.dx - 5, base.dy);
    
    // Draw wavy kelp using bezier curves
    final segments = 5;
    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      final y = base.dy - height * t;
      final x = base.dx + sway * math.sin(t * math.pi) * (1 - t * 0.3);
      final width = 10 * (1 - t * 0.7);
      
      if (i == 1) {
        path.quadraticBezierTo(x - width, y, x, y);
      } else {
        path.lineTo(x - width / 2, y);
      }
    }
    
    // Draw back down the other side
    for (int i = segments; i >= 0; i--) {
      final t = i / segments;
      final y = base.dy - height * t;
      final x = base.dx + sway * math.sin(t * math.pi) * (1 - t * 0.3);
      final width = 10 * (1 - t * 0.7);
      
      path.lineTo(x + width / 2, y);
    }
    
    path.close();
    canvas.drawPath(path, paint);
    
    // Add kelp leaves
    final leafPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    
    for (int i = 1; i <= 4; i++) {
      final t = i / 5;
      final y = base.dy - height * t;
      final x = base.dx + sway * math.sin(t * math.pi) * (1 - t * 0.3);
      
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x + 15, y), width: 20, height: 8),
        leafPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x - 15, y), width: 20, height: 8),
        leafPaint,
      );
    }
  }
  
  void _drawFloatingParticles(Canvas canvas, Size size) {
    final particleCount = biome == BiomeType.abyssalZone ? 30 : 50;
    final particlePaint = Paint()
      ..color = biome == BiomeType.abyssalZone
          ? Colors.cyanAccent.withValues(alpha: 0.3) // Bioluminescent plankton
          : Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < particleCount; i++) {
      final baseX = (i / particleCount) * size.width;
      final baseY = (i * 37 % 100) / 100 * size.height;
      
      final x = baseX + math.sin(particleValue + i * 0.5) * 20;
      final y = baseY + math.cos(particleValue * 0.7 + i * 0.3) * 15;
      
      final particleSize = 1.0 + math.sin(particleValue * 2 + i) * 0.5;
      
      // Draw glow for bioluminescent particles
      if (biome == BiomeType.abyssalZone) {
        final glowPaint = Paint()
          ..color = Colors.cyanAccent.withValues(alpha: 0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawCircle(Offset(x, y), particleSize * 3, glowPaint);
      }
      
      canvas.drawCircle(Offset(x, y), particleSize, particlePaint);
    }
  }
  
  void _drawForegroundElements(Canvas canvas, Size size, double parallaxSpeed) {
    // Draw coral silhouettes in foreground
    final coralPaint = Paint()
      ..color = const Color(0xFF0A2A4A).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    
    // Left coral formation
    final leftPath = Path();
    leftPath.moveTo(0, size.height);
    leftPath.quadraticBezierTo(
      50 + math.sin(waveValue * parallaxSpeed) * 5, 
      size.height - 100, 
      30, 
      size.height - 150,
    );
    leftPath.quadraticBezierTo(
      20, 
      size.height - 180, 
      0, 
      size.height - 200,
    );
    leftPath.lineTo(0, size.height);
    leftPath.close();
    canvas.drawPath(leftPath, coralPaint);
    
    // Right coral formation
    final rightPath = Path();
    rightPath.moveTo(size.width, size.height);
    rightPath.quadraticBezierTo(
      size.width - 50 + math.sin(waveValue * parallaxSpeed) * 5, 
      size.height - 120, 
      size.width - 40, 
      size.height - 170,
    );
    rightPath.quadraticBezierTo(
      size.width - 25, 
      size.height - 190, 
      size.width, 
      size.height - 210,
    );
    rightPath.lineTo(size.width, size.height);
    rightPath.close();
    canvas.drawPath(rightPath, coralPaint);
  }
  
  void _drawWaterCaustics(Canvas canvas, Size size) {
    if (biome == BiomeType.deepOcean || biome == BiomeType.abyssalZone) return;
    
    final causticPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03 * timeOfDay)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 6; j++) {
        final x = size.width * (i / 7) + math.sin(waveValue + i * 0.5) * 15;
        final y = size.height * (j / 5) + math.cos(waveValue + j * 0.7) * 10;
        final radius = 20 + math.sin(waveValue * 2 + i + j) * 10;
        
        canvas.drawCircle(Offset(x, y), radius, causticPaint);
      }
    }
  }
  
  void _drawBackgroundCreatures(Canvas canvas, Size size) {
    if (visibleCreatures == null || visibleCreatures!.isEmpty) return;
    
    // Draw simple fish silhouettes swimming in background
    final fishPaint = Paint()
      ..color = const Color(0xFF1A3A5A).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < math.min(5, visibleCreatures!.length); i++) {
      final x = size.width * (0.1 + i * 0.2) + math.sin(waveValue + i) * 50;
      final y = size.height * (0.3 + (i % 3) * 0.15);
      
      // Simple fish shape
      final path = Path();
      path.moveTo(x, y);
      path.quadraticBezierTo(x + 15, y - 5, x + 30, y);
      path.quadraticBezierTo(x + 35, y - 3, x + 40, y - 5);
      path.lineTo(x + 35, y);
      path.lineTo(x + 40, y + 5);
      path.quadraticBezierTo(x + 35, y + 3, x + 30, y);
      path.quadraticBezierTo(x + 15, y + 5, x, y);
      path.close();
      
      canvas.drawPath(path, fishPaint);
    }
  }
  
  @override
  bool shouldRepaint(UnderwaterPainter oldDelegate) {
    return oldDelegate.waveValue != waveValue ||
           oldDelegate.lightRayValue != lightRayValue ||
           oldDelegate.particleValue != particleValue ||
           oldDelegate.kelp1Value != kelp1Value ||
           oldDelegate.kelp2Value != kelp2Value ||
           oldDelegate.kelp3Value != kelp3Value ||
           oldDelegate.isStudySession != isStudySession ||
           oldDelegate.biome != biome ||
           oldDelegate.timeOfDay != timeOfDay;
  }
}