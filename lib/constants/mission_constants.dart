/// Mission System Constants
///
/// Defines mission types, categories, difficulties, and reward structures
/// for the FlowPulse hybrid leveling system.
class MissionConstants {
  MissionConstants._();

  // Mission Types
  static const String typeDaily = 'daily';
  static const String typeWeekly = 'weekly';
  static const String typeAchievement = 'achievement';

  // Mission Categories
  static const String categoryConsistency = 'consistency';
  static const String categoryProductivity = 'productivity';
  static const String categoryDiscovery = 'discovery';
  static const String categoryQuality = 'quality';

  // Mission Difficulties
  static const String difficultyBeginner = 'beginner';
  static const String difficultyIntermediate = 'intermediate';
  static const String difficultyAdvanced = 'advanced';
  static const String difficultyExpert = 'expert';

  // Mission Statuses
  static const String statusActive = 'active';
  static const String statusCompleted = 'completed';
  static const String statusExpired = 'expired';
  static const String statusLocked = 'locked';

  // RP Rewards by Difficulty
  static const Map<String, int> rpRewardsByDifficulty = {
    difficultyBeginner: 5,      // Basic missions for new users
    difficultyIntermediate: 10, // Standard daily missions
    difficultyAdvanced: 20,     // Weekly missions
    difficultyExpert: 50,       // Achievement-based missions
  };

  // Mission Duration Limits (in hours)
  static const Map<String, int> missionDurationHours = {
    typeDaily: 24,        // Daily missions expire in 24 hours
    typeWeekly: 168,      // Weekly missions expire in 7 days
    typeAchievement: -1,  // Achievement missions never expire
  };

  // Maximum Active Missions by Type
  static const Map<String, int> maxActiveMissions = {
    typeDaily: 3,         // Maximum 3 daily missions active
    typeWeekly: 2,        // Maximum 2 weekly missions active
    typeAchievement: 10,  // Up to 10 achievement missions can be active
  };

  // Mission Target Value Ranges by Category and Difficulty
  static const Map<String, Map<String, Map<String, int>>> targetRanges = {
    categoryConsistency: {
      difficultyBeginner: {'min': 1, 'max': 3},     // 1-3 sessions
      difficultyIntermediate: {'min': 3, 'max': 5}, // 3-5 sessions
      difficultyAdvanced: {'min': 5, 'max': 10},    // 5-10 day streak
      difficultyExpert: {'min': 14, 'max': 30},     // 14-30 day streak
    },
    categoryProductivity: {
      difficultyBeginner: {'min': 25, 'max': 50},   // 25-50 minutes total
      difficultyIntermediate: {'min': 75, 'max': 125}, // 75-125 minutes total
      difficultyAdvanced: {'min': 200, 'max': 400},    // 200-400 minutes weekly
      difficultyExpert: {'min': 500, 'max': 1000},     // 500-1000 minutes monthly
    },
    categoryDiscovery: {
      difficultyBeginner: {'min': 1, 'max': 2},     // 1-2 discoveries
      difficultyIntermediate: {'min': 2, 'max': 4}, // 2-4 discoveries
      difficultyAdvanced: {'min': 5, 'max': 10},    // 5-10 discoveries weekly
      difficultyExpert: {'min': 20, 'max': 50},     // 20-50 unique species
    },
    categoryQuality: {
      difficultyBeginner: {'min': 1, 'max': 2},     // 1-2 perfect sessions
      difficultyIntermediate: {'min': 3, 'max': 5}, // 3-5 perfect sessions
      difficultyAdvanced: {'min': 5, 'max': 10},    // 5-10 perfect sessions weekly
      difficultyExpert: {'min': 80, 'max': 95},     // 80-95% quality rate
    },
  };

