import '../constants/research_points_constants.dart';
import 'session_quality.dart';

/// Core Research Points (RP) model with calculation utilities
/// 
/// This model provides deterministic RP calculations based on session duration,
/// quality, break adherence, and streak bonuses while preventing exploitation.
class ResearchPoints {
  final int baseRP;
  final int bonusRP;
  final int streakBonus;
  final int qualityBonus;
  final int breakAdherenceBonus;
  final SessionQuality sessionQuality;
  final Duration sessionDuration;
  final bool hasStreakBonus;
  final DateTime calculatedAt;
  final String? notes;

  const ResearchPoints({
    required this.baseRP,
    required this.bonusRP,
    required this.streakBonus,
    required this.qualityBonus,
    required this.breakAdherenceBonus,
    required this.sessionQuality,
    required this.sessionDuration,
    required this.hasStreakBonus,
    required this.calculatedAt,
    this.notes,
  });

  /// Calculate RP for a completed session
  factory ResearchPoints.calculate({
    required Duration sessionDuration,
    required SessionQualityModel qualityModel,
    required int currentStreak,
    required bool hasStreakBonusToday,
    String? notes,
  }) {
    // Validate session duration
    if (!_isValidSessionDuration(sessionDuration)) {
      return ResearchPoints._invalid(sessionDuration, notes);
    }

    // Calculate base RP from duration
    final baseRP = _calculateBaseRP(sessionDuration);
    
    // Apply quality multiplier
    final qualityMultiplier = qualityModel.rpMultiplier;
    final adjustedBaseRP = (baseRP * qualityMultiplier).round();
    
    // Calculate bonuses
    final qualityBonus = qualityModel.bonusRP;
    final breakBonus = qualityModel.breakAdherenceBonus;
    final streakBonus = _calculateStreakBonus(
      currentStreak: currentStreak,
      hasStreakBonusToday: hasStreakBonusToday,
      sessionQuality: qualityModel.quality,
    );
    
    // Calculate total bonus RP (capped for exploitation prevention)
    final totalBonusRP = _capBonusRP(qualityBonus + breakBonus + streakBonus);
    
    return ResearchPoints(
      baseRP: adjustedBaseRP,
      bonusRP: totalBonusRP,
      streakBonus: streakBonus,
      qualityBonus: qualityBonus,
      breakAdherenceBonus: breakBonus,
      sessionQuality: qualityModel.quality,
      sessionDuration: sessionDuration,
      hasStreakBonus: streakBonus > 0,
      calculatedAt: DateTime.now(),
      notes: notes,
    );
  }

  /// Create RP instance for abandoned/invalid sessions
  factory ResearchPoints._invalid(Duration sessionDuration, String? notes) {
    return ResearchPoints(
      baseRP: 0,
      bonusRP: 0,
      streakBonus: 0,
      qualityBonus: 0,
      breakAdherenceBonus: 0,
      sessionQuality: SessionQuality.abandoned,
      sessionDuration: sessionDuration,
      hasStreakBonus: false,
      calculatedAt: DateTime.now(),
      notes: notes ?? 'Invalid session - insufficient duration or incomplete',
    );
  }

  /// Calculate base RP from session duration using the standard formula
  static int _calculateBaseRP(Duration sessionDuration) {
    final minutes = sessionDuration.inMinutes;
    
    // Use the base formula: minutes / 25 * 10 (simplified to minutes * 0.4)
    // But ensure minimum sessions get some RP
    if (minutes < ResearchPointsConstants.minSessionForRP) {
      return 0;
    }
    
    // Apply the base calculation
    final calculatedRP = (minutes / ResearchPointsConstants.baseRPPerMinute * 10).round();
    
    // Cap at maximum base RP to prevent exploitation of very long sessions
    return calculatedRP.clamp(0, ResearchPointsConstants.maxBaseRP);
  }

  /// Calculate streak bonus (max 1 per day to prevent exploitation)
  static int _calculateStreakBonus({
    required int currentStreak,
    required bool hasStreakBonusToday,
    required SessionQuality sessionQuality,
  }) {
    // No bonus for abandoned sessions
    if (sessionQuality == SessionQuality.abandoned) {
      return 0;
    }
    
    // No bonus if already awarded today
    if (hasStreakBonusToday) {
      return 0;
    }
    
    // Must have minimum streak for bonus
    if (currentStreak < ResearchPointsConstants.minStreakForBonus) {
      return 0;
    }
    
    // Award streak bonus
    return ResearchPointsConstants.streakBonus;
  }

