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
    // Return empty list - no mock equipment data
    return <ResearchEquipment>[];
  }
  
  /// Calculate total equipment bonuses
  static EquipmentBonuses calculateEquipmentBonuses(List<String> equippedEquipment, int userLevel, List<Creature> discoveredCreatures) {
    // Return empty bonuses - no equipment available
    return const EquipmentBonuses(
      discoveryRateBonus: 0.0,
      sessionXPBonus: 0.0,
      equippedCount: 0,
      availableCount: 0,
      totalCount: 0,
      categoryBonuses: {},
    );
  }
  
  /// Get next equipment unlock
  static ResearchEquipment? getNextUnlock(int userLevel, List<Creature> discoveredCreatures, List<String> unlockedEquipment) {
    // No equipment available to unlock
    return null;
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