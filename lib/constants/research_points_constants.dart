/// Research Points (RP) system constants for FlowPulse hybrid leveling
/// 
/// This file defines the core constants and formulas for the RP-based
/// progression system that promotes sustainable productivity habits.
class ResearchPointsConstants {
  ResearchPointsConstants._();

  // Base RP Formula Constants
  static const int baseRPPerMinute = 25; // Base RP calculation: minutes / 25 = base RP
  static const int minSessionForRP = 5; // Minimum session duration for RP (5 minutes)
  static const int maxBaseRP = 40; // Maximum base RP from a single session
  
  // Reference RP values for common session durations
  static const Map<int, int> referenceSessionRP = {
    5: 2,   // 5min = 2 RP (minimum)
    10: 4,  // 10min = 4 RP
    15: 6,  // 15min = 6 RP
    20: 8,  // 20min = 8 RP
    25: 10, // 25min = 10 RP (standard Pomodoro)
    30: 12, // 30min = 12 RP
    45: 18, // 45min = 18 RP
    50: 20, // 50min = 20 RP
    60: 24, // 60min = 24 RP
    90: 36, // 90min = 36 RP
    120: 40, // 120min+ = 40 RP (capped)
  };

  // Bonus RP System
  static const int breakAdherenceBonus = 2; // +2 RP for taking proper breaks
  static const int streakBonus = 5; // +5 RP for daily streak (max 1 per day)
  static const int perfectSessionBonus = 1; // +1 RP for perfect session quality
  
  // Maximum bonuses to prevent exploitation
  static const int maxBonusRP = 8; // Maximum total bonus RP per session
  static const int maxStreakBonusPerDay = 1; // Prevent multiple streak bonuses per day
  
  // Session Quality Multipliers
  static const Map<SessionQuality, double> qualityMultipliers = {
    SessionQuality.perfect: 1.0, // 100% of calculated RP
    SessionQuality.good: 0.85,   // 85% of calculated RP
    SessionQuality.abandoned: 0.0, // 0% of calculated RP (no rewards for incomplete sessions)
  };

  // Break Adherence Criteria
  static const int minBreakDurationSeconds = 30; // Minimum break duration for bonus
  static const int maxSessionWithoutBreakMinutes = 60; // Sessions over 60min should have breaks
  static const double breakToSessionRatio = 0.15; // Break should be at least 15% of session time
  
  // Depth Zone RP Thresholds (Cumulative RP)
  static const Map<int, String> depthZoneThresholds = {
    0: 'Shallow Waters',     // 0-50 RP
    51: 'Coral Garden',      // 51-200 RP  
    201: 'Deep Ocean',       // 201-500 RP
    501: 'Abyssal Zone',     // 501+ RP
  };
  
  static const List<int> depthZoneBoundaries = [0, 51, 201, 501];
  
  // Career Title RP Thresholds (Cumulative RP)
  static const Map<int, String> careerTitleThresholds = {
    0: 'Marine Biology Intern',
    50: 'Junior Research Assistant',
    150: 'Research Assistant',
    300: 'Marine Biology Student',
    500: 'Research Associate',
    750: 'Field Researcher',
    1050: 'Marine Biologist',
    1400: 'Senior Marine Biologist',
    1800: 'Research Scientist',
    2250: 'Senior Research Scientist',
    2750: 'Principal Investigator',
    3300: 'Marine Biology Expert',
    3900: 'Distinguished Researcher',
    4550: 'Research Director',
    5250: 'Marine Biology Professor',
    6000: 'Department Head',
    6800: 'Research Institute Director',
    7650: 'World-Renowned Expert',
    8550: 'Marine Biology Legend',
    9500: 'Ocean Pioneer',
    10500: 'Master Marine Biologist',
  };
  
  static const List<int> careerMilestones = [
    0, 50, 150, 300, 500, 750, 1050, 1400, 1800, 2250,
    2750, 3300, 3900, 4550, 5250, 6000, 6800, 7650, 8550, 9500, 10500
  ];

  // Equipment Unlock RP Thresholds
  static const Map<int, String> equipmentUnlockThresholds = {
    0: 'Basic Equipment',      // Starting gear
    50: 'Common Equipment',    // Basic improvements
    150: 'Uncommon Equipment', // Professional tools
    300: 'Rare Equipment',     // Advanced instruments
    500: 'Epic Equipment',     // Research-grade equipment
    750: 'Legendary Equipment', // Cutting-edge technology
    1400: 'Master Equipment',  // Expert-level gear
    2250: 'Elite Equipment',   // Institution-quality tools
  };

  // Mission RP Rewards
  static const Map<String, int> missionRewards = {
    'daily_easy': 5,     // Easy daily missions
    'daily_medium': 10,  // Medium daily missions  
    'daily_hard': 15,    // Hard daily missions
    'weekly_easy': 20,   // Easy weekly missions
    'weekly_medium': 35, // Medium weekly missions
    'weekly_hard': 50,   // Hard weekly missions
    'achievement_easy': 25,   // Easy achievement missions
    'achievement_medium': 45, // Medium achievement missions
    'achievement_hard': 75,   // Hard achievement missions
  };

  // Validation Constants
  static const int minValidSessionSeconds = 300; // 5 minutes minimum
  static const int maxValidSessionSeconds = 14400; // 4 hours maximum
  static const int maxDailyRP = 200; // Reasonable daily RP limit to prevent exploitation
  
  // Streak System Constants
  static const int maxStreakForBonus = 365; // Maximum trackable streak
  static const int minStreakForBonus = 2; // Minimum streak days for bonus
}

/// Session quality levels that affect RP calculation
enum SessionQuality {
  perfect,   // Completed session with proper break adherence
  good,      // Completed session without perfect break adherence  
  abandoned, // Incomplete/interrupted session
}

/// Extension methods for SessionQuality enum
extension SessionQualityExtension on SessionQuality {
  /// Get the display name for the session quality
  String get displayName {
    switch (this) {
      case SessionQuality.perfect:
        return 'Perfect';
      case SessionQuality.good:
        return 'Good';
      case SessionQuality.abandoned:
        return 'Abandoned';
    }
  }
  
  /// Get the description for the session quality
  String get description {
    switch (this) {
      case SessionQuality.perfect:
        return 'Session completed with proper break adherence';
      case SessionQuality.good:
        return 'Session completed successfully';
      case SessionQuality.abandoned:
        return 'Session was interrupted or abandoned';
    }
  }
  
  /// Get the icon for the session quality
  String get icon {
    switch (this) {
      case SessionQuality.perfect:
        return '⭐';
      case SessionQuality.good:
        return '✅';
      case SessionQuality.abandoned:
        return '❌';
    }
  }
  
  /// Get the color associated with this quality level
  /// Returns hex color code string for compatibility
  /// Maps to unified OceanThemeColors:
  /// - Perfect: seafoamGreen (#7FB3B1)
  /// - Good: deepOceanAccent (#4682B4)
  /// - Abandoned: coralPink (#FF9B85)
  String get colorCode {
    switch (this) {
      case SessionQuality.perfect:
        return '#7FB3B1'; // Seafoam green (from OceanThemeColors)
      case SessionQuality.good:
        return '#4682B4'; // Deep ocean accent (from OceanThemeColors)
      case SessionQuality.abandoned:
        return '#FF9B85'; // Coral pink (from OceanThemeColors)
    }
  }
}