import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'persistence/persistence_service.dart';
import 'marine_biology_career_service.dart';
import '../models/research_points.dart';
import '../models/session_quality.dart';
import '../constants/research_points_constants.dart';

class GamificationService {
  static GamificationService? _instance;
  static GamificationService get instance {
    _instance ??= GamificationService._();
    return _instance!;
  }
  
  GamificationService._();
  
  SharedPreferences? _prefs;
  
  // Keys for SharedPreferences
  static const String _rpKey = 'total_rp';
  static const String _cumulativeRPKey = 'cumulative_rp';
  static const String _depthZoneKey = 'current_depth_zone';
  static const String _streakKey = 'current_streak';
  static const String _lastSessionDateKey = 'last_session_date';
  static const String _unlockedThemesKey = 'unlocked_themes';
  static const String _unlockedAchievementsKey = 'unlocked_achievements';
  static const String _totalSessionsKey = 'total_sessions';
  static const String _totalFocusTimeKey = 'total_focus_time';
  static const String _todayRPKey = 'today_rp';
  static const String _todayDateKey = 'today_date';
  static const String _hasStreakBonusTodayKey = 'has_streak_bonus_today';
  
  // RP and Progression System
  int _totalRP = 0;
  int _cumulativeRP = 0;
  int _currentDepthZone = 0; // 0=Shallow, 1=Coral, 2=Deep, 3=Abyssal
  int _currentStreak = 0;
  DateTime? _lastSessionDate;
  Set<String> _unlockedThemes = {'default'};
  Set<String> _unlockedAchievements = {};
  int _totalSessions = 0;
  int _totalFocusTime = 0; // in seconds
  int _todayRP = 0;
  DateTime? _todayDate;
  bool _hasStreakBonusToday = false;
  
  // Getters
  int get totalRP => _totalRP;
  int get cumulativeRP => _cumulativeRP;
  int get currentLevel => _calculateLevel(_cumulativeRP);
  int get currentDepthZone => _currentDepthZone;
  int get currentStreak => _currentStreak;
  Set<String> get unlockedThemes => _unlockedThemes;
  Set<String> get unlockedAchievements => _unlockedAchievements;
  int get totalSessions => _totalSessions;
  int get totalFocusTime => _totalFocusTime;
  int get todayRP => _todayRP;
  bool get hasStreakBonusToday => _hasStreakBonusToday;
  
  // RP and Depth Zone calculations
  int getRPForNextLevel() {
    final currentLvl = currentLevel;
    final nextLevel = currentLvl + 1;
    return getRPRequiredForLevel(nextLevel) - getRPRequiredForLevel(currentLvl);
  }
  
  int getCurrentLevelRP() => _cumulativeRP - getRPRequiredForLevel(currentLevel);
  
  int getRPRequiredForLevel(int level) {
    // Each level requires 50 RP (vs 100 XP in old system)
    return (level - 1) * 50;
  }
  
  double getLevelProgress() {
    final currentLevelRP = getCurrentLevelRP();
    final rpForNextLevel = getRPForNextLevel();
    return rpForNextLevel > 0 ? (currentLevelRP / rpForNextLevel).clamp(0.0, 1.0) : 0.0;
  }
  
  int _calculateDepthZone(int cumulativeRP) {
    if (cumulativeRP >= 501) return 3; // Abyssal
    if (cumulativeRP >= 201) return 2; // Deep
    if (cumulativeRP >= 51) return 1;  // Coral
    return 0; // Shallow
  }
  
