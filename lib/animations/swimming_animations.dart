import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/creature.dart';

class SwimmingCreature extends StatefulWidget {
  final Creature creature;
  final double size;
  final Duration swimDuration;
  final Offset startPosition;
  final Offset endPosition;
  final bool showDetails;
  
  const SwimmingCreature({
    super.key,
    required this.creature,
    this.size = 40,
    this.swimDuration = const Duration(seconds: 10),
    required this.startPosition,
    required this.endPosition,
    this.showDetails = false,
  });

  @override
  State<SwimmingCreature> createState() => _SwimmingCreatureState();
}

class _SwimmingCreatureState extends State<SwimmingCreature>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _tailAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.swimDuration,
      vsync: this,
    )..repeat();
    
    // Create a curved path for swimming
    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    // Add slight rotation for realistic movement
    _rotationAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    // Tail animation for swimming motion
    _tailAnimation = Tween<double>(
      begin: -0.2,
      end: 0.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: CustomPaint(
              size: Size(widget.size, widget.size * 0.6),
              painter: SwimmingCreaturePainter(
                creature: widget.creature,
                tailAngle: _tailAnimation.value,
                showDetails: widget.showDetails,
              ),
            ),
          ),
        );
      },
    );
  }
}

class SwimmingCreaturePainter extends CustomPainter {
  final Creature creature;
  final double tailAngle;
  final bool showDetails;
  
  SwimmingCreaturePainter({
    required this.creature,
    required this.tailAngle,
    required this.showDetails,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Get creature color based on rarity
    final baseColor = _getCreatureColor();
    
    // Draw body
    paint.color = baseColor;
    paint.style = PaintingStyle.fill;
    
    // Fish body (ellipse)
    final bodyRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.5),
      width: size.width * 0.7,
      height: size.height * 0.8,
    );
    canvas.drawOval(bodyRect, paint);
    
    // Draw tail with animation
    final tailPath = Path();
    final tailBase = Offset(size.width * 0.15, size.height * 0.5);
    
    tailPath.moveTo(tailBase.dx, tailBase.dy - size.height * 0.2);
    tailPath.quadraticBezierTo(
      tailBase.dx - size.width * 0.2 + tailAngle * 20,
      tailBase.dy,
      tailBase.dx,
      tailBase.dy + size.height * 0.2,
    );
    tailPath.lineTo(tailBase.dx, tailBase.dy);
    tailPath.close();
    
    paint.color = baseColor.withValues(alpha: baseColor.a * 0.8);
    canvas.drawPath(tailPath, paint);
    
    // Draw fins
    _drawFins(canvas, size, baseColor);
    
