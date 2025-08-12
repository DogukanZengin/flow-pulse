import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'providers/theme_provider.dart';
import 'providers/timer_provider.dart';
import 'screens/settings_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/tasks_screen.dart';
import 'services/database_service.dart';
import 'models/session.dart';
import 'widgets/audio_controls.dart';
import 'widgets/rolling_timer.dart';
import 'widgets/celebration_dialog.dart';
import 'widgets/particle_system.dart';
import 'widgets/gradient_mesh_background.dart';
import 'screens/ambient_mode_screen.dart';
import 'services/ui_sound_service.dart';
import 'services/time_based_theme_service.dart';

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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.timer,
                    label: 'Timer',
                    index: 0,
                    isSelected: _currentIndex == 0,
                    onTap: () => _selectTab(0),
                  ),
                  _NavItem(
                    icon: Icons.task_alt,
                    label: 'Tasks',
                    index: 1,
                    isSelected: _currentIndex == 1,
                    onTap: () => _selectTab(1),
                  ),
                  _NavItem(
                    icon: Icons.analytics,
                    label: 'Analytics',
                    index: 2,
                    isSelected: _currentIndex == 2,
                    onTap: () => _selectTab(2),
                  ),
                  _NavItem(
                    icon: Icons.settings,
                    label: 'Settings',
                    index: 3,
                    isSelected: _currentIndex == 3,
                    onTap: () => _selectTab(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;
    });
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reinitialize timer when TimerProvider settings change
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _reinitializeTimer();
      });
    }
  }

  void _initializeTimer() {
    final timerProvider = context.read<TimerProvider>();
    setState(() {
      _secondsRemaining = timerProvider.focusDuration * 60;
    });
  }

  void _reinitializeTimer() {
    if (!_isRunning) {
      final timerProvider = context.read<TimerProvider>();
      setState(() {
        _secondsRemaining = _isStudySession 
            ? timerProvider.focusDuration * 60
            : (_shouldUseLongBreak() ? timerProvider.longBreakDuration * 60 : timerProvider.breakDuration * 60);
      });
    }
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
        UISoundService.instance.timerStart();
      } else {
        _pauseTimer();
        UISoundService.instance.timerPause();
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
    
    // Play session complete sound
    UISoundService.instance.sessionComplete();
    
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
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => CelebrationDialog(
        isStudySession: _isStudySession,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }
  
  void _enterAmbientMode() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AmbientModeScreen(
          isRunning: _isRunning,
          isStudySession: _isStudySession,
          secondsRemaining: _secondsRemaining,
          progress: 1 - (_secondsRemaining / (context.read<TimerProvider>().focusDuration * 60)),
          sessionTitle: _getSessionTitle(),
          onTap: _toggleTimer,
          onBack: () => Navigator.of(context).pop(),
        ),
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
    final timeColors = TimeBasedThemeService.instance.getTimeBasedColors(_isStudySession);
    
    final totalSeconds = _isStudySession 
        ? timerProvider.focusDuration * 60 
        : (_shouldUseLongBreak() ? timerProvider.longBreakDuration * 60 : timerProvider.breakDuration * 60);
    final progress = totalSeconds > 0 ? (_secondsRemaining / totalSeconds).clamp(0.0, 1.0) : 0.0;
    
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: timeColors.primaryGradient,
          ),
        ),
        child: Stack(
          children: [
            // Gradient mesh background
            if (timerProvider.enableVisualEffects)
              Positioned.fill(
                child: RepaintBoundary(
                  child: GradientMeshBackground(
                    isStudySession: _isStudySession,
                    isEnabled: timerProvider.enableVisualEffects,
                  ),
                ),
              ),
            // Particle system background
            if (timerProvider.enableVisualEffects)
              Positioned.fill(
                child: RepaintBoundary(
                  child: ParticleSystem(
                    isRunning: _isRunning,
                    isStudySession: _isStudySession,
                    screenSize: MediaQuery.of(context).size,
                    timeBasedColors: timeColors.particleColors,
                  ),
                ),
              ),
            Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'FlowPulse',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
              children: [
              Text(
                _getSessionTitle(),
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
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
              const SizedBox(height: 40),
              RepaintBoundary(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: 360,
                        height: 360,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _isRunning ? _pulseAnimation.value : 1.0,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    RepaintBoundary(
                                      child: SizedBox(
                                        width: 280,
                                        height: 280,
                                        child: CustomPaint(
                                          painter: CircularProgressPainter(
                                            progress: progress,
                                            isStudySession: _isStudySession,
                                          ),
                                        ),
                                      ),
                                    ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RollingTimer(
                                  seconds: _secondsRemaining,
                                  textStyle: theme.textTheme.displayLarge?.copyWith(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 64,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(0, 2),
                                        blurRadius: 8,
                                        color: Colors.black.withOpacity(0.4),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isRunning ? 'Stay Focused!' : 'Paused',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(0, 1),
                                        blurRadius: 4,
                                        color: Colors.black.withOpacity(0.3),
                                      ),
                                    ],
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
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _resetTimer,
                      icon: const Icon(Icons.refresh),
                      iconSize: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _enterAmbientMode,
                      icon: const Icon(Icons.fullscreen),
                      iconSize: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _isStudySession 
                            ? [const Color(0xFF6B5B95), const Color(0xFF88B0D3)]
                            : [const Color(0xFFFF6B6B), const Color(0xFFFECA57)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isStudySession 
                              ? const Color(0xFF6B5B95) 
                              : const Color(0xFFFF6B6B)).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: _ElasticPlayButton(
                      isRunning: _isRunning,
                      onTap: _toggleTimer,
                      isStudySession: _isStudySession,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _isStudySession = !_isStudySession;
                          _resetTimer();
                        });
                      },
                      icon: Icon(_isStudySession ? Icons.coffee : Icons.psychology),
                      iconSize: 28,
                      color: Colors.white,
                    ),
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
            ),
          ],
        ),
          ],
        ),
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final bool isStudySession;
  
  CircularProgressPainter({
    required this.progress,
    required this.isStudySession,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 16.0;
    const glowStrokeWidth = 24.0;
    
    // Gradient colors based on session type
    final gradientColors = isStudySession 
        ? [const Color(0xFF6B5B95), const Color(0xFF88B0D3)]
        : [const Color(0xFFFF6B6B), const Color(0xFFFECA57)];
    
    // Background circle with subtle transparency
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    // Glow effect paint
    final glowPaint = Paint()
      ..color = gradientColors[0].withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = glowStrokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    
    // Progress gradient paint
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: gradientColors,
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    // Draw background circle
    canvas.drawCircle(center, radius, backgroundPaint);
    
    if (progress > 0) {
      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;
      
      // Draw glow effect
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
      
      // Draw progress arc with gradient
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isStudySession != isStudySession;
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

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Create elastic animation: 1.0 -> 0.95 -> 1.05 -> 1.0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.95)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.05)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
    ]).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    // Play UI sound and haptic feedback
    UISoundService.instance.navigationSwitch();
    
    // Play elastic animation
    await _animationController.forward();
    _animationController.reset();
    
    // Execute the original onTap callback
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) {
            if (!widget.isSelected) {
              setState(() {});
            }
          },
          onExit: (_) {
            if (!widget.isSelected) {
              setState(() {});
            }
          },
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: _handleTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: widget.isSelected 
                      ? Colors.white.withOpacity(0.3) 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: widget.isSelected ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        widget.icon,
                        color: Colors.white.withOpacity(widget.isSelected ? 1.0 : 0.7),
                        size: widget.isSelected ? 28 : 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: Colors.white.withOpacity(widget.isSelected ? 1.0 : 0.7),
                        fontSize: widget.isSelected ? 12 : 10,
                        fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      child: Text(widget.label),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ElasticPlayButton extends StatefulWidget {
  final bool isRunning;
  final VoidCallback onTap;
  final bool isStudySession;

  const _ElasticPlayButton({
    required this.isRunning,
    required this.onTap,
    required this.isStudySession,
  });

  @override
  State<_ElasticPlayButton> createState() => _ElasticPlayButtonState();
}

class _ElasticPlayButtonState extends State<_ElasticPlayButton> 
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
              width: 96,
              height: 96,
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
                    size: 40,
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