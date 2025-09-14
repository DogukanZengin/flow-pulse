import 'package:flutter/material.dart';
import '../../../models/creature.dart';

/// Enhanced expedition result model that wraps GamificationReward with additional
/// research narrative and celebration configuration
class ExpeditionResult {
  // Core session data
  final int dataPointsCollected;
  final String researchNarrative;
  final String depthDescription;
  final MarineBiologyCareerLevel careerProgression;
  
  // Core reward data (RP-based system)
  final int rpGained;  // Total RP gained this session
  final int baseRP;     // Base RP from session duration
  final int bonusRP;    // Total bonus RP (break + streak + quality)
  final bool leveledUp;
  final int oldLevel;
  final int newLevel;
  final int currentStreak;
  
  // Career progression (enhanced)
  final String? oldCareerTitle;
  final String? newCareerTitle;
  final bool careerTitleChanged;
  final String? careerAdvancementNarrative;
  
  // Equipment and achievements (enhanced with narratives)
  final List<String> unlockedThemes;
  final List<ResearchAchievement> unlockedAchievements;
  final List<EquipmentUnlock> unlockedEquipment;
  
  // Species discoveries (enhanced)
  final dynamic discoveredCreature;
  final List<dynamic> allDiscoveredCreatures;
  final List<SpeciesDiscoveryNarrative> discoveryNarratives;
  
  // Research progress
  final int researchPapersUnlocked;
  final List<String> researchPaperIds;
  
  // Session quality metrics
  final int sessionDurationMinutes;
  final double sessionDepthReached;
  final bool sessionCompleted;
  final bool isStudySession;
  final double researchEfficiency;
  final SessionQualityAssessment qualityAssessment;
  
  // Streak and bonus information
  final int streakBonusRP;  // Bonus RP from streak
  final int breakAdherenceBonus;  // Bonus RP from break adherence
  final int qualityBonus;  // Bonus RP from session quality
  final int cumulativeRP;  // Total RP accumulated all-time
  final String currentDepthZone;  // Current depth zone from RP
  final String streakBonusNarrative;
  
  // Progress hints
  final String? nextEquipmentHint;
  final String? nextAchievementHint;
  final String? nextCareerMilestone;
  
  // Celebration configuration
  final CelebrationIntensity celebrationLevel;
  final BiomeType sessionBiome;
  final List<CelebrationEffect> celebrationEffects;

  const ExpeditionResult({
    required this.dataPointsCollected,
    required this.researchNarrative,
    required this.depthDescription,
    required this.careerProgression,
    required this.rpGained,
    this.baseRP = 0,
    this.bonusRP = 0,
    required this.leveledUp,
    required this.oldLevel,
    required this.newLevel,
    required this.currentStreak,
    this.oldCareerTitle,
    this.newCareerTitle,
    required this.careerTitleChanged,
    this.careerAdvancementNarrative,
    required this.unlockedThemes,
    required this.unlockedAchievements,
    required this.unlockedEquipment,
    this.discoveredCreature,
    required this.allDiscoveredCreatures,
    required this.discoveryNarratives,
    required this.researchPapersUnlocked,
    required this.researchPaperIds,
    required this.sessionDurationMinutes,
    required this.sessionDepthReached,
    required this.sessionCompleted,
    required this.isStudySession,
    required this.researchEfficiency,
    required this.qualityAssessment,
    required this.streakBonusRP,
    required this.breakAdherenceBonus,
    required this.qualityBonus,
    required this.cumulativeRP,
    required this.currentDepthZone,
    required this.streakBonusNarrative,
    this.nextEquipmentHint,
    this.nextAchievementHint,
    this.nextCareerMilestone,
    required this.celebrationLevel,
    required this.sessionBiome,
    required this.celebrationEffects,
  });

  /// Calculate total research value (RP-based)
  int get totalResearchValue {
    int total = rpGained; 
    if (discoveredCreature != null && discoveredCreature is Creature) {
      total += (discoveredCreature as Creature).pearlValue;
    }
    for (final creature in allDiscoveredCreatures) {
      if (creature is Creature) {
        total += creature.pearlValue;
      }
    }
    return total;
  }

  /// Get RP breakdown as readable string
  String get rpBreakdown {
    final parts = <String>[];
    if (baseRP > 0) parts.add('Base: $baseRP');
    if (streakBonusRP > 0) parts.add('Streak: +$streakBonusRP');
    if (breakAdherenceBonus > 0) parts.add('Break: +$breakAdherenceBonus');
    if (qualityBonus > 0) parts.add('Quality: +$qualityBonus');
    return parts.isEmpty ? 'No RP earned' : parts.join(', ');
  }

  /// Check if this session has significant accomplishments
  bool get hasSignificantAccomplishments {
    return leveledUp || 
           careerTitleChanged || 
           unlockedEquipment.isNotEmpty || 
           unlockedAchievements.isNotEmpty ||
           discoveredCreature != null ||
           allDiscoveredCreatures.isNotEmpty ||
           researchPapersUnlocked > 0 ||
           currentStreak >= 7;
  }

