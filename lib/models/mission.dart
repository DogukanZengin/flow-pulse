import '../constants/mission_constants.dart';

/// Core Mission model representing individual missions in the FlowPulse hybrid leveling system
///
/// Missions provide structured goals that encourage consistent, quality-focused productivity
/// habits rather than duration-based achievements.
class Mission {
  final String id;
  final String title;
  final String description;
  final String category;
  final String type;
  final String difficulty;
  final int targetValue;
  final int currentProgress;
  final bool isCompleted;
  final DateTime? completedAt;
  final int rewardRP;
  final Map<String, dynamic>? rewardBonus;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
  final String status;
  final String progressType;

  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.difficulty,
    required this.targetValue,
    required this.currentProgress,
    required this.isCompleted,
    this.completedAt,
    required this.rewardRP,
    this.rewardBonus,
    this.expiresAt,
    required this.createdAt,
    this.metadata,
    required this.status,
    required this.progressType,
  });

  /// Create a new mission from template
  factory Mission.fromTemplate({
    required Map<String, dynamic> template,
    required int targetValue,
    String? customDescription,
    Map<String, dynamic>? customMetadata,
  }) {
    final now = DateTime.now();
    final type = template['type'] as String;
    final difficulty = template['difficulty'] as String;

    // Calculate expiration time based on mission type
    DateTime? expiresAt;
    final durationHours = MissionConstants.getMissionDuration(type);
    if (durationHours > 0) {
      expiresAt = now.add(Duration(hours: durationHours));
    }

    // Generate unique ID
    final id = '${template['id']}_${now.millisecondsSinceEpoch}';

    // Replace placeholder in description
    final description = customDescription ??
        (template['description'] as String).replaceAll('{target}', targetValue.toString());

    return Mission(
      id: id,
      title: template['title'] as String,
      description: description,
      category: template['category'] as String,
      type: type,
      difficulty: difficulty,
      targetValue: targetValue,
      currentProgress: 0,
      isCompleted: false,
      rewardRP: MissionConstants.getRPReward(difficulty),
      expiresAt: expiresAt,
      createdAt: now,
      metadata: customMetadata,
      status: MissionConstants.statusActive,
      progressType: _determineProgressType(template['category'] as String),
    );
  }

  /// Create mission from JSON (for database persistence)
  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      type: json['type'] as String,
      difficulty: json['difficulty'] as String? ?? MissionConstants.difficultyIntermediate,
      targetValue: json['target_value'] as int,
      currentProgress: json['current_progress'] as int? ?? 0,
      isCompleted: (json['is_completed'] as int? ?? 0) == 1,
      completedAt: json['completed_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completed_date'] as int)
          : null,
      rewardRP: json['reward_rp'] as int? ?? 0,
      rewardBonus: json['reward_bonus'] != null
          ? Map<String, dynamic>.from(json['reward_bonus'] as Map)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['expires_at'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['created_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      status: json['status'] as String? ?? MissionConstants.statusActive,
      progressType: json['progress_type'] as String? ?? MissionConstants.progressTypeCount,
    );
  }

  /// Convert to JSON for database persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'type': type,
      'difficulty': difficulty,
      'target_value': targetValue,
      'current_progress': currentProgress,
      'is_completed': isCompleted ? 1 : 0,
      'completed_date': completedAt?.millisecondsSinceEpoch,
      'reward_rp': rewardRP,
      'reward_bonus': rewardBonus,
      'expires_at': expiresAt?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'metadata': metadata,
      'status': status,
      'progress_type': progressType,
    };
  }

  /// Update mission progress
  Mission updateProgress(int progressDelta) {
    final newProgress = (currentProgress + progressDelta).clamp(0, targetValue);
    final completed = newProgress >= targetValue;

    return copyWith(
      currentProgress: newProgress,
      isCompleted: completed,
      completedAt: completed && !isCompleted ? DateTime.now() : completedAt,
      status: completed ? MissionConstants.statusCompleted : status,
    );
  }

  /// Set mission progress to specific value
  Mission setProgress(int progress) {
    final clampedProgress = progress.clamp(0, targetValue);
    final completed = clampedProgress >= targetValue;

    return copyWith(
      currentProgress: clampedProgress,
      isCompleted: completed,
      completedAt: completed && !isCompleted ? DateTime.now() : completedAt,
      status: completed ? MissionConstants.statusCompleted : status,
    );
  }

  /// Mark mission as expired
  Mission markExpired() {
    return copyWith(
      status: MissionConstants.statusExpired,
    );
  }

  /// Get progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (targetValue == 0) return 0.0;
    return (currentProgress / targetValue).clamp(0.0, 1.0);
  }

  /// Check if mission is active and can receive progress updates
  bool get isActive {
    return status == MissionConstants.statusActive && !isExpired;
  }

  /// Check if mission has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get time remaining until expiration
  Duration? get timeRemaining {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return Duration.zero;
    return expiresAt!.difference(now);
  }

  /// Get mission difficulty as enum for easier comparison
  MissionDifficulty get difficultyLevel {
    switch (difficulty) {
      case MissionConstants.difficultyBeginner:
        return MissionDifficulty.beginner;
      case MissionConstants.difficultyIntermediate:
        return MissionDifficulty.intermediate;
      case MissionConstants.difficultyAdvanced:
        return MissionDifficulty.advanced;
      case MissionConstants.difficultyExpert:
        return MissionDifficulty.expert;
      default:
        return MissionDifficulty.intermediate;
    }
  }

  /// Get appropriate icon for this mission
  String get icon {
    return MissionConstants.getCategoryIcon(category);
  }

  /// Get difficulty icon
  String get difficultyIcon {
    return MissionConstants.getDifficultyIcon(difficulty);
  }

  /// Get formatted progress string
  String get formattedProgress {
    switch (progressType) {
      case MissionConstants.progressTypeTime:
        final currentMinutes = currentProgress;
        final targetMinutes = targetValue;
        return '$currentMinutes / $targetMinutes minutes';
      case MissionConstants.progressTypePercentage:
        return '${(progressPercentage * 100).toInt()}%';
      case MissionConstants.progressTypeStreak:
        return '$currentProgress day${currentProgress == 1 ? '' : 's'} streak';
      case MissionConstants.progressTypeCount:
      default:
        return '$currentProgress / $targetValue';
    }
  }

  /// Get user-friendly status description
  String get statusDescription {
    switch (status) {
      case MissionConstants.statusActive:
        return isExpired ? 'Expired' : 'Active';
      case MissionConstants.statusCompleted:
        return 'Completed';
      case MissionConstants.statusExpired:
        return 'Expired';
      case MissionConstants.statusLocked:
        return 'Locked';
      default:
        return 'Unknown';
    }
  }

  /// Determine progress type based on category
  static String _determineProgressType(String category) {
    switch (category) {
      case MissionConstants.categoryConsistency:
        return MissionConstants.progressTypeStreak;
      case MissionConstants.categoryProductivity:
        return MissionConstants.progressTypeTime;
      case MissionConstants.categoryQuality:
        return MissionConstants.progressTypePercentage;
      case MissionConstants.categoryDiscovery:
      default:
        return MissionConstants.progressTypeCount;
    }
  }

  /// Copy with new values
  Mission copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? type,
    String? difficulty,
    int? targetValue,
    int? currentProgress,
    bool? isCompleted,
    DateTime? completedAt,
    int? rewardRP,
    Map<String, dynamic>? rewardBonus,
    DateTime? expiresAt,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
    String? status,
    String? progressType,
  }) {
    return Mission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      targetValue: targetValue ?? this.targetValue,
      currentProgress: currentProgress ?? this.currentProgress,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      rewardRP: rewardRP ?? this.rewardRP,
      rewardBonus: rewardBonus ?? this.rewardBonus,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
      progressType: progressType ?? this.progressType,
    );
  }

  @override
  String toString() {
    return 'Mission(id: $id, title: $title, progress: $formattedProgress, status: $statusDescription)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Mission && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Mission difficulty levels for easier comparison and logic
enum MissionDifficulty {
  beginner,
  intermediate,
  advanced,
  expert,
}

/// Extension methods for MissionDifficulty
extension MissionDifficultyExtension on MissionDifficulty {
  String get displayName {
    switch (this) {
      case MissionDifficulty.beginner:
        return 'Beginner';
      case MissionDifficulty.intermediate:
        return 'Intermediate';
      case MissionDifficulty.advanced:
        return 'Advanced';
      case MissionDifficulty.expert:
        return 'Expert';
    }
  }

  String get constantValue {
    switch (this) {
      case MissionDifficulty.beginner:
        return MissionConstants.difficultyBeginner;
      case MissionDifficulty.intermediate:
        return MissionConstants.difficultyIntermediate;
      case MissionDifficulty.advanced:
        return MissionConstants.difficultyAdvanced;
      case MissionDifficulty.expert:
        return MissionConstants.difficultyExpert;
    }
  }

  int get rpReward {
    return MissionConstants.getRPReward(constantValue);
  }
}