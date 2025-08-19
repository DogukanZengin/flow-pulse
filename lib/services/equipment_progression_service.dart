import 'package:flutter/material.dart';
import '../models/creature.dart';

/// Equipment Progression Service for Phase 4
/// Handles marine research equipment unlocks, upgrades, and visual indicators
class EquipmentProgressionService {
  
  /// Get all available equipment based on user level and discoveries
  static List<ResearchEquipment> getAllEquipment(
    int userLevel,
    List<Creature> discoveredCreatures,
    List<String> unlockedEquipment,
  ) {
    final equipment = <ResearchEquipment>[];
    
    // Basic Equipment (Levels 1-25)
    equipment.addAll(_getBasicEquipment(userLevel, unlockedEquipment));
    
    // Intermediate Equipment (Levels 26-50)
    equipment.addAll(_getIntermediateEquipment(userLevel, discoveredCreatures, unlockedEquipment));
    
    // Advanced Equipment (Levels 51-75)
    equipment.addAll(_getAdvancedEquipment(userLevel, discoveredCreatures, unlockedEquipment));
    
    // Master Equipment (Levels 76-100)
    equipment.addAll(_getMasterEquipment(userLevel, discoveredCreatures, unlockedEquipment));
    
    // Sort by unlock level
    equipment.sort((a, b) => a.unlockLevel.compareTo(b.unlockLevel));
    
    return equipment;
  }
  
  /// Basic Equipment (Snorkeling to Open Water Diver)
  static List<ResearchEquipment> _getBasicEquipment(
    int userLevel,
    List<String> unlockedEquipment,
  ) {
    return [
      ResearchEquipment(
        id: 'mask_snorkel',
        name: 'Mask & Snorkel',
        description: 'Basic underwater vision for shallow water research',
        icon: '🤿',
        unlockLevel: 1,
        category: EquipmentCategory.breathing,
        rarity: EquipmentRarity.common,
        benefits: ['Basic underwater vision', 'Surface breathing'],
        discoveryBonus: 0.0,
        sessionBonus: 0.0,
        isUnlocked: userLevel >= 1,
        isEquipped: unlockedEquipment.contains('mask_snorkel'),
        unlockCondition: 'Start your marine research journey',
      ),
      
      ResearchEquipment(
        id: 'diving_fins',
        name: 'Diving Fins',
        description: 'Improved movement speed underwater',
        icon: '🦶',
        unlockLevel: 3,
        category: EquipmentCategory.mobility,
        rarity: EquipmentRarity.common,
        benefits: ['25% faster movement', 'Less energy consumption'],
        discoveryBonus: 0.05,
        sessionBonus: 0.0,
        isUnlocked: userLevel >= 3,
        isEquipped: unlockedEquipment.contains('diving_fins'),
        unlockCondition: 'Reach level 3 marine researcher',
      ),
      
      ResearchEquipment(
        id: 'waterproof_notebook',
        name: 'Waterproof Research Notebook',
        description: 'Manual species logging and observation notes',
        icon: '📓',
        unlockLevel: 5,
        category: EquipmentCategory.documentation,
        rarity: EquipmentRarity.common,
        benefits: ['Species documentation', 'Observation tracking'],
        discoveryBonus: 0.0,
        sessionBonus: 0.1,
        isUnlocked: userLevel >= 5,
        isEquipped: unlockedEquipment.contains('waterproof_notebook'),
        unlockCondition: 'Reach level 5 research assistant',
      ),
      
      ResearchEquipment(
        id: 'basic_camera',
        name: 'Basic Underwater Camera',
        description: 'Document species discoveries with photos',
        icon: '📷',
        unlockLevel: 8,
        category: EquipmentCategory.documentation,
        rarity: EquipmentRarity.common,
        benefits: ['Photo documentation', '+10% discovery verification'],
        discoveryBonus: 0.1,
        sessionBonus: 0.05,
        isUnlocked: userLevel >= 8,
        isEquipped: unlockedEquipment.contains('basic_camera'),
        unlockCondition: 'Reach level 8 marine student',
      ),
      
      ResearchEquipment(
        id: 'scuba_gear',
        name: 'Scuba Diving Gear',
        description: 'Full scuba equipment for extended underwater research',
        icon: '🤿',
        unlockLevel: 10,
        category: EquipmentCategory.breathing,
        rarity: EquipmentRarity.uncommon,
        benefits: ['Extended dive times', 'Access to 20m depth', 'Oxygen supply management'],
        discoveryBonus: 0.15,
        sessionBonus: 0.2,
        isUnlocked: userLevel >= 10,
        isEquipped: unlockedEquipment.contains('scuba_gear'),
        unlockCondition: 'Reach level 10 open water diver',
      ),
      
      ResearchEquipment(
        id: 'underwater_lights',
        name: 'Underwater LED Lights',
        description: 'Illuminate dark depths and hidden creatures',
        icon: '💡',
        unlockLevel: 15,
        category: EquipmentCategory.visibility,
        rarity: EquipmentRarity.uncommon,
        benefits: ['See in darker depths', '+20% deep water discovery rate'],
        discoveryBonus: 0.2,
        sessionBonus: 0.0,
        isUnlocked: userLevel >= 15,
        isEquipped: unlockedEquipment.contains('underwater_lights'),
        unlockCondition: 'Reach level 15 field researcher',
      ),
      
      ResearchEquipment(
        id: 'dive_computer',
        name: 'Advanced Dive Computer',
        description: 'Accurate depth, time, and decompression tracking',
        icon: '⌚',
        unlockLevel: 20,
        category: EquipmentCategory.safety,
        rarity: EquipmentRarity.uncommon,
        benefits: ['Precise depth tracking', 'Safety monitoring', '+15% session efficiency'],
        discoveryBonus: 0.1,
        sessionBonus: 0.15,
        isUnlocked: userLevel >= 20,
        isEquipped: unlockedEquipment.contains('dive_computer'),
        unlockCondition: 'Reach level 20 marine biologist',
      ),
      
      ResearchEquipment(
        id: 'sample_kit',
        name: 'Sample Collection Kit',
        description: 'Collect water and biological samples for analysis',
        icon: '🧪',
        unlockLevel: 25,
        category: EquipmentCategory.sampling,
        rarity: EquipmentRarity.uncommon,
        benefits: ['Sample collection', 'Water quality testing', '+25% research value'],
        discoveryBonus: 0.0,
        sessionBonus: 0.25,
        isUnlocked: userLevel >= 25,
        isEquipped: unlockedEquipment.contains('sample_kit'),
        unlockCondition: 'Reach level 25 senior marine biologist',
      ),
    ];
  }
  
