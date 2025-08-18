import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/gamification_service.dart';

/// Service for managing break session rewards and activities
/// Tracks break activities and provides bonuses for proper rest habits
class BreakRewardsService {
  static final BreakRewardsService _instance = BreakRewardsService._internal();
  factory BreakRewardsService() => _instance;
  BreakRewardsService._internal();

  static const String _breakStreakKey = 'break_streak';
  static const String _breakActivitiesKey = 'break_activities';
  static const String _lastBreakDateKey = 'last_break_date';
  static const String _totalBreakTimeKey = 'total_break_time';
  static const String _equipmentBoostKey = 'equipment_boost';
  
  // Current break session state
  int _currentBreakStreak = 0;
  Map<String, int> _breakActivities = {};
  DateTime? _lastBreakDate;
  int _totalBreakTimeMinutes = 0;
  bool _hasEquipmentBoost = false;
  
  // Getters
  int get currentBreakStreak => _currentBreakStreak;
  Map<String, int> get breakActivities => Map.unmodifiable(_breakActivities);
  int get totalBreakTimeMinutes => _totalBreakTimeMinutes;
  bool get hasEquipmentBoost => _hasEquipmentBoost;
  
  /// Initialize the service
  Future<void> initialize() async {
    await _loadBreakData();
  }
  
  /// Complete a break activity and earn rewards
  Future<BreakActivityReward> completeActivity(String activityType, int breakDurationMinutes) async {
    final reward = BreakActivityReward();
    
    // Track activity completion
    _breakActivities[activityType] = (_breakActivities[activityType] ?? 0) + 1;
    
    // Award XP and bonuses based on activity type
    switch (activityType) {
      case 'equipment_maintenance':
        reward.xpGained = 10;
        reward.discoveryBoostNext = 0.1; // 10% boost
        reward.message = 'Equipment maintained! Next dive +10% discovery rate';
        _hasEquipmentBoost = true;
        break;
        
      case 'wildlife_observation':
        reward.xpGained = 5;
        reward.surfaceSpeciesXP = 5;
        reward.message = 'Wildlife observed! +5 Surface Species XP earned';
        break;
        
      case 'journal_review':
        reward.xpGained = 15;
        reward.focusInsight = true;
        reward.message = 'Journal reviewed! +15 Research XP and focus insights gained';
        break;
        
      case 'weather_monitoring':
        reward.xpGained = 8;
        reward.migrationDataUnlocked = true;
        reward.message = 'Weather logged! Seasonal migration data unlocked';
        break;
        
      default:
        reward.xpGained = 5;
        reward.message = 'Activity completed! Break rewards earned';
    }
    
    // Apply break streak bonuses
    if (_shouldUpdateBreakStreak()) {
      _currentBreakStreak++;
      reward.streakBonus = _calculateStreakBonus();
      reward.xpGained += reward.streakBonus;
    }
    
    // Track total break time
    _totalBreakTimeMinutes += breakDurationMinutes;
    reward.totalBreakTime = _totalBreakTimeMinutes;
    
    // Award XP through break session completion
    await GamificationService.instance.completeSession(
      durationMinutes: breakDurationMinutes,
      isStudySession: false, // This is a break activity
    );
    
    // Save updated data
    await _saveBreakData();
    
    return reward;
  }
  
  /// Complete a full break session
  Future<BreakSessionReward> completeBreakSession(int durationMinutes, List<String> completedActivities) async {
    final reward = BreakSessionReward();
    
    // Base XP for taking the break
    reward.baseXP = durationMinutes * 2; // 2 XP per minute of proper rest
    
    // Activity completion bonuses
    reward.activityBonusXP = completedActivities.length * 5;
    
    // Break quality multiplier based on activities completed
    final qualityMultiplier = _calculateBreakQuality(completedActivities);
    reward.qualityMultiplier = qualityMultiplier;
    
    // Apply streak bonuses
    if (_shouldUpdateBreakStreak()) {
      _currentBreakStreak++;
      reward.streakBonus = _calculateStreakBonus();
    }
    
    // Calculate total XP
    final baseTotal = reward.baseXP + reward.activityBonusXP;
    reward.totalXP = (baseTotal * qualityMultiplier + reward.streakBonus).round();
    
    // Determine next session bonuses
    reward.nextSessionBonus = _calculateNextSessionBonus(completedActivities);
    
    // Update statistics
    _totalBreakTimeMinutes += durationMinutes;
    _lastBreakDate = DateTime.now();
    
    // Award total XP through session completion
    await GamificationService.instance.completeSession(
      durationMinutes: durationMinutes,
      isStudySession: false, // This is a break session
    );
    
    // Save data
    await _saveBreakData();
    
    return reward;
  }
  
  /// Check if equipment boost should be consumed and applied
  bool consumeEquipmentBoost() {
    if (_hasEquipmentBoost) {
      _hasEquipmentBoost = false;
      _saveBreakData(); // Save async but don't await to keep performance
      return true;
    }
    return false;
  }
  
  /// Get break streak bonuses description
  String getStreakBonusDescription() {
    if (_currentBreakStreak >= 30) {
      return '🔥 Master Researcher: +50% XP, legendary surface encounters';
    } else if (_currentBreakStreak >= 14) {
      return '⚡ Professional Habits: +25% XP, advanced vessel upgrades';
    } else if (_currentBreakStreak >= 7) {
      return '💜 Well-Rested Researcher: +15% XP, rare surface wildlife';
    } else if (_currentBreakStreak >= 3) {
      return '✨ Good Rest Habits: +10% XP, improved equipment efficiency';
    } else if (_currentBreakStreak >= 1) {
      return '🌟 Break Starter: +5% XP, equipment maintenance unlocked';
    } else {
      return '💤 Take breaks to unlock streak bonuses';
    }
  }
  
