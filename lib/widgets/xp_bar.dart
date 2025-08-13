import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../services/gamification_service.dart';

class XPBar extends StatefulWidget {
  final int currentXP;
  final int currentLevel;
  final double progress;
  final bool showAnimation;
  
  const XPBar({
    super.key,
    required this.currentXP,
    required this.currentLevel,
    required this.progress,
    this.showAnimation = false,
  });

  @override
  State<XPBar> createState() => _XPBarState();
}

class _XPBarState extends State<XPBar> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _glowController;
  late AnimationController _levelUpController;
  
  late Animation<double> _progressAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _levelUpAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _levelUpController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutQuart,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _levelUpAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 0.95),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0),
        weight: 30,
      ),
    ]).animate(CurvedAnimation(
      parent: _levelUpController,
      curve: Curves.elasticOut,
    ));
    
    if (widget.showAnimation) {
      _progressController.forward();
    } else {
      _progressController.value = 1.0;
    }
  }
  
  @override
  void didUpdateWidget(XPBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.currentLevel < widget.currentLevel) {
      _levelUpController.forward().then((_) {
        _levelUpController.reset();
      });
    }
    
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutQuart,
      ));
      _progressController.reset();
      _progressController.forward();
    }
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    _glowController.dispose();
    _levelUpController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnimation, _glowAnimation, _levelUpAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _levelUpAnimation.value,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                children: [
                  // Background
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  
                  // Progress fill
                  Positioned.fill(
                    child: CustomPaint(
                      painter: XPBarPainter(
                        progress: _progressAnimation.value,
                        glowIntensity: _glowAnimation.value,
                        level: widget.currentLevel,
                      ),
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Level badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'LV ${widget.currentLevel}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // XP text
                        Text(
                          '${GamificationService.instance.getCurrentLevelXP()} / ${GamificationService.instance.getXPForNextLevel()} XP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 3,
                                color: Colors.black38,
                              ),
                            ],
                          ),
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
}

class XPBarPainter extends CustomPainter {
  final double progress;
  final double glowIntensity;
  final int level;
  
  XPBarPainter({
    required this.progress,
    required this.glowIntensity,
    required this.level,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final progressWidth = size.width * progress;
    
    // Background gradient
    final backgroundPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(size.width, 0),
        [
          Colors.white.withOpacity(0.05),
          Colors.white.withOpacity(0.1),
        ],
      );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(30)),
      backgroundPaint,
    );
    
    if (progress > 0) {
      // Progress gradient colors based on level
      final progressColors = _getProgressColors(level);
      
      // Glow effect
      final glowPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, 0),
          Offset(progressWidth, 0),
          progressColors.map((c) => c.withOpacity(0.3 * glowIntensity)).toList(),
        )
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * glowIntensity);
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, progressWidth, size.height),
          const Radius.circular(30),
        ),
        glowPaint,
      );
      
      // Progress fill
      final progressPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, 0),
          Offset(progressWidth, 0),
          progressColors,
        );
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, progressWidth, size.height),
          const Radius.circular(30),
        ),
        progressPaint,
      );
      
      // Shimmer effect
      final shimmerPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(progressWidth * 0.3, 0),
          Offset(progressWidth * 0.7, 0),
          [
            Colors.transparent,
            Colors.white.withOpacity(0.3),
            Colors.transparent,
          ],
        );
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, progressWidth, size.height),
          const Radius.circular(30),
        ),
        shimmerPaint,
      );
    }
  }
  
  List<Color> _getProgressColors(int level) {
    // Different color schemes for different level ranges
    if (level >= 50) {
      return [const Color(0xFFFF6B6B), const Color(0xFFFFD93D)]; // Red to Gold
    } else if (level >= 25) {
      return [const Color(0xFF6B5B95), const Color(0xFFFF6B6B)]; // Purple to Red
    } else if (level >= 15) {
      return [const Color(0xFF4ECDC4), const Color(0xFF6B5B95)]; // Teal to Purple
    } else if (level >= 10) {
      return [const Color(0xFF45B7D1), const Color(0xFF4ECDC4)]; // Blue to Teal
    } else if (level >= 5) {
      return [const Color(0xFF96CEB4), const Color(0xFF45B7D1)]; // Green to Blue
    } else {
      return [const Color(0xFFFFCE56), const Color(0xFF96CEB4)]; // Yellow to Green
    }
  }
  
  @override
  bool shouldRepaint(XPBarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.glowIntensity != glowIntensity ||
           oldDelegate.level != level;
  }
}