import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'persistence/persistence_service.dart';
import 'marine_biology_career_service.dart';

class GamificationService {
  static GamificationService? _instance;
  static GamificationService get instance {
    _instance ??= GamificationService._();
    return _instance!;
  }
  
  GamificationService._();
  
  SharedPreferences? _prefs;
  
  // Keys for SharedPreferences
  static const String _xpKey = 'total_xp';
  static const String _levelKey = 'current_level';
  static const String _streakKey = 'current_streak';
  static const String _lastSessionDateKey = 'last_session_date';
  static const String _unlockedThemesKey = 'unlocked_themes';
  static const String _unlockedAchievementsKey = 'unlocked_achievements';
  static const String _totalSessionsKey = 'total_sessions';
  static const String _totalFocusTimeKey = 'total_focus_time';
  
  // XP and Level System
  int _totalXP = 0;
  int _currentLevel = 1;
  int _currentStreak = 0;
  DateTime? _lastSessionDate;
  Set<String> _unlockedThemes = {'default'};
  Set<String> _unlockedAchievements = {};
  int _totalSessions = 0;
  int _totalFocusTime = 0; // in seconds
  
  // Getters
  int get totalXP => _totalXP;
  int get currentLevel => _currentLevel;
  int get currentStreak => _currentStreak;
  Set<String> get unlockedThemes => _unlockedThemes;
  Set<String> get unlockedAchievements => _unlockedAchievements;
  int get totalSessions => _totalSessions;
  int get totalFocusTime => _totalFocusTime;
  
  // XP calculation - consistent with square root level formula
  int getXPForNextLevel() {
    // XP needed for next level based on square root formula
    final nextLevel = _currentLevel + 1;
    return getXPRequiredForLevel(nextLevel) - getXPRequiredForLevel(_currentLevel);
  }
  
  int getCurrentLevelXP() => _totalXP - getXPRequiredForLevel(_currentLevel);
  
  int getXPRequiredForLevel(int level) {
    // Inverse of sqrt formula: totalXP = ((level^2) - 1) * 50
    return ((level * level) - 1) * 50;
  }
  
