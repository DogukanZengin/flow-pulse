import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/animation_constants.dart';

/// Jellyfish level-up effect for career advancement celebrations
class JellyfishLevelUpEffect extends StatefulWidget {
  final AnimationController controller;
  final int newLevel;
  final String newTitle;
  final VoidCallback? onComplete;

  const JellyfishLevelUpEffect({
    super.key,
    required this.controller,
    required this.newLevel,
    required this.newTitle,
    this.onComplete,
  });

  @override
  State<JellyfishLevelUpEffect> createState() => _JellyfishLevelUpEffectState();
}

class _JellyfishLevelUpEffectState extends State<JellyfishLevelUpEffect>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  
  late Animation<double> _riseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  final List<Jellyfish> _jellyfishes = [];
  
  @override
  void initState() {
    super.initState();
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _riseAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: widget.controller,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: widget.controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: widget.controller,
      curve: Curves.elasticOut,
    ));
    
    _initializeJellyfishes();
    
    widget.controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }
  
  void _initializeJellyfishes() {
    final random = math.Random();
    
    for (int i = 0; i < AnimationConstants.jellyfishCount; i++) {
      _jellyfishes.add(Jellyfish(
        position: Offset(
          random.nextDouble() * 400,
          600 + random.nextDouble() * 200,
        ),
        size: 30 + random.nextDouble() * 40,
        color: [
          Colors.purpleAccent.withValues(alpha: 0.6),
          Colors.blueAccent.withValues(alpha: 0.6),
          Colors.cyanAccent.withValues(alpha: 0.6),
        ][random.nextInt(3)],
        pulsePhase: random.nextDouble() * math.pi * 2,
        floatSpeed: 0.5 + random.nextDouble() * 0.5,
      ));
    }
  }
  
  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        // Bioluminescent jellyfish background
        AnimatedBuilder(
          animation: Listenable.merge([
            _riseAnimation,
            _floatController,
            _pulseController,
          ]),
          builder: (context, child) {
            return CustomPaint(
              size: size,
              painter: _JellyfishPainter(
                jellyfishes: _jellyfishes,
                riseProgress: _riseAnimation.value,
                floatProgress: _floatController.value,
                pulseProgress: _pulseController.value,
                opacity: _fadeAnimation.value,
              ),
            );
          },
        ),
        
        // Central level-up card
        Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _fadeAnimation,
              _scaleAnimation,
            ]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: _buildLevelUpCard(),
                ),
              );
            },
          ),
        ),
        
        // Sparkle overlay
        AnimatedBuilder(
          animation: _sparkleController,
          builder: (context, child) {
            return CustomPaint(
              size: size,
              painter: _SparkleOverlayPainter(
                sparkleProgress: _sparkleController.value,
                opacity: _fadeAnimation.value,
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildLevelUpCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade400.withValues(alpha: 0.9),
            Colors.blue.shade600.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.cyanAccent,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🎊 CAREER ADVANCEMENT 🎊',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Level display with glow
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'LEVEL',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  '${widget.newLevel}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // New title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.cyanAccent.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Text(
              widget.newTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 15),
          
          // Congratulations message
          Text(
            'Congratulations on your promotion!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Jellyfish data class
class Jellyfish {
  final Offset position;
  final double size;
  final Color color;
  final double pulsePhase;
  final double floatSpeed;

  Jellyfish({
    required this.position,
    required this.size,
    required this.color,
    required this.pulsePhase,
    required this.floatSpeed,
  });
}

/// Painter for jellyfish constellation
class _JellyfishPainter extends CustomPainter {
  final List<Jellyfish> jellyfishes;
  final double riseProgress;
  final double floatProgress;
  final double pulseProgress;
  final double opacity;

  _JellyfishPainter({
    required this.jellyfishes,
    required this.riseProgress,
    required this.floatProgress,
    required this.pulseProgress,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final jellyfish in jellyfishes) {
      _drawJellyfish(canvas, jellyfish, size);
    }
  }
  
  void _drawJellyfish(Canvas canvas, Jellyfish jellyfish, Size size) {
    final x = (jellyfish.position.dx * size.width / 400) + 
              math.sin(floatProgress * math.pi * 2 * jellyfish.floatSpeed) * 20;
    final y = jellyfish.position.dy * riseProgress;
    
    final position = Offset(x, y);
    
    // Pulsing size
    final pulseSize = jellyfish.size * 
                      (1 + 0.2 * math.sin(pulseProgress * math.pi * 2 + jellyfish.pulsePhase));
    
    final paint = Paint();
    
    // Jellyfish bell with gradient
    paint.shader = RadialGradient(
      colors: [
        jellyfish.color.withValues(alpha: jellyfish.color.a * opacity),
        jellyfish.color.withValues(alpha: jellyfish.color.a * opacity * 0.3),
      ],
    ).createShader(Rect.fromCircle(center: position, radius: pulseSize));
    
    // Draw bell
    final bellPath = Path()
      ..addOval(Rect.fromCenter(
        center: position,
        width: pulseSize * 2,
        height: pulseSize * 1.5,
      ));
    
    canvas.drawPath(bellPath, paint);
    
    // Draw tentacles
    paint.shader = null;
    paint.color = jellyfish.color.withValues(alpha: jellyfish.color.a * opacity * 0.5);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    
    for (int i = 0; i < AnimationConstants.tentacleCount; i++) {
      final tentacleX = position.dx + (i - 2.5) * pulseSize / 3;
      final tentacleStartY = position.dy + pulseSize * 0.7;
      
      final path = Path()
        ..moveTo(tentacleX, tentacleStartY);
      
      for (double t = 0; t <= 1; t += 0.1) {
        final waveX = tentacleX + math.sin(t * math.pi * 2 + floatProgress * math.pi * 2) * 5;
        final waveY = tentacleStartY + t * pulseSize * 1.5;
        path.lineTo(waveX, waveY);
      }
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _JellyfishPainter oldDelegate) {
    return riseProgress != oldDelegate.riseProgress ||
           floatProgress != oldDelegate.floatProgress ||
           pulseProgress != oldDelegate.pulseProgress ||
           opacity != oldDelegate.opacity;
  }
}

/// Sparkle overlay painter
class _SparkleOverlayPainter extends CustomPainter {
  final double sparkleProgress;
  final double opacity;

  _SparkleOverlayPainter({
    required this.sparkleProgress,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()
      ..blendMode = BlendMode.plus;
    
    for (int i = 0; i < AnimationConstants.maxSparkleCount; i++) {
      final sparklePhase = (sparkleProgress + i / 30) % 1.0;
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      
      final sparkleOpacity = math.sin(sparklePhase * math.pi) * opacity;
      
      paint.color = Colors.white.withValues(alpha: sparkleOpacity * 0.6);
      
      // Draw sparkle
      canvas.drawCircle(Offset(x, y), 2 + sparklePhase * 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkleOverlayPainter oldDelegate) {
    return sparkleProgress != oldDelegate.sparkleProgress ||
           opacity != oldDelegate.opacity;
  }
}