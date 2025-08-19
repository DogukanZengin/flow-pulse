import 'package:flutter/material.dart';

/// Efficient timer display widget that uses ValueListenableBuilder
/// to avoid unnecessary rebuilds during timer updates
class TimerDisplay extends StatelessWidget {
  final ValueNotifier<int> secondsNotifier;
  final TextStyle? style;
  final Color? color;
  final double? fontSize;

  const TimerDisplay({
    super.key,
    required this.secondsNotifier,
    this.style,
    this.color,
    this.fontSize,
  });

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ValueListenableBuilder<int>(
        valueListenable: secondsNotifier,
        builder: (context, seconds, child) {
          return Text(
            _formatTime(seconds),
            style: style ??
                TextStyle(
                  color: color ?? Colors.white,
                  fontSize: fontSize ?? 16,
                  fontWeight: FontWeight.bold,
                ),
          );
        },
      ),
    );
  }
}

/// Efficient timer progress indicator that uses ValueListenableBuilder
class TimerProgressIndicator extends StatelessWidget {
  final ValueNotifier<int> secondsRemainingNotifier;
  final int totalSeconds;
  final Color? color;
  final Color? backgroundColor;
  final double strokeWidth;

  const TimerProgressIndicator({
    super.key,
    required this.secondsRemainingNotifier,
    required this.totalSeconds,
    this.color,
    this.backgroundColor,
    this.strokeWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ValueListenableBuilder<int>(
        valueListenable: secondsRemainingNotifier,
        builder: (context, secondsRemaining, child) {
          final progress = totalSeconds > 0 
              ? (secondsRemaining / totalSeconds).clamp(0.0, 1.0) 
              : 0.0;
          
          return CircularProgressIndicator(
            value: progress,
            strokeWidth: strokeWidth,
            color: color ?? Colors.white,
            backgroundColor: backgroundColor ?? Colors.white.withAlpha(51),
          );
        },
      ),
    );
  }
}

/// Efficient linear progress bar that uses ValueListenableBuilder
class TimerProgressBar extends StatelessWidget {
  final ValueNotifier<int> secondsRemainingNotifier;
  final int totalSeconds;
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final double width;

  const TimerProgressBar({
    super.key,
    required this.secondsRemainingNotifier,
    required this.totalSeconds,
    this.color,
    this.backgroundColor,
    this.height = 3.0,
    this.width = 150.0,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ValueListenableBuilder<int>(
        valueListenable: secondsRemainingNotifier,
        builder: (context, secondsRemaining, child) {
          final progress = totalSeconds > 0 
              ? (secondsRemaining / totalSeconds).clamp(0.0, 1.0) 
              : 0.0;
          
          final urgencyColor = secondsRemaining < 60 
            ? Colors.red 
            : secondsRemaining < 300 
              ? Colors.orange 
              : (color ?? Colors.lightBlue);
          
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height),
              color: backgroundColor ?? Colors.white.withAlpha(51),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height),
                  gradient: LinearGradient(
                    colors: [
                      urgencyColor,
                      urgencyColor.withAlpha(179),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}