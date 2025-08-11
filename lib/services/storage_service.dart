import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/session.dart';
import '../models/task.dart';

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

  // Task storage methods
  static Future<void> saveTask(Task task) async {
    final prefs = await _preferences;
    final tasks = await getAllTasks();
    
    // Remove existing task with same ID if it exists
    tasks.removeWhere((t) => t.id == task.id);
    tasks.add(task);
    
    final tasksJson = tasks.map((t) => t.toMap()).toList();
    await prefs.setString('tasks', jsonEncode(tasksJson));
  }

  static Future<List<Task>> getAllTasks() async {
    final prefs = await _preferences;
    final tasksString = prefs.getString('tasks');
    if (tasksString == null) return [];
    
    try {
      final List<dynamic> tasksJson = jsonDecode(tasksString);
      return tasksJson.map((json) => Task.fromMap(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading tasks: $e');
      }
      return [];
    }
  }

  static Future<void> deleteTask(String taskId) async {
    final prefs = await _preferences;
    final tasks = await getAllTasks();
    tasks.removeWhere((t) => t.id == taskId);
    
    final tasksJson = tasks.map((t) => t.toMap()).toList();
    await prefs.setString('tasks', jsonEncode(tasksJson));
  }

  static Future<List<Task>> getTasksForProject(String projectId) async {
    final tasks = await getAllTasks();
    return tasks.where((task) => task.projectId == projectId).toList();
  }

  static Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    final tasks = await getAllTasks();
    return tasks.where((task) => task.status == status).toList();
  }

  // Project storage methods
  static Future<void> saveProject(Project project) async {
    final prefs = await _preferences;
    final projects = await getAllProjects();
    
    // Remove existing project with same ID if it exists
    projects.removeWhere((p) => p.id == project.id);
    projects.add(project);
    
    final projectsJson = projects.map((p) => p.toMap()).toList();
    await prefs.setString('projects', jsonEncode(projectsJson));
  }

  static Future<List<Project>> getAllProjects() async {
    final prefs = await _preferences;
    final projectsString = prefs.getString('projects');
    if (projectsString == null) return [];
    
    try {
      final List<dynamic> projectsJson = jsonDecode(projectsString);
      return projectsJson.map((json) => Project.fromMap(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading projects: $e');
      }
      return [];
    }
  }

  static Future<void> deleteProject(String projectId) async {
    final prefs = await _preferences;
    final projects = await getAllProjects();
    projects.removeWhere((p) => p.id == projectId);
    
    final projectsJson = projects.map((p) => p.toMap()).toList();
    await prefs.setString('projects', jsonEncode(projectsJson));
  }

  static Future<Project?> getProjectById(String projectId) async {
    final projects = await getAllProjects();
    try {
      return projects.firstWhere((p) => p.id == projectId);
    } catch (e) {
      return null;
    }
  }

  // Analytics data
  static Future<Map<String, dynamic>> getAnalyticsData() async {
    final sessions = await getAllSessions();
    final tasks = await getAllTasks();
    
    // Calculate various analytics
    final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).length;
    final totalTasks = tasks.length;
    final completedSessions = sessions.where((s) => s.completed).length;
    final totalSessions = sessions.length;
    
    // Daily data for the last 30 days
    final List<Map<String, dynamic>> dailyData = [];
    for (int i = 29; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final daySessions = await getSessionsForDate(date);
      final focusTime = daySessions
          .where((s) => s.type == SessionType.focus && s.completed)
          .fold<int>(0, (sum, session) => sum + session.duration);
      
      dailyData.add({
        'date': date.toIso8601String(),
        'focusTime': focusTime,
        'sessions': daySessions.where((s) => s.completed).length,
      });
    }
    
    return {
      'completedTasks': completedTasks,
      'totalTasks': totalTasks,
      'completedSessions': completedSessions,
      'totalSessions': totalSessions,
      'taskCompletionRate': totalTasks > 0 ? completedTasks / totalTasks : 0.0,
      'sessionCompletionRate': totalSessions > 0 ? completedSessions / totalSessions : 0.0,
      'dailyData': dailyData,
    };
  }

  // Clear all data
  static Future<void> clearAllData() async {
    final prefs = await _preferences;
    await prefs.remove('sessions');
    await prefs.remove('tasks');
    await prefs.remove('projects');
  }

  // Export data
  static Future<Map<String, dynamic>> exportAllData() async {
    final sessions = await getAllSessions();
    final tasks = await getAllTasks();
    final projects = await getAllProjects();
    
    return {
      'sessions': sessions.map((s) => s.toMap()).toList(),
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'projects': projects.map((p) => p.toMap()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  // Import data
  static Future<void> importAllData(Map<String, dynamic> data) async {
    try {
      // Clear existing data
      await clearAllData();
      
      // Import sessions
      if (data['sessions'] != null) {
        final List<dynamic> sessionsJson = data['sessions'];
        final sessions = sessionsJson.map((json) => Session.fromMap(json)).toList();
        for (final session in sessions) {
          await saveSession(session);
        }
      }
      
      // Import projects first (tasks depend on projects)
      if (data['projects'] != null) {
        final List<dynamic> projectsJson = data['projects'];
        final projects = projectsJson.map((json) => Project.fromMap(json)).toList();
        for (final project in projects) {
          await saveProject(project);
        }
      }
      
      // Import tasks
      if (data['tasks'] != null) {
        final List<dynamic> tasksJson = data['tasks'];
        final tasks = tasksJson.map((json) => Task.fromMap(json)).toList();
        for (final task in tasks) {
          await saveTask(task);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error importing data: $e');
      }
      throw Exception('Failed to import data: $e');
    }
  }
}