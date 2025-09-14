import 'dart:math';
import '../models/creature.dart';

/// Service for managing ocean biomes and depth-based content
/// Part of the RP-based hybrid leveling system implementation
class OceanBiomeService {
  static const Map<BiomeType, DepthRange> biomeDepthRanges = {
    BiomeType.shallowWaters: DepthRange(0, 20),
    BiomeType.coralGarden: DepthRange(20, 50),
    BiomeType.deepOcean: DepthRange(50, 100),
    BiomeType.abyssalZone: DepthRange(100, double.infinity),
  };

  static const Map<BiomeType, String> biomeDescriptions = {
    BiomeType.shallowWaters: 'Sunlit Surface Waters',
    BiomeType.coralGarden: 'Vibrant Coral Gardens',
    BiomeType.deepOcean: 'Deep Ocean Twilight',
    BiomeType.abyssalZone: 'Abyssal Depths',
  };

  static const Map<BiomeType, List<String>> biomeCharacteristics = {
    BiomeType.shallowWaters: [
      'Bright sunlight penetration',
      'Warm water temperatures',
      'High oxygen levels',
      'Diverse small fish species',
    ],
    BiomeType.coralGarden: [
      'Colorful coral formations',
      'Complex reef ecosystems',
      'Medium light levels',
      'Rich biodiversity',
    ],
    BiomeType.deepOcean: [
      'Minimal sunlight',
      'Cooler temperatures',
      'Larger predatory species',
      'Bioluminescent creatures',
    ],
    BiomeType.abyssalZone: [
      'Complete darkness',
      'Near-freezing temperatures',
      'Extreme pressure',
      'Rare legendary species',
    ],
  };

  /// Get the biome type for a specific depth
  static BiomeType getBiomeAtDepth(double depth) {
    for (final entry in biomeDepthRanges.entries) {
      if (depth >= entry.value.min && depth < entry.value.max) {
        return entry.key;
      }
    }
    return BiomeType.abyssalZone; // Default to abyssal for extreme depths
  }

  /// Get all biomes traversed from surface to current depth
  static List<BiomeType> getTraversedBiomes(double currentDepth) {
    final traversed = <BiomeType>[];

    for (final entry in biomeDepthRanges.entries) {
      if (currentDepth > entry.value.min) {
        traversed.add(entry.key);
      }
      if (currentDepth < entry.value.max) {
        break; // No need to check deeper biomes
      }
    }

    return traversed;
  }

  /// Calculate time spent in each biome during descent
  static Map<BiomeType, Duration> calculateTimeInBiomes({
    required Duration sessionTime,
    required int cumulativeRP,
  }) {
    final timeInBiomes = <BiomeType, Duration>{};

    // Get descent rate based on RP
    final descentRate = getDescentRate(cumulativeRP);
    final totalMinutes = sessionTime.inMinutes;

    double currentDepth = 0;
    double minutesElapsed = 0;

    for (final entry in biomeDepthRanges.entries.toList()) {
      final biome = entry.key;
      final range = entry.value;

      if (minutesElapsed >= totalMinutes) break;

      // Calculate time to traverse this biome
      final depthToTraverse = min(
        range.max - currentDepth,
        (totalMinutes - minutesElapsed) * descentRate,
      );

      if (depthToTraverse > 0) {
        final minutesInBiome = depthToTraverse / descentRate;
        timeInBiomes[biome] = Duration(
          minutes: minutesInBiome.round(),
        );

        minutesElapsed += minutesInBiome;
        currentDepth += depthToTraverse;
      }

      if (currentDepth >= range.max && range.max != double.infinity) {
        currentDepth = range.max;
      } else {
        break; // Haven't fully traversed this biome
      }
    }

    return timeInBiomes;
  }

  /// Get the descent rate in meters per minute based on cumulative RP
  static double getDescentRate(int cumulativeRP) {
    const baseRate = 2.0; // meters per minute
    final multiplier = getDescentMultiplier(cumulativeRP);
    return baseRate * multiplier;
  }

