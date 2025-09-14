import '../models/creature.dart';

/// Constants for the accelerated depth traversal system
///
/// This system allows experienced divers (higher RP) to descend faster
/// through water layers while maintaining discovery opportunities at all depths.
class DepthConstants {
  DepthConstants._();

  // Base Traversal System
  static const double baseDescentRateMetersPerMinute = 2.0;

  // Experience Level Multipliers (based on cumulative RP)
  static const Map<String, DescentProfile> experienceProfiles = {
    'beginner': DescentProfile(
      rpThreshold: 0,
      speedMultiplier: 1.0,
      description: 'Beginner Diver',
      maxDepthPerSession: 60.0, // 30min * 2m/min
    ),
    'experienced': DescentProfile(
      rpThreshold: 51,
      speedMultiplier: 2.0,
      description: 'Experienced Diver',
      maxDepthPerSession: 120.0, // 30min * 4m/min
    ),
    'expert': DescentProfile(
      rpThreshold: 201,
      speedMultiplier: 3.0,
      description: 'Expert Diver',
      maxDepthPerSession: 180.0, // 30min * 6m/min
    ),
    'master': DescentProfile(
      rpThreshold: 501,
      speedMultiplier: 4.0,
      description: 'Master Diver',
      maxDepthPerSession: 240.0, // 30min * 8m/min
    ),
  };

  // Biome Depth Boundaries
  static const Map<BiomeType, BiomeDepthInfo> biomeDepthBoundaries = {
    BiomeType.shallowWaters: BiomeDepthInfo(
      minDepth: 0.0,
      maxDepth: 20.0,
      name: 'Shallow Waters',
      characteristics: [
        'Sunlit surface waters',
        'High oxygen content',
        'Small reef fish',
        'Easy navigation',
      ],
      minTimeForDiscovery: Duration(minutes: 2),
    ),
    BiomeType.coralGarden: BiomeDepthInfo(
      minDepth: 20.0,
      maxDepth: 50.0,
      name: 'Coral Garden',
      characteristics: [
        'Vibrant coral formations',
        'Rich ecosystem diversity',
        'Colorful marine life',
        'Complex reef structures',
      ],
      minTimeForDiscovery: Duration(minutes: 3),
    ),
    BiomeType.deepOcean: BiomeDepthInfo(
      minDepth: 50.0,
      maxDepth: 100.0,
      name: 'Deep Ocean',
      characteristics: [
        'Reduced sunlight',
        'Larger marine species',
        'Cooler water temperatures',
        'Increased pressure',
      ],
      minTimeForDiscovery: Duration(minutes: 4),
    ),
    BiomeType.abyssalZone: BiomeDepthInfo(
      minDepth: 100.0,
      maxDepth: double.infinity,
      name: 'Abyssal Zone',
      characteristics: [
        'Complete darkness',
        'Extreme pressure',
        'Rare species',
        'Bioluminescent life',
      ],
      minTimeForDiscovery: Duration(minutes: 5),
    ),
  };

  // Session Duration Examples
  static const Map<int, SessionDepthExample> sessionExamples = {
    10: SessionDepthExample(
      durationMinutes: 10,
      beginnerDepth: 20.0,
      experiencedDepth: 40.0,
      expertDepth: 60.0,
      masterDepth: 80.0,
    ),
    25: SessionDepthExample(
      durationMinutes: 25,
      beginnerDepth: 50.0,
      experiencedDepth: 100.0,
      expertDepth: 150.0,
      masterDepth: 200.0,
    ),
    45: SessionDepthExample(
      durationMinutes: 45,
      beginnerDepth: 90.0,
      experiencedDepth: 180.0,
      expertDepth: 270.0,
      masterDepth: 360.0,
    ),
  };

  // Discovery System Constants
  static const double baseDiscoveryChancePerBiome = 0.3; // 30% base chance

  static const Map<BiomeType, double> biomeDiscoveryMultipliers = {
    BiomeType.shallowWaters: 1.2, // +20% discovery chance (many small species)
    BiomeType.coralGarden: 1.0,   // Base discovery chance
    BiomeType.deepOcean: 0.8,     // -20% discovery chance (sparse species)
    BiomeType.abyssalZone: 0.4,   // -60% discovery chance (very rare species)
  };

