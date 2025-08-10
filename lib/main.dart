import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

void main() {
  runApp(const FlowPulseApp());
}

class FlowPulseApp extends StatelessWidget {
  const FlowPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowPulse',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const TimerScreen(),
    );
  }
}

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  static const int studyDurationMinutes = 25;
  static const int breakDurationMinutes = 5;
  
  late AnimationController _progressAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  
  Timer? _timer;
  bool _isRunning = false;
  bool _isStudySession = true;
  int _secondsRemaining = studyDurationMinutes * 60;
  
  @override
  void initState() {
    super.initState();
    
    _progressAnimationController = AnimationController(
      duration: Duration(seconds: _secondsRemaining),
      vsync: this,
    );
    
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _progressAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }
  
  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _startTimer();
      } else {
        _pauseTimer();
      }
    });
  }
  
  void _startTimer() {
    _progressAnimationController.duration = Duration(seconds: _secondsRemaining);
    _progressAnimationController.forward();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _completeSession();
        }
      });
    });
  }
  
  void _pauseTimer() {
    _timer?.cancel();
    _progressAnimationController.stop();
  }
  
  void _resetTimer() {
    setState(() {
      _timer?.cancel();
      _isRunning = false;
      _secondsRemaining = _isStudySession 
          ? studyDurationMinutes * 60 
          : breakDurationMinutes * 60;
      _progressAnimationController.reset();
    });
  }
  
  void _completeSession() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isStudySession = !_isStudySession;
      _secondsRemaining = _isStudySession 
          ? studyDurationMinutes * 60 
          : breakDurationMinutes * 60;
      _progressAnimationController.reset();
    });
    
    _showSessionCompleteDialog();
  }
  
  void _showSessionCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_isStudySession ? 'Break Complete!' : 'Study Session Complete!'),
        content: Text(
          _isStudySession 
              ? 'Ready to start another study session?' 
              : 'Time for a break!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSeconds = _isStudySession 
        ? studyDurationMinutes * 60 
        : breakDurationMinutes * 60;
    final progress = (_secondsRemaining / totalSeconds).clamp(0.0, 1.0);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                _isStudySession ? 'Focus Time' : 'Break Time',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _isStudySession 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 60),
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isRunning ? _pulseAnimation.value : 1.0,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 280,
                              height: 280,
                              child: CustomPaint(
                                painter: CircularProgressPainter(
                                  progress: progress,
                                  color: _isStudySession 
                                      ? theme.colorScheme.primary 
                                      : theme.colorScheme.secondary,
                                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatTime(_secondsRemaining),
                                  style: theme.textTheme.displayLarge?.copyWith(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 64,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isRunning ? 'Stay Focused!' : 'Paused',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.refresh),
                    iconSize: 32,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 24),
                  FloatingActionButton.large(
                    onPressed: _toggleTimer,
                    backgroundColor: _isStudySession 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.secondary,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        _isRunning ? Icons.pause : Icons.play_arrow,
                        key: ValueKey(_isRunning),
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isStudySession = !_isStudySession;
                        _resetTimer();
                      });
                    },
                    icon: Icon(_isStudySession ? Icons.coffee : Icons.psychology),
                    iconSize: 32,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  
  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 12.0;
    
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }
  
  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}