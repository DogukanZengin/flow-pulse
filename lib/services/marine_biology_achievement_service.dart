import 'package:flutter/material.dart';
import '../models/creature.dart';
import 'marine_biology_career_service.dart';

/// Marine Biology Achievement System for Phase 4
/// Handles comprehensive achievement tracking, badges, and research milestones
class MarineBiologyAchievementService {
  
  /// Discovery Achievement Categories
  static List<MarineBiologyAchievement> getDiscoveryAchievements(
    List<Creature> discoveredCreatures,
    int currentLevel,
    ResearchMetrics metrics,
  ) {
    final achievements = <MarineBiologyAchievement>[];
    
    // First Contact Achievements
    if (discoveredCreatures.isNotEmpty) {
      achievements.add(const MarineBiologyAchievement(
        id: 'first_contact',
        category: AchievementCategory.discovery,
        title: 'First Contact',
        description: 'Discover your first marine species',
        icon: '🐠',
        rarity: AchievementRarity.common,
        researchValue: 50,
        unlocksAt: 'First species discovery',
        isUnlocked: true,
      ));
    }
    
    // Discovery Milestone Achievements
    final discoveryMilestones = [
      (5, 'Aquatic Explorer', 'Discover 5 marine species', '🌊'),
      (10, 'Marine Researcher', 'Discover 10 marine species', '🔬'),
      (25, 'Species Cataloger', 'Discover 25 marine species', '📚'),
      (50, 'Biodiversity Expert', 'Discover 50 marine species', '🏆'),
      (75, 'Ocean Scholar', 'Discover 75 marine species', '🎓'),
      (100, 'Marine Biology Master', 'Discover 100 marine species', '👨‍🔬'),
      (125, 'Ocean Pioneer', 'Discover 125 marine species', '⭐'),
      (144, 'Complete Ocean Survey', 'Discover all 144 marine species', '🏅'),
    ];
    
    for (final milestone in discoveryMilestones) {
      final (count, title, description, icon) = milestone;
      final isUnlocked = discoveredCreatures.length >= count;
      final progress = discoveredCreatures.length / count;
      
      achievements.add(MarineBiologyAchievement(
        id: 'discovery_$count',
        category: AchievementCategory.discovery,
        title: title,
        description: description,
        icon: icon,
        rarity: _getRarityForMilestone(count),
        researchValue: count * 5,
        unlocksAt: '$count total discoveries',
        isUnlocked: isUnlocked,
        progress: progress.clamp(0.0, 1.0),
        current: discoveredCreatures.length,
        target: count,
      ));
    }
    
    return achievements;
  }
  
  /// Rarity-Based Discovery Achievements
  static List<MarineBiologyAchievement> getRarityAchievements(
    List<Creature> discoveredCreatures,
  ) {
    final achievements = <MarineBiologyAchievement>[];
    
    // Count discoveries by rarity
    final rarityCount = <CreatureRarity, int>{};
    for (final creature in discoveredCreatures) {
      rarityCount[creature.rarity] = (rarityCount[creature.rarity] ?? 0) + 1;
    }
    
    // Uncommon Species Achievements
    final uncommonCount = rarityCount[CreatureRarity.uncommon] ?? 0;
    if (uncommonCount >= 1) {
      achievements.add(const MarineBiologyAchievement(
        id: 'uncommon_finder',
        category: AchievementCategory.rarity,
        title: 'Uncommon Finder',
        description: 'Discover your first uncommon species',
        icon: '💙',
        rarity: AchievementRarity.uncommon,
        researchValue: 75,
        unlocksAt: '1 uncommon species',
        isUnlocked: true,
      ));
    }
    
    if (uncommonCount >= 10) {
      achievements.add(const MarineBiologyAchievement(
        id: 'uncommon_specialist',
        category: AchievementCategory.rarity,
        title: 'Uncommon Species Specialist',
        description: 'Discover 10 uncommon species',
        icon: '💎',
        rarity: AchievementRarity.uncommon,
        researchValue: 200,
        unlocksAt: '10 uncommon species',
        isUnlocked: true,
      ));
    }
    
    // Rare Species Achievements
    final rareCount = rarityCount[CreatureRarity.rare] ?? 0;
    if (rareCount >= 1) {
      achievements.add(const MarineBiologyAchievement(
        id: 'rare_discovery',
        category: AchievementCategory.rarity,
        title: 'Rare Discovery',
        description: 'Discover your first rare species',
        icon: '💜',
        rarity: AchievementRarity.rare,
        researchValue: 150,
        unlocksAt: '1 rare species',
        isUnlocked: true,
      ));
    }
    
    if (rareCount >= 5) {
      achievements.add(const MarineBiologyAchievement(
        id: 'rare_hunter',
        category: AchievementCategory.rarity,
        title: 'Rare Species Hunter',
        description: 'Discover 5 rare species',
        icon: '🔍',
        rarity: AchievementRarity.rare,
        researchValue: 500,
        unlocksAt: '5 rare species',
        isUnlocked: true,
      ));
    }
    
    // Legendary Species Achievements
    final legendaryCount = rarityCount[CreatureRarity.legendary] ?? 0;
    if (legendaryCount >= 1) {
      achievements.add(const MarineBiologyAchievement(
        id: 'legendary_encounter',
        category: AchievementCategory.rarity,
        title: 'Legendary Encounter',
        description: 'Discover your first legendary species',
        icon: '⭐',
        rarity: AchievementRarity.legendary,
        researchValue: 1000,
        unlocksAt: '1 legendary species',
        isUnlocked: true,
      ));
    }
    
    if (legendaryCount >= 2) {
      achievements.add(const MarineBiologyAchievement(
        id: 'leviathan_hunter',
        category: AchievementCategory.rarity,
        title: 'Leviathan Hunter',
        description: 'Discover multiple legendary species',
        icon: '🐋',
        rarity: AchievementRarity.legendary,
        researchValue: 2500,
        unlocksAt: '2 legendary species',
        isUnlocked: true,
      ));
    }
    
    return achievements;
  }
  
