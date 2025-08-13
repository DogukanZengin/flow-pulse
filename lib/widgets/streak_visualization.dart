import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/gamification_service.dart';

class StreakVisualization extends StatefulWidget {
  final int streakCount;
  final bool showAnimation;
  
  const StreakVisualization({
    super.key,
    required this.streakCount,
    this.showAnimation = false,
  });

  @override
  State<StreakVisualization> createState() => _StreakVisualizationState();
}

class _StreakVisualizationState extends State<StreakVisualization>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _growthController;
  late AnimationController _fireController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _growthAnimation;
  late Animation<double> _fireAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _growthController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fireController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
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
    
    _fireAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fireController,
      curve: Curves.linear,
    ));
    
    if (widget.showAnimation) {
      _growthController.forward();
    } else {
      _growthController.value = 1.0;
    }
  }
  
  @override
  void didUpdateWidget(StreakVisualization oldWidget) {
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
    _fireController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _growthAnimation, _fireAnimation]),
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Streak visualization
              Transform.scale(
                scale: _pulseAnimation.value * _growthAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: GamificationService.instance.getStreakColor().withOpacity(0.1),
                    border: Border.all(
                      color: GamificationService.instance.getStreakColor().withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: GamificationService.instance.getStreakColor().withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated background based on streak type
                      if (widget.streakCount >= 7)
                        CustomPaint(
                          size: const Size(120, 120),
                          painter: StreakEffectPainter(
                            streakCount: widget.streakCount,
                            animationValue: _fireAnimation.value,
                          ),
                        ),
                      
                      // Main streak display
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            GamificationService.instance.getStreakEmoji(),
                            style: TextStyle(
                              fontSize: widget.streakCount >= 30 ? 36 : 
                                       widget.streakCount >= 14 ? 32 :
                                       widget.streakCount >= 7 ? 28 : 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.streakCount}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: GamificationService.instance.getStreakColor(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Streak description
              Text(
                _getStreakDescription(widget.streakCount),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Streak progress indicators
              if (widget.streakCount > 0)
                _buildStreakProgress(),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildStreakProgress() {
    final milestones = [3, 7, 14, 30];
    final nextMilestone = milestones.firstWhere(
      (milestone) => milestone > widget.streakCount,
      orElse: () => milestones.last,
    );
    
    return Column(
      children: [
        Text(
          'Next milestone: ${nextMilestone - widget.streakCount} days',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white60,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 100,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (widget.streakCount / nextMilestone).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: GamificationService.instance.getStreakColor(),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  String _getStreakDescription(int streak) {
    if (streak >= 30) return 'Legendary Streak! 🏆';
    if (streak >= 14) return 'Two Week Champion! ⚡';
    if (streak >= 7) return 'Week Warrior! 🌟';
    if (streak >= 3) return 'Building Momentum! 💪';
    if (streak >= 1) return 'Great Start! 🌱';
    return 'Start Your Streak! 💤';
  }
}

class StreakEffectPainter extends CustomPainter {
  final int streakCount;
  final double animationValue;
  
  StreakEffectPainter({
    required this.streakCount,
    required this.animationValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    if (streakCount >= 30) {
      // Fire effect for legendary streaks
      _paintFireEffect(canvas, size, center, radius);
    } else if (streakCount >= 14) {
      // Lightning effect for two-week streaks
      _paintLightningEffect(canvas, center, radius);
    } else if (streakCount >= 7) {
      // Star effect for week streaks
      _paintStarEffect(canvas, center, radius);
    }
  }
  
  void _paintFireEffect(Canvas canvas, Size size, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.orange.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    // Animated fire particles
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi + (animationValue * 2 * math.pi);
      final distance = radius * 0.7 + (math.sin(animationValue * 4 + i) * 10);
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;
      
      canvas.drawCircle(
        Offset(x, y),
        3 + math.sin(animationValue * 3 + i) * 2,
        paint,
      );
    }
  }
  
  void _paintLightningEffect(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.yellow.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    // Animated lightning bolts
    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * math.pi + (animationValue * 2 * math.pi);
      final startX = center.dx + math.cos(angle) * (radius * 0.4);
      final startY = center.dy + math.sin(angle) * (radius * 0.4);
      final endX = center.dx + math.cos(angle) * (radius * 0.8);
      final endY = center.dy + math.sin(angle) * (radius * 0.8);
      
      final path = Path();
      path.moveTo(startX, startY);
      path.lineTo(endX, endY);
      
      canvas.drawPath(path, paint);
    }
  }
  
  void _paintStarEffect(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.purple.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    
    // Rotating stars
    for (int i = 0; i < 5; i++) {
      final angle = (i / 5) * 2 * math.pi + (animationValue * math.pi);
      final distance = radius * 0.6;
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;
      
      _drawStar(canvas, Offset(x, y), 8, paint);
    }
  }
  
  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - (math.pi / 2);
      final x = center.dx + math.cos(angle) * size;
      final y = center.dy + math.sin(angle) * size;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(StreakEffectPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.streakCount != streakCount;
  }
}