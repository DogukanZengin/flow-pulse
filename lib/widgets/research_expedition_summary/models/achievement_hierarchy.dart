import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/creature.dart';
import '../models/expedition_result.dart';
import '../utils/biome_color_inheritance.dart';

/// Achievement hierarchy system that creates visual priority for expedition rewards
///
/// Analyzes ExpeditionResult to determine primary, secondary, and tertiary achievements
/// with biome-aware colors for visual continuity with the ocean widget.
class AchievementHierarchy {

  /// Calculate achievement priority classification for an expedition
  static AchievementClassification calculatePriority(ExpeditionResult result) {
    final List<Achievement> allAchievements = _extractAllAchievements(result);
    final Map<Achievement, int> scores = {};

    // Score each achievement based on impact and rarity
    for (final achievement in allAchievements) {
      scores[achievement] = _calculateAchievementScore(achievement, result);
    }

    // Sort by score and classify
    final sortedAchievements = allAchievements..sort(
      (a, b) => scores[b]!.compareTo(scores[a]!)
    );

    return AchievementClassification(
      primary: sortedAchievements.isNotEmpty ? sortedAchievements[0] : null,
      secondary: sortedAchievements.length > 1
          ? sortedAchievements.sublist(1, math.min(4, sortedAchievements.length))
          : [],
      tertiary: sortedAchievements.length > 4
          ? sortedAchievements.sublist(4)
          : [],
    );
  }