  /// Biome Exploration Achievements
  static List<MarineBiologyAchievement> getBiomeAchievements(
    List<Creature> discoveredCreatures,
  ) {
    final achievements = <MarineBiologyAchievement>[];
    
    // Count discoveries by biome
    final biomeCount = <BiomeType, int>{};
    for (final creature in discoveredCreatures) {
      biomeCount[creature.habitat] = (biomeCount[creature.habitat] ?? 0) + 1;
    }
    
    // Define biome achievement thresholds
    final biomeThresholds = [
      (5, 'Explorer', 'Explore and document'),
      (15, 'Researcher', 'Conduct research in'),
      (25, 'Specialist', 'Master the ecology of'),
      (36, 'Expert', 'Complete survey of'),
    ];
    
    for (final biome in BiomeType.values) {
      final count = biomeCount[biome] ?? 0;
      final biomeName = biome.displayName;
      final biomeIcon = _getBiomeIcon(biome);
      
      for (final threshold in biomeThresholds) {
        final (requiredCount, level, actionText) = threshold;
        final isUnlocked = count >= requiredCount;
        final progress = count / requiredCount;
        
        if (count > 0 || requiredCount <= 5) { // Only show if some progress or initial threshold
          achievements.add(MarineBiologyAchievement(
            id: '${biome.name.toLowerCase()}_${level.toLowerCase()}',
            category: AchievementCategory.biome,
            title: '$biomeName $level',
            description: '$actionText $biomeName',
            icon: biomeIcon,
            rarity: _getRarityForBiomeLevel(requiredCount),
            researchValue: requiredCount * 10,
            unlocksAt: '$requiredCount $biomeName discoveries',
            isUnlocked: isUnlocked,
            progress: progress.clamp(0.0, 1.0),
            current: count,
            target: requiredCount,
          ));
        }
      }
    }
    
    return achievements;
  }
  