  // Mission Templates by Category
  static const Map<String, List<Map<String, dynamic>>> missionTemplates = {
    categoryConsistency: [
      {
        'id': 'daily_consistency_1',
        'title': 'Daily Dive',
        'description': 'Complete {target} research sessions today',
        'type': typeDaily,
        'difficulty': difficultyBeginner,
        'category': categoryConsistency,
      },
      {
        'id': 'weekly_streak_1',
        'title': 'Research Streak',
        'description': 'Maintain a {target}-day research streak',
        'type': typeWeekly,
        'difficulty': difficultyAdvanced,
        'category': categoryConsistency,
      },
      {
        'id': 'achievement_dedication',
        'title': 'Dedicated Researcher',
        'description': 'Complete sessions for {target} consecutive days',
        'type': typeAchievement,
        'difficulty': difficultyExpert,
        'category': categoryConsistency,
      },
    ],
    categoryProductivity: [
      {
        'id': 'daily_focus_1',
        'title': 'Focus Time',
        'description': 'Complete {target} minutes of focused research today',
        'type': typeDaily,
        'difficulty': difficultyIntermediate,
        'category': categoryProductivity,
      },
      {
        'id': 'weekly_research_1',
        'title': 'Weekly Research Goal',
        'description': 'Log {target} minutes of research time this week',
        'type': typeWeekly,
        'difficulty': difficultyAdvanced,
        'category': categoryProductivity,
      },
    ],
    categoryDiscovery: [
      {
        'id': 'daily_discovery_1',
        'title': 'New Species',
        'description': 'Discover {target} new marine species today',
        'type': typeDaily,
        'difficulty': difficultyBeginner,
        'category': categoryDiscovery,
      },
      {
        'id': 'weekly_explorer_1',
        'title': 'Marine Explorer',
        'description': 'Discover {target} species across different biomes this week',
        'type': typeWeekly,
        'difficulty': difficultyAdvanced,
        'category': categoryDiscovery,
      },
      {
        'id': 'achievement_biodiversity',
        'title': 'Biodiversity Expert',
        'description': 'Discover {target} unique marine species in total',
        'type': typeAchievement,
        'difficulty': difficultyExpert,
        'category': categoryDiscovery,
      },
    ],
    categoryQuality: [
      {
        'id': 'daily_perfect_1',
        'title': 'Perfect Research',
        'description': 'Complete {target} perfect research sessions today',
        'type': typeDaily,
        'difficulty': difficultyIntermediate,
        'category': categoryQuality,
      },
      {
        'id': 'weekly_excellence_1',
        'title': 'Research Excellence',
        'description': 'Achieve {target}% session completion rate this week',
        'type': typeWeekly,
        'difficulty': difficultyExpert,
        'category': categoryQuality,
      },
    ],
  };

  // Bonus Rewards for Mission Completion Streaks
  static const Map<int, int> streakBonusRP = {
    3: 5,   // +5 RP for completing 3 missions in a row
    7: 15,  // +15 RP for completing 7 missions in a row
    14: 30, // +30 RP for completing 14 missions in a row
    30: 75, // +75 RP for completing 30 missions in a row
  };

  // Special Mission Events (seasonal/limited time)
  static const Map<String, Map<String, dynamic>> specialEvents = {
    'marine_conservation_week': {
      'name': 'Marine Conservation Week',
      'description': 'Special missions focused on marine conservation research',
      'duration_days': 7,
      'rp_multiplier': 1.5,
      'exclusive_rewards': ['conservation_badge', 'marine_protector_title'],
    },
    'deep_sea_exploration': {
      'name': 'Deep Sea Exploration Challenge',
      'description': 'Focus on deep ocean and abyssal zone discoveries',
      'duration_days': 14,
      'rp_multiplier': 2.0,
      'exclusive_rewards': ['deep_explorer_badge', 'abyssal_researcher_title'],
    },
  };

  // Mission Progress Tracking Types
  static const String progressTypeCount = 'count';         // Count discrete actions
  static const String progressTypeTime = 'time';           // Track time duration
  static const String progressTypePercentage = 'percentage'; // Track percentage completion
  static const String progressTypeStreak = 'streak';       // Track consecutive days

  // Mission Notification Settings
  static const Map<String, bool> defaultNotifications = {
    'new_mission_available': true,
    'mission_progress_update': false,
    'mission_completion': true,
    'mission_expiry_warning': true,
    'streak_bonus_earned': true,
  };

  // Mission Icon Mappings
  static const Map<String, String> categoryIcons = {
    categoryConsistency: '📅',
    categoryProductivity: '⏱️',
    categoryDiscovery: '🔍',
    categoryQuality: '⭐',
  };

  static const Map<String, String> difficultyIcons = {
    difficultyBeginner: '🟢',
    difficultyIntermediate: '🟡',
    difficultyAdvanced: '🟠',
    difficultyExpert: '🔴',
  };

  // Helper Methods
  static int getRPReward(String difficulty) {
    return rpRewardsByDifficulty[difficulty] ?? 0;
  }

  static int getMissionDuration(String type) {
    return missionDurationHours[type] ?? -1;
  }

  static Map<String, int> getTargetRange(String category, String difficulty) {
    return targetRanges[category]?[difficulty] ?? {'min': 1, 'max': 1};
  }

  static String getCategoryIcon(String category) {
    return categoryIcons[category] ?? '📋';
  }

  static String getDifficultyIcon(String difficulty) {
    return difficultyIcons[difficulty] ?? '⚪';
  }

  static List<Map<String, dynamic>> getTemplatesForCategory(String category) {
    return missionTemplates[category] ?? [];
  }
}