  /// Get celebration intensity as a value between 0.0 and 1.0
  double get celebrationIntensity {
    double intensity = 0.1; // Base intensity
    
    if (leveledUp) intensity += 0.3;
    if (careerTitleChanged) intensity += 0.25;
    intensity += unlockedEquipment.length * 0.15;
    intensity += unlockedAchievements.length * 0.2;
    
    if (allDiscoveredCreatures.isNotEmpty) {
      intensity += 0.2;
      for (final creature in allDiscoveredCreatures) {
        if (creature is Creature) {
          switch (creature.rarity) {
            case CreatureRarity.uncommon: 
              intensity += 0.05;
              break;
            case CreatureRarity.rare: 
              intensity += 0.1;
              break;
            case CreatureRarity.legendary: 
              intensity += 0.2;
              break;
            case CreatureRarity.common: 
              break;
          }
        }
      }
    }
    
    // Streak milestones
    if (currentStreak >= 100) {
      intensity += 0.3;
    } else if (currentStreak >= 30) {
      intensity += 0.2;
    } else if (currentStreak >= 14) {
      intensity += 0.15;
    } else if (currentStreak >= 7) {
      intensity += 0.1;
    }
    
    // Research efficiency
    if (researchEfficiency >= 8.0) {
      intensity += 0.2;
    } else if (researchEfficiency >= 6.0) {
      intensity += 0.15;
    } else if (researchEfficiency >= 4.0) {
      intensity += 0.1;
    }
    
    return intensity.clamp(0.0, 1.0);
  }

  /// Get the primary biome for this session based on depth
  BiomeType getPrimaryBiome() {
    if (sessionDepthReached <= 10.0) return BiomeType.shallowWaters;
    if (sessionDepthReached <= 30.0) return BiomeType.coralGarden;
    if (sessionDepthReached <= 100.0) return BiomeType.deepOcean;
    return BiomeType.abyssalZone;
  }
}

/// Marine biology career level information
class MarineBiologyCareerLevel {
  final int level;
  final String title;
  final String description;
  final String researchCapabilities;
  final List<String> unlockedEquipment;

  const MarineBiologyCareerLevel({
    required this.level,
    required this.title,
    required this.description,
    required this.researchCapabilities,
    required this.unlockedEquipment,
  });

  static MarineBiologyCareerLevel fromLevel(int level) {
    if (level <= 1) {
      return const MarineBiologyCareerLevel(
        level: 1,
        title: 'Research Intern',
        description: 'Beginning your journey in marine science',
        researchCapabilities: 'Basic underwater observation and note-taking',
        unlockedEquipment: ['Research Notebook', 'Basic Snorkel Mask'],
      );
    } else if (level <= 3) {
      return const MarineBiologyCareerLevel(
        level: 2,
        title: 'Field Assistant',
        description: 'Supporting marine research expeditions',
        researchCapabilities: 'Species counting and basic photography',
        unlockedEquipment: ['Waterproof Camera', 'Fish ID Guide'],
      );
    } else if (level <= 5) {
      return const MarineBiologyCareerLevel(
        level: 4,
        title: 'Research Associate',
        description: 'Contributing to scientific studies',
        researchCapabilities: 'Data collection and preliminary analysis',
        unlockedEquipment: ['Underwater Tablet', 'Sample Containers'],
      );
    } else if (level <= 8) {
      return const MarineBiologyCareerLevel(
        level: 6,
        title: 'Marine Biologist',
        description: 'Certified researcher with independent authority',
        researchCapabilities: 'Species identification and behavior documentation',
        unlockedEquipment: ['Advanced Dive Computer', 'Scientific Camera'],
      );
    } else if (level <= 10) {
      return const MarineBiologyCareerLevel(
        level: 9,
        title: 'Senior Researcher',
        description: 'Experienced scientist with specialization expertise',
        researchCapabilities: 'Ecosystem health assessment and conservation planning',
        unlockedEquipment: ['Deep Sea Equipment', 'Water Quality Sensors'],
      );
    } else if (level <= 12) {
      return const MarineBiologyCareerLevel(
        level: 11,
        title: 'Lead Scientist',
        description: 'Directing marine research programs',
        researchCapabilities: 'Multi-species studies and habitat protection initiatives',
        unlockedEquipment: ['Research Submersible Access', 'Advanced Sonar'],
      );
    } else if (level <= 15) {
      return const MarineBiologyCareerLevel(
        level: 13,
        title: 'Research Director',
        description: 'Leading marine conservation institutions',
        researchCapabilities: 'Policy influence and international collaboration',
        unlockedEquipment: ['Satellite Tracking', 'AI Analysis Tools'],
      );
    } else if (level <= 18) {
      return const MarineBiologyCareerLevel(
        level: 16,
        title: 'Professor of Marine Biology',
        description: 'Academic leader training next generation',
        researchCapabilities: 'Groundbreaking research and scientific publication',
        unlockedEquipment: ['University Research Lab', 'Genetic Sequencer'],
      );
    } else if (level <= 20) {
      return const MarineBiologyCareerLevel(
        level: 19,
        title: 'Department Head',
        description: 'Institutional leader shaping marine science',
        researchCapabilities: 'Research program development and funding acquisition',
        unlockedEquipment: ['Research Vessel Command', 'Global Network Access'],
      );
    } else {
      return const MarineBiologyCareerLevel(
        level: 21,
        title: 'Ocean Research Pioneer',
        description: 'Legendary scientist transforming ocean conservation',
        researchCapabilities: 'Paradigm-shifting discoveries and global policy impact',
        unlockedEquipment: ['Quantum Ocean Scanner', 'International Authority'],
      );
    }
  }
}