  /// Career Progression Achievements
  static List<MarineBiologyAchievement> getCareerAchievements(
    int currentLevel,
    ResearchMetrics metrics,
  ) {
    final achievements = <MarineBiologyAchievement>[];
    
    // Level Milestone Achievements
    final levelMilestones = [
      (10, 'Research Assistant', 'Graduate to Research Assistant level', '🎓'),
      (25, 'Field Researcher', 'Achieve Field Researcher status', '🏕️'),
      (50, 'Marine Biologist', 'Become a certified Marine Biologist', '🔬'),
      (75, 'Senior Scientist', 'Reach Senior Scientist level', '👨‍🔬'),
      (100, 'Research Legend', 'Achieve legendary researcher status', '🏆'),
    ];
    
    for (final milestone in levelMilestones) {
      final (level, title, description, icon) = milestone;
      final isUnlocked = currentLevel >= level;
      final progress = currentLevel / level;
      
      achievements.add(MarineBiologyAchievement(
        id: 'career_level_$level',
        category: AchievementCategory.career,
        title: title,
        description: description,
        icon: icon,
        rarity: _getRarityForLevel(level),
        researchValue: level * 20,
        unlocksAt: 'Level $level',
        isUnlocked: isUnlocked,
        progress: progress.clamp(0.0, 1.0),
        current: currentLevel,
        target: level,
      ));
    }
    
    // Research Efficiency Achievements
    if (metrics.researchEfficiency >= 5.0) {
      achievements.add(const MarineBiologyAchievement(
        id: 'efficient_researcher',
        category: AchievementCategory.career,
        title: 'Efficient Researcher',
        description: 'Achieve high research efficiency (5.0+)',
        icon: '⚡',
        rarity: AchievementRarity.uncommon,
        researchValue: 300,
        unlocksAt: '5.0+ research efficiency',
        isUnlocked: true,
      ));
    }
    
    if (metrics.researchEfficiency >= 10.0) {
      achievements.add(const MarineBiologyAchievement(
        id: 'research_virtuoso',
        category: AchievementCategory.career,
        title: 'Research Virtuoso',
        description: 'Achieve exceptional research efficiency (10.0+)',
        icon: '🎯',
        rarity: AchievementRarity.rare,
        researchValue: 750,
        unlocksAt: '10.0+ research efficiency',
        isUnlocked: true,
      ));
    }
    
    // Biodiversity Achievements
    if (metrics.diversityIndex >= 0.6) {
      achievements.add(const MarineBiologyAchievement(
        id: 'biodiversity_advocate',
        category: AchievementCategory.career,
        title: 'Biodiversity Advocate',
        description: 'Study diverse marine ecosystems',
        icon: '🌈',
        rarity: AchievementRarity.uncommon,
        researchValue: 400,
        unlocksAt: '0.6+ diversity index',
        isUnlocked: true,
      ));
    }
    
    if (metrics.diversityIndex >= 0.8) {
      achievements.add(const MarineBiologyAchievement(
        id: 'ecosystem_expert',
        category: AchievementCategory.career,
        title: 'Ecosystem Expert',
        description: 'Master multiple marine ecosystems',
        icon: '🌊',
        rarity: AchievementRarity.rare,
        researchValue: 1000,
        unlocksAt: '0.8+ diversity index',
        isUnlocked: true,
      ));
    }
    
    return achievements;
  }
  
  /// Streak & Productivity Achievements
  static List<MarineBiologyAchievement> getStreakAchievements(
    int currentStreak,
    int totalSessions,
    double averageSessionTime,
  ) {
    final achievements = <MarineBiologyAchievement>[];
    
    // Streak Achievements
    final streakMilestones = [
      (3, 'Consistent Explorer', 'Maintain 3-day research streak', '🔥'),
      (7, 'Weekly Researcher', 'Maintain 7-day research streak', '📅'),
      (14, 'Dedicated Scientist', 'Maintain 2-week research streak', '⚡'),
      (30, 'Research Devotee', 'Maintain 30-day research streak', '💪'),
      (60, 'Ocean Guardian', 'Maintain 2-month research streak', '🛡️'),
      (100, 'Eternal Explorer', 'Maintain 100-day research streak', '♾️'),
    ];
    
    for (final milestone in streakMilestones) {
      final (days, title, description, icon) = milestone;
      final isUnlocked = currentStreak >= days;
      final progress = currentStreak / days;
      
      achievements.add(MarineBiologyAchievement(
        id: 'streak_$days',
        category: AchievementCategory.streak,
        title: title,
        description: description,
        icon: icon,
        rarity: _getRarityForStreak(days),
        researchValue: days * 15,
        unlocksAt: '$days-day streak',
        isUnlocked: isUnlocked,
        progress: progress.clamp(0.0, 1.0),
        current: currentStreak,
        target: days,
      ));
    }
    
    // Session Count Achievements
    final sessionMilestones = [
      (10, 'New Researcher', 'Complete 10 research sessions', '🚀'),
      (25, 'Experienced Diver', 'Complete 25 research sessions', '🤿'),
      (50, 'Seasoned Explorer', 'Complete 50 research sessions', '⛵'),
      (100, 'Century Explorer', 'Complete 100 research sessions', '💯'),
      (250, 'Expedition Master', 'Complete 250 research sessions', '🗺️'),
      (500, 'Ocean Veteran', 'Complete 500 research sessions', '🌊'),
    ];
    
    for (final milestone in sessionMilestones) {
      final (count, title, description, icon) = milestone;
      final isUnlocked = totalSessions >= count;
      final progress = totalSessions / count;
      
      achievements.add(MarineBiologyAchievement(
        id: 'sessions_$count',
        category: AchievementCategory.productivity,
        title: title,
        description: description,
        icon: icon,
        rarity: _getRarityForSessions(count),
        researchValue: count * 5,
        unlocksAt: '$count completed sessions',
        isUnlocked: isUnlocked,
        progress: progress.clamp(0.0, 1.0),
        current: totalSessions,
        target: count,
      ));
    }
    
    // Deep Dive Session Achievements
    if (averageSessionTime >= 45.0) {
      achievements.add(const MarineBiologyAchievement(
        id: 'deep_dive_specialist',
        category: AchievementCategory.productivity,
        title: 'Deep Dive Specialist',
        description: 'Master of extended research sessions',
        icon: '🏊‍♂️',
        rarity: AchievementRarity.uncommon,
        researchValue: 500,
        unlocksAt: '45+ minute average sessions',
        isUnlocked: true,
      ));
    }
    
    if (averageSessionTime >= 60.0) {
      achievements.add(const MarineBiologyAchievement(
        id: 'abyssal_explorer',
        category: AchievementCategory.productivity,
        title: 'Abyssal Zone Explorer',
        description: 'Expert in long-duration research expeditions',
        icon: '🕳️',
        rarity: AchievementRarity.rare,
        researchValue: 1000,
        unlocksAt: '60+ minute average sessions',
        isUnlocked: true,
      ));
    }
    
    return achievements;
  }
  
