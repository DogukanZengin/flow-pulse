import 'package:flutter/material.dart';
import '../models/creature.dart';
import 'persistence/repositories/equipment_repository.dart';

/// Equipment Progression Service for Phase 4
/// Handles marine research equipment unlocks, upgrades, and visual indicators
class EquipmentProgressionService {
  final EquipmentRepository _equipmentRepository;
  
  EquipmentProgressionService(this._equipmentRepository);
  
  /// Get all available equipment based on cumulative RP and discoveries
  Future<List<ResearchEquipment>> getAllEquipment(
    int cumulativeRP,
    List<Creature> discoveredCreatures,
    List<String> unlockedEquipment,
  ) async {
    final equipmentData = await _equipmentRepository.getAllEquipment();
    final List<ResearchEquipment> equipment = [];

    for (final data in equipmentData) {
      // Safely handle nullable integers with proper defaults
      final isUnlocked = ((data['is_unlocked'] as int?) ?? 0) == 1;
      final isEquipped = ((data['is_equipped'] as int?) ?? 0) == 1;

      // Get unlock_rp and calculate level from it
      final unlockRP = (data['unlock_rp'] as int?) ?? 0;
      final unlockLevel = _calculateLevelFromRP(unlockRP);

      equipment.add(ResearchEquipment(
        id: data['id'] as String,
        name: data['name'] as String,
        description: data['description'] as String? ?? '',
        icon: data['icon'] as String? ?? '🔬',
        unlockLevel: unlockLevel,
        category: _parseCategory(data['category'] as String? ?? 'documentation'),
        rarity: _parseRarity(data['rarity'] as String? ?? 'common'),
        benefits: _generateBenefits(data),
        discoveryBonus: (data['discovery_bonus'] as num?)?.toDouble() ?? 0.0,
        sessionBonus: (data['session_bonus'] as num?)?.toDouble() ?? 0.0,
        isUnlocked: isUnlocked,
        isEquipped: isEquipped,
        unlockCondition: 'Reach level $unlockLevel ($unlockRP RP)',
        requiredDiscoveries: (data['required_discoveries'] as int?) ?? 0,
        requiredRareSpecies: (data['required_rare_species'] as int?) ?? 0,
        requiredLegendarySpecies: (data['required_legendary_species'] as int?) ?? 0,
      ));
    }

    return equipment;
  }
  
  /// Calculate total equipment bonuses
  Future<EquipmentBonuses> calculateEquipmentBonuses(List<String> equippedEquipment, int cumulativeRP, List<Creature> discoveredCreatures) async {
    final allEquipment = await _equipmentRepository.getAllEquipment();
    final equippedItems = await _equipmentRepository.getEquippedItems();
    final unlockedItems = await _equipmentRepository.getUnlockedEquipment();
    
    double discoveryBonus = 0.0;
    double sessionBonus = 0.0;
    final Map<EquipmentCategory, double> categoryBonuses = {};
    
    for (final item in equippedItems) {
      discoveryBonus += (item['discovery_bonus'] as num?)?.toDouble() ?? 0.0;
      sessionBonus += (item['session_bonus'] as num?)?.toDouble() ?? 0.0;
      
      final category = _parseCategory(item['category'] as String);
      categoryBonuses[category] = (categoryBonuses[category] ?? 0.0) + 
          ((item['discovery_bonus'] as num?)?.toDouble() ?? 0.0) +
          ((item['session_bonus'] as num?)?.toDouble() ?? 0.0);
    }
    
    return EquipmentBonuses(
      discoveryRateBonus: discoveryBonus,
      sessionXPBonus: sessionBonus,
      equippedCount: equippedItems.length,
      availableCount: unlockedItems.length,
      totalCount: allEquipment.length,
      categoryBonuses: categoryBonuses,
    );
  }
  
