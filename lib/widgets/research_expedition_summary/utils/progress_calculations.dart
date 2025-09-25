import '../models/expedition_result.dart';

/// Extension methods for calculating progression percentages
/// Used by ProgressIndicatorWidget to display progress bars
extension ProgressCalculations on ExpeditionResult {

  /// Calculate progress to next level based on cumulative RP
  double get progressToNextLevel {
    // Level thresholds (from gamification_service.dart patterns)
    final levelThresholds = [
      0,     // Level 1
      100,   // Level 2
      250,   // Level 3
      450,   // Level 4
      700,   // Level 5
      1000,  // Level 6
      1400,  // Level 7
      1900,  // Level 8
      2500,  // Level 9
      3200,  // Level 10
      4000,  // Level 11
      4900,  // Level 12
      5900,  // Level 13
      7000,  // Level 14
      8200,  // Level 15
      9500,  // Level 16
      10900, // Level 17
      12400, // Level 18
      14000, // Level 19
      15700, // Level 20
    ];

    // Find current level and next threshold
    int currentLevel = newLevel;
    if (currentLevel >= levelThresholds.length) {
      // Max level reached
      return 1.0;
    }

    if (currentLevel < 1) currentLevel = 1;

    final currentThreshold = levelThresholds[currentLevel - 1];
    final nextThreshold = currentLevel < levelThresholds.length
        ? levelThresholds[currentLevel]
        : levelThresholds.last + 2000; // Estimate for levels beyond 20

    final progressInLevel = cumulativeRP - currentThreshold;
    final requiredForNext = nextThreshold - currentThreshold;

    if (requiredForNext <= 0) return 1.0;

    return (progressInLevel / requiredForNext).clamp(0.0, 1.0);
  }

  /// Get RP needed to reach next level
  int get rpToNextLevel {
    final levelThresholds = [
      0, 100, 250, 450, 700, 1000, 1400, 1900, 2500, 3200,
      4000, 4900, 5900, 7000, 8200, 9500, 10900, 12400, 14000, 15700,
    ];

    int currentLevel = newLevel;
    if (currentLevel >= levelThresholds.length) return 0;
    if (currentLevel < 1) currentLevel = 1;

    final nextThreshold = currentLevel < levelThresholds.length
        ? levelThresholds[currentLevel]
        : levelThresholds.last + 2000;

    return (nextThreshold - cumulativeRP).clamp(0, 999999);
  }

  /// Calculate career progression (simplified since we don't have full career data)
  double get progressToNextCareer {
    // Career progression milestones (estimated from patterns)
    final careerThresholds = {
      'Student Researcher': 0,
      'Junior Marine Biologist': 500,
      'Marine Biologist': 1500,
      'Senior Marine Biologist': 3000,
      'Lead Researcher': 5000,
      'Principal Scientist': 8000,
      'Research Director': 12000,
      'Chief Scientist': 18000,
    };

    final currentTitle = newCareerTitle ?? 'Student Researcher';
    final titles = careerThresholds.keys.toList();
    final currentIndex = titles.indexOf(currentTitle);

    if (currentIndex == -1 || currentIndex >= titles.length - 1) {
      return 1.0; // Max career or unknown
    }

    final currentThreshold = careerThresholds[currentTitle] ?? 0;
    final nextTitle = titles[currentIndex + 1];
    final nextThreshold = careerThresholds[nextTitle] ?? 0;

    if (nextThreshold <= currentThreshold) return 1.0;

    final progress = cumulativeRP - currentThreshold;
    final required = nextThreshold - currentThreshold;

    return (progress / required).clamp(0.0, 1.0);
  }

