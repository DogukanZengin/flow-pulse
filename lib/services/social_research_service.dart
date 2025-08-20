import 'package:flutter/material.dart';

/// Social Research Service - Phase 4 Social Hub Implementation
/// Manages leaderboards, collaborations, and community goals for marine research simulation
class SocialResearchService {
  static final SocialResearchService _instance = SocialResearchService._internal();
  SocialResearchService._internal();
  static SocialResearchService get instance => _instance;

  /// Generate leaderboards based on category and current user
  static List<ResearcherProfile> generateLeaderboards(
    ResearcherProfile currentUser,
    LeaderboardCategory category,
  ) {
    // Return only the current user for now - no mock data
    final researchers = <ResearcherProfile>[];
    researchers.add(currentUser.copyWith(ranking: 1));
    return researchers;
  }
  
  /// Get collaboration opportunities for a researcher
  static List<CollaborationOpportunity> getCollaborationOpportunities(ResearcherProfile user) {
    // Return empty list - no mock collaborations
    return [];
  }
  
  /// Get community goals
  static List<CommunityGoal> getCommunityGoals() {
    // Return empty list - no mock community goals
    return [];
  }
}

/// Leaderboard categories for ranking researchers
enum LeaderboardCategory {
  totalDiscoveries,
  researchLevel,
  currentStreak,
  researchEfficiency,
  weeklyDiscoveries,
  legendaryDiscoveries,
}

/// Researcher profile containing all social research data
class ResearcherProfile {
  final String id;
  final String name;
  final int researchLevel;
  final int totalDiscoveries;
  final int currentStreak;
  final double researchEfficiency;
  final int weeklyDiscoveries;
  final int legendaryDiscoveries;
  final String specialization;
  final DateTime joinedDate;
  final DateTime lastActiveDate;
  final int achievements;
  final int publicationsCount;
  final int collaborationsCount;
  final int ranking;

  const ResearcherProfile({
    required this.id,
    required this.name,
    required this.researchLevel,
    required this.totalDiscoveries,
    required this.currentStreak,
    required this.researchEfficiency,
    required this.weeklyDiscoveries,
    required this.legendaryDiscoveries,
    required this.specialization,
    required this.joinedDate,
    required this.lastActiveDate,
    required this.achievements,
    required this.publicationsCount,
    required this.collaborationsCount,
    required this.ranking,
  });

  String get rankingDisplay {
    switch (ranking) {
      case 1:
        return '🏆 #1';
      case 2:
        return '🥈 #2';
      case 3:
        return '🥉 #3';
      default:
        return '#$ranking';
    }
  }

  ResearcherProfile copyWith({
    String? id,
    String? name,
    int? researchLevel,
    int? totalDiscoveries,
    int? currentStreak,
    double? researchEfficiency,
    int? weeklyDiscoveries,
    int? legendaryDiscoveries,
    String? specialization,
    DateTime? joinedDate,
    DateTime? lastActiveDate,
    int? achievements,
    int? publicationsCount,
    int? collaborationsCount,
    int? ranking,
  }) {
    return ResearcherProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      researchLevel: researchLevel ?? this.researchLevel,
      totalDiscoveries: totalDiscoveries ?? this.totalDiscoveries,
      currentStreak: currentStreak ?? this.currentStreak,
      researchEfficiency: researchEfficiency ?? this.researchEfficiency,
      weeklyDiscoveries: weeklyDiscoveries ?? this.weeklyDiscoveries,
      legendaryDiscoveries: legendaryDiscoveries ?? this.legendaryDiscoveries,
      specialization: specialization ?? this.specialization,
      joinedDate: joinedDate ?? this.joinedDate,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      achievements: achievements ?? this.achievements,
      publicationsCount: publicationsCount ?? this.publicationsCount,
      collaborationsCount: collaborationsCount ?? this.collaborationsCount,
      ranking: ranking ?? this.ranking,
    );
  }
}

/// Types of collaboration opportunities
enum CollaborationType {
  expedition,
  conservation,
  documentation,
  mentorship,
}

extension CollaborationTypeExtension on CollaborationType {
  String get displayName {
    switch (this) {
      case CollaborationType.expedition:
        return 'Research Expedition';
      case CollaborationType.conservation:
        return 'Conservation Project';
      case CollaborationType.documentation:
        return 'Documentation';
      case CollaborationType.mentorship:
        return 'Mentorship';
    }
  }

  Color get color {
    switch (this) {
      case CollaborationType.expedition:
        return const Color(0xFF2196F3); // Blue
      case CollaborationType.conservation:
        return const Color(0xFF4CAF50); // Green
      case CollaborationType.documentation:
        return const Color(0xFF9C27B0); // Purple
      case CollaborationType.mentorship:
        return const Color(0xFFFF9800); // Orange
    }
  }
}

/// Collaboration opportunity for researchers
class CollaborationOpportunity {
  final String id;
  final String title;
  final String description;
  final CollaborationType category;
  final List<String> requirements;
  final CollaborationRewards rewards;
  final int currentParticipants;
  final int maxParticipants;
  final int daysRemaining;
  final double completionPercentage;
  final bool isEligible;

  const CollaborationOpportunity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.requirements,
    required this.rewards,
    required this.currentParticipants,
    required this.maxParticipants,
    required this.daysRemaining,
    required this.completionPercentage,
    required this.isEligible,
  });
}

/// Rewards for collaboration participation
class CollaborationRewards {
  final int xpBonus;
  final String specialBadge;
  final String exclusiveSpecies;

  const CollaborationRewards({
    required this.xpBonus,
    required this.specialBadge,
    required this.exclusiveSpecies,
  });
}

/// Community goal categories
enum CommunityGoalCategory {
  discoveries,
  conservation,
  research,
}

/// Community goals for all researchers
class CommunityGoal {
  final String id;
  final String title;
  final String description;
  final int currentProgress;
  final int targetProgress;
  final int daysRemaining;
  final CommunityRewards rewards;
  final CommunityGoalCategory category;

  const CommunityGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.currentProgress,
    required this.targetProgress,
    required this.daysRemaining,
    required this.rewards,
    required this.category,
  });

  double get progressPercentage => currentProgress / targetProgress;
}

/// Rewards for community goal completion
class CommunityRewards {
  final int globalXpBonus;
  final String specialBadge;
  final String exclusiveContent;
  final String titleUnlock;

  const CommunityRewards({
    required this.globalXpBonus,
    required this.specialBadge,
    required this.exclusiveContent,
    required this.titleUnlock,
  });
}