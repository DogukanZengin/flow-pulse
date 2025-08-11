import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math' as math;
import 'providers/theme_provider.dart';
import 'providers/timer_provider.dart';
import 'screens/settings_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/tasks_screen.dart';
import 'services/database_service.dart';
import 'models/session.dart';
import 'widgets/audio_controls.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FlowPulseApp());
}

class FlowPulseApp extends StatelessWidget {
  const FlowPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider()..loadTheme(),
        ),
        ChangeNotifierProvider(
          create: (context) => TimerProvider()..loadSettings(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'FlowPulse',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const TimerScreen(),
      const TasksScreen(),
      const AnalyticsScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timer),
            selectedIcon: Icon(Icons.timer),
            label: 'Timer',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt),
            selectedIcon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
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
  
  late AnimationController _progressAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  
  Timer? _timer;
  bool _isRunning = false;
  bool _isStudySession = true;
  int _secondsRemaining = 0;
  int _completedSessions = 0;
  DateTime? _sessionStartTime;
  Map<String, dynamic>? _todayStats;
  
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTimer();
      _loadTodayStats();
    });
    
    _progressAnimationController = AnimationController(
      duration: const Duration(seconds: 1500), // Will be updated dynamically
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

  void _initializeTimer() {
    final timerProvider = context.read<TimerProvider>();
    setState(() {
      _secondsRemaining = timerProvider.focusDuration * 60;
    });
  }

  Future<void> _loadTodayStats() async {
    final stats = await DatabaseService.getStatistics();
    if (mounted) {
      setState(() {
        _todayStats = stats;
      });
    }
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
    _sessionStartTime = DateTime.now();
    
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
    final timerProvider = context.read<TimerProvider>();
    
    // Save incomplete session if timer was running
    if (_isRunning && _sessionStartTime != null) {
      _saveSession(completed: false);
    }
    
    setState(() {
      _timer?.cancel();
      _isRunning = false;
      _sessionStartTime = null;
      _secondsRemaining = _isStudySession 
          ? timerProvider.focusDuration * 60 
          : (_shouldUseLongBreak() ? timerProvider.longBreakDuration * 60 : timerProvider.breakDuration * 60);
      _progressAnimationController.reset();
    });
  }

  bool _shouldUseLongBreak() {
    final timerProvider = context.read<TimerProvider>();
    return _completedSessions > 0 && _completedSessions % timerProvider.sessionsUntilLongBreak == 0;
  }
  
  void _completeSession() {
    final timerProvider = context.read<TimerProvider>();
    _timer?.cancel();
    
    // Save completed session
    _saveSession(completed: true);
    
    setState(() {
      _isRunning = false;
      if (_isStudySession) {
        _completedSessions++;
      }
      _isStudySession = !_isStudySession;
      _secondsRemaining = _isStudySession 
          ? timerProvider.focusDuration * 60 
          : (_shouldUseLongBreak() ? timerProvider.longBreakDuration * 60 : timerProvider.breakDuration * 60);
      _progressAnimationController.reset();
      _sessionStartTime = null;
    });
    
    // Refresh stats after completing session
    _loadTodayStats();
    
    _showSessionCompleteDialog();
  }

  Future<void> _saveSession({required bool completed}) async {
    if (_sessionStartTime == null) return;

    final endTime = DateTime.now();
    final actualDuration = endTime.difference(_sessionStartTime!).inSeconds;
    
    SessionType sessionType;
    if (_isStudySession) {
      sessionType = SessionType.focus;
    } else {
      sessionType = _shouldUseLongBreak() ? SessionType.longBreak : SessionType.shortBreak;
    }

    final session = Session(
      startTime: _sessionStartTime!,
      endTime: endTime,
      duration: actualDuration,
      type: sessionType,
      completed: completed,
    );

    await DatabaseService.insertSession(session);
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

  String _getSessionTitle() {
    if (_isStudySession) {
      return 'Focus Time';
    } else {
      return _shouldUseLongBreak() ? 'Long Break' : 'Break Time';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timerProvider = context.watch<TimerProvider>();
    
    final totalSeconds = _isStudySession 
        ? timerProvider.focusDuration * 60 
        : (_shouldUseLongBreak() ? timerProvider.longBreakDuration * 60 : timerProvider.breakDuration * 60);
    final progress = totalSeconds > 0 ? (_secondsRemaining / totalSeconds).clamp(0.0, 1.0) : 0.0;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'FlowPulse',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                _getSessionTitle(),
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _isStudySession 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.secondary,
                ),
              ),
              if (_todayStats != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatChip(
                      icon: Icons.access_time,
                      label: _formatTime(_todayStats!['todayFocusTime'] ?? 0),
                      tooltip: 'Today\'s focus time',
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      icon: Icons.local_fire_department,
                      label: '${_todayStats!['currentStreak'] ?? 0}',
                      tooltip: 'Current streak',
                    ),
                  ],
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
              const SizedBox(height: 40),
              const AudioControls(),
              const SizedBox(height: 24),
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

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}