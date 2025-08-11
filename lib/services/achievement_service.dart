import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum AchievementType {
  // Basic achievements (free)
  firstSession,
  streak3,
  streak7,
  totalHours10,
  totalHours50,
  
  // Premium achievements
  streak30,
  streak100,
  totalHours100,
  totalHours500,
  breathingMaster,
  soundMixer,
  themeExplorer,
  nightOwl,
  earlyBird,
  focused,
  marathon,
  consistent,
  explorer,
  perfectWeek,
  zenMaster,
}

class Achievement {
  final AchievementType type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isPremium;
  final DateTime? unlockedAt;
  
  Achievement({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isPremium = false,
    this.unlockedAt,
  });
  
  bool get isUnlocked => unlockedAt != null;
  
  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
    };
  }
  
  static Achievement fromJson(Map<String, dynamic> json, Achievement template) {
    return Achievement(
      type: template.type,
      title: template.title,
      description: template.description,
      icon: template.icon,
      color: template.color,
      isPremium: template.isPremium,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['unlockedAt'])
          : null,
    );
  }
}

class AchievementService {
  static AchievementService? _instance;
  static AchievementService get instance => _instance ??= AchievementService._();
  
  AchievementService._();
  
  SharedPreferences? _prefs;
  final Map<AchievementType, Achievement> _achievements = {};
  final List<Function(Achievement)> _listeners = [];
  
