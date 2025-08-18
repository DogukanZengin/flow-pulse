import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:ui';
import 'providers/theme_provider.dart';
import 'providers/timer_provider.dart';
import 'screens/settings_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/enhanced_ocean_debug_screen.dart';
import 'services/database_service.dart';
import 'models/session.dart';
import 'widgets/celebration_dialog.dart';
import 'widgets/particle_system.dart';
import 'widgets/underwater_environment.dart';
import 'screens/ambient_mode_screen.dart';
import 'services/ui_sound_service.dart';
import 'services/time_based_theme_service.dart';
import 'services/gamification_service.dart';
import 'services/notification_service.dart';
import 'services/quick_actions_service.dart';
import 'services/deep_linking_service.dart';
import 'services/live_activities_service.dart';
import 'widgets/full_screen_ocean_widget.dart';
import 'models/aquarium.dart';
import 'models/creature.dart';
import 'models/coral.dart';
import 'services/creature_service.dart';
import 'widgets/creature_discovery_animation.dart';
import 'services/ocean_activity_service.dart';
import 'services/ocean_audio_service.dart';
import 'services/break_rewards_service.dart';
import 'widgets/research_vessel_deck_widget.dart';
import 'widgets/surface_transition_animation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize core services
  await GamificationService.instance.initialize();
  await BreakRewardsService().initialize();
  
  // Mobile-only services
  if (!kIsWeb) {
    await NotificationService().initialize();
    await QuickActionsService().initialize();
    await DeepLinkingService().initialize();
    await LiveActivitiesService().initialize();
  }
  
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
  final GlobalKey<_TimerScreenState> _timerKey = GlobalKey<_TimerScreenState>();

  @override
  void initState() {
    super.initState();
    _screens = [
      TimerScreen(key: _timerKey),
      const TasksScreen(),
      const AnalyticsScreen(),
      const EnhancedOceanDebugScreen(),
      const SettingsScreen(),
    ];
    
    // Set up quick actions and deep linking callbacks
    _setupQuickActions();
    _setupDeepLinking();
  }
  
  void _setupQuickActions() {
    QuickActionsService().setActionCallback((action) {
      _handleAction(action);
    });
  }
  
  void _setupDeepLinking() {
    DeepLinkingService().setLinkCallback((action) {
      _handleAction(action);
    });
  }
  
  void _handleAction(String action) {
    switch (action) {
      case 'start_focus':
        setState(() => _currentIndex = 0);
        _timerKey.currentState?.startFocusSession();
        break;
      case 'start_break':
        setState(() => _currentIndex = 0);
        _timerKey.currentState?.startBreakSession();
        break;
      case 'pause_timer':
        _timerKey.currentState?.pauseTimer();
        break;
      case 'resume_timer':
        _timerKey.currentState?.resumeTimer();
        break;
      case 'reset_timer':
        _timerKey.currentState?.resetTimer();
        break;
      case 'view_stats':
        setState(() => _currentIndex = 2);
        break;
      case 'ambient_mode':
        setState(() => _currentIndex = 0);
        _timerKey.currentState?.enterAmbientMode();
        break;
    }
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
        margin: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.scuba_diving,
                    label: 'Dive',
                    index: 0,
                    isSelected: _currentIndex == 0,
                    onTap: () => _selectTab(0),
                  ),
                  _NavItem(
                    icon: Icons.science,
                    label: 'Research',
                    index: 1,
                    isSelected: _currentIndex == 1,
                    onTap: () => _selectTab(1),
                  ),
                  _NavItem(
                    icon: Icons.analytics,
                    label: 'Data Log',
                    index: 2,
                    isSelected: _currentIndex == 2,
                    onTap: () => _selectTab(2),
                  ),
                  _NavItem(
                    icon: Icons.biotech,
                    label: 'Lab',
                    index: 3,
                    isSelected: _currentIndex == 3,
                    onTap: () => _selectTab(3),
                  ),
                  _NavItem(
                    icon: Icons.settings,
                    label: 'Station',
                    index: 4,
                    isSelected: _currentIndex == 4,
                    onTap: () => _selectTab(4),
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
  
  Timer? _timer;
  bool _isRunning = false;
  bool _isStudySession = true;
  int _secondsRemaining = 0;
  int _completedSessions = 0;
  DateTime? _sessionStartTime;
  Map<String, dynamic>? _todayStats;
  
  // Ocean system state
  Aquarium? _aquarium;
  List<Creature> _visibleCreatures = [];
  List<Coral> _visibleCorals = [];
  
  // Break system state
  bool _showingTransition = false;
  bool _isOnSurface = false; // true when in break mode on vessel deck
  List<String> _completedBreakActivities = [];
  
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTimer();
      _loadTodayStats();
      _initializeOceanSystem();
      _initializeOceanAudio();
    });
    
    _progressAnimationController = AnimationController(
      duration: const Duration(seconds: 1500), // Will be updated dynamically
      vsync: this,
    );
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
  
  Future<void> _initializeOceanAudio() async {
    // Initialize ocean audio with current biome
    final biome = _aquarium?.currentBiome ?? BiomeType.shallowWaters;
    await OceanAudioService.instance.initializeBiomeAudio(biome);
  }

  Future<void> _initializeOceanSystem() async {
    try {
      // Create demo aquarium for the UI integration
      final demoAquarium = Aquarium(
        id: 'demo_aquarium',
        currentBiome: BiomeType.shallowWaters,
        pearlWallet: const PearlWallet(pearls: 150, crystals: 2),
        ecosystemHealth: 0.85,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        lastActiveAt: DateTime.now().subtract(const Duration(hours: 2)),
        unlockedBiomes: const {
          BiomeType.shallowWaters: true,
          BiomeType.coralGarden: true,
        },
        settings: const AquariumSettings(),
        stats: const AquariumStats(
          totalCreaturesDiscovered: 3,
          totalCoralsGrown: 2,
          totalFocusTime: 180,
          currentStreak: 4,
          longestStreak: 7,
        ),
      );
      
      // Create some demo creatures
      final demoCreatures = [
        Creature(
          id: 'clownfish',
          name: 'Clownfish',
          species: 'Amphiprioninae',
          rarity: CreatureRarity.common,
          type: CreatureType.starterFish,
          habitat: BiomeType.shallowWaters,
          animationAsset: 'assets/creatures/clownfish.png',
          pearlValue: 10,
          requiredLevel: 1,
          description: 'A friendly orange fish that lives in sea anemones',
          discoveryChance: 0.7,
          isDiscovered: true,
          discoveredAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Creature(
          id: 'blue_tang',
          name: 'Blue Tang',
          species: 'Paracanthurus hepatus',
          rarity: CreatureRarity.common,
          type: CreatureType.starterFish,
          habitat: BiomeType.shallowWaters,
          animationAsset: 'assets/creatures/blue_tang.png',
          pearlValue: 12,
          requiredLevel: 2,
          description: 'A vibrant blue fish with a peaceful nature',
          discoveryChance: 0.7,
          isDiscovered: true,
          discoveredAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
      
      // Create some demo corals
      final demoCorals = [
        Coral(
          id: 'brain_coral_1',
          type: CoralType.brain,
          stage: CoralStage.mature,
          growthProgress: 0.8,
          plantedAt: DateTime.now().subtract(const Duration(days: 3)),
          lastGrowthAt: DateTime.now().subtract(const Duration(hours: 4)),
          biome: BiomeType.shallowWaters,
          sessionsGrown: 3,
        ),
        Coral(
          id: 'staghorn_coral_1',
          type: CoralType.staghorn,
          stage: CoralStage.flourishing,
          growthProgress: 1.0,
          plantedAt: DateTime.now().subtract(const Duration(days: 2)),
          lastGrowthAt: DateTime.now().subtract(const Duration(hours: 1)),
          biome: BiomeType.shallowWaters,
          sessionsGrown: 4,
          attractedSpecies: ['clownfish'],
        ),
      ];
      
      if (mounted) {
        setState(() {
          _aquarium = demoAquarium;
          _visibleCreatures = demoCreatures;
          _visibleCorals = demoCorals;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing ocean system: $e');
      }
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _progressAnimationController.dispose();
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
    
    // Play ocean audio when session starts
    OceanAudioService.instance.playSessionSound(SessionOceanSound.sessionStart);
    
    // Log coral planting activity for focus sessions
    if (_isStudySession) {
      final coralType = _aquarium?.corals.isNotEmpty == true 
          ? _aquarium!.corals.first.type 
          : CoralType.brain;
      final biome = _aquarium?.currentBiome ?? BiomeType.shallowWaters;
      
      OceanActivityService.logCoralPlanted(
        coralType: coralType,
        biome: biome,
      );
    }
    
    // Show notification with timer controls
    NotificationService().showTimerWithActions(
      title: _getSessionTitle(),
      body: 'Timer running: ${_formatTime(_secondsRemaining)} remaining',
      isRunning: true,
    );
    
    // Schedule background timer check
    NotificationService().scheduleBackgroundTimerCheck(
      durationSeconds: _secondsRemaining,
      isStudySession: _isStudySession,
    );
    
    // Update quick actions
    QuickActionsService().updateShortcuts(
      isTimerRunning: true,
      isStudySession: _isStudySession,
    );
    
    // Start Live Activity (iOS)
    final timerProvider = context.read<TimerProvider>();
    final totalSeconds = _isStudySession 
        ? timerProvider.focusDuration * 60 
        : (_shouldUseLongBreak() ? timerProvider.longBreakDuration * 60 : timerProvider.breakDuration * 60);
    
    LiveActivitiesService().startTimerActivity(
      sessionTitle: _getSessionTitle(),
      totalSeconds: totalSeconds,
      remainingSeconds: _secondsRemaining,
      isStudySession: _isStudySession,
    );
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
          
          // Update notification every 30 seconds to avoid spam
          if (_secondsRemaining % 30 == 0) {
            NotificationService().showTimerWithActions(
              title: _getSessionTitle(),
              body: 'Timer running: ${_formatTime(_secondsRemaining)} remaining',
              isRunning: true,
            );
          }
          
          // Update Live Activity every 10 seconds
          if (_secondsRemaining % 10 == 0) {
            final timerProvider = context.read<TimerProvider>();
            final totalSeconds = _isStudySession 
                ? timerProvider.focusDuration * 60 
                : (_shouldUseLongBreak() ? timerProvider.longBreakDuration * 60 : timerProvider.breakDuration * 60);
            
            LiveActivitiesService().updateTimerActivity(
              sessionTitle: _getSessionTitle(),
              totalSeconds: totalSeconds,
              remainingSeconds: _secondsRemaining,
              isRunning: true,
              isStudySession: _isStudySession,
            );
          }
        } else {
          _completeSession();
        }
      });
    });
  }
  
  void _pauseTimer() {
    _timer?.cancel();
    _progressAnimationController.stop();
    
    // Cancel background timer check
    NotificationService().cancelBackgroundTimerCheck();
    
    // Show paused notification
    NotificationService().showTimerWithActions(
      title: '⏸️ ${_getSessionTitle()} Paused',
      body: 'Tap to resume: ${_formatTime(_secondsRemaining)} remaining',
      isRunning: false,
    );
    
    // Update quick actions
    QuickActionsService().updateShortcuts(
      isTimerRunning: false,
      isStudySession: _isStudySession,
    );
    
    // Update Live Activity to paused state
    final timerProvider = context.read<TimerProvider>();
    final totalSeconds = _isStudySession 
        ? timerProvider.focusDuration * 60 
        : (_shouldUseLongBreak() ? timerProvider.longBreakDuration * 60 : timerProvider.breakDuration * 60);
    
    LiveActivitiesService().pauseTimerActivity(
      sessionTitle: _getSessionTitle(),
      totalSeconds: totalSeconds,
      remainingSeconds: _secondsRemaining,
      isStudySession: _isStudySession,
    );
  }
  
  void _resetTimer() {
    final timerProvider = context.read<TimerProvider>();
    
    // Save incomplete session if timer was running
    if (_isRunning && _sessionStartTime != null) {
      _saveSession(completed: false);
      
      // Log pollution event for abandoned focus session
      if (_isStudySession) {
        OceanActivityService.logPollutionEvent(
          reason: 'Focus session abandoned',
          ecosystemDamage: 0.05, // 5% damage for abandoning
        );
      }
    }
    
    // Cancel notifications and background tasks
    NotificationService().cancelBackgroundTimerCheck();
    NotificationService().cancelAllNotifications();
    
    // End Live Activity
    LiveActivitiesService().endTimerActivity();
    
    setState(() {
      _timer?.cancel();
      _isRunning = false;
      _sessionStartTime = null;
      _secondsRemaining = _isStudySession 
          ? timerProvider.focusDuration * 60 
          : (_shouldUseLongBreak() ? timerProvider.longBreakDuration * 60 : timerProvider.breakDuration * 60);
      _progressAnimationController.reset();
    });
    
    // Update quick actions
    QuickActionsService().updateShortcuts(
      isTimerRunning: false,
      isStudySession: _isStudySession,
    );
  }

  bool _shouldUseLongBreak() {
    final timerProvider = context.read<TimerProvider>();
    return _completedSessions > 0 && _completedSessions % timerProvider.sessionsUntilLongBreak == 0;
  }
  
  void _completeSession() async {
    final timerProvider = context.read<TimerProvider>();
    _timer?.cancel();
    
    // Play session complete sound
    UISoundService.instance.sessionComplete();
    
    // Play ocean audio for session completion
    OceanAudioService.instance.playSessionSound(SessionOceanSound.sessionComplete);
    
    final wasStudySession = _isStudySession;
    
    // Calculate session duration
    final sessionDuration = wasStudySession 
        ? timerProvider.focusDuration 
        : (_shouldUseLongBreak() ? timerProvider.longBreakDuration : timerProvider.breakDuration);
    
    // Check for creature discovery (only for focus sessions)
    Creature? discoveredCreature;
    if (wasStudySession && _aquarium != null) {
      final sessionDepth = CreatureService.calculateSessionDepth(sessionDuration, 1.0);
      discoveredCreature = await CreatureService.checkForCreatureDiscovery(
        aquarium: _aquarium!,
        sessionDurationMinutes: sessionDuration,
        sessionCompleted: true,
        sessionDepth: sessionDepth,
      );
      
      if (discoveredCreature != null) {
        // Add to visible creatures
        final creature = discoveredCreature; // Capture non-null value
        setState(() {
          if (!_visibleCreatures.any((c) => c.id == creature.id)) {
            _visibleCreatures.add(creature);
          }
        });
      }
    }
    
    // Update notification with ocean theme if creature discovered
    final notificationTitle = wasStudySession 
        ? (discoveredCreature != null 
            ? '🐠 New Creature Discovered!' 
            : '🪸 Coral Bloomed Beautifully!')
        : '🌊 Peaceful Currents Restored';
    
    final notificationBody = wasStudySession
        ? (discoveredCreature != null
            ? 'You discovered a ${discoveredCreature.name}! +${discoveredCreature.pearlValue} pearls earned!'
            : 'Your coral garden is growing! Keep focusing to attract marine life.')
        : 'Ready for another dive into deep focus?';
    
    // Show completion notification
    NotificationService().showTimerNotification(
      title: notificationTitle,
      body: notificationBody,
      payload: 'session_completed',
    );
    
    // Award XP and rewards
    final reward = await GamificationService.instance.completeSession(
      durationMinutes: sessionDuration,
      isStudySession: wasStudySession,
    );
    
    // Save completed session
    _saveSession(completed: true);
    
    // Log ocean activity for the session
    if (wasStudySession) {
      // Use first coral in aquarium or default to brain coral
      final coralType = _aquarium?.corals.isNotEmpty == true 
          ? _aquarium!.corals.first.type 
          : CoralType.brain;
      
      await OceanActivityService.logCoralGrowth(
        coralType: coralType,
        finalStage: CoralStage.flourishing,
        sessionDurationMinutes: sessionDuration,
        discoveredCreatures: discoveredCreature != null ? [discoveredCreature] : [],
        pearlsEarned: discoveredCreature?.pearlValue ?? 0,
      );
    }
    
    // Show transition animation before changing session
    setState(() {
      _showingTransition = true;
    });
    
    // Start transition animation
    _showTransitionAnimation(wasStudySession, () {
      setState(() {
        _showingTransition = false;
        _isRunning = false;
        if (wasStudySession) {
          _completedSessions++;
          _isOnSurface = true; // Go to surface for break
        } else {
          _isOnSurface = false; // Return underwater for work
        }
        _isStudySession = !_isStudySession;
        _secondsRemaining = _isStudySession 
            ? timerProvider.focusDuration * 60 
            : (_shouldUseLongBreak() ? timerProvider.longBreakDuration * 60 : timerProvider.breakDuration * 60);
        _progressAnimationController.reset();
        _sessionStartTime = null;
        _completedBreakActivities.clear(); // Reset break activities
      });
      
      // Auto-start next session if enabled
      if ((wasStudySession && timerProvider.autoStartBreaks) || 
          (!wasStudySession && timerProvider.autoStartSessions)) {
        // Wait a moment for the UI to update, then auto-start
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && !_isRunning) {
            _startTimer();
          }
        });
      }
    });
    
    // Update quick actions for new session
    QuickActionsService().updateShortcuts(
      isTimerRunning: false,
      isStudySession: _isStudySession,
    );
    
    // Complete Live Activity
    LiveActivitiesService().completeTimerActivity(
      isStudySession: wasStudySession,
      nextSessionType: _isStudySession ? 'Research Dive' : 'Surface Rest',
    );
    
    // Refresh stats after completing session
    _loadTodayStats();
    
    // Show creature discovery animation if creature was discovered
    if (discoveredCreature != null) {
      _showCreatureDiscoveryAnimation(discoveredCreature);
    } else {
      _showSessionCompleteDialog(reward);
    }
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
  
  void _showSessionCompleteDialog(GamificationReward reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => CelebrationDialog(
        isStudySession: _isStudySession,
        reward: reward,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }
  
  void _showCreatureDiscoveryAnimation(Creature creature) {
    // Play creature discovery sound
    OceanAudioService.instance.playOceanEffect(OceanSoundEffect.creatureDiscover);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => CreatureDiscoveryAnimation(
        creature: creature,
        onComplete: () {
          Navigator.of(context).pop();
          // Show regular completion dialog after creature discovery
          // Create a simple reward for the discovery
          final discoveryReward = GamificationReward()
            ..xpGained = creature.pearlValue * 10 // Convert pearls to XP
            ..currentStreak = GamificationService.instance.currentStreak
            ..newLevel = GamificationService.instance.currentLevel;
          _showSessionCompleteDialog(discoveryReward);
        },
      ),
    );
  }
  
  void _showTransitionAnimation(bool wasStudySession, VoidCallback onComplete) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => SurfaceTransitionAnimation(
        isAscending: wasStudySession, // Ascending after study, descending after break
        duration: const Duration(seconds: 3),
        onComplete: () {
          Navigator.of(context).pop();
          onComplete();
        },
      ),
    );
  }
  
  void _onBreakActivityComplete(String activityType) async {
    if (!_completedBreakActivities.contains(activityType)) {
      _completedBreakActivities.add(activityType);
      
      // Award activity rewards
      final timerProvider = context.read<TimerProvider>();
      final breakDuration = _shouldUseLongBreak() 
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
      return 'Research Dive';
    } else {
      return _shouldUseLongBreak() ? 'Extended Surface Rest' : 'Vessel Deck Break';
    }
  }
  
  // External control methods for quick actions and deep linking
  void startFocusSession() {
    if (!_isStudySession || _isRunning) {
      setState(() {
        _isStudySession = true;
        _resetTimer();
      });
    }
    if (!_isRunning) {
      _toggleTimer();
    }
  }
  
  void startBreakSession() {
    if (_isStudySession || _isRunning) {
      setState(() {
        _isStudySession = false;
        _resetTimer();
      });
    }
    if (!_isRunning) {
      _toggleTimer();
    }
  }
  
  void pauseTimer() {
    if (_isRunning) {
      _toggleTimer();
    }
  }
  
  void resumeTimer() {
    if (!_isRunning) {
      _toggleTimer();
    }
  }
  
  void resetTimer() {
    _resetTimer();
  }
  
  void enterAmbientMode() {
    _enterAmbientMode();
  }
  
  // Session switching methods
  void _switchToWorkSession() {
    if (!_isStudySession && !_isRunning) {
      final timerProvider = context.read<TimerProvider>();
      setState(() {
        _isStudySession = true;
        _isOnSurface = false; // Go underwater for work
        _secondsRemaining = timerProvider.focusDuration * 60;
        _completedBreakActivities.clear();
      });
      
      // Play transition sound
      UISoundService.instance.navigationSwitch();
    }
  }
  
  void _switchToBreakSession() {
    if (_isStudySession && !_isRunning) {
      final timerProvider = context.read<TimerProvider>();
      setState(() {
        _isStudySession = false;
        _isOnSurface = true; // Go to surface for break
        _secondsRemaining = _shouldUseLongBreak() 
            ? timerProvider.longBreakDuration * 60 
            : timerProvider.breakDuration * 60;
        _completedBreakActivities.clear();
      });
      
      // Play transition sound
      UISoundService.instance.navigationSwitch();
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
                  child: UnderwaterEnvironment(
                    isStudySession: _isStudySession,
                    isEnabled: timerProvider.enableVisualEffects,
                    aquarium: _aquarium,
                    visibleCreatures: _visibleCreatures,
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
                    
                    // Compact session type selector
                    Container(
                      height: 40, // Fixed height to prevent overflow
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(26),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withAlpha(51),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Work session button
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _switchToWorkSession(),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: _isStudySession 
                                      ? Colors.white.withAlpha(51)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.scuba_diving,
                                      color: Colors.white.withAlpha(_isStudySession ? 255 : 179),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Dive',
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(_isStudySession ? 255 : 179),
                                          fontWeight: _isStudySession ? FontWeight.bold : FontWeight.normal,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
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
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: !_isStudySession 
                                      ? Colors.white.withAlpha(51)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.deck,
                                      color: Colors.white.withAlpha(!_isStudySession ? 255 : 179),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Break',
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(!_isStudySession ? 255 : 179),
                                          fontWeight: !_isStudySession ? FontWeight.bold : FontWeight.normal,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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
                  : _isOnSurface && !_isStudySession
                      ? (_aquarium != null 
                          ? ResearchVesselDeckWidget(
                              aquarium: _aquarium!,
                              secondsRemaining: _secondsRemaining,
                              totalBreakSeconds: totalSeconds,
                              isRunning: _isRunning,
                              recentDiscoveries: _visibleCreatures.where((c) => c.isDiscovered).toList(),
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
                      : (_aquarium != null
                          ? FullScreenOceanWidget(
                              aquarium: _aquarium!,
                              sessionProgress: 1.0 - progress, // Invert for depth progression
                              isRunning: _isRunning,
                              isStudySession: _isStudySession,
                              visibleCreatures: _visibleCreatures,
                              visibleCorals: _visibleCorals,
                              secondsRemaining: _secondsRemaining,
                              totalSessionSeconds: totalSeconds,
                              onTap: _toggleTimer,
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
                    const SizedBox(height: 2),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: Colors.white.withOpacity(widget.isSelected ? 1.0 : 0.7),
                        fontSize: widget.isSelected ? 11 : 9,
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

// Compact XP Bar widget for positioning above timer
class _CompactXPBar extends StatefulWidget {
  final int currentXP;
  final int currentLevel;
  final double progress;
  
  const _CompactXPBar({
    required this.currentXP,
    required this.currentLevel,
    required this.progress,
  });
  
  @override
  State<_CompactXPBar> createState() => _CompactXPBarState();
}

class _CompactXPBarState extends State<_CompactXPBar>
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
  
  Color _getLevelColor() {
    if (widget.currentLevel >= 25) return Colors.purple;
    if (widget.currentLevel >= 20) return Colors.indigo;
    if (widget.currentLevel >= 15) return Colors.blue;
    if (widget.currentLevel >= 10) return Colors.teal;
    if (widget.currentLevel >= 5) return Colors.green;
    return Colors.lightBlue;
  }
  
  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor();
    
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 140,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.1),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: levelColor.withOpacity(0.3 * _glowAnimation.value),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Progress fill
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: LinearProgressIndicator(
                    value: widget.progress,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      levelColor.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Level badge - blended with background
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: levelColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        'LV${widget.currentLevel}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // XP text
                    Text(
                      '${GamificationService.instance.getCurrentLevelXP()}/${GamificationService.instance.getXPForNextLevel()}',
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
            ],
          ),
        );
      },
    );
  }
}

// Compact Streak Bar widget to match the level bar style
class _CompactStreakBar extends StatefulWidget {
  final int streakCount;
  
  const _CompactStreakBar({
    required this.streakCount,
  });
  
  @override
  State<_CompactStreakBar> createState() => _CompactStreakBarState();
}

class _CompactStreakBarState extends State<_CompactStreakBar>
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
            color: Colors.white.withOpacity(0.1),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: streakColor.withOpacity(0.3 * _glowAnimation.value),
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
                    color: streakColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
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