  /// Cap bonus RP to prevent exploitation
  static int _capBonusRP(int bonusRP) {
    return bonusRP.clamp(0, ResearchPointsConstants.maxBonusRP);
  }

  /// Validate session duration
  static bool _isValidSessionDuration(Duration sessionDuration) {
    final seconds = sessionDuration.inSeconds;
    return seconds >= ResearchPointsConstants.minValidSessionSeconds &&
           seconds <= ResearchPointsConstants.maxValidSessionSeconds;
  }

  /// Get total RP (base + bonus)
  int get totalRP => baseRP + bonusRP;
  
  /// Check if this is a valid RP calculation
  bool get isValid => baseRP > 0 || sessionQuality != SessionQuality.abandoned;
  
  /// Check if session earned maximum possible RP
  bool get isMaximumEfficiency {
    return sessionQuality == SessionQuality.perfect &&
           breakAdherenceBonus > 0 &&
           hasStreakBonus;
  }

  /// Get efficiency percentage (0-100%)
  double get efficiencyPercentage {
    if (!isValid) return 0.0;
    
    final maxPossibleBase = _calculateBaseRP(sessionDuration);
    final maxPossibleBonus = ResearchPointsConstants.maxBonusRP;
    final maxPossibleTotal = maxPossibleBase + maxPossibleBonus;
    
    if (maxPossibleTotal == 0) return 0.0;
    
    return (totalRP / maxPossibleTotal * 100).clamp(0.0, 100.0);
  }

  /// Get detailed breakdown of RP calculation
  RPBreakdown get breakdown {
    return RPBreakdown(
      sessionDuration: sessionDuration,
      sessionQuality: sessionQuality,
      baseRP: baseRP,
      qualityBonus: qualityBonus,
      breakAdherenceBonus: breakAdherenceBonus,
      streakBonus: streakBonus,
      totalBonus: bonusRP,
      totalRP: totalRP,
      efficiencyPercentage: efficiencyPercentage,
      isMaximumEfficiency: isMaximumEfficiency,
      calculatedAt: calculatedAt,
    );
  }

  /// Generate feedback message for the user
  String get feedbackMessage {
    if (!isValid) {
      return 'No RP earned - session was too short or incomplete.';
    }
    
    final messages = <String>[];
    messages.add('Earned $totalRP RP total');
    
    if (bonusRP > 0) {
      final bonusParts = <String>[];
      if (qualityBonus > 0) bonusParts.add('$qualityBonus quality');
      if (breakAdherenceBonus > 0) bonusParts.add('$breakAdherenceBonus breaks');
      if (streakBonus > 0) bonusParts.add('$streakBonus streak');
      
      messages.add('($baseRP} base + $bonusRP bonus: ${bonusParts.join(', ')})');
    }
    
    if (isMaximumEfficiency) {
      messages.add('Perfect session! 🌟');
    }
    
    return messages.join(' ');
  }

