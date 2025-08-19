import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../services/gamification_service.dart';

class CelebrationDialog extends StatefulWidget {
  final bool isStudySession;
  final GamificationReward? reward;
  final VoidCallback onDismiss;

  const CelebrationDialog({
    super.key,
    required this.isStudySession,
    this.reward,
    required this.onDismiss,
  });

  @override
  State<CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<CelebrationDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _confettiAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Haptic feedback for celebration
    HapticFeedback.mediumImpact();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _scaleController.forward();
    _confettiController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Confetti background
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _confettiAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ConfettiPainter(_confettiAnimation.value),
                  size: MediaQuery.of(context).size,
                );
              },
            ),
          ),
          
          // Dialog content
          Center(
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: 320,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Celebration icon
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: widget.isStudySession
                                            ? [const Color(0xFF6B5B95), const Color(0xFF88B0D3)]
                                            : [const Color(0xFFFF6B6B), const Color(0xFFFECA57)],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (widget.isStudySession 
                                              ? const Color(0xFF6B5B95) 
                                              : const Color(0xFFFF6B6B)).withValues(alpha: 0.4),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      widget.isStudySession ? Icons.coffee : Icons.psychology,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Title
                            Text(
                              widget.isStudySession ? 'Break Complete!' : 'Session Complete!',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Subtitle
                            Text(
                              widget.isStudySession
                                  ? 'Time to focus again! 🚀'
                                  : 'Great work! Take a break 🎉',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Reward information
                            if (widget.reward != null) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // XP Gained
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.stars,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '+${widget.reward!.xpGained} XP',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    // Level up notification
                                    if (widget.reward!.leveledUp) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Colors.purple, Colors.pink],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'LEVEL UP! Level ${widget.reward!.newLevel}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                    
                                    // Streak info
                                    if (widget.reward!.currentStreak > 0) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            GamificationService.instance.getStreakEmoji(),
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${widget.reward!.currentStreak} day streak!',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: GamificationService.instance.getStreakColor(),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    
                                    // Unlocked themes
                                    if (widget.reward!.unlockedThemes.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: widget.reward!.unlockedThemes.map((theme) => 
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.green),
                                            ),
                                            child: Text(
                                              'New theme: $theme',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                            
                            // Continue button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  widget.onDismiss();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final double animationValue;
  final List<Particle> particles;

  ConfettiPainter(this.animationValue) : particles = _generateParticles();

  static List<Particle> _generateParticles() {
    final random = math.Random();
    return List.generate(50, (index) {
      return Particle(
        x: random.nextDouble(),
        y: random.nextDouble() * 0.3,
        size: random.nextDouble() * 8 + 4,
        color: [
          Colors.yellow,
          Colors.pink,
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.purple,
        ][random.nextInt(6)],
        rotation: random.nextDouble() * math.pi * 2,
        velocity: random.nextDouble() * 2 + 1,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: animationValue * 0.8)
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = (particle.y + animationValue * particle.velocity) * size.height;

      if (y > size.height) continue;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation + animationValue * math.pi * 4);
      
      // Draw confetti as small rectangles
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 0.6,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class Particle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double rotation;
  final double velocity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.rotation,
    required this.velocity,
  });
}