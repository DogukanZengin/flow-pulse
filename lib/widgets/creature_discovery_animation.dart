import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/creature.dart';

class CreatureDiscoveryAnimation extends StatefulWidget {
  final Creature creature;
  final VoidCallback onComplete;
  
  const CreatureDiscoveryAnimation({
    super.key,
    required this.creature,
    required this.onComplete,
  });
  
  @override
  State<CreatureDiscoveryAnimation> createState() => _CreatureDiscoveryAnimationState();
}

class _CreatureDiscoveryAnimationState extends State<CreatureDiscoveryAnimation>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _shimmerController;
  late AnimationController _bubbleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _shimmerAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Fade in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    
    // Scale animation for creature reveal
    _scaleController = AnimationController(
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
    
    // Rotation animation for excitement
    _rotateController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.easeInOut,
    ));
    
    // Shimmer effect for rarity
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_shimmerController);
    
    // Bubble animation
    _bubbleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _rotateController.repeat(reverse: true);
    
    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _fadeController.reverse().then((_) {
          widget.onComplete();
        });
      }
    });
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    _shimmerController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }
  
  Color get _rarityColor {
    switch (widget.creature.rarity) {
      case CreatureRarity.common:
        return Colors.grey;
      case CreatureRarity.uncommon:
        return Colors.green;
      case CreatureRarity.rare:
        return Colors.blue;
      case CreatureRarity.legendary:
        return Colors.purple;
    }
  }
  
  String get _rarityText {
    switch (widget.creature.rarity) {
      case CreatureRarity.common:
        return 'Common Discovery!';
      case CreatureRarity.uncommon:
        return 'Uncommon Find!';
      case CreatureRarity.rare:
        return 'Rare Creature!';
      case CreatureRarity.legendary:
        return '✨ LEGENDARY! ✨';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background bubbles
              _buildBubbles(),
              
              // Main discovery card
              AnimatedBuilder(
                animation: _rotateController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 320,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF1E3A5F),
                              const Color(0xFF0D2137),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _rarityColor.withValues(alpha: 0.8),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _rarityColor.withValues(alpha: 0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // "New Discovery!" header
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  Colors.white,
                                  _rarityColor,
                                  Colors.white,
                                ],
                                stops: [
                                  _shimmerAnimation.value - 0.3,
                                  _shimmerAnimation.value,
                                  _shimmerAnimation.value + 0.3,
                                ].map((e) => e.clamp(0.0, 1.0)).toList(),
                              ).createShader(bounds),
                              child: const Text(
                                '🌊 NEW DISCOVERY! 🌊',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Creature visual
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    _rarityColor.withValues(alpha: 0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: _buildCreatureVisual(),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Creature name
                            Text(
                              widget.creature.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            
                            // Scientific name
                            Text(
                              widget.creature.species,
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Rarity badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _rarityColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _rarityColor,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _rarityText,
                                style: TextStyle(
                                  color: _rarityColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Pearl reward
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '💎 +',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.amber,
                                  ),
                                ),
                                Text(
                                  '${widget.creature.pearlValue}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                                const Text(
                                  ' Pearls',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Habitat info
                            Text(
                              'Found in: ${widget.creature.habitat.displayName}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Sparkle effects for legendary creatures
              if (widget.creature.rarity == CreatureRarity.legendary)
                _buildSparkles(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCreatureVisual() {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            math.sin(_rotateController.value * 2 * math.pi) * 5,
            math.cos(_rotateController.value * 2 * math.pi) * 3,
          ),
          child: CustomPaint(
            size: const Size(80, 60),
            painter: SimpleCreaturePainter(
              creature: widget.creature,
              animationValue: _rotateController.value,
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildBubbles() {
    return AnimatedBuilder(
      animation: _bubbleController,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: BubblesPainter(
            animationValue: _bubbleController.value,
            color: _rarityColor.withValues(alpha: 0.3),
          ),
        );
      },
    );
  }
  
  Widget _buildSparkles() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(400, 400),
          painter: SparklesPainter(
            animationValue: _shimmerController.value,
            color: Colors.amber,
          ),
        );
      },
    );
  }
}

// Simple creature painter for the discovery animation
class SimpleCreaturePainter extends CustomPainter {
  final Creature creature;
  final double animationValue;
  
  SimpleCreaturePainter({
    required this.creature,
    required this.animationValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // Set color based on rarity
    switch (creature.rarity) {
      case CreatureRarity.common:
        paint.color = Colors.grey;
        break;
      case CreatureRarity.uncommon:
        paint.color = Colors.green;
        break;
      case CreatureRarity.rare:
        paint.color = Colors.blue;
        break;
      case CreatureRarity.legendary:
        paint.color = Colors.purple;
        break;
    }
    
    // Draw simple fish shape
    final path = Path();
    final wobble = math.sin(animationValue * 2 * math.pi) * 2;
    
    // Body
    path.moveTo(size.width * 0.2, size.height * 0.5 + wobble);
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.2 + wobble,
      size.width * 0.8, size.height * 0.5 + wobble,
    );
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.8 + wobble,
      size.width * 0.2, size.height * 0.5 + wobble,
    );
    
    // Tail
    path.moveTo(size.width * 0.2, size.height * 0.5 + wobble);
    path.lineTo(0, size.height * 0.3 + wobble);
    path.lineTo(0, size.height * 0.7 + wobble);
    path.lineTo(size.width * 0.2, size.height * 0.5 + wobble);
    
    canvas.drawPath(path, paint);
    
    // Eye
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.45 + wobble),
      4,
      eyePaint,
    );
    
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.45 + wobble),
      2,
      pupilPaint,
    );
  }
  
  @override
  bool shouldRepaint(SimpleCreaturePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// Bubbles painter for background effect
class BubblesPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  
  BubblesPainter({
    required this.animationValue,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Draw several bubbles at different positions
    for (int i = 0; i < 8; i++) {
      final offset = (animationValue + i * 0.125) % 1.0;
      final x = size.width * (0.2 + i * 0.1);
      final y = size.height * (1.0 - offset);
      final radius = 3 + i % 3 * 2.0;
      
      if (y > 0 && y < size.height) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(BubblesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// Sparkles painter for legendary creatures
class SparklesPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  
  SparklesPainter({
    required this.animationValue,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    
    // Draw sparkles in a circular pattern
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi + animationValue * 2 * math.pi;
      final radius = 120 + math.sin(animationValue * 4 * math.pi + i) * 20;
      
      final x = size.width / 2 + math.cos(angle) * radius;
      final y = size.height / 2 + math.sin(angle) * radius;
      
      final sparkleSize = 2 + math.sin(animationValue * 3 * math.pi + i) * 2;
      
      // Draw a star shape
      final path = Path();
      for (int j = 0; j < 4; j++) {
        final starAngle = (j / 4) * 2 * math.pi;
        final px = x + math.cos(starAngle) * sparkleSize;
        final py = y + math.sin(starAngle) * sparkleSize;
        
        if (j == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }
  
  @override
  bool shouldRepaint(SparklesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}