  /// Special Research Achievements
  static List<MarineBiologyAchievement> getSpecialAchievements(
    List<Creature> discoveredCreatures,
    int currentLevel,
    ResearchMetrics metrics,
  ) {
    final achievements = <MarineBiologyAchievement>[];
    
    // First in Biome Achievements
    final biomeFirsts = <BiomeType, bool>{};
    for (final creature in discoveredCreatures) {
      if (!biomeFirsts.containsKey(creature.habitat)) {
        biomeFirsts[creature.habitat] = true;
        final biomeName = creature.habitat.displayName;
        final biomeIcon = _getBiomeIcon(creature.habitat);
        
        achievements.add(MarineBiologyAchievement(
          id: 'first_${creature.habitat.name.toLowerCase()}',
          category: AchievementCategory.special,
          title: '$biomeName Pioneer',
          description: 'First discovery in $biomeName',
          icon: biomeIcon,
          rarity: AchievementRarity.uncommon,
          researchValue: 100,
          unlocksAt: 'First $biomeName discovery',
          isUnlocked: true,
        ));
      }
    }
    
    // Rapid Discovery Achievement
    final recentDiscoveries = discoveredCreatures.where((c) => 
      c.discoveredAt != null && 
      DateTime.now().difference(c.discoveredAt!).inHours <= 24
    ).length;
    
    if (recentDiscoveries >= 5) {
      achievements.add(MarineBiologyAchievement(
        id: 'rapid_discovery',
        category: AchievementCategory.special,
        title: 'Rapid Discovery Expert',
        description: 'Discover 5+ species in 24 hours',
        icon: '⚡',
        rarity: AchievementRarity.rare,
        researchValue: 750,
        unlocksAt: '5 discoveries in 24 hours',
        isUnlocked: true,
        current: recentDiscoveries,
        target: 5,
      ));
    }
    
    // Research Quality Achievement
    if (metrics.discoveriesPerSession >= 0.8) {
      achievements.add(const MarineBiologyAchievement(
        id: 'quality_researcher',
        category: AchievementCategory.special,
        title: 'Quality Researcher',
        description: 'High discovery rate per session',
        icon: '🎯',
        rarity: AchievementRarity.uncommon,
        researchValue: 400,
        unlocksAt: '0.8+ discoveries per session',
        isUnlocked: true,
      ));
    }
    
    return achievements;
  }
  
  /// Get all achievements for display
  static List<MarineBiologyAchievement> getAllAchievements(
    List<Creature> discoveredCreatures,
    int currentLevel,
    ResearchMetrics metrics,
    int currentStreak,
    int totalSessions,
  ) {
    final allAchievements = <MarineBiologyAchievement>[];
    
    allAchievements.addAll(getDiscoveryAchievements(discoveredCreatures, currentLevel, metrics));
    allAchievements.addAll(getRarityAchievements(discoveredCreatures));
    allAchievements.addAll(getBiomeAchievements(discoveredCreatures));
    allAchievements.addAll(getCareerAchievements(currentLevel, metrics));
    allAchievements.addAll(getStreakAchievements(currentStreak, totalSessions, metrics.averageSessionTime));
    allAchievements.addAll(getSpecialAchievements(discoveredCreatures, currentLevel, metrics));
    
    // Sort by category then by unlock status
    allAchievements.sort((a, b) {
      final categoryCompare = a.category.index.compareTo(b.category.index);
      if (categoryCompare != 0) return categoryCompare;
      
      if (a.isUnlocked && !b.isUnlocked) return -1;
      if (!a.isUnlocked && b.isUnlocked) return 1;
      
      return b.researchValue.compareTo(a.researchValue);
    });
    
    return allAchievements;
  }
  
