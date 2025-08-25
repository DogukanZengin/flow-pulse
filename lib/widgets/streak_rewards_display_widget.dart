import 'package:flutter/material.dart';
import '../services/streak_rewards_service.dart';
import '../utils/responsive_helper.dart';

/// Streak Rewards Display Widget for Phase 4
/// Shows current streak, tier, rewards, and motivation
class StreakRewardsDisplayWidget extends StatelessWidget {
  final int currentStreak;
  final StreakTier currentTier;
  final List<StreakReward> availableRewards;
  final DailyStreakReward? todaysReward;
  final bool showCompact;
  
  const StreakRewardsDisplayWidget({
    super.key,
    required this.currentStreak,
    required this.currentTier,
    required this.availableRewards,
    this.todaysReward,
    this.showCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showCompact) {
      return _buildCompactView(context);
    }
    
    return Column(
      children: [
        _buildCurrentStreakCard(context),
        const SizedBox(height: 16),
        _buildTierProgressCard(context),
        const SizedBox(height: 16),
        if (todaysReward != null) ...[
          _buildTodaysRewardCard(context),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
        ],
        _buildUpcomingRewardsSection(context),
      ],
    );
  }
  
  Widget _buildCompactView(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'card')),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            currentTier.color.withValues(alpha: 0.3),
            currentTier.color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: currentTier.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: currentTier.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              currentTier.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$currentStreak Day${currentStreak == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle'),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: currentTier.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(currentTier.xpMultiplier * 100).toInt()}% XP',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                          color: currentTier.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  currentTier.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: currentTier.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (currentStreak > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    currentTier.color.withValues(alpha: 0.3),
                    currentTier.color.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'ACTIVE',
                style: TextStyle(
                  fontSize: 10,
                  color: currentTier.color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildCurrentStreakCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            currentTier.color.withValues(alpha: 0.3),
            currentTier.color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: currentTier.color.withValues(alpha: 0.5), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'card')),
                decoration: BoxDecoration(
                  color: currentTier.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  currentTier.icon,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$currentStreak',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: currentTier.color,
                      height: 1,
                    ),
                  ),
                  Text(
                    'DAY${currentStreak == 1 ? '' : 'S'}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: currentTier.color.withValues(alpha: 0.8),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
          Text(
            currentTier.name,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title'),
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentTier.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBenefitChip(
                context,
                '${(currentTier.xpMultiplier * 100).toInt()}%',
                'XP Bonus',
                Icons.trending_up,
                currentTier.color,
              ),
              _buildBenefitChip(
                context,
                '+${(currentTier.discoveryBonus * 100).toInt()}%',
                'Discovery Rate',
                Icons.search,
                Colors.cyan,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildBenefitChip(BuildContext context, String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTierProgressCard(BuildContext context) {
    final nextTier = StreakRewardsService.getNextStreakTier(currentStreak);
    
    if (nextTier == null) {
      return _buildMaxTierCard(context);
    }
    
    final progress = currentTier.getProgressToNext(currentStreak, nextTier);
    final daysRemaining = nextTier.minStreak - currentStreak;
    
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'card')),
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
              const Icon(Icons.trending_up, color: Colors.cyan, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Next Tier Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '$daysRemaining days to go',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(nextTier.color),
            borderRadius: BorderRadius.circular(4),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: nextTier.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  nextTier.icon,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextTier.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: nextTier.color,
                      ),
                    ),
                    Text(
                      nextTier.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMaxTierCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'card')),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.withValues(alpha: 0.3),
            Colors.amber.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('👑', style: TextStyle(fontSize: 24)),
          ),
          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Maximum Tier Achieved!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'You\'ve reached the highest streak tier in marine biology research',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTodaysRewardCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'card')),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withValues(alpha: 0.2),
            Colors.green.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_giftcard, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Today\'s Streak Rewards',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '+${todaysReward!.totalXP} XP',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
          Row(
            children: [
              Expanded(
                child: _buildRewardStat(
                  context,
                  'Sessions',
                  todaysReward!.sessionsCompleted.toString(),
                  Icons.timer,
                ),
              ),
              Expanded(
                child: _buildRewardStat(
                  context,
                  'Focus Time',
                  '${todaysReward!.focusTimeMinutes}m',
                  Icons.psychology,
                ),
              ),
              Expanded(
                child: _buildRewardStat(
                  context,
                  'Bonus Rate',
                  '+${(todaysReward!.discoveryRateBonus * 100).toInt()}%',
                  Icons.search,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildRewardStat(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 14, color: Colors.green),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.green,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.green.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUpcomingRewardsSection(BuildContext context) {
    final upcomingRewards = availableRewards
        .where((r) => !r.isUnlocked && r.requiredStreak <= currentStreak + 30) // Show next 30 days
        .take(3) // Show next 3 rewards
        .toList();
    
    if (upcomingRewards.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Rewards',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
        ...upcomingRewards.map((reward) => _buildUpcomingRewardCard(context, reward)),
      ],
    );
  }
  
  Widget _buildUpcomingRewardCard(BuildContext context, StreakReward reward) {
    final daysRemaining = reward.getDaysRemaining(currentStreak);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: reward.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: reward.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              reward.icon,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  reward.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$daysRemaining days',
                style: TextStyle(
                  fontSize: 12,
                  color: reward.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '+${reward.xpReward} XP',
                style: TextStyle(
                  fontSize: 10,
                  color: reward.color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}