  double getLevelProgress() {
    final currentLevelXP = getCurrentLevelXP();
    final xpForNextLevel = getXPForNextLevel();
    return xpForNextLevel > 0 ? (currentLevelXP / xpForNextLevel).clamp(0.0, 1.0) : 0.0;
  }
  
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await loadProgress();
  }
  
  Future<void> loadProgress() async {
    _totalXP = _prefs?.getInt(_xpKey) ?? 0;
    _currentLevel = _prefs?.getInt(_levelKey) ?? 1;
    _currentStreak = _prefs?.getInt(_streakKey) ?? 0;
    _totalSessions = _prefs?.getInt(_totalSessionsKey) ?? 0;
    _totalFocusTime = _prefs?.getInt(_totalFocusTimeKey) ?? 0;
    
    final lastSessionMillis = _prefs?.getInt(_lastSessionDateKey);
    _lastSessionDate = lastSessionMillis != null 
        ? DateTime.fromMillisecondsSinceEpoch(lastSessionMillis)
        : null;
    
    final themesString = _prefs?.getStringList(_unlockedThemesKey) ?? ['default'];
    _unlockedThemes = Set.from(themesString);
    
    final achievementsString = _prefs?.getStringList(_unlockedAchievementsKey) ?? [];
    _unlockedAchievements = Set.from(achievementsString);
  }
  
  Future<void> updateDailyWeeklyGoals({
    required int durationMinutes,
    required bool isStudySession,
  }) async {
    if (!isStudySession) return; // Only track focus sessions for goals
    
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month}-${now.day}';
    final weekKey = '${now.year}-week-${_getWeekNumber(now)}';
    
    // Update daily goals
    final dailySessions = (_prefs?.getInt('daily_sessions_$todayKey') ?? 0) + 1;
    final dailyMinutes = (_prefs?.getInt('daily_minutes_$todayKey') ?? 0) + durationMinutes;
    await _prefs?.setInt('daily_sessions_$todayKey', dailySessions);
    await _prefs?.setInt('daily_minutes_$todayKey', dailyMinutes);
    
    // Update weekly goals
    final weeklySessions = (_prefs?.getInt('weekly_sessions_$weekKey') ?? 0) + 1;
    final weeklyMinutes = (_prefs?.getInt('weekly_minutes_$weekKey') ?? 0) + durationMinutes;
    await _prefs?.setInt('weekly_sessions_$weekKey', weeklySessions);
    await _prefs?.setInt('weekly_minutes_$weekKey', weeklyMinutes);
  }
  
  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday - 1) / 7).ceil();
  }
  
  Future<GamificationReward> completeSession({
    required int durationMinutes,
    required bool isStudySession,
    double sessionDepthReached = 0.0,
    bool sessionCompleted = true,
    List<dynamic> discoveredCreatures = const [],
  }) async {
    final now = DateTime.now();
    final reward = GamificationReward();
    
    // Populate session metrics
    reward.sessionDurationMinutes = durationMinutes;
    reward.sessionDepthReached = sessionDepthReached;
    reward.sessionCompleted = sessionCompleted;
    reward.isStudySession = isStudySession;
    reward.allDiscoveredCreatures = List.from(discoveredCreatures);
    
    // Update daily/weekly goals
    await updateDailyWeeklyGoals(
      durationMinutes: durationMinutes,
      isStudySession: isStudySession,
    );
    
    // Calculate base XP based on session type and duration
    int baseXP = 0;
    if (isStudySession) {
      baseXP = (durationMinutes * 2.5).round(); // 2.5 XP per minute of focus
    } else {
      baseXP = (durationMinutes * 1).round(); // 1 XP per minute of break
    }
    
    // Streak calculation and bonus
    if (_isConsecutiveDay(now)) {
      _currentStreak++;
    } else if (_lastSessionDate == null || !_isSameDay(now, _lastSessionDate!)) {
      if (_lastSessionDate != null && !_isYesterday(now, _lastSessionDate!)) {
        _currentStreak = 1; // Reset streak if more than a day gap
      } else {
        _currentStreak = 1; // Start new streak
      }
    }
    
    // Apply streak multiplier
    final streakMultiplier = 1.0 + (_currentStreak * 0.1); // 10% bonus per streak day
    final streakBonusXP = (baseXP * (streakMultiplier - 1.0)).round();
    
    // Apply depth bonus for study sessions
    int depthBonusXP = 0;
    if (isStudySession && sessionDepthReached > 0) {
      double depthMultiplier = 1.0;
      if (sessionDepthReached > 40) {
        depthMultiplier = 1.5; // Abyssal zone bonus
      } else if (sessionDepthReached > 20) {
        depthMultiplier = 1.3; // Deep ocean bonus
      } else if (sessionDepthReached > 10) {
        depthMultiplier = 1.2; // Coral garden bonus
      }
      depthBonusXP = (baseXP * (depthMultiplier - 1.0)).round();
    }
    
    // Apply completion bonus
    int completionBonusXP = 0;
    if (sessionCompleted) {
      completionBonusXP = (baseXP * 0.2).round(); // 20% bonus for completion
    }
    
    final totalXPGained = baseXP + streakBonusXP + depthBonusXP + completionBonusXP;
    
    _totalXP += totalXPGained;
    _totalSessions++;
    if (isStudySession) {
      _totalFocusTime += durationMinutes * 60;
    }
    
    // Populate reward XP breakdown
    reward.xpGained = totalXPGained;
    reward.streakBonusXP = streakBonusXP;
    reward.streakMultiplier = streakMultiplier;
    reward.depthBonusXP = depthBonusXP;
    reward.completionBonusXP = completionBonusXP;
    reward.currentStreak = _currentStreak;
    
    // Career progression tracking
    final oldLevel = _currentLevel;
    final oldCareerTitle = MarineBiologyCareerService.getCareerTitle(_currentLevel);
    
    _currentLevel = _calculateLevel(_totalXP);
    final newCareerTitle = MarineBiologyCareerService.getCareerTitle(_currentLevel);
    
    reward.oldLevel = oldLevel;
    reward.newLevel = _currentLevel;
    reward.oldCareerTitle = oldCareerTitle;
    reward.newCareerTitle = newCareerTitle;
    reward.careerTitleChanged = oldCareerTitle != newCareerTitle;
    
    if (_currentLevel > oldLevel) {
      reward.leveledUp = true;
      
      // Unlock equipment based on new level
      try {
        final equipmentRepository = PersistenceService.instance.equipment;
        final unlockedEquipment = await equipmentRepository.checkAndUnlockEquipmentByLevel(_currentLevel);
        reward.unlockedEquipment = unlockedEquipment;
        if (unlockedEquipment.isNotEmpty) {
          debugPrint('🎒 Unlocked ${unlockedEquipment.length} new equipment items at level $_currentLevel');
          for (final equipmentId in unlockedEquipment) {
            debugPrint('🎒 Unlocked equipment: $equipmentId');
          }
        }
        
        // Generate next equipment hint
        final nextEquipmentLevel = _getNextEquipmentUnlockLevel(_currentLevel);
        if (nextEquipmentLevel > 0) {
          reward.nextEquipmentHint = "Next research equipment unlocks at Level $nextEquipmentLevel";
        }
      } catch (e) {
        debugPrint('❌ Error unlocking equipment: $e');
      }
      
      // Unlock theme for level milestone
      if (_currentLevel % 5 == 0) {
        final newTheme = _getThemeForLevel(_currentLevel);
        if (!_unlockedThemes.contains(newTheme)) {
          _unlockedThemes.add(newTheme);
          reward.unlockedThemes.add(newTheme);
        }
      }
    } else {
      // Still provide next unlock hints even without leveling up
      final nextEquipmentLevel = _getNextEquipmentUnlockLevel(_currentLevel);
      if (nextEquipmentLevel > 0) {
        final xpNeeded = getXPRequiredForLevel(nextEquipmentLevel) - _totalXP;
        reward.nextEquipmentHint = "Advanced research equipment unlocks at Level $nextEquipmentLevel ($xpNeeded XP needed)";
      }
    }
    
    // Generate next career milestone hint
    final nextCareerMilestone = _getNextCareerMilestone(_currentLevel);
    if (nextCareerMilestone != null) {
      reward.nextCareerMilestone = nextCareerMilestone;
    }
    
    // Check for achievements
    final newAchievements = _checkAchievements();
    reward.unlockedAchievements.addAll(newAchievements);
    
    // Calculate research efficiency
    reward.researchEfficiency = _calculateResearchEfficiency(durationMinutes, discoveredCreatures, sessionCompleted);
    
    _lastSessionDate = now;
    
    await _saveProgress();
    
    return reward;
  }
  
  int _calculateLevel(int totalXP) {
    // Level formula: level = sqrt((totalXP / 50) + 1)
    return (math.sqrt((totalXP / 50) + 1)).floor();
  }
  
  String _getThemeForLevel(int level) {
    final themes = ['sunset', 'ocean', 'forest', 'cosmos', 'aurora', 'cyberpunk'];
    final themeIndex = (level ~/ 5 - 1) % themes.length;
    return themes[themeIndex];
  }
  
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  bool _isYesterday(DateTime today, DateTime date) {
    final yesterday = today.subtract(const Duration(days: 1));
    return _isSameDay(yesterday, date);
  }
  
  bool _isConsecutiveDay(DateTime now) {
    if (_lastSessionDate == null) return false;
    return _isSameDay(now, _lastSessionDate!) || _isYesterday(now, _lastSessionDate!);
  }
  
  List<Achievement> _checkAchievements() {
    final newAchievements = <Achievement>[];
    
    // Define achievements
    final achievements = [
      Achievement(
        id: 'first_session',
        title: 'Getting Started',
        description: 'Complete your first focus session',
        icon: Icons.play_arrow,
        color: Colors.green,
        condition: () => _totalSessions >= 1,
      ),
      Achievement(
        id: 'streak_3',
        title: 'On Fire!',
        description: 'Maintain a 3-day streak',
        icon: Icons.local_fire_department,
        color: Colors.orange,
        condition: () => _currentStreak >= 3,
      ),
      Achievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        icon: Icons.military_tech,
        color: Colors.purple,
        condition: () => _currentStreak >= 7,
      ),
      Achievement(
        id: 'sessions_25',
        title: 'Quarter Century',
        description: 'Complete 25 focus sessions',
        icon: Icons.star,
        color: Colors.amber,
        condition: () => _totalSessions >= 25,
      ),
      Achievement(
        id: 'sessions_100',
        title: 'Centurion',
        description: 'Complete 100 focus sessions',
        icon: Icons.diamond,
        color: Colors.cyan,
        condition: () => _totalSessions >= 100,
      ),
      Achievement(
        id: 'focus_10_hours',
        title: 'Deep Diver',
        description: 'Accumulate 10 hours of focus time',
        icon: Icons.psychology,
        color: Colors.blue,
        condition: () => _totalFocusTime >= 36000, // 10 hours in seconds
      ),
      Achievement(
        id: 'level_10',
        title: 'Expert',
        description: 'Reach level 10',
        icon: Icons.emoji_events,
        color: Colors.amber,
        condition: () => _currentLevel >= 10,
      ),
      Achievement(
        id: 'level_25',
        title: 'Master',
        description: 'Reach level 25',
        icon: Icons.workspace_premium,
        color: Colors.deepPurple,
        condition: () => _currentLevel >= 25,
      ),
    ];
    
    for (final achievement in achievements) {
      if (!_unlockedAchievements.contains(achievement.id) && achievement.condition()) {
        _unlockedAchievements.add(achievement.id);
        newAchievements.add(achievement);
      }
    }
    
    return newAchievements;
  }
  
  Future<void> _saveProgress() async {
    await _prefs?.setInt(_xpKey, _totalXP);
    await _prefs?.setInt(_levelKey, _currentLevel);
    await _prefs?.setInt(_streakKey, _currentStreak);
    await _prefs?.setInt(_totalSessionsKey, _totalSessions);
    await _prefs?.setInt(_totalFocusTimeKey, _totalFocusTime);
    
    if (_lastSessionDate != null) {
      await _prefs?.setInt(_lastSessionDateKey, _lastSessionDate!.millisecondsSinceEpoch);
    }
    
    await _prefs?.setStringList(_unlockedThemesKey, _unlockedThemes.toList());
    await _prefs?.setStringList(_unlockedAchievementsKey, _unlockedAchievements.toList());
  }
  
  // Get streak emoji based on count
  String getStreakEmoji() {
    if (_currentStreak >= 30) return '🔥'; // Fire for long streaks
    if (_currentStreak >= 14) return '⚡'; // Lightning for good streaks
    if (_currentStreak >= 7) return '🌟'; // Star for week streaks
    if (_currentStreak >= 3) return '💪'; // Muscle for short streaks
    if (_currentStreak >= 1) return '🌱'; // Plant for starting
    return '💤'; // Sleep for no streak
  }
  
  Color getStreakColor() {
    if (_currentStreak >= 30) return Colors.deepOrange;
    if (_currentStreak >= 14) return Colors.amber;
    if (_currentStreak >= 7) return Colors.purple;
    if (_currentStreak >= 3) return Colors.green;
    if (_currentStreak >= 1) return Colors.lightGreen;
    return Colors.grey;
  }
  
  // Helper method to find next equipment unlock level
  int _getNextEquipmentUnlockLevel(int currentLevel) {
    // Common equipment unlock levels (simplified)
    final equipmentLevels = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50];
    for (final level in equipmentLevels) {
      if (level > currentLevel) {
        return level;
      }
    }
    return 0; // No more unlocks
  }
  
  // Helper method to generate next career milestone hint
  String? _getNextCareerMilestone(int currentLevel) {
    final nextMilestone = MarineBiologyCareerService.careerTitles.entries
        .where((entry) => entry.key > currentLevel)
        .firstOrNull;
    
    if (nextMilestone != null) {
      final xpNeeded = getXPRequiredForLevel(nextMilestone.key) - _totalXP;
      return "Next promotion: ${nextMilestone.value} at Level ${nextMilestone.key} ($xpNeeded XP needed)";
    }
    return null;
  }
  
  // Calculate research efficiency based on session performance
  double _calculateResearchEfficiency(int durationMinutes, List<dynamic> discoveredCreatures, bool completed) {
    double efficiency = 0.0;
    
    // Base efficiency from session completion
    if (completed) {
      efficiency += 2.0;
    } else {
      efficiency += 1.0;
    }
    
    // Bonus for discoveries
    efficiency += discoveredCreatures.length * 1.5;
    
    // Duration efficiency (optimal around 25-45 minutes)
    if (durationMinutes >= 20 && durationMinutes <= 50) {
      efficiency += 1.0;
    } else if (durationMinutes >= 15 && durationMinutes <= 60) {
      efficiency += 0.5;
    }
    
    return efficiency;
  }
}

