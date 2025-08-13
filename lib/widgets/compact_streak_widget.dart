import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/gamification_service.dart';

class CompactStreakWidget extends StatefulWidget {
  final int streakCount;
  final bool showAnimation;
  
  const CompactStreakWidget({
    super.key,
    required this.streakCount,
    this.showAnimation = false,
  });

  @override
  State<CompactStreakWidget> createState() => _CompactStreakWidgetState();
}

class _CompactStreakWidgetState extends State<CompactStreakWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _growthController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _growthAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _growthController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _growthAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _growthController,
      curve: Curves.elasticOut,
    ));
    
    if (widget.showAnimation) {
      _growthController.forward();
    } else {
      _growthController.value = 1.0;
    }
  }
  
  @override
  void didUpdateWidget(CompactStreakWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.streakCount != widget.streakCount && widget.showAnimation) {
      _growthController.reset();
      _growthController.forward();
    }
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _growthController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _growthAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value * _growthAnimation.value,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: GamificationService.instance.getStreakColor().withOpacity(0.1),
              border: Border.all(
                color: GamificationService.instance.getStreakColor().withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: GamificationService.instance.getStreakColor().withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Streak emoji with effects
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: GamificationService.instance.getStreakColor().withOpacity(0.2),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background effect for high streaks
                        if (widget.streakCount >= 7)
                          CustomPaint(
                            size: const Size(32, 32),
                            painter: CompactStreakEffectPainter(
                              streakCount: widget.streakCount,
                              animationValue: _pulseAnimation.value,
                            ),
                          ),
                        
                        // Emoji
                        Text(
                          GamificationService.instance.getStreakEmoji(),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Streak count and description
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.streakCount} days',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: GamificationService.instance.getStreakColor(),
                          ),
                        ),
                        Text(
                          _getCompactDescription(widget.streakCount),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  String _getCompactDescription(int streak) {
    if (streak >= 30) return 'Legendary!';
    if (streak >= 14) return 'Champion!';
    if (streak >= 7) return 'Warrior!';
    if (streak >= 3) return 'Momentum!';
    if (streak >= 1) return 'Started!';
    return 'Start streak!';
  }
}

class CompactStreakEffectPainter extends CustomPainter {
  final int streakCount;
  final double animationValue;
  
  CompactStreakEffectPainter({
    required this.streakCount,
    required this.animationValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    if (streakCount >= 30) {
      // Fire particles for legendary streaks
      _paintFireParticles(canvas, center, radius);
    } else if (streakCount >= 14) {
      // Lightning effect for champions
      _paintLightning(canvas, center, radius);
    } else if (streakCount >= 7) {
      // Star effect for warriors
      _paintStars(canvas, center, radius);
    }
  }
  
  void _paintFireParticles(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.orange.withOpacity(0.4)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    for (int i = 0; i < 4; i++) {
      final angle = (i / 4) * 2 * math.pi + (animationValue * 2 * math.pi);
      final distance = radius * 0.6;
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;
      
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }
  
  void _paintLightning(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.yellow.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    for (int i = 0; i < 3; i++) {
      final angle = (i / 3) * 2 * math.pi + (animationValue * math.pi);
      final startRadius = radius * 0.3;
      final endRadius = radius * 0.7;
      
      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * startRadius,
          center.dy + math.sin(angle) * startRadius,
        ),
        Offset(
          center.dx + math.cos(angle) * endRadius,
          center.dy + math.sin(angle) * endRadius,
        ),
        paint,
      );
    }
  }
  
  void _paintStars(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.purple.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 3; i++) {
      final angle = (i / 3) * 2 * math.pi + (animationValue * math.pi);
      final x = center.dx + math.cos(angle) * radius * 0.5;
      final y = center.dy + math.sin(angle) * radius * 0.5;
      
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }
  
  @override
  bool shouldRepaint(CompactStreakEffectPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.streakCount != streakCount;
  }
}