    // Draw eye
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.4),
      size.width * 0.05,
      paint,
    );
    
    paint.color = Colors.black;
    canvas.drawCircle(
      Offset(size.width * 0.66, size.height * 0.4),
      size.width * 0.03,
      paint,
    );
    
    // Add shimmer effect for rare/legendary creatures
    if (creature.rarity == CreatureRarity.rare || 
        creature.rarity == CreatureRarity.legendary) {
      _drawShimmer(canvas, size);
    }
    
    // Draw details if enabled
    if (showDetails) {
      _drawCreatureDetails(canvas, size);
    }
  }
  
  Color _getCreatureColor() {
    switch (creature.rarity) {
      case CreatureRarity.common:
        switch (creature.type) {
          case CreatureType.starterFish:
            return const Color(0xFFFF8C42); // Orange
          case CreatureType.reefBuilder:
            return const Color(0xFF4ECDC4); // Turquoise
          case CreatureType.predator:
            return const Color(0xFF95A99C); // Gray
          case CreatureType.deepSeaDweller:
            return const Color(0xFF2C3E50); // Dark blue
          case CreatureType.mythical:
            return const Color(0xFF9B59B6); // Purple
        }
      case CreatureRarity.uncommon:
        return const Color(0xFF3498DB); // Bright blue
      case CreatureRarity.rare:
        return const Color(0xFFE74C3C); // Red
      case CreatureRarity.legendary:
        return const Color(0xFFFFD700); // Gold
    }
  }
  
  void _drawFins(Canvas canvas, Size size, Color baseColor) {
    final finPaint = Paint()
      ..color = baseColor.withValues(alpha: baseColor.a * 0.6)
      ..style = PaintingStyle.fill;
    
    // Top fin
    final topFinPath = Path();
    topFinPath.moveTo(size.width * 0.4, size.height * 0.1);
    topFinPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.05,
      size.width * 0.6,
      size.height * 0.15,
    );
    topFinPath.lineTo(size.width * 0.5, size.height * 0.2);
    topFinPath.close();
    canvas.drawPath(topFinPath, finPaint);
    
    // Bottom fin
    final bottomFinPath = Path();
    bottomFinPath.moveTo(size.width * 0.4, size.height * 0.9);
    bottomFinPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.95,
      size.width * 0.6,
      size.height * 0.85,
    );
    bottomFinPath.lineTo(size.width * 0.5, size.height * 0.8);
    bottomFinPath.close();
    canvas.drawPath(bottomFinPath, finPaint);
    
    // Side fins
    final sideFinPath = Path();
    sideFinPath.moveTo(size.width * 0.45, size.height * 0.6);
    sideFinPath.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.75,
      size.width * 0.5,
      size.height * 0.7,
    );
    sideFinPath.close();
    canvas.drawPath(sideFinPath, finPaint);
  }
  
  void _drawShimmer(Canvas canvas, Size size) {
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withAlpha(0),
          Colors.white.withAlpha(51),
          Colors.white.withAlpha(0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.overlay;
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.5),
        width: size.width * 0.6,
        height: size.height * 0.7,
      ),
      shimmerPaint,
    );
  }
  
  void _drawCreatureDetails(Canvas canvas, Size size) {
    // Add stripes or patterns based on creature type
    if (creature.type == CreatureType.reefBuilder) {
      final stripePaint = Paint()
        ..color = Colors.white.withAlpha(51)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      for (int i = 0; i < 3; i++) {
        final x = size.width * (0.3 + i * 0.15);
        canvas.drawLine(
          Offset(x, size.height * 0.2),
          Offset(x, size.height * 0.8),
          stripePaint,
        );
      }
    } else if (creature.type == CreatureType.predator) {
      // Draw teeth for predators
      final teethPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      for (int i = 0; i < 3; i++) {
        final toothPath = Path();
        final x = size.width * (0.6 + i * 0.05);
        toothPath.moveTo(x, size.height * 0.45);
        toothPath.lineTo(x + 2, size.height * 0.5);
        toothPath.lineTo(x - 2, size.height * 0.5);
        toothPath.close();
        canvas.drawPath(toothPath, teethPaint);
      }
    }
  }
  
  @override
  bool shouldRepaint(SwimmingCreaturePainter oldDelegate) {
    return oldDelegate.tailAngle != tailAngle ||
           oldDelegate.showDetails != showDetails;
  }
}

// School of fish animation widget
class SchoolOfFish extends StatefulWidget {
  final List<Creature> creatures;
  final Size containerSize;
  final int maxVisible;
  
  const SchoolOfFish({
    super.key,
    required this.creatures,
    required this.containerSize,
    this.maxVisible = 10,
  });

  @override
  State<SchoolOfFish> createState() => _SchoolOfFishState();
}

class _SchoolOfFishState extends State<SchoolOfFish> 
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<Offset>> _animations = [];
  final math.Random _random = math.Random();
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    final visibleCount = math.min(widget.maxVisible, widget.creatures.length);
    
    for (int i = 0; i < visibleCount; i++) {
      final controller = AnimationController(
        duration: Duration(seconds: 15 + _random.nextInt(10)),
        vsync: this,
      );
      
      // Create a path that goes across the screen
      final startX = _random.nextBool() ? -50.0 : widget.containerSize.width + 50;
      final endX = startX < 0 ? widget.containerSize.width + 50 : -50.0;
      final y = _random.nextDouble() * widget.containerSize.height;
      
      final animation = Tween<Offset>(
        begin: Offset(startX, y),
        end: Offset(endX, y + (_random.nextDouble() - 0.5) * 100),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.linear,
      ));
      
      _controllers.add(controller);
      _animations.add(animation);
      
      // Start animation with random delay
      Future.delayed(Duration(milliseconds: _random.nextInt(5000)), () {
        if (mounted) {
          controller.repeat();
        }
      });
    }
  }
  
  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final visibleCount = math.min(widget.maxVisible, widget.creatures.length);
    
    return Stack(
      children: List.generate(visibleCount, (index) {
        return SwimmingCreature(
          creature: widget.creatures[index],
          size: 30 + _random.nextDouble() * 20,
          swimDuration: Duration(seconds: 15 + _random.nextInt(10)),
          startPosition: _animations[index].value,
          endPosition: _animations[index].value,
        );
      }),
    );
  }
}