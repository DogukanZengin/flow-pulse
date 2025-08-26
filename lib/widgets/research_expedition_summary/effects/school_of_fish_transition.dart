import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/animation_constants.dart';

/// School of fish transition effect for session completion
class SchoolOfFishTransition extends StatefulWidget {
  final AnimationController controller;
  final Color fishColor;
  final VoidCallback? onComplete;

  const SchoolOfFishTransition({
    super.key,
    required this.controller,
    this.fishColor = Colors.cyan,
    this.onComplete,
  });

  @override
  State<SchoolOfFishTransition> createState() => _SchoolOfFishTransitionState();
}

class _SchoolOfFishTransitionState extends State<SchoolOfFishTransition>
    with SingleTickerProviderStateMixin {
  final List<Fish> _fishes = [];
  late AnimationController _swimController;
  
  // Pre-computed fish templates for instanced rendering
  Path? _fishBodyTemplate;
  Path? _fishTailTemplate;
  bool _templatesInitialized = false;
  
  @override
  void initState() {
    super.initState();
    
    _swimController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _initializeFishSchool();
    
    widget.controller.forward().then((_) {
      widget.onComplete?.call();
    });
    
    _swimController.repeat();
  }
  
  void _initializeFishSchool() {
    final random = math.Random();
    final fishCount = AnimationConstants.fishSchoolCount;
    
    for (int i = 0; i < fishCount; i++) {
      _fishes.add(Fish(
        id: i,
        startOffset: Offset(
          -100 - random.nextDouble() * 200,
          random.nextDouble() * 600,
        ),
        size: 10 + random.nextDouble() * 20,
        speed: 200 + random.nextDouble() * 300,
        verticalWave: random.nextDouble() * 30,
        phase: random.nextDouble() * math.pi * 2,
      ));
    }
    
    _initializeFishTemplates();
  }
  
  void _initializeFishTemplates() {
    if (_templatesInitialized) return;
    
    // Create reusable fish body template (normalized size)
    _fishBodyTemplate = Path()
      ..addOval(const Rect.fromLTWH(-0.5, -0.2, 1.0, 0.4));
    
    // Create reusable fish tail template  
    _fishTailTemplate = Path()
      ..moveTo(-0.5, 0)
      ..lineTo(-0.8, -0.2)
      ..lineTo(-0.8, 0.2)
      ..close();
    
    _templatesInitialized = true;
  }
  
  @override
  void dispose() {
    _swimController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return AnimatedBuilder(
      animation: Listenable.merge([widget.controller, _swimController]),
      builder: (context, child) {
        return CustomPaint(
          size: size,
          painter: _SchoolOfFishPainter(
            fishes: _fishes,
            progress: widget.controller.value,
            swimAnimation: _swimController.value,
            fishColor: widget.fishColor,
            screenSize: size,
            fishBodyTemplate: _fishBodyTemplate,
            fishTailTemplate: _fishTailTemplate,
          ),
        );
      },
    );
  }
}

/// Individual fish data
class Fish {
  final int id;
  final Offset startOffset;
  final double size;
  final double speed;
  final double verticalWave;
  final double phase;

  Fish({
    required this.id,
    required this.startOffset,
    required this.size,
    required this.speed,
    required this.verticalWave,
    required this.phase,
  });
}

/// Painter for school of fish
class _SchoolOfFishPainter extends CustomPainter {
  final List<Fish> fishes;
  final double progress;
  final double swimAnimation;
  final Color fishColor;
  final Size screenSize;
  final Path? fishBodyTemplate;
  final Path? fishTailTemplate;

  _SchoolOfFishPainter({
    required this.fishes,
    required this.progress,
    required this.swimAnimation,
    required this.fishColor,
    required this.screenSize,
    this.fishBodyTemplate,
    this.fishTailTemplate,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final fish in fishes) {
      _drawFish(canvas, fish, size);
    }
  }
  
  void _drawFish(Canvas canvas, Fish fish, Size size) {
    // Calculate fish position
    final x = fish.startOffset.dx + (progress * (size.width + 300));
    final waveY = math.sin(swimAnimation * math.pi * 2 + fish.phase) * fish.verticalWave;
    final y = fish.startOffset.dy + waveY;
    
    // Early exit optimizations
    if (x < -50 || x > size.width + 50) return;
    if (fishBodyTemplate == null || fishTailTemplate == null) return;
    
    final position = Offset(x, y);
    
    // Fish body paint
    final paint = Paint()
      ..color = fishColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    
    // Setup transform once
    canvas.save();
    canvas.translate(position.dx, position.dy);
    
    // Rotate fish slightly based on swimming (cached calculation)
    final rotation = math.sin(swimAnimation * math.pi * 4 + fish.phase) * 0.1;
    canvas.rotate(rotation);
    canvas.scale(fish.size, fish.size);
    
    // Draw using pre-computed templates
    canvas.drawPath(fishBodyTemplate!, paint);
    
    // Fish tail with different opacity
    paint.color = fishColor.withValues(alpha: 0.6);
    canvas.drawPath(fishTailTemplate!, paint);
    
    // Simplified eye drawing (combine into single draw operation)
    canvas.scale(1.0 / fish.size, 1.0 / fish.size); // Reset scale for eyes
    
    // White eye background
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(fish.size * 0.3, -fish.size * 0.05),
      fish.size * 0.06,
      paint,
    );
    
    // Black pupil
    paint.color = Colors.black;
    canvas.drawCircle(
      Offset(fish.size * 0.32, -fish.size * 0.05),
      fish.size * 0.03,
      paint,
    );
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SchoolOfFishPainter oldDelegate) {
    return progress != oldDelegate.progress || 
           swimAnimation != oldDelegate.swimAnimation;
  }
}