  String getDepthZoneName() {
    switch (_currentDepthZone) {
      case 0: return 'Shallow Waters';
      case 1: return 'Coral Garden';
      case 2: return 'Deep Ocean';
      case 3: return 'Abyssal Zone';
      default: return 'Shallow Waters';
    }
  }
  
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await loadProgress();
  }
  
  Future<void> loadProgress() async {
    _totalRP = _prefs?.getInt(_rpKey) ?? 0;
    _cumulativeRP = _prefs?.getInt(_cumulativeRPKey) ?? 0;
    _currentDepthZone = _prefs?.getInt(_depthZoneKey) ?? 0;
    _currentStreak = _prefs?.getInt(_streakKey) ?? 0;
    _totalSessions = _prefs?.getInt(_totalSessionsKey) ?? 0;
    _totalFocusTime = _prefs?.getInt(_totalFocusTimeKey) ?? 0;
    _todayRP = _prefs?.getInt(_todayRPKey) ?? 0;
    _hasStreakBonusToday = _prefs?.getBool(_hasStreakBonusTodayKey) ?? false;
    
    final lastSessionMillis = _prefs?.getInt(_lastSessionDateKey);
    _lastSessionDate = lastSessionMillis != null 
        ? DateTime.fromMillisecondsSinceEpoch(lastSessionMillis)
        : null;
    
    final todayMillis = _prefs?.getInt(_todayDateKey);
    _todayDate = todayMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(todayMillis)
        : null;
    
    // Reset daily tracking if it's a new day
    final now = DateTime.now();
    if (_todayDate == null || !_isSameDay(_todayDate!, now)) {
      _todayRP = 0;
      _hasStreakBonusToday = false;
      _todayDate = now;
    }
    
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
    
    // Check if it's a new day and reset daily tracking
    if (_todayDate == null || !_isSameDay(_todayDate!, now)) {
      _todayRP = 0;
      _hasStreakBonusToday = false;
      _todayDate = now;
    }
    
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
    
    // Only calculate RP for study sessions
    int totalRPGained = 0;
    int baseRP = 0;
    int breakBonus = 0;
    int streakBonusRP = 0;
    int qualityBonus = 0;
    
    if (isStudySession && sessionCompleted) {
      // For proper RP calculation, don't pass fake break duration
      // Break adherence bonus should only be awarded for actual breaks taken
      // TODO: Implement actual break tracking during sessions

      // Create session quality model with correct break data
      final sessionQuality = SessionQualityModel.fromSessionData(
        sessionDuration: Duration(minutes: durationMinutes),
        isCompleted: sessionCompleted,
        wasInterrupted: !sessionCompleted,
        breakDuration: null, // No break duration unless actually tracked
        notes: 'Focus session',
        timestamp: now,
      );
      
      // Calculate RP using the ResearchPoints model
      final rpCalculation = ResearchPoints.calculate(
        sessionDuration: Duration(minutes: durationMinutes),
        qualityModel: sessionQuality,
        currentStreak: _currentStreak,
        hasStreakBonusToday: _hasStreakBonusToday,
      );
      
      baseRP = rpCalculation.baseRP;
      breakBonus = rpCalculation.breakAdherenceBonus;
      streakBonusRP = rpCalculation.streakBonus;
      qualityBonus = rpCalculation.qualityBonus;
      totalRPGained = rpCalculation.totalRP;
      
      // Update streak bonus flag
      if (streakBonusRP > 0) {
        _hasStreakBonusToday = true;
      }
    }
    
    // Streak calculation
    if (_isConsecutiveDay(now)) {
      _currentStreak++;
    } else if (_lastSessionDate == null || !_isSameDay(now, _lastSessionDate!)) {
      if (_lastSessionDate != null && !_isYesterday(now, _lastSessionDate!)) {
        _currentStreak = 1; // Reset streak if more than a day gap
      } else {
        _currentStreak = 1; // Start new streak
      }
    }
    
    // Update RP and stats
    if (totalRPGained > 0) {
      _totalRP += totalRPGained;
      _cumulativeRP += totalRPGained;
      _todayRP += totalRPGained;
      
      // Update depth zone based on cumulative RP
      final oldDepthZone = _currentDepthZone;
      _currentDepthZone = _calculateDepthZone(_cumulativeRP);
      
      if (_currentDepthZone > oldDepthZone) {
        reward.depthZoneUnlocked = true;
        reward.newDepthZone = getDepthZoneName();
      }
    }
    
    _totalSessions++;
    if (isStudySession) {
      _totalFocusTime += durationMinutes * 60;
    }
    
    // Populate reward RP breakdown
    reward.rpGained = totalRPGained;
    reward.baseRP = baseRP;
    reward.streakBonusRP = streakBonusRP;
    reward.breakAdherenceBonus = breakBonus;
    reward.qualityBonus = qualityBonus;
    reward.currentStreak = _currentStreak;
    reward.cumulativeRP = _cumulativeRP;
    reward.currentDepthZone = getDepthZoneName();
    
    // Career progression tracking
    final oldLevel = currentLevel;
    final oldCareerTitle = MarineBiologyCareerService.getCareerTitleFromRP(_cumulativeRP);
    
    final newLevel = _calculateLevel(_cumulativeRP);
    final newCareerTitle = MarineBiologyCareerService.getCareerTitleFromRP(_cumulativeRP);
    
    reward.oldLevel = oldLevel;
    reward.newLevel = newLevel;
    reward.oldCareerTitle = oldCareerTitle;
    reward.newCareerTitle = newCareerTitle;
    reward.careerTitleChanged = oldCareerTitle != newCareerTitle;
    
    if (newLevel > oldLevel) {
      reward.leveledUp = true;
      
      // Unlock equipment based on cumulative RP
      try {
        final equipmentRepository = PersistenceService.instance.equipment;
        final unlockedEquipment = await equipmentRepository.checkAndUnlockEquipmentByRP(_cumulativeRP);
        reward.unlockedEquipment = unlockedEquipment;
        if (unlockedEquipment.isNotEmpty) {
          debugPrint('🎒 Unlocked ${unlockedEquipment.length} new equipment items at $_cumulativeRP RP');
          for (final equipmentId in unlockedEquipment) {
            debugPrint('🎒 Unlocked equipment: $equipmentId');
          }
        }
        
        // Generate next equipment hint
        final nextEquipmentRP = _getNextEquipmentUnlockRP(_cumulativeRP);
        if (nextEquipmentRP > 0) {
          final rpNeeded = nextEquipmentRP - _cumulativeRP;
          reward.nextEquipmentHint = "Next research equipment unlocks at $nextEquipmentRP RP ($rpNeeded RP needed)";
        }
      } catch (e) {
        debugPrint('❌ Error unlocking equipment: $e');
      }
      
      // Unlock theme for level milestone
      if (newLevel % 5 == 0) {
        final newTheme = _getThemeForLevel(newLevel);
        if (!_unlockedThemes.contains(newTheme)) {
          _unlockedThemes.add(newTheme);
          reward.unlockedThemes.add(newTheme);
        }
      }
    } else {
      // Still provide next unlock hints even without leveling up
      final nextEquipmentRP = _getNextEquipmentUnlockRP(_cumulativeRP);
      if (nextEquipmentRP > 0) {
        final rpNeeded = nextEquipmentRP - _cumulativeRP;
        reward.nextEquipmentHint = "Advanced research equipment unlocks at $nextEquipmentRP RP ($rpNeeded RP needed)";
      }
    }
    
    // Generate next career milestone hint
    final nextCareerMilestone = _getNextCareerMilestone(_cumulativeRP);
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
  
  int _calculateLevel(int cumulativeRP) {
    // Each level requires 50 RP
    return (cumulativeRP / 50).floor() + 1;
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
        condition: () => currentLevel >= 10,
      ),
      Achievement(
        id: 'level_25',
        title: 'Master',
        description: 'Reach level 25',
        icon: Icons.workspace_premium,
        color: Colors.deepPurple,
        condition: () => currentLevel >= 25,
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
    await _prefs?.setInt(_rpKey, _totalRP);
    await _prefs?.setInt(_cumulativeRPKey, _cumulativeRP);
    await _prefs?.setInt(_depthZoneKey, _currentDepthZone);
    await _prefs?.setInt(_streakKey, _currentStreak);
    await _prefs?.setInt(_totalSessionsKey, _totalSessions);
    await _prefs?.setInt(_totalFocusTimeKey, _totalFocusTime);
    await _prefs?.setInt(_todayRPKey, _todayRP);
    await _prefs?.setBool(_hasStreakBonusTodayKey, _hasStreakBonusToday);
    
    if (_lastSessionDate != null) {
      await _prefs?.setInt(_lastSessionDateKey, _lastSessionDate!.millisecondsSinceEpoch);
    }
    
    if (_todayDate != null) {
      await _prefs?.setInt(_todayDateKey, _todayDate!.millisecondsSinceEpoch);
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
  
  // Helper method to find next equipment unlock RP threshold
  int _getNextEquipmentUnlockRP(int currentRP) {
    // Equipment unlock RP thresholds based on career progression
    final equipmentRPLevels = [50, 150, 300, 500, 750, 1050, 1400, 1800, 2250, 2750];
    for (final rpThreshold in equipmentRPLevels) {
      if (rpThreshold > currentRP) {
        return rpThreshold;
      }
    }
    return 0; // No more unlocks
  }
  
  // Helper method to generate next career milestone hint
  String? _getNextCareerMilestone(int currentRP) {
    final nextMilestone = ResearchPointsConstants.careerMilestones
        .where((milestone) => milestone > currentRP)
        .firstOrNull;
    
    if (nextMilestone != null) {
      final rpNeeded = nextMilestone - currentRP;
      final nextTitle = MarineBiologyCareerService.getCareerTitleFromRP(nextMilestone);
      return "Next promotion: $nextTitle at $nextMilestone RP ($rpNeeded RP needed)";
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
  // Basic RP and Level Progression
  int rpGained = 0;  // Total RP gained this session
  int baseRP = 0;    // Base RP from session duration
  int streakBonusRP = 0;  // Bonus RP from streak
  int breakAdherenceBonus = 0;  // Bonus RP from break adherence
  int qualityBonus = 0;  // Bonus RP from session quality

  bool leveledUp = false;
  int oldLevel = 1;
  int newLevel = 1;
  int currentStreak = 0;

  // Depth Zone Progression
  int cumulativeRP = 0;  // Total RP accumulated all-time
  String currentDepthZone = 'Shallow Waters';
  bool depthZoneUnlocked = false;
  String? newDepthZone;

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

  // Progress Hints (for next unlocks without spoiling)
  String? nextEquipmentHint;
  String? nextAchievementHint;
  String? nextCareerMilestone;

  // Calculate total research value (RP-based)
  int get totalResearchValue {
    int total = rpGained;  // Changed from xpGained to rpGained
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
           depthZoneUnlocked ||
           unlockedEquipment.isNotEmpty ||
           unlockedAchievements.isNotEmpty ||
           discoveredCreature != null ||
           allDiscoveredCreatures.isNotEmpty ||
           researchPapersUnlocked > 0 ||
           currentStreak >= 7;
  }

  // Get RP breakdown as readable string
  String get rpBreakdown {
    final parts = <String>[];
    if (baseRP > 0) parts.add('Base: $baseRP');
    if (streakBonusRP > 0) parts.add('Streak: +$streakBonusRP');
    if (breakAdherenceBonus > 0) parts.add('Break: +$breakAdherenceBonus');
    if (qualityBonus > 0) parts.add('Quality: +$qualityBonus');
    return parts.isEmpty ? 'No RP earned' : parts.join(', ');
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