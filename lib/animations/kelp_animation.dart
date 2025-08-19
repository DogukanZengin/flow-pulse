import 'package:flutter/material.dart';

class KelpAnimation extends StatefulWidget {
  final double height;
  final double width;
  final Color color;
  final Duration animationDuration;
  final double swayIntensity;
  final int segments;
  
  const KelpAnimation({
    super.key,
    required this.height,
    required this.width,
    required this.color,
    this.animationDuration = const Duration(seconds: 6),
    this.swayIntensity = 0.05,
    this.segments = 8,
  });

  @override
  State<KelpAnimation> createState() => _KelpAnimationState();
}

class _KelpAnimationState extends State<KelpAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _swayAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat(reverse: true);
    
    _swayAnimation = Tween<double>(
      begin: -widget.swayIntensity,
      end: widget.swayIntensity,
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
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _swayAnimation,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.width, widget.height),
            painter: KelpPainter(
              swayOffset: _swayAnimation.value,
              color: widget.color,
              segments: widget.segments,
            ),
          );
        },
      ),
    );
  }
}

class KelpPainter extends CustomPainter {
  final double swayOffset;
  final Color color;
  final int segments;
  
  KelpPainter({
    required this.swayOffset,
    required this.color,
    required this.segments,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    
    final segmentHeight = size.height / segments;
    
    // Draw kelp as connected curved segments
    final path = Path();
    path.moveTo(size.width / 2, size.height);
    
    for (int i = 1; i <= segments; i++) {
      final y = size.height - (i * segmentHeight);
      final swayFactor = i / segments; // More sway at the top
      final x = size.width / 2 + (swayOffset * swayFactor * size.width * 0.3);
      
      if (i == 1) {
        path.lineTo(x, y);
      } else {
        // Add some curve to make it more organic
        final controlY = y + segmentHeight / 2;
        final prevX = size.width / 2 + (swayOffset * ((i-1) / segments) * size.width * 0.3);
        path.quadraticBezierTo(prevX, controlY, x, y);
      }
    }
    
    canvas.drawPath(path, paint);
    
    // Add kelp fronds at intervals
    for (int i = 2; i < segments; i += 2) {
      final y = size.height - (i * segmentHeight);
      final swayFactor = i / segments;
      final centerX = size.width / 2 + (swayOffset * swayFactor * size.width * 0.3);
      
      // Left frond
      final leftFrond = Path();
      leftFrond.moveTo(centerX, y);
      leftFrond.quadraticBezierTo(
        centerX - 15 + (swayOffset * 10),
        y - 10,
        centerX - 20 + (swayOffset * 15),
        y - 25,
      );
      
      // Right frond
      final rightFrond = Path();
      rightFrond.moveTo(centerX, y);
      rightFrond.quadraticBezierTo(
        centerX + 15 + (swayOffset * 10),
        y - 10,
        centerX + 20 + (swayOffset * 15),
        y - 25,
      );
      
      final frondPaint = Paint()
        ..color = color.withValues(alpha: color.a * 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      
      canvas.drawPath(leftFrond, frondPaint);
      canvas.drawPath(rightFrond, frondPaint);
    }
  }
  
  @override
  bool shouldRepaint(KelpPainter oldDelegate) {
    return oldDelegate.swayOffset != swayOffset;
  }
}