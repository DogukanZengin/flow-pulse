import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerProvider extends ChangeNotifier {
  int _focusDuration = 25; // minutes
  int _breakDuration = 5;  // minutes
  int _longBreakDuration = 15; // minutes
  int _sessionsUntilLongBreak = 4;
  bool _autoStartBreaks = false;
  bool _autoStartSessions = false;
  bool _enableVisualEffects = true; // Performance setting
  
  SharedPreferences? _prefs;

  // Getters
  int get focusDuration => _focusDuration;
  int get breakDuration => _breakDuration;
  int get longBreakDuration => _longBreakDuration;
  int get sessionsUntilLongBreak => _sessionsUntilLongBreak;
  bool get autoStartBreaks => _autoStartBreaks;
  bool get autoStartSessions => _autoStartSessions;
  bool get enableVisualEffects => _enableVisualEffects;

  // SharedPreferences keys
  static const String _focusDurationKey = 'focus_duration';
  static const String _breakDurationKey = 'break_duration';
  static const String _longBreakDurationKey = 'long_break_duration';
  static const String _sessionsUntilLongBreakKey = 'sessions_until_long_break';
  static const String _autoStartBreaksKey = 'auto_start_breaks';
  static const String _autoStartSessionsKey = 'auto_start_sessions';
  static const String _enableVisualEffectsKey = 'enable_visual_effects';

  Future<void> loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    
    _focusDuration = _prefs?.getInt(_focusDurationKey) ?? 25;
    _breakDuration = _prefs?.getInt(_breakDurationKey) ?? 5;
    _longBreakDuration = _prefs?.getInt(_longBreakDurationKey) ?? 15;
    _sessionsUntilLongBreak = _prefs?.getInt(_sessionsUntilLongBreakKey) ?? 4;
    _autoStartBreaks = _prefs?.getBool(_autoStartBreaksKey) ?? false;
    _autoStartSessions = _prefs?.getBool(_autoStartSessionsKey) ?? false;
    _enableVisualEffects = _prefs?.getBool(_enableVisualEffectsKey) ?? true;
    
    notifyListeners();
  }

  Future<void> setFocusDuration(int minutes) async {
    _focusDuration = minutes.clamp(1, 120);
    await _prefs?.setInt(_focusDurationKey, _focusDuration);
    notifyListeners();
  }

  Future<void> setBreakDuration(int minutes) async {
    _breakDuration = minutes.clamp(1, 60);
    await _prefs?.setInt(_breakDurationKey, _breakDuration);
    notifyListeners();
  }

  Future<void> setLongBreakDuration(int minutes) async {
    _longBreakDuration = minutes.clamp(1, 60);
    await _prefs?.setInt(_longBreakDurationKey, _longBreakDuration);
    notifyListeners();
  }

  Future<void> setSessionsUntilLongBreak(int sessions) async {
    _sessionsUntilLongBreak = sessions.clamp(1, 10);
    await _prefs?.setInt(_sessionsUntilLongBreakKey, _sessionsUntilLongBreak);
    notifyListeners();
  }

  Future<void> setAutoStartBreaks(bool enabled) async {
    _autoStartBreaks = enabled;
    await _prefs?.setBool(_autoStartBreaksKey, _autoStartBreaks);
    notifyListeners();
  }

  Future<void> setAutoStartSessions(bool enabled) async {
    _autoStartSessions = enabled;
    await _prefs?.setBool(_autoStartSessionsKey, _autoStartSessions);
    notifyListeners();
  }

  // Marine research expedition presets
  Future<void> setShallowWaterDive() async {
    await setFocusDuration(25);
    await setBreakDuration(5);
    await setLongBreakDuration(15);
    await setSessionsUntilLongBreak(4);
  }

  Future<void> setDeepSeaExpedition() async {
    await setFocusDuration(45);
    await setBreakDuration(10);
    await setLongBreakDuration(30);
    await setSessionsUntilLongBreak(3);
  }

  Future<void> setSurfaceExploration() async {
    await setFocusDuration(15);
    await setBreakDuration(3);
    await setLongBreakDuration(15);
    await setSessionsUntilLongBreak(6);
  }
  
  Future<void> setEnableVisualEffects(bool enabled) async {
    _enableVisualEffects = enabled;
    await _prefs?.setBool(_enableVisualEffectsKey, _enableVisualEffects);
    notifyListeners();
  }
}