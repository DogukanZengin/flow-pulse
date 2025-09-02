import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../persistence_service.dart';

/// Repository for managing gamification data
class GamificationRepository {
  final PersistenceService _persistence;
  
  GamificationRepository(this._persistence);

  // Get gamification state
  Future<Map<String, dynamic>> getGamificationState() async {
    final db = await _persistence.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'gamification_state',
      where: 'id = 1',
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    
    // Return default state if none exists
    return {
      'id': 1,
      'total_rp': 0,
      'cumulative_rp': 0,
      'current_depth_zone': 0,
      'current_level': 1,
      'current_streak': 0,
      'longest_streak': 0,
      'last_session_date': null,
      'unlocked_themes': '["default"]',
      'unlocked_achievements': '[]',
      'total_sessions': 0,
      'total_focus_time': 0,
      'daily_goals': '{}',
      'weekly_goals': '{}',
      'monthly_goals': '{}',
    };
  }

  // Save gamification state
  Future<void> saveGamificationState(Map<String, dynamic> state) async {
    final db = await _persistence.database;
    
    state['last_updated'] = DateTime.now().millisecondsSinceEpoch;
    
    await db.insert(
      'gamification_state',
      state,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update RP and level
  Future<void> addRP(int rpToAdd) async {
    final state = await getGamificationState();
    final currentRP = state['total_rp'] as int;
    final currentCumulativeRP = state['cumulative_rp'] as int;
    final newRP = currentRP + rpToAdd;
    final newCumulativeRP = currentCumulativeRP + rpToAdd;
    
    // Calculate new level
    final newLevel = _calculateLevel(newRP);
    
    // Calculate new depth zone based on cumulative RP
    final newDepthZone = _calculateDepthZone(newCumulativeRP);
    
    state['total_rp'] = newRP;
    state['cumulative_rp'] = newCumulativeRP;
    state['current_level'] = newLevel;
    state['current_depth_zone'] = newDepthZone;
    
    await saveGamificationState(state);
  }

  // Calculate level from RP
  int _calculateLevel(int totalRP) {
    // Level formula: each level requires progressively more RP
    int level = 1;
    int rpNeeded = 0;
    
    while (rpNeeded <= totalRP) {
      level++;
      rpNeeded += level * 50; // Each level requires level * 50 RP (adjusted from XP)
    }
    
    return level - 1;
  }

  // Calculate depth zone from cumulative RP
  int _calculateDepthZone(int cumulativeRP) {
    // Depth zones based on cumulative RP thresholds
    if (cumulativeRP >= 501) return 3; // Abyssal Zone
    if (cumulativeRP >= 201) return 2; // Deep Ocean
    if (cumulativeRP >= 51) return 1;  // Coral Garden
    return 0; // Shallow Waters
  }

  // Get RP required for next level
  Future<int> getRPForNextLevel() async {
    final state = await getGamificationState();
    final currentLevel = state['current_level'] as int;
    return (currentLevel + 1) * 50;
  }

  // Update streak
  Future<void> updateStreak(int streak) async {
    final state = await getGamificationState();
    final longestStreak = state['longest_streak'] as int;
    
    state['current_streak'] = streak;
    if (streak > longestStreak) {
      state['longest_streak'] = streak;
    }
    state['last_session_date'] = DateTime.now().millisecondsSinceEpoch;
    
    await saveGamificationState(state);
  }

  // Add unlocked theme
  Future<void> unlockTheme(String theme) async {
    final state = await getGamificationState();
    final themesJson = state['unlocked_themes'] as String? ?? '[]';
    final themes = List<String>.from(jsonDecode(themesJson));
    
    if (!themes.contains(theme)) {
      themes.add(theme);
      state['unlocked_themes'] = jsonEncode(themes);
      await saveGamificationState(state);
    }
  }

  // Get unlocked themes
  Future<List<String>> getUnlockedThemes() async {
    final state = await getGamificationState();
    final themesJson = state['unlocked_themes'] as String? ?? '["default"]';
    return List<String>.from(jsonDecode(themesJson));
  }

  // Add unlocked achievement
  Future<void> unlockAchievement(String achievementId) async {
    final state = await getGamificationState();
    final achievementsJson = state['unlocked_achievements'] as String? ?? '[]';
    final achievements = List<String>.from(jsonDecode(achievementsJson));
    
    if (!achievements.contains(achievementId)) {
      achievements.add(achievementId);
      state['unlocked_achievements'] = jsonEncode(achievements);
      await saveGamificationState(state);
    }
  }

  // Get unlocked achievements
  Future<List<String>> getUnlockedAchievements() async {
    final state = await getGamificationState();
    final achievementsJson = state['unlocked_achievements'] as String? ?? '[]';
    return List<String>.from(jsonDecode(achievementsJson));
  }

  // Increment session count
  Future<void> incrementSessionCount() async {
    final state = await getGamificationState();
    state['total_sessions'] = (state['total_sessions'] as int) + 1;
    await saveGamificationState(state);
  }

  // Add focus time
  Future<void> addFocusTime(int seconds) async {
    final state = await getGamificationState();
    state['total_focus_time'] = (state['total_focus_time'] as int) + seconds;
    await saveGamificationState(state);
  }

  // Update daily goals
  Future<void> updateDailyGoals(Map<String, dynamic> goals) async {
    final state = await getGamificationState();
    state['daily_goals'] = jsonEncode(goals);
    await saveGamificationState(state);
  }

  // Get daily goals
  Future<Map<String, dynamic>> getDailyGoals() async {
    final state = await getGamificationState();
    final goalsJson = state['daily_goals'] as String? ?? '{}';
    return Map<String, dynamic>.from(jsonDecode(goalsJson));
  }

  // Update weekly goals
  Future<void> updateWeeklyGoals(Map<String, dynamic> goals) async {
    final state = await getGamificationState();
    state['weekly_goals'] = jsonEncode(goals);
    await saveGamificationState(state);
  }

  // Get weekly goals
  Future<Map<String, dynamic>> getWeeklyGoals() async {
    final state = await getGamificationState();
    final goalsJson = state['weekly_goals'] as String? ?? '{}';
    return Map<String, dynamic>.from(jsonDecode(goalsJson));
  }

  // === ACHIEVEMENTS ===
  
  // Save achievement
  Future<void> saveAchievement(Map<String, dynamic> achievement) async {
    final db = await _persistence.database;
    
    await db.insert(
      'achievements',
      achievement,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all achievements
  Future<List<Map<String, dynamic>>> getAllAchievements() async {
    final db = await _persistence.database;
    
    return await db.query(
      'achievements',
      orderBy: 'category, title',
    );
  }

  // Get unlocked achievements with details
  Future<List<Map<String, dynamic>>> getUnlockedAchievementsWithDetails() async {
    final db = await _persistence.database;
    
    return await db.query(
      'achievements',
      where: 'unlocked = 1',
      orderBy: 'unlocked_date DESC',
    );
  }

  // Get achievements by category
  Future<List<Map<String, dynamic>>> getAchievementsByCategory(String category) async {
    final db = await _persistence.database;
    
    return await db.query(
      'achievements',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'title',
    );
  }

  // Update achievement progress
  Future<void> updateAchievementProgress(
    String achievementId,
    double progress,
    int currentValue,
  ) async {
    final db = await _persistence.database;
    
    await db.update(
      'achievements',
      {
        'progress': progress,
        'current_value': currentValue,
      },
      where: 'id = ?',
      whereArgs: [achievementId],
    );
  }

  // Unlock achievement
  Future<void> unlockAchievementWithDetails(
    String achievementId, {
    int? rpReward,
  }) async {
    final db = await _persistence.database;
    
    await db.update(
      'achievements',
      {
        'unlocked': 1,
        'unlocked_date': DateTime.now().millisecondsSinceEpoch,
        'progress': 1.0,
        if (rpReward != null) 'rp_reward': rpReward,
      },
      where: 'id = ?',
      whereArgs: [achievementId],
    );
    
    // Also add to gamification state
    await unlockAchievement(achievementId);
    
    // Add RP if provided
    if (rpReward != null) {
      await addRP(rpReward);
    }
  }

  // Check and unlock achievements based on conditions
  Future<List<String>> checkAndUnlockAchievements({
    int? totalSessions,
    int? currentStreak,
    int? totalFocusTime,
    int? currentLevel,
  }) async {
    final unlockedAchievements = <String>[];
    
    // Check session-based achievements
    if (totalSessions != null) {
      if (totalSessions >= 1) {
        await _tryUnlockAchievement('first_session', unlockedAchievements);
      }
      if (totalSessions >= 25) {
        await _tryUnlockAchievement('sessions_25', unlockedAchievements);
      }
      if (totalSessions >= 100) {
        await _tryUnlockAchievement('sessions_100', unlockedAchievements);
      }
    }
    
    // Check streak-based achievements
    if (currentStreak != null) {
      if (currentStreak >= 3) {
        await _tryUnlockAchievement('streak_3', unlockedAchievements);
      }
      if (currentStreak >= 7) {
        await _tryUnlockAchievement('streak_7', unlockedAchievements);
      }
      if (currentStreak >= 30) {
        await _tryUnlockAchievement('streak_30', unlockedAchievements);
      }
    }
    
    // Check focus time achievements (in seconds)
    if (totalFocusTime != null) {
      if (totalFocusTime >= 36000) { // 10 hours
        await _tryUnlockAchievement('focus_10_hours', unlockedAchievements);
      }
      if (totalFocusTime >= 360000) { // 100 hours
        await _tryUnlockAchievement('focus_100_hours', unlockedAchievements);
      }
    }
    
    // Check level achievements
    if (currentLevel != null) {
      if (currentLevel >= 10) {
        await _tryUnlockAchievement('level_10', unlockedAchievements);
      }
      if (currentLevel >= 25) {
        await _tryUnlockAchievement('level_25', unlockedAchievements);
      }
      if (currentLevel >= 50) {
        await _tryUnlockAchievement('level_50', unlockedAchievements);
      }
    }
    
    return unlockedAchievements;
  }

  // Helper to try unlocking an achievement
  Future<void> _tryUnlockAchievement(
    String achievementId,
    List<String> unlockedList,
  ) async {
    final db = await _persistence.database;
    
    // Check if already unlocked
    final existing = await db.query(
      'achievements',
      where: 'id = ? AND unlocked = 1',
      whereArgs: [achievementId],
      limit: 1,
    );
    
    if (existing.isEmpty) {
      // Not yet unlocked, unlock it now
      await unlockAchievementWithDetails(achievementId);
      unlockedList.add(achievementId);
    }
  }

  // Reset all gamification data
  Future<void> resetGamification() async {
    final db = await _persistence.database;
    
    // Reset gamification state
    await db.delete('gamification_state');
    
    // Reset achievements
    await db.update(
      'achievements',
      {
        'unlocked': 0,
        'unlocked_date': null,
        'progress': 0.0,
        'current_value': 0,
      },
    );
    
    // Insert default state
    await db.insert('gamification_state', {
      'id': 1,
      'total_rp': 0,
      'cumulative_rp': 0,
      'current_depth_zone': 0,
      'current_level': 1,
      'current_streak': 0,
      'longest_streak': 0,
      'total_sessions': 0,
      'total_focus_time': 0,
      'unlocked_themes': '["default"]',
      'unlocked_achievements': '[]',
      'last_updated': DateTime.now().millisecondsSinceEpoch,
    });
  }
}