  /// Build hero achievement widget with biome-appropriate styling
  static Widget buildHeroAchievement(Achievement? primary, ExpeditionResult result) {
    if (primary == null) {
      return _buildDefaultHero(result);
    }

    final biome = result.sessionBiome;
    final depth = result.sessionDepthReached;
    final achievementColor = BiomeColorInheritance.getAchievementTypeColor(primary.type, biome);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Use biome-appropriate background instead of harsh black
        gradient: BiomeColorInheritance.getBiomeBackgroundGradient(biome, depth),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: BiomeColorInheritance.getBorderColor(biome, depth),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: achievementColor.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Achievement icon with biome-themed styling
          _buildAnimatedAchievementIcon(primary, achievementColor, biome),

          const SizedBox(height: 16),

          // Achievement title with ocean-themed shadows
          Text(
            primary.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: achievementColor,
              shadows: BiomeColorInheritance.getOceanTextShadows(biome),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Achievement description
          Text(
            primary.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              shadows: BiomeColorInheritance.getOceanTextShadows(biome),
            ),
            textAlign: TextAlign.center,
          ),

          // RP value if applicable
          if (primary.rpValue > 0) ...[
            const SizedBox(height: 12),
            _buildRPReward(primary.rpValue, achievementColor, biome),
          ],
        ],
      ),
    );
  }

  /// Build secondary achievements display with biome styling
  static Widget buildSecondaryAchievements(List<Achievement> secondary, ExpeditionResult result) {
    if (secondary.isEmpty) return const SizedBox.shrink();

    final biome = result.sessionBiome;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Accomplishments',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
            shadows: BiomeColorInheritance.getOceanTextShadows(biome),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: secondary.map((achievement) =>
            _buildSecondaryAchievementChip(achievement, biome)
          ).toList(),
        ),
      ],
    );
  }

  /// Extract all achievements from expedition result
  static List<Achievement> _extractAllAchievements(ExpeditionResult result) {
    final achievements = <Achievement>[];

    // Level progression achievements
    if (result.leveledUp) {
      achievements.add(Achievement(
        type: AchievementType.levelUp,
        title: 'Level ${result.newLevel} Researcher',
        description: 'Advanced from level ${result.oldLevel} to ${result.newLevel}',
        significance: result.newLevel >= 10 ? 'major' : 'moderate',
        rpValue: result.rpGained,
        icon: Icons.trending_up,
      ));
    }

    // Career progression achievements (highest priority)
    if (result.careerTitleChanged) {
      achievements.add(Achievement(
        type: AchievementType.careerAdvancement,
        title: result.newCareerTitle ?? 'Career Advancement',
        description: result.careerAdvancementNarrative ?? 'Promoted to new research position',
        significance: 'major', // Career changes are always significant
        rpValue: 0,
        icon: Icons.workspace_premium,
      ));
    }

    // Streak achievements
    if (result.currentStreak >= 7) {
      String title = _getStreakTitle(result.currentStreak);
      achievements.add(Achievement(
        type: AchievementType.streakMilestone,
        title: title,
        description: 'Maintained ${result.currentStreak}-day research consistency',
        significance: result.currentStreak >= 30 ? 'major' : 'moderate',
        rpValue: result.streakBonusRP,
        icon: Icons.local_fire_department,
      ));
    }

    // Research achievements from unlocked achievements
    achievements.addAll(result.unlockedAchievements.map((researchAchievement) =>
      Achievement(
        type: AchievementType.research,
        title: researchAchievement.title,
        description: researchAchievement.description,
        significance: researchAchievement.category == AchievementCategory.discovery ? 'major' : 'moderate',
        rpValue: 0,
        icon: researchAchievement.icon,
      )
    ));

    // Species discovery achievements
    if (result.discoveredCreature != null) {
      final creature = result.discoveredCreature as Creature;
      achievements.add(Achievement(
        type: AchievementType.speciesDiscovery,
        title: 'Discovered ${creature.species}',
        description: 'First observation of this ${creature.rarity.name} species',
        significance: creature.rarity == CreatureRarity.legendary ? 'major' :
                     creature.rarity == CreatureRarity.rare ? 'moderate' : 'minor',
        rpValue: creature.pearlValue,
        icon: Icons.pets,
      ));
    }

    // Quality achievements
    if (result.qualityAssessment.qualityTier == 'Exceptional' ||
        result.qualityAssessment.qualityTier == 'Legendary') {
      achievements.add(Achievement(
        type: AchievementType.sessionQuality,
        title: '${result.qualityAssessment.qualityTier} Research Session',
        description: result.qualityAssessment.qualityNarrative,
        significance: result.qualityAssessment.qualityTier == 'Legendary' ? 'major' : 'moderate',
        rpValue: result.qualityBonus,
        icon: Icons.star,
      ));
    }

    return achievements;
  }

  /// Calculate achievement score for priority ranking
  static int _calculateAchievementScore(Achievement achievement, ExpeditionResult result) {
    int baseScore = 0;

    // Base scores by type (higher = more important)
    switch (achievement.type) {
      case AchievementType.careerAdvancement:
        baseScore = 1000; // Career changes are highest priority
        break;
      case AchievementType.levelUp:
        baseScore = 800 + (result.newLevel * 20); // Higher levels = higher score
        break;
      case AchievementType.speciesDiscovery:
        baseScore = 600 + _getRarityBonus(achievement);
        break;
      case AchievementType.streakMilestone:
        baseScore = 400 + (result.currentStreak * 2);
        break;
      case AchievementType.sessionQuality:
        baseScore = 300;
        break;
      case AchievementType.research:
        baseScore = 200;
        break;
    }

    // Significance multiplier
    switch (achievement.significance) {
      case 'major':
        baseScore = (baseScore * 1.5).round();
        break;
      case 'moderate':
        baseScore = (baseScore * 1.2).round();
        break;
      case 'minor':
        // No multiplier
        break;
    }

    // RP value bonus (achievements that give more RP are more important)
    baseScore += achievement.rpValue;

    return baseScore;
  }

  /// Build default hero when no specific achievement is primary
  static Widget _buildDefaultHero(ExpeditionResult result) {
    final biome = result.sessionBiome;
    final depth = result.sessionDepthReached;
    final defaultColor = BiomeColorInheritance.getBiomeAccentColor(biome);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: BiomeColorInheritance.getBiomeBackgroundGradient(biome, depth),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: BiomeColorInheritance.getBorderColor(biome, depth),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.science,
            size: 48,
            color: defaultColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Research Session Complete',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: defaultColor,
              shadows: BiomeColorInheritance.getOceanTextShadows(biome),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${result.dataPointsCollected} data points collected',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              shadows: BiomeColorInheritance.getOceanTextShadows(biome),
            ),
          ),
        ],
      ),
    );
  }

  /// Build animated achievement icon with biome styling
  static Widget _buildAnimatedAchievementIcon(Achievement achievement, Color color, BiomeType biome) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        achievement.icon,
        size: 36,
        color: color,
      ),
    );
  }

  /// Build RP reward display with biome styling
  static Widget _buildRPReward(int rpValue, Color color, BiomeType biome) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        '+$rpValue RP',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
          shadows: BiomeColorInheritance.getOceanTextShadows(biome),
        ),
      ),
    );
  }

  /// Build secondary achievement chip with biome styling
  static Widget _buildSecondaryAchievementChip(Achievement achievement, BiomeType biome) {
    final color = BiomeColorInheritance.getAchievementTypeColor(achievement.type, biome);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            achievement.icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            achievement.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Get streak title based on streak length
  static String _getStreakTitle(int streak) {
    if (streak >= 100) return 'Century Researcher';
    if (streak >= 50) return 'Master Researcher';
    if (streak >= 30) return 'Dedicated Researcher';
    if (streak >= 14) return 'Committed Researcher';
    if (streak >= 7) return 'Consistent Researcher';
    return 'Research Streak';
  }

  /// Get rarity bonus for creature discoveries
  static int _getRarityBonus(Achievement achievement) {
    // Extract rarity from description or use default
    if (achievement.description.contains('legendary')) return 200;
    if (achievement.description.contains('rare')) return 100;
    if (achievement.description.contains('uncommon')) return 50;
    return 25; // common
  }
}

/// Achievement data model
class Achievement {
  final AchievementType type;
  final String title;
  final String description;
  final String significance; // 'major', 'moderate', 'minor'
  final int rpValue;
  final IconData icon;

  const Achievement({
    required this.type,
    required this.title,
    required this.description,
    required this.significance,
    required this.rpValue,
    required this.icon,
  });
}

/// Achievement classification result
class AchievementClassification {
  final Achievement? primary;
  final List<Achievement> secondary;
  final List<Achievement> tertiary;

  const AchievementClassification({
    this.primary,
    required this.secondary,
    required this.tertiary,
  });
}

/// Achievement priority levels
enum AchievementPriority {
  primary,    // Hero achievement - most prominent display
  secondary,  // Supporting achievements - medium visibility
  tertiary,   // Background achievements - subtle display
  hidden,     // Not shown this session
}