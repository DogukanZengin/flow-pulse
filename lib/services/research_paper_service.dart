import 'package:flutter/material.dart';
import '../models/creature.dart';

/// Research Paper Service - Phase 4 Scientific Documentation System
/// Manages research paper creation, publication, and rewards for marine biology career progression
class ResearchPaperService {
  static final ResearchPaperService _instance = ResearchPaperService._internal();
  ResearchPaperService._internal();
  static ResearchPaperService get instance => _instance;

  /// Get available research papers based on user progress
  static List<ResearchPaper> getAvailablePapers(
    List<Creature> discoveredCreatures,
    int cumulativeRP,
    List<String> publishedPaperIds,
  ) {
    final papers = <ResearchPaper>[];
    
    // Filter discovered creatures by biome
    final shallowWaterCreatures = discoveredCreatures
        .where((c) => c.habitat == BiomeType.shallowWaters)
        .toList();
    final coralGardenCreatures = discoveredCreatures
        .where((c) => c.habitat == BiomeType.coralGarden)
        .toList();
    final deepOceanCreatures = discoveredCreatures
        .where((c) => c.habitat == BiomeType.deepOcean)
        .toList();
    final abyssalCreatures = discoveredCreatures
        .where((c) => c.habitat == BiomeType.abyssalZone)
        .toList();
    
    // Biome-specific papers
    if (shallowWaterCreatures.length >= 5 && cumulativeRP >= 200) { // Level 5 = 200 RP
      papers.add(ResearchPaper(
        id: 'shallow_waters_survey',
        title: 'Shallow Waters Biodiversity Survey',
        description: 'Document the diverse ecosystem of the shallow waters biome, cataloging species interactions and habitat preferences.',
        category: PaperCategory.biomeSurvey,
        biome: BiomeType.shallowWaters,
        requiredLevel: 5,
        requiredDiscoveries: 5,
        requiredSpecies: [],
        researchValue: 100,
        rpReward: 50,
        citations: 0,
        publicationDate: null,
      ));
    }
    
    if (coralGardenCreatures.length >= 10 && cumulativeRP >= 700) { // Level 15 = 700 RP
      papers.add(ResearchPaper(
        id: 'coral_garden_ecology',
        title: 'Coral Garden Ecosystem Dynamics',
        description: 'Analyze the complex relationships between coral species and their inhabitants, documenting symbiotic relationships and growth patterns.',
        category: PaperCategory.biomeSurvey,
        biome: BiomeType.coralGarden,
        requiredLevel: 15,
        requiredDiscoveries: 10,
        requiredSpecies: [],
        researchValue: 150,
        rpReward: 75,
        citations: 0,
        publicationDate: null,
      ));
    }
    
    if (deepOceanCreatures.length >= 8 && cumulativeRP >= 1200) { // Level 25 = 1200 RP
      papers.add(ResearchPaper(
        id: 'deep_ocean_adaptations',
        title: 'Deep Ocean Pressure Adaptations',
        description: 'Study the remarkable adaptations of deep ocean species to extreme pressure and low light conditions.',
        category: PaperCategory.biomeSurvey,
        biome: BiomeType.deepOcean,
        requiredLevel: 25,
        requiredDiscoveries: 8,
        requiredSpecies: [],
        researchValue: 200,
        rpReward: 100,
        citations: 0,
        publicationDate: null,
      ));
    }
    
    if (abyssalCreatures.length >= 5 && cumulativeRP >= 1950) { // Level 40 = 1950 RP
      papers.add(ResearchPaper(
        id: 'abyssal_bioluminescence',
        title: 'Bioluminescence in the Abyssal Zone',
        description: 'Investigate the mechanisms and purposes of bioluminescence in the deepest ocean trenches.',
        category: PaperCategory.biomeSurvey,
        biome: BiomeType.abyssalZone,
        requiredLevel: 40,
        requiredDiscoveries: 5,
        requiredSpecies: [],
        researchValue: 300,
        rpReward: 150,
        citations: 0,
        publicationDate: null,
      ));
    }
    
    // Rarity-based papers
    final commonCount = discoveredCreatures.where((c) => c.rarity == CreatureRarity.common).length;
    final uncommonCount = discoveredCreatures.where((c) => c.rarity == CreatureRarity.uncommon).length;
    final rareCount = discoveredCreatures.where((c) => c.rarity == CreatureRarity.rare).length;
    final legendaryCount = discoveredCreatures.where((c) => c.rarity == CreatureRarity.legendary).length;
    
    if (commonCount >= 20 && cumulativeRP >= 450) { // Level 10 = 450 RP
      papers.add(ResearchPaper(
        id: 'common_species_catalog',
        title: 'Common Marine Species Catalog',
        description: 'Create a comprehensive catalog of frequently encountered marine species and their behaviors.',
        category: PaperCategory.speciesStudy,
        biome: null,
        requiredLevel: 10,
        requiredDiscoveries: 20,
        requiredSpecies: [],
        researchValue: 80,
        rpReward: 30,
        citations: 0,
        publicationDate: null,
      ));
    }
    
    if (uncommonCount >= 10 && cumulativeRP >= 950) { // Level 20 = 950 RP
      papers.add(ResearchPaper(
        id: 'uncommon_species_behavior',
        title: 'Behavioral Patterns of Uncommon Species',
        description: 'Analyze the unique behaviors and habitats of less frequently observed marine life.',
        category: PaperCategory.speciesStudy,
        biome: null,
        requiredLevel: 20,
        requiredDiscoveries: 10,
        requiredSpecies: [],
        researchValue: 120,
        rpReward: 60,
        citations: 0,
        publicationDate: null,
      ));
    }
    
    if (rareCount >= 5 && cumulativeRP >= 1700) { // Level 35 = 1700 RP
      papers.add(ResearchPaper(
        id: 'rare_species_discovery',
        title: 'Rare Species Discovery Report',
        description: 'Document the discovery and characteristics of exceptionally rare marine species.',
        category: PaperCategory.speciesStudy,
        biome: null,
        requiredLevel: 35,
        requiredDiscoveries: 5,
        requiredSpecies: [],
        researchValue: 250,
        rpReward: 125,
        citations: 0,
        publicationDate: null,
      ));
    }
    
    if (legendaryCount >= 1 && cumulativeRP >= 2450) { // Level 50 = 2450 RP
      papers.add(ResearchPaper(
        id: 'legendary_creature_thesis',
        title: 'Legendary Creature Research Thesis',
        description: 'Present groundbreaking research on mythical marine creatures previously thought to be extinct or fictional.',
        category: PaperCategory.speciesStudy,
        biome: null,
        requiredLevel: 50,
        requiredDiscoveries: 1,
        requiredSpecies: [],
        researchValue: 500,
        rpReward: 250,
        citations: 0,
        publicationDate: null,
      ));
    }
    
    // Comparative and special papers
    if (discoveredCreatures.length >= 30 && cumulativeRP >= 1450) { // Level 30 = 1450 RP
      papers.add(ResearchPaper(
        id: 'comparative_marine_biology',
        title: 'Comparative Marine Biology Analysis',
        description: 'Compare and contrast species across different ocean biomes, identifying evolutionary patterns.',
        category: PaperCategory.comparative,
        biome: null,
        requiredLevel: 30,
        requiredDiscoveries: 30,
        requiredSpecies: [],
        researchValue: 180,
        rpReward: 90,
        citations: 0,
        publicationDate: null,
      ));
    }
    
    if (discoveredCreatures.length >= 50 && cumulativeRP >= 2200) { // Level 45 = 2200 RP
      papers.add(ResearchPaper(
        id: 'ocean_biodiversity_report',
        title: 'Comprehensive Ocean Biodiversity Report',
        description: 'Compile extensive research on ocean biodiversity, creating a reference work for future researchers.',
        category: PaperCategory.milestone,
        biome: null,
        requiredLevel: 45,
        requiredDiscoveries: 50,
        requiredSpecies: [],
        researchValue: 350,
        rpReward: 175,
        citations: 0,
        publicationDate: null,
      ));
    }
    
    if (discoveredCreatures.length >= 75 && cumulativeRP >= 2950) { // Level 60 = 2950 RP
      papers.add(ResearchPaper(
        id: 'marine_conservation_thesis',
        title: 'Marine Conservation Strategy Thesis',
        description: 'Develop comprehensive conservation strategies based on extensive species documentation.',
        category: PaperCategory.milestone,
        biome: null,
        requiredLevel: 60,
        requiredDiscoveries: 75,
        requiredSpecies: [],
        researchValue: 450,
        rpReward: 225,
        citations: 0,
        publicationDate: null,
      ));
    }
    
    if (discoveredCreatures.length >= 100 && cumulativeRP >= 3700) { // Level 75 = 3700 RP
      papers.add(ResearchPaper(
        id: 'marine_biology_textbook',
        title: 'Marine Biology Research Textbook',
        description: 'Author a comprehensive textbook based on your extensive marine research experience.',
        category: PaperCategory.milestone,
        biome: null,
        requiredLevel: 75,
        requiredDiscoveries: 100,
        requiredSpecies: [],
        researchValue: 600,
        rpReward: 300,
        citations: 0,
        publicationDate: null,
      ));
    }
    
    if (discoveredCreatures.length >= 144 && cumulativeRP >= 4950) { // Level 100 = 4950 RP
      papers.add(ResearchPaper(
        id: 'complete_ocean_encyclopedia',
        title: 'Complete Ocean Life Encyclopedia',
        description: 'Create the definitive encyclopedia of all discovered ocean life, a magnum opus of marine biology.',
        category: PaperCategory.milestone,
        biome: null,
        requiredLevel: 100,
        requiredDiscoveries: 144,
        requiredSpecies: [],
        researchValue: 1000,
        rpReward: 500,
        citations: 0,
        publicationDate: null,
      ));
    }
    
    // Filter out already published papers
    return papers.where((paper) => !publishedPaperIds.contains(paper.id)).toList();
  }
  
