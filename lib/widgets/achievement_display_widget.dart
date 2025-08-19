import 'package:flutter/material.dart';
import '../services/marine_biology_achievement_service.dart';

/// Achievement Display Widget for Phase 4
/// Shows marine biology achievements with progress tracking and badges
class AchievementDisplayWidget extends StatelessWidget {
  final List<MarineBiologyAchievement> achievements;
  final bool showOnlyUnlocked;
  final bool compactView;
  
  const AchievementDisplayWidget({super.key, 
    required this.achievements,
    this.showOnlyUnlocked = false,
    this.compactView = false,
  });

  @override
  Widget build(BuildContext context) {
    final filteredAchievements = showOnlyUnlocked 
        ? achievements.where((a) => a.isUnlocked).toList()
        : achievements;
    
    if (filteredAchievements.isEmpty) {
      return _buildEmptyState();
    }
    
    return compactView 
        ? _buildCompactView(filteredAchievements)
        : _buildFullView(filteredAchievements);
  }
  
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A5F), // Deep Ocean Blue
            Color(0xFF2E5A7A), // Ocean Research Blue
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 48,
            color: Colors.cyan.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No achievements yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your marine research journey!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFullView(List<MarineBiologyAchievement> achievements) {
    // Group achievements by category
    final groupedAchievements = <AchievementCategory, List<MarineBiologyAchievement>>{};
    for (final achievement in achievements) {
      groupedAchievements.putIfAbsent(achievement.category, () => []).add(achievement);
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedAchievements.length,
      itemBuilder: (context, index) {
        final category = groupedAchievements.keys.elementAt(index);
        final categoryAchievements = groupedAchievements[category]!;
        
        return _buildCategorySection(category, categoryAchievements);
      },
    );
  }
  
  Widget _buildCompactView(List<MarineBiologyAchievement> achievements) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: achievements.take(10).length, // Show max 10 in compact view
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return _buildCompactAchievementCard(achievement);
        },
      ),
    );
  }
  
  Widget _buildCategorySection(AchievementCategory category, List<MarineBiologyAchievement> achievements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryHeader(category),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            return _buildAchievementCard(achievements[index]);
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
  
  Widget _buildCategoryHeader(AchievementCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.cyan.withValues(alpha: 0.2),
            Colors.blue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category.icon,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),
          Text(
            category.displayName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAchievementCard(MarineBiologyAchievement achievement) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: achievement.isUnlocked 
              ? [
                  achievement.rarityColor.withValues(alpha: 0.2),
                  achievement.rarityColor.withValues(alpha: 0.05),
                ]
              : [
                  Colors.grey.withValues(alpha: 0.2),
                  Colors.grey.withValues(alpha: 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.isUnlocked 
              ? achievement.rarityColor.withValues(alpha: 0.5)
              : Colors.grey.withValues(alpha: 0.3),
          width: achievement.isUnlocked ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: achievement.isUnlocked 
                      ? achievement.rarityColor.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  achievement.icon,
                  style: TextStyle(
                    fontSize: 16,
                    color: achievement.isUnlocked ? null : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: achievement.isUnlocked ? Colors.white : Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      achievement.rarityDisplayName,
                      style: TextStyle(
                        fontSize: 10,
                        color: achievement.isUnlocked 
                            ? achievement.rarityColor
                            : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              achievement.description,
              style: TextStyle(
                fontSize: 10,
                color: achievement.isUnlocked 
                    ? Colors.white.withValues(alpha: 0.8)
                    : Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          if (!achievement.isUnlocked && achievement.progress > 0) 
            _buildProgressBar(achievement),
          if (achievement.isUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: achievement.rarityColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '+${achievement.researchValue} XP',
                style: TextStyle(
                  fontSize: 10,
                  color: achievement.rarityColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (!achievement.isUnlocked)
            Text(
              achievement.unlocksAt,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
  
  Widget _buildCompactAchievementCard(MarineBiologyAchievement achievement) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: achievement.isUnlocked 
              ? [
                  achievement.rarityColor.withValues(alpha: 0.3),
                  achievement.rarityColor.withValues(alpha: 0.1),
                ]
              : [
                  Colors.grey.withValues(alpha: 0.3),
                  Colors.grey.withValues(alpha: 0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.isUnlocked 
              ? achievement.rarityColor
              : Colors.grey.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: achievement.isUnlocked 
                  ? achievement.rarityColor.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              achievement.icon,
              style: TextStyle(
                fontSize: 24,
                color: achievement.isUnlocked ? null : Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            achievement.title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: achievement.isUnlocked ? Colors.white : Colors.grey,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          if (achievement.isUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: achievement.rarityColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                '+${achievement.researchValue}',
                style: TextStyle(
                  fontSize: 9,
                  color: achievement.rarityColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (!achievement.isUnlocked && achievement.progress > 0)
            SizedBox(
              height: 4,
              child: LinearProgressIndicator(
                value: achievement.progress,
                backgroundColor: Colors.grey.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  achievement.rarityColor.withValues(alpha: 0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildProgressBar(MarineBiologyAchievement achievement) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${achievement.current}/${achievement.target}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(achievement.progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 10,
                color: achievement.rarityColor.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 6,
          child: LinearProgressIndicator(
            value: achievement.progress,
            backgroundColor: Colors.grey.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(achievement.rarityColor),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }
}

/// Achievement Summary Widget for quick stats display
class AchievementSummaryWidget extends StatelessWidget {
  final List<MarineBiologyAchievement> achievements;
  
  const AchievementSummaryWidget({super.key, 
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final totalCount = achievements.length;
    final completionPercentage = totalCount > 0 ? (unlockedCount / totalCount) * 100 : 0.0;
    
    // Count by rarity
    final rarityCount = <AchievementRarity, int>{};
    for (final achievement in achievements.where((a) => a.isUnlocked)) {
      rarityCount[achievement.rarity] = (rarityCount[achievement.rarity] ?? 0) + 1;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A5F), // Deep Ocean Blue
            Color(0xFF2E5A7A), // Ocean Research Blue
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Research Achievements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '$unlockedCount/$totalCount',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: completionPercentage / 100,
            backgroundColor: Colors.grey.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 8),
          Text(
            '${completionPercentage.toInt()}% Complete',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          if (rarityCount.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: rarityCount.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRarityColor(entry.key).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getRarityColor(entry.key).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    '${entry.value} ${_getRarityDisplayName(entry.key)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: _getRarityColor(entry.key),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
  
  Color _getRarityColor(AchievementRarity rarity) {
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
  
  String _getRarityDisplayName(AchievementRarity rarity) {
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