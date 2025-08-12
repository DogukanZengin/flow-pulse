import 'package:flutter/material.dart';

class RollingTimer extends StatefulWidget {
  final int seconds;
  final TextStyle? textStyle;

  const RollingTimer({
    super.key,
    required this.seconds,
    this.textStyle,
  });

  @override
  State<RollingTimer> createState() => _RollingTimerState();
}

class _RollingTimerState extends State<RollingTimer> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _previousSeconds;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _previousSeconds = widget.seconds;
  }

  @override
  void didUpdateWidget(RollingTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seconds != widget.seconds) {
      _previousSeconds = oldWidget.seconds;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Use a simple crossfade effect for smoother performance
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: Transform.translate(
                offset: Offset(0, -10 * (1 - animation.value)),
                child: child,
              ),
            );
          },
          child: Text(
            _formatTime(widget.seconds),
            key: ValueKey(widget.seconds),
            style: widget.textStyle,
          ),
        );
      },
    );
  }
}