  /// Get surface wildlife unlock status based on break habits
  List<String> getUnlockedSurfaceWildlife() {
    final unlocked = <String>['seagull', 'pelican']; // Always available
    
    if (_currentBreakStreak >= 3) {
      unlocked.addAll(['dolphin', 'flying_fish']);
    }
    if (_currentBreakStreak >= 7) {
      unlocked.addAll(['whale_distant', 'sea_lion']);
    }
    if (_currentBreakStreak >= 14) {
      unlocked.addAll(['rainbow_formation', 'waterspout']);
    }
    if (_currentBreakStreak >= 30) {
      unlocked.addAll(['ocean_spirit', 'legendary_albatross']);
    }
    
    return unlocked;
  }
  
  bool _shouldUpdateBreakStreak() {
    final now = DateTime.now();
    if (_lastBreakDate == null) return true;
    
    final daysDifference = now.difference(_lastBreakDate!).inDays;
    
    // Reset streak if more than 2 days without a break
    if (daysDifference > 2) {
      _currentBreakStreak = 0;
      return true;
    }
    
    // Update streak if it's a new day
    return daysDifference >= 1;
  }
  
  int _calculateStreakBonus() {
    if (_currentBreakStreak >= 30) return 50;
    if (_currentBreakStreak >= 14) return 25;
    if (_currentBreakStreak >= 7) return 15;
    if (_currentBreakStreak >= 3) return 10;
    if (_currentBreakStreak >= 1) return 5;
    return 0;
  }
  
  double _calculateBreakQuality(List<String> completedActivities) {
    if (completedActivities.isEmpty) return 1.0; // Base quality
    
    // Higher quality for diverse activities
    final uniqueActivities = completedActivities.toSet();
    if (uniqueActivities.length >= 4) return 1.5; // Excellent break
    if (uniqueActivities.length >= 3) return 1.3; // Good break
    if (uniqueActivities.length >= 2) return 1.2; // Decent break
    return 1.1; // Basic break
  }
  
  Map<String, double> _calculateNextSessionBonus(List<String> completedActivities) {
    final bonuses = <String, double>{};
    
    for (final activity in completedActivities) {
      switch (activity) {
        case 'equipment_maintenance':
          bonuses['discovery_rate'] = (bonuses['discovery_rate'] ?? 0.0) + 0.1;
          break;
        case 'journal_review':
          bonuses['focus_quality'] = (bonuses['focus_quality'] ?? 0.0) + 0.05;
          break;
        case 'weather_monitoring':
          bonuses['rare_species_chance'] = (bonuses['rare_species_chance'] ?? 0.0) + 0.03;
          break;
        case 'wildlife_observation':
          bonuses['ecosystem_health'] = (bonuses['ecosystem_health'] ?? 0.0) + 0.02;
          break;
      }
    }
    
    return bonuses;
  }
  
  Future<void> _loadBreakData() async {
    final prefs = await SharedPreferences.getInstance();
    
    _currentBreakStreak = prefs.getInt(_breakStreakKey) ?? 0;
    _totalBreakTimeMinutes = prefs.getInt(_totalBreakTimeKey) ?? 0;
    _hasEquipmentBoost = prefs.getBool(_equipmentBoostKey) ?? false;
    
    final lastBreakString = prefs.getString(_lastBreakDateKey);
    if (lastBreakString != null) {
      _lastBreakDate = DateTime.parse(lastBreakString);
    }
    
    final activitiesJson = prefs.getString(_breakActivitiesKey);
    if (activitiesJson != null) {
      final Map<String, dynamic> activitiesMap = json.decode(activitiesJson);
      _breakActivities = activitiesMap.map((key, value) => MapEntry(key, value as int));
    }
  }
  
  Future<void> _saveBreakData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt(_breakStreakKey, _currentBreakStreak);
    await prefs.setInt(_totalBreakTimeKey, _totalBreakTimeMinutes);
    await prefs.setBool(_equipmentBoostKey, _hasEquipmentBoost);
    
    if (_lastBreakDate != null) {
      await prefs.setString(_lastBreakDateKey, _lastBreakDate!.toIso8601String());
    }
    
    final activitiesJson = json.encode(_breakActivities);
    await prefs.setString(_breakActivitiesKey, activitiesJson);
  }
  
  /// Debug method to reset all break data
  Future<void> resetBreakData() async {
    if (kDebugMode) {
      _currentBreakStreak = 0;
      _breakActivities.clear();
      _lastBreakDate = null;
      _totalBreakTimeMinutes = 0;
      _hasEquipmentBoost = false;
      await _saveBreakData();
    }
  }
}

/// Reward data for completing a specific break activity
class BreakActivityReward {
  int xpGained = 0;
  int surfaceSpeciesXP = 0;
  double discoveryBoostNext = 0.0;
  bool focusInsight = false;
  bool migrationDataUnlocked = false;
  int streakBonus = 0;
  int totalBreakTime = 0;
  String message = '';
}

/// Reward data for completing a full break session
class BreakSessionReward {
  int baseXP = 0;
  int activityBonusXP = 0;
  double qualityMultiplier = 1.0;
  int streakBonus = 0;
  int totalXP = 0;
  Map<String, double> nextSessionBonus = {};
  
  String get qualityDescription {
    if (qualityMultiplier >= 1.5) return 'Excellent break quality!';
    if (qualityMultiplier >= 1.3) return 'Good break quality';
    if (qualityMultiplier >= 1.2) return 'Decent break quality';
    if (qualityMultiplier >= 1.1) return 'Basic break quality';
    return 'Break completed';
  }
}