/// Enhanced achievement with research narrative
class ResearchAchievement {
  final String id;
  final String title;
  final String description;
  final String researchNarrative;
  final IconData icon;
  final Color color;
  final AchievementCategory category;

  const ResearchAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.researchNarrative,
    required this.icon,
    required this.color,
    required this.category,
  });
}

enum AchievementCategory {
  conservation,
  research,
  exploration,
  consistency,
  discovery,
}

/// Equipment unlock with research station narrative
class EquipmentUnlock {
  final String id;
  final String name;
  final String description;
  final String researchStationUpgrade;
  final IconData icon;
  final EquipmentCategory category;

  const EquipmentUnlock({
    required this.id,
    required this.name,
    required this.description,
    required this.researchStationUpgrade,
    required this.icon,
    required this.category,
  });
}

enum EquipmentCategory {
  diving,
  photography,
  sampling,
  navigation,
  communication,
  laboratory,
}

/// Species discovery with research narrative
class SpeciesDiscoveryNarrative {
  final Creature creature;
  final String discoveryStory;
  final String scientificImportance;
  final String conservationImpact;
  final DateTime discoveredAt;

  const SpeciesDiscoveryNarrative({
    required this.creature,
    required this.discoveryStory,
    required this.scientificImportance,
    required this.conservationImpact,
    required this.discoveredAt,
  });
}

/// Session quality assessment
class SessionQualityAssessment {
  final double efficiency;
  final String qualityTier;
  final String researchGrade;
  final String qualityNarrative;
  final Color gradeColor;

  const SessionQualityAssessment({
    required this.efficiency,
    required this.qualityTier,
    required this.researchGrade,
    required this.qualityNarrative,
    required this.gradeColor,
  });

  static SessionQualityAssessment fromEfficiency(double efficiency) {
    if (efficiency >= 10.0) {
      return const SessionQualityAssessment(
        efficiency: 10.0,
        qualityTier: 'Legendary',
        researchGrade: 'A+',
        qualityNarrative: 'Groundbreaking research methodology with exceptional data quality',
        gradeColor: Colors.purple,
      );
    } else if (efficiency >= 8.0) {
      return const SessionQualityAssessment(
        efficiency: 8.0,
        qualityTier: 'Exceptional',
        researchGrade: 'A',
        qualityNarrative: 'Outstanding research session with high-quality observations',
        gradeColor: Colors.amber,
      );
    } else if (efficiency >= 6.0) {
      return const SessionQualityAssessment(
        efficiency: 6.0,
        qualityTier: 'Excellent',
        researchGrade: 'B+',
        qualityNarrative: 'Solid research work with valuable scientific contributions',
        gradeColor: Colors.green,
      );
    } else if (efficiency >= 4.0) {
      return const SessionQualityAssessment(
        efficiency: 4.0,
        qualityTier: 'Good',
        researchGrade: 'B',
        qualityNarrative: 'Good research session with useful data collection',
        gradeColor: Colors.lightBlue,
      );
    } else if (efficiency >= 2.0) {
      return const SessionQualityAssessment(
        efficiency: 2.0,
        qualityTier: 'Solid',
        researchGrade: 'C+',
        qualityNarrative: 'Steady research progress with consistent methodology',
        gradeColor: Colors.cyan,
      );
    } else {
      return const SessionQualityAssessment(
        efficiency: 1.0,
        qualityTier: 'Learning',
        researchGrade: 'C',
        qualityNarrative: 'Research session logged - building experience and skills',
        gradeColor: Colors.grey,
      );
    }
  }
}

/// Celebration intensity levels
enum CelebrationIntensity {
  minimal,    // 0.0-0.3
  moderate,   // 0.4-0.6
  high,       // 0.7-0.8
  maximum,    // 0.9-1.0
}

/// Celebration effects configuration
class CelebrationEffect {
  final CelebrationEffectType type;
  final Duration duration;
  final double intensity;
  final Map<String, dynamic> parameters;

  const CelebrationEffect({
    required this.type,
    required this.duration,
    required this.intensity,
    this.parameters = const {},
  });
}

enum CelebrationEffectType {
  schoolOfFish,
  coralBloom,
  bioluminescentJellyfish,
  bubbleTrail,
  waterCaustics,
  particleStorm,
  creatureSpotlight,
  badgeShimmer,
  depthTransition,
}