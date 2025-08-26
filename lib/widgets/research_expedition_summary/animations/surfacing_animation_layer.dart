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
  
  
  // Cache expensive calculations
  late double _largeIconSize;
  late double _navigationSpacing;
  late double _cardSpacing;
  late double _subtitleFontSize;
  late double _bodyFontSize;
  late double _smallIconSize;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache ResponsiveHelper calculations once
    _largeIconSize = ResponsiveHelper.getIconSize(context, 'large');
    _navigationSpacing = ResponsiveHelper.getResponsiveSpacing(context, 'navigation');
    _cardSpacing = ResponsiveHelper.getResponsiveSpacing(context, 'card');
    _subtitleFontSize = ResponsiveHelper.getResponsiveFontSize(context, 'subtitle');
    _bodyFontSize = ResponsiveHelper.getResponsiveFontSize(context, 'body');
    _smallIconSize = ResponsiveHelper.getIconSize(context, 'small');
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
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: widget.controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));


  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Stack(
              children: [
                // Background elements with slide animation
                SlideTransition(
                  position: _surfacingAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildSurfacingBackground(context),
                  ),
                ),
                // Static text - no slide animation, just fade
                Center(
                  child: _buildSimpleExpeditionText(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSurfacingBackground(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        final progress = widget.controller.value;
        final inverseProgress = 1.0 - progress;
        
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
              colors: [
                _getDepthColor(widget.expeditionResult.sessionDepthReached)
                    .withValues(alpha: 0.9 * inverseProgress),
                const Color(0xFF1B4D72).withValues(alpha: 0.7 * inverseProgress),
                Colors.blue.withValues(alpha: 0.5 * inverseProgress),
                Colors.lightBlue.withValues(alpha: 0.3 * inverseProgress),
                Colors.cyan.withValues(alpha: 0.1 * inverseProgress),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Optimized surfacing icon
                Icon(
                  Icons.keyboard_double_arrow_up,
                  size: _largeIconSize + inverseProgress * _navigationSpacing,
                  color: Colors.white.withValues(alpha: inverseProgress),
                ),
                
                SizedBox(height: _cardSpacing + inverseProgress * _navigationSpacing),
          
                // Optimized depth indicator
                if (widget.expeditionResult.sessionDepthReached > 0 && inverseProgress > 0.1)
                  Opacity(
                    opacity: inverseProgress,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: _cardSpacing,
                        vertical: _navigationSpacing,
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
                          Icon(Icons.straighten, color: Colors.cyan, size: _smallIconSize),
                          SizedBox(width: _navigationSpacing),
                          Text(
                            '${widget.expeditionResult.depthDescription}: ${widget.expeditionResult.sessionDepthReached.toStringAsFixed(1)}m',
                            style: TextStyle(
                              fontSize: _bodyFontSize,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Optimized bubble effects
                if (progress < 0.8)
                  RepaintBoundary(
                    child: CustomPaint(
                      size: const Size(200, 100),
                      painter: _BubbleEffectPainter(
                        progress: progress,
                        bubbleCount: widget.celebrationConfig.intensity.index * 3 + 3, // Reduced count
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

  /// Simple text widget - just reveal and disappear with layer
  Widget _buildSimpleExpeditionText(BuildContext context) {
    final text = widget.expeditionResult.hasSignificantAccomplishments
        ? '🏆 SURFACING WITH DISCOVERIES! 🏆'
        : '🌊 SURFACING FROM EXPEDITION 🌊';
    
    return Text(
      text,
      style: TextStyle(
        fontSize: _subtitleFontSize,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: 2.0,
        shadows: const [
          // Text shadow for depth
          Shadow(
            color: Colors.black54,
            offset: Offset(2, 2),
            blurRadius: 4,
          ),
          // Subtle colored shadow for atmosphere
          Shadow(
            color: Colors.cyan,
            offset: Offset(-1, -1),
            blurRadius: 8,
          ),
        ],
      ),
      textAlign: TextAlign.center,
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
    if (bubbleCount <= 0) return;
    
    final paint = Paint()..blendMode = BlendMode.screen;
    final highlightPaint = Paint()..blendMode = BlendMode.screen;
    
    // Use a fixed seed for consistent bubble patterns
    final random = _FixedRandom(123);
    
    // Pre-calculate common values
    final sizeHeight = size.height;
    final sizeWidth = size.width;
    
    for (int i = 0; i < bubbleCount; i++) {
      final bubbleProgress = (progress + (i * 0.15)) % 1.0;
      if (bubbleProgress > 0.95) continue; // Skip bubbles that are almost gone
      
      final bubbleLifetime = bubbleProgress * bubbleProgress; // Optimized curve
      final lifetimeInverse = 1.0 - bubbleLifetime;
      
      if (lifetimeInverse < 0.05) continue; // Skip nearly invisible bubbles
      
      // Bubble position - rising effect
      final startX = random.nextDouble() * sizeWidth;
      final endX = startX + (random.nextDouble() - 0.5) * 25; // Reduced movement
      final x = startX + (endX - startX) * bubbleLifetime;
      final y = sizeHeight - (sizeHeight * bubbleLifetime);
      
      // Early exit if bubble is off-screen
      if (x < -10 || x > sizeWidth + 10 || y < -10 || y > sizeHeight + 10) continue;
      
      // Bubble size and opacity
      final bubbleSize = (1.5 + random.nextDouble() * 3.0) * (1.0 - bubbleLifetime * 0.2); // Slightly smaller
      final alpha = lifetimeInverse * 0.5; // Reduced opacity
      
      if (alpha < 0.05 || bubbleSize < 0.5) continue; // Skip tiny/invisible bubbles
      
      // Draw main bubble
      paint.color = Colors.cyan.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), bubbleSize, paint);
      
      // Simplified highlight (only for larger bubbles)
      if (bubbleSize > 2.0) {
        highlightPaint.color = Colors.white.withValues(alpha: alpha * 0.3);
        canvas.drawCircle(Offset(x - bubbleSize * 0.25, y - bubbleSize * 0.25), bubbleSize * 0.15, highlightPaint);
      }
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