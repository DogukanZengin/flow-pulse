import 'package:flutter/material.dart';
import '../../../utils/responsive_helper.dart';
import '../../../theme/ocean_theme_colors.dart';

/// Surfacing celebration color system for expedition summary.
///
/// Represents emerging from depths into bright, refreshing celebration colors
/// that naturally transition to break sessions. Replaces the problematic
/// depth-based color system that showed dark colors during celebrations.
///
/// Now uses unified OceanThemeColors palette for consistency.
class SurfacingCelebrationColors {

  /// Surfacing gradient - represents emerging from depths to surface
  /// Used as main background gradient for celebration interface
  /// Now uses unified celebration gradient from theme
  static const List<Color> surfacingGradient = OceanThemeColors.celebrationGradient;

  /// Enhanced surfacing gradient with more stops for smoother transition
  static const List<Color> surfacingGradientEnhanced = [
    Color(0xFF2C5F7C), // Deep ocean blue (start)
    Color(0xFF3A6F8C), // Slightly lighter
    Color(0xFF4682B4), // Steel blue (rising)
    Color(0xFF5B9BD5), // Mid-rise blue
    Color(0xFF87CEEB), // Sky blue (surface)
    Color(0xFF9DD9F3), // Lighter sky
    Color(0xFFB0E0E6), // Powder blue (celebration)
  ];

  /// Achievement rarity colors - softened for less visual aggression
  static const Color legendary = OceanThemeColors.legendaryRarity;
  static const Color epic = Color(0xFFE6E6FA); // Lavender (kept for silver/platinum feel)
  static const Color rare = OceanThemeColors.rareRarity;
  static const Color uncommon = OceanThemeColors.uncommonRarity;
  static const Color common = OceanThemeColors.commonRarity;

  /// Achievement type specific colors that harmonize with surfacing theme
  /// Now using unified theme colors with subtle variations
  static const Color careerAdvancement = OceanThemeColors.legendaryRarity; // Soft gold - highest honor
  static const Color levelUp = Color(0xFFE6E6FA); // Silver/platinum - significant
  static const Color speciesDiscovery = OceanThemeColors.celebrationAccent; // Turquoise - discovery excitement
  static const Color streakMilestone = OceanThemeColors.seafoamGreen; // Seafoam - momentum
  static const Color sessionQuality = OceanThemeColors.shallowWatersAccent; // Sky blue - excellence
  static const Color research = OceanThemeColors.uncommonRarity; // Soft green - knowledge

  /// Break session transition colors - natural flow from celebration to rest
  static const List<Color> breakTransitionGradient = [
    OceanThemeColors.shallowWatersAccent, // Sky blue (from celebration)
    OceanThemeColors.seafoamGreen, // Refreshing seafoam
    OceanThemeColors.backgroundLight, // Light ocean background (rest preparation)
    OceanThemeColors.backgroundWhite, // White (clean rest state)
  ];