  /// Intermediate Equipment (Deep Water Research)
  static List<ResearchEquipment> _getIntermediateEquipment(
    int userLevel,
    List<Creature> discoveredCreatures,
    List<String> unlockedEquipment,
  ) {
    return [
      ResearchEquipment(
        id: 'technical_gear',
        name: 'Technical Diving Equipment',
        description: 'Advanced gear for extreme depth exploration',
        icon: '🎯',
        unlockLevel: 30,
        category: EquipmentCategory.breathing,
        rarity: EquipmentRarity.rare,
        benefits: ['Access to 40m depth', 'Extended bottom time', 'Mixed gas support'],
        discoveryBonus: 0.3,
        sessionBonus: 0.2,
        isUnlocked: userLevel >= 30,
        isEquipped: unlockedEquipment.contains('technical_gear'),
        unlockCondition: 'Reach level 30 research scientist',
        requiredDiscoveries: 25,
      ),
      
      ResearchEquipment(
        id: 'sonar_system',
        name: 'Portable Sonar System',
        description: 'Detect creatures before visual contact',
        icon: '📡',
        unlockLevel: 35,
        category: EquipmentCategory.detection,
        rarity: EquipmentRarity.rare,
        benefits: ['Early creature detection', '+40% rare species detection', 'Terrain mapping'],
        discoveryBonus: 0.4,
        sessionBonus: 0.1,
        isUnlocked: userLevel >= 35 && discoveredCreatures.length >= 30,
        isEquipped: unlockedEquipment.contains('sonar_system'),
        unlockCondition: 'Level 35 + 30 species discovered',
        requiredDiscoveries: 30,
      ),
      
      ResearchEquipment(
        id: 'rov_companion',
        name: 'ROV Companion Drone',
        description: 'Remote operated vehicle for dangerous areas',
        icon: '🤖',
        unlockLevel: 40,
        category: EquipmentCategory.safety,
        rarity: EquipmentRarity.rare,
        benefits: ['Remote exploration', 'Hazardous area access', 'Extended range'],
        discoveryBonus: 0.25,
        sessionBonus: 0.3,
        isUnlocked: userLevel >= 40,
        isEquipped: unlockedEquipment.contains('rov_companion'),
        unlockCondition: 'Reach level 40 principal investigator',
        requiredDiscoveries: 40,
      ),
      
      ResearchEquipment(
        id: 'portable_lab',
        name: 'Portable Laboratory',
        description: 'Field analysis of specimens and water samples',
        icon: '🔬',
        unlockLevel: 45,
        category: EquipmentCategory.analysis,
        rarity: EquipmentRarity.rare,
        benefits: ['Immediate sample analysis', '+50% research value', 'Field experiments'],
        discoveryBonus: 0.15,
        sessionBonus: 0.5,
        isUnlocked: userLevel >= 45 && discoveredCreatures.length >= 50,
        isEquipped: unlockedEquipment.contains('portable_lab'),
        unlockCondition: 'Level 45 + 50 species discovered',
        requiredDiscoveries: 50,
      ),
      
      ResearchEquipment(
        id: 'research_vessel',
        name: 'Mobile Research Vessel',
        description: 'Floating laboratory platform with full facilities',
        icon: '🛥️',
        unlockLevel: 50,
        category: EquipmentCategory.platform,
        rarity: EquipmentRarity.epic,
        benefits: ['Mobile base of operations', 'Extended expeditions', 'Team research'],
        discoveryBonus: 0.2,
        sessionBonus: 0.4,
        isUnlocked: userLevel >= 50,
        isEquipped: unlockedEquipment.contains('research_vessel'),
        unlockCondition: 'Reach level 50 marine biology expert',
        requiredDiscoveries: 60,
      ),
    ];
  }
  
