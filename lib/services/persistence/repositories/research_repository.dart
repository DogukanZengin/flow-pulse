import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../persistence_service.dart';

/// Repository for managing research papers and certifications
class ResearchRepository {
  final PersistenceService _persistence;
  
  ResearchRepository(this._persistence);

  // === RESEARCH PAPERS ===
  
  // Save research paper
  Future<void> saveResearchPaper(Map<String, dynamic> paper) async {
    final db = await _persistence.database;
    
    await db.insert(
      'research_papers',
      paper,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Save multiple research papers (batch)
  Future<void> saveResearchPapersBatch(List<Map<String, dynamic>> papers) async {
    final db = await _persistence.database;
    final batch = db.batch();
    
    for (final paper in papers) {
      batch.insert(
        'research_papers',
        paper,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  // Get all research papers
  Future<List<Map<String, dynamic>>> getAllResearchPapers() async {
    final db = await _persistence.database;
    
    return await db.query(
      'research_papers',
      orderBy: 'category, title',
    );
  }

  // Get published papers
  Future<List<Map<String, dynamic>>> getPublishedPapers() async {
    final db = await _persistence.database;
    
    return await db.query(
      'research_papers',
      where: 'published = 1',
      orderBy: 'published_date DESC',
    );
  }

  // Get unpublished papers
  Future<List<Map<String, dynamic>>> getUnpublishedPapers() async {
    final db = await _persistence.database;
    
    return await db.query(
      'research_papers',
      where: 'published = 0',
      orderBy: 'required_level, title',
    );
  }

  // Get papers by category
  Future<List<Map<String, dynamic>>> getPapersByCategory(String category) async {
    final db = await _persistence.database;
    
    return await db.query(
      'research_papers',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'published DESC, title',
    );
  }

  // Get papers by biome
  Future<List<Map<String, dynamic>>> getPapersByBiome(String biome) async {
    final db = await _persistence.database;
    
    return await db.query(
      'research_papers',
      where: 'biome = ?',
      whereArgs: [biome],
      orderBy: 'published DESC, title',
    );
  }

  // Get paper by ID
  Future<Map<String, dynamic>?> getPaperById(String id) async {
    final db = await _persistence.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'research_papers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Publish research paper
  Future<void> publishPaper(String paperId, {int? xpReward}) async {
    final db = await _persistence.database;
    
    await db.update(
      'research_papers',
      {
        'published': 1,
        'published_date': DateTime.now().millisecondsSinceEpoch,
        'citations': 0,
        if (xpReward != null) 'xp_reward': xpReward,
      },
      where: 'id = ?',
      whereArgs: [paperId],
    );
  }

  // Add citation to paper
  Future<void> addCitation(String paperId) async {
    final db = await _persistence.database;
    
    // Get current citations
    final paper = await getPaperById(paperId);
    if (paper == null) return;
    
    final currentCitations = paper['citations'] as int? ?? 0;
    
    await db.update(
      'research_papers',
      {'citations': currentCitations + 1},
      where: 'id = ?',
      whereArgs: [paperId],
    );
  }

  // Check papers available for user
  Future<List<Map<String, dynamic>>> getAvailablePapers({
    required int userLevel,
    required List<String> discoveredCreatureIds,
  }) async {
    final db = await _persistence.database;
    
    // Get papers that meet level requirement
    final papers = await db.query(
      'research_papers',
      where: 'published = 0 AND required_level <= ?',
      whereArgs: [userLevel],
    );
    
    // Filter by required discoveries
    final availablePapers = <Map<String, dynamic>>[];
    
    for (final paper in papers) {
      final requiredDiscoveriesJson = paper['required_discoveries'] as String?;
      if (requiredDiscoveriesJson == null || requiredDiscoveriesJson.isEmpty) {
        // No specific discoveries required
        availablePapers.add(paper);
        continue;
      }
      
      final requiredDiscoveries = List<String>.from(jsonDecode(requiredDiscoveriesJson));
      
      // Check if all required discoveries are met
      bool allRequirementsMet = true;
      for (final required in requiredDiscoveries) {
        if (!discoveredCreatureIds.contains(required)) {
          allRequirementsMet = false;
          break;
        }
      }
      
      if (allRequirementsMet) {
        availablePapers.add(paper);
      }
    }
    
    return availablePapers;
  }

  // === RESEARCH CERTIFICATIONS ===
  
  // Save certification
  Future<void> saveCertification(Map<String, dynamic> certification) async {
    final db = await _persistence.database;
    
    await db.insert(
      'research_certifications',
      certification,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all certifications
  Future<List<Map<String, dynamic>>> getAllCertifications() async {
    final db = await _persistence.database;
    
    return await db.query(
      'research_certifications',
      orderBy: 'name',
    );
  }

  // Get earned certifications
  Future<List<Map<String, dynamic>>> getEarnedCertifications() async {
    final db = await _persistence.database;
    
    return await db.query(
      'research_certifications',
      where: 'earned = 1',
      orderBy: 'earned_date DESC',
    );
  }

  // Get unearned certifications
  Future<List<Map<String, dynamic>>> getUnearnedCertifications() async {
    final db = await _persistence.database;
    
    return await db.query(
      'research_certifications',
      where: 'earned = 0',
      orderBy: 'name',
    );
  }

  // Earn certification
  Future<void> earnCertification(String certificationId) async {
    final db = await _persistence.database;
    
    await db.update(
      'research_certifications',
      {
        'earned': 1,
        'earned_date': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [certificationId],
    );
  }

  // Check and earn certifications based on progress
  Future<List<String>> checkAndEarnCertifications({
    required int papersPublished,
    required int totalDiscoveries,
    required int careerLevel,
    Map<String, int>? biomeDiscoveries,
  }) async {
    final earnedCertifications = <String>[];
    
    // Paper-based certifications
    if (papersPublished >= 1) {
      await _tryEarnCertification('first_publication', earnedCertifications);
    }
    if (papersPublished >= 5) {
      await _tryEarnCertification('prolific_researcher', earnedCertifications);
    }
    if (papersPublished >= 10) {
      await _tryEarnCertification('published_author', earnedCertifications);
    }
    
    // Discovery-based certifications
    if (totalDiscoveries >= 25) {
      await _tryEarnCertification('field_researcher', earnedCertifications);
    }
    if (totalDiscoveries >= 50) {
      await _tryEarnCertification('species_expert', earnedCertifications);
    }
    if (totalDiscoveries >= 100) {
      await _tryEarnCertification('biodiversity_specialist', earnedCertifications);
    }
    if (totalDiscoveries >= 144) {
      await _tryEarnCertification('complete_cataloger', earnedCertifications);
    }
    
    // Level-based certifications
    if (careerLevel >= 20) {
      await _tryEarnCertification('certified_biologist', earnedCertifications);
    }
    if (careerLevel >= 40) {
      await _tryEarnCertification('senior_researcher', earnedCertifications);
    }
    if (careerLevel >= 60) {
      await _tryEarnCertification('distinguished_scientist', earnedCertifications);
    }
    if (careerLevel >= 80) {
      await _tryEarnCertification('research_director', earnedCertifications);
    }
    if (careerLevel >= 100) {
      await _tryEarnCertification('master_marine_biologist', earnedCertifications);
    }
    
    // Biome-specific certifications
    if (biomeDiscoveries != null) {
      for (final entry in biomeDiscoveries.entries) {
        final biome = entry.key;
        final count = entry.value;
        
        if (count >= 10) {
          await _tryEarnCertification('${biome}_specialist', earnedCertifications);
        }
        if (count >= 25) {
          await _tryEarnCertification('${biome}_expert', earnedCertifications);
        }
        if (count >= 36) {
          await _tryEarnCertification('${biome}_master', earnedCertifications);
        }
      }
    }
    
    return earnedCertifications;
  }

  // Helper to try earning a certification
  Future<void> _tryEarnCertification(
    String certificationId,
    List<String> earnedList,
  ) async {
    final db = await _persistence.database;
    
    // Check if already earned
    final existing = await db.query(
      'research_certifications',
      where: 'id = ? AND earned = 1',
      whereArgs: [certificationId],
      limit: 1,
    );
    
    if (existing.isEmpty) {
      // Not yet earned, earn it now
      await earnCertification(certificationId);
      earnedList.add(certificationId);
    }
  }

  // === RESEARCH STATISTICS ===
  
  // Get research statistics
  Future<Map<String, dynamic>> getResearchStatistics() async {
    final db = await _persistence.database;
    
    // Total papers
    final totalPapersResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM research_papers'
    );
    final totalPapers = totalPapersResult.first['total'] as int;
    
    // Published papers
    final publishedResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM research_papers WHERE published = 1'
    );
    final publishedPapers = publishedResult.first['total'] as int;
    
    // Total citations
    final citationsResult = await db.rawQuery(
      'SELECT SUM(citations) as total FROM research_papers WHERE published = 1'
    );
    final totalCitations = citationsResult.first['total'] as int? ?? 0;
    
    // Papers by category
    final categoryResult = await db.rawQuery('''
      SELECT category, COUNT(*) as count 
      FROM research_papers 
      WHERE published = 1 
      GROUP BY category
    ''');
    
    final categoryDistribution = <String, int>{};
    for (final row in categoryResult) {
      categoryDistribution[row['category'] as String] = row['count'] as int;
    }
    
    // Total certifications
    final totalCertsResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM research_certifications'
    );
    final totalCertifications = totalCertsResult.first['total'] as int;
    
    // Earned certifications
    final earnedCertsResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM research_certifications WHERE earned = 1'
    );
    final earnedCertifications = earnedCertsResult.first['total'] as int;
    
    // Most cited paper
    Map<String, dynamic>? mostCitedPaper;
    final mostCitedResult = await db.query(
      'research_papers',
      where: 'published = 1 AND citations > 0',
      orderBy: 'citations DESC',
      limit: 1,
    );
    if (mostCitedResult.isNotEmpty) {
      mostCitedPaper = mostCitedResult.first;
    }
    
    return {
      'totalPapers': totalPapers,
      'publishedPapers': publishedPapers,
      'unpublishedPapers': totalPapers - publishedPapers,
      'publishPercentage': totalPapers > 0
          ? (publishedPapers / totalPapers * 100).toStringAsFixed(1)
          : '0.0',
      'totalCitations': totalCitations,
      'avgCitationsPerPaper': publishedPapers > 0
          ? (totalCitations / publishedPapers).toStringAsFixed(1)
          : '0.0',
      'categoryDistribution': categoryDistribution,
      'totalCertifications': totalCertifications,
      'earnedCertifications': earnedCertifications,
      'certificationPercentage': totalCertifications > 0
          ? (earnedCertifications / totalCertifications * 100).toStringAsFixed(1)
          : '0.0',
      'mostCitedPaper': mostCitedPaper,
    };
  }

  // Initialize default research papers
  Future<void> initializeDefaultPapers() async {
    final existingPapers = await getAllResearchPapers();
    if (existingPapers.isNotEmpty) return; // Already initialized
    
    // Define default research papers
    final defaultPapers = [
      {
        'id': 'shallow_waters_survey',
        'title': 'Shallow Waters Biodiversity Survey',
        'category': 'biome_survey',
        'description': 'Document the diverse ecosystem of the shallow waters biome',
        'published': 0,
        'required_level': 5,
        'xp_reward': 200,
        'biome': 'shallow_waters',
        'required_discoveries': '[]',
      },
      {
        'id': 'coral_garden_ecology',
        'title': 'Coral Garden Ecosystem Dynamics',
        'category': 'biome_survey',
        'description': 'Analyze the complex relationships in coral gardens',
        'published': 0,
        'required_level': 15,
        'xp_reward': 350,
        'biome': 'coral_garden',
        'required_discoveries': '[]',
      },
      {
        'id': 'deep_ocean_adaptations',
        'title': 'Deep Ocean Pressure Adaptations',
        'category': 'biome_survey',
        'description': 'Study adaptations to extreme pressure and low light',
        'published': 0,
        'required_level': 25,
        'xp_reward': 500,
        'biome': 'deep_ocean',
        'required_discoveries': '[]',
      },
      {
        'id': 'abyssal_bioluminescence',
        'title': 'Bioluminescence in the Abyssal Zone',
        'category': 'biome_survey',
        'description': 'Investigate bioluminescence in ocean trenches',
        'published': 0,
        'required_level': 40,
        'xp_reward': 750,
        'biome': 'abyssal_zone',
        'required_discoveries': '[]',
      },
    ];
    
    await saveResearchPapersBatch(defaultPapers);
  }

  // Initialize default certifications
  Future<void> initializeDefaultCertifications() async {
    final existingCerts = await getAllCertifications();
    if (existingCerts.isNotEmpty) return; // Already initialized
    
    // Define default certifications
    final defaultCertifications = [
      {
        'id': 'first_publication',
        'name': 'Published Researcher',
        'description': 'Publish your first research paper',
        'earned': 0,
        'requirements': '1 published paper',
        'badge_icon': '📄',
      },
      {
        'id': 'field_researcher',
        'name': 'Field Researcher',
        'description': 'Discover 25 marine species',
        'earned': 0,
        'requirements': '25 discoveries',
        'badge_icon': '🔬',
      },
      {
        'id': 'certified_biologist',
        'name': 'Certified Marine Biologist',
        'description': 'Reach career level 20',
        'earned': 0,
        'requirements': 'Career level 20',
        'badge_icon': '🎓',
      },
      {
        'id': 'species_expert',
        'name': 'Species Expert',
        'description': 'Discover 50 marine species',
        'earned': 0,
        'requirements': '50 discoveries',
        'badge_icon': '🐠',
      },
      {
        'id': 'master_marine_biologist',
        'name': 'Master Marine Biologist',
        'description': 'Reach career level 100',
        'earned': 0,
        'requirements': 'Career level 100',
        'badge_icon': '👨‍🔬',
      },
    ];
    
    for (final cert in defaultCertifications) {
      await saveCertification(cert);
    }
  }

  // Reset research progress
  Future<void> resetResearch() async {
    final db = await _persistence.database;
    
    // Reset papers to unpublished
    await db.update(
      'research_papers',
      {
        'published': 0,
        'published_date': null,
        'citations': 0,
      },
    );
    
    // Reset certifications
    await db.update(
      'research_certifications',
      {
        'earned': 0,
        'earned_date': null,
      },
    );
  }
}