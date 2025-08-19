import 'package:flutter/material.dart';

/// Streak Rewards Service for Phase 4
/// Handles streak tracking, bonuses, and marine biology themed rewards
class StreakRewardsService {
  
  /// Calculate streak bonus multiplier for XP and discovery rates
  static double calculateStreakMultiplier(int currentStreak) {
    if (currentStreak >= 100) return 3.0; // 300% bonus for legendary streaks
    if (currentStreak >= 60) return 2.5;  // 250% bonus for master streaks
    if (currentStreak >= 30) return 2.0;  // 200% bonus for expert streaks
    if (currentStreak >= 14) return 1.5;  // 150% bonus for advanced streaks
    if (currentStreak >= 7) return 1.3;   // 130% bonus for weekly streaks
    if (currentStreak >= 3) return 1.1;   // 110% bonus for consistent streaks
    return 1.0; // No bonus for streaks less than 3 days
  }
  
  /// Get discovery rate bonus for streak (affects creature spawn rates)
  static double calculateDiscoveryRateBonus(int currentStreak) {
    if (currentStreak >= 100) return 0.5;  // 50% increased discovery rate
    if (currentStreak >= 60) return 0.4;   // 40% increased discovery rate
    if (currentStreak >= 30) return 0.3;   // 30% increased discovery rate
    if (currentStreak >= 14) return 0.2;   // 20% increased discovery rate
    if (currentStreak >= 7) return 0.15;   // 15% increased discovery rate
    if (currentStreak >= 3) return 0.1;    // 10% increased discovery rate
    return 0.0; // No bonus
  }
  
  /// Get all available streak rewards
  static List<StreakReward> getStreakRewards(int currentStreak) {
    final rewards = <StreakReward>[];
    
    // Define streak milestone rewards
    final milestones = [
      (3, 'Consistent Explorer', 'Early morning diving pays off', '🌅', Colors.green, 100),
      (7, 'Weekly Researcher', 'A week of dedicated research', '📅', Colors.blue, 250),
      (14, 'Dedicated Scientist', 'Two weeks of ocean exploration', '⚡', Colors.purple, 500),
      (21, 'Research Devotee', 'Three weeks of marine studies', '🔬', Colors.orange, 750),
      (30, 'Monthly Explorer', 'A full month of discoveries', '💪', Colors.red, 1200),
      (60, 'Ocean Guardian', 'Two months protecting marine life', '🛡️', Colors.cyan, 2500),
      (90, 'Marine Biology Master', 'Three months of expertise', '👨‍🔬', Colors.amber, 4000),
      (100, 'Eternal Explorer', 'One hundred days of exploration', '♾️', Colors.deepPurple, 5000),
      (150, 'Ocean Legend', 'Five months of legendary research', '🌊', Colors.indigo, 7500),
      (200, 'Deep Sea Sage', 'Two hundred days of wisdom', '🧙‍♂️', Colors.teal, 10000),
      (365, 'Year-Long Voyager', 'A full year of ocean research', '🗓️', Colors.amber, 20000),
    ];
    
    for (final milestone in milestones) {
      final (days, title, description, icon, color, xpReward) = milestone;
      final isUnlocked = currentStreak >= days;
      final progress = currentStreak / days;
      
      rewards.add(StreakReward(
        id: 'streak_$days',
        requiredStreak: days,
        title: title,
        description: description,
        icon: icon,
        color: color,
        xpReward: xpReward,
        multiplierBonus: calculateStreakMultiplier(days),
        discoveryBonus: calculateDiscoveryRateBonus(days),
        isUnlocked: isUnlocked,
        progress: progress.clamp(0.0, 1.0),
        category: _getStreakCategory(days),
        unlocksBadge: days >= 30, // Major milestones get badges
        badge: days >= 30 ? _getBadgeForStreak(days, title, icon, color) : null,
      ));
    }
    
    return rewards;
  }
  
