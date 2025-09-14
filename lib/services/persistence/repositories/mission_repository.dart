import 'package:sqflite/sqflite.dart';
import '../persistence_service.dart';

/// Repository for managing mission data
class MissionRepository {
  final PersistenceService _persistence;
  
  MissionRepository(this._persistence);

  // Save mission
  Future<void> saveMission(Map<String, dynamic> mission) async {
    final db = await _persistence.database;
    
    await db.insert(
      'missions',
      mission,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Save multiple missions (batch)
  Future<void> saveMissionsBatch(List<Map<String, dynamic>> missions) async {
    final db = await _persistence.database;
    final batch = db.batch();
    
    for (final mission in missions) {
      batch.insert(
        'missions',
        mission,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  // Get all missions
  Future<List<Map<String, dynamic>>> getAllMissions() async {
    final db = await _persistence.database;
    
    return await db.query(
      'missions',
      orderBy: 'created_at DESC',
    );
  }

  // Get active missions (not completed and not expired)
  Future<List<Map<String, dynamic>>> getActiveMissions() async {
    final db = await _persistence.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    return await db.query(
      'missions',
      where: 'is_completed = 0 AND (expires_at IS NULL OR expires_at > ?)',
      whereArgs: [now],
      orderBy: 'created_at DESC',
    );
  }

  // Get completed missions
  Future<List<Map<String, dynamic>>> getCompletedMissions() async {
    final db = await _persistence.database;
    
    return await db.query(
      'missions',
      where: 'is_completed = 1',
      orderBy: 'completed_date DESC',
    );
  }

  // Get missions by category
  Future<List<Map<String, dynamic>>> getMissionsByCategory(String category) async {
    final db = await _persistence.database;
    
    return await db.query(
      'missions',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
  }

  // Get missions by type
  Future<List<Map<String, dynamic>>> getMissionsByType(String type) async {
    final db = await _persistence.database;
    
    return await db.query(
      'missions',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'created_at DESC',
    );
  }

  // Get mission by ID
  Future<Map<String, dynamic>?> getMissionById(String id) async {
    final db = await _persistence.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'missions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Update mission progress
  Future<void> updateMissionProgress(String missionId, int progress) async {
    final db = await _persistence.database;
    
    await db.update(
      'missions',
      {'current_progress': progress},
      where: 'id = ?',
      whereArgs: [missionId],
    );
  }

  // Complete mission
  Future<void> completeMission(String missionId) async {
    final db = await _persistence.database;
    
    await db.update(
      'missions',
      {
        'is_completed': 1,
        'completed_date': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [missionId],
    );
  }

  // Save mission progress
  Future<void> saveMissionProgress(Map<String, dynamic> progress) async {
    final db = await _persistence.database;
    
    await db.insert(
      'mission_progress',
      progress,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get mission progress for user
  Future<Map<String, dynamic>?> getMissionProgress(String missionId, {String userId = 'default'}) async {
    final db = await _persistence.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'mission_progress',
      where: 'mission_id = ? AND user_id = ?',
      whereArgs: [missionId, userId],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Update mission progress for user
  Future<void> updateUserMissionProgress(
    String missionId,
    int progressValue, {
    String userId = 'default',
    bool isCompleted = false,
  }) async {
    final db = await _persistence.database;
    
    final progressData = {
      'id': '${missionId}_$userId',
      'mission_id': missionId,
      'user_id': userId,
      'progress_value': progressValue,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': isCompleted ? DateTime.now().millisecondsSinceEpoch : null,
      'last_updated': DateTime.now().millisecondsSinceEpoch,
    };
    
    await db.insert(
      'mission_progress',
      progressData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Check and complete missions based on progress
  Future<List<String>> checkAndCompleteMissions({
    int? totalSessions,
    int? currentStreak,
    int? totalFocusTime,
    int? totalRP,
  }) async {
    final completedMissions = <String>[];
    final activeMissions = await getActiveMissions();
    
    for (final mission in activeMissions) {
      final missionId = mission['id'] as String;
      final missionType = mission['type'] as String;
      final targetValue = mission['target_value'] as int;
      final currentProgress = mission['current_progress'] as int;
      
      int newProgress = currentProgress;
      bool shouldComplete = false;
      
      switch (missionType) {
        case 'sessions':
          if (totalSessions != null) {
            newProgress = totalSessions;
            shouldComplete = totalSessions >= targetValue;
          }
          break;
        case 'streak':
          if (currentStreak != null) {
            newProgress = currentStreak;
            shouldComplete = currentStreak >= targetValue;
          }
          break;
        case 'focus_time':
          if (totalFocusTime != null) {
            newProgress = totalFocusTime;
            shouldComplete = totalFocusTime >= targetValue;
          }
          break;
        case 'research_points':
          if (totalRP != null) {
            newProgress = totalRP;
            shouldComplete = totalRP >= targetValue;
          }
          break;
      }
      
      if (newProgress != currentProgress) {
        await updateMissionProgress(missionId, newProgress);
      }
      
      if (shouldComplete && !completedMissions.contains(missionId)) {
        await completeMission(missionId);
        completedMissions.add(missionId);
      }
    }
    
    return completedMissions;
  }

  // Get mission statistics
  Future<Map<String, dynamic>> getMissionStatistics() async {
    final db = await _persistence.database;
    
    // Total missions
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM missions'
    );
    final totalMissions = totalResult.first['total'] as int;
    
    // Completed missions
    final completedResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM missions WHERE is_completed = 1'
    );
    final completedMissions = completedResult.first['total'] as int;
    
    // Active missions
    final now = DateTime.now().millisecondsSinceEpoch;
    final activeResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM missions WHERE is_completed = 0 AND (expires_at IS NULL OR expires_at > ?)',
      [now]
    );
    final activeMissions = activeResult.first['total'] as int;
    
    // Missions by category
    final categoryResult = await db.rawQuery('''
      SELECT category, COUNT(*) as count 
      FROM missions 
      WHERE is_completed = 1 
      GROUP BY category
    ''');
    
    final categoryDistribution = <String, int>{};
    for (final row in categoryResult) {
      categoryDistribution[row['category'] as String] = row['count'] as int;
    }
    
    // Total RP earned from missions
    final rpResult = await db.rawQuery(
      'SELECT SUM(reward_rp) as total FROM missions WHERE is_completed = 1'
    );
    final totalRPFromMissions = rpResult.first['total'] as int? ?? 0;
    
    return {
      'totalMissions': totalMissions,
      'completedMissions': completedMissions,
      'activeMissions': activeMissions,
      'completionRate': totalMissions > 0 
          ? (completedMissions / totalMissions * 100).toStringAsFixed(1)
          : '0.0',
      'categoryDistribution': categoryDistribution,
      'totalRPFromMissions': totalRPFromMissions,
    };
  }

  // Initialize default missions
  Future<void> initializeDefaultMissions() async {
    final existingMissions = await getAllMissions();
    if (existingMissions.isNotEmpty) return; // Already initialized
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final tomorrow = DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch;
    final nextWeek = DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch;
    
    // Define default missions
    final defaultMissions = [
      // Daily missions
      {
        'id': 'daily_first_dive',
        'title': 'First Dive of the Day',
        'description': 'Complete your first research session today',
        'category': 'daily',
        'type': 'sessions',
        'target_value': 1,
        'current_progress': 0,
        'is_completed': 0,
        'reward_rp': 5,
        'reward_bonus': '{"message": "Great start to the day!"}',
        'expires_at': tomorrow,
        'created_at': now,
        'metadata': '{"difficulty": "easy"}',
      },
      {
        'id': 'daily_three_sessions',
        'title': 'Triple Dive',
        'description': 'Complete 3 research sessions today',
        'category': 'daily',
        'type': 'sessions',
        'target_value': 3,
        'current_progress': 0,
        'is_completed': 0,
        'reward_rp': 15,
        'reward_bonus': '{"message": "Excellent productivity!"}',
        'expires_at': tomorrow,
        'created_at': now,
        'metadata': '{"difficulty": "medium"}',
      },
      
      // Weekly missions
      {
        'id': 'weekly_consistency',
        'title': 'Consistency Champion',
        'description': 'Maintain a 5-day research streak',
        'category': 'weekly',
        'type': 'streak',
        'target_value': 5,
        'current_progress': 0,
        'is_completed': 0,
        'reward_rp': 50,
        'reward_bonus': '{"message": "Your dedication is inspiring!"}',
        'expires_at': nextWeek,
        'created_at': now,
        'metadata': '{"difficulty": "hard"}',
      },
      {
        'id': 'weekly_research_points',
        'title': 'Research Milestone',
        'description': 'Earn 100 research points this week',
        'category': 'weekly',
        'type': 'research_points',
        'target_value': 100,
        'current_progress': 0,
        'is_completed': 0,
        'reward_rp': 25,
        'reward_bonus': '{"message": "Outstanding research contribution!"}',
        'expires_at': nextWeek,
        'created_at': now,
        'metadata': '{"difficulty": "medium"}',
      },
      
      // Achievement-based missions (no expiration)
      {
        'id': 'achievement_first_streak',
        'title': 'Breaking the Surface',
        'description': 'Achieve your first 3-day streak',
        'category': 'achievement',
        'type': 'streak',
        'target_value': 3,
        'current_progress': 0,
        'is_completed': 0,
        'reward_rp': 30,
        'reward_bonus': '{"message": "You\'re building great habits!", "unlock": "streak_badge"}',
        'expires_at': null,
        'created_at': now,
        'metadata': '{"difficulty": "easy", "permanent": true}',
      },
    ];
    
    await saveMissionsBatch(defaultMissions);
  }

  // Reset all mission progress
  Future<void> resetMissions() async {
    final db = await _persistence.database;
    
    // Reset all missions to incomplete
    await db.update(
      'missions',
      {
        'is_completed': 0,
        'completed_date': null,
        'current_progress': 0,
      },
    );
    
    // Clear mission progress
    await db.delete('mission_progress');
  }
}