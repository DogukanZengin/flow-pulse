import '../constants/mission_constants.dart';

/// Mission Progress tracking model for detailed progress monitoring
///
/// Tracks individual progress updates for missions, enabling detailed
/// analytics and progress history for the hybrid leveling system.
class MissionProgress {
  final String id;
  final String missionId;
  final String userId;
  final int progressValue;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime lastUpdated;
  final String progressType;
  final Map<String, dynamic>? metadata;

  const MissionProgress({
    required this.id,
    required this.missionId,
    required this.userId,
    required this.progressValue,
    required this.isCompleted,
    this.completedAt,
    required this.lastUpdated,
    required this.progressType,
    this.metadata,
  });

  /// Create new mission progress entry
  factory MissionProgress.create({
    required String missionId,
    required String userId,
    required int progressValue,
    required String progressType,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return MissionProgress(
      id: '${missionId}_${userId}_${now.millisecondsSinceEpoch}',
      missionId: missionId,
      userId: userId,
      progressValue: progressValue,
      isCompleted: false,
      lastUpdated: now,
      progressType: progressType,
      metadata: metadata,
    );
  }

  /// Create from JSON (database persistence)
  factory MissionProgress.fromJson(Map<String, dynamic> json) {
    return MissionProgress(
      id: json['id'] as String,
      missionId: json['mission_id'] as String,
      userId: json['user_id'] as String? ?? 'default',
      progressValue: json['progress_value'] as int? ?? 0,
      isCompleted: (json['is_completed'] as int? ?? 0) == 1,
      completedAt: json['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completed_at'] as int)
          : null,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(
        json['last_updated'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      progressType: json['progress_type'] as String? ?? MissionConstants.progressTypeCount,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  /// Convert to JSON for database persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mission_id': missionId,
      'user_id': userId,
      'progress_value': progressValue,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.millisecondsSinceEpoch,
      'last_updated': lastUpdated.millisecondsSinceEpoch,
      'progress_type': progressType,
      'metadata': metadata,
    };
  }

  /// Update progress with new value
  MissionProgress updateProgress(int newProgressValue, {bool? completed}) {
    final isNowCompleted = completed ?? isCompleted;
    return copyWith(
      progressValue: newProgressValue,
      isCompleted: isNowCompleted,
      completedAt: isNowCompleted && !isCompleted ? DateTime.now() : completedAt,
      lastUpdated: DateTime.now(),
    );
  }

  /// Mark as completed
  MissionProgress markCompleted() {
    return copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
      lastUpdated: DateTime.now(),
    );
  }

  /// Get formatted progress string
  String get formattedProgress {
    switch (progressType) {
      case MissionConstants.progressTypeTime:
        final hours = progressValue ~/ 60;
        final minutes = progressValue % 60;
        if (hours > 0) {
          return '${hours}h ${minutes}m';
        }
        return '${minutes}m';

      case MissionConstants.progressTypePercentage:
        return '$progressValue%';

      case MissionConstants.progressTypeStreak:
        return '$progressValue day${progressValue == 1 ? '' : 's'}';

      case MissionConstants.progressTypeCount:
      default:
        return progressValue.toString();
    }
  }

  /// Get progress increment since creation
  int getProgressIncrement(MissionProgress? previousProgress) {
    if (previousProgress == null) return progressValue;
    return progressValue - previousProgress.progressValue;
  }

  /// Check if this is a significant progress milestone
  bool isSignificantMilestone(int targetValue) {
    final percentage = (progressValue / targetValue * 100).round();
    return percentage > 0 && percentage % 25 == 0; // Every 25% milestone
  }

  /// Get time since last update
  Duration get timeSinceUpdate {
    return DateTime.now().difference(lastUpdated);
  }

  /// Check if progress is recent (within last hour)
  bool get isRecentProgress {
    return timeSinceUpdate.inHours < 1;
  }

  /// Copy with new values
  MissionProgress copyWith({
    String? id,
    String? missionId,
    String? userId,
    int? progressValue,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? lastUpdated,
    String? progressType,
    Map<String, dynamic>? metadata,
  }) {
    return MissionProgress(
      id: id ?? this.id,
      missionId: missionId ?? this.missionId,
      userId: userId ?? this.userId,
      progressValue: progressValue ?? this.progressValue,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      progressType: progressType ?? this.progressType,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'MissionProgress(mission: $missionId, progress: $formattedProgress, completed: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MissionProgress && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Mission completion statistics for analytics
class MissionCompletionStats {
  final String missionId;
  final String category;
  final String type;
  final String difficulty;
  final int totalAttempts;
  final int completedAttempts;
  final double completionRate;
  final Duration averageCompletionTime;
  final int totalRPEarned;
  final DateTime firstAttempt;
  final DateTime? lastCompleted;

  const MissionCompletionStats({
    required this.missionId,
    required this.category,
    required this.type,
    required this.difficulty,
    required this.totalAttempts,
    required this.completedAttempts,
    required this.completionRate,
    required this.averageCompletionTime,
    required this.totalRPEarned,
    required this.firstAttempt,
    this.lastCompleted,
  });

  /// Create stats from list of mission progress entries
  factory MissionCompletionStats.fromProgressList({
    required String missionId,
    required String category,
    required String type,
    required String difficulty,
    required List<MissionProgress> progressList,
    required int rpPerCompletion,
  }) {
    if (progressList.isEmpty) {
      return MissionCompletionStats(
        missionId: missionId,
        category: category,
        type: type,
        difficulty: difficulty,
        totalAttempts: 0,
        completedAttempts: 0,
        completionRate: 0.0,
        averageCompletionTime: Duration.zero,
        totalRPEarned: 0,
        firstAttempt: DateTime.now(),
      );
    }

    final completed = progressList.where((p) => p.isCompleted).toList();
    final completionTimes = completed
        .where((p) => p.completedAt != null)
        .map((p) => p.completedAt!.difference(p.lastUpdated).abs())
        .toList();

    final avgCompletionTime = completionTimes.isNotEmpty
        ? Duration(
            milliseconds: completionTimes
                .map((d) => d.inMilliseconds)
                .reduce((a, b) => a + b) ~/
            completionTimes.length,
          )
        : Duration.zero;

    progressList.sort((a, b) => a.lastUpdated.compareTo(b.lastUpdated));

    return MissionCompletionStats(
      missionId: missionId,
      category: category,
      type: type,
      difficulty: difficulty,
      totalAttempts: progressList.length,
      completedAttempts: completed.length,
      completionRate: progressList.isNotEmpty
          ? completed.length / progressList.length
          : 0.0,
      averageCompletionTime: avgCompletionTime,
      totalRPEarned: completed.length * rpPerCompletion,
      firstAttempt: progressList.first.lastUpdated,
      lastCompleted: completed.isNotEmpty
          ? completed.last.completedAt
          : null,
    );
  }

  /// Check if this mission type shows good completion rates
  bool get hasGoodCompletionRate => completionRate >= 0.7;

  /// Check if this is a challenging mission for the user
  bool get isChallengingMission => completionRate < 0.5 && totalAttempts >= 3;

  /// Get completion rate as percentage string
  String get completionRatePercentage => '${(completionRate * 100).toInt()}%';

  @override
  String toString() {
    return 'MissionStats($missionId: $completionRatePercentage completion, '
           '$completedAttempts/$totalAttempts attempts, ${totalRPEarned}RP earned)';
  }
}