  /// Calculate total research impact from published papers
  static int calculateResearchImpact(List<ResearchPaper> publishedPapers) {
    return publishedPapers.fold(0, (sum, paper) => sum + paper.researchValue + paper.citations);
  }
  
  /// Get researcher title based on published papers
  static String getResearcherTitle(int publishedCount) {
    if (publishedCount >= 20) return 'Distinguished Scholar';
    if (publishedCount >= 15) return 'Senior Researcher';
    if (publishedCount >= 10) return 'Research Fellow';
    if (publishedCount >= 5) return 'Published Researcher';
    if (publishedCount >= 1) return 'Contributing Author';
    return 'Research Assistant';
  }
}

/// Research paper categories
enum PaperCategory {
  biomeSurvey,
  speciesStudy,
  comparative,
  milestone,
}

/// Research paper model
class ResearchPaper {
  final String id;
  final String title;
  final String description;
  final PaperCategory category;
  final BiomeType? biome;
  final int requiredLevel;
  final int requiredDiscoveries;
  final List<String> requiredSpecies;
  final int researchValue;
  final int rpReward;
  int citations;
  DateTime? publicationDate;

  ResearchPaper({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.biome,
    required this.requiredLevel,
    required this.requiredDiscoveries,
    required this.requiredSpecies,
    required this.researchValue,
    required this.rpReward,
    required this.citations,
    this.publicationDate,
  });

  bool get isPublished => publicationDate != null;

  Color get categoryColor {
    switch (category) {
      case PaperCategory.biomeSurvey:
        return Colors.blue;
      case PaperCategory.speciesStudy:
        return Colors.green;
      case PaperCategory.comparative:
        return Colors.purple;
      case PaperCategory.milestone:
        return Colors.orange;
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case PaperCategory.biomeSurvey:
        return Icons.water;
      case PaperCategory.speciesStudy:
        return Icons.pets;
      case PaperCategory.comparative:
        return Icons.compare_arrows;
      case PaperCategory.milestone:
        return Icons.emoji_events;
    }
  }
}