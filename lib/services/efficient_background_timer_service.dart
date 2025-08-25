import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'live_activities_service.dart';
import 'battery_optimization_service.dart';

/// Battery-efficient background timer service using timestamp-based calculations
/// Follows Apple's recommended approach: no background timers, just timestamp math
class EfficientBackgroundTimerService with WidgetsBindingObserver {
  static final EfficientBackgroundTimerService _instance = EfficientBackgroundTimerService._internal();
  factory EfficientBackgroundTimerService() => _instance;
  EfficientBackgroundTimerService._internal();

  static const MethodChannel _channel = MethodChannel('flow_pulse/background_timer');
  
  // Session state - NO background timers, just timestamps
  DateTime? _sessionStartTime;
  DateTime? _backgroundTime;
  int _originalDurationSeconds = 0;
  bool _timerRunning = false;
  bool _isStudySession = true;
  String _sessionTitle = '';
  bool _isInBackground = false;
  
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
      case 'backgroundAppRefresh':
        // iOS 13+ background app refresh - sync timer state
        final timestamp = call.arguments['timestamp'] ?? DateTime.now().millisecondsSinceEpoch / 1000;
        debugPrint('Background app refresh triggered at: $timestamp');
        await _syncTimerFromBackground();
        break;
      case 'backgroundTaskExpired':
        debugPrint('Background task expired, saving timer state');
        await _saveTimerState();
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
    _backgroundTime = DateTime.now();
    
    // Notify battery optimization service
    BatteryOptimizationService().setBackgroundState(true);
    
    debugPrint('App backgrounded at: $_backgroundTime');
    
    // Save current timer state - NO background timer started!
    await _saveTimerState();
    
    // Schedule background app refresh (iOS 13+)
    if (Platform.isIOS) {
      await _scheduleBackgroundRefresh();
    }
    
