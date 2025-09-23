import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';

/// Performance monitoring system for celebration animations
///
/// Tracks frame rates during celebration sequences and automatically adjusts
/// animation quality to maintain smooth 60fps performance while preserving
/// visual fidelity where possible.
class CelebrationPerformanceMonitor {
  static final CelebrationPerformanceMonitor _instance = CelebrationPerformanceMonitor._internal();
  factory CelebrationPerformanceMonitor() => _instance;
  CelebrationPerformanceMonitor._internal();

  // Performance tracking state
  final List<Duration> _frameTimes = [];
  double _currentFPS = 60.0;
  AnimationQuality _currentQuality = AnimationQuality.high;
  bool _isMonitoring = false;

  // Performance thresholds - adjusted for different environments
  static double get _targetFPS => kIsWeb || kDebugMode ? 30.0 : 60.0;
  static double get _warningFPS => kIsWeb || kDebugMode ? 20.0 : 45.0;
  static double get _criticalFPS => kIsWeb || kDebugMode ? 15.0 : 30.0;
  static const int _sampleSize = 15; // Monitor last 15 frames for faster response

  /// Start monitoring frame performance during celebrations
  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    _frameTimes.clear();

    SchedulerBinding.instance.addTimingsCallback(_onFrameTiming);
    debugPrint('🔬 Performance monitoring started for celebration');
    debugPrint('   Target FPS: $_targetFPS | Warning: $_warningFPS | Critical: $_criticalFPS');
    debugPrint('   Environment: ${kIsWeb ? "Web" : kDebugMode ? "Debug" : "Release"}');
  }

  /// Stop monitoring and clean up
  void stopMonitoring() {
    if (!_isMonitoring) return;
    _isMonitoring = false;

    SchedulerBinding.instance.removeTimingsCallback(_onFrameTiming);
    debugPrint('🔬 Performance monitoring stopped - Final FPS: ${_currentFPS.toStringAsFixed(1)}');
  }

  /// Frame timing callback
  void _onFrameTiming(List<FrameTiming> timings) {
    for (final timing in timings) {
      // Use buildDuration + rasterDuration for actual frame rendering time
      // totalSpan includes all phases which can be misleading
      final buildTime = timing.buildDuration;
      final rasterTime = timing.rasterDuration;
      final frameDuration = buildTime + rasterTime;

      // Debug timing info for first few frames
      if (_frameTimes.length < 3 && kDebugMode) {
        debugPrint('   Frame timing - Build: ${buildTime.inMicroseconds}μs, Raster: ${rasterTime.inMicroseconds}μs, Total: ${timing.totalSpan.inMicroseconds}μs');
      }

      _frameTimes.add(frameDuration);

      // Keep only recent samples
      if (_frameTimes.length > _sampleSize) {
        _frameTimes.removeAt(0);
      }
    }

    _updateFPSAndQuality();
  }

  /// Calculate current FPS and adjust quality
  void _updateFPSAndQuality() {
    if (_frameTimes.length < 5) return; // Need fewer samples for faster response

    // Calculate average frame time in microseconds
    final totalMicroseconds = _frameTimes.fold<int>(0, (sum, duration) => sum + duration.inMicroseconds);
    final avgFrameTimeMicroseconds = totalMicroseconds / _frameTimes.length;

    // Convert to FPS - handle edge cases
    if (avgFrameTimeMicroseconds <= 0) {
      _currentFPS = 60.0; // Default to 60 if calculation fails
    } else {
      _currentFPS = 1000000 / avgFrameTimeMicroseconds;
    }

    // Clamp FPS to reasonable bounds (simulators can report weird values)
    _currentFPS = _currentFPS.clamp(1.0, 120.0);

    // Determine appropriate quality based on performance
    final newQuality = _determineOptimalQuality(_currentFPS);
    if (newQuality != _currentQuality) {
      _currentQuality = newQuality;
      debugPrint('🎯 Animation quality adjusted to: $newQuality (FPS: ${_currentFPS.toStringAsFixed(1)})');
      debugPrint('   Frame time: ${avgFrameTimeMicroseconds.toStringAsFixed(0)}μs | Sample count: ${_frameTimes.length}');
    }
  }

  /// Determine optimal animation quality based on current FPS
  AnimationQuality _determineOptimalQuality(double fps) {
    if (fps >= _targetFPS) {
      return AnimationQuality.maximum; // Can handle full quality
    } else if (fps >= _warningFPS) {
      return AnimationQuality.high; // Slight reduction
    } else if (fps >= _criticalFPS) {
      return AnimationQuality.medium; // Significant reduction
    } else {
      return AnimationQuality.low; // Minimal effects only
    }
  }

  /// Get current adaptive quality setting
  static AnimationQuality getAdaptiveQuality() {
    return _instance._currentQuality;
  }

  /// Get current FPS reading
  static double getCurrentFPS() {
    return _instance._currentFPS;
  }

  /// Check if performance is acceptable
  static bool isPerformanceAcceptable() {
    return _instance._currentFPS >= _warningFPS;
  }

  /// Get adaptive particle count based on quality
  static int getAdaptiveParticleCount(int baseCount) {
    switch (_instance._currentQuality) {
      case AnimationQuality.maximum:
        return baseCount;
      case AnimationQuality.high:
        return (baseCount * 0.8).round();
      case AnimationQuality.medium:
        return (baseCount * 0.5).round();
      case AnimationQuality.low:
        return (baseCount * 0.25).round();
    }
  }

  /// Get adaptive animation duration multiplier
  static double getAdaptiveDurationMultiplier() {
    switch (_instance._currentQuality) {
      case AnimationQuality.maximum:
        return 1.0;
      case AnimationQuality.high:
        return 1.0;
      case AnimationQuality.medium:
        return 0.8; // Slightly faster animations
      case AnimationQuality.low:
        return 0.6; // Much faster animations
    }
  }

  /// Check if expensive effects should be rendered
  static bool shouldRenderExpensiveEffects() {
    return _instance._currentQuality.index >= AnimationQuality.medium.index;
  }

  /// Check if monitoring is currently active
  bool get isMonitoring => _isMonitoring;
}

/// Animation quality levels for adaptive performance
enum AnimationQuality {
  low,      // Minimal effects, highest performance
  medium,   // Balanced effects and performance
  high,     // Rich effects, good performance
  maximum,  // All effects, requires high performance
}