  // Visual and Audio Constants
  static const Map<BiomeType, BiomeAesthetics> biomeAesthetics = {
    BiomeType.shallowWaters: BiomeAesthetics(
      primaryColor: 0xFF00BCD4,
      secondaryColor: 0xFF0097A7,
      lightLevel: 1.0,
      particleDensity: 0.7,
      soundProfile: 'gentle_waves',
    ),
    BiomeType.coralGarden: BiomeAesthetics(
      primaryColor: 0xFF0097A7,
      secondaryColor: 0xFF00838F,
      lightLevel: 0.7,
      particleDensity: 1.0,
      soundProfile: 'reef_ambience',
    ),
    BiomeType.deepOcean: BiomeAesthetics(
      primaryColor: 0xFF00838F,
      secondaryColor: 0xFF006064,
      lightLevel: 0.3,
      particleDensity: 0.4,
      soundProfile: 'deep_ocean',
    ),
    BiomeType.abyssalZone: BiomeAesthetics(
      primaryColor: 0xFF006064,
      secondaryColor: 0xFF263238,
      lightLevel: 0.1,
      particleDensity: 0.2,
      soundProfile: 'abyss_mystery',
    ),
  };

  // Utility methods for depth calculations
  static double calculateDepthForSession(int durationMinutes, int cumulativeRP) {
    final multiplier = getSpeedMultiplierForRP(cumulativeRP);
    return durationMinutes * baseDescentRateMetersPerMinute * multiplier;
  }

  static double getSpeedMultiplierForRP(int cumulativeRP) {
    if (cumulativeRP >= 501) return 4.0; // Master
    if (cumulativeRP >= 201) return 3.0; // Expert
    if (cumulativeRP >= 51) return 2.0;  // Experienced
    return 1.0; // Beginner
  }

  static BiomeType getBiomeAtDepth(double depth) {
    for (final entry in biomeDepthBoundaries.entries) {
      if (depth >= entry.value.minDepth && depth < entry.value.maxDepth) {
        return entry.key;
      }
    }
    return BiomeType.abyssalZone; // Default for extreme depths
  }

  static String getExperienceLevelName(int cumulativeRP) {
    if (cumulativeRP >= 501) return 'Master Diver';
    if (cumulativeRP >= 201) return 'Expert Diver';
    if (cumulativeRP >= 51) return 'Experienced Diver';
    return 'Beginner Diver';
  }
}

/// Represents a descent profile for a specific experience level
class DescentProfile {
  final int rpThreshold;
  final double speedMultiplier;
  final String description;
  final double maxDepthPerSession; // Theoretical max depth for 30min session

  const DescentProfile({
    required this.rpThreshold,
    required this.speedMultiplier,
    required this.description,
    required this.maxDepthPerSession,
  });

  double get speedMetersPerMinute =>
      DepthConstants.baseDescentRateMetersPerMinute * speedMultiplier;

  @override
  String toString() {
    return '$description (${speedMetersPerMinute}m/min)';
  }
}

/// Information about a specific biome's depth range and characteristics
class BiomeDepthInfo {
  final double minDepth;
  final double maxDepth;
  final String name;
  final List<String> characteristics;
  final Duration minTimeForDiscovery;

  const BiomeDepthInfo({
    required this.minDepth,
    required this.maxDepth,
    required this.name,
    required this.characteristics,
    required this.minTimeForDiscovery,
  });

  bool containsDepth(double depth) {
    return depth >= minDepth && depth < maxDepth;
  }

  double get depthRange => maxDepth == double.infinity
      ? double.infinity
      : maxDepth - minDepth;

  @override
  String toString() {
    final maxStr = maxDepth == double.infinity ? '∞' : '${maxDepth.toInt()}';
    return '$name (${minDepth.toInt()}m - ${maxStr}m)';
  }
}

/// Example depths reached at different experience levels for a session duration
class SessionDepthExample {
  final int durationMinutes;
  final double beginnerDepth;
  final double experiencedDepth;
  final double expertDepth;
  final double masterDepth;

  const SessionDepthExample({
    required this.durationMinutes,
    required this.beginnerDepth,
    required this.experiencedDepth,
    required this.expertDepth,
    required this.masterDepth,
  });

  double getDepthForRP(int cumulativeRP) {
    if (cumulativeRP >= 501) return masterDepth;
    if (cumulativeRP >= 201) return expertDepth;
    if (cumulativeRP >= 51) return experiencedDepth;
    return beginnerDepth;
  }

  @override
  String toString() {
    return '${durationMinutes}min: ${beginnerDepth}m → ${masterDepth}m';
  }
}

/// Visual and audio aesthetics for a biome
class BiomeAesthetics {
  final int primaryColor;
  final int secondaryColor;
  final double lightLevel; // 0.0 to 1.0
  final double particleDensity; // 0.0 to 1.0
  final String soundProfile;

  const BiomeAesthetics({
    required this.primaryColor,
    required this.secondaryColor,
    required this.lightLevel,
    required this.particleDensity,
    required this.soundProfile,
  });

  @override
  String toString() {
    return 'BiomeAesthetics(light: ${(lightLevel * 100).toInt()}%, '
           'particles: ${(particleDensity * 100).toInt()}%)';
  }
}