import 'package:flutter/material.dart';
import '../models/celebration_config.dart';
import '../models/expedition_result.dart';

/// Underwater background component with biome-specific gradients and depth effects
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

class _UnderwaterBackgroundState extends State<UnderwaterBackground> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.depthProgress,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: _buildDepthAwareGradient(),
          ),
          child: _buildCausticOverlay(),
        );
      },
    );
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

/// Painter for underwater caustic light effects
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
    if (intensity < 0.1) return;
    
    final paint = Paint()
      ..blendMode = BlendMode.overlay
      ..color = lightColor.withValues(alpha: 0.1 * intensity);

    // Draw caustic pattern
    for (int i = 0; i < 10; i++) {
      final offset = Offset(
        (i * size.width / 10) + (progress * 50),
        size.height * 0.2 + (i * 20),
      );
      
      canvas.drawCircle(offset, 20 + (progress * 10), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CausticOverlayPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}