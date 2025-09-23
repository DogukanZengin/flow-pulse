import 'package:flutter/material.dart';
import 'creature.dart';

/// Simplified creature representation for biome-specific animations
/// No database dependencies - purely for visual movement patterns
class BiomeCreature {
  final String species;
  final BiomeType biome;
  final CreatureSize size;
  final MovementPattern pattern;
  final Color primaryColor;
  final Color secondaryColor;
  final double baseSpeed; // Multiplier for animation speed
  final double schoolingTendency; // 0.0 = solitary, 1.0 = always schools

  const BiomeCreature({
    required this.species,
    required this.biome,
    required this.size,
    required this.pattern,
    required this.primaryColor,
    required this.secondaryColor,
    required this.baseSpeed,
    required this.schoolingTendency,
  });

  /// Create animation-optimized creature for display
  factory BiomeCreature.forBiome(BiomeType biome, int index) {
    return _getBiomeCreatures(biome)[index % _getBiomeCreatures(biome).length];
  }

  /// Get all creatures for a specific biome
  static List<BiomeCreature> _getBiomeCreatures(BiomeType biome) {
    switch (biome) {
      case BiomeType.shallowWaters:
        return _shallowWaterCreatures;
      case BiomeType.coralGarden:
        return _coralGardenCreatures;
      case BiomeType.deepOcean:
        return _deepOceanCreatures;
      case BiomeType.abyssalZone:
        return _abyssalZoneCreatures;
    }
  }

  /// Get creature count for biome (for performance optimization)
  static int getCreatureCount(BiomeType biome) {
    switch (biome) {
      case BiomeType.shallowWaters:
        return 8; // Busy, energetic environment
      case BiomeType.coralGarden:
        return 6; // Moderate activity
      case BiomeType.deepOcean:
        return 4; // Fewer, larger creatures
      case BiomeType.abyssalZone:
        return 2; // Sparse, mysterious
    }
  }

  /// Get animation duration in seconds for this creature's biome
  static int getAnimationDuration(BiomeType biome) {
    switch (biome) {
      case BiomeType.shallowWaters:
        return 4; // Fast movement
      case BiomeType.coralGarden:
        return 6; // Medium speed
      case BiomeType.deepOcean:
        return 12; // Slow, graceful
      case BiomeType.abyssalZone:
        return 20; // Very slow, mysterious
    }
  }
}

/// Size categories for visual scaling
enum CreatureSize {
  tiny,    // 0.6x scale
  small,   // 0.8x scale
  medium,  // 1.0x scale
  large,   // 1.3x scale
  huge,    // 1.6x scale
}

extension CreatureSizeExtension on CreatureSize {
  double get scale {
    switch (this) {
      case CreatureSize.tiny:
        return 0.6;
      case CreatureSize.small:
        return 0.8;
      case CreatureSize.medium:
        return 1.0;
      case CreatureSize.large:
        return 1.3;
      case CreatureSize.huge:
        return 1.6;
    }
  }
}

/// Movement patterns for authentic biome behavior
enum MovementPattern {
  schoolingDart,    // Fast, erratic, group movement (shallow waters)
  territorialWeave, // Medium speed, territorial paths (coral garden)
  gracefulCruise,   // Slow, elegant, large arcs (deep ocean)
  mysteriousFloat,  // Very slow, vertical movement (abyssal zone)
}

extension MovementPatternExtension on MovementPattern {
  /// Get curve for this movement pattern
  Curve get animationCurve {
    switch (this) {
      case MovementPattern.schoolingDart:
        return Curves.easeInOut; // Quick direction changes
      case MovementPattern.territorialWeave:
        return Curves.easeInOutCubic; // Smooth territorial paths
      case MovementPattern.gracefulCruise:
        return Curves.linear; // Consistent, elegant movement
      case MovementPattern.mysteriousFloat:
        return Curves.easeInOutSine; // Gentle, floating motion
    }
  }

  /// Get vertical movement amplitude as percentage of screen height
  double get verticalAmplitude {
    switch (this) {
      case MovementPattern.schoolingDart:
        return 0.15; // Small vertical changes
      case MovementPattern.territorialWeave:
        return 0.25; // Moderate weaving
      case MovementPattern.gracefulCruise:
        return 0.35; // Large, graceful arcs
      case MovementPattern.mysteriousFloat:
        return 0.45; // Significant vertical movement
    }
  }

  /// Get horizontal speed variation
  double get speedVariation {
    switch (this) {
      case MovementPattern.schoolingDart:
        return 0.4; // High speed variation
      case MovementPattern.territorialWeave:
        return 0.25; // Moderate variation
      case MovementPattern.gracefulCruise:
        return 0.15; // Low variation
      case MovementPattern.mysteriousFloat:
        return 0.1; // Minimal variation
    }
  }
}

