import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/timer_provider.dart';
import '../services/persistence/persistence_service.dart';
import '../widgets/particle_system.dart';
import '../widgets/underwater_environment.dart';
import '../widgets/full_screen_ocean_widget.dart';
import '../services/break_rewards_service.dart';
import '../widgets/research_vessel_deck_widget.dart';
import '../controllers/timer_controller.dart';
import '../controllers/ocean_system_controller.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => TimerScreenState();
}

class TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _progressAnimationController;
  late TimerController _timerController;
  late OceanSystemController _oceanSystemController;
  
  // UI state
  final bool _showingTransition = false;

  @override
  void initState() {
    super.initState();
    
    final timerProvider = context.read<TimerProvider>();
    _oceanSystemController = OceanSystemController();
    _timerController = TimerController(timerProvider, _oceanSystemController.aquarium);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTodayStats();
      _oceanSystemController.initializeOceanSystem();
    });
    
    _progressAnimationController = AnimationController(
      duration: const Duration(seconds: 1500), // Will be updated dynamically
      vsync: this,
    );
    
    // Listen to timer controller changes
    _timerController.addListener(_onTimerUpdate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reinitialize timer when TimerProvider settings change
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _timerController.reinitializeTimer();
      });
    }
  }

  Future<void> _loadTodayStats() async {
    await PersistenceService.instance.sessions.getStatistics();
  }

  void _onTimerUpdate() {
    if (mounted) {
      setState(() {
        // Update progress animation controller
        if (_timerController.isRunning) {
          _progressAnimationController.duration = Duration(seconds: _timerController.secondsRemaining);
          if (!_progressAnimationController.isAnimating) {
            _progressAnimationController.forward();
          }
        } else {
          _progressAnimationController.stop();
        }
      });
    }
  }
  
  @override
  void dispose() {
    _timerController.removeListener(_onTimerUpdate);
    _timerController.dispose();
    _oceanSystemController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }
  
  void _toggleTimer() {
    _timerController.toggleTimer();
  }
  
  
  void _onBreakActivityComplete(String activityType) async {
    _oceanSystemController.addCompletedBreakActivity(activityType);
    
    // Award activity rewards
    final timerProvider = context.read<TimerProvider>();
    final breakDuration = _timerController.completedSessions > 0 && 
        _timerController.completedSessions % timerProvider.sessionsUntilLongBreak == 0
        ? timerProvider.longBreakDuration 
        : timerProvider.breakDuration;
    
    final reward = await BreakRewardsService().completeActivity(activityType, breakDuration);
    
    // Show activity reward feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reward.message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  
  
  
  // Session switching methods
  void _switchToWorkSession() {
    _timerController.switchToWorkSession();
    _oceanSystemController.setOnSurface(false);
  }
  
  void _switchToBreakSession() {
    _timerController.switchToBreakSession();
    _oceanSystemController.setOnSurface(true);
  }
  
  // External control methods for quick actions and deep linking
  void startFocusSession() {
    _timerController.startFocusSession();
  }
  
  void startBreakSession() {
    _timerController.startBreakSession();
  }
  
  void pauseTimer() {
    _timerController.pauseTimer();
  }
  
  void resumeTimer() {
    _timerController.resumeTimer();
  }
  
  void resetTimer() {
    _timerController.resetTimer();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timerProvider = context.watch<TimerProvider>();
    
    // Listen to controllers
    return ListenableBuilder(
      listenable: Listenable.merge([_timerController, _oceanSystemController]),
      builder: (context, child) {
        // Use consistent ocean theme colors
        final oceanGradientColors = _timerController.isStudySession 
          ? [const Color(0xFF1B4D72), const Color(0xFF2E86AB)] // Deep ocean focus
          : [const Color(0xFF48A38A), const Color(0xFF81C7D4)]; // Light ocean break
        final oceanParticleColors = [
          Colors.blue.shade200,
          Colors.cyan.shade200, 
          Colors.teal.shade200,
        ];
        
        final totalSeconds = _timerController.isStudySession 
            ? timerProvider.focusDuration * 60 
            : (_timerController.completedSessions > 0 && 
               _timerController.completedSessions % timerProvider.sessionsUntilLongBreak == 0 
               ? timerProvider.longBreakDuration * 60 
               : timerProvider.breakDuration * 60);
        final progress = totalSeconds > 0 ? (_timerController.secondsRemaining / totalSeconds).clamp(0.0, 1.0) : 0.0;
        
        return Scaffold(
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: oceanGradientColors,
              ),
            ),
            child: Stack(
              children: [
                // Gradient mesh background
                if (timerProvider.enableVisualEffects)
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: UnderwaterEnvironment(
                        isStudySession: _timerController.isStudySession,
                        isEnabled: timerProvider.enableVisualEffects,
                        aquarium: _oceanSystemController.aquarium,
                        visibleCreatures: _oceanSystemController.visibleCreatures,
                      ),
                    ),
                  ),
                // Particle system background
                if (timerProvider.enableVisualEffects)
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: ParticleSystem(
                        isRunning: _timerController.isRunning,
                        isStudySession: _timerController.isStudySession,
                        screenSize: MediaQuery.of(context).size,
                        timeBasedColors: oceanParticleColors,
                      ),
                    ),
                  ),
                Column(
                  children: [
                    // Compact responsive header
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Compact title
                            Text(
                              'Marine Research',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // iOS-style session type selector
                            Container(
                              height: 44, // Standard iOS touch target height
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B4D72).withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF5DADE2).withValues(alpha: 0.4),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final tabWidth = (constraints.maxWidth - 4) / 2;
                                  return Stack(
                                    children: [
                                      // Sliding indicator background
                                      AnimatedPositioned(
                                        duration: const Duration(milliseconds: 250),
                                        curve: Curves.easeInOut,
                                        left: _timerController.isStudySession ? 2 : 2 + tabWidth,
                                        top: 2,
                                        bottom: 2,
                                        width: tabWidth,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                const Color(0xFF5DADE2).withValues(alpha: 0.9),
                                                const Color(0xFF87CEEB).withValues(alpha: 0.8),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF5DADE2).withValues(alpha: 0.3),
                                                blurRadius: 6,
                                                spreadRadius: 1,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  // Tab buttons
                                  Row(
                                    children: [
                                      // Dive session button
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => _switchToWorkSession(),
                                          child: SizedBox(
                                            height: 44,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.scuba_diving,
                                                  color: _timerController.isStudySession 
                                                      ? const Color(0xFF1B4D72)
                                                      : Colors.white.withValues(alpha: 0.8),
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Dive',
                                                  style: TextStyle(
                                                    color: _timerController.isStudySession 
                                                        ? const Color(0xFF1B4D72)
                                                        : Colors.white.withValues(alpha: 0.8),
                                                    fontWeight: _timerController.isStudySession 
                                                        ? FontWeight.w600 
                                                        : FontWeight.w500,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      // Break session button
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => _switchToBreakSession(),
                                          child: SizedBox(
                                            height: 44,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.deck,
                                                  color: !_timerController.isStudySession 
                                                      ? const Color(0xFF1B4D72)
                                                      : Colors.white.withValues(alpha: 0.8),
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Break',
                                                  style: TextStyle(
                                                    color: !_timerController.isStudySession 
                                                        ? const Color(0xFF1B4D72)
                                                        : Colors.white.withValues(alpha: 0.8),
                                                    fontWeight: !_timerController.isStudySession 
                                                        ? FontWeight.w600 
                                                        : FontWeight.w500,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Full-screen marine biology research station or research vessel deck
                    Expanded(
                      child: _showingTransition 
                          ? Container() // Transition animation will overlay
                          : _oceanSystemController.isOnSurface && !_timerController.isStudySession
                              ? (_oceanSystemController.aquarium != null 
                                  ? ResearchVesselDeckWidget(
                                      aquarium: _oceanSystemController.aquarium!,
                                      secondsRemaining: _timerController.secondsRemaining,
                                      totalBreakSeconds: totalSeconds,
                                      isRunning: _timerController.isRunning,
                                      recentDiscoveries: _oceanSystemController.visibleCreatures.where((c) => c.isDiscovered).toList(),
                                      onTap: _toggleTimer,
                                      onActivityComplete: _onBreakActivityComplete,
                                    )
                                  : Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0xFF87CEEB),
                                            Color(0xFFFFF8DC),
                                            Color(0xFF00BFFF),
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ))
                              : (_oceanSystemController.aquarium != null
                                  ? FullScreenOceanWidget(
                                      aquarium: _oceanSystemController.aquarium!,
                                      sessionProgress: 1.0 - progress, // Invert for depth progression
                                      isRunning: _timerController.isRunning,
                                      isStudySession: _timerController.isStudySession,
                                      visibleCreatures: _oceanSystemController.visibleCreatures,
                                      visibleCorals: _oceanSystemController.visibleCorals,
                                      secondsRemaining: _timerController.secondsRemaining,
                                      totalSessionSeconds: totalSeconds,
                                      onTap: _toggleTimer,
                                      // Pass ValueNotifiers for efficient timer updates
                                      secondsRemainingNotifier: _timerController.secondsRemainingNotifier,
                                      isRunningNotifier: _timerController.isRunningNotifier,
                                    )
                                  : Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0xFF87CEEB),
                                            Color(0xFF00A6D6),
                                            Color(0xFF006994),
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}