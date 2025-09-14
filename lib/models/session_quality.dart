import '../constants/research_points_constants.dart';

/// Model representing session quality metrics and assessment
/// 
/// This model evaluates session completion and break adherence to determine
/// the appropriate SessionQuality level for RP calculation.
class SessionQualityModel {
  final SessionQuality quality;
  final bool isCompleted;
  final bool hasProperBreakAdherence;
  final bool wasInterrupted;
  final Duration sessionDuration;
  final Duration? breakDuration;
  final String? qualityNotes;
  final DateTime timestamp;

  const SessionQualityModel({
    required this.quality,
    required this.isCompleted,
    required this.hasProperBreakAdherence,
    required this.wasInterrupted,
    required this.sessionDuration,
    this.breakDuration,
    this.qualityNotes,
    required this.timestamp,
  });

  /// Create a SessionQualityModel from session data
  factory SessionQualityModel.fromSessionData({
    required Duration sessionDuration,
    required bool isCompleted,
    required bool wasInterrupted,
    Duration? breakDuration,
    String? notes,
    DateTime? timestamp,
  }) {
    final hasProperBreakAdherence = _assessBreakAdherence(
      sessionDuration: sessionDuration,
      breakDuration: breakDuration,
    );

    final quality = _determineQuality(
      isCompleted: isCompleted,
      wasInterrupted: wasInterrupted,
      hasProperBreakAdherence: hasProperBreakAdherence,
    );

    return SessionQualityModel(
      quality: quality,
      isCompleted: isCompleted,
      hasProperBreakAdherence: hasProperBreakAdherence,
      wasInterrupted: wasInterrupted,
      sessionDuration: sessionDuration,
      breakDuration: breakDuration,
      qualityNotes: notes,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// Create a perfect quality session
  factory SessionQualityModel.perfect({
    required Duration sessionDuration,
    Duration? breakDuration,
    String? notes,
  }) {
    return SessionQualityModel(
      quality: SessionQuality.perfect,
      isCompleted: true,
      hasProperBreakAdherence: true,
      wasInterrupted: false,
      sessionDuration: sessionDuration,
      breakDuration: breakDuration,
      qualityNotes: notes,
      timestamp: DateTime.now(),
    );
  }

  /// Create a good quality session
  factory SessionQualityModel.good({
    required Duration sessionDuration,
    Duration? breakDuration,
    String? notes,
  }) {
    return SessionQualityModel(
      quality: SessionQuality.good,
      isCompleted: true,
      hasProperBreakAdherence: false,
      wasInterrupted: false,
      sessionDuration: sessionDuration,
      breakDuration: breakDuration,
      qualityNotes: notes,
      timestamp: DateTime.now(),
    );
  }

  /// Create an abandoned quality session
  factory SessionQualityModel.abandoned({
    required Duration sessionDuration,
    String? notes,
  }) {
    return SessionQualityModel(
      quality: SessionQuality.abandoned,
      isCompleted: false,
      hasProperBreakAdherence: false,
      wasInterrupted: true,
      sessionDuration: sessionDuration,
      breakDuration: null,
      qualityNotes: notes,
      timestamp: DateTime.now(),
    );
  }

  /// Assess if the session had proper break adherence
  static bool _assessBreakAdherence({
    required Duration sessionDuration,
    Duration? breakDuration,
  }) {
    // Sessions under 30 minutes don't require breaks
    if (sessionDuration.inMinutes < 30) {
      return true;
    }

    // No break taken for longer sessions
    if (breakDuration == null || breakDuration.inSeconds == 0) {
      return false;
    }

    // Break must be at least the minimum duration
    if (breakDuration.inSeconds < ResearchPointsConstants.minBreakDurationSeconds) {
      return false;
    }

    // Break should be appropriate for session length
    final requiredBreakRatio = ResearchPointsConstants.breakToSessionRatio;
    final minBreakSeconds = (sessionDuration.inSeconds * requiredBreakRatio).round();
    
    return breakDuration.inSeconds >= minBreakSeconds;
  }

  /// Determine the overall session quality
  static SessionQuality _determineQuality({
    required bool isCompleted,
    required bool wasInterrupted,
    required bool hasProperBreakAdherence,
  }) {
    // Abandoned sessions get no RP
    if (!isCompleted || wasInterrupted) {
      return SessionQuality.abandoned;
    }

    // Perfect sessions: completed with proper break adherence
    if (hasProperBreakAdherence) {
      return SessionQuality.perfect;
    }

    // Good sessions: completed but without perfect break adherence
    return SessionQuality.good;
  }

  /// Get the RP multiplier for this session quality
  double get rpMultiplier {
    return ResearchPointsConstants.qualityMultipliers[quality] ?? 0.0;
  }

  /// Get bonus RP for perfect sessions
  int get bonusRP {
    return quality == SessionQuality.perfect 
        ? ResearchPointsConstants.perfectSessionBonus 
        : 0;
  }

  /// Get break adherence bonus RP
  int get breakAdherenceBonus {
    return hasProperBreakAdherence 
        ? ResearchPointsConstants.breakAdherenceBonus 
        : 0;
  }

  /// Get a detailed quality assessment
  SessionQualityAssessment get assessment {
    return SessionQualityAssessment(
      quality: quality,
      rpMultiplier: rpMultiplier,
      bonusRP: bonusRP,
      breakAdherenceBonus: breakAdherenceBonus,
      feedback: _generateFeedback(),
      recommendations: _generateRecommendations(),
    );
  }

  /// Generate quality feedback message
  String _generateFeedback() {
    switch (quality) {
      case SessionQuality.perfect:
        return 'Excellent work! You completed your session with proper break adherence.';
      case SessionQuality.good:
        return 'Good session! Consider taking proper breaks to achieve perfect quality.';
      case SessionQuality.abandoned:
        return 'Session was incomplete. Try to finish your planned focus time.';
    }
  }

  /// Generate improvement recommendations
  List<String> _generateRecommendations() {
    final recommendations = <String>[];

    if (!isCompleted) {
      recommendations.add('Try to complete your full planned session duration');
    }

    if (!hasProperBreakAdherence && sessionDuration.inMinutes >= 30) {
      recommendations.add('Take regular breaks to maintain focus and earn break bonuses');
      recommendations.add('Breaks should be at least ${ResearchPointsConstants.breakToSessionRatio * 100}% of your session time');
    }

    if (wasInterrupted) {
      recommendations.add('Minimize distractions during focus sessions');
    }

    if (sessionDuration.inMinutes > ResearchPointsConstants.maxSessionWithoutBreakMinutes) {
      recommendations.add('Consider breaking longer sessions into smaller chunks');
    }

    return recommendations;
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'quality': quality.name,
      'isCompleted': isCompleted,
      'hasProperBreakAdherence': hasProperBreakAdherence,
      'wasInterrupted': wasInterrupted,
      'sessionDurationSeconds': sessionDuration.inSeconds,
      'breakDurationSeconds': breakDuration?.inSeconds,
      'qualityNotes': qualityNotes,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  /// Create from JSON
  factory SessionQualityModel.fromJson(Map<String, dynamic> json) {
    return SessionQualityModel(
      quality: SessionQuality.values.firstWhere(
        (e) => e.name == json['quality'],
        orElse: () => SessionQuality.good,
      ),
      isCompleted: json['isCompleted'] ?? false,
      hasProperBreakAdherence: json['hasProperBreakAdherence'] ?? false,
      wasInterrupted: json['wasInterrupted'] ?? false,
      sessionDuration: Duration(seconds: json['sessionDurationSeconds'] ?? 0),
      breakDuration: json['breakDurationSeconds'] != null
          ? Duration(seconds: json['breakDurationSeconds'])
          : null,
      qualityNotes: json['qualityNotes'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  String toString() {
    return 'SessionQuality(${quality.displayName}, completed: $isCompleted, '
           'breakAdherence: $hasProperBreakAdherence, duration: ${sessionDuration.inMinutes}min)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionQualityModel &&
        other.quality == quality &&
        other.isCompleted == isCompleted &&
        other.hasProperBreakAdherence == hasProperBreakAdherence &&
        other.wasInterrupted == wasInterrupted &&
        other.sessionDuration == sessionDuration;
  }

  @override
  int get hashCode {
    return Object.hash(
      quality,
      isCompleted,
      hasProperBreakAdherence,
      wasInterrupted,
      sessionDuration,
    );
  }
}

/// Detailed assessment of session quality with feedback
class SessionQualityAssessment {
  final SessionQuality quality;
  final double rpMultiplier;
  final int bonusRP;
  final int breakAdherenceBonus;
  final String feedback;
  final List<String> recommendations;

  const SessionQualityAssessment({
    required this.quality,
    required this.rpMultiplier,
    required this.bonusRP,
    required this.breakAdherenceBonus,
    required this.feedback,
    required this.recommendations,
  });

  /// Get total bonus RP from quality and break adherence
  int get totalBonusRP => bonusRP + breakAdherenceBonus;

  /// Check if this was a high-quality session
  bool get isHighQuality => quality == SessionQuality.perfect;

  /// Get a summary of the assessment
  String get summary {
    return '${quality.displayName} session (${(rpMultiplier * 100).toInt()}% RP, +$totalBonusRP bonus)';
  }
}