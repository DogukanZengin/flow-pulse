import 'package:flutter/foundation.dart';
import 'dart:async';
import '../providers/timer_provider.dart';
import '../models/session.dart';
import '../services/database_service.dart';
import '../services/ui_sound_service.dart';
import '../services/gamification_service.dart';
import '../services/notification_service.dart';
import '../services/live_activities_service.dart';
import '../services/ocean_activity_service.dart';
import '../services/ocean_audio_service.dart';
import '../models/coral.dart';
import '../models/aquarium.dart';
import '../models/creature.dart';

class TimerController extends ChangeNotifier {
  Timer? _timer;
  bool _isRunning = false;
  bool _isStudySession = true;
  int _secondsRemaining = 0;
  int _completedSessions = 0;
  DateTime? _sessionStartTime;
  
  // ValueNotifiers for efficient timer updates
  final ValueNotifier<int> _secondsRemainingNotifier = ValueNotifier(0);
  final ValueNotifier<bool> _isRunningNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isStudySessionNotifier = ValueNotifier(true);
  
  // Getters
  bool get isRunning => _isRunning;
  bool get isStudySession => _isStudySession;
  int get secondsRemaining => _secondsRemaining;
  int get completedSessions => _completedSessions;
  DateTime? get sessionStartTime => _sessionStartTime;
  
  // ValueNotifier getters for efficient timer updates
  ValueNotifier<int> get secondsRemainingNotifier => _secondsRemainingNotifier;
  ValueNotifier<bool> get isRunningNotifier => _isRunningNotifier;
  ValueNotifier<bool> get isStudySessionNotifier => _isStudySessionNotifier;
  
  final TimerProvider _timerProvider;
  final Aquarium? _aquarium;
  
  TimerController(this._timerProvider, this._aquarium) {
    _initializeTimer();
    _secondsRemainingNotifier.value = _secondsRemaining;
    _isRunningNotifier.value = _isRunning;
    _isStudySessionNotifier.value = _isStudySession;
  }
  
  void _initializeTimer() {
    _secondsRemaining = _timerProvider.focusDuration * 60;
    _secondsRemainingNotifier.value = _secondsRemaining;
    notifyListeners();
  }
  
  void reinitializeTimer() {
    if (!_isRunning) {
      _secondsRemaining = _isStudySession 
          ? _timerProvider.focusDuration * 60
          : (_shouldUseLongBreak() ? _timerProvider.longBreakDuration * 60 : _timerProvider.breakDuration * 60);
      _secondsRemainingNotifier.value = _secondsRemaining;
      notifyListeners();
    }
  }
  
  bool _shouldUseLongBreak() {
    return _completedSessions > 0 && _completedSessions % _timerProvider.sessionsUntilLongBreak == 0;
  }
  
  void toggleTimer() {
    _isRunning = !_isRunning;
    _isRunningNotifier.value = _isRunning;
    if (_isRunning) {
      _startTimer();
      UISoundService.instance.timerStart();
    } else {
      _pauseTimer();
      UISoundService.instance.timerPause();
    }
    notifyListeners();
  }
  
  void _startTimer() {
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
      body: 'Timer running: ${formatTime(_secondsRemaining)} remaining',
      isRunning: true,
    );
    
    // Schedule background timer check
    NotificationService().scheduleBackgroundTimerCheck(
      durationSeconds: _secondsRemaining,
      isStudySession: _isStudySession,
    );
    
    // Start Live Activity (iOS)
    final totalSeconds = _isStudySession 
        ? _timerProvider.focusDuration * 60 
        : (_shouldUseLongBreak() ? _timerProvider.longBreakDuration * 60 : _timerProvider.breakDuration * 60);
    
    LiveActivitiesService().startTimerActivity(
      sessionTitle: _getSessionTitle(),
      totalSeconds: totalSeconds,
      remainingSeconds: _secondsRemaining,
      isStudySession: _isStudySession,
    );
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        _secondsRemainingNotifier.value = _secondsRemaining;
        
        // Update notification every 30 seconds to avoid spam
        if (_secondsRemaining % 30 == 0) {
          NotificationService().showTimerWithActions(
            title: _getSessionTitle(),
            body: 'Timer running: ${formatTime(_secondsRemaining)} remaining',
            isRunning: true,
          );
        }
        
