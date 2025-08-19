import 'dart:math';
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
    final random = Random();
    final researchers = <ResearcherProfile>[];
    
    // Add current user to the list
    researchers.add(currentUser);
    
    // Generate 19 other researchers for a top 20 leaderboard
    for (int i = 1; i < 20; i++) {
      final researcher = _generateMockResearcher(i + 1, category, random);
      researchers.add(researcher);
    }
    
    // Sort based on category
    researchers.sort((a, b) => _compareByCategory(a, b, category));
    
    // Update rankings
    for (int i = 0; i < researchers.length; i++) {
      researchers[i] = researchers[i].copyWith(ranking: i + 1);
    }
    
    return researchers;
  }
  
  /// Get collaboration opportunities for a researcher
  static List<CollaborationOpportunity> getCollaborationOpportunities(ResearcherProfile user) {
    return [
      CollaborationOpportunity(
        id: 'coral_restoration',
        title: 'Global Coral Restoration Initiative',
        description: 'Join marine biologists worldwide in documenting coral bleaching patterns and restoration efforts. This collaborative project aims to create a comprehensive database of coral health across different ocean regions.',
        category: CollaborationType.conservation,
        requirements: [
          'Minimum Level 10',
          '25+ Coral Garden discoveries',
          '10+ research sessions this month'
        ],
        rewards: CollaborationRewards(
          xpBonus: 500,
          specialBadge: 'Coral Guardian',
          exclusiveSpecies: 'Pristine Staghorn Coral'
        ),
        currentParticipants: 847,
        maxParticipants: 1000,
        daysRemaining: 14,
        completionPercentage: 0.847,
        isEligible: user.researchLevel >= 10,
      ),
      CollaborationOpportunity(
        id: 'deep_sea_expedition',
        title: 'Abyssal Zone Research Expedition',
        description: 'Participate in a month-long deep sea research expedition. Document bioluminescent species and contribute to our understanding of life in the deepest ocean trenches.',
        category: CollaborationType.expedition,
        requirements: [
          'Minimum Level 25',
          '5+ Abyssal Zone discoveries',
          'Advanced diving certification'
        ],
        rewards: CollaborationRewards(
          xpBonus: 1000,
          specialBadge: 'Abyss Explorer',
          exclusiveSpecies: 'Phantom Lanternfish'
        ),
        currentParticipants: 156,
        maxParticipants: 200,
        daysRemaining: 28,
        completionPercentage: 0.78,
        isEligible: user.researchLevel >= 25,
      ),
      CollaborationOpportunity(
        id: 'species_documentation',
        title: 'Marine Species Documentation Project',
        description: 'Help create the most comprehensive marine species database ever assembled. Contribute detailed observations and behavioral notes for newly discovered species.',
        category: CollaborationType.documentation,
        requirements: [
          'Minimum Level 5',
          '50+ total discoveries',
          'Research journal active'
        ],
        rewards: CollaborationRewards(
          xpBonus: 300,
          specialBadge: 'Species Cataloger',
          exclusiveSpecies: 'Researcher\'s Notebook Fish'
        ),
        currentParticipants: 2341,
        maxParticipants: 3000,
        daysRemaining: 45,
        completionPercentage: 0.78,
        isEligible: user.researchLevel >= 5,
      ),
      CollaborationOpportunity(
        id: 'mentorship_program',
        title: 'New Researcher Mentorship Program',
        description: 'Guide newcomers to marine biology research. Share your expertise and help build the next generation of ocean explorers.',
        category: CollaborationType.mentorship,
        requirements: [
          'Minimum Level 50',
          '100+ total discoveries',
          '30+ days research streak'
        ],
        rewards: CollaborationRewards(
          xpBonus: 750,
          specialBadge: 'Research Mentor',
          exclusiveSpecies: 'Wisdom Whale'
        ),
        currentParticipants: 89,
        maxParticipants: 150,
        daysRemaining: 60,
        completionPercentage: 0.593,
        isEligible: user.researchLevel >= 50,
      ),
    ];
  }
  
  /// Get community goals
  static List<CommunityGoal> getCommunityGoals() {
    return [
      CommunityGoal(
        id: 'million_discoveries',
        title: 'One Million Species Discoveries',
        description: 'The global research community is working together to reach one million total species discoveries. Every dive session contributes to this monumental goal.',
        currentProgress: 847263,
        targetProgress: 1000000,
        daysRemaining: 89,
        rewards: CommunityRewards(
          globalXpBonus: 1000,
          specialBadge: 'Million Discovery Pioneer',
          exclusiveContent: 'Ancient Ocean Biome Unlock',
          titleUnlock: 'Legendary Ocean Explorer'
        ),
        category: CommunityGoalCategory.discoveries,
      ),
      CommunityGoal(
        id: 'ocean_cleanup',
        title: 'Virtual Ocean Cleanup Initiative',
        description: 'Through focused research sessions, we\'re simulating the positive impact of ocean conservation efforts. Help us reach our monthly conservation goal.',
        currentProgress: 156,
        targetProgress: 500,
        daysRemaining: 23,
        rewards: CommunityRewards(
          globalXpBonus: 500,
          specialBadge: 'Ocean Protector',
          exclusiveContent: 'Clean Ocean Visual Effects',
          titleUnlock: 'Conservation Champion'
        ),
        category: CommunityGoalCategory.conservation,
      ),
      CommunityGoal(
        id: 'research_papers',
        title: 'Collaborative Research Publication',
        description: 'The community is working together to publish research papers based on collective discoveries. Contribute your findings to advance marine science.',
        currentProgress: 78,
        targetProgress: 100,
        daysRemaining: 15,
        rewards: CommunityRewards(
          globalXpBonus: 300,
          specialBadge: 'Co-Author',
          exclusiveContent: 'Academic Journal Interface Theme',
          titleUnlock: 'Published Researcher'
        ),
        category: CommunityGoalCategory.research,
      ),
    ];
  }
  
  static ResearcherProfile _generateMockResearcher(int rank, LeaderboardCategory category, Random random) {
    final names = [
      'Dr. Marina Torres', 'Prof. James Deepwell', 'Dr. Coral Reefson', 'Dr. Abyss Walker',
      'Prof. Kelp Forest', 'Dr. Pearl Diver', 'Dr. Blue Whale', 'Prof. Tide Pool',
      'Dr. Ocean Current', 'Dr. Nautilus Shell', 'Prof. Dolphin Echo', 'Dr. Shark Fin',
      'Dr. Sea Turtle', 'Prof. Plankton Bloom', 'Dr. Seahorse Bay', 'Dr. Jellyfish Drift',
      'Prof. Starfish Point', 'Dr. Lobster Claw', 'Dr. Octopus Garden', 'Prof. Whale Song'
    ];
    
    final specializations = [
      'Deep Sea Biology', 'Coral Reef Ecology', 'Marine Conservation', 'Abyssal Research',
      'Coastal Biology', 'Plankton Studies', 'Marine Genetics', 'Ocean Chemistry',
      'Fish Behavior', 'Marine Botany', 'Invertebrate Studies', 'Whale Research'
    ];
    
    final baseStats = _generateStatsForCategory(category, rank, random);
    
    return ResearcherProfile(
      id: 'researcher_$rank',
      name: names[rank % names.length],
      researchLevel: baseStats['level']!,
      totalDiscoveries: baseStats['discoveries']!,
      currentStreak: baseStats['streak']!,
      researchEfficiency: baseStats['efficiency']! / 10.0,
      weeklyDiscoveries: baseStats['weekly']!,
      legendaryDiscoveries: baseStats['legendary']!,
      specialization: specializations[random.nextInt(specializations.length)],
      joinedDate: DateTime.now().subtract(Duration(days: random.nextInt(365) + 30)),
      lastActiveDate: DateTime.now().subtract(Duration(hours: random.nextInt(24))),
      achievements: random.nextInt(20) + 5,
      publicationsCount: random.nextInt(10) + 1,
      collaborationsCount: random.nextInt(8) + 1,
      ranking: rank,
    );
  }
  
  static Map<String, int> _generateStatsForCategory(LeaderboardCategory category, int rank, Random random) {
    final baseVariation = random.nextInt(20) + 80; // 80-100% of expected value
    
    switch (category) {
      case LeaderboardCategory.totalDiscoveries:
        final baseDiscoveries = 200 - (rank * 8);
        return {
          'discoveries': (baseDiscoveries * baseVariation / 100).floor(),
          'level': random.nextInt(50) + 10,
          'streak': random.nextInt(30) + 1,
          'efficiency': random.nextInt(50) + 50,
          'weekly': random.nextInt(15) + 5,
          'legendary': random.nextInt(5) + 1,
        };
      
      case LeaderboardCategory.researchLevel:
        final baseLevel = 100 - (rank * 3);
        return {
          'level': (baseLevel * baseVariation / 100).floor(),
          'discoveries': random.nextInt(100) + 50,
          'streak': random.nextInt(30) + 1,
          'efficiency': random.nextInt(50) + 50,
          'weekly': random.nextInt(15) + 5,
          'legendary': random.nextInt(5) + 1,
        };
      
      case LeaderboardCategory.currentStreak:
        final baseStreak = 50 - (rank * 2);
        return {
          'streak': (baseStreak * baseVariation / 100).floor(),
          'level': random.nextInt(50) + 10,
          'discoveries': random.nextInt(100) + 50,
          'efficiency': random.nextInt(50) + 50,
          'weekly': random.nextInt(15) + 5,
          'legendary': random.nextInt(5) + 1,
        };
      
      case LeaderboardCategory.researchEfficiency:
        final baseEfficiency = 150 - (rank * 5);
        return {
          'efficiency': (baseEfficiency * baseVariation / 100).floor(),
          'level': random.nextInt(50) + 10,
          'discoveries': random.nextInt(100) + 50,
          'streak': random.nextInt(30) + 1,
          'weekly': random.nextInt(15) + 5,
          'legendary': random.nextInt(5) + 1,
        };
      
      case LeaderboardCategory.weeklyDiscoveries:
        final baseWeekly = 25 - rank;
        return {
          'weekly': (baseWeekly * baseVariation / 100).floor(),
          'level': random.nextInt(50) + 10,
          'discoveries': random.nextInt(100) + 50,
          'streak': random.nextInt(30) + 1,
          'efficiency': random.nextInt(50) + 50,
          'legendary': random.nextInt(5) + 1,
        };
      
      case LeaderboardCategory.legendaryDiscoveries:
        final baseLegendary = 15 - rank;
        return {
          'legendary': (baseLegendary * baseVariation / 100).floor().clamp(0, 15),
          'level': random.nextInt(50) + 10,
          'discoveries': random.nextInt(100) + 50,
          'streak': random.nextInt(30) + 1,
          'efficiency': random.nextInt(50) + 50,
          'weekly': random.nextInt(15) + 5,
        };
    }
  }
  
  static int _compareByCategory(ResearcherProfile a, ResearcherProfile b, LeaderboardCategory category) {
    switch (category) {
      case LeaderboardCategory.totalDiscoveries:
        return b.totalDiscoveries.compareTo(a.totalDiscoveries);
      case LeaderboardCategory.researchLevel:
        return b.researchLevel.compareTo(a.researchLevel);
      case LeaderboardCategory.currentStreak:
        return b.currentStreak.compareTo(a.currentStreak);
      case LeaderboardCategory.researchEfficiency:
        return b.researchEfficiency.compareTo(a.researchEfficiency);
      case LeaderboardCategory.weeklyDiscoveries:
        return b.weeklyDiscoveries.compareTo(a.weeklyDiscoveries);
      case LeaderboardCategory.legendaryDiscoveries:
        return b.legendaryDiscoveries.compareTo(a.legendaryDiscoveries);
    }
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