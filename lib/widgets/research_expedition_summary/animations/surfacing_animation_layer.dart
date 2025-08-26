import 'package:flutter/material.dart';
import '../models/expedition_result.dart';
import '../models/celebration_config.dart';
import '../../../utils/responsive_helper.dart';

/// Handles the surfacing animation from session depth to surface
/// Shows the transition from underwater research environment to surface celebration
class SurfacingAnimationLayer extends StatefulWidget {
  final AnimationController controller;
  final ExpeditionResult expeditionResult;
  final CelebrationConfig celebrationConfig;

  const SurfacingAnimationLayer({
    super.key,
    required this.controller,
    required this.expeditionResult,
    required this.celebrationConfig,
  });

  @override
  State<SurfacingAnimationLayer> createState() => _SurfacingAnimationLayerState();
}

class _SurfacingAnimationLayerState extends State<SurfacingAnimationLayer>
    with SingleTickerProviderStateMixin {
  
  late Animation<Offset> _surfacingAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Main surfacing movement - from bottom to top
    _surfacingAnimation = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: widget.controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutQuint),
    ));

    // Fade out as we reach surface
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: widget.controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeInQuart),
    ));

    // Scale effect for dramatic emergence
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: widget.controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        final progress = widget.controller.value;
        
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _surfacingAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                    colors: [
                      // Deep ocean (starting depth)
                      _getDepthColor(widget.expeditionResult.sessionDepthReached)
                          .withValues(alpha: 0.9 - progress * 0.9),
                      // Mid depth
                      const Color(0xFF1B4D72).withValues(alpha: 0.7 - progress * 0.7),
                      // Shallow waters  
                      Colors.blue.withValues(alpha: 0.5 - progress * 0.5),
                      // Near surface
                      Colors.lightBlue.withValues(alpha: 0.3 - progress * 0.3),
                      // Surface/research station
                      Colors.cyan.withValues(alpha: 0.1 - progress * 0.1),
                    ],
                  ),
                ),
                child: _buildSurfacingContent(context, progress),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSurfacingContent(BuildContext context, double progress) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated surfacing icon
          Transform.scale(
            scale: 1.0 + (1.0 - progress) * 0.5,
            child: Icon(
              Icons.keyboard_double_arrow_up,
              size: ResponsiveHelper.getIconSize(context, 'large') + 
                    (1.0 - progress) * ResponsiveHelper.getResponsiveSpacing(context, 'navigation'),
              color: Colors.white.withValues(alpha: 1.0 - progress),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card') + 
                              (1.0 - progress) * ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
          
          // Animated expedition complete text
          Transform.scale(
            scale: 1.0 + (1.0 - progress) * 0.2,
            child: Text(
              widget.expeditionResult.hasSignificantAccomplishments
                  ? '🏆 SURFACING WITH DISCOVERIES! 🏆'
                  : '🌊 SURFACING FROM EXPEDITION 🌊',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle') + 
                          (1.0 - progress) * ResponsiveHelper.getResponsiveFontSize(context, 'navigation'),
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 1.0 - progress),
                letterSpacing: 2.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Depth indicator with fade
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation') + 
                              (1.0 - progress) * ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
          
          if (widget.expeditionResult.sessionDepthReached > 0)
            FadeTransition(
              opacity: AlwaysStoppedAnimation(1.0 - progress),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(context, 'card'), 
                  vertical: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.cyan.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.straighten, color: Colors.cyan, 
                         size: ResponsiveHelper.getIconSize(context, 'small')),
                    SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
                    Text(
                      '${widget.expeditionResult.depthDescription}: ${widget.expeditionResult.sessionDepthReached.toStringAsFixed(1)}m',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Floating bubbles effect during surfacing
          if (progress < 0.8)
            CustomPaint(
              size: const Size(200, 100),
              painter: _BubbleEffectPainter(
                progress: progress,
                bubbleCount: (widget.celebrationConfig.intensity.index * 5 + 5),
              ),
            ),
        ],
      ),
    );
  }

  Color _getDepthColor(double depth) {
    if (depth > 100) return const Color(0xFF000033); // Abyssal zone - very dark blue
    if (depth > 50) return const Color(0xFF0B1426);  // Deep ocean - dark blue
    if (depth > 20) return const Color(0xFF1B4D72);  // Mid water - medium blue
    if (depth > 5) return const Color(0xFF2E8B57);   // Coral reef - sea green
    return const Color(0xFF4682B4);                  // Shallow - steel blue
  }
}

/// Custom painter for bubble effects during surfacing animation
class _BubbleEffectPainter extends CustomPainter {
  final double progress;
  final int bubbleCount;

  _BubbleEffectPainter({
    required this.progress,
    required this.bubbleCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.6)
      ..blendMode = BlendMode.screen;
    
    // Use a fixed seed for consistent bubble patterns
    final random = _FixedRandom(123);
    
    for (int i = 0; i < bubbleCount; i++) {
      final bubbleProgress = (progress + (i * 0.1)) % 1.0;
      final bubbleLifetime = Curves.easeOut.transform(bubbleProgress);
      
      // Bubble position - rising effect
      final startX = random.nextDouble() * size.width;
      final endX = startX + (random.nextDouble() - 0.5) * 30;
      final x = startX + (endX - startX) * bubbleLifetime;
      final y = size.height - (size.height * bubbleLifetime);
      
      // Bubble size and opacity
      final bubbleSize = (2.0 + random.nextDouble() * 4.0) * (1.0 - bubbleLifetime * 0.3);
      final alpha = (1.0 - bubbleLifetime).clamp(0.0, 1.0) * 0.6;
      
      paint.color = Colors.cyan.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), bubbleSize, paint);
      
      // Add inner highlight for bubble effect
      paint.color = Colors.white.withValues(alpha: alpha * 0.5);
      canvas.drawCircle(Offset(x - bubbleSize * 0.3, y - bubbleSize * 0.3), bubbleSize * 0.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubbleEffectPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

/// Simple random number generator with fixed seed for consistent animations
class _FixedRandom {
  int _seed;

  _FixedRandom(this._seed);

  double nextDouble() {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed / 0x7fffffff;
  }
}