  /// Get streak category for organization
  static StreakCategory _getStreakCategory(int days) {
    if (days >= 100) return StreakCategory.legendary;
    if (days >= 30) return StreakCategory.expert;
    if (days >= 14) return StreakCategory.advanced;
    if (days >= 7) return StreakCategory.intermediate;
    return StreakCategory.beginner;
  }
  
  /// Get badge for significant streak milestones
  static StreakBadge _getBadgeForStreak(int days, String title, String icon, Color color) {
    String badgeDescription;
    if (days >= 365) {
      badgeDescription = 'Completed a full year of marine research';
    } else if (days >= 200) {
      badgeDescription = 'Achieved legendary research consistency';
    } else if (days >= 100) {
      badgeDescription = 'Mastered long-term research dedication';
    } else if (days >= 60) {
      badgeDescription = 'Demonstrated exceptional research commitment';
    } else if (days >= 30) {
      badgeDescription = 'Maintained consistent research habits';
    } else {
      badgeDescription = 'Achieved research milestone';
    }
    
    return StreakBadge(
      name: title,
      description: badgeDescription,
      icon: icon,
      color: color,
      streakRequired: days,
    );
  }
  
  /// Get current streak tier and benefits
  static StreakTier getCurrentStreakTier(int currentStreak) {
    if (currentStreak >= 100) {
      return StreakTier(
        name: 'Legendary Explorer',
        description: 'Ultimate marine research dedication',
        icon: '👑',
        color: Colors.amber,
        minStreak: 100,
        xpMultiplier: 3.0,
        discoveryBonus: 0.5,
        specialBenefit: 'Access to legendary creatures',
        tierLevel: 6,
      );
    } else if (currentStreak >= 60) {
      return StreakTier(
        name: 'Master Researcher',
        description: 'Exceptional research consistency',
        icon: '🎯',
        color: Colors.deepPurple,
        minStreak: 60,
        xpMultiplier: 2.5,
        discoveryBonus: 0.4,
        specialBenefit: 'Enhanced rare species detection',
        tierLevel: 5,
      );
    } else if (currentStreak >= 30) {
      return StreakTier(
        name: 'Expert Diver',
        description: 'Advanced research capabilities',
        icon: '⭐',
        color: Colors.orange,
        minStreak: 30,
        xpMultiplier: 2.0,
        discoveryBonus: 0.3,
        specialBenefit: 'Improved deep-sea access',
        tierLevel: 4,
      );
    } else if (currentStreak >= 14) {
      return StreakTier(
        name: 'Seasoned Explorer',
        description: 'Reliable research habits',
        icon: '🌟',
        color: Colors.purple,
        minStreak: 14,
        xpMultiplier: 1.5,
        discoveryBonus: 0.2,
        specialBenefit: 'Extended session bonuses',
        tierLevel: 3,
      );
    } else if (currentStreak >= 7) {
      return StreakTier(
        name: 'Regular Researcher',
        description: 'Weekly research commitment',
        icon: '📈',
        color: Colors.blue,
        minStreak: 7,
        xpMultiplier: 1.3,
        discoveryBonus: 0.15,
        specialBenefit: 'Faster coral growth',
        tierLevel: 2,
      );
    } else if (currentStreak >= 3) {
      return StreakTier(
        name: 'Consistent Diver',
        description: 'Building research habits',
        icon: '🌱',
        color: Colors.green,
        minStreak: 3,
        xpMultiplier: 1.1,
        discoveryBonus: 0.1,
        specialBenefit: 'Basic research bonuses',
        tierLevel: 1,
      );
    } else {
      return StreakTier(
        name: 'New Explorer',
        description: 'Starting marine research journey',
        icon: '🔍',
        color: Colors.grey,
        minStreak: 0,
        xpMultiplier: 1.0,
        discoveryBonus: 0.0,
        specialBenefit: 'None',
        tierLevel: 0,
      );
    }
  }
  
