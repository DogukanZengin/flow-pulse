import '../models/creature.dart';
import '../constants/research_points_constants.dart';

class MarineBiologyCareerService {
  
  /// Career titles based on RP progression (using ResearchPointsConstants)
  /// This uses the same RP thresholds defined in ResearchPointsConstants.careerTitleThresholds
  static Map<int, String> get careerTitles => ResearchPointsConstants.careerTitleThresholds;

  /// Get career title based on cumulative RP (primary method)
  static String getCareerTitle(int cumulativeRP) {
    // Find the highest RP threshold user has achieved
    int highestRP = 0;
    for (final rpThreshold in careerTitles.keys) {
      if (cumulativeRP >= rpThreshold && rpThreshold > highestRP) {
        highestRP = rpThreshold;
      }
    }
    return careerTitles[highestRP] ?? 'Marine Biology Intern';
  }

  /// Get next career milestone information
  static Map<String, dynamic>? getNextCareerMilestone(int cumulativeRP) {
    for (final entry in careerTitles.entries) {
      if (cumulativeRP < entry.key) {
        return {
          'requiredRP': entry.key,
          'title': entry.value,
          'rpNeeded': entry.key - cumulativeRP,
        };
      }
    }
    return null; // Max level reached
  }

  /// Get career progress percentage to next title
  static double getCareerProgress(int cumulativeRP) {
    final currentTitle = getCareerTitle(cumulativeRP);
    final nextMilestone = getNextCareerMilestone(cumulativeRP);

    if (nextMilestone == null) return 1.0; // Max level reached

    // Find current RP threshold
    int currentRP = 0;
    for (final entry in careerTitles.entries) {
      if (entry.value == currentTitle) {
        currentRP = entry.key;
        break;
      }
    }

    final nextRP = nextMilestone['requiredRP'] as int;
    final progressRange = nextRP - currentRP;
    final currentProgress = cumulativeRP - currentRP;

    return progressRange > 0 ? currentProgress / progressRange : 1.0;
  }


  /// Calculate RP bonus based on discovery circumstances (aligned with RP system)
  static int calculateDiscoveryRP(Creature creature, {
    required int cumulativeRP,
    required int sessionDuration,
    bool isFirstDiscovery = false,
    bool isSessionCompleted = true,
    int currentStreak = 1,
  }) {
    int baseRP = creature.pearlValue ~/ 2; // Base RP is lower than pearl value

    // Rarity multiplier (adjusted for RP system)
    double rarityMultiplier = creature.rarity.pearlMultiplier.toDouble() * 0.5;

    // RP milestone bonus (based on cumulative RP, not session depth)
    double rpMilestoneMultiplier = 1.0;
    if (cumulativeRP >= 2250) {
      rpMilestoneMultiplier = 2.0; // Senior Research Scientist+
    } else if (cumulativeRP >= 750) {
      rpMilestoneMultiplier = 1.6; // Field Researcher+
    } else if (cumulativeRP >= 150) {
      rpMilestoneMultiplier = 1.3; // Research Assistant+
    } else if (cumulativeRP >= 50) {
      rpMilestoneMultiplier = 1.1; // Junior Research Assistant+
    }

    // Session completion bonus
    double completionMultiplier = isSessionCompleted ? 1.0 : 0.3;

    // First discovery bonus
    double firstDiscoveryMultiplier = isFirstDiscovery ? 1.5 : 1.0;

    // Streak bonus (consistency reward instead of duration)
    double streakMultiplier = 1.0;
    if (currentStreak >= 30) {
      streakMultiplier = 1.5; // Month+ streak
    } else if (currentStreak >= 14) {
      streakMultiplier = 1.3; // 2+ week streak
    } else if (currentStreak >= 7) {
      streakMultiplier = 1.2; // Week+ streak
    } else if (currentStreak >= 3) {
      streakMultiplier = 1.1; // 3+ day streak
    }

    final totalRP = (baseRP * rarityMultiplier * rpMilestoneMultiplier *
                    completionMultiplier * firstDiscoveryMultiplier * streakMultiplier).round();

    // Cap discovery RP to prevent exploitation
    return totalRP.clamp(1, 15);
  }

