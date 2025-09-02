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
      'career_rp': 0,
      'current_career_rp': 0,
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

  // Add career RP
  Future<void> addCareerRP(int rpToAdd) async {
    final state = await getCareerState();
    final currentRP = state['career_rp'] as int;
    final currentCareerRP = state['current_career_rp'] as int;
    final newRP = currentRP + rpToAdd;
    final newCareerRP = currentCareerRP + rpToAdd;
    
    // Update title based on RP thresholds
    final newTitle = _getCareerTitleFromRP(newCareerRP);
    
    state['career_rp'] = newRP;
    state['current_career_rp'] = newCareerRP;
    state['career_title'] = newTitle;
    
    await saveCareerState(state);
  }

  // Get career title based on RP thresholds
  String _getCareerTitleFromRP(int cumulativeRP) {
    // RP-based career titles as defined in implementation plan
    if (cumulativeRP >= 10500) return 'Master Marine Biologist';
    if (cumulativeRP >= 9500) return 'Ocean Pioneer';
    if (cumulativeRP >= 8550) return 'Marine Biology Legend';
    if (cumulativeRP >= 7650) return 'World-Renowned Expert';
    if (cumulativeRP >= 6800) return 'Research Institute Director';
    if (cumulativeRP >= 6000) return 'Department Head';
    if (cumulativeRP >= 5250) return 'Marine Biology Professor';
    if (cumulativeRP >= 4550) return 'Research Director';
    if (cumulativeRP >= 3900) return 'Distinguished Researcher';
    if (cumulativeRP >= 3300) return 'Marine Biology Expert';
    if (cumulativeRP >= 2750) return 'Principal Investigator';
    if (cumulativeRP >= 2250) return 'Senior Research Scientist';
    if (cumulativeRP >= 1800) return 'Research Scientist';
    if (cumulativeRP >= 1400) return 'Senior Marine Biologist';
    if (cumulativeRP >= 1050) return 'Marine Biologist';
    if (cumulativeRP >= 750) return 'Field Researcher';
    if (cumulativeRP >= 500) return 'Research Associate';
    if (cumulativeRP >= 300) return 'Marine Biology Student';
    if (cumulativeRP >= 150) return 'Research Assistant';
    if (cumulativeRP >= 50) return 'Junior Research Assistant';
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
  Future<void> achieveMilestone(String milestoneId, {int? rpReward}) async {
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
    
    // Add RP if provided
    if (rpReward != null) {
      await addCareerRP(rpReward);
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
    int rpReward,
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
      await achieveMilestone(milestoneId, rpReward: rpReward);
      achievedList.add(milestoneId);
    }
  }

  // Get career statistics
  Future<Map<String, dynamic>> getCareerStatistics() async {
    final state = await getCareerState();
    final milestones = await getAchievedMilestones();
    
    // Get career progression based on RP
    final currentRP = state['career_rp'] as int;
    final currentCareerRP = state['current_career_rp'] as int;
    final nextRPMilestone = _getNextRPMilestone(currentCareerRP);
    final rpProgress = currentCareerRP;
    final rpNeeded = nextRPMilestone > 0 ? nextRPMilestone - currentCareerRP : 0;
    
    return {
      'careerRP': currentRP,
      'currentCareerRP': currentCareerRP,
      'careerTitle': state['career_title'],
      'specialization': state['specialization'],
      'totalDiscoveries': state['total_discoveries'],
      'researchPoints': state['research_points'],
      'papersPublished': state['papers_published'],
      'certificationsEarned': (jsonDecode(state['certifications_earned'] ?? '[]') as List).length,
      'milestonesAchieved': milestones.length,
      'rpProgress': rpProgress,
      'rpNeeded': rpNeeded,
      'nextTitle': nextRPMilestone > 0 ? _getCareerTitleFromRP(nextRPMilestone) : 'Max Level',
      'progressPercentage': rpNeeded > 0 ? (rpProgress / nextRPMilestone * 100).toStringAsFixed(1) : '100.0',
    };
  }
  
  // Get next RP milestone for career progression
  int _getNextRPMilestone(int currentRP) {
    final milestones = [50, 150, 300, 500, 750, 1050, 1400, 1800, 2250, 2750, 3300, 3900, 4550, 5250, 6000, 6800, 7650, 8550, 9500, 10500];
    for (final milestone in milestones) {
      if (currentRP < milestone) return milestone;
    }
    return 0; // Max level reached
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
      'career_rp': 0,
      'current_career_rp': 0,
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