  /// Get next streak tier to motivate progression
  static StreakTier? getNextStreakTier(int currentStreak) {
    final nextMilestone = [3, 7, 14, 30, 60, 100].firstWhere(
      (milestone) => currentStreak < milestone,
      orElse: () => -1,
    );
    
    if (nextMilestone == -1) return null; // Already at maximum tier
    
    return getCurrentStreakTier(nextMilestone);
  }
  
  /// Calculate daily rewards based on streak
  static DailyStreakReward calculateDailyReward(
    int currentStreak,
    int sessionsToday,
    double totalFocusTimeToday,
  ) {
    final tier = getCurrentStreakTier(currentStreak);
    final baseXP = sessionsToday * 25; // Base XP per session
    final streakBonusXP = (baseXP * (tier.xpMultiplier - 1.0)).round();
    final timeBonus = (totalFocusTimeToday * 2.0).round(); // 2 XP per minute
    
    return DailyStreakReward(
      baseXP: baseXP,
      streakBonusXP: streakBonusXP,
      timeBonusXP: timeBonus,
      totalXP: baseXP + streakBonusXP + timeBonus,
      tier: tier,
      sessionsCompleted: sessionsToday,
      focusTimeMinutes: totalFocusTimeToday.round(),
      discoveryRateBonus: tier.discoveryBonus,
    );
  }
  
  /// Check for streak freeze opportunities (allow missing 1 day without breaking streak)
  static StreakFreeze? getStreakFreeze(int currentStreak, DateTime lastSessionDate) {
    final now = DateTime.now();
    final daysSinceLastSession = now.difference(lastSessionDate).inDays;
    
    // Only offer freeze for streaks >= 7 days
    if (currentStreak < 7) return null;
    
    // Only if it's been exactly 1 day since last session
    if (daysSinceLastSession != 1) return null;
    
    final freezesAvailable = _calculateAvailableFreezes(currentStreak);
    
    return StreakFreeze(
      currentStreak: currentStreak,
      freezesAvailable: freezesAvailable,
      costInXP: currentStreak * 10, // Cost scales with streak length
      description: 'Use a streak freeze to maintain your $currentStreak-day research streak',
      tier: getCurrentStreakTier(currentStreak),
    );
  }
  
  /// Calculate how many streak freezes are available based on streak length
  static int _calculateAvailableFreezes(int currentStreak) {
    if (currentStreak >= 100) return 5; // Legendary streaks get 5 freezes
    if (currentStreak >= 60) return 4;  // Master streaks get 4 freezes
    if (currentStreak >= 30) return 3;  // Expert streaks get 3 freezes
    if (currentStreak >= 14) return 2;  // Advanced streaks get 2 freezes
    if (currentStreak >= 7) return 1;   // Weekly streaks get 1 freeze
    return 0; // No freezes for short streaks
  }
  
  /// Get motivational messages based on streak status
  static String getStreakMotivationMessage(int currentStreak, bool isStreakIncreasing) {
    if (!isStreakIncreasing && currentStreak == 0) {
      return "🌊 Start your marine research journey today!";
    } else if (!isStreakIncreasing && currentStreak > 0) {
      return "🏊‍♂️ Get back to the ocean - your research station awaits!";
    } else if (isStreakIncreasing) {
      final tier = getCurrentStreakTier(currentStreak);
      final messages = [
        "🌅 Another day of ocean discoveries awaits!",
        "🔬 Your research consistency is paying off!",
        "🌊 The ocean rewards dedicated explorers like you!",
        "📊 Your ${tier.name} status grows stronger!",
        "🐠 Marine life appreciates your dedication!",
        "⚡ $currentStreak days of research excellence!",
      ];
      return messages[currentStreak % messages.length];
    }
    
    return "🌊 Ready for today's research dive?";
  }
  
  /// Get streak recovery suggestions
  static List<String> getStreakRecoveryTips(int lostStreak) {
    final tips = <String>[
      "🌅 Start with a short 15-minute morning research session",
      "📅 Set daily reminders for consistent research time",
      "🎯 Focus on small, achievable research goals",
      "🌊 Remember: every expert was once a beginner",
      "💪 Your previous $lostStreak-day streak shows you can do it again",
    ];
    
    if (lostStreak >= 30) {
      tips.add("👑 You've proven you can maintain long streaks - rebuild gradually");
    }
    
    if (lostStreak >= 7) {
      tips.add("⚡ You had great momentum before - use that experience");
    }
    
    return tips;
  }
}

