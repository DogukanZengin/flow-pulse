import 'package:flutter/material.dart';
import '../utils/performance_monitor.dart';

/// Adaptive animation constants that adjust based on device performance
///
/// Provides performance-aware timing for celebration animations,
/// ensuring smooth 60fps experience across all device capabilities.
class AdaptiveAnimationConstants {

  /// Get adaptive duration based on current performance
  static Duration getAdaptiveDuration(Duration baseDuration) {
    final multiplier = CelebrationPerformanceMonitor.getAdaptiveDurationMultiplier();
    return Duration(
      milliseconds: (baseDuration.inMilliseconds * multiplier).round(),
    );
  }

  /// Adaptive phase transition duration
  static Duration get adaptivePhaseTransition => getAdaptiveDuration(
    const Duration(milliseconds: 800)
  );

  /// Adaptive particle animation duration
  static Duration get adaptiveParticleAnimation => getAdaptiveDuration(
    const Duration(seconds: 3)
  );

  /// Adaptive hero achievement animation duration
  static Duration get adaptiveHeroAnimation => getAdaptiveDuration(
    const Duration(milliseconds: 1200)
  );

  /// Adaptive secondary achievement animation duration
  static Duration get adaptiveSecondaryAnimation => getAdaptiveDuration(
    const Duration(milliseconds: 600)
  );

  /// Adaptive surfacing animation duration
  static Duration get adaptiveSurfacingAnimation => getAdaptiveDuration(
    const Duration(milliseconds: 1200)
  );

  /// Adaptive jellyfish effect duration
  static Duration get adaptiveJellyfishEffect => getAdaptiveDuration(
    const Duration(seconds: 4)
  );

  /// Adaptive school of fish transition duration
  static Duration get adaptiveSchoolOfFishTransition => getAdaptiveDuration(
    const Duration(seconds: 2)
  );

  /// Get adaptive delay between animations
  static Duration getAdaptiveDelay(Duration baseDelay) {
    return getAdaptiveDuration(baseDelay);
  }

  /// Check if we should use reduced motion for accessibility
  static bool shouldUseReducedMotion() {
    final quality = CelebrationPerformanceMonitor.getAdaptiveQuality();
    return quality == AnimationQuality.low;
  }

  /// Get adaptive curve based on performance
  static Curve getAdaptiveCurve(Curve baseCurve) {
    final quality = CelebrationPerformanceMonitor.getAdaptiveQuality();

    switch (quality) {
      case AnimationQuality.low:
        return Curves.linear; // Simplest curve for performance
      case AnimationQuality.medium:
        return Curves.easeInOut; // Balanced curve
      case AnimationQuality.high:
      case AnimationQuality.maximum:
        return baseCurve; // Use original curve
    }
  }
}