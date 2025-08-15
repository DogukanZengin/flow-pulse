import '../models/creature.dart';

/// Marine Biology Career Progression System for Phase 2
/// Handles XP tracking, level progression, titles, and certifications
class MarineBiologyCareerService {
  
  /// Career Level Definitions
  static const Map<int, String> careerTitles = {
    1: 'Marine Biology Intern',
    5: 'Junior Research Assistant', 
    10: 'Research Assistant',
    15: 'Marine Biology Student',
    20: 'Research Associate',
    25: 'Field Researcher',
    30: 'Marine Biologist',
    35: 'Senior Marine Biologist',
    40: 'Research Scientist',
    45: 'Senior Research Scientist',
    50: 'Principal Investigator',
    55: 'Marine Biology Expert',
    60: 'Distinguished Researcher',
    65: 'Research Director',
    70: 'Marine Biology Professor',
    75: 'Department Head',
    80: 'Research Institute Director',
    85: 'World-Renowned Expert',
    90: 'Marine Biology Legend',
    95: 'Ocean Pioneer',
    100: 'Master Marine Biologist',
  };

  /// XP required for each level (exponential progression)
  static int getXPRequiredForLevel(int level) {
    if (level <= 1) return 0;
    // Base XP requirement with exponential growth
    return (100 * (level - 1) * 1.15).round() + getXPRequiredForLevel(level - 1);
  }

  /// Calculate current level from total XP
  static int getLevelFromXP(int totalXP) {
    int level = 1;
    while (level <= 100) {
      final requiredXP = getXPRequiredForLevel(level + 1);
      if (totalXP < requiredXP) break;
      level++;
    }
    return level;
  }

  /// Get career title for current level
  static String getCareerTitle(int level) {
    // Find the highest title level that the player has achieved
    int titleLevel = 1;
    for (final entry in careerTitles.entries) {
      if (level >= entry.key) {
        titleLevel = entry.key;
      } else {
        break;
      }
    }
    return careerTitles[titleLevel] ?? 'Marine Biology Intern';
  }

  /// Calculate XP bonus based on discovery circumstances
  static int calculateDiscoveryXP(Creature creature, {
    required double sessionDepth,
    required int sessionDuration,
    bool isFirstDiscovery = false,
    bool isSessionCompleted = true,
  }) {
    int baseXP = creature.pearlValue;
    
    // Rarity multiplier
    double rarityMultiplier = creature.rarity.pearlMultiplier.toDouble();
    
    // Depth bonus (deeper discoveries worth more)
    double depthMultiplier = 1.0;
    if (sessionDepth > 40) {
      depthMultiplier = 2.5; // Abyssal zone
    } else if (sessionDepth > 20) {
      depthMultiplier = 2.0; // Deep ocean
    } else if (sessionDepth > 10) {
      depthMultiplier = 1.5; // Coral garden
    } else {
      depthMultiplier = 1.0; // Shallow waters
    }
    
    // Session completion bonus
    double completionMultiplier = isSessionCompleted ? 1.0 : 0.5;
    
    // First discovery bonus
    double firstDiscoveryMultiplier = isFirstDiscovery ? 2.0 : 1.0;
    
    // Session duration bonus (longer sessions = more research value)
    double durationMultiplier = 1.0;
    if (sessionDuration >= 90) {
      durationMultiplier = 2.0; // Abyssal expeditions
    } else if (sessionDuration >= 60) {
      durationMultiplier = 1.8; // Deep sea research
    } else if (sessionDuration >= 30) {
      durationMultiplier = 1.5; // Mid-water expeditions
    } else if (sessionDuration >= 15) {
      durationMultiplier = 1.2; // Shallow water research
    }
    
    final totalXP = (baseXP * rarityMultiplier * depthMultiplier * 
                    completionMultiplier * firstDiscoveryMultiplier * durationMultiplier).round();
    
    return totalXP;
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

  /// Get research certifications earned
  static List<ResearchCertification> getCertifications(
    List<Creature> discoveredCreatures,
    int totalXP,
    int currentLevel,
  ) {
    final certifications = <ResearchCertification>[];
    
    // Level-based certifications
    if (currentLevel >= 10) {
      certifications.add(const ResearchCertification(
        name: 'Marine Biology Fundamentals',
        description: 'Basic understanding of marine ecosystems',
        icon: '🎓',
        earnedAt: 'Level 10',
      ));
    }
    
    if (currentLevel >= 25) {
      certifications.add(const ResearchCertification(
        name: 'Field Research Certification',
        description: 'Qualified to conduct independent field research',
        icon: '🔬',
        earnedAt: 'Level 25',
      ));
    }
    
    if (currentLevel >= 50) {
      certifications.add(const ResearchCertification(
        name: 'Senior Researcher Certification',
        description: 'Authorized to lead research expeditions',
        icon: '🏆',
        earnedAt: 'Level 50',
      ));
    }
    
    if (currentLevel >= 75) {
      certifications.add(const ResearchCertification(
        name: 'Marine Biology Expert',
        description: 'Recognized expert in marine biology',
        icon: '⭐',
        earnedAt: 'Level 75',
      ));
    }
    
    if (currentLevel >= 100) {
      certifications.add(const ResearchCertification(
        name: 'Master Marine Biologist',
        description: 'Ultimate achievement in marine biology research',
        icon: '👑',
        earnedAt: 'Level 100',
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

  /// Get research achievements based on progress
  static List<ResearchAchievement> getResearchAchievements(
    List<Creature> discoveredCreatures,
    int currentLevel,
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
    
    // Level achievements
    final levelMilestones = [10, 25, 50, 75, 100];
    for (final milestone in levelMilestones) {
      if (currentLevel >= milestone) {
        achievements.add(ResearchAchievement(
          name: 'Career Milestone',
          description: 'Reached level $milestone',
          icon: '📈',
          progress: 1.0,
          target: milestone,
          current: currentLevel,
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