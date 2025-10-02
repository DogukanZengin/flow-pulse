import 'package:flutter/material.dart';
import '../../../models/creature.dart';
import '../../../theme/ocean_theme_colors.dart';

/// Biome-aware color inheritance system for visual continuity
/// between ocean widget and expedition summary.
///
/// Implements ocean-harmonious colors instead of harsh contrasts
/// following the "Research Station Underwater" design principle.
///
/// Now uses unified OceanThemeColors palette for consistency.
class BiomeColorInheritance {

  /// Get biome-specific accent color for achievements and highlights
  /// Uses softened colors from unified theme
  static Color getBiomeAccentColor(BiomeType biome) {
    switch (biome) {
      case BiomeType.shallowWaters:
        return OceanThemeColors.shallowWatersAccent;
      case BiomeType.coralGarden:
        return OceanThemeColors.coralGardenAccent;
      case BiomeType.deepOcean:
        return OceanThemeColors.deepOceanAccent;
      case BiomeType.abyssalZone:
        return OceanThemeColors.abyssalZoneAccent;
    }
  }

  /// Get depth-appropriate background gradient colors
  /// Replaces harsh black overlays with ocean-themed backgrounds
  static List<Color> getDepthTransitionColors(double depth) {
    if (depth >= 100.0) {
      // Abyssal zone - darkest depths
      return [
        const Color(0xFF0B0B1F).withValues(alpha: 0.95), // Deep midnight
        const Color(0xFF191970).withValues(alpha: 0.90), // Midnight blue
        const Color(0xFF000000).withValues(alpha: 0.85), // True black depths
      ];
    } else if (depth >= 30.0) {
      // Deep ocean - substantial depth
      return [
        const Color(0xFF001122).withValues(alpha: 0.95), // Deep ocean blue
        const Color(0xFF003366).withValues(alpha: 0.90), // Darker blue
        const Color(0xFF001B3D).withValues(alpha: 0.85), // Very deep blue
      ];
    } else if (depth >= 10.0) {
      // Coral garden - medium depth
      return [
        const Color(0xFF003366).withValues(alpha: 0.90), // Medium ocean blue
        const Color(0xFF004477).withValues(alpha: 0.85), // Coral depth blue
        const Color(0xFF002244).withValues(alpha: 0.80), // Deeper coral blue
      ];
    } else {
      // Shallow waters - lighter depths
      return [
        const Color(0xFF004477).withValues(alpha: 0.85), // Shallow blue
        const Color(0xFF0066AA).withValues(alpha: 0.80), // Light ocean blue
        const Color(0xFF003366).withValues(alpha: 0.75), // Transitional blue
      ];
    }
  }

  /// Get biome-appropriate background gradient for containers
  static LinearGradient getBiomeBackgroundGradient(BiomeType biome, double depth) {
    final colors = getDepthTransitionColors(depth);

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
      stops: const [0.0, 0.6, 1.0],
    );
  }

  /// Get ocean-themed text shadows instead of harsh black shadows
  static List<Shadow> getOceanTextShadows(BiomeType biome) {
    final biomeAccent = getBiomeAccentColor(biome);

    return [
      Shadow(
        color: biomeAccent.withValues(alpha: 0.3),
        blurRadius: 12.0,
        offset: const Offset(0, 0),
      ),
      Shadow(
        color: const Color(0xFF003366).withValues(alpha: 0.8),
        blurRadius: 8.0,
        offset: const Offset(0, 2),
      ),
      Shadow(
        color: Colors.black.withValues(alpha: 0.6),
        blurRadius: 12.0,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// Get achievement-specific colors that harmonize with biome
  static Color getAchievementTypeColor(AchievementType type, BiomeType biome) {
    final baseAccent = getBiomeAccentColor(biome);

    switch (type) {
      case AchievementType.careerAdvancement:
        // Career advancement gets the purest biome color - highest honor
        return baseAccent;

      case AchievementType.levelUp:
        // Level ups get a slightly lighter variant
        return Color.lerp(baseAccent, Colors.white, 0.2) ?? baseAccent;

      case AchievementType.speciesDiscovery:
        // Species discoveries get a warmer variant
        return Color.lerp(baseAccent, const Color(0xFFFFD700), 0.15) ?? baseAccent;

      case AchievementType.streakMilestone:
        // Streaks get a cooler variant
        return Color.lerp(baseAccent, const Color(0xFF00FFFF), 0.1) ?? baseAccent;

      case AchievementType.sessionQuality:
        // Quality gets a softer variant
        return Color.lerp(baseAccent, Colors.white, 0.1) ?? baseAccent;

      case AchievementType.research:
        // Research gets the base color
        return baseAccent;
    }
  }

  /// Get border color with appropriate alpha for depth
  static Color getBorderColor(BiomeType biome, double depth) {
    final baseColor = getBiomeAccentColor(biome);

    // Deeper waters have more subtle borders
    if (depth >= 50.0) {
      return baseColor.withValues(alpha: 0.6);
    } else if (depth >= 20.0) {
      return baseColor.withValues(alpha: 0.7);
    } else {
      return baseColor.withValues(alpha: 0.8);
    }
  }
}

/// Achievement types for color assignment
enum AchievementType {
  careerAdvancement,
  levelUp,
  speciesDiscovery,
  streakMilestone,
  sessionQuality,
  research,
}