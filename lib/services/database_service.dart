import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/session.dart';

class DatabaseService {
  static Database? _database;
  static const String _tableName = 'sessions';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'flowpulse.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        type INTEGER NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // Insert a new session
  static Future<int> insertSession(Session session) async {
    final db = await database;
    return await db.insert(_tableName, session.toMap());
  }

  // Get all sessions
  static Future<List<Session>> getAllSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'start_time DESC',
    );
    return List.generate(maps.length, (i) => Session.fromMap(maps[i]));
  }

  // Get sessions for a specific date
  static Future<List<Session>> getSessionsForDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
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
  static Future<List<Session>> getRecentSessions(int days) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'start_time >= ?',
      whereArgs: [cutoffDate.millisecondsSinceEpoch],
      orderBy: 'start_time DESC',
    );
    return List.generate(maps.length, (i) => Session.fromMap(maps[i]));
  }

  // Get sessions within a date range
  static Future<List<Session>> getSessionsByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
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
  static Future<int> getTodayFocusTime() async {
    final today = DateTime.now();
    final sessions = await getSessionsForDate(today);
    return sessions
        .where((session) => session.type == SessionType.focus && session.completed)
        .fold<int>(0, (sum, session) => sum + session.duration);
  }

  // Get current streak (consecutive days with at least one completed focus session)
  static Future<int> getCurrentStreak() async {
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
  static Future<Map<String, dynamic>> getStatistics() async {
    final sessions = await getRecentSessions(30); // Last 30 days
    
    final totalSessions = sessions.length;
    final completedSessions = sessions.where((s) => s.completed).length;
    final totalFocusTime = sessions
        .where((s) => s.type == SessionType.focus && s.completed)
        .fold<int>(0, (sum, session) => sum + session.duration);
    
    final todayFocusTime = await getTodayFocusTime();
    final currentStreak = await getCurrentStreak();
    
    return {
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'totalFocusTime': totalFocusTime,
      'todayFocusTime': todayFocusTime,
      'currentStreak': currentStreak,
      'completionRate': totalSessions > 0 ? (completedSessions / totalSessions) : 0.0,
    };
  }

  // Delete old sessions (keep only last 90 days)
  static Future<void> cleanupOldSessions() async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
    
    await db.delete(
      _tableName,
      where: 'start_time < ?',
      whereArgs: [cutoffDate.millisecondsSinceEpoch],
    );
  }

  // Update a session
  static Future<void> updateSession(Session session) async {
    final db = await database;
    await db.update(
      _tableName,
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  // Delete a session
  static Future<void> deleteSession(int id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}