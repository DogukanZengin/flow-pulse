import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'live_activities_service.dart';
import 'battery_optimization_service.dart';

/// Service to handle timer continuity when app is backgrounded
/// Implements iOS background tasks and proper state persistence
class BackgroundTimerService with WidgetsBindingObserver {
  static final BackgroundTimerService _instance = BackgroundTimerService._internal();
  factory BackgroundTimerService() => _instance;
  BackgroundTimerService._internal();

  static const MethodChannel _channel = MethodChannel('flow_pulse/background_timer');
  
  Timer? _backgroundTimer;
  DateTime? _backgroundStartTime;
  bool _isInBackground = false;
  int _backgroundTaskId = -1;
  
  // Timer state
  bool _timerRunning = false;
  int _remainingSeconds = 0;
  bool _isStudySession = true;
  String _sessionTitle = '';
  
  // Callbacks
  void Function(int remainingSeconds)? onTimerTick;
  void Function()? onTimerComplete;
  void Function(AppLifecycleState state)? onAppLifecycleChanged;

  Future<void> initialize() async {
    if (kIsWeb) return;
    
    WidgetsBinding.instance.addObserver(this);
    
    // Set up method channel for iOS background tasks
    if (Platform.isIOS) {
      _channel.setMethodCallHandler(_handleMethodCall);
    }
    
    // Initialize battery optimization
    await BatteryOptimizationService().initialize();
    
    // Restore timer state on app startup
    await _restoreTimerState();
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'backgroundTaskExpired':
        debugPrint('Background task expired, saving timer state');
        await _saveTimerState();
        break;
      case 'backgroundTaskStarted':
        _backgroundTaskId = call.arguments['taskId'] ?? -1;
        debugPrint('Background task started: $_backgroundTaskId');
        break;
      default:
        throw PlatformException(
          code: 'UNIMPLEMENTED',
          message: 'Method ${call.method} not implemented',
        );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    debugPrint('App lifecycle changed to: $state');
    onAppLifecycleChanged?.call(state);
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        _handleAppBackgrounded();
        break;
      case AppLifecycleState.resumed:
        _handleAppForegrounded();
        break;
      case AppLifecycleState.hidden:
        // App is hidden but may still be running
        break;
    }
  }

  void _handleAppBackgrounded() async {
    if (!_timerRunning) return;
    
    _isInBackground = true;
    _backgroundStartTime = DateTime.now();
    
    // Notify battery optimization service
    BatteryOptimizationService().setBackgroundState(true);
    
    debugPrint('App backgrounded - starting background timer handling');
    
    // Save current timer state
    await _saveTimerState();
    
    // Start iOS background task
    if (Platform.isIOS) {
      await _startBackgroundTask();
    }
    
    // Start background timer for Android or fallback
    _startBackgroundTimer();
    
    // Update notifications
    await NotificationService().showTimerWithActions(
      title: _sessionTitle,
      body: 'Timer running: ${_formatTime(_remainingSeconds)} remaining',
      isRunning: true,
    );
  }

  void _handleAppForegrounded() async {
    if (!_isInBackground) return;
    
    debugPrint('App foregrounded - syncing timer state');
    
    _isInBackground = false;
    
    // Notify battery optimization service
    BatteryOptimizationService().setBackgroundState(false);
    
    // Calculate elapsed time while backgrounded
    if (_backgroundStartTime != null) {
      final elapsed = DateTime.now().difference(_backgroundStartTime!).inSeconds;
      _remainingSeconds = (_remainingSeconds - elapsed).clamp(0, double.infinity).toInt();
      
      debugPrint('Background elapsed: ${elapsed}s, remaining: ${_remainingSeconds}s');
    }
    
    // Stop background timer
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
    
    // End iOS background task
    if (Platform.isIOS && _backgroundTaskId != -1) {
      await _endBackgroundTask();
    }
    
    // Update UI
    onTimerTick?.call(_remainingSeconds);
    
    // Check if timer completed while backgrounded
    if (_remainingSeconds <= 0 && _timerRunning) {
      _timerRunning = false;
      await _saveTimerState();
      onTimerComplete?.call();
    }
    
    // Clear background notifications
    await NotificationService().cancelNotification(0);
    await NotificationService().cancelNotification(1);
  }

  Future<void> _startBackgroundTask() async {
    if (!Platform.isIOS) return;
    
    try {
      final result = await _channel.invokeMethod('startBackgroundTask', {
        'reason': 'Timer session in progress'
      });
      _backgroundTaskId = result['taskId'] ?? -1;
      debugPrint('Started background task: $_backgroundTaskId');
    } catch (e) {
      debugPrint('Error starting background task: $e');
    }
  }

  Future<void> _endBackgroundTask() async {
    if (!Platform.isIOS || _backgroundTaskId == -1) return;
    
    try {
      await _channel.invokeMethod('endBackgroundTask', {
        'taskId': _backgroundTaskId
      });
      debugPrint('Ended background task: $_backgroundTaskId');
      _backgroundTaskId = -1;
    } catch (e) {
      debugPrint('Error ending background task: $e');
    }
  }

  void _startBackgroundTimer() {
    _backgroundTimer?.cancel();
    
    final batteryService = BatteryOptimizationService();
    
    // Use battery-optimized interval
    final timerInterval = batteryService.getOptimalTimerInterval();
    final notificationInterval = batteryService.getNotificationUpdateInterval();
    
    _backgroundTimer = Timer.periodic(timerInterval, (timer) {
      if (!_timerRunning) {
        timer.cancel();
        return;
      }
      
      _remainingSeconds -= timerInterval.inSeconds;
      
      if (_remainingSeconds <= 0) {
        _remainingSeconds = 0;
        _timerRunning = false;
        timer.cancel();
        
        // Show completion notification
        NotificationService().showTimerNotification(
          title: 'Timer Completed! 🎉',
          body: _isStudySession 
              ? 'Great work! Time for a well-deserved break.'
              : 'Break time is over. Ready to focus again?',
          payload: 'timer_completed',
        );
        
        // Save completed state
        _saveTimerState();
        
        return;
      }
      
      // Update notification based on battery optimization settings
      if (_remainingSeconds % notificationInterval.inSeconds == 0 && 
          !batteryService.shouldReduceBackgroundActivity()) {
        NotificationService().showTimerWithActions(
          title: _sessionTitle,
          body: 'Timer running: ${_formatTime(_remainingSeconds)} remaining',
          isRunning: true,
        );
      }
      
      // Update Live Activity with battery-optimized frequency
      final liveActivityInterval = batteryService.isLowPowerMode ? 30 : 10;
      if (_remainingSeconds % liveActivityInterval == 0) {
        LiveActivitiesService().updateTimerActivity(
          sessionTitle: _sessionTitle,
          totalSeconds: _isStudySession ? 1500 : 300, // Simplified
          remainingSeconds: _remainingSeconds,
          isRunning: true,
          isStudySession: _isStudySession,
        );
      }
    });
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('timer_running', _timerRunning);
    await prefs.setInt('remaining_seconds', _remainingSeconds);
    await prefs.setBool('is_study_session', _isStudySession);
    await prefs.setString('session_title', _sessionTitle);
    
    if (_backgroundStartTime != null) {
      await prefs.setInt('background_start_time', _backgroundStartTime!.millisecondsSinceEpoch);
    }
    
    debugPrint('Timer state saved: running=$_timerRunning, remaining=${_remainingSeconds}s');
  }

  Future<void> _restoreTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    
    _timerRunning = prefs.getBool('timer_running') ?? false;
    _remainingSeconds = prefs.getInt('remaining_seconds') ?? 0;
    _isStudySession = prefs.getBool('is_study_session') ?? true;
    _sessionTitle = prefs.getString('session_title') ?? '';
    
    final backgroundStartMs = prefs.getInt('background_start_time');
    if (backgroundStartMs != null) {
      _backgroundStartTime = DateTime.fromMillisecondsSinceEpoch(backgroundStartMs);
      
      // Calculate elapsed time since app was backgrounded
      final elapsed = DateTime.now().difference(_backgroundStartTime!).inSeconds;
      _remainingSeconds = (_remainingSeconds - elapsed).clamp(0, double.infinity).toInt();
      
      debugPrint('Restored timer state: elapsed=${elapsed}s, remaining=${_remainingSeconds}s');
    }
    
    // Clear background start time
    await prefs.remove('background_start_time');
    
    // If timer was running and completed while app was closed, trigger completion
    if (_timerRunning && _remainingSeconds <= 0) {
      _timerRunning = false;
      await _saveTimerState();
      
      // Delay completion callback to allow UI to initialize
      Future.delayed(const Duration(milliseconds: 500), () {
        onTimerComplete?.call();
      });
    }
  }

  // Public methods for timer control
  void startTimer({
    required int remainingSeconds,
    required bool isStudySession,
    required String sessionTitle,
  }) {
    _timerRunning = true;
    _remainingSeconds = remainingSeconds;
    _isStudySession = isStudySession;
    _sessionTitle = sessionTitle;
    
    debugPrint('Timer started: ${remainingSeconds}s, study=$isStudySession');
    _saveTimerState();
  }

  void pauseTimer() {
    _timerRunning = false;
    _backgroundTimer?.cancel();
    
    debugPrint('Timer paused');
    _saveTimerState();
  }

  void stopTimer() {
    _timerRunning = false;
    _remainingSeconds = 0;
    _backgroundTimer?.cancel();
    
    // End background task if active
    if (Platform.isIOS && _backgroundTaskId != -1) {
      _endBackgroundTask();
    }
    
    debugPrint('Timer stopped');
    _saveTimerState();
  }

  void updateTimer(int remainingSeconds) {
    _remainingSeconds = remainingSeconds;
    
    // Update state periodically to handle unexpected app termination
    if (remainingSeconds % 30 == 0) {
      _saveTimerState();
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Getters
  bool get isTimerRunning => _timerRunning;
  int get remainingSeconds => _remainingSeconds;
  bool get isInBackground => _isInBackground;
  
  void dispose() {
    _backgroundTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }
}