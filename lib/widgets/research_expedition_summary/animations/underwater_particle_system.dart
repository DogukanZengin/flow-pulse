import 'package:flutter/material.dart';
import '../models/celebration_config.dart';

/// Manages underwater particle effects and environmental ambience
class UnderwaterParticleSystem extends StatefulWidget {
  final AnimationController controller;
  final CelebrationConfig celebrationConfig;
  final CelebrationPhase? currentPhase;

  const UnderwaterParticleSystem({
    super.key,
    required this.controller,
    required this.celebrationConfig,
    this.currentPhase,
  });

  @override
  State<UnderwaterParticleSystem> createState() => _UnderwaterParticleSystemState();
}

class _UnderwaterParticleSystemState extends State<UnderwaterParticleSystem> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _ParticleSystemPainter(
            progress: widget.controller.value,
            celebrationConfig: widget.celebrationConfig,
            currentPhase: widget.currentPhase,
          ),
        );
      },
    );
  }
}

class _ParticleSystemPainter extends CustomPainter {
  final double progress;
  final CelebrationConfig celebrationConfig;
  final CelebrationPhase? currentPhase;

  _ParticleSystemPainter({
    required this.progress,
    required this.celebrationConfig,
    this.currentPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // For now, draw basic particle effects
    // This will be enhanced with full particle systems later
    _drawAmbientParticles(canvas, size);
    
    if (currentPhase != null) {
      _drawPhaseSpecificEffects(canvas, size, currentPhase!);
    }
  }

  void _drawAmbientParticles(Canvas canvas, Size size) {
    final paint = Paint()..blendMode = BlendMode.screen;
    
    // Draw floating marine particles
    for (int i = 0; i < 20; i++) {
      final t = (progress + (i / 20)) % 1.0;
      final x = (i * 37.0) % size.width;
      final y = size.height * 0.2 + (size.height * 0.6 * t);
      
      paint.color = Colors.cyan.withValues(alpha: 0.3 * (1.0 - t));
      canvas.drawCircle(Offset(x, y), 2.0, paint);
    }
  }

  void _drawPhaseSpecificEffects(Canvas canvas, Size size, CelebrationPhase phase) {
    // Phase-specific particle effects will be implemented here
    // For now, just basic effects
  }

  @override
  bool shouldRepaint(covariant _ParticleSystemPainter oldDelegate) {
    return progress != oldDelegate.progress ||
           currentPhase != oldDelegate.currentPhase;
  }
}