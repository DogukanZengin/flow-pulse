import 'package:flutter/material.dart';

/// Unified ocean-inspired color palette for FlowPulse
///
/// Follows Forest app design principles:
/// - Soft, calming colors that reduce stress
/// - Gentle gradients rather than harsh contrasts
/// - Nature-inspired palette with ocean theme
/// - Minimal visual aggression
///
/// Replaces scattered biome-specific color systems with cohesive palette
class OceanThemeColors {

  // ============================================================================
  // PRIMARY COLORS - Core application palette
  // ============================================================================

  /// Deep ocean blue - Primary brand color, used for main UI elements
  /// Calming and focused, represents the depth of concentration
  static const Color deepOceanBlue = Color(0xFF2C5F7C);

  /// Seafoam green - Secondary accent, gentle and refreshing
  /// Used for success states, positive feedback, progress indicators
  static const Color seafoamGreen = Color(0xFF7FB3B1);

  /// Sandy beige - Warm neutral for contrast
  /// Used sparingly for warmth against cool ocean tones
  static const Color sandyBeige = Color(0xFFE8D5B7);

  /// Coral pink - Special accent for rare/important elements
  /// Used only for legendary discoveries and critical actions
  static const Color coralPink = Color(0xFFFF9B85);

  // ============================================================================
  // BACKGROUND COLORS - Subtle, calming foundations
  // ============================================================================

  /// Very light blue-tinted background
  /// Used for main app background, creates subtle ocean atmosphere
  static const Color backgroundLight = Color(0xFFF0F7FA);

  /// Pure white for cards and elevated surfaces
  static const Color backgroundWhite = Color(0xFFFFFFFF);