  /// Get the descent speed multiplier based on experience (RP)
  static double getDescentMultiplier(int cumulativeRP) {
    // Using depth zone boundaries from ResearchPointsConstants
    if (cumulativeRP >= 501) {
      return 4.0; // Master (Abyssal Zone): 8m/min
    } else if (cumulativeRP >= 201) {
      return 3.0; // Expert (Deep Ocean): 6m/min
    } else if (cumulativeRP >= 51) {
      return 2.0; // Experienced (Coral Garden): 4m/min
    }
    return 1.0; // Beginner (Shallow Waters): 2m/min
  }

  /// Check if a biome is accessible based on depth reached
  static bool isBiomeAccessible(BiomeType biome, double depthReached) {
    final range = biomeDepthRanges[biome];
    if (range == null) return false;
    return depthReached >= range.min;
  }

  /// Get discovery eligibility for a biome based on time spent
  static bool isEligibleForDiscovery({
    required BiomeType biome,
    required Duration timeInBiome,
  }) {
    // Minimum time requirements for discovery eligibility
    const minTimeForDiscovery = {
      BiomeType.shallowWaters: Duration(minutes: 2),
      BiomeType.coralGarden: Duration(minutes: 3),
      BiomeType.deepOcean: Duration(minutes: 4),
      BiomeType.abyssalZone: Duration(minutes: 5),
    };

    final required = minTimeForDiscovery[biome] ?? Duration(minutes: 2);
    return timeInBiome >= required;
  }

  /// Calculate discovery weight based on time spent in biome
  static double getDiscoveryWeight({
    required BiomeType biome,
    required Duration timeInBiome,
  }) {
    if (!isEligibleForDiscovery(biome: biome, timeInBiome: timeInBiome)) {
      return 0.0;
    }

    // Base weight increases with time spent
    final minutes = timeInBiome.inMinutes;

    // Biome-specific weight multipliers
    const biomeMultipliers = {
      BiomeType.shallowWaters: 1.0,
      BiomeType.coralGarden: 1.2,
      BiomeType.deepOcean: 1.5,
      BiomeType.abyssalZone: 2.0,
    };

    final multiplier = biomeMultipliers[biome] ?? 1.0;

    // Weight formula: sqrt(minutes) * multiplier
    // This gives diminishing returns for very long times in one biome
    return sqrt(minutes) * multiplier;
  }

  /// Get the visual color gradient for a biome
  static List<int> getBiomeColorGradient(BiomeType biome) {
    switch (biome) {
      case BiomeType.shallowWaters:
        return [0xFF00BCD4, 0xFF0097A7]; // Cyan gradient
      case BiomeType.coralGarden:
        return [0xFF0097A7, 0xFF00838F]; // Teal gradient
      case BiomeType.deepOcean:
        return [0xFF00838F, 0xFF006064]; // Dark teal gradient
      case BiomeType.abyssalZone:
        return [0xFF006064, 0xFF263238]; // Deep blue to dark gradient
    }
  }

  /// Get ambient light level for depth (0.0 to 1.0)
  static double getAmbientLightLevel(double depth) {
    if (depth <= 20) {
      return 1.0; // Full sunlight in shallow waters
    } else if (depth <= 50) {
      return 0.7 - ((depth - 20) / 30) * 0.3; // Gradual dimming in coral garden
    } else if (depth <= 100) {
      return 0.4 - ((depth - 50) / 50) * 0.3; // Twilight zone
    } else {
      return 0.1; // Minimal bioluminescent light only
    }
  }

  /// Get pressure level for depth (affects UI and sound)
  static double getPressureLevel(double depth) {
    // Pressure increases by approximately 1 atmosphere every 10 meters
    return 1.0 + (depth / 10.0);
  }
}

/// Represents a depth range for a biome
class DepthRange {
  final double min;
  final double max;

  const DepthRange(this.min, this.max);

  bool contains(double depth) => depth >= min && depth < max;
}