  /// Advanced Equipment (Expert Researcher)
  static List<ResearchEquipment> _getAdvancedEquipment(
    int userLevel,
    List<Creature> discoveredCreatures,
    List<String> unlockedEquipment,
  ) {
    final rareSpecies = discoveredCreatures.where((c) => c.rarity == CreatureRarity.rare).length;
    
    return [
      ResearchEquipment(
        id: 'research_submersible',
        name: 'Research Submersible',
        description: 'Deep abyss exploration vehicle',
        icon: '🚤',
        unlockLevel: 60,
        category: EquipmentCategory.platform,
        rarity: EquipmentRarity.epic,
        benefits: ['Unlimited depth access', 'Pressure protection', 'Abyssal zone exploration'],
        discoveryBonus: 0.5,
        sessionBonus: 0.3,
        isUnlocked: userLevel >= 60 && discoveredCreatures.length >= 75,
        isEquipped: unlockedEquipment.contains('research_submersible'),
        unlockCondition: 'Level 60 + 75 species discovered',
        requiredDiscoveries: 75,
      ),
      
      ResearchEquipment(
        id: 'genetic_sequencer',
        name: 'Genetic Sequencing Lab',
        description: 'DNA analysis capabilities for species identification',
        icon: '🧬',
        unlockLevel: 65,
        category: EquipmentCategory.analysis,
        rarity: EquipmentRarity.epic,
        benefits: ['Genetic analysis', 'Species relationship mapping', '+100% research value'],
        discoveryBonus: 0.2,
        sessionBonus: 1.0,
        isUnlocked: userLevel >= 65 && rareSpecies >= 5,
        isEquipped: unlockedEquipment.contains('genetic_sequencer'),
        unlockCondition: 'Level 65 + 5 rare species discovered',
        requiredDiscoveries: 80,
        requiredRareSpecies: 5,
      ),
      
      ResearchEquipment(
        id: 'satellite_comm',
        name: 'Satellite Communication System',
        description: 'Real-time data sharing with global research network',
        icon: '🛰️',
        unlockLevel: 70,
        category: EquipmentCategory.communication,
        rarity: EquipmentRarity.epic,
        benefits: ['Global collaboration', 'Real-time data sharing', 'Research network access'],
        discoveryBonus: 0.3,
        sessionBonus: 0.6,
        isUnlocked: userLevel >= 70,
        isEquipped: unlockedEquipment.contains('satellite_comm'),
        unlockCondition: 'Reach level 70 research director',
        requiredDiscoveries: 90,
      ),
      
      ResearchEquipment(
        id: 'conservation_center',
        name: 'Marine Conservation Center',
        description: 'Species rehabilitation and breeding facility',
        icon: '🏥',
        unlockLevel: 75,
        category: EquipmentCategory.conservation,
        rarity: EquipmentRarity.legendary,
        benefits: ['Species rehabilitation', 'Breeding programs', 'Conservation research'],
        discoveryBonus: 0.25,
        sessionBonus: 0.75,
        isUnlocked: userLevel >= 75 && discoveredCreatures.length >= 100,
        isEquipped: unlockedEquipment.contains('conservation_center'),
        unlockCondition: 'Level 75 + 100 species discovered',
        requiredDiscoveries: 100,
      ),
    ];
  }
  
