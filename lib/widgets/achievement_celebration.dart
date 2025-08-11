import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../services/achievement_service.dart';
import 'dart:math' as math;

class AchievementCelebration extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback? onDismiss;

  const AchievementCelebration({
    super.key,
    required this.achievement,
    this.onDismiss,
  });

  @override
  State<AchievementCelebration> createState() => _AchievementCelebrationState();
}

class _AchievementCelebrationState extends State<AchievementCelebration>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startCelebration();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
    ));
  }

  void _startCelebration() {
    _controller.forward();
    _particleController.forward();

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Particle effects
                if (widget.achievement.isPremium)
                  AnimatedBuilder(
                    animation: _particleController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: ParticlePainter(
                          progress: _particleController.value,
                          color: widget.achievement.color,
                        ),
                        size: const Size(300, 300),
                      );
                    },
                  ),

                // Achievement card
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Container(
                        width: 280,
                        height: 320,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: widget.achievement.color.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                          border: Border.all(
                            color: widget.achievement.color,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Premium badge
                            if (widget.achievement.isPremium)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.amber,
                                      Colors.orange,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'PREMIUM',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 20),

                            // Achievement icon with glow
                            AnimatedBuilder(
                              animation: _particleController,
                              builder: (context, child) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: widget.achievement.color.withOpacity(0.2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: widget.achievement.color.withOpacity(
                                          0.3 + (0.2 * math.sin(_particleController.value * 2 * math.pi))
                                        ),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    widget.achievement.icon,
                                    size: 40,
                                    color: widget.achievement.color,
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 20),

                            // Achievement title
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                'Achievement Unlocked!',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: widget.achievement.color,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                widget.achievement.title,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                widget.achievement.description,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Tap to dismiss
                            GestureDetector(
                              onTap: _dismiss,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.achievement.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Tap to continue',
                                  style: TextStyle(
                                    color: widget.achievement.color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final List<Particle> particles = [];

  ParticlePainter({
    required this.progress,
    required this.color,
  }) {
    // Generate particles on first paint
    if (particles.isEmpty) {
      for (int i = 0; i < 20; i++) {
        particles.add(Particle(
          startX: 150 + (math.Random().nextDouble() - 0.5) * 100,
          startY: 150 + (math.Random().nextDouble() - 0.5) * 100,
          endX: 150 + (math.Random().nextDouble() - 0.5) * 300,
          endY: 150 + (math.Random().nextDouble() - 0.5) * 300,
          size: math.Random().nextDouble() * 4 + 2,
          color: color.withOpacity(math.Random().nextDouble() * 0.8 + 0.2),
        ));
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(
          (1 - progress) * particle.color.opacity,
        );

      final x = particle.startX + (particle.endX - particle.startX) * progress;
      final y = particle.startY + (particle.endY - particle.startY) * progress;
      final particleSize = particle.size * (1 - progress * 0.5);

      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Particle {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double size;
  final Color color;

  Particle({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.size,
    required this.color,
  });
}

class AchievementOverlay extends StatelessWidget {
  final Widget child;

  const AchievementOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        StreamBuilder<Achievement?>(
          stream: _achievementStream,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: AchievementCelebration(
                    achievement: snapshot.data!,
                    onDismiss: () {
                      _clearAchievement();
                    },
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  // In a real app, you'd use a proper stream controller
  static Stream<Achievement?> get _achievementStream => Stream.empty();
  static void _clearAchievement() {}
}