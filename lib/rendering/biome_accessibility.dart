import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/creature.dart';
import 'simple_biome_creatures.dart';

/// Accessibility features for biome creatures
/// Ensures the simplified creature system is inclusive and screen-reader friendly
class BiomeAccessibility {

  /// Generate semantic description for current biome
  static String getBiomeSemanticDescription(BiomeType biome, int creatureCount) {
    final biomeNames = {
      BiomeType.shallowWaters: 'shallow tropical waters',
      BiomeType.coralGarden: 'vibrant coral garden',
      BiomeType.deepOcean: 'deep ocean environment',
      BiomeType.abyssalZone: 'mysterious abyssal depths',
    };

    final creatureDescriptions = {
      BiomeType.shallowWaters: 'small colorful tropical fish',
      BiomeType.coralGarden: 'reef fish with elaborate fins',
      BiomeType.deepOcean: 'large streamlined pelagic creatures',
      BiomeType.abyssalZone: 'bioluminescent deep-sea creatures',
    };

    return 'Currently in ${biomeNames[biome]} with $creatureCount ${creatureDescriptions[biome]} swimming nearby';
  }

  /// Create semantic widget wrapper for ocean environment
  static Widget createSemanticOceanWrapper({
    required Widget child,
    required BiomeType currentBiome,
    required int creatureCount,
    required bool isSessionActive,
    required int currentDepth,
  }) {
    return Semantics(
      label: 'Ocean diving environment',
      value: getBiomeSemanticDescription(currentBiome, creatureCount),
      hint: isSessionActive
        ? 'Currently diving at $currentDepth meters depth'
        : 'Session paused - tap to continue diving',
      child: child,
    );
  }

  /// High contrast color alternatives for accessibility
  static BiomeColors getHighContrastColors(BiomeType biome, int creatureIndex) {
    switch (biome) {
      case BiomeType.shallowWaters:
        final highContrastColors = [
          BiomeColors(body: const Color(0xFF000000), accent: const Color(0xFFFFFFFF)),
          BiomeColors(body: const Color(0xFF0000FF), accent: const Color(0xFFFFFF00)),
          BiomeColors(body: const Color(0xFF008000), accent: const Color(0xFFFFFFFF)),
        ];
        return highContrastColors[creatureIndex % highContrastColors.length];

      case BiomeType.coralGarden:
        final highContrastColors = [
          BiomeColors(body: const Color(0xFF800080), accent: const Color(0xFFFFFFFF)),
          BiomeColors(body: const Color(0xFF000080), accent: const Color(0xFFFFFF00)),
          BiomeColors(body: const Color(0xFF8B4513), accent: const Color(0xFFFFFFFF)),
        ];
        return highContrastColors[creatureIndex % highContrastColors.length];

      case BiomeType.deepOcean:
        final highContrastColors = [
          BiomeColors(body: const Color(0xFF000000), accent: const Color(0xFF00FFFF)),
          BiomeColors(body: const Color(0xFF2F4F4F), accent: const Color(0xFFFFFFFF)),
          BiomeColors(body: const Color(0xFF000080), accent: const Color(0xFFFFFFFF)),
        ];
        return highContrastColors[creatureIndex % highContrastColors.length];

      case BiomeType.abyssalZone:
        final highContrastColors = [
          BiomeColors(body: const Color(0xFF000000), accent: const Color(0xFF00FF00)),
          BiomeColors(body: const Color(0xFF2F2F4F), accent: const Color(0xFFFF00FF)),
          BiomeColors(body: const Color(0xFF000000), accent: const Color(0xFFFFFFFF)),
        ];
        return highContrastColors[creatureIndex % highContrastColors.length];
    }
  }

  /// Reduced motion alternatives for creatures
  static double getReducedMotionAnimationSpeed(double normalSpeed) {
    // Reduce animation speed by 75% for users with motion sensitivity
    return normalSpeed * 0.25;
  }

  /// Check if high contrast should be used based on system accessibility settings
  static bool shouldUseHighContrast(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Check if reduced motion should be used
  static bool shouldUseReducedMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Create accessible creature animation that respects user preferences
  static double getAccessibleAnimationValue(BuildContext context, double animationValue) {
    if (shouldUseReducedMotion(context)) {
      return getReducedMotionAnimationSpeed(animationValue);
    }
    return animationValue;
  }

  /// Generate readable creature type announcement for screen readers
  static String getCreatureTypeAnnouncement(BiomeType biome, int creatureIndex) {
    switch (biome) {
      case BiomeType.shallowWaters:
        final types = ['clownfish', 'angelfish', 'tang', 'damselfish'];
        return types[creatureIndex % types.length];
      case BiomeType.coralGarden:
        final types = ['parrotfish', 'butterflyfish', 'wrasse', 'triggerfish'];
        return types[creatureIndex % types.length];
      case BiomeType.deepOcean:
        final types = ['shark', 'ray', 'tuna', 'barracuda'];
        return types[creatureIndex % types.length];
      case BiomeType.abyssalZone:
        final types = ['anglerfish', 'jellyfish', 'lanternfish', 'deep sea eel'];
        return types[creatureIndex % types.length];
    }
  }
}

/// Extension for the BiomeColors class to include accessibility features
extension BiomeColorsAccessibility on BiomeColors {
  /// Get WCAG AA compliant color contrast ratios
  double getContrastRatio() {
    // Simplified contrast calculation
    final bodyLuminance = _calculateLuminance(body);
    final accentLuminance = _calculateLuminance(accent);

    final lighter = bodyLuminance > accentLuminance ? bodyLuminance : accentLuminance;
    final darker = bodyLuminance <= accentLuminance ? bodyLuminance : accentLuminance;

    return (lighter + 0.05) / (darker + 0.05);
  }

  double _calculateLuminance(Color color) {
    // W3C relative luminance calculation
    final r = _linearize(color.r);
    final g = _linearize(color.g);
    final b = _linearize(color.b);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  double _linearize(double colorValue) {
    if (colorValue <= 0.03928) {
      return colorValue / 12.92;
    } else {
      return math.pow((colorValue + 0.055) / 1.055, 2.4).toDouble();
    }
  }

  /// Check if color combination meets WCAG AA standards
  bool meetsWCAGAA() {
    return getContrastRatio() >= 4.5;
  }

  /// Check if color combination meets WCAG AAA standards
  bool meetsWCAGAAA() {
    return getContrastRatio() >= 7.0;
  }
}