    // Show notification with current state
    await _updateBackgroundNotification();
  }

  void _handleAppForegrounded() async {
    if (!_isInBackground) return;
    
    debugPrint('App foregrounded - syncing timer using timestamps');
    
    _isInBackground = false;
    BatteryOptimizationService().setBackgroundState(false);
    
    // Calculate elapsed time using system timestamps (battery efficient!)
    await _syncTimerFromBackground();
    
    // Clear background notifications
    await NotificationService().cancelNotification(0);
    await NotificationService().cancelNotification(1);
  }

  Future<void> _syncTimerFromBackground() async {
    if (!_timerRunning || _sessionStartTime == null) return;
    
    final now = DateTime.now();
    final totalElapsed = now.difference(_sessionStartTime!).inSeconds;
    final remainingSeconds = (_originalDurationSeconds - totalElapsed).clamp(0, double.infinity).toInt();
    
    debugPrint('Timer sync: elapsed=${totalElapsed}s, remaining=${remainingSeconds}s');
    
    if (remainingSeconds <= 0 && _timerRunning) {
      // Session completed while backgrounded
      _timerRunning = false;
      await _saveTimerState();
      
      // Show completion notification
      await NotificationService().showTimerNotification(
        title: 'Timer Completed! 🎉',
        body: _isStudySession 
            ? 'Great work! Time for a well-deserved break.'
            : 'Break time is over. Ready to focus again?',
        payload: 'timer_completed',
      );
      
      // Trigger completion callback
      onTimerComplete?.call();
    } else {
      // Update UI with remaining time
      onTimerTick?.call(remainingSeconds);
    }
  }

  Future<void> _scheduleBackgroundRefresh() async {
    if (!Platform.isIOS) return;
    
    try {
      await _channel.invokeMethod('scheduleBackgroundRefresh', {
        'sessionDuration': _originalDurationSeconds,
        'startTime': _sessionStartTime?.millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('Error scheduling background refresh: $e');
    }
  }

  Future<void> _updateBackgroundNotification() async {
    if (!_timerRunning) return;
    
    final now = DateTime.now();
    final elapsed = _sessionStartTime != null ? now.difference(_sessionStartTime!).inSeconds : 0;
    final remaining = (_originalDurationSeconds - elapsed).clamp(0, double.infinity).toInt();
    
    await NotificationService().showTimerWithActions(
      title: _sessionTitle,
      body: 'Timer running: ${_formatTime(remaining)} remaining',
      isRunning: true,
    );
    
    // Update Live Activity
    LiveActivitiesService().updateTimerActivity(
      sessionTitle: _sessionTitle,
      totalSeconds: _originalDurationSeconds,
      remainingSeconds: remaining,
      isRunning: true,
      isStudySession: _isStudySession,
    );
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('timer_running', _timerRunning);
    await prefs.setInt('original_duration_seconds', _originalDurationSeconds);
    await prefs.setBool('is_study_session', _isStudySession);
    await prefs.setString('session_title', _sessionTitle);
    
    if (_sessionStartTime != null) {
      await prefs.setInt('session_start_time', _sessionStartTime!.millisecondsSinceEpoch);
    }
    
    if (_backgroundTime != null) {
      await prefs.setInt('background_start_time', _backgroundTime!.millisecondsSinceEpoch);
    }
    
    debugPrint('Timer state saved: running=$_timerRunning, duration=${_originalDurationSeconds}s');
  }

  Future<void> _restoreTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    
    _timerRunning = prefs.getBool('timer_running') ?? false;
    _originalDurationSeconds = prefs.getInt('original_duration_seconds') ?? 0;
    _isStudySession = prefs.getBool('is_study_session') ?? true;
    _sessionTitle = prefs.getString('session_title') ?? '';
    
    final sessionStartMs = prefs.getInt('session_start_time');
    if (sessionStartMs != null) {
      _sessionStartTime = DateTime.fromMillisecondsSinceEpoch(sessionStartMs);
    }
    
    final backgroundStartMs = prefs.getInt('background_start_time');
    if (backgroundStartMs != null) {
      _backgroundTime = DateTime.fromMillisecondsSinceEpoch(backgroundStartMs);
    }
    
    // Clear background start time
    await prefs.remove('background_start_time');
    
    debugPrint('Timer state restored: running=$_timerRunning, duration=${_originalDurationSeconds}s');
    
    // If timer was running, sync with current time
    if (_timerRunning) {
      await _syncTimerFromBackground();
    }
  }

  // Public methods for timer control
  void startTimer({
    required int durationSeconds,
    required bool isStudySession,
    required String sessionTitle,
  }) {
    _timerRunning = true;
    _originalDurationSeconds = durationSeconds;
    _isStudySession = isStudySession;
    _sessionTitle = sessionTitle;
    _sessionStartTime = DateTime.now(); // Critical: use system timestamp
    
    debugPrint('Timer started: ${durationSeconds}s at $_sessionStartTime');
    _saveTimerState();
    
    // Start Live Activity
    LiveActivitiesService().startTimerActivity(
      sessionTitle: sessionTitle,
      totalSeconds: durationSeconds,
      remainingSeconds: durationSeconds,
      isStudySession: isStudySession,
    );
  }

  void pauseTimer() {
    if (!_timerRunning) return;
    
    // Calculate elapsed time and adjust start time
    final now = DateTime.now();
    final elapsed = _sessionStartTime != null ? now.difference(_sessionStartTime!).inSeconds : 0;
    final remaining = (_originalDurationSeconds - elapsed).clamp(0, double.infinity).toInt();
    
    _timerRunning = false;
    _originalDurationSeconds = remaining; // Update duration to remaining time
    _sessionStartTime = null; // Clear start time
    
    debugPrint('Timer paused: ${remaining}s remaining');
    _saveTimerState();
    
    // Update Live Activity
    LiveActivitiesService().pauseTimerActivity(
      sessionTitle: _sessionTitle,
      totalSeconds: _originalDurationSeconds,
      remainingSeconds: remaining,
      isStudySession: _isStudySession,
    );
  }

  void resumeTimer() {
    if (_timerRunning) return;
    
    _timerRunning = true;
    _sessionStartTime = DateTime.now(); // Reset start time to now
    
    debugPrint('Timer resumed: ${_originalDurationSeconds}s from $_sessionStartTime');
    _saveTimerState();
    
    // Update Live Activity
    LiveActivitiesService().startTimerActivity(
      sessionTitle: _sessionTitle,
      totalSeconds: _originalDurationSeconds,
      remainingSeconds: _originalDurationSeconds,
      isStudySession: _isStudySession,
    );
  }

  void stopTimer() {
    _timerRunning = false;
    _originalDurationSeconds = 0;
    _sessionStartTime = null;
    _backgroundTime = null;
    
    debugPrint('Timer stopped');
    _saveTimerState();
    
    // End Live Activity
    LiveActivitiesService().endTimerActivity();
  }

  int getCurrentRemainingSeconds() {
    if (!_timerRunning || _sessionStartTime == null) {
      return _originalDurationSeconds;
    }
    
    final elapsed = DateTime.now().difference(_sessionStartTime!).inSeconds;
    return (_originalDurationSeconds - elapsed).clamp(0, double.infinity).toInt();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Getters
  bool get isTimerRunning => _timerRunning;
  int get originalDurationSeconds => _originalDurationSeconds;
  DateTime? get sessionStartTime => _sessionStartTime;
  bool get isInBackground => _isInBackground;
  
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}