import 'dart:async';
import 'dart:math';

import '../constants/mission_constants.dart';
import '../models/mission.dart';
import '../models/mission_progress.dart';
import 'persistence/persistence_service.dart';

/// Mission Service for managing mission system in FlowPulse hybrid leveling system
///
/// Handles mission generation, progress tracking, completion rewards,
/// and integration with the RP-based progression system.
class MissionService {
  static final MissionService _instance = MissionService._internal();
  static MissionService get instance => _instance;
  MissionService._internal();

  final Random _random = Random();
  final String _defaultUserId = 'default';

  // Cache for active missions
  List<Mission>? _cachedActiveMissions;
  DateTime? _cacheTimestamp;
  static const Duration _cacheValidity = Duration(minutes: 5);

  /// Initialize mission service and generate initial missions
  Future<void> initialize() async {
    await _generateInitialMissionsIfNeeded();
    await _expireOldMissions();
  }

  /// Get all active missions for the user
  Future<List<Mission>> getActiveMissions({String? userId}) async {
    userId ??= _defaultUserId;

    // Check cache validity
    if (_cachedActiveMissions != null &&
        _cacheTimestamp != null &&
        DateTime.now().difference(_cacheTimestamp!).compareTo(_cacheValidity) < 0) {
      return _cachedActiveMissions!;
    }

    final missionMaps = await PersistenceService.instance.mission.getActiveMissions();
    final missions = missionMaps
        .where((map) => (map['user_id'] as String? ?? _defaultUserId) == userId)
        .map((map) => Mission.fromJson(map))
        .toList();

    // Update cache
    _cachedActiveMissions = missions;
    _cacheTimestamp = DateTime.now();

    return missions;
  }

  /// Get completed missions for the user
  Future<List<Mission>> getCompletedMissions({String? userId}) async {
    userId ??= _defaultUserId;
    final missionMaps = await PersistenceService.instance.mission.getCompletedMissions();
    return missionMaps
        .where((map) => (map['user_id'] as String? ?? _defaultUserId) == userId)
        .map((map) => Mission.fromJson(map))
        .toList();
  }

  /// Get mission by ID
  Future<Mission?> getMissionById(String missionId) async {
    final missionMap = await PersistenceService.instance.mission.getMissionById(missionId);
    if (missionMap == null) return null;
    return Mission.fromJson(missionMap);
  }

  /// Generate new missions based on user patterns and preferences
  Future<List<Mission>> generateNewMissions({
    String? userId,
    int? dailyCount,
    int? weeklyCount,
  }) async {
    userId ??= _defaultUserId;
    dailyCount ??= 2;
    weeklyCount ??= 1;

    final generatedMissions = <Mission>[];

    // Generate daily missions
    for (int i = 0; i < dailyCount; i++) {
      final mission = await _generateMissionByType(
        MissionConstants.typeDaily,
        userId: userId,
      );
      if (mission != null) {
        generatedMissions.add(mission);
      }
    }

    // Generate weekly missions
    for (int i = 0; i < weeklyCount; i++) {
      final mission = await _generateMissionByType(
        MissionConstants.typeWeekly,
        userId: userId,
      );
      if (mission != null) {
        generatedMissions.add(mission);
      }
    }

    // Save generated missions
    for (final mission in generatedMissions) {
      await PersistenceService.instance.mission.saveMission(mission.toJson());
    }

    // Invalidate cache
    _invalidateCache();

    return generatedMissions;
  }