  /// Generate recommendations for improvement
  List<String> get recommendations {
    final recommendations = <String>[];
    
    if (sessionQuality == SessionQuality.abandoned) {
      recommendations.add('Complete your full session to earn RP');
    }
    
    if (breakAdherenceBonus == 0 && sessionDuration.inMinutes >= 30) {
      recommendations.add('Take proper breaks to earn +${ResearchPointsConstants.breakAdherenceBonus} RP bonus');
    }
    
    if (streakBonus == 0) {
      recommendations.add('Maintain daily consistency to earn +${ResearchPointsConstants.streakBonus} RP streak bonus');
    }
    
    if (sessionDuration.inMinutes < 25) {
      recommendations.add('25-minute sessions provide optimal RP efficiency');
    }
    
    if (sessionDuration.inMinutes > 90) {
      recommendations.add('Consider shorter sessions (25-50 min) for better work-rest balance');
    }
    
    return recommendations;
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'baseRP': baseRP,
      'bonusRP': bonusRP,
      'streakBonus': streakBonus,
      'qualityBonus': qualityBonus,
      'breakAdherenceBonus': breakAdherenceBonus,
      'sessionQuality': sessionQuality.name,
      'sessionDurationSeconds': sessionDuration.inSeconds,
      'hasStreakBonus': hasStreakBonus,
      'calculatedAt': calculatedAt.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  /// Create from JSON
  factory ResearchPoints.fromJson(Map<String, dynamic> json) {
    return ResearchPoints(
      baseRP: json['baseRP'] ?? 0,
      bonusRP: json['bonusRP'] ?? 0,
      streakBonus: json['streakBonus'] ?? 0,
      qualityBonus: json['qualityBonus'] ?? 0,
      breakAdherenceBonus: json['breakAdherenceBonus'] ?? 0,
      sessionQuality: SessionQuality.values.firstWhere(
        (e) => e.name == json['sessionQuality'],
        orElse: () => SessionQuality.good,
      ),
      sessionDuration: Duration(seconds: json['sessionDurationSeconds'] ?? 0),
      hasStreakBonus: json['hasStreakBonus'] ?? false,
      calculatedAt: DateTime.fromMillisecondsSinceEpoch(
        json['calculatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      notes: json['notes'],
    );
  }

  @override
  String toString() {
    return 'ResearchPoints(total: $totalRP, base: $baseRP, bonus: $bonusRP, quality: ${sessionQuality.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResearchPoints &&
        other.baseRP == baseRP &&
        other.bonusRP == bonusRP &&
        other.sessionQuality == sessionQuality &&
        other.sessionDuration == sessionDuration;
  }

  @override
  int get hashCode {
    return Object.hash(baseRP, bonusRP, sessionQuality, sessionDuration);
  }
}

/// Detailed breakdown of RP calculation for transparency
class RPBreakdown {
  final Duration sessionDuration;
  final SessionQuality sessionQuality;
  final int baseRP;
  final int qualityBonus;
  final int breakAdherenceBonus;
  final int streakBonus;
  final int totalBonus;
  final int totalRP;
  final double efficiencyPercentage;
  final bool isMaximumEfficiency;
  final DateTime calculatedAt;

  const RPBreakdown({
    required this.sessionDuration,
    required this.sessionQuality,
    required this.baseRP,
    required this.qualityBonus,
    required this.breakAdherenceBonus,
    required this.streakBonus,
    required this.totalBonus,
    required this.totalRP,
    required this.efficiencyPercentage,
    required this.isMaximumEfficiency,
    required this.calculatedAt,
  });

  /// Get formatted breakdown for display
  String get formattedBreakdown {
    final parts = <String>[];
    parts.add('Base RP: $baseRP');
    
    if (qualityBonus > 0) parts.add('Quality Bonus: +$qualityBonus');
    if (breakAdherenceBonus > 0) parts.add('Break Bonus: +$breakAdherenceBonus');
    if (streakBonus > 0) parts.add('Streak Bonus: +$streakBonus');
    
    parts.add('Total: $totalRP RP');
    parts.add('Efficiency: ${efficiencyPercentage.toStringAsFixed(1)}%');
    
    return parts.join('\n');
  }
}

/// Utility class for RP calculations and validations
class RPCalculator {
  RPCalculator._();

  /// Calculate expected RP for a given session duration (for planning)
  static int calculateExpectedRP({
    required Duration sessionDuration,
    SessionQuality quality = SessionQuality.good,
    bool withBreakBonus = false,
    bool withStreakBonus = false,
  }) {
    if (!ResearchPoints._isValidSessionDuration(sessionDuration)) {
      return 0;
    }

    final baseRP = ResearchPoints._calculateBaseRP(sessionDuration);
    final qualityMultiplier = ResearchPointsConstants.qualityMultipliers[quality] ?? 1.0;
    final adjustedBaseRP = (baseRP * qualityMultiplier).round();
    
    int bonus = 0;
    if (quality == SessionQuality.perfect) {
      bonus += ResearchPointsConstants.perfectSessionBonus;
    }
    if (withBreakBonus) {
      bonus += ResearchPointsConstants.breakAdherenceBonus;
    }
    if (withStreakBonus) {
      bonus += ResearchPointsConstants.streakBonus;
    }
    
    return adjustedBaseRP + ResearchPoints._capBonusRP(bonus);
  }

  /// Get optimal session duration for maximum RP efficiency
  static Duration get optimalSessionDuration {
    return const Duration(minutes: 25); // Standard Pomodoro
  }

  /// Validate if daily RP limit would be exceeded
  static bool isWithinDailyLimit(int currentDailyRP, int additionalRP) {
    return (currentDailyRP + additionalRP) <= ResearchPointsConstants.maxDailyRP;
  }

  /// Get RP requirements for next career milestone
  static int getRPToNextCareerMilestone(int currentRP) {
    for (final milestone in ResearchPointsConstants.careerMilestones) {
      if (currentRP < milestone) {
        return milestone - currentRP;
      }
    }
    return 0; // Max level reached
  }

  /// Get RP requirements for next depth zone
  static int getRPToNextDepthZone(int currentRP) {
    for (final threshold in ResearchPointsConstants.depthZoneBoundaries) {
      if (currentRP < threshold) {
        return threshold - currentRP;
      }
    }
    return 0; // Max depth reached
  }
}