// Static creature definitions for each biome
final List<BiomeCreature> _shallowWaterCreatures = [
  BiomeCreature(
    species: 'Tropical Clownfish',
    biome: BiomeType.shallowWaters,
    size: CreatureSize.small,
    pattern: MovementPattern.schoolingDart,
    primaryColor: Colors.orange.shade600,
    secondaryColor: Colors.white,
    baseSpeed: 1.2,
    schoolingTendency: 0.8,
  ),
  BiomeCreature(
    species: 'Yellow Tang',
    biome: BiomeType.shallowWaters,
    size: CreatureSize.small,
    pattern: MovementPattern.schoolingDart,
    primaryColor: Colors.yellow.shade500,
    secondaryColor: Colors.black,
    baseSpeed: 1.1,
    schoolingTendency: 0.9,
  ),
  BiomeCreature(
    species: 'Blue Damselfish',
    biome: BiomeType.shallowWaters,
    size: CreatureSize.tiny,
    pattern: MovementPattern.schoolingDart,
    primaryColor: Colors.blue.shade400,
    secondaryColor: Colors.lightBlue.shade200,
    baseSpeed: 1.4,
    schoolingTendency: 0.95,
  ),
  BiomeCreature(
    species: 'Green Chromis',
    biome: BiomeType.shallowWaters,
    size: CreatureSize.tiny,
    pattern: MovementPattern.schoolingDart,
    primaryColor: Colors.green.shade400,
    secondaryColor: Colors.white,
    baseSpeed: 1.3,
    schoolingTendency: 0.9,
  ),
];

final List<BiomeCreature> _coralGardenCreatures = [
  BiomeCreature(
    species: 'Rainbow Parrotfish',
    biome: BiomeType.coralGarden,
    size: CreatureSize.medium,
    pattern: MovementPattern.territorialWeave,
    primaryColor: Colors.teal.shade500,
    secondaryColor: Colors.pink.shade300,
    baseSpeed: 0.8,
    schoolingTendency: 0.3,
  ),
  BiomeCreature(
    species: 'Butterflyfish',
    biome: BiomeType.coralGarden,
    size: CreatureSize.small,
    pattern: MovementPattern.territorialWeave,
    primaryColor: Colors.amber.shade400,
    secondaryColor: Colors.black,
    baseSpeed: 0.9,
    schoolingTendency: 0.6,
  ),
  BiomeCreature(
    species: 'Cleaner Wrasse',
    biome: BiomeType.coralGarden,
    size: CreatureSize.small,
    pattern: MovementPattern.territorialWeave,
    primaryColor: Colors.blue.shade500,
    secondaryColor: Colors.yellow,
    baseSpeed: 0.7,
    schoolingTendency: 0.2,
  ),
  BiomeCreature(
    species: 'Coral Grouper',
    biome: BiomeType.coralGarden,
    size: CreatureSize.large,
    pattern: MovementPattern.territorialWeave,
    primaryColor: Colors.red.shade600,
    secondaryColor: Colors.orange.shade300,
    baseSpeed: 0.6,
    schoolingTendency: 0.1,
  ),
];

final List<BiomeCreature> _deepOceanCreatures = [
  BiomeCreature(
    species: 'Reef Shark',
    biome: BiomeType.deepOcean,
    size: CreatureSize.huge,
    pattern: MovementPattern.gracefulCruise,
    primaryColor: Colors.grey.shade600,
    secondaryColor: Colors.white,
    baseSpeed: 0.5,
    schoolingTendency: 0.0,
  ),
  BiomeCreature(
    species: 'Manta Ray',
    biome: BiomeType.deepOcean,
    size: CreatureSize.huge,
    pattern: MovementPattern.gracefulCruise,
    primaryColor: Colors.grey.shade500,
    secondaryColor: Colors.grey.shade300,
    baseSpeed: 0.4,
    schoolingTendency: 0.0,
  ),
  BiomeCreature(
    species: 'Giant Tuna',
    biome: BiomeType.deepOcean,
    size: CreatureSize.large,
    pattern: MovementPattern.gracefulCruise,
    primaryColor: Colors.blue.shade800,
    secondaryColor: Colors.silver,
    baseSpeed: 0.7,
    schoolingTendency: 0.3,
  ),
  BiomeCreature(
    species: 'Barracuda',
    biome: BiomeType.deepOcean,
    size: CreatureSize.large,
    pattern: MovementPattern.gracefulCruise,
    primaryColor: Colors.grey.shade400,
    secondaryColor: Colors.black,
    baseSpeed: 0.8,
    schoolingTendency: 0.2,
  ),
];

final List<BiomeCreature> _abyssalZoneCreatures = [
  BiomeCreature(
    species: 'Deep Anglerfish',
    biome: BiomeType.abyssalZone,
    size: CreatureSize.medium,
    pattern: MovementPattern.mysteriousFloat,
    primaryColor: Colors.black87,
    secondaryColor: Colors.yellow.shade300,
    baseSpeed: 0.3,
    schoolingTendency: 0.0,
  ),
  BiomeCreature(
    species: 'Bioluminescent Jellyfish',
    biome: BiomeType.abyssalZone,
    size: CreatureSize.large,
    pattern: MovementPattern.mysteriousFloat,
    primaryColor: Colors.purple.shade200.withValues(alpha: 0.7),
    secondaryColor: Colors.cyan.shade100.withValues(alpha: 0.5),
    baseSpeed: 0.2,
    schoolingTendency: 0.0,
  ),
];