  /// Update mission progress
  Future<Mission?> updateMissionProgress({
    required String missionId,
    required int progressDelta,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    userId ??= _defaultUserId;

    final mission = await getMissionById(missionId);
    if (mission == null || !mission.isActive) {
      return null;
    }

    // Update mission progress
    final updatedMission = mission.updateProgress(progressDelta);

    // Save updated mission
    await PersistenceService.instance.mission.saveMission(updatedMission.toJson());

    // Record progress entry
    final progressEntry = MissionProgress.create(
      missionId: missionId,
      userId: userId,
      progressValue: updatedMission.currentProgress,
      progressType: mission.progressType,
      metadata: metadata,
    );
    await PersistenceService.instance.mission.saveMissionProgress(progressEntry.toJson());

    // Handle mission completion
    if (updatedMission.isCompleted && !mission.isCompleted) {
      await _handleMissionCompletion(updatedMission, userId);
    }

    // Invalidate cache
    _invalidateCache();

    return updatedMission;
  }

  /// Set mission progress to specific value
  Future<Mission?> setMissionProgress({
    required String missionId,
    required int progress,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    userId ??= _defaultUserId;

    final mission = await getMissionById(missionId);
    if (mission == null || !mission.isActive) {
      return null;
    }

    // Set mission progress
    final updatedMission = mission.setProgress(progress);

    // Save updated mission
    await PersistenceService.instance.mission.saveMission(updatedMission.toJson());

    // Record progress entry
    final progressEntry = MissionProgress.create(
      missionId: missionId,
      userId: userId,
      progressValue: updatedMission.currentProgress,
      progressType: mission.progressType,
      metadata: metadata,
    );
    await PersistenceService.instance.mission.saveMissionProgress(progressEntry.toJson());

    // Handle mission completion
    if (updatedMission.isCompleted && !mission.isCompleted) {
      await _handleMissionCompletion(updatedMission, userId);
    }

    // Invalidate cache
    _invalidateCache();

    return updatedMission;
  }

  /// Update multiple mission progress based on session completion
  Future<List<Mission>> updateMissionsFromSession({
    required int sessionDurationMinutes,
    required bool sessionCompleted,
    required bool hasBreakAdherence,
    required int speciesDiscovered,
    String? userId,
  }) async {
    userId ??= _defaultUserId;

    final activeMissions = await getActiveMissions(userId: userId);
    final updatedMissions = <Mission>[];

    for (final mission in activeMissions) {
      Mission? updated;

      switch (mission.category) {
        case MissionConstants.categoryConsistency:
          // Update consistency missions (session completion count)
          if (sessionCompleted) {
            updated = await updateMissionProgress(
              missionId: mission.id,
              progressDelta: 1,
              userId: userId,
              metadata: {'session_duration': sessionDurationMinutes},
            );
          }
          break;

        case MissionConstants.categoryProductivity:
          // Update productivity missions (total session time)
          if (sessionCompleted) {
            updated = await updateMissionProgress(
              missionId: mission.id,
              progressDelta: sessionDurationMinutes,
              userId: userId,
              metadata: {'break_adherence': hasBreakAdherence},
            );
          }
          break;

        case MissionConstants.categoryDiscovery:
          // Update discovery missions (species discovered)
          if (speciesDiscovered > 0) {
            updated = await updateMissionProgress(
              missionId: mission.id,
              progressDelta: speciesDiscovered,
              userId: userId,
              metadata: {'session_duration': sessionDurationMinutes},
            );
          }
          break;

        case MissionConstants.categoryQuality:
          // Update quality missions (perfect sessions with break adherence)
          if (sessionCompleted) {
            if (mission.progressType == MissionConstants.progressTypeCount) {
              // Count perfect sessions
              if (hasBreakAdherence) {
                updated = await updateMissionProgress(
                  missionId: mission.id,
                  progressDelta: 1,
                  userId: userId,
                  metadata: {'perfect_session': true},
                );
              }
            } else if (mission.progressType == MissionConstants.progressTypePercentage) {
              // Calculate quality percentage (placeholder for more complex logic)
              final qualityScore = hasBreakAdherence ? 100 : 75;
              updated = await setMissionProgress(
                missionId: mission.id,
                progress: qualityScore,
                userId: userId,
                metadata: {'quality_score': qualityScore},
              );
            }
          }
          break;
      }

      if (updated != null) {
        updatedMissions.add(updated);
      }
    }

    return updatedMissions;
  }

  /// Get mission completion statistics
  Future<MissionCompletionStats> getMissionStats({
    required String missionCategory,
    String? userId,
  }) async {
    userId ??= _defaultUserId;

    // For now, create basic stats from available data
    // This will be enhanced when repository methods are available
    final completedMissions = await getCompletedMissions(userId: userId);
    final categoryMissions = completedMissions
        .where((m) => m.category == missionCategory)
        .toList();

    if (categoryMissions.isEmpty) {
      return MissionCompletionStats(
        missionId: 'category_$missionCategory',
        category: missionCategory,
        type: 'aggregate',
        difficulty: 'mixed',
        totalAttempts: 0,
        completedAttempts: 0,
        completionRate: 0.0,
        averageCompletionTime: Duration.zero,
        totalRPEarned: 0,
        firstAttempt: DateTime.now(),
      );
    }

    final totalRP = categoryMissions.fold(0, (sum, m) => sum + m.rewardRP);
    final avgCompletionTime = Duration(
      milliseconds: categoryMissions
          .where((m) => m.completedAt != null)
          .map((m) => m.completedAt!.difference(m.createdAt).inMilliseconds)
          .fold(0, (sum, duration) => sum + duration) ~/
          categoryMissions.length,
    );

    return MissionCompletionStats(
      missionId: 'category_$missionCategory',
      category: missionCategory,
      type: 'aggregate',
      difficulty: 'mixed',
      totalAttempts: categoryMissions.length,
      completedAttempts: categoryMissions.length,
      completionRate: 1.0,
      averageCompletionTime: avgCompletionTime,
      totalRPEarned: totalRP,
      firstAttempt: categoryMissions.last.createdAt,
      lastCompleted: categoryMissions.first.completedAt,
    );
  }

  /// Get user's overall mission statistics
  Future<Map<String, dynamic>> getUserMissionSummary({String? userId}) async {
    userId ??= _defaultUserId;

    final activeMissions = await getActiveMissions(userId: userId);
    final completedMissions = await getCompletedMissions(userId: userId);

    final totalRPEarned = completedMissions
        .fold(0, (sum, mission) => sum + mission.rewardRP);

    final completionRates = <String, double>{};
    for (final category in [
      MissionConstants.categoryConsistency,
      MissionConstants.categoryProductivity,
      MissionConstants.categoryDiscovery,
      MissionConstants.categoryQuality,
    ]) {
      final categoryCompleted = completedMissions
          .where((m) => m.category == category)
          .length;
      final categoryTotal = categoryCompleted + activeMissions
          .where((m) => m.category == category)
          .length;

      completionRates[category] = categoryTotal > 0
          ? categoryCompleted / categoryTotal
          : 0.0;
    }

    return {
      'active_missions': activeMissions.length,
      'completed_missions': completedMissions.length,
      'total_rp_earned': totalRPEarned,
      'completion_rates': completionRates,
      'current_streak': await _getCurrentMissionStreak(userId),
      'favorite_category': _getFavoriteCategory(completedMissions),
    };
  }

  /// Expire old missions that have passed their expiration time
  Future<void> _expireOldMissions() async {
    // For now, we'll implement basic expiration logic
    // This will be enhanced when repository method is available
    final activeMissions = await getActiveMissions();

    for (final mission in activeMissions) {
      if (mission.isExpired) {
        final expiredMission = mission.markExpired();
        await PersistenceService.instance.mission.saveMission(expiredMission.toJson());
      }
    }

    _invalidateCache();
  }

  /// Generate initial missions if none exist
  Future<void> _generateInitialMissionsIfNeeded() async {
    final activeMissions = await getActiveMissions();

    if (activeMissions.isEmpty) {
      await generateNewMissions(dailyCount: 3, weeklyCount: 1);
    }
  }

  /// Generate a mission of specific type
  Future<Mission?> _generateMissionByType(String type, {String? userId}) async {
    // Get available templates for this type
    final availableTemplates = <Map<String, dynamic>>[];

    for (final category in MissionConstants.missionTemplates.keys) {
      final categoryTemplates = MissionConstants.getTemplatesForCategory(category);
      availableTemplates.addAll(
        categoryTemplates.where((template) => template['type'] == type),
      );
    }

    if (availableTemplates.isEmpty) return null;

    // Select random template
    final template = availableTemplates[_random.nextInt(availableTemplates.length)];
    final category = template['category'] as String;
    final difficulty = template['difficulty'] as String;

    // Generate appropriate target value
    final targetRange = MissionConstants.getTargetRange(category, difficulty);
    final targetValue = targetRange['min']! +
        _random.nextInt(targetRange['max']! - targetRange['min']! + 1);

    // Create mission from template
    return Mission.fromTemplate(
      template: template,
      targetValue: targetValue,
    );
  }

  /// Handle mission completion rewards and side effects
  Future<void> _handleMissionCompletion(Mission mission, String userId) async {
    // Award RP through gamification service (this will be integrated later)
    // For now, just track the completion
    // TODO: Integrate with GamificationService to award RP
    // mission.title completed, +${mission.rewardRP} RP

    // Check for streak bonuses
    final streak = await _getCurrentMissionStreak(userId);
    if (MissionConstants.streakBonusRP.containsKey(streak)) {
      // TODO: Award streak bonus RP for mission completion streak
      // final bonusRP = MissionConstants.streakBonusRP[streak]!;
    }

    // Generate replacement mission if needed
    if (mission.type == MissionConstants.typeDaily) {
      await _generateReplacementDailyMission();
    }
  }

  /// Get current mission completion streak
  Future<int> _getCurrentMissionStreak(String userId) async {
    final completedMissions = await getCompletedMissions(userId: userId);

    if (completedMissions.isEmpty) return 0;

    // Sort by completion date
    completedMissions.sort((a, b) =>
        (b.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(a.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0)));

    // Count consecutive days with completed missions
    int streak = 0;
    DateTime? lastDate;

    for (final mission in completedMissions) {
      if (mission.completedAt == null) continue;

      final completionDate = DateTime(
        mission.completedAt!.year,
        mission.completedAt!.month,
        mission.completedAt!.day,
      );

      if (lastDate == null) {
        lastDate = completionDate;
        streak = 1;
      } else {
        final daysDiff = lastDate.difference(completionDate).inDays;
        if (daysDiff == 1) {
          streak++;
          lastDate = completionDate;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  /// Get user's favorite mission category based on completion history
  String _getFavoriteCategory(List<Mission> completedMissions) {
    if (completedMissions.isEmpty) return MissionConstants.categoryConsistency;

    final categoryCount = <String, int>{};
    for (final mission in completedMissions) {
      categoryCount[mission.category] = (categoryCount[mission.category] ?? 0) + 1;
    }

    return categoryCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Generate replacement daily mission
  Future<void> _generateReplacementDailyMission() async {
    final activeDailies = (await getActiveMissions())
        .where((m) => m.type == MissionConstants.typeDaily)
        .length;

    if (activeDailies < MissionConstants.maxActiveMissions[MissionConstants.typeDaily]!) {
      await generateNewMissions(dailyCount: 1, weeklyCount: 0);
    }
  }

  /// Invalidate mission cache
  void _invalidateCache() {
    _cachedActiveMissions = null;
    _cacheTimestamp = null;
  }

  /// Dispose resources
  void dispose() {
    _invalidateCache();
  }
}