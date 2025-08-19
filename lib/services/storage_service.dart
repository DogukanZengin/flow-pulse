import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/session.dart';

/// Storage service that provides a unified interface for data persistence
/// Uses SharedPreferences for web and simple data, SQLite for complex data on mobile
class StorageService {
  static SharedPreferences? _prefs;
  
  static Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Session storage methods
  static Future<void> saveSession(Session session) async {
    final prefs = await _preferences;
    final sessions = await getAllSessions();
    sessions.add(session);
    
    // Keep only last 1000 sessions to prevent storage overflow
    if (sessions.length > 1000) {
      sessions.removeRange(0, sessions.length - 1000);
    }
    
    final sessionsJson = sessions.map((s) => s.toMap()).toList();
    await prefs.setString('sessions', jsonEncode(sessionsJson));
  }

  static Future<List<Session>> getAllSessions() async {
    final prefs = await _preferences;
    final sessionsString = prefs.getString('sessions');
    if (sessionsString == null) return [];
    
    try {
      final List<dynamic> sessionsJson = jsonDecode(sessionsString);
      return sessionsJson.map((json) => Session.fromMap(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading sessions: $e');
      }
      return [];
    }
  }

  static Future<List<Session>> getSessionsForDate(DateTime date) async {
    final sessions = await getAllSessions();
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return sessions.where((session) {
      return session.startTime.isAfter(startOfDay) && 
             session.startTime.isBefore(endOfDay);
    }).toList();
  }

  static Future<List<Session>> getRecentSessions(int days) async {
    final sessions = await getAllSessions();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    
    return sessions.where((session) {
      return session.startTime.isAfter(cutoffDate);
    }).toList();
  }

  static Future<List<Session>> getSessionsByDateRange(DateTime startDate, DateTime endDate) async {
    final sessions = await getAllSessions();
    
    return sessions.where((session) {
      return session.startTime.isAfter(startDate) && 
             session.startTime.isBefore(endDate);
    }).toList();
  }

  static Future<int> getTodayFocusTime() async {
    final today = DateTime.now();
    final sessions = await getSessionsForDate(today);
    return sessions
        .where((session) => session.type == SessionType.focus && session.completed)
        .fold<int>(0, (sum, session) => sum + session.duration);
  }

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

  // Clear all data
  static Future<void> clearAllData() async {
    final prefs = await _preferences;
    await prefs.remove('sessions');
  }
}