  static const String _achievementsKey = 'achievements';
  
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _initializeAchievements();
    await _loadAchievements();
  }
  
  void _initializeAchievements() {
    final achievementTemplates = [
      // Basic achievements
      Achievement(
        type: AchievementType.firstSession,
        title: 'First Steps',
        description: 'Complete your first focus session',
        icon: Icons.play_circle_filled,
        color: Colors.green,
      ),
      Achievement(
        type: AchievementType.streak3,
        title: 'Getting Started',
        description: 'Complete 3 sessions in a row',
        icon: Icons.local_fire_department,
        color: Colors.orange,
      ),
      Achievement(
        type: AchievementType.streak7,
        title: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        icon: Icons.whatshot,
        color: Colors.red,
      ),
      Achievement(
        type: AchievementType.totalHours10,
        title: 'Time Keeper',
        description: 'Accumulate 10 hours of focus time',
        icon: Icons.schedule,
        color: Colors.blue,
      ),
      Achievement(
        type: AchievementType.totalHours50,
        title: 'Dedication',
        description: 'Accumulate 50 hours of focus time',
        icon: Icons.timer,
        color: Colors.purple,
      ),
      
      // Premium achievements
      Achievement(
        type: AchievementType.streak30,
        title: 'Monthly Master',
        description: 'Maintain a 30-day streak',
        icon: Icons.calendar_month,
        color: Colors.deepPurple,
        isPremium: true,
      ),
      Achievement(
        type: AchievementType.streak100,
        title: 'Century Club',
        description: 'Maintain a 100-day streak',
        icon: Icons.emoji_events,
        color: Colors.amber,
        isPremium: true,
      ),
      Achievement(
        type: AchievementType.totalHours100,
        title: 'Century Focus',
        description: 'Accumulate 100 hours of focus time',
        icon: Icons.access_time_filled,
        color: Colors.indigo,
        isPremium: true,
      ),
      Achievement(
        type: AchievementType.totalHours500,
        title: 'Master of Time',
        description: 'Accumulate 500 hours of focus time',
        icon: Icons.history_toggle_off,
        color: Colors.deepOrange,
        isPremium: true,
      ),
      Achievement(
        type: AchievementType.breathingMaster,
        title: 'Breath Master',
        description: 'Complete 50 breathing exercises',
        icon: Icons.air,
        color: Colors.cyan,
        isPremium: true,
      ),
      Achievement(
        type: AchievementType.soundMixer,
        title: 'Sound Alchemist',
        description: 'Mix 3 different sounds simultaneously',
        icon: Icons.equalizer,
        color: Colors.teal,
        isPremium: true,
      ),
      Achievement(
        type: AchievementType.themeExplorer,
        title: 'Theme Explorer',
        description: 'Try 10 different premium themes',
        icon: Icons.palette,
        color: Colors.pink,
        isPremium: true,
      ),
      Achievement(
        type: AchievementType.nightOwl,
        title: 'Night Owl',
        description: 'Complete 20 sessions after 10 PM',
        icon: Icons.nightlight,
        color: Colors.indigo,
        isPremium: true,
      ),
      Achievement(
        type: AchievementType.earlyBird,
        title: 'Early Bird',
        description: 'Complete 20 sessions before 7 AM',
        icon: Icons.wb_sunny,
        color: Colors.orange,
        isPremium: true,
      ),
      Achievement(
        type: AchievementType.focused,
        title: 'Laser Focus',
        description: 'Complete a 2-hour session without breaks',
        icon: Icons.center_focus_strong,
        color: Colors.red,
        isPremium: true,
      ),
      Achievement(
        type: AchievementType.marathon,
        title: 'Marathon Runner',
        description: 'Complete 10 sessions in one day',
        icon: Icons.directions_run,
        color: Colors.green,
        isPremium: true,
      ),
      Achievement(
        type: AchievementType.consistent,
        title: 'Consistency King',
        description: 'Complete at least one session every day for 30 days',
        icon: Icons.trending_up,
        color: Colors.blue,
        isPremium: true,
      ),
      Achievement(
        type: AchievementType.explorer,
        title: 'Sound Explorer',
        description: 'Use every premium sound at least once',
        icon: Icons.explore,
        color: Colors.purple,
        isPremium: true,
      ),
      Achievement(
        type: AchievementType.perfectWeek,
        title: 'Perfect Week',
        description: 'Complete your target sessions 7 days in a row',
        icon: Icons.star,
        color: Colors.amber,
        isPremium: true,
      ),
      Achievement(
        type: AchievementType.zenMaster,
        title: 'Zen Master',
        description: 'Complete 1000 total sessions',
        icon: Icons.self_improvement,
        color: Colors.deepPurple,
        isPremium: true,
      ),
    ];
    
    for (final template in achievementTemplates) {
      _achievements[template.type] = template;
    }
  }
  
  Future<void> _loadAchievements() async {
    final achievementsJson = _prefs?.getString(_achievementsKey);
    if (achievementsJson != null) {
      final Map<String, dynamic> data = json.decode(achievementsJson);
      
      for (final entry in data.entries) {
        final type = AchievementType.values[int.parse(entry.key)];
        final template = _achievements[type];
        if (template != null) {
          _achievements[type] = Achievement.fromJson(entry.value, template);
        }
      }
    }
  }
  
  Future<void> _saveAchievements() async {
    final Map<String, dynamic> data = {};
    
    for (final entry in _achievements.entries) {
      if (entry.value.isUnlocked) {
        data[entry.key.index.toString()] = entry.value.toJson();
      }
    }
    
    await _prefs?.setString(_achievementsKey, json.encode(data));
  }
  
  void addListener(Function(Achievement) listener) {
    _listeners.add(listener);
  }
  
  void removeListener(Function(Achievement) listener) {
    _listeners.remove(listener);
  }
  
  void _notifyListeners(Achievement achievement) {
    for (final listener in _listeners) {
      listener(achievement);
    }
  }
  
  Future<void> unlockAchievement(AchievementType type) async {
    final achievement = _achievements[type];
    if (achievement != null && !achievement.isUnlocked) {
      _achievements[type] = Achievement(
        type: achievement.type,
        title: achievement.title,
        description: achievement.description,
        icon: achievement.icon,
        color: achievement.color,
        isPremium: achievement.isPremium,
        unlockedAt: DateTime.now(),
      );
      
      await _saveAchievements();
      _notifyListeners(_achievements[type]!);
    }
  }
  
  // Check methods for different achievement triggers
  Future<void> checkSessionAchievements({
    required int totalSessions,
    required int currentStreak,
    required double totalHours,
    required DateTime sessionTime,
    required int dailySessions,
  }) async {
    // First session
    if (totalSessions == 1) {
      await unlockAchievement(AchievementType.firstSession);
    }
    
    // Streak achievements
    if (currentStreak >= 3) await unlockAchievement(AchievementType.streak3);
    if (currentStreak >= 7) await unlockAchievement(AchievementType.streak7);
    if (currentStreak >= 30) await unlockAchievement(AchievementType.streak30);
    if (currentStreak >= 100) await unlockAchievement(AchievementType.streak100);
    
    // Total time achievements
    if (totalHours >= 10) await unlockAchievement(AchievementType.totalHours10);
    if (totalHours >= 50) await unlockAchievement(AchievementType.totalHours50);
    if (totalHours >= 100) await unlockAchievement(AchievementType.totalHours100);
    if (totalHours >= 500) await unlockAchievement(AchievementType.totalHours500);
    
    // Time-based achievements
    final hour = sessionTime.hour;
    if (hour >= 22 || hour < 6) {
      // Night owl logic would need session counting
    }
    if (hour >= 5 && hour < 7) {
      // Early bird logic would need session counting
    }
    
    // Daily achievements
    if (dailySessions >= 10) {
      await unlockAchievement(AchievementType.marathon);
    }
    
    // Total session milestones
    if (totalSessions >= 1000) {
      await unlockAchievement(AchievementType.zenMaster);
    }
  }
  
  Future<void> checkBreathingAchievements(int totalBreathingSessions) async {
    if (totalBreathingSessions >= 50) {
      await unlockAchievement(AchievementType.breathingMaster);
    }
  }
  
  Future<void> checkSoundMixingAchievements(int activeSoundsCount) async {
    if (activeSoundsCount >= 3) {
      await unlockAchievement(AchievementType.soundMixer);
    }
  }
  
  Future<void> checkThemeAchievements(int uniqueThemesUsed) async {
    if (uniqueThemesUsed >= 10) {
      await unlockAchievement(AchievementType.themeExplorer);
    }
  }
  
  List<Achievement> get allAchievements => _achievements.values.toList();
  List<Achievement> get unlockedAchievements => 
      _achievements.values.where((a) => a.isUnlocked).toList();
  List<Achievement> get lockedAchievements => 
      _achievements.values.where((a) => !a.isUnlocked).toList();
  List<Achievement> get freeAchievements => 
      _achievements.values.where((a) => !a.isPremium).toList();
  List<Achievement> get premiumAchievements => 
      _achievements.values.where((a) => a.isPremium).toList();
  
  double get completionPercentage {
    final total = _achievements.length;
    final unlocked = unlockedAchievements.length;
    return total > 0 ? (unlocked / total) * 100 : 0;
  }
}