        // Update Live Activity every 10 seconds
        if (_secondsRemaining % 10 == 0) {
          final totalSeconds = _isStudySession 
              ? _timerProvider.focusDuration * 60 
              : (_shouldUseLongBreak() ? _timerProvider.longBreakDuration * 60 : _timerProvider.breakDuration * 60);
          
          LiveActivitiesService().updateTimerActivity(
            sessionTitle: _getSessionTitle(),
            totalSeconds: totalSeconds,
            remainingSeconds: _secondsRemaining,
            isRunning: true,
            isStudySession: _isStudySession,
          );
        }
        notifyListeners();
      } else {
        _completeSession();
      }
    });
  }
  
  void _pauseTimer() {
    _timer?.cancel();
    
    // Cancel background timer check
    NotificationService().cancelBackgroundTimerCheck();
    
    // Show paused notification
    NotificationService().showTimerWithActions(
      title: '⏸️ ${_getSessionTitle()} Paused',
      body: 'Tap to resume: ${formatTime(_secondsRemaining)} remaining',
      isRunning: false,
    );
    
    // Update Live Activity to paused state
    final totalSeconds = _isStudySession 
        ? _timerProvider.focusDuration * 60 
        : (_shouldUseLongBreak() ? _timerProvider.longBreakDuration * 60 : _timerProvider.breakDuration * 60);
    
    LiveActivitiesService().pauseTimerActivity(
      sessionTitle: _getSessionTitle(),
      totalSeconds: totalSeconds,
      remainingSeconds: _secondsRemaining,
      isStudySession: _isStudySession,
    );
  }
  
  void resetTimer() {
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
    
    _timer?.cancel();
    _isRunning = false;
    _isRunningNotifier.value = _isRunning;
    _sessionStartTime = null;
    _secondsRemaining = _isStudySession 
        ? _timerProvider.focusDuration * 60 
        : (_shouldUseLongBreak() ? _timerProvider.longBreakDuration * 60 : _timerProvider.breakDuration * 60);
    _secondsRemainingNotifier.value = _secondsRemaining;
    
    notifyListeners();
  }
  
  Future<GamificationReward> _completeSession() async {
    _timer?.cancel();
    
    // Play session complete sound
    UISoundService.instance.sessionComplete();
    
    // Play ocean audio for session completion
    OceanAudioService.instance.playSessionSound(SessionOceanSound.sessionComplete);
    
    final wasStudySession = _isStudySession;
    
    // Calculate session duration
    final sessionDuration = wasStudySession 
        ? _timerProvider.focusDuration 
        : (_shouldUseLongBreak() ? _timerProvider.longBreakDuration : _timerProvider.breakDuration);
    
    // Award XP and rewards
    final reward = await GamificationService.instance.completeSession(
      durationMinutes: sessionDuration,
      isStudySession: wasStudySession,
    );
    
    // Save completed session
    await _saveSession(completed: true);
    
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
        discoveredCreatures: [],
        pearlsEarned: 0,
      );
    }
    
    _isRunning = false;
    _isRunningNotifier.value = _isRunning;
    if (wasStudySession) {
      _completedSessions++;
    }
    _isStudySession = !_isStudySession;
    _isStudySessionNotifier.value = _isStudySession;
    _secondsRemaining = _isStudySession 
        ? _timerProvider.focusDuration * 60 
        : (_shouldUseLongBreak() ? _timerProvider.longBreakDuration * 60 : _timerProvider.breakDuration * 60);
    _secondsRemainingNotifier.value = _secondsRemaining;
    _sessionStartTime = null;
    
    // Complete Live Activity
    LiveActivitiesService().completeTimerActivity(
      isStudySession: wasStudySession,
      nextSessionType: _isStudySession ? 'Research Dive' : 'Surface Rest',
    );
    
    notifyListeners();
    
    // Return reward for UI to display
    return reward;
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
  
  void switchToWorkSession() {
    if (!_isStudySession && !_isRunning) {
      _isStudySession = true;
      _isStudySessionNotifier.value = _isStudySession;
      _secondsRemaining = _timerProvider.focusDuration * 60;
      _secondsRemainingNotifier.value = _secondsRemaining;
      
      // Play transition sound
      UISoundService.instance.navigationSwitch();
      notifyListeners();
    }
  }
  
  void switchToBreakSession() {
    if (_isStudySession && !_isRunning) {
      _isStudySession = false;
      _isStudySessionNotifier.value = _isStudySession;
      _secondsRemaining = _shouldUseLongBreak() 
          ? _timerProvider.longBreakDuration * 60 
          : _timerProvider.breakDuration * 60;
      _secondsRemainingNotifier.value = _secondsRemaining;
      
      // Play transition sound
      UISoundService.instance.navigationSwitch();
      notifyListeners();
    }
  }
  
  void startFocusSession() {
    if (!_isStudySession || _isRunning) {
      _isStudySession = true;
      resetTimer();
    }
    if (!_isRunning) {
      toggleTimer();
    }
  }
  
  void startBreakSession() {
    if (_isStudySession || _isRunning) {
      _isStudySession = false;
      resetTimer();
    }
    if (!_isRunning) {
      toggleTimer();
    }
  }
  
  void pauseTimer() {
    if (_isRunning) {
      toggleTimer();
    }
  }
  
  void resumeTimer() {
    if (!_isRunning) {
      toggleTimer();
    }
  }
  
  String formatTime(int seconds) {
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
  
  @override
  void dispose() {
    _timer?.cancel();
    _secondsRemainingNotifier.dispose();
    _isRunningNotifier.dispose();
    _isStudySessionNotifier.dispose();
    super.dispose();
  }
}