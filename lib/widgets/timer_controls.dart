import 'package:flutter/material.dart';
import '../services/ui_sound_service.dart';

class ElasticPlayButton extends StatefulWidget {
  final bool isRunning;
  final VoidCallback onTap;
  final bool isStudySession;

  const ElasticPlayButton({
    super.key,
    required this.isRunning,
    required this.onTap,
    required this.isStudySession,
  });

  @override
  State<ElasticPlayButton> createState() => _ElasticPlayButtonState();
}

class _ElasticPlayButtonState extends State<ElasticPlayButton> 
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _iconController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconScaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Scale animation controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Icon transition controller
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Elastic scale animation: 1.0 -> 0.85 -> 1.15 -> 1.0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.85)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.85, end: 1.15)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(_scaleController);
    
    // Icon scale animation for icon switching
    _iconScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    // Play UI sound (the timer toggle already handles timer start/pause sounds)
    UISoundService.instance.buttonTap();
    
    // Play elastic scale animation
    _scaleController.forward().then((_) {
      _scaleController.reset();
    });
    
    // Play icon animation
    _iconController.forward().then((_) {
      _iconController.reverse();
    });
    
    // Execute the onTap callback
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _iconScaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _handleTap,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Transform.scale(
                scale: _iconScaleAnimation.value,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.elasticOut,
                  switchOutCurve: Curves.easeInBack,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    widget.isRunning ? Icons.pause : Icons.play_arrow,
                    key: ValueKey(widget.isRunning),
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Compact Streak Bar widget to match the level bar style
class CompactStreakBar extends StatefulWidget {
  final int streakCount;
  
  const CompactStreakBar({
    super.key,
    required this.streakCount,
  });
  
  @override
  State<CompactStreakBar> createState() => _CompactStreakBarState();
}

class _CompactStreakBarState extends State<CompactStreakBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }
  
  Color _getStreakColor() {
    if (widget.streakCount >= 30) return Colors.orange;
    if (widget.streakCount >= 14) return Colors.red;
    if (widget.streakCount >= 7) return Colors.purple;
    if (widget.streakCount >= 3) return Colors.green;
    if (widget.streakCount >= 1) return Colors.blue;
    return Colors.grey;
  }
  
  String _getStreakEmoji() {
    if (widget.streakCount >= 30) return '🔥';
    if (widget.streakCount >= 14) return '⚡';
    if (widget.streakCount >= 7) return '💜';
    if (widget.streakCount >= 3) return '✨';
    if (widget.streakCount >= 1) return '🌟';
    return '💤';
  }
  
  @override
  Widget build(BuildContext context) {
    final streakColor = _getStreakColor();
    
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 110,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: streakColor.withValues(alpha: 0.3 * _glowAnimation.value),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Streak emoji badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: streakColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    _getStreakEmoji(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                
                // Streak text
                Text(
                  '${widget.streakCount} ${widget.streakCount == 1 ? 'day' : 'days'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        color: Colors.black38,
                      ),
                    ],
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