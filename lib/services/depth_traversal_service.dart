import '../models/creature.dart';
import 'ocean_biome_service.dart';

/// Service for calculating depth traversal during diving sessions
///
/// Implements the accelerated depth traversal system where:
/// - All dives start at surface (0m)
/// - Descent speed increases with cumulative RP
/// - Higher RP = faster passage through water layers
/// - Discovery opportunities exist at all depths during descent
class DepthTraversalService {
  /// Base descent rate in meters per minute
  static const double baseDescentRate = 2.0;

  /// Calculate current depth based on session time and RP
  static double calculateCurrentDepth(Duration sessionTime, int cumulativeRP) {
    final minutes = sessionTime.inMinutes;
    final multiplier = OceanBiomeService.getDescentMultiplier(cumulativeRP);

    return minutes * baseDescentRate * multiplier;
  }

  /// Calculate depth reached at a specific point in time during session
  static double calculateDepthAtTime(
    Duration elapsedTime,
    int cumulativeRP,
  ) {
    return calculateCurrentDepth(elapsedTime, cumulativeRP);
  }

  /// Get descent speed in meters per minute based on RP
  static double getDescentSpeed(int cumulativeRP) {
    return baseDescentRate * OceanBiomeService.getDescentMultiplier(cumulativeRP);
  }

  /// Get human-readable descent speed description
  static String getDescentSpeedDescription(int cumulativeRP) {
    final multiplier = OceanBiomeService.getDescentMultiplier(cumulativeRP);
    final speed = baseDescentRate * multiplier;

    switch (multiplier.toInt()) {
      case 1:
        return 'Beginner (${speed}m/min)';
      case 2:
        return 'Experienced (${speed}m/min)';
      case 3:
        return 'Expert (${speed}m/min)';
      case 4:
        return 'Master (${speed}m/min)';
      default:
        return 'Advanced (${speed}m/min)';
    }
  }

  /// Calculate the biome progression during a session
  static List<BiomeTransition> calculateBiomeProgression({
    required Duration sessionTime,
    required int cumulativeRP,
  }) {
    final transitions = <BiomeTransition>[];
    final descentSpeed = getDescentSpeed(cumulativeRP);
    final totalMinutes = sessionTime.inMinutes;

    BiomeType? currentBiome;

    // Track progression through each minute
    for (int minute = 0; minute <= totalMinutes; minute++) {
      final depth = minute * descentSpeed;
      final biome = OceanBiomeService.getBiomeAtDepth(depth);

      if (biome != currentBiome) {
        transitions.add(BiomeTransition(
          timeFromStart: Duration(minutes: minute),
          depth: depth,
          biome: biome,
          entrySpeed: descentSpeed,
        ));
        currentBiome = biome;
      }
    }

    return transitions;
  }

  /// Calculate discovery opportunities during descent
  static Map<BiomeType, DiscoveryWindow> calculateDiscoveryWindows({
    required Duration sessionTime,
    required int cumulativeRP,
  }) {
    final windows = <BiomeType, DiscoveryWindow>{};
    final biomeTimeMap = OceanBiomeService.calculateTimeInBiomes(
      sessionTime: sessionTime,
      cumulativeRP: cumulativeRP,
    );

    for (final entry in biomeTimeMap.entries) {
      final biome = entry.key;
      final timeInBiome = entry.value;

      if (timeInBiome.inMinutes > 0) {
        windows[biome] = DiscoveryWindow(
          biome: biome,
          timeSpent: timeInBiome,
          discoveryWeight: OceanBiomeService.getDiscoveryWeight(
            biome: biome,
            timeInBiome: timeInBiome,
          ),
          isEligible: OceanBiomeService.isEligibleForDiscovery(
            biome: biome,
            timeInBiome: timeInBiome,
          ),
        );
      }
    }

    return windows;
  }

  /// Get depth example for different experience levels
  static Map<String, DepthExample> getDepthExamples() {
    const sessionDurations = [10, 25, 45];
    const experienceLevels = [
      (0, 'Beginner'),
      (100, 'Experienced'),
      (300, 'Expert'),
      (600, 'Master'),
    ];

    final examples = <String, DepthExample>{};

    for (final level in experienceLevels) {
      final rp = level.$1;
      final name = level.$2;
      final depths = <int, double>{};

      for (final duration in sessionDurations) {
        final depth = calculateCurrentDepth(Duration(minutes: duration), rp);
        depths[duration] = depth;
      }

      examples[name] = DepthExample(
        experienceLevel: name,
        cumulativeRP: rp,
        sessionDepths: depths,
        descentSpeed: getDescentSpeed(rp),
        multiplier: OceanBiomeService.getDescentMultiplier(rp),
      );
    }

    return examples;
  }