  /// Get responsive surfacing gradient based on screen size
  /// Larger screens get more dramatic gradients, mobile gets subtle ones
  /// Now using unified theme colors for consistency
  static LinearGradient getResponsiveSurfacingGradient(BuildContext context) {
    final screenType = ResponsiveHelper.getScreenType(context);

    switch (screenType) {
      case DeviceScreenType.mobile:
        // Subtle gradient for mobile readability - simplified for clarity
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2C5F7C), // Deep ocean blue
            Color(0xFF4682B4), // Steel blue
            Color(0xFF87CEEB), // Sky blue
          ],
          stops: [0.0, 0.5, 1.0],
        );

      case DeviceScreenType.tablet:
        // Balanced gradient for tablets - uses unified gradient
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: surfacingGradient,
          stops: [0.0, 0.3, 0.7, 1.0],
        );

      case DeviceScreenType.desktop:
      case DeviceScreenType.wideDesktop:
        // Full dramatic gradient for desktop - enhanced with more stops
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: surfacingGradientEnhanced,
          stops: [0.0, 0.15, 0.3, 0.5, 0.7, 0.85, 1.0],
        );
    }
  }

  /// Get achievement color based on type
  static Color getAchievementTypeColor(AchievementType type) {
    switch (type) {
      case AchievementType.careerAdvancement:
        return careerAdvancement;
      case AchievementType.levelUp:
        return levelUp;
      case AchievementType.speciesDiscovery:
        return speciesDiscovery;
      case AchievementType.streakMilestone:
        return streakMilestone;
      case AchievementType.sessionQuality:
        return sessionQuality;
      case AchievementType.research:
        return research;
    }
  }

  /// Get achievement color based on rarity
  static Color getAchievementRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.legendary:
        return legendary;
      case AchievementRarity.epic:
        return epic;
      case AchievementRarity.rare:
        return rare;
      case AchievementRarity.uncommon:
        return uncommon;
      case AchievementRarity.common:
        return common;
    }
  }

  /// Get celebration text shadows that complement surfacing colors
  /// Replaces harsh black shadows with ocean-harmonious alternatives
  /// Now uses softened shadows from unified theme
  static List<Shadow> getCelebrationTextShadows(BuildContext context) {
    // Simplified shadow system - softer and less aggressive
    return OceanThemeColors.getOceanTextShadows(
      accentColor: OceanThemeColors.celebrationAccent,
    );
  }

  /// Get responsive text color that works well against surfacing backgrounds
  static Color getCelebrationTextColor(BuildContext context) {
    return Colors.white; // Always white for best readability against ocean blues
  }

  /// Get secondary text color for less prominent information
  static Color getCelebrationSecondaryTextColor(BuildContext context) {
    return Colors.white.withValues(alpha: 0.8); // Slightly transparent white
  }

  /// Get border color that complements surfacing celebration theme
  /// Now using unified theme accent color
  static Color getCelebrationBorderColor(AchievementType? type) {
    if (type != null) {
      return getAchievementTypeColor(type).withValues(alpha: 0.8);
    }
    return OceanThemeColors.celebrationAccent.withValues(alpha: 0.8); // Default turquoise
  }

  /// Get accent color for achievements (replaces problematic gold everywhere)
  /// Now using unified theme accent color
  static Color getCelebrationAccentColor(AchievementType? type) {
    if (type != null) {
      return getAchievementTypeColor(type);
    }
    return OceanThemeColors.celebrationAccent; // Default turquoise accent
  }

  /// Get colors for the celebration-to-break transition
  static LinearGradient getBreakTransitionGradient() {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: breakTransitionGradient,
      stops: [0.0, 0.4, 0.7, 1.0],
    );
  }

  /// Get particle colors for celebration effects
  /// Now uses softened colors from unified theme
  static List<Color> getCelebrationParticleColors() {
    return [
      OceanThemeColors.celebrationAccent, // Turquoise
      OceanThemeColors.shallowWatersAccent, // Sky blue
      OceanThemeColors.seafoamGreen, // Seafoam green
      OceanThemeColors.uncommonRarity, // Soft green
      Colors.white.withValues(alpha: 0.8), // White sparkles
    ];
  }

  /// Get container background for achievement cards
  /// Now uses softened colors from unified theme
  static BoxDecoration getCelebrationCardDecoration(
    BuildContext context,
    AchievementType? type,
  ) {
    final borderColor = getCelebrationBorderColor(type);

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          OceanThemeColors.deepOceanBlue.withValues(alpha: 0.9),
          OceanThemeColors.deepOceanAccent.withValues(alpha: 0.8),
        ],
      ),
      borderRadius: BorderRadius.circular(
        ResponsiveHelper.responsiveValue(
          context: context,
          mobile: 12.0,
          tablet: 16.0,
          desktop: 20.0,
        ),
      ),
      border: Border.all(
        color: borderColor,
        width: ResponsiveHelper.responsiveValue(
          context: context,
          mobile: 1.5,
          tablet: 2.0,
          desktop: 2.5,
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: borderColor.withValues(alpha: 0.2), // Softer shadow
          blurRadius: 8, // Reduced blur for subtlety
          spreadRadius: 1, // Reduced spread
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

/// Achievement type enumeration for color assignment
enum AchievementType {
  careerAdvancement,
  levelUp,
  speciesDiscovery,
  streakMilestone,
  sessionQuality,
  research,
}

/// Achievement rarity enumeration for color assignment
enum AchievementRarity {
  legendary,
  epic,
  rare,
  uncommon,
  common,
}