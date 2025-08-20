import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../persistence_service.dart';

/// Repository for managing marine biology career data
class CareerRepository {
  final PersistenceService _persistence;
  
  CareerRepository(this._persistence);

  // Get career state
  Future<Map<String, dynamic>> getCareerState() async {
    final db = await _persistence.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'marine_career',
      where: 'id = 1',
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    
    // Return default career state
    return {
      'id': 1,
      'career_xp': 0,
      'career_level': 1,
      'career_title': 'Marine Biology Intern',
      'specialization': null,
      'total_discoveries': 0,
      'research_points': 0,
      'papers_published': 0,
      'certifications_earned': '[]',
      'discovery_history': '[]',
    };
  }

  // Save career state
  Future<void> saveCareerState(Map<String, dynamic> state) async {
    final db = await _persistence.database;
    
    state['last_updated'] = DateTime.now().millisecondsSinceEpoch;
    
    await db.insert(
      'marine_career',
      state,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Add career XP
  Future<void> addCareerXP(int xpToAdd) async {
    final state = await getCareerState();
    final currentXP = state['career_xp'] as int;
    final newXP = currentXP + xpToAdd;
    
    // Calculate new level
    final newLevel = _calculateCareerLevel(newXP);
    
    // Update title based on level
    final newTitle = _getCareerTitle(newLevel);
    
    state['career_xp'] = newXP;
    state['career_level'] = newLevel;
    state['career_title'] = newTitle;
    
    await saveCareerState(state);
  }

  // Calculate career level from XP
  int _calculateCareerLevel(int totalXP) {
    // Exponential progression for career levels
    int level = 1;
    int xpRequired = 0;
    
    while (level <= 100) {
      xpRequired = _getXPRequiredForLevel(level + 1);
      if (totalXP < xpRequired) break;
      level++;
    }
    
    return level;
  }

  // Get XP required for a specific level
  int _getXPRequiredForLevel(int level) {
    if (level <= 1) return 0;
    // Exponential growth formula
    return (100 * (level - 1) * 1.15).round() + _getXPRequiredForLevel(level - 1);
  }

  // Get career title based on level
  String _getCareerTitle(int level) {
    if (level >= 100) return 'Master Marine Biologist';
    if (level >= 95) return 'Ocean Pioneer';
    if (level >= 90) return 'Marine Biology Legend';
    if (level >= 85) return 'World-Renowned Expert';
    if (level >= 80) return 'Research Institute Director';
    if (level >= 75) return 'Department Head';
    if (level >= 70) return 'Marine Biology Professor';
    if (level >= 65) return 'Research Director';
    if (level >= 60) return 'Distinguished Researcher';
    if (level >= 55) return 'Marine Biology Expert';
    if (level >= 50) return 'Principal Investigator';
    if (level >= 45) return 'Senior Research Scientist';
    if (level >= 40) return 'Research Scientist';
    if (level >= 35) return 'Senior Marine Biologist';
    if (level >= 30) return 'Marine Biologist';
    if (level >= 25) return 'Field Researcher';
    if (level >= 20) return 'Research Associate';
    if (level >= 15) return 'Marine Biology Student';
    if (level >= 10) return 'Research Assistant';
    if (level >= 5) return 'Junior Research Assistant';
    return 'Marine Biology Intern';
  }

  // Update specialization
  Future<void> updateSpecialization(String specialization) async {
    final state = await getCareerState();
    state['specialization'] = specialization;
    await saveCareerState(state);
  }

  // Increment discovery count
  Future<void> incrementDiscoveries() async {
    final state = await getCareerState();
    state['total_discoveries'] = (state['total_discoveries'] as int) + 1;
    await saveCareerState(state);
  }

  // Add research points
  Future<void> addResearchPoints(int points) async {
    final state = await getCareerState();
    state['research_points'] = (state['research_points'] as int) + points;
    await saveCareerState(state);
  }

  // Increment papers published
  Future<void> incrementPapersPublished() async {
    final state = await getCareerState();
    state['papers_published'] = (state['papers_published'] as int) + 1;
    await saveCareerState(state);
  }

  // Add certification
  Future<void> addCertification(String certificationId) async {
    final state = await getCareerState();
    final certsJson = state['certifications_earned'] as String? ?? '[]';
    final certifications = List<String>.from(jsonDecode(certsJson));
    
    if (!certifications.contains(certificationId)) {
      certifications.add(certificationId);
      state['certifications_earned'] = jsonEncode(certifications);
      await saveCareerState(state);
    }
  }

  // Get certifications
  Future<List<String>> getCertifications() async {
    final state = await getCareerState();
    final certsJson = state['certifications_earned'] as String? ?? '[]';
    return List<String>.from(jsonDecode(certsJson));
  }

  // Add to discovery history
  Future<void> addDiscoveryToHistory(Map<String, dynamic> discovery) async {
    final state = await getCareerState();
    final historyJson = state['discovery_history'] as String? ?? '[]';
    final history = List<Map<String, dynamic>>.from(
      (jsonDecode(historyJson) as List).map((e) => Map<String, dynamic>.from(e))
    );
    
    // Add timestamp to discovery
    discovery['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    
    history.add(discovery);
    
    // Keep only last 100 discoveries
    if (history.length > 100) {
      history.removeRange(0, history.length - 100);
    }
    
    state['discovery_history'] = jsonEncode(history);
    await saveCareerState(state);
  }

  // Get discovery history
  Future<List<Map<String, dynamic>>> getDiscoveryHistory() async {
    final state = await getCareerState();
    final historyJson = state['discovery_history'] as String? ?? '[]';
    return List<Map<String, dynamic>>.from(
      (jsonDecode(historyJson) as List).map((e) => Map<String, dynamic>.from(e))
    );
  }

  // === RESEARCH MILESTONES ===
  
  // Save research milestone
  Future<void> saveResearchMilestone(Map<String, dynamic> milestone) async {
    final db = await _persistence.database;
    
    await db.insert(
      'research_milestones',
      milestone,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all research milestones
  Future<List<Map<String, dynamic>>> getAllResearchMilestones() async {
    final db = await _persistence.database;
    
    return await db.query(
      'research_milestones',
      orderBy: 'category, title',
    );
  }

  // Get achieved milestones
  Future<List<Map<String, dynamic>>> getAchievedMilestones() async {
    final db = await _persistence.database;
    
    return await db.query(
      'research_milestones',
      where: 'achieved = 1',
      orderBy: 'achieved_date DESC',
    );
  }

  // Achieve milestone
  Future<void> achieveMilestone(String milestoneId, {int? xpReward}) async {
    final db = await _persistence.database;
    
    await db.update(
      'research_milestones',
      {
        'achieved': 1,
        'achieved_date': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [milestoneId],
    );
    
    // Add XP if provided
    if (xpReward != null) {
      await addCareerXP(xpReward);
    }
  }

  // Check milestones based on progress
  Future<List<String>> checkAndAchieveMilestones({
    int? totalDiscoveries,
    int? papersPublished,
    int? careerLevel,
    String? specialization,
  }) async {
    final achievedMilestones = <String>[];
    
    // Discovery milestones
    if (totalDiscoveries != null) {
      if (totalDiscoveries >= 1) {
        await _tryAchieveMilestone('first_discovery', achievedMilestones, 50);
      }
      if (totalDiscoveries >= 10) {
        await _tryAchieveMilestone('10_discoveries', achievedMilestones, 100);
      }
      if (totalDiscoveries >= 50) {
        await _tryAchieveMilestone('50_discoveries', achievedMilestones, 250);
      }
      if (totalDiscoveries >= 100) {
        await _tryAchieveMilestone('100_discoveries', achievedMilestones, 500);
      }
      if (totalDiscoveries >= 144) {
        await _tryAchieveMilestone('all_discoveries', achievedMilestones, 1000);
      }
    }
    
    // Paper milestones
    if (papersPublished != null) {
      if (papersPublished >= 1) {
        await _tryAchieveMilestone('first_paper', achievedMilestones, 100);
      }
      if (papersPublished >= 5) {
        await _tryAchieveMilestone('5_papers', achievedMilestones, 250);
      }
      if (papersPublished >= 10) {
        await _tryAchieveMilestone('10_papers', achievedMilestones, 500);
      }
    }
    
    // Career level milestones
    if (careerLevel != null) {
      if (careerLevel >= 10) {
        await _tryAchieveMilestone('level_10_career', achievedMilestones, 150);
      }
      if (careerLevel >= 25) {
        await _tryAchieveMilestone('level_25_career', achievedMilestones, 300);
      }
      if (careerLevel >= 50) {
        await _tryAchieveMilestone('level_50_career', achievedMilestones, 600);
      }
      if (careerLevel >= 75) {
        await _tryAchieveMilestone('level_75_career', achievedMilestones, 900);
      }
      if (careerLevel >= 100) {
        await _tryAchieveMilestone('level_100_career', achievedMilestones, 1500);
      }
    }
    
    // Specialization milestones
    if (specialization != null && specialization.isNotEmpty) {
      await _tryAchieveMilestone('specialization_chosen', achievedMilestones, 100);
    }
    
    return achievedMilestones;
  }

  // Helper to try achieving a milestone
  Future<void> _tryAchieveMilestone(
    String milestoneId,
    List<String> achievedList,
    int xpReward,
  ) async {
    final db = await _persistence.database;
    
    // Check if already achieved
    final existing = await db.query(
      'research_milestones',
      where: 'id = ? AND achieved = 1',
      whereArgs: [milestoneId],
      limit: 1,
    );
    
    if (existing.isEmpty) {
      // Not yet achieved, achieve it now
      await achieveMilestone(milestoneId, xpReward: xpReward);
      achievedList.add(milestoneId);
    }
  }

  // Get career statistics
  Future<Map<String, dynamic>> getCareerStatistics() async {
    final state = await getCareerState();
    final milestones = await getAchievedMilestones();
    
    // Calculate progress to next level
    final currentXP = state['career_xp'] as int;
    final currentLevel = state['career_level'] as int;
    final xpForCurrentLevel = _getXPRequiredForLevel(currentLevel);
    final xpForNextLevel = _getXPRequiredForLevel(currentLevel + 1);
    final xpProgress = currentXP - xpForCurrentLevel;
    final xpNeeded = xpForNextLevel - xpForCurrentLevel;
    
    return {
      'careerXP': currentXP,
      'careerLevel': currentLevel,
      'careerTitle': state['career_title'],
      'specialization': state['specialization'],
      'totalDiscoveries': state['total_discoveries'],
      'researchPoints': state['research_points'],
      'papersPublished': state['papers_published'],
      'certificationsEarned': (jsonDecode(state['certifications_earned'] ?? '[]') as List).length,
      'milestonesAchieved': milestones.length,
      'xpProgress': xpProgress,
      'xpNeeded': xpNeeded,
      'progressPercentage': xpNeeded > 0 ? (xpProgress / xpNeeded * 100).toStringAsFixed(1) : '0.0',
    };
  }

  // Reset career progress
  Future<void> resetCareer() async {
    final db = await _persistence.database;
    
    // Reset career state
    await db.delete('marine_career');
    
    // Reset milestones
    await db.update(
      'research_milestones',
      {
        'achieved': 0,
        'achieved_date': null,
      },
    );
    
    // Insert default career state
    await db.insert('marine_career', {
      'id': 1,
      'career_xp': 0,
      'career_level': 1,
      'career_title': 'Marine Biology Intern',
      'total_discoveries': 0,
      'research_points': 0,
      'papers_published': 0,
      'certifications_earned': '[]',
      'discovery_history': '[]',
      'last_updated': DateTime.now().millisecondsSinceEpoch,
    });
  }
}