  /// Validate if current depth calculation is consistent with RP system
  static bool validateDepthCalculation(
    Duration sessionTime,
    int cumulativeRP,
    double expectedDepth,
  ) {
    final calculatedDepth = calculateCurrentDepth(sessionTime, cumulativeRP);
    const tolerance = 0.1; // 0.1m tolerance

    return (calculatedDepth - expectedDepth).abs() <= tolerance;
  }

  /// Get the deepest biome accessible with current RP and session time
  static BiomeType getDeepestAccessibleBiome(
    Duration sessionTime,
    int cumulativeRP,
  ) {
    final maxDepth = calculateCurrentDepth(sessionTime, cumulativeRP);
    return OceanBiomeService.getBiomeAtDepth(maxDepth);
  }

  /// Calculate efficiency metrics for traversal
  static TraversalEfficiency calculateEfficiency({
    required Duration sessionTime,
    required int cumulativeRP,
  }) {
    final depth = calculateCurrentDepth(sessionTime, cumulativeRP);
    final biomes = OceanBiomeService.getTraversedBiomes(depth);
    final speed = getDescentSpeed(cumulativeRP);

    return TraversalEfficiency(
      depthReached: depth,
      biomesTraversed: biomes.length,
      averageSpeed: speed,
      efficiency: speed / baseDescentRate, // Efficiency ratio
      experienceMultiplier: OceanBiomeService.getDescentMultiplier(cumulativeRP),
    );
  }
}

/// Represents a transition from one biome to another during descent
class BiomeTransition {
  final Duration timeFromStart;
  final double depth;
  final BiomeType biome;
  final double entrySpeed;

  const BiomeTransition({
    required this.timeFromStart,
    required this.depth,
    required this.biome,
    required this.entrySpeed,
  });

  @override
  String toString() {
    return 'BiomeTransition(time: ${timeFromStart.inMinutes}min, '
           'depth: ${depth.toStringAsFixed(1)}m, '
           'biome: $biome, '
           'speed: ${entrySpeed.toStringAsFixed(1)}m/min)';
  }
}

/// Represents a discovery opportunity window in a specific biome
class DiscoveryWindow {
  final BiomeType biome;
  final Duration timeSpent;
  final double discoveryWeight;
  final bool isEligible;

  const DiscoveryWindow({
    required this.biome,
    required this.timeSpent,
    required this.discoveryWeight,
    required this.isEligible,
  });

  /// Get discovery chance percentage (0-100)
  double get discoveryChancePercent {
    if (!isEligible) return 0.0;
    return (discoveryWeight * 10).clamp(0.0, 100.0);
  }

  @override
  String toString() {
    return 'DiscoveryWindow(biome: $biome, '
           'time: ${timeSpent.inMinutes}min, '
           'weight: ${discoveryWeight.toStringAsFixed(2)}, '
           'eligible: $isEligible)';
  }
}

/// Example depth calculations for different experience levels
class DepthExample {
  final String experienceLevel;
  final int cumulativeRP;
  final Map<int, double> sessionDepths; // duration -> depth
  final double descentSpeed;
  final double multiplier;

  const DepthExample({
    required this.experienceLevel,
    required this.cumulativeRP,
    required this.sessionDepths,
    required this.descentSpeed,
    required this.multiplier,
  });

  @override
  String toString() {
    final depthStrings = sessionDepths.entries
        .map((e) => '${e.key}min: ${e.value.toStringAsFixed(0)}m')
        .join(', ');

    return '$experienceLevel (${cumulativeRP}RP): $depthStrings';
  }
}

/// Efficiency metrics for depth traversal
class TraversalEfficiency {
  final double depthReached;
  final int biomesTraversed;
  final double averageSpeed;
  final double efficiency; // Multiplier over base rate
  final double experienceMultiplier;

  const TraversalEfficiency({
    required this.depthReached,
    required this.biomesTraversed,
    required this.averageSpeed,
    required this.efficiency,
    required this.experienceMultiplier,
  });

  /// Get efficiency grade (A+ to F)
  String get efficiencyGrade {
    if (efficiency >= 4.0) return 'A+';
    if (efficiency >= 3.0) return 'A';
    if (efficiency >= 2.0) return 'B';
    if (efficiency >= 1.5) return 'C';
    return 'D';
  }

  @override
  String toString() {
    return 'TraversalEfficiency(depth: ${depthReached.toStringAsFixed(1)}m, '
           'biomes: $biomesTraversed, '
           'speed: ${averageSpeed.toStringAsFixed(1)}m/min, '
           'grade: $efficiencyGrade)';
  }
}