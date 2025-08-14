import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/gamification_service.dart';

class AvatarMascotWidget extends StatefulWidget {
  final bool isRunning;
  final bool isStudySession;
  final double size;
  
  const AvatarMascotWidget({
    Key? key,
    required this.isRunning,
    required this.isStudySession,
    this.size = 120,
  }) : super(key: key);

  @override
  State<AvatarMascotWidget> createState() => _AvatarMascotWidgetState();
}

class _AvatarMascotWidgetState extends State<AvatarMascotWidget> 
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _blinkController;
  late AnimationController _moodController;
  late Animation<double> _floatAnimation;
  late Animation<double> _blinkAnimation;
  late Animation<double> _moodAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Floating animation
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    // Blinking animation
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _blinkAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _blinkController,
      curve: Curves.easeInOut,
    ));
    
    // Start periodic blinking
    _startBlinking();
    
    // Mood animation
    _moodController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _moodAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _moodController,
      curve: Curves.easeInOut,
    ));
  }
  
  void _startBlinking() {
    Future.delayed(Duration(seconds: 3 + math.Random().nextInt(3)), () {
      if (mounted) {
        _blinkController.forward().then((_) {
          _blinkController.reverse().then((_) {
            _startBlinking();
          });
        });
      }
    });
  }
  
  @override
  void dispose() {
    _floatController.dispose();
    _blinkController.dispose();
    _moodController.dispose();
    super.dispose();
  }
  
  Color _getMascotColor() {
    final level = GamificationService.instance.currentLevel;
    if (level >= 25) return Colors.purple;
    if (level >= 20) return Colors.indigo;
    if (level >= 15) return Colors.blue;
    if (level >= 10) return Colors.teal;
    if (level >= 5) return Colors.green;
    return Colors.lightBlue;
  }
  
  String _getMascotMood() {
    if (widget.isRunning && widget.isStudySession) return 'focused';
    if (widget.isRunning && !widget.isStudySession) return 'relaxed';
    if (!widget.isRunning && widget.isStudySession) return 'waiting';
    return 'happy';
  }
  
  @override
  Widget build(BuildContext context) {
    final mascotColor = _getMascotColor();
    final mood = _getMascotMood();
    final scaleFactor = widget.size / 120; // Default size is 120
    
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value * scaleFactor),
          child: Container(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Subtle glow effect
                Container(
                  width: widget.size * 0.83, // 100/120 ratio
                  height: widget.size * 0.83,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: mascotColor.withOpacity(0.2),
                        blurRadius: 20 * scaleFactor,
                        spreadRadius: 5 * scaleFactor,
                      ),
                    ],
                  ),
                ),
                
                // Main body
                Container(
                  width: widget.size * 0.67, // 80/120 ratio
                  height: widget.size * 0.67,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        mascotColor.withOpacity(0.3),
                        mascotColor.withOpacity(0.2),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Eyes
                      Positioned(
                        top: 22 * scaleFactor,
                        left: 20 * scaleFactor,
                        child: AnimatedBuilder(
                          animation: _blinkAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 12 * scaleFactor,
                              height: 12 * scaleFactor * _blinkAnimation.value,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6 * scaleFactor),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 22 * scaleFactor,
                        right: 20 * scaleFactor,
                        child: AnimatedBuilder(
                          animation: _blinkAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 12 * scaleFactor,
                              height: 12 * scaleFactor * _blinkAnimation.value,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6 * scaleFactor),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Mouth based on mood
                      Positioned(
                        bottom: 18 * scaleFactor,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: CustomPaint(
                            size: Size(40 * scaleFactor, 20 * scaleFactor),
                            painter: MouthPainter(
                              mood: mood,
                              animation: _moodAnimation.value,
                            ),
                          ),
                        ),
                      ),
                      
                      // Status indicator
                      if (widget.isRunning)
                        Positioned(
                          top: 5 * scaleFactor,
                          right: 5 * scaleFactor,
                          child: AnimatedBuilder(
                            animation: _moodAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 10 * scaleFactor,
                                height: 10 * scaleFactor,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.isStudySession 
                                      ? Colors.green.withOpacity(0.5 + _moodAnimation.value * 0.5)
                                      : Colors.orange.withOpacity(0.5 + _moodAnimation.value * 0.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.isStudySession 
                                          ? Colors.green.withOpacity(0.5)
                                          : Colors.orange.withOpacity(0.5),
                                      blurRadius: 10 * scaleFactor,
                                      spreadRadius: 2 * scaleFactor,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Level badge
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8 * scaleFactor, vertical: 2 * scaleFactor),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10 * scaleFactor),
                      border: Border.all(
                        color: mascotColor,
                        width: 1 * scaleFactor,
                      ),
                    ),
                    child: Text(
                      'Lv.${GamificationService.instance.currentLevel}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10 * scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MouthPainter extends CustomPainter {
  final String mood;
  final double animation;
  
  MouthPainter({
    required this.mood,
    required this.animation,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    switch (mood) {
      case 'focused':
        // Straight line (concentrated)
        path.moveTo(8, centerY);
        path.lineTo(size.width - 8, centerY);
        break;
        
      case 'relaxed':
        // Nice smile
        path.moveTo(8, centerY - 2);
        path.quadraticBezierTo(
          centerX, 
          centerY + 10 + (animation * 3), 
          size.width - 8, 
          centerY - 2,
        );
        break;
        
      case 'waiting':
        // Subtle neutral/slightly concerned expression
        path.moveTo(6, centerY + 1);
        path.quadraticBezierTo(
          centerX, 
          centerY - 2 - (animation * 1), 
          size.width - 6, 
          centerY + 1,
        );
        break;
        
      default: // happy
        // Gentle natural smile - longer/broader
        path.moveTo(4, centerY - 1);
        path.quadraticBezierTo(
          centerX, 
          centerY + 5 + (animation * 1), 
          size.width - 4, 
          centerY - 1,
        );
        break;
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(MouthPainter oldDelegate) {
    return oldDelegate.mood != mood || oldDelegate.animation != animation;
  }
}