  /// Master Equipment (Ocean Explorer Legend)
  static List<ResearchEquipment> _getMasterEquipment(
    int userLevel,
    List<Creature> discoveredCreatures,
    List<String> unlockedEquipment,
  ) {
    final legendarySpecies = discoveredCreatures.where((c) => c.rarity == CreatureRarity.legendary).length;
    
    return [
      ResearchEquipment(
        id: 'ai_research_assistant',
        name: 'AI Research Assistant',
        description: 'Artificial intelligence for predictive creature modeling',
        icon: '🤖',
        unlockLevel: 80,
        category: EquipmentCategory.analysis,
        rarity: EquipmentRarity.legendary,
        benefits: ['Predictive modeling', 'Pattern recognition', '+200% research efficiency'],
        discoveryBonus: 0.6,
        sessionBonus: 2.0,
        isUnlocked: userLevel >= 80 && discoveredCreatures.length >= 110,
        isEquipped: unlockedEquipment.contains('ai_research_assistant'),
        unlockCondition: 'Level 80 + 110 species discovered',
        requiredDiscoveries: 110,
      ),
      
      ResearchEquipment(
        id: 'holographic_display',
        name: 'Holographic Species Display',
        description: '3D species visualization and interaction system',
        icon: '👁️',
        unlockLevel: 85,
        category: EquipmentCategory.visualization,
        rarity: EquipmentRarity.legendary,
        benefits: ['3D species modeling', 'Interactive displays', 'Educational presentations'],
        discoveryBonus: 0.4,
        sessionBonus: 1.5,
        isUnlocked: userLevel >= 85 && legendarySpecies >= 1,
        isEquipped: unlockedEquipment.contains('holographic_display'),
        unlockCondition: 'Level 85 + 1 legendary species discovered',
        requiredDiscoveries: 120,
        requiredLegendarySpecies: 1,
      ),
      
      ResearchEquipment(
        id: 'temporal_camera',
        name: 'Time-lapse Photography System',
        description: 'Long-term behavior studies and environmental monitoring',
        icon: '⏰',
        unlockLevel: 90,
        category: EquipmentCategory.documentation,
        rarity: EquipmentRarity.legendary,
        benefits: ['Behavioral analysis', 'Environmental monitoring', 'Long-term studies'],
        discoveryBonus: 0.3,
        sessionBonus: 1.2,
        isUnlocked: userLevel >= 90,
        isEquipped: unlockedEquipment.contains('temporal_camera'),
        unlockCondition: 'Reach level 90 ocean pioneer',
        requiredDiscoveries: 130,
      ),
      
      ResearchEquipment(
        id: 'quantum_scanner',
        name: 'Quantum Species Scanner',
        description: 'Advanced detection of mythical and rare creatures',
        icon: '🌟',
        unlockLevel: 95,
        category: EquipmentCategory.detection,
        rarity: EquipmentRarity.legendary,
        benefits: ['Mythical creature detection', '+500% legendary spawn rate', 'Quantum entanglement tracking'],
        discoveryBonus: 2.0,
        sessionBonus: 0.8,
        isUnlocked: userLevel >= 95 && legendarySpecies >= 2,
        isEquipped: unlockedEquipment.contains('quantum_scanner'),
        unlockCondition: 'Level 95 + 2 legendary species discovered',
        requiredDiscoveries: 140,
        requiredLegendarySpecies: 2,
      ),
      
      ResearchEquipment(
        id: 'global_research_network',
        name: 'Global Marine Research Network',
        description: 'Ultimate collaboration system connecting all marine researchers',
        icon: '🌐',
        unlockLevel: 100,
        category: EquipmentCategory.communication,
        rarity: EquipmentRarity.legendary,
        benefits: ['Global collaboration', 'Shared discoveries', 'Master researcher status'],
        discoveryBonus: 1.0,
        sessionBonus: 3.0,
        isUnlocked: userLevel >= 100 && discoveredCreatures.length >= 144,
        isEquipped: unlockedEquipment.contains('global_research_network'),
        unlockCondition: 'Level 100 + All species discovered',
        requiredDiscoveries: 144,
      ),
    ];
  }
  
