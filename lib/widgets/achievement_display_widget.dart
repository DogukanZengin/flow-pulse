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
    
    return _MobileAchievementCategoryView(
      groupedAchievements: groupedAchievements,
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
            child: achievement.isUnlocked
                ? Text(
                    achievement.icon,
                    style: const TextStyle(fontSize: 24),
                  )
                : Icon(
                    Icons.help_outline,
                    size: 24,
                    color: Colors.grey.withValues(alpha: 0.6),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            achievement.isUnlocked ? achievement.title : '???',
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

/// Mobile-friendly Achievement Category View
class _MobileAchievementCategoryView extends StatefulWidget {
  final Map<AchievementCategory, List<MarineBiologyAchievement>> groupedAchievements;

  const _MobileAchievementCategoryView({
    required this.groupedAchievements,
  });

  @override
  State<_MobileAchievementCategoryView> createState() => _MobileAchievementCategoryViewState();
}

class _MobileAchievementCategoryViewState extends State<_MobileAchievementCategoryView> {
  String? expandedCategory;
  
  @override
  void initState() {
    super.initState();
    // Expand the first category by default if it has achievements
    if (widget.groupedAchievements.isNotEmpty) {
      expandedCategory = widget.groupedAchievements.keys.first.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.groupedAchievements.entries.map((entry) {
        final category = entry.key;
        final achievements = entry.value;
        final isExpanded = expandedCategory == category.toString();
        final unlockedCount = achievements.where((a) => a.isUnlocked).length;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getCategoryColor(category).withValues(alpha: 0.1),
                _getCategoryColor(category).withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getCategoryColor(category).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Category Header (Always Visible)
              InkWell(
                onTap: () {
                  setState(() {
                    expandedCategory = isExpanded ? null : category.toString();
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(category).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.displayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '$unlockedCount/${achievements.length} unlocked',
                              style: TextStyle(
                                fontSize: 12,
                                color: _getCategoryColor(category),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Progress indicator
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Stack(
                          children: [
                            Center(
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  value: unlockedCount / achievements.length,
                                  strokeWidth: 4,
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                  valueColor: AlwaysStoppedAnimation(_getCategoryColor(category)),
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                '$unlockedCount',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getCategoryColor(category),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.white60,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Achievement Grid (Expandable)
              if (isExpanded) ...[
                const Divider(
                  color: Colors.white12,
                  height: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildMobileAchievementGrid(achievements),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildMobileAchievementGrid(List<MarineBiologyAchievement> achievements) {
    // Always use Column with individual cards to avoid any grid constraints
    return Column(
      children: achievements.map((achievement) => 
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildMobileAchievementCard(achievement),
        ),
      ).toList(),
    );
  }
  
  Widget _buildMobileAchievementCard(MarineBiologyAchievement achievement) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompactScreen = screenWidth < 400;
    
    return IntrinsicHeight(
      child: Container(
      padding: EdgeInsets.all(isCompactScreen ? 10 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: achievement.isUnlocked 
              ? [
                  achievement.rarityColor.withValues(alpha: 0.3),
                  achievement.rarityColor.withValues(alpha: 0.1),
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
      child: Row(
        children: [
          // Achievement Icon
          Container(
            padding: EdgeInsets.all(isCompactScreen ? 8 : 10),
            decoration: BoxDecoration(
              color: achievement.isUnlocked 
                  ? achievement.rarityColor.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(isCompactScreen ? 8 : 10),
            ),
            child: achievement.isUnlocked
                ? Text(
                    achievement.icon,
                    style: TextStyle(fontSize: isCompactScreen ? 20 : 24),
                  )
                : Icon(
                    Icons.help_outline,
                    size: isCompactScreen ? 20 : 24,
                    color: Colors.grey.withValues(alpha: 0.6),
                  ),
          ),
          
          SizedBox(width: isCompactScreen ? 8 : 12),
          
          // Achievement Details
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Rarity
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.isUnlocked ? achievement.title : '???',
                        style: TextStyle(
                          fontSize: isCompactScreen ? 12 : 14,
                          fontWeight: FontWeight.w600,
                          color: achievement.isUnlocked ? Colors.white : Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: achievement.isUnlocked 
                            ? achievement.rarityColor.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        achievement.isUnlocked ? achievement.rarityDisplayName : '???',
                        style: TextStyle(
                          fontSize: 9,
                          color: achievement.isUnlocked 
                              ? achievement.rarityColor 
                              : Colors.grey.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: isCompactScreen ? 2 : 4),
                
                // Description
                Flexible(
                  child: Text(
                    achievement.isUnlocked 
                        ? achievement.description 
                        : 'Complete marine research activities to unlock this mysterious achievement...',
                    style: TextStyle(
                      fontSize: isCompactScreen ? 10 : 12,
                      color: achievement.isUnlocked 
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.grey.withValues(alpha: 0.6),
                      fontStyle: achievement.isUnlocked ? FontStyle.normal : FontStyle.italic,
                    ),
                    maxLines: isCompactScreen ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                SizedBox(height: isCompactScreen ? 3 : 6),
                
                // Progress or Reward
                if (achievement.isUnlocked) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompactScreen ? 4 : 8, 
                      vertical: isCompactScreen ? 2 : 4
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: isCompactScreen ? 10 : 12),
                        SizedBox(width: isCompactScreen ? 2 : 4),
                        Flexible(
                          child: Text(
                            'Unlocked • +${achievement.researchValue} XP',
                            style: TextStyle(
                              fontSize: isCompactScreen ? 8 : 10,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (achievement.progress > 0) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${achievement.current}/${achievement.target} • ${(achievement.progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: achievement.rarityColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: achievement.progress,
                        backgroundColor: Colors.grey.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(achievement.rarityColor),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  ),
                ] else ...[
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
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
  
  Color _getCategoryColor(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.discovery:
        return Colors.cyan;
      case AchievementCategory.rarity:
        return Colors.purple;
      case AchievementCategory.biome:
        return Colors.blue;
      case AchievementCategory.career:
        return Colors.amber;
      case AchievementCategory.streak:
        return Colors.orange;
      case AchievementCategory.productivity:
        return Colors.green;
      case AchievementCategory.special:
        return Colors.pink;
    }
  }
}