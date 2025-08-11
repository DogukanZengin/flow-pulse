import 'package:flutter/material.dart';
import 'dart:math' as math;

enum BreathingPhase {
  inhale,
  hold,
  exhale,
  pause,
}

class BreathingExercise extends StatefulWidget {
  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int pauseSeconds;
  final Color primaryColor;
  final Color secondaryColor;
  final VoidCallback? onComplete;

  const BreathingExercise({
    super.key,
    this.inhaleSeconds = 4,
    this.holdSeconds = 4,
    this.exhaleSeconds = 4,
    this.pauseSeconds = 4,
    required this.primaryColor,
    required this.secondaryColor,
    this.onComplete,
  });

  @override
  State<BreathingExercise> createState() => _BreathingExerciseState();
}

class _BreathingExerciseState extends State<BreathingExercise>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _circleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Color?> _colorAnimation;
  
  BreathingPhase _currentPhase = BreathingPhase.inhale;
  int _cycleCount = 0;
  int _remainingSeconds = 4;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startBreathingCycle();
  }
  
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(seconds: _getTotalCycleDuration()),
      vsync: this,
    );
    
    _circleController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    
    _scaleAnimation = Tween<double>(
      begin: 0.6,
      end: 1.4,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: _createBreathingCurve(),
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _colorAnimation = ColorTween(
      begin: widget.primaryColor,
      end: widget.secondaryColor,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  Curve _createBreathingCurve() {
    final totalDuration = _getTotalCycleDuration();
    final inhaleEnd = widget.inhaleSeconds / totalDuration;
    final holdEnd = (widget.inhaleSeconds + widget.holdSeconds) / totalDuration;
    final exhaleEnd = (widget.inhaleSeconds + widget.holdSeconds + widget.exhaleSeconds) / totalDuration;
    
    return Interval(0.0, 1.0, curve: _BreathingCurve(
      inhaleEnd: inhaleEnd,
      holdEnd: holdEnd,
      exhaleEnd: exhaleEnd,
    ));
  }
  
  int _getTotalCycleDuration() {
    return widget.inhaleSeconds + widget.holdSeconds + widget.exhaleSeconds + widget.pauseSeconds;
  }
  
  void _startBreathingCycle() {
    _animationController.addListener(() {
      final progress = _animationController.value;
      final totalDuration = _getTotalCycleDuration();
      final currentSecond = (progress * totalDuration).floor();
      
      BreathingPhase newPhase;
      int phaseSeconds;
      
      if (currentSecond < widget.inhaleSeconds) {
        newPhase = BreathingPhase.inhale;
        phaseSeconds = widget.inhaleSeconds - currentSecond;
      } else if (currentSecond < widget.inhaleSeconds + widget.holdSeconds) {
        newPhase = BreathingPhase.hold;
        phaseSeconds = (widget.inhaleSeconds + widget.holdSeconds) - currentSecond;
      } else if (currentSecond < widget.inhaleSeconds + widget.holdSeconds + widget.exhaleSeconds) {
        newPhase = BreathingPhase.exhale;
        phaseSeconds = (widget.inhaleSeconds + widget.holdSeconds + widget.exhaleSeconds) - currentSecond;
      } else {
        newPhase = BreathingPhase.pause;
        phaseSeconds = totalDuration - currentSecond;
      }
      
      if (newPhase != _currentPhase || phaseSeconds != _remainingSeconds) {
        setState(() {
          _currentPhase = newPhase;
          _remainingSeconds = phaseSeconds;
        });
      }
    });
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _cycleCount++;
        });
        _animationController.reset();
        _animationController.forward();
      }
    });
    
    _animationController.forward();
  }
  
  String get _phaseText {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return 'Breathe In';
      case BreathingPhase.hold:
        return 'Hold';
      case BreathingPhase.exhale:
        return 'Breathe Out';
      case BreathingPhase.pause:
        return 'Pause';
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _circleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.primaryColor.withOpacity(0.1),
            widget.secondaryColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Breathing Exercise',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: widget.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Cycle ${_cycleCount + 1}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: widget.primaryColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 40),
          
          // Animated breathing circle
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulsing ring
                    AnimatedBuilder(
                      animation: _circleController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (math.sin(_circleController.value * 2 * math.pi) * 0.05),
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _colorAnimation.value?.withOpacity(0.3) ?? widget.primaryColor.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Main breathing circle
                    Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _colorAnimation.value?.withOpacity(_opacityAnimation.value) ??
                              widget.primaryColor.withOpacity(_opacityAnimation.value),
                          boxShadow: [
                            BoxShadow(
                              color: _colorAnimation.value?.withOpacity(0.3) ?? widget.primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _remainingSeconds.toString(),
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
          Text(
            _phaseText,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: widget.primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${widget.inhaleSeconds}s in • ${widget.holdSeconds}s hold • ${widget.exhaleSeconds}s out • ${widget.pauseSeconds}s pause',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: widget.primaryColor.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BreathingCurve extends Curve {
  final double inhaleEnd;
  final double holdEnd;
  final double exhaleEnd;
  
  const _BreathingCurve({
    required this.inhaleEnd,
    required this.holdEnd,
    required this.exhaleEnd,
  });
  
  @override
  double transformInternal(double t) {
    if (t <= inhaleEnd) {
      // Inhale: smooth increase from 0.6 to 1.4
      return Curves.easeInOut.transform(t / inhaleEnd);
    } else if (t <= holdEnd) {
      // Hold: stay at maximum
      return 1.0;
    } else if (t <= exhaleEnd) {
      // Exhale: smooth decrease from 1.4 to 0.6
      final exhaleProgress = (t - holdEnd) / (exhaleEnd - holdEnd);
      return 1.0 - Curves.easeInOut.transform(exhaleProgress);
    } else {
      // Pause: stay at minimum
      return 0.0;
    }
  }
}