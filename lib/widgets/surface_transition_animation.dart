import 'package:flutter/material.dart';
import 'dart:math';

/// Animation widget for transitioning from underwater to surface during breaks
/// Shows ascending bubbles and depth change visualization
class SurfaceTransitionAnimation extends StatefulWidget {
  final bool isAscending; // true when going to surface (break), false when diving (work)
  final VoidCallback? onComplete;
  final Duration duration;
  
  const SurfaceTransitionAnimation({
    super.key,
    required this.isAscending,
    this.onComplete,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<SurfaceTransitionAnimation> createState() => _SurfaceTransitionAnimationState();
}

class _SurfaceTransitionAnimationState extends State<SurfaceTransitionAnimation> 
    with TickerProviderStateMixin {
  
  late AnimationController _transitionController;
  late AnimationController _bubblesController;
  late Animation<double> _transitionAnimation;
  late Animation<double> _bubblesAnimation;
  late Animation<Color?> _colorTransition;
  late Animation<double> _depthIndicatorAnimation;
  
  final List<Bubble> _bubbles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateBubbles();
    _startAnimation();
  }
  
  void _initializeAnimations() {
    _transitionController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _bubblesController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _transitionAnimation = CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    );
    
    _bubblesAnimation = CurvedAnimation(
      parent: _bubblesController,
      curve: Curves.linear,
    );
    
    // Color transition from deep blue to sky blue
    final startColor = widget.isAscending 
        ? const Color(0xFF006994) // Deep ocean
        : const Color(0xFF87CEEB); // Sky blue
    final endColor = widget.isAscending 
        ? const Color(0xFF87CEEB) // Sky blue
        : const Color(0xFF006994); // Deep ocean
    
    _colorTransition = ColorTween(
      begin: startColor,
      end: endColor,
    ).animate(_transitionAnimation);
    
    // Depth indicator animation
    _depthIndicatorAnimation = Tween<double>(
      begin: widget.isAscending ? 40.0 : 0.0, // 40m to 0m when ascending
      end: widget.isAscending ? 0.0 : 40.0,   // 0m to 40m when diving
    ).animate(_transitionAnimation);
  }
  
  void _generateBubbles() {
    for (int i = 0; i < 20; i++) {
      _bubbles.add(
        Bubble(
          startPosition: Offset(
            _random.nextDouble(),
            widget.isAscending ? 1.0 + _random.nextDouble() * 0.5 : -0.5,
          ),
          size: _random.nextDouble() * 8 + 4,
          speed: _random.nextDouble() * 0.5 + 0.3,
          opacity: _random.nextDouble() * 0.8 + 0.2,
        ),
      );
    }
  }
  
  void _startAnimation() {
    _transitionController.forward();
    _bubblesController.repeat();
    
    _transitionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _transitionController.dispose();
    _bubblesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_transitionAnimation, _bubblesAnimation]),
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _colorTransition.value!,
                _colorTransition.value!.withAlpha(180),
                _colorTransition.value!.withAlpha(100),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Bubbles animation
              ..._bubbles.map((bubble) => _buildBubble(bubble)),
              
              // Depth indicator
              Positioned(
                top: 60,
                left: 20,
                child: _buildDepthIndicator(),
              ),
              
              // Transition message
              Center(
                child: _buildTransitionMessage(),
              ),
              
              // Light rays effect (when ascending to surface)
              if (widget.isAscending && _transitionAnimation.value > 0.7)
                _buildLightRays(),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildBubble(Bubble bubble) {
    final screenSize = MediaQuery.of(context).size;
    final progress = widget.isAscending 
        ? (bubble.startPosition.dy - _bubblesAnimation.value * bubble.speed) 
        : (bubble.startPosition.dy + _bubblesAnimation.value * bubble.speed);
    
    // Remove bubble when it goes off screen
    if (widget.isAscending && progress < -0.1) return const SizedBox.shrink();
    if (!widget.isAscending && progress > 1.1) return const SizedBox.shrink();
    
    final position = Offset(
      bubble.startPosition.dx * screenSize.width,
      progress * screenSize.height,
    );
    
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Container(
        width: bubble.size,
        height: bubble.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withAlpha((bubble.opacity * 255).round()),
          border: Border.all(
            color: Colors.white.withAlpha(100),
            width: 1,
          ),
        ),
      ),
    );
  }
  
  Widget _buildDepthIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withAlpha(100),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '📊 DIVE COMPUTER',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Depth: ${_depthIndicatorAnimation.value.toStringAsFixed(1)}m',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 80,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widget.isAscending 
                  ? (1.0 - _transitionAnimation.value) 
                  : _transitionAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isAscending ? Colors.lightBlue : Colors.blue[800],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTransitionMessage() {
    final message = widget.isAscending 
        ? 'Ascending to Research Vessel'
        : 'Diving to Research Depth';
    final submessage = widget.isAscending 
        ? 'Preparing surface break activities...'
        : 'Descending for focused research...';
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(128),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withAlpha(100),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.isAscending ? Icons.arrow_upward : Icons.arrow_downward,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            submessage,
            style: TextStyle(
              color: Colors.white.withAlpha(204),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLightRays() {
    return Positioned.fill(
      child: CustomPaint(
        painter: LightRaysPainter(_transitionAnimation.value),
      ),
    );
  }
}

/// Custom painter for light rays coming from the surface
class LightRaysPainter extends CustomPainter {
  final double progress;
  
  LightRaysPainter(this.progress);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha((progress * 100).round())
      ..style = PaintingStyle.fill;
    
    // Draw several light rays from top of screen
    final rayCount = 6;
    for (int i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * 0.8 - 0.4; // -0.4 to 0.4 radians
      final startX = size.width * (0.5 + angle);
      final endX = startX + sin(angle) * size.height;
      
      final path = Path();
      path.moveTo(startX - 20, 0);
      path.lineTo(startX + 20, 0);
      path.lineTo(endX + 40, size.height);
      path.lineTo(endX - 40, size.height);
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }
  
  @override
  bool shouldRepaint(LightRaysPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Data model for bubble animation
class Bubble {
  final Offset startPosition;
  final double size;
  final double speed;
  final double opacity;
  
  Bubble({
    required this.startPosition,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}