  /// Get RP needed for next career advancement
  int get rpToNextCareer {
    final careerThresholds = {
      'Student Researcher': 0,
      'Junior Marine Biologist': 500,
      'Marine Biologist': 1500,
      'Senior Marine Biologist': 3000,
      'Lead Researcher': 5000,
      'Principal Scientist': 8000,
      'Research Director': 12000,
      'Chief Scientist': 18000,
    };

    final currentTitle = newCareerTitle ?? 'Student Researcher';
    final titles = careerThresholds.keys.toList();
    final currentIndex = titles.indexOf(currentTitle);

    if (currentIndex == -1 || currentIndex >= titles.length - 1) {
      return 0;
    }

    final nextTitle = titles[currentIndex + 1];
    final nextThreshold = careerThresholds[nextTitle] ?? 0;

    return (nextThreshold - cumulativeRP).clamp(0, 999999);
  }

  /// Get next career title
  String? get nextCareerTitle {
    final careerProgression = [
      'Student Researcher',
      'Junior Marine Biologist',
      'Marine Biologist',
      'Senior Marine Biologist',
      'Lead Researcher',
      'Principal Scientist',
      'Research Director',
      'Chief Scientist',
    ];

    final currentTitle = newCareerTitle ?? 'Student Researcher';
    final currentIndex = careerProgression.indexOf(currentTitle);

    if (currentIndex == -1 || currentIndex >= careerProgression.length - 1) {
      return null;
    }

    return careerProgression[currentIndex + 1];
  }

  /// Calculate depth zone progression based on cumulative RP
  double get depthZoneProgress {
    // Depth zone thresholds (from depth_traversal_service.dart patterns)
    final depthThresholds = {
      'Shallow Waters': 0,
      'Coral Garden': 300,
      'Deep Ocean': 1000,
      'Abyssal Zone': 3000,
      'Hadal Zone': 10000, // Future zone
    };

    final zones = depthThresholds.keys.toList();
    final currentIndex = zones.indexOf(currentDepthZone);

    if (currentIndex == -1 || currentIndex >= zones.length - 1) {
      return 1.0;
    }

    final currentThreshold = depthThresholds[currentDepthZone] ?? 0;
    final nextZone = zones[currentIndex + 1];
    final nextThreshold = depthThresholds[nextZone] ?? 0;

    if (nextThreshold <= currentThreshold) return 1.0;

    final progress = cumulativeRP - currentThreshold;
    final required = nextThreshold - currentThreshold;

    return (progress / required).clamp(0.0, 1.0);
  }

  /// Get RP needed to reach next depth zone
  int get rpToNextDepthZone {
    final depthThresholds = {
      'Shallow Waters': 0,
      'Coral Garden': 300,
      'Deep Ocean': 1000,
      'Abyssal Zone': 3000,
      'Hadal Zone': 10000,
    };

    final zones = depthThresholds.keys.toList();
    final currentIndex = zones.indexOf(currentDepthZone);

    if (currentIndex == -1 || currentIndex >= zones.length - 1) {
      return 0;
    }

    final nextZone = zones[currentIndex + 1];
    final nextThreshold = depthThresholds[nextZone] ?? 0;

    return (nextThreshold - cumulativeRP).clamp(0, 999999);
  }

  /// Get next depth zone name
  String? get nextDepthZone {
    final zones = [
      'Shallow Waters',
      'Coral Garden',
      'Deep Ocean',
      'Abyssal Zone',
      'Hadal Zone',
    ];

    final currentIndex = zones.indexOf(currentDepthZone);

    if (currentIndex == -1 || currentIndex >= zones.length - 1) {
      return null;
    }

    return zones[currentIndex + 1];
  }

  /// Calculate collection progress (simplified estimate)
  double get collectionProgress {
    // Estimate based on discovered creatures
    // Typical biome has ~20-30 species
    const estimatedTotalSpecies = 25;
    final discovered = allDiscoveredCreatures.length;

    return (discovered / estimatedTotalSpecies).clamp(0.0, 1.0);
  }

  /// Get estimated species left to discover
  int get speciesLeftToDiscover {
    const estimatedTotalSpecies = 25;
    final discovered = allDiscoveredCreatures.length;
    return (estimatedTotalSpecies - discovered).clamp(0, estimatedTotalSpecies);
  }
}