class GamificationReward {
  // Basic XP and Level Progression
  int xpGained = 0;
  bool leveledUp = false;
  int oldLevel = 1;
  int newLevel = 1;
  int currentStreak = 0;
  
  // Career Progression
  String? oldCareerTitle;
  String? newCareerTitle;
  bool careerTitleChanged = false;
  
  // Equipment and Achievements
  List<String> unlockedThemes = [];
  List<Achievement> unlockedAchievements = [];
  List<String> unlockedEquipment = [];
  
  // Session-specific rewards
  dynamic discoveredCreature; // Can be Creature or null
  List<dynamic> allDiscoveredCreatures = []; // Multiple creatures per session
  
  // Research Progress
  int researchPapersUnlocked = 0;
  List<String> researchPaperIds = [];
  
  // Session Quality Metrics
  int sessionDurationMinutes = 0;
  double sessionDepthReached = 0.0;
  bool sessionCompleted = true;
  bool isStudySession = true; // Track whether this was a study session or break session
  double researchEfficiency = 0.0;
  
  // Streak and Bonus Information
  int streakBonusXP = 0;
  double streakMultiplier = 1.0;
  int depthBonusXP = 0;
  int completionBonusXP = 0;
  
  // Progress Hints (for next unlocks without spoiling)
  String? nextEquipmentHint;
  String? nextAchievementHint;
  String? nextCareerMilestone;
  
  // Calculate total research value
  int get totalResearchValue {
    int total = xpGained;
    if (discoveredCreature != null) {
      total += (discoveredCreature.pearlValue ?? 0) as int;
    }
    for (final creature in allDiscoveredCreatures) {
      if (creature?.pearlValue != null) {
        total += (creature.pearlValue as int);
      }
    }
    return total;
  }
  
  // Check if this session had significant accomplishments
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
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool Function() condition;
  
  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.condition,
  });
}