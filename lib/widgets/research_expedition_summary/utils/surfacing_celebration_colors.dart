import 'package:flutter/material.dart';
import '../../../utils/responsive_helper.dart';

/// Surfacing celebration color system for expedition summary.
///
/// Represents emerging from depths into bright, refreshing celebration colors
/// that naturally transition to break sessions. Replaces the problematic
/// depth-based color system that showed dark colors during celebrations.
class SurfacingCelebrationColors {

  /// Surfacing gradient - represents emerging from depths to surface
  /// Used as main background gradient for celebration interface
  static const List<Color> surfacingGradient = [
    Color(0xFF001B3D), // Deep start (where we came from)
    Color(0xFF0077BE), // Rising blue
    Color(0xFF00BFFF), // Bright sky blue
    Color(0xFF87CEEB), // Surface sky blue
  ];

  /// Enhanced surfacing gradient with more stops for smoother transition
  static const List<Color> surfacingGradientEnhanced = [
    Color(0xFF000B1A), // Deepest depths
    Color(0xFF001B3D), // Deep ocean
    Color(0xFF003366), // Mid-rise
    Color(0xFF0077BE), // Rising blue
    Color(0xFF00BFFF), // Bright sky blue
    Color(0xFF87CEEB), // Surface sky blue
    Color(0xFFB0E0E6), // Powder blue (surface sparkle)
  ];

  /// Achievement rarity colors - bright and celebratory
  static const Color legendary = Color(0xFFFFD700); // Gold
  static const Color epic = Color(0xFFE6E6FA); // Lavender (silver/platinum feel)
  static const Color rare = Color(0xFF40E0D0); // Turquoise
  static const Color uncommon = Color(0xFF87CEEB); // Sky blue
  static const Color common = Color(0xFF98FB98); // Pale green

  /// Achievement type specific colors that harmonize with surfacing theme
  static const Color careerAdvancement = Color(0xFFE6B800); // Softer gold - highest honor
  static const Color levelUp = Color(0xFFE6E6FA); // Silver/platinum - significant
  static const Color speciesDiscovery = Color(0xFF40E0D0); // Turquoise - discovery excitement
  static const Color streakMilestone = Color(0xFF00E5FF); // Bright cyan - momentum
  static const Color sessionQuality = Color(0xFF87CEEB); // Sky blue - excellence
  static const Color research = Color(0xFF98FB98); // Pale green - knowledge

  /// Break session transition colors - natural flow from celebration to rest
  static const List<Color> breakTransitionGradient = [
    Color(0xFF87CEEB), // Sky blue (from celebration)
    Color(0xFF98FB98), // Refreshing pale green
    Color(0xFFF0F8FF), // Alice blue (rest preparation)
    Color(0xFFF5F5F5), // White smoke (clean rest state)
  ];

  /// Get responsive surfacing gradient based on screen size
  /// Larger screens get more dramatic gradients, mobile gets subtle ones
  static LinearGradient getResponsiveSurfacingGradient(BuildContext context) {
    final screenType = ResponsiveHelper.getScreenType(context);

    switch (screenType) {
      case DeviceScreenType.mobile:
        // Subtle gradient for mobile readability
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF001B3D),
            Color(0xFF0077BE),
            Color(0xFF87CEEB),
          ],
          stops: [0.0, 0.5, 1.0],
        );

      case DeviceScreenType.tablet:
        // Balanced gradient for tablets
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: surfacingGradient,
          stops: [0.0, 0.3, 0.7, 1.0],
        );

      case DeviceScreenType.desktop:
      case DeviceScreenType.wideDesktop:
        // Full dramatic gradient for desktop
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
  static List<Shadow> getCelebrationTextShadows(BuildContext context) {
    final screenType = ResponsiveHelper.getScreenType(context);

    // Adjust shadow intensity based on screen size
    final baseAlpha = screenType == DeviceScreenType.mobile ? 0.6 : 0.8;

    return [
      Shadow(
        color: const Color(0xFF40E0D0).withValues(alpha: 0.3), // Turquoise glow
        blurRadius: 12.0,
        offset: const Offset(0, 0),
      ),
      Shadow(
        color: const Color(0xFF0077BE).withValues(alpha: baseAlpha), // Ocean blue depth
        blurRadius: 8.0,
        offset: const Offset(0, 2),
      ),
      Shadow(
        color: Colors.black.withValues(alpha: baseAlpha), // Subtle black for readability
        blurRadius: 12.0,
        offset: const Offset(0, 4),
      ),
    ];
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
  static Color getCelebrationBorderColor(AchievementType? type) {
    if (type != null) {
      return getAchievementTypeColor(type).withValues(alpha: 0.8);
    }
    return const Color(0xFF40E0D0).withValues(alpha: 0.8); // Default turquoise
  }

  /// Get accent color for achievements (replaces problematic gold everywhere)
  static Color getCelebrationAccentColor(AchievementType? type) {
    if (type != null) {
      return getAchievementTypeColor(type);
    }
    return const Color(0xFF40E0D0); // Default turquoise accent
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
  static List<Color> getCelebrationParticleColors() {
    return [
      const Color(0xFF40E0D0), // Turquoise
      const Color(0xFF87CEEB), // Sky blue
      const Color(0xFF00E5FF), // Bright cyan
      const Color(0xFF98FB98), // Pale green
      Colors.white.withValues(alpha: 0.8), // White sparkles
    ];
  }

  /// Get container background for achievement cards
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
          const Color(0xFF001B3D).withValues(alpha: 0.9),
          const Color(0xFF0077BE).withValues(alpha: 0.8),
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
          color: borderColor.withValues(alpha: 0.3),
          blurRadius: 12,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 8,
          spreadRadius: 1,
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