/// Streak Reward Model
class StreakReward {
  final String id;
  final int requiredStreak;
  final String title;
  final String description;
  final String icon;
  final Color color;
  final int xpReward;
  final double multiplierBonus;
  final double discoveryBonus;
  final bool isUnlocked;
  final double progress;
  final StreakCategory category;
  final bool unlocksBadge;
  final StreakBadge? badge;

  const StreakReward({
    required this.id,
    required this.requiredStreak,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.xpReward,
    required this.multiplierBonus,
    required this.discoveryBonus,
    required this.isUnlocked,
    required this.progress,
    required this.category,
    required this.unlocksBadge,
    this.badge,
  });
  
  /// Get days remaining until unlock
  int getDaysRemaining(int currentStreak) {
    return (requiredStreak - currentStreak).clamp(0, requiredStreak);
  }
}

/// Streak Categories
enum StreakCategory {
  beginner,
  intermediate,
  advanced,
  expert,
  legendary,
}

extension StreakCategoryExtension on StreakCategory {
  String get displayName {
    switch (this) {
      case StreakCategory.beginner:
        return 'Beginner';
      case StreakCategory.intermediate:
        return 'Intermediate';
      case StreakCategory.advanced:
        return 'Advanced';
      case StreakCategory.expert:
        return 'Expert';
      case StreakCategory.legendary:
        return 'Legendary';
    }
  }
  
  Color get color {
    switch (this) {
      case StreakCategory.beginner:
        return Colors.green;
      case StreakCategory.intermediate:
        return Colors.blue;
      case StreakCategory.advanced:
        return Colors.purple;
      case StreakCategory.expert:
        return Colors.orange;
      case StreakCategory.legendary:
        return Colors.amber;
    }
  }
}

/// Streak Tier Model
class StreakTier {
  final String name;
  final String description;
  final String icon;
  final Color color;
  final int minStreak;
  final double xpMultiplier;
  final double discoveryBonus;
  final String specialBenefit;
  final int tierLevel;

  const StreakTier({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.minStreak,
    required this.xpMultiplier,
    required this.discoveryBonus,
    required this.specialBenefit,
    required this.tierLevel,
  });
  
  /// Get progress to next tier
  double getProgressToNext(int currentStreak, StreakTier? nextTier) {
    if (nextTier == null) return 1.0; // Already at max tier
    
    final progressInTier = currentStreak - minStreak;
    final tierRange = nextTier.minStreak - minStreak;
    
    return (progressInTier / tierRange).clamp(0.0, 1.0);
  }
}

/// Streak Badge Model
class StreakBadge {
  final String name;
  final String description;
  final String icon;
  final Color color;
  final int streakRequired;

  const StreakBadge({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.streakRequired,
  });
}

/// Daily Streak Reward Model
class DailyStreakReward {
  final int baseXP;
  final int streakBonusXP;
  final int timeBonusXP;
  final int totalXP;
  final StreakTier tier;
  final int sessionsCompleted;
  final int focusTimeMinutes;
  final double discoveryRateBonus;

  const DailyStreakReward({
    required this.baseXP,
    required this.streakBonusXP,
    required this.timeBonusXP,
    required this.totalXP,
    required this.tier,
    required this.sessionsCompleted,
    required this.focusTimeMinutes,
    required this.discoveryRateBonus,
  });
}

/// Streak Freeze Model
class StreakFreeze {
  final int currentStreak;
  final int freezesAvailable;
  final int costInXP;
  final String description;
  final StreakTier tier;

  const StreakFreeze({
    required this.currentStreak,
    required this.freezesAvailable,
    required this.costInXP,
    required this.description,
    required this.tier,
  });
}