  /// Get next equipment unlock
  Future<ResearchEquipment?> getNextUnlock(int cumulativeRP, List<Creature> discoveredCreatures, List<String> unlockedEquipment) async {
    final equipmentData = await _equipmentRepository.getAllEquipment();

    for (final data in equipmentData) {
      final isUnlocked = ((data['is_unlocked'] as int?) ?? 0) == 1;
      final unlockRP = (data['unlock_rp'] as int?) ?? 0;
      final unlockLevel = _calculateLevelFromRP(unlockRP);

      final userLevel = _calculateLevelFromRP(cumulativeRP);
      if (!isUnlocked && unlockLevel <= userLevel + 3) { // Show items up to 3 levels ahead
        return ResearchEquipment(
          id: data['id'] as String,
          name: data['name'] as String,
          description: data['description'] as String? ?? '',
          icon: data['icon'] as String? ?? '🔬',
          unlockLevel: unlockLevel,
          category: _parseCategory(data['category'] as String? ?? 'documentation'),
          rarity: _parseRarity(data['rarity'] as String? ?? 'common'),
          benefits: _generateBenefits(data),
          discoveryBonus: (data['discovery_bonus'] as num?)?.toDouble() ?? 0.0,
          sessionBonus: (data['session_bonus'] as num?)?.toDouble() ?? 0.0,
          isUnlocked: false,
          isEquipped: false,
          unlockCondition: 'Reach level $unlockLevel ($unlockRP RP)',
          requiredDiscoveries: (data['required_discoveries'] as int?) ?? 0,
          requiredRareSpecies: (data['required_rare_species'] as int?) ?? 0,
          requiredLegendarySpecies: (data['required_legendary_species'] as int?) ?? 0,
        );
      }
    }

    return null;
  }
  
  /// Parse equipment category from string
  EquipmentCategory _parseCategory(String categoryStr) {
    switch (categoryStr) {
      case 'breathing': return EquipmentCategory.breathing;
      case 'mobility': return EquipmentCategory.mobility;
      case 'documentation': return EquipmentCategory.documentation;
      case 'visibility': return EquipmentCategory.visibility;
      case 'safety': return EquipmentCategory.safety;
      case 'sampling': return EquipmentCategory.sampling;
      case 'detection': return EquipmentCategory.detection;
      case 'analysis': return EquipmentCategory.analysis;
      case 'platform': return EquipmentCategory.platform;
      case 'communication': return EquipmentCategory.communication;
      case 'conservation': return EquipmentCategory.conservation;
      case 'visualization': return EquipmentCategory.visualization;
      default: return EquipmentCategory.documentation;
    }
  }
  
  /// Parse equipment rarity from string
  EquipmentRarity _parseRarity(String rarityStr) {
    switch (rarityStr) {
      case 'common': return EquipmentRarity.common;
      case 'uncommon': return EquipmentRarity.uncommon;
      case 'rare': return EquipmentRarity.rare;
      case 'epic': return EquipmentRarity.epic;
      case 'legendary': return EquipmentRarity.legendary;
      default: return EquipmentRarity.common;
    }
  }
  
  /// Generate benefits list from equipment data
  List<String> _generateBenefits(Map<String, dynamic> data) {
    final List<String> benefits = [];
    
    final discoveryBonus = (data['discovery_bonus'] as num?)?.toDouble() ?? 0.0;
    final sessionBonus = (data['session_bonus'] as num?)?.toDouble() ?? 0.0;
    
    if (discoveryBonus > 0) {
      benefits.add('+${(discoveryBonus * 100).toInt()}% Species Discovery Rate');
    }
    if (sessionBonus > 0) {
      benefits.add('+${(sessionBonus * 100).toInt()}% Session Experience');
    }
    
    // Add category-specific benefits
    final category = data['category'] as String;
    switch (category) {
      case 'breathing':
        benefits.add('Extended underwater exploration time');
        break;
      case 'mobility':
        benefits.add('Faster underwater movement');
        break;
      case 'documentation':
        benefits.add('Better species documentation');
        break;
      case 'visibility':
        benefits.add('Improved underwater visibility');
        break;
      case 'safety':
        benefits.add('Enhanced safety during exploration');
        break;
      case 'sampling':
        benefits.add('Advanced sample collection');
        break;
      case 'detection':
        benefits.add('Enhanced species detection');
        break;
      case 'analysis':
        benefits.add('Real-time species analysis');
        break;
      case 'platform':
        benefits.add('Mobile research platform');
        break;
      case 'communication':
        benefits.add('Surface communication capabilities');
        break;
      case 'conservation':
        benefits.add('Conservation data collection');
        break;
      case 'visualization':
        benefits.add('Advanced underwater visualization');
        break;
    }
    
    return benefits;
  }

  /// Convert RP to level (same formula as GamificationService)
  int _calculateLevelFromRP(int cumulativeRP) {
    return (cumulativeRP / 50).floor() + 1;
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
  double get completionPercentage => totalCount > 0 ? availableCount / totalCount : 0.0;
  
  /// Get equipped percentage
  double get equippedPercentage => availableCount > 0 ? equippedCount / availableCount : 0.0;
}