  /// Subtle gradient background (from light to white)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundLight, backgroundWhite],
  );

  // ============================================================================
  // TEXT COLORS - Readable, not harsh
  // ============================================================================

  /// Dark blue-grey for primary text (not pure black)
  /// Softer on eyes while maintaining readability
  static const Color textPrimary = Color(0xFF2A3F4F);

  /// Medium blue-grey for secondary text
  /// Clearly de-emphasized from primary
  static const Color textSecondary = Color(0xFF6B7B8A);

  /// Light blue-grey for tertiary/disabled text
  static const Color textTertiary = Color(0xFF9CADB8);

  // ============================================================================
  // BIOME ACCENT COLORS - Softened versions for visual variety
  // ============================================================================

  /// Shallow waters - Soft sky blue (brighter, welcoming)
  static const Color shallowWatersAccent = Color(0xFF87CEEB);

  /// Coral garden - Soft coral pink (warm, vibrant)
  static const Color coralGardenAccent = Color(0xFFFF9B85);

  /// Deep ocean - Steel blue (deeper, more serious)
  static const Color deepOceanAccent = Color(0xFF4682B4);

  /// Abyssal zone - Slate blue (mysterious, not harsh purple)
  static const Color abyssalZoneAccent = Color(0xFF6A5ACD);

  // ============================================================================
  // RARITY COLORS - Softened for less visual aggression
  // ============================================================================

  /// Common rarity - Blue grey (neutral, not dull)
  static const Color commonRarity = Color(0xFF90A4AE);

  /// Uncommon rarity - Soft green (fresh, achievable)
  static const Color uncommonRarity = Color(0xFF81C784);

  /// Rare rarity - Light blue (special but not overwhelming)
  static const Color rareRarity = Color(0xFF64B5F6);

  /// Legendary rarity - Soft orange/gold (exciting without being harsh)
  static const Color legendaryRarity = Color(0xFFFFB74D);

  // ============================================================================
  // CELEBRATION COLORS - Bright but harmonious
  // ============================================================================

  /// Celebration gradient - Emerging from depths to surface
  /// Used for expedition summary and achievement celebrations
  static const List<Color> celebrationGradient = [
    Color(0xFF2C5F7C), // Deep ocean blue (start)
    Color(0xFF4682B4), // Steel blue (rising)
    Color(0xFF87CEEB), // Sky blue (surface)
    Color(0xFFB0E0E6), // Powder blue (celebration)
  ];

  /// Celebration accent - Turquoise for discovery excitement
  static const Color celebrationAccent = Color(0xFF40E0D0);

  // ============================================================================
  // FUNCTIONAL COLORS - Standard states
  // ============================================================================

  /// Success - Soft seafoam green
  static const Color success = seafoamGreen;

  /// Warning - Sandy beige (not alarming yellow)
  static const Color warning = sandyBeige;

  /// Error - Soft coral (not aggressive red)
  static const Color error = coralPink;

  /// Info - Deep ocean blue
  static const Color info = deepOceanBlue;

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get biome-specific accent color (softened versions)
  static Color getBiomeAccent(String biomeName) {
    switch (biomeName.toLowerCase()) {
      case 'shallow waters':
      case 'shallowwaters':
        return shallowWatersAccent;
      case 'coral garden':
      case 'coralgarden':
        return coralGardenAccent;
      case 'deep ocean':
      case 'deepocean':
        return deepOceanAccent;
      case 'abyssal zone':
      case 'abyssalzone':
        return abyssalZoneAccent;
      default:
        return deepOceanBlue;
    }
  }

  /// Get rarity-specific color (softened versions)
  static Color getRarityColor(String rarityName) {
    switch (rarityName.toLowerCase()) {
      case 'common':
        return commonRarity;
      case 'uncommon':
        return uncommonRarity;
      case 'rare':
        return rareRarity;
      case 'legendary':
        return legendaryRarity;
      default:
        return commonRarity;
    }
  }

  /// Get celebration gradient as LinearGradient
  static LinearGradient getCelebrationGradient() {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: celebrationGradient,
      stops: [0.0, 0.3, 0.7, 1.0],
    );
  }

  /// Get ocean-themed text shadows (soft, not harsh)
  static List<Shadow> getOceanTextShadows({Color? accentColor}) {
    final accent = accentColor ?? celebrationAccent;

    return [
      Shadow(
        color: accent.withValues(alpha: 0.2),
        blurRadius: 8.0,
        offset: const Offset(0, 0),
      ),
      Shadow(
        color: deepOceanBlue.withValues(alpha: 0.3),
        blurRadius: 6.0,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Get enhanced text shadows for readability on gradient backgrounds
  /// Use this for white text that needs to be readable on light areas of gradients
  static List<Shadow> getReadableTextShadows() {
    return [
      // Strong black shadow for contrast
      Shadow(
        color: Colors.black.withValues(alpha: 0.7),
        blurRadius: 4.0,
        offset: const Offset(0, 2),
      ),
      // Additional soft shadow for depth
      Shadow(
        color: Colors.black.withValues(alpha: 0.5),
        blurRadius: 8.0,
        offset: const Offset(0, 1),
      ),
      // Subtle ocean glow
      Shadow(
        color: deepOceanBlue.withValues(alpha: 0.3),
        blurRadius: 12.0,
        offset: const Offset(0, 0),
      ),
    ];
  }

  /// Get text shadows specifically optimized for locked/mysterious text on ocean gradients
  /// Subtle shadows for readability without being too heavy
  static List<Shadow> getLockedTextShadows() {
    return [
      // Gentle shadow for definition
      Shadow(
        color: Colors.black.withValues(alpha: 0.4),
        blurRadius: 2.0,
        offset: const Offset(0, 1),
      ),
      // Very subtle depth shadow
      Shadow(
        color: Colors.black.withValues(alpha: 0.25),
        blurRadius: 4.0,
        offset: const Offset(0, 1),
      ),
    ];
  }

  /// Get card decoration with subtle styling
  static BoxDecoration getCardDecoration({
    Color? accentColor,
    double borderRadius = 12.0,
  }) {
    final accent = accentColor ?? deepOceanBlue;

    return BoxDecoration(
      color: backgroundWhite,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: accent.withValues(alpha: 0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: accent.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Get subtle background gradient for containers
  static LinearGradient getSubtleGradient({Color? accentColor}) {
    final accent = accentColor ?? deepOceanBlue;

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        accent.withValues(alpha: 0.05),
        accent.withValues(alpha: 0.02),
      ],
    );
  }
}
