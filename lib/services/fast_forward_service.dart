import 'package:flutter/foundation.dart';

/// Service to handle fast forward mode for accelerated timer testing
class FastForwardService extends ChangeNotifier {
  static final FastForwardService instance = FastForwardService._internal();
  
  factory FastForwardService() => instance;
  
  FastForwardService._internal();

  bool _isEnabled = false;
  double _speedMultiplier = 1.0;
  
  // Pre-defined speed presets for easy testing
  static const Map<String, double> speedPresets = {
    'Normal Speed': 1.0,
    'Fast (5x)': 5.0,
    'Very Fast (10x)': 10.0,
    'Extreme (30x)': 30.0,
    'Lightning (60x)': 60.0,
    'Time Warp (300x)': 300.0, // 5 minute session in 1 second
  };

  // Getters
  bool get isEnabled => _isEnabled;
  double get speedMultiplier => _speedMultiplier;
  String get currentPresetName => speedPresets.entries
      .firstWhere(
        (entry) => entry.value == _speedMultiplier,
        orElse: () => MapEntry('Custom', _speedMultiplier),
      )
      .key;

  /// Enable fast forward mode with specified multiplier
  void enable({double multiplier = 5.0}) {
    if (multiplier <= 0) {
      throw ArgumentError('Speed multiplier must be positive');
    }
    
    _isEnabled = true;
    _speedMultiplier = multiplier;
    
    if (kDebugMode) {
      print('🚀 FastForward: Enabled at ${multiplier}x speed');
    }
    
    notifyListeners();
  }

  /// Disable fast forward mode and return to normal speed
  void disable() {
    _isEnabled = false;
    _speedMultiplier = 1.0;
    
    if (kDebugMode) {
      print('🐌 FastForward: Disabled - Normal speed restored');
    }
    
    notifyListeners();
  }

  /// Set specific speed multiplier
  void setSpeedMultiplier(double multiplier) {
    if (multiplier <= 0) {
      throw ArgumentError('Speed multiplier must be positive');
    }
    
    _speedMultiplier = multiplier;
    
    // Enable if not already enabled
    if (!_isEnabled && multiplier > 1.0) {
      _isEnabled = true;
    }
    // Disable if setting to normal speed
    else if (_isEnabled && multiplier == 1.0) {
      _isEnabled = false;
    }
    
    if (kDebugMode) {
      print('⚡ FastForward: Speed set to ${multiplier}x');
    }
    
    notifyListeners();
  }

  /// Apply a speed preset
  void applyPreset(String presetName) {
    if (speedPresets.containsKey(presetName)) {
      setSpeedMultiplier(speedPresets[presetName]!);
    }
  }

  /// Toggle fast forward on/off (using last used multiplier)
  void toggle() {
    if (_isEnabled) {
      disable();
    } else {
      enable(multiplier: _speedMultiplier > 1.0 ? _speedMultiplier : 5.0);
    }
  }

  /// Get the effective timer duration in milliseconds for a 1-second tick
  /// This is used by the timer to determine how fast to tick
  int getTimerIntervalMs() {
    if (!_isEnabled || _speedMultiplier <= 1.0) {
      return 1000; // Normal 1-second intervals
    }
    
    // Calculate faster interval: 1000ms / speedMultiplier
    // e.g., 5x speed = 200ms intervals
    final intervalMs = (1000 / _speedMultiplier).round();
    
    // Clamp to minimum 10ms to avoid excessive CPU usage
    return intervalMs < 10 ? 10 : intervalMs;
  }

  /// Get how many seconds to subtract per timer tick
  /// This is used when the timer interval is faster than 1 second
  int getSecondsPerTick() {
    if (!_isEnabled || _speedMultiplier <= 1.0) {
      return 1; // Normal 1 second per tick
    }
    
    // For very high multipliers, subtract multiple seconds per tick
    if (_speedMultiplier >= 30.0) {
      return _speedMultiplier.round();
    }
    
    return 1; // Still subtract 1 second, but tick faster
  }

  Duration getEffectiveSessionDuration(Duration acceleratedDuration) {
    if (!_isEnabled || _speedMultiplier <= 1.0) {
      return acceleratedDuration;
    }
    
    // Return what the duration would have been at normal speed
    final totalMs = acceleratedDuration.inMilliseconds * _speedMultiplier;
    return Duration(milliseconds: totalMs.round());
  }

  /// Format time remaining with fast forward indicator
  String formatTimeWithIndicator(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    
    if (_isEnabled && _speedMultiplier > 1.0) {
      return '$timeString ⚡${_speedMultiplier.toStringAsFixed(1)}x';
    }
    
    return timeString;
  }

  /// Get warning message for fast forward mode
  String getWarningMessage() {
    if (!_isEnabled) return '';
    
    if (_speedMultiplier >= 100.0) {
      return '⚠️ EXTREME SPEED: Sessions will complete in seconds';
    } else if (_speedMultiplier >= 30.0) {
      return '🚀 VERY FAST: 25min session → ${(25 * 60 / _speedMultiplier).round()}s';
    } else if (_speedMultiplier >= 10.0) {
      return '⚡ FAST MODE: 25min session → ${(25 / _speedMultiplier).toStringAsFixed(1)}min';
    } else if (_speedMultiplier > 1.0) {
      return '🔥 ${_speedMultiplier}x SPEED: Accelerated testing mode';
    }
    
    return '';
  }

  /// Reset to normal speed (utility method)
  void reset() {
    disable();
  }
}