  /// Get research specialization based on discoveries
  static String getResearchSpecialization(List<Creature> discoveredCreatures) {
    if (discoveredCreatures.isEmpty) return 'General Marine Biology';
    
    // Count discoveries by biome
    final biomeCount = <BiomeType, int>{};
    for (final creature in discoveredCreatures) {
      biomeCount[creature.habitat] = (biomeCount[creature.habitat] ?? 0) + 1;
    }
    
    // Find dominant biome
    BiomeType? dominantBiome;
    int maxCount = 0;
    for (final entry in biomeCount.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        dominantBiome = entry.key;
      }
    }
    
    // Return specialization based on dominant biome
    switch (dominantBiome) {
      case BiomeType.shallowWaters:
        return 'Coral Reef Ecology';
      case BiomeType.coralGarden:
        return 'Coral Biology & Conservation';
      case BiomeType.deepOcean:
        return 'Deep Sea Biology';
      case BiomeType.abyssalZone:
        return 'Abyssal Ecology';
      default:
        return 'General Marine Biology';
    }
  }

  /// Get research certifications earned based on cumulative RP
  static List<ResearchCertification> getCertifications(
    List<Creature> discoveredCreatures,
    int cumulativeRP,
  ) {
    final certifications = <ResearchCertification>[];

    // RP-based certifications aligned with career progression
    if (cumulativeRP >= 150) { // Research Assistant level
      certifications.add(const ResearchCertification(
        name: 'Marine Biology Fundamentals',
        description: 'Basic understanding of marine ecosystems',
        icon: '🎓',
        earnedAt: '150 RP',
      ));
    }

    if (cumulativeRP >= 500) { // Research Associate level
      certifications.add(const ResearchCertification(
        name: 'Field Research Certification',
        description: 'Qualified to conduct independent field research',
        icon: '🔬',
        earnedAt: '500 RP',
      ));
    }

    if (cumulativeRP >= 1400) { // Senior Marine Biologist level
      certifications.add(const ResearchCertification(
        name: 'Senior Researcher Certification',
        description: 'Authorized to lead research expeditions',
        icon: '🏆',
        earnedAt: '1400 RP',
      ));
    }

    if (cumulativeRP >= 5250) { // Marine Biology Professor level
      certifications.add(const ResearchCertification(
        name: 'Marine Biology Expert',
        description: 'Recognized expert in marine biology',
        icon: '⭐',
        earnedAt: '5250 RP',
      ));
    }

    if (cumulativeRP >= 10500) { // Master Marine Biologist level
      certifications.add(const ResearchCertification(
        name: 'Master Marine Biologist',
        description: 'Ultimate achievement in marine biology research',
        icon: '👑',
        earnedAt: '10500 RP',
      ));
    }
    
    // Discovery-based certifications
    final biomeDiscoveries = <BiomeType, int>{};
    final rarityDiscoveries = <CreatureRarity, int>{};
    
    for (final creature in discoveredCreatures) {
      biomeDiscoveries[creature.habitat] = (biomeDiscoveries[creature.habitat] ?? 0) + 1;
      rarityDiscoveries[creature.rarity] = (rarityDiscoveries[creature.rarity] ?? 0) + 1;
    }
    
    // Biome Explorer Certifications
    for (final biome in BiomeType.values) {
      final count = biomeDiscoveries[biome] ?? 0;
      if (count >= 10) {
        certifications.add(ResearchCertification(
          name: '${biome.displayName} Explorer',
          description: 'Discovered 10+ species in ${biome.displayName}',
          icon: _getBiomeIcon(biome),
          earnedAt: '10 ${biome.displayName} discoveries',
        ));
      }
      
      if (count >= 25) {
        certifications.add(ResearchCertification(
          name: '${biome.displayName} Specialist',
          description: 'Comprehensive knowledge of ${biome.displayName}',
          icon: _getBiomeIcon(biome),
          earnedAt: '25 ${biome.displayName} discoveries',
        ));
      }
    }
    
    // Rarity Hunter Certifications
    if ((rarityDiscoveries[CreatureRarity.rare] ?? 0) >= 5) {
      certifications.add(const ResearchCertification(
        name: 'Rare Species Hunter',
        description: 'Discovered 5+ rare species',
        icon: '💎',
        earnedAt: '5 rare discoveries',
      ));
    }
    
    if ((rarityDiscoveries[CreatureRarity.legendary] ?? 0) >= 1) {
      certifications.add(const ResearchCertification(
        name: 'Legendary Discovery',
        description: 'Found a legendary species',
        icon: '✨',
        earnedAt: '1 legendary discovery',
      ));
    }
    
    // Milestone Certifications
    if (discoveredCreatures.length >= 50) {
      certifications.add(const ResearchCertification(
        name: 'Species Catalog Contributor',
        description: 'Discovered 50+ species',
        icon: '📚',
        earnedAt: '50 total discoveries',
      ));
    }
    
    if (discoveredCreatures.length >= 100) {
      certifications.add(const ResearchCertification(
        name: 'Biodiversity Champion',
        description: 'Major contributor to marine biodiversity research',
        icon: '🌊',
        earnedAt: '100 total discoveries',
      ));
    }
    
    if (discoveredCreatures.length >= 144) {
      certifications.add(const ResearchCertification(
        name: 'Complete Ocean Survey',
        description: 'Discovered every known marine species',
        icon: '🏅',
        earnedAt: 'All 144 species discovered',
      ));
    }
    
    return certifications;
  }

  /// Calculate research productivity metrics
  static ResearchMetrics calculateResearchMetrics(
    List<Creature> discoveredCreatures,
    int totalSessionsCompleted,
    int totalSessionTime,
  ) {
    final now = DateTime.now();
    
    // Calculate discoveries per session
    final discoveriesPerSession = totalSessionsCompleted > 0 
        ? discoveredCreatures.length / totalSessionsCompleted 
        : 0.0;
    
    // Calculate discoveries per hour
    final totalHours = totalSessionTime / 60.0;
    final discoveriesPerHour = totalHours > 0 
        ? discoveredCreatures.length / totalHours 
        : 0.0;
    
    // Calculate recent activity (last 7 days)
    final recentDiscoveries = discoveredCreatures.where((c) => 
      c.discoveredAt != null && 
      now.difference(c.discoveredAt!).inDays <= 7
    ).length;
    
    // Calculate diversity index (Simpson's Diversity Index)
    final biomeCount = <BiomeType, int>{};
    for (final creature in discoveredCreatures) {
      biomeCount[creature.habitat] = (biomeCount[creature.habitat] ?? 0) + 1;
    }
    
    double diversityIndex = 0.0;
    if (discoveredCreatures.isNotEmpty) {
      final total = discoveredCreatures.length;
      for (final count in biomeCount.values) {
        final proportion = count / total;
        diversityIndex += proportion * proportion;
      }
      diversityIndex = 1.0 - diversityIndex; // Simpson's D
    }
    
    // Calculate research efficiency
    final rarityWeights = {
      CreatureRarity.common: 1,
      CreatureRarity.uncommon: 2,
      CreatureRarity.rare: 5,
      CreatureRarity.legendary: 10,
    };
    
    int weightedDiscoveries = 0;
    for (final creature in discoveredCreatures) {
      weightedDiscoveries += rarityWeights[creature.rarity] ?? 1;
    }
    
    final efficiency = totalHours > 0 ? weightedDiscoveries / totalHours : 0.0;
    
    return ResearchMetrics(
      totalDiscoveries: discoveredCreatures.length,
      discoveriesPerSession: discoveriesPerSession,
      discoveriesPerHour: discoveriesPerHour,
      recentDiscoveries: recentDiscoveries,
      diversityIndex: diversityIndex,
      researchEfficiency: efficiency,
      averageSessionTime: totalSessionsCompleted > 0 
          ? totalSessionTime / totalSessionsCompleted 
          : 0.0,
    );
  }

  /// Get research achievements based on progress (RP-based)
  static List<ResearchAchievement> getResearchAchievements(
    List<Creature> discoveredCreatures,
    int cumulativeRP,
    ResearchMetrics metrics,
  ) {
    final achievements = <ResearchAchievement>[];

    // Discovery milestones
    final milestones = [1, 5, 10, 25, 50, 75, 100, 125, 144];
    for (final milestone in milestones) {
      if (discoveredCreatures.length >= milestone) {
        achievements.add(ResearchAchievement(
          name: 'Discovery Milestone',
          description: 'Discovered $milestone species',
          icon: '🎯',
          progress: 1.0,
          target: milestone,
          current: discoveredCreatures.length,
        ));
      }
    }

    // Career RP milestones (major career progression points)
    final rpMilestones = [150, 500, 1050, 2750, 5250, 10500];
    final rpMilestoneNames = [
      'Research Assistant',
      'Research Associate',
      'Marine Biologist',
      'Principal Investigator',
      'Marine Biology Professor',
      'Master Marine Biologist'
    ];

    for (int i = 0; i < rpMilestones.length; i++) {
      final milestone = rpMilestones[i];
      if (cumulativeRP >= milestone) {
        achievements.add(ResearchAchievement(
          name: 'Career Milestone',
          description: 'Achieved ${rpMilestoneNames[i]} ($milestone RP)',
          icon: '📈',
          progress: 1.0,
          target: milestone,
          current: cumulativeRP,
        ));
      }
    }

    // Efficiency achievements
    if (metrics.researchEfficiency >= 10.0) {
      achievements.add(const ResearchAchievement(
        name: 'Research Expert',
        description: 'Achieved high research efficiency',
        icon: '🔬',
        progress: 1.0,
        target: 10,
        current: 10,
      ));
    }

    if (metrics.diversityIndex >= 0.8) {
      achievements.add(const ResearchAchievement(
        name: 'Biodiversity Champion',
        description: 'Excellent species diversity in research',
        icon: '🌈',
        progress: 1.0,
        target: 1,
        current: 1,
      ));
    }

    return achievements;
  }

  static String _getBiomeIcon(BiomeType biome) {
    switch (biome) {
      case BiomeType.shallowWaters:
        return '🏝️';
      case BiomeType.coralGarden:
        return '🪸';
      case BiomeType.deepOcean:
        return '🌊';
      case BiomeType.abyssalZone:
        return '🕳️';
    }
  }
}

/// Research certification earned by the player
class ResearchCertification {
  final String name;
  final String description;
  final String icon;
  final String earnedAt;

  const ResearchCertification({
    required this.name,
    required this.description,
    required this.icon,
    required this.earnedAt,
  });
}

/// Research performance metrics
class ResearchMetrics {
  final int totalDiscoveries;
  final double discoveriesPerSession;
  final double discoveriesPerHour;
  final int recentDiscoveries;
  final double diversityIndex;
  final double researchEfficiency;
  final double averageSessionTime;

  const ResearchMetrics({
    required this.totalDiscoveries,
    required this.discoveriesPerSession,
    required this.discoveriesPerHour,
    required this.recentDiscoveries,
    required this.diversityIndex,
    required this.researchEfficiency,
    required this.averageSessionTime,
  });
}

/// Research achievement
class ResearchAchievement {
  final String name;
  final String description;
  final String icon;
  final double progress;
  final int target;
  final int current;

  const ResearchAchievement({
    required this.name,
    required this.description,
    required this.icon,
    required this.progress,
    required this.target,
    required this.current,
  });
}