  // Helper methods
  static AchievementRarity _getRarityForMilestone(int count) {
    if (count >= 100) return AchievementRarity.legendary;
    if (count >= 50) return AchievementRarity.rare;
    if (count >= 25) return AchievementRarity.uncommon;
    return AchievementRarity.common;
  }
  
  static AchievementRarity _getRarityForLevel(int level) {
    if (level >= 100) return AchievementRarity.legendary;
    if (level >= 50) return AchievementRarity.rare;
    if (level >= 25) return AchievementRarity.uncommon;
    return AchievementRarity.common;
  }
  
  static AchievementRarity _getRarityForBiomeLevel(int requiredCount) {
    if (requiredCount >= 36) return AchievementRarity.legendary;
    if (requiredCount >= 25) return AchievementRarity.rare;
    if (requiredCount >= 15) return AchievementRarity.uncommon;
    return AchievementRarity.common;
  }
  
  static AchievementRarity _getRarityForStreak(int days) {
    if (days >= 100) return AchievementRarity.legendary;
    if (days >= 30) return AchievementRarity.rare;
    if (days >= 14) return AchievementRarity.uncommon;
    return AchievementRarity.common;
  }
  
  static AchievementRarity _getRarityForSessions(int count) {
    if (count >= 500) return AchievementRarity.legendary;
    if (count >= 100) return AchievementRarity.rare;
    if (count >= 50) return AchievementRarity.uncommon;
    return AchievementRarity.common;
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

/// Marine Biology Achievement Model
class MarineBiologyAchievement {
  final String id;
  final AchievementCategory category;
  final String title;
  final String description;
  final String icon;
  final AchievementRarity rarity;
  final int researchValue;
  final String unlocksAt;
  final bool isUnlocked;
  final double progress;
  final int current;
  final int target;

  const MarineBiologyAchievement({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.researchValue,
    required this.unlocksAt,
    required this.isUnlocked,
    this.progress = 0.0,
    this.current = 0,
    this.target = 1,
  });
  
  /// Get rarity color for UI display
  Color get rarityColor {
    switch (rarity) {
      case AchievementRarity.common:
        return const Color(0xFF90EE90); // Light Green
      case AchievementRarity.uncommon:
        return const Color(0xFF87CEEB); // Sky Blue
      case AchievementRarity.rare:
        return const Color(0xFFDDA0DD); // Plum
      case AchievementRarity.legendary:
        return const Color(0xFFFFD700); // Gold
    }
  }
  
  /// Get rarity display name
  String get rarityDisplayName {
    switch (rarity) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.uncommon:
        return 'Uncommon';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.legendary:
        return 'Legendary';
    }
  }
}

/// Achievement Categories
enum AchievementCategory {
  discovery,
  rarity,
  biome,
  career,
  streak,
  productivity,
  special,
}

extension AchievementCategoryExtension on AchievementCategory {
  String get displayName {
    switch (this) {
      case AchievementCategory.discovery:
        return 'Discovery';
      case AchievementCategory.rarity:
        return 'Rarity Hunter';
      case AchievementCategory.biome:
        return 'Biome Explorer';
      case AchievementCategory.career:
        return 'Career Progress';
      case AchievementCategory.streak:
        return 'Consistency';
      case AchievementCategory.productivity:
        return 'Productivity';
      case AchievementCategory.special:
        return 'Special';
    }
  }
  
  String get icon {
    switch (this) {
      case AchievementCategory.discovery:
        return '🔍';
      case AchievementCategory.rarity:
        return '💎';
      case AchievementCategory.biome:
        return '🗺️';
      case AchievementCategory.career:
        return '🎓';
      case AchievementCategory.streak:
        return '🔥';
      case AchievementCategory.productivity:
        return '⚡';
      case AchievementCategory.special:
        return '⭐';
    }
  }
}

/// Achievement Rarity Levels
enum AchievementRarity {
  common,
  uncommon,
  rare,
  legendary,
}