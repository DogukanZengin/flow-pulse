import 'package:sqflite/sqflite.dart';
import '../../../models/session.dart';
import '../persistence_service.dart';

/// Repository for managing session data
class SessionRepository {
  final PersistenceService _persistence;
  
  SessionRepository(this._persistence);

  // Save a new session
  Future<int> saveSession(Session session) async {
    final db = await _persistence.database;
    
    final id = await db.insert(
      'sessions',
      {
        ...session.toMap(),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return id;
  }

  // Get all sessions
  Future<List<Session>> getAllSessions() async {
    final db = await _persistence.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      orderBy: 'start_time DESC',
    );
    
    return List.generate(maps.length, (i) => Session.fromMap(maps[i]));
  }

  // Get sessions for a specific date
  Future<List<Session>> getSessionsForDate(DateTime date) async {
    final db = await _persistence.database;
    
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      where: 'start_time >= ? AND start_time < ?',
      whereArgs: [
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
      ],
      orderBy: 'start_time DESC',
    );
    
    return List.generate(maps.length, (i) => Session.fromMap(maps[i]));
  }

  // Get sessions for the last N days
  Future<List<Session>> getRecentSessions(int days) async {
    final db = await _persistence.database;
    
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      where: 'start_time >= ?',
      whereArgs: [cutoffDate.millisecondsSinceEpoch],
      orderBy: 'start_time DESC',
    );
    
    return List.generate(maps.length, (i) => Session.fromMap(maps[i]));
  }

  // Get sessions within a date range
  Future<List<Session>> getSessionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _persistence.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      where: 'start_time >= ? AND start_time < ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'start_time ASC',
    );
    
    return List.generate(maps.length, (i) => Session.fromMap(maps[i]));
  }

  // Get total focus time for today
  Future<int> getTodayFocusTime() async {
    final today = DateTime.now();
    final sessions = await getSessionsForDate(today);
    
    return sessions
        .where((session) => session.type == SessionType.focus && session.completed)
        .fold<int>(0, (sum, session) => sum + session.duration);
  }

  // Get current streak (consecutive days with at least one completed focus session)
  Future<int> getCurrentStreak() async {
    int streak = 0;
    DateTime checkDate = DateTime.now();
    
    while (true) {
      final sessions = await getSessionsForDate(checkDate);
      final hasCompletedFocus = sessions.any(
        (session) => session.type == SessionType.focus && session.completed,
      );
      
      if (hasCompletedFocus) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        // If today has no sessions yet, don't break the streak
        if (streak == 0 && checkDate.day == DateTime.now().day) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
      
      // Prevent infinite loop - max reasonable streak
      if (streak > 365) break;
    }
    
    return streak;
  }

  // Get session statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final sessions = await getRecentSessions(30); // Last 30 days
    
    final totalSessions = sessions.length;
    final completedSessions = sessions.where((s) => s.completed).length;
    final totalFocusTime = sessions
        .where((s) => s.type == SessionType.focus && s.completed)
        .fold<int>(0, (sum, session) => sum + session.duration);
    
    final todayFocusTime = await getTodayFocusTime();
    final currentStreak = await getCurrentStreak();
    
    // Calculate average session duration
    final avgDuration = totalSessions > 0 
        ? totalFocusTime ~/ totalSessions 
        : 0;
    
    // Calculate best streak
    final bestStreak = await getBestStreak();
    
    return {
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'totalFocusTime': totalFocusTime,
      'todayFocusTime': todayFocusTime,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'avgSessionDuration': avgDuration,
      'completionRate': totalSessions > 0 
          ? (completedSessions / totalSessions) 
          : 0.0,
    };
  }

  // Get best streak ever
  Future<int> getBestStreak() async {
    final db = await _persistence.database;
    
    // Get all sessions ordered by date
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      where: 'type = ? AND completed = 1',
      whereArgs: [SessionType.focus.index],
      orderBy: 'start_time ASC',
    );
    
    if (maps.isEmpty) return 0;
    
    int bestStreak = 0;
    int currentStreak = 1;
    DateTime? lastDate;
    
    for (final map in maps) {
      final session = Session.fromMap(map);
      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      
      if (lastDate != null) {
        final dayDiff = sessionDate.difference(lastDate).inDays;
        
        if (dayDiff == 1) {
          // Consecutive day
          currentStreak++;
        } else if (dayDiff > 1) {
          // Streak broken
          bestStreak = currentStreak > bestStreak ? currentStreak : bestStreak;
          currentStreak = 1;
        }
        // dayDiff == 0 means same day, don't change streak
      }
      
      lastDate = sessionDate;
    }
    
    // Check final streak
    bestStreak = currentStreak > bestStreak ? currentStreak : bestStreak;
    
    return bestStreak;
  }

  // Update a session
  Future<void> updateSession(Session session) async {
    final db = await _persistence.database;
    
    await db.update(
      'sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  // Delete a session
  Future<void> deleteSession(int id) async {
    final db = await _persistence.database;
    
    await db.delete(
      'sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete old sessions (keep only last 90 days)
  Future<void> cleanupOldSessions() async {
    final db = await _persistence.database;
    
    final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
    
    await db.delete(
      'sessions',
      where: 'start_time < ?',
      whereArgs: [cutoffDate.millisecondsSinceEpoch],
    );
  }

  // Get session by ID
  Future<Session?> getSessionById(int id) async {
    final db = await _persistence.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return Session.fromMap(maps.first);
    }
    return null;
  }

  // Get total number of sessions
  Future<int> getTotalSessionCount() async {
    final db = await _persistence.database;
    
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM sessions')
    );
    
    return count ?? 0;
  }

  // Get total focus time ever
  Future<int> getTotalFocusTime() async {
    final db = await _persistence.database;
    
    final result = await db.rawQuery(
      'SELECT SUM(duration) as total FROM sessions WHERE type = ? AND completed = 1',
      [SessionType.focus.index],
    );
    
    if (result.isNotEmpty && result.first['total'] != null) {
      return result.first['total'] as int;
    }
    return 0;
  }
}