  /// Calculate total equipment bonuses
  static EquipmentBonuses calculateEquipmentBonuses(List<String> equippedEquipment, int userLevel, List<Creature> discoveredCreatures) {
    final allEquipment = getAllEquipment(userLevel, discoveredCreatures, equippedEquipment);
    final equipped = allEquipment.where((e) => e.isEquipped).toList();
    
    double totalDiscoveryBonus = 0.0;
    double totalSessionBonus = 0.0;
    
    for (final equipment in equipped) {
      totalDiscoveryBonus += equipment.discoveryBonus;
      totalSessionBonus += equipment.sessionBonus;
    }
    
    return EquipmentBonuses(
      discoveryRateBonus: totalDiscoveryBonus,
      sessionXPBonus: totalSessionBonus,
      equippedCount: equipped.length,
      availableCount: allEquipment.where((e) => e.isUnlocked).length,
      totalCount: allEquipment.length,
      categoryBonuses: _calculateCategoryBonuses(equipped),
    );
  }
  
  /// Calculate bonuses by equipment category
  static Map<EquipmentCategory, double> _calculateCategoryBonuses(List<ResearchEquipment> equipped) {
    final categoryBonuses = <EquipmentCategory, double>{};
    
    for (final equipment in equipped) {
      categoryBonuses[equipment.category] = 
          (categoryBonuses[equipment.category] ?? 0.0) + equipment.discoveryBonus + equipment.sessionBonus;
    }
    
    return categoryBonuses;
  }
  
  /// Get next equipment unlock
  static ResearchEquipment? getNextUnlock(int userLevel, List<Creature> discoveredCreatures, List<String> unlockedEquipment) {
    final allEquipment = getAllEquipment(userLevel, discoveredCreatures, unlockedEquipment);
    
    return allEquipment
        .where((e) => !e.isUnlocked)
        .toList()
        .isNotEmpty 
            ? allEquipment.where((e) => !e.isUnlocked).first
            : null;
  }
}

/// Research Equipment Model
class ResearchEquipment {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int unlockLevel;
  final EquipmentCategory category;
  final EquipmentRarity rarity;
  final List<String> benefits;
  final double discoveryBonus;
  final double sessionBonus;
  final bool isUnlocked;
  final bool isEquipped;
  final String unlockCondition;
  final int requiredDiscoveries;
  final int requiredRareSpecies;
  final int requiredLegendarySpecies;

  const ResearchEquipment({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.unlockLevel,
    required this.category,
    required this.rarity,
    required this.benefits,
    required this.discoveryBonus,
    required this.sessionBonus,
    required this.isUnlocked,
    required this.isEquipped,
    required this.unlockCondition,
    this.requiredDiscoveries = 0,
    this.requiredRareSpecies = 0,
    this.requiredLegendarySpecies = 0,
  });
  
  /// Get rarity color
  Color get rarityColor {
    switch (rarity) {
      case EquipmentRarity.common:
        return Colors.grey;
      case EquipmentRarity.uncommon:
        return Colors.green;
      case EquipmentRarity.rare:
        return Colors.blue;
      case EquipmentRarity.epic:
        return Colors.purple;
      case EquipmentRarity.legendary:
        return Colors.amber;
    }
  }
  
  /// Get category color
  Color get categoryColor {
    switch (category) {
      case EquipmentCategory.breathing:
        return Colors.cyan;
      case EquipmentCategory.mobility:
        return Colors.green;
      case EquipmentCategory.documentation:
        return Colors.orange;
      case EquipmentCategory.visibility:
        return Colors.yellow;
      case EquipmentCategory.safety:
        return Colors.red;
      case EquipmentCategory.sampling:
        return Colors.purple;
      case EquipmentCategory.detection:
        return Colors.pink;
      case EquipmentCategory.analysis:
        return Colors.indigo;
      case EquipmentCategory.platform:
        return Colors.brown;
      case EquipmentCategory.communication:
        return Colors.teal;
      case EquipmentCategory.conservation:
        return Colors.lightGreen;
      case EquipmentCategory.visualization:
        return Colors.deepOrange;
    }
  }
}

/// Equipment Categories
enum EquipmentCategory {
  breathing,
  mobility,
  documentation,
  visibility,
  safety,
  sampling,
  detection,
  analysis,
  platform,
  communication,
  conservation,
  visualization,
}

extension EquipmentCategoryExtension on EquipmentCategory {
  String get displayName {
    switch (this) {
      case EquipmentCategory.breathing:
        return 'Breathing Systems';
      case EquipmentCategory.mobility:
        return 'Mobility Equipment';
      case EquipmentCategory.documentation:
        return 'Documentation Tools';
      case EquipmentCategory.visibility:
        return 'Visibility Enhancement';
      case EquipmentCategory.safety:
        return 'Safety Equipment';
      case EquipmentCategory.sampling:
        return 'Sample Collection';
      case EquipmentCategory.detection:
        return 'Detection Systems';
      case EquipmentCategory.analysis:
        return 'Analysis Equipment';
      case EquipmentCategory.platform:
        return 'Research Platforms';
      case EquipmentCategory.communication:
        return 'Communication Systems';
      case EquipmentCategory.conservation:
        return 'Conservation Tools';
      case EquipmentCategory.visualization:
        return 'Visualization Systems';
    }
  }
}

/// Equipment Rarity Levels
enum EquipmentRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

extension EquipmentRarityExtension on EquipmentRarity {
  String get displayName {
    switch (this) {
      case EquipmentRarity.common:
        return 'Common';
      case EquipmentRarity.uncommon:
        return 'Uncommon';
      case EquipmentRarity.rare:
        return 'Rare';
      case EquipmentRarity.epic:
        return 'Epic';
      case EquipmentRarity.legendary:
        return 'Legendary';
    }
  }
}

/// Equipment Bonuses Summary
class EquipmentBonuses {
  final double discoveryRateBonus;
  final double sessionXPBonus;
  final int equippedCount;
  final int availableCount;
  final int totalCount;
  final Map<EquipmentCategory, double> categoryBonuses;

  const EquipmentBonuses({
    required this.discoveryRateBonus,
    required this.sessionXPBonus,
    required this.equippedCount,
    required this.availableCount,
    required this.totalCount,
    required this.categoryBonuses,
  });
  
  /// Get equipment completion percentage
  double get completionPercentage => availableCount / totalCount;
  
  /// Get equipped percentage
  double get equippedPercentage => equippedCount / availableCount;
}