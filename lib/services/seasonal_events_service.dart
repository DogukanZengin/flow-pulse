import 'dart:math' as math;

import '../models/creature.dart';

/// Seasonal Events Service - Phase 5 Implementation
/// Provides time-based special encounters and seasonal creature appearances
class SeasonalEventsService {
  static SeasonalEventsService? _instance;
  static SeasonalEventsService get instance => _instance ??= SeasonalEventsService._();
  
  SeasonalEventsService._();
  
  /// Get current active seasonal events
  List<SeasonalEvent> getCurrentEvents() {
    final now = DateTime.now();
    final events = <SeasonalEvent>[];
    
    // Monthly Migration Events
    final monthlyEvent = _getMonthlyMigrationEvent(now);
    if (monthlyEvent != null) {
      events.add(monthlyEvent);
    }
    
    // Weekly Special Encounters
    final weeklyEvent = _getWeeklySpecialEvent(now);
    if (weeklyEvent != null) {
      events.add(weeklyEvent);
    }
    
    // Daily Tide Events
    final dailyEvent = _getDailyTideEvent(now);
    if (dailyEvent != null) {
      events.add(dailyEvent);
    }
    
    return events;
  }
  
  /// Check if a specific creature is available due to seasonal events
  bool isSeasonalCreatureAvailable(String creatureId) {
    final activeEvents = getCurrentEvents();
    
    for (final event in activeEvents) {
      if (event.availableCreatures.contains(creatureId)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Get seasonal discovery bonus multiplier
  double getSeasonalDiscoveryBonus(BiomeType biome) {
    final activeEvents = getCurrentEvents();
    double bonus = 1.0;
    
    for (final event in activeEvents) {
      if (event.bonusBiomes.contains(biome)) {
        bonus *= event.discoveryMultiplier;
      }
    }
    
    return bonus;
  }
  
  /// Get special encounter chance for current session
  double getSpecialEncounterChance() {
    final activeEvents = getCurrentEvents();
    double baseChance = 0.05; // 5% base special encounter chance
    
    for (final event in activeEvents) {
      if (event.type == SeasonalEventType.specialEncounter) {
        baseChance += event.specialEncounterBonus;
      }
    }
    
    return math.min(baseChance, 0.25); // Cap at 25%
  }
  
  /// Monthly migration events based on calendar month
  SeasonalEvent? _getMonthlyMigrationEvent(DateTime now) {
    switch (now.month) {
      case 1: // January - Deep Water Whale Migration
        return SeasonalEvent(
          id: 'whale_migration_jan',
          name: 'Winter Whale Migration',
          description: 'Humpback whales migrate through deep waters. 2x chance of legendary creatures in Deep Ocean biome.',
          type: SeasonalEventType.migration,
          startDate: DateTime(now.year, 1, 1),
          endDate: DateTime(now.year, 1, 31),
          bonusBiomes: [BiomeType.deepOcean],
          discoveryMultiplier: 2.0,
          availableCreatures: ['do_leg_001'], // Whale Shark or special whale
          iconName: 'whale',
          rarity: EventRarity.epic,
        );
        
      case 2: // February - Coral Spawning Season
        return SeasonalEvent(
          id: 'coral_spawning_feb',
          name: 'Coral Spawning Season',
          description: 'Annual coral reproduction event. Enhanced coral growth and 50% discovery bonus in Coral Gardens.',
          type: SeasonalEventType.breeding,
          startDate: DateTime(now.year, 2, 1),
          endDate: DateTime(now.year, 2, 28),
          bonusBiomes: [BiomeType.coralGarden],
          discoveryMultiplier: 1.5,
          availableCreatures: ['cg_rare_001', 'cg_rare_002'], // Special coral fish
          iconName: 'coral_spawning',
          rarity: EventRarity.rare,
        );
        
      case 3: // March - Spring Plankton Bloom
        return SeasonalEvent(
          id: 'plankton_bloom_mar',
          name: 'Spring Plankton Bloom',
          description: 'Massive plankton blooms attract filter feeders. Increased activity in all shallow areas.',
          type: SeasonalEventType.bloom,
          startDate: DateTime(now.year, 3, 1),
          endDate: DateTime(now.year, 3, 31),
          bonusBiomes: [BiomeType.shallowWaters],
          discoveryMultiplier: 1.3,
          availableCreatures: ['sw_unc_005', 'sw_unc_006'], // Filter feeding fish
          iconName: 'plankton',
          rarity: EventRarity.uncommon,
        );
        
      case 4: // April - Shark Patrol Season
        return SeasonalEvent(
          id: 'shark_patrol_apr',
          name: 'Shark Patrol Season',
          description: 'Shark species become more active. Higher chance of apex predator encounters.',
          type: SeasonalEventType.predatorActivity,
          startDate: DateTime(now.year, 4, 1),
          endDate: DateTime(now.year, 4, 30),
          bonusBiomes: [BiomeType.deepOcean, BiomeType.coralGarden],
          discoveryMultiplier: 1.4,
          availableCreatures: ['do_rare_001', 'do_rare_002'], // Shark species
          iconName: 'shark',
          rarity: EventRarity.rare,
          specialEncounterBonus: 0.1,
        );
        
      case 5: // May - Manta Ray Season
        return SeasonalEvent(
          id: 'manta_season_may',
          name: 'Manta Ray Gathering',
          description: 'Gentle giants gather for feeding. Peaceful encounters with large pelagic species.',
          type: SeasonalEventType.gathering,
          startDate: DateTime(now.year, 5, 1),
          endDate: DateTime(now.year, 5, 31),
          bonusBiomes: [BiomeType.deepOcean],
          discoveryMultiplier: 1.6,
          availableCreatures: ['do_rare_003', 'do_unc_008'], // Manta rays
          iconName: 'manta_ray',
          rarity: EventRarity.rare,
        );
        
      case 6: // June - Summer Abundance
        return SeasonalEvent(
          id: 'summer_abundance_jun',
          name: 'Summer Marine Abundance',
          description: 'Peak marine activity season. All biomes show increased species diversity.',
          type: SeasonalEventType.abundance,
          startDate: DateTime(now.year, 6, 1),
          endDate: DateTime(now.year, 6, 30),
          bonusBiomes: [BiomeType.shallowWaters, BiomeType.coralGarden, BiomeType.deepOcean],
          discoveryMultiplier: 1.25,
          availableCreatures: [], // Affects all species
          iconName: 'abundance',
          rarity: EventRarity.epic,
        );
        
      case 7: // July - Deep Sea Exploration Month
        return SeasonalEvent(
          id: 'deep_exploration_jul',
          name: 'Deep Sea Exploration',
          description: 'Optimal conditions for deep water research. Enhanced abyssal zone discoveries.',
          type: SeasonalEventType.exploration,
          startDate: DateTime(now.year, 7, 1),
          endDate: DateTime(now.year, 7, 31),
          bonusBiomes: [BiomeType.abyssalZone],
          discoveryMultiplier: 2.5,
          availableCreatures: ['ab_leg_001'], // Special abyssal creatures
          iconName: 'deep_sea',
          rarity: EventRarity.legendary,
        );
        
      case 8: // August - Bioluminescence Festival
        return SeasonalEvent(
          id: 'bioluminescence_aug',
          name: 'Bioluminescence Festival',
          description: 'Peak bioluminescent activity in deep waters. Glowing creatures more common.',
          type: SeasonalEventType.bioluminescence,
          startDate: DateTime(now.year, 8, 1),
          endDate: DateTime(now.year, 8, 31),
          bonusBiomes: [BiomeType.deepOcean, BiomeType.abyssalZone],
          discoveryMultiplier: 1.8,
          availableCreatures: ['ab_rare_001', 'ab_rare_002'], // Bioluminescent species
          iconName: 'bioluminescence',
          rarity: EventRarity.rare,
        );
        
      case 9: // September - Autumn Migration
        return SeasonalEvent(
          id: 'autumn_migration_sep',
          name: 'Autumn Migration Routes',
          description: 'Species begin seasonal migrations. Increased movement across all biomes.',
          type: SeasonalEventType.migration,
          startDate: DateTime(now.year, 9, 1),
          endDate: DateTime(now.year, 9, 30),
          bonusBiomes: [BiomeType.deepOcean, BiomeType.coralGarden],
          discoveryMultiplier: 1.4,
          availableCreatures: ['do_unc_009', 'cg_unc_008'], // Migratory species
          iconName: 'migration',
          rarity: EventRarity.uncommon,
        );
        
      case 10: // October - Mysterious Depths
        return SeasonalEvent(
          id: 'mysterious_depths_oct',
          name: 'Mysterious Depths Month',
          description: 'Strange encounters in the abyss. Legendary creatures more active.',
          type: SeasonalEventType.mystery,
          startDate: DateTime(now.year, 10, 1),
          endDate: DateTime(now.year, 10, 31),
          bonusBiomes: [BiomeType.abyssalZone],
          discoveryMultiplier: 3.0,
          availableCreatures: ['ab_leg_001'], // Mysterious legendary creatures
          iconName: 'mystery',
          rarity: EventRarity.legendary,
          specialEncounterBonus: 0.15,
        );
        
      case 11: // November - Conservation Month
        return SeasonalEvent(
          id: 'conservation_nov',
          name: 'Marine Conservation Month',
          description: 'Focus on endangered species conservation. Rare species protection efforts.',
          type: SeasonalEventType.conservation,
          startDate: DateTime(now.year, 11, 1),
          endDate: DateTime(now.year, 11, 30),
          bonusBiomes: [BiomeType.coralGarden, BiomeType.deepOcean],
          discoveryMultiplier: 1.3,
          availableCreatures: ['cg_rare_003', 'do_rare_004'], // Endangered species
          iconName: 'conservation',
          rarity: EventRarity.rare,
        );
        
      case 12: // December - Winter Solstice
        return SeasonalEvent(
          id: 'winter_solstice_dec',
          name: 'Winter Solstice Deep Dive',
          description: 'Year-end expedition season. All biomes accessible with bonuses.',
          type: SeasonalEventType.celebration,
          startDate: DateTime(now.year, 12, 1),
          endDate: DateTime(now.year, 12, 31),
          bonusBiomes: [BiomeType.shallowWaters, BiomeType.coralGarden, BiomeType.deepOcean, BiomeType.abyssalZone],
          discoveryMultiplier: 1.5,
          availableCreatures: [], // All species bonus
          iconName: 'celebration',
          rarity: EventRarity.epic,
        );
        
      default:
        return null;
    }
  }
  
  /// Weekly special events based on week of year
  SeasonalEvent? _getWeeklySpecialEvent(DateTime now) {
    final weekOfYear = _getWeekOfYear(now);
    
    // Every 4th week has a special encounter event
    if (weekOfYear % 4 == 0) {
      return SeasonalEvent(
        id: 'weekly_special_${weekOfYear}',
        name: 'Research Expedition Week',
        description: 'Special research opportunities available. Increased legendary encounter rates.',
        type: SeasonalEventType.specialEncounter,
        startDate: now.subtract(Duration(days: now.weekday - 1)),
        endDate: now.add(Duration(days: 7 - now.weekday)),
        bonusBiomes: [BiomeType.deepOcean, BiomeType.abyssalZone],
        discoveryMultiplier: 1.2,
        availableCreatures: [],
        iconName: 'special_expedition',
        rarity: EventRarity.rare,
        specialEncounterBonus: 0.08,
      );
    }
    
    return null;
  }
  
  /// Daily tide-based events
  SeasonalEvent? _getDailyTideEvent(DateTime now) {
    final hourOfDay = now.hour;
    
    // High tide events (6-8 AM and 6-8 PM)
    if ((hourOfDay >= 6 && hourOfDay <= 8) || (hourOfDay >= 18 && hourOfDay <= 20)) {
      return SeasonalEvent(
        id: 'high_tide_${now.day}',
        name: 'High Tide Activity',
        description: 'Peak marine activity during high tide. Enhanced shallow water discoveries.',
        type: SeasonalEventType.tidal,
        startDate: DateTime(now.year, now.month, now.day, hourOfDay),
        endDate: DateTime(now.year, now.month, now.day, hourOfDay + 2),
        bonusBiomes: [BiomeType.shallowWaters, BiomeType.coralGarden],
        discoveryMultiplier: 1.15,
        availableCreatures: [],
        iconName: 'high_tide',
        rarity: EventRarity.common,
      );
    }
    
    // Low tide events (12-2 PM)
    if (hourOfDay >= 12 && hourOfDay <= 14) {
      return SeasonalEvent(
        id: 'low_tide_${now.day}',
        name: 'Low Tide Exploration',
        description: 'Low tide reveals hidden pools and creatures. Bonus to rare discoveries.',
        type: SeasonalEventType.tidal,
        startDate: DateTime(now.year, now.month, now.day, 12),
        endDate: DateTime(now.year, now.month, now.day, 14),
        bonusBiomes: [BiomeType.shallowWaters],
        discoveryMultiplier: 1.2,
        availableCreatures: ['sw_rare_001'], // Tide pool species
        iconName: 'low_tide',
        rarity: EventRarity.uncommon,
      );
    }
    
    return null;
  }
  
  /// Helper to get week of year
  int _getWeekOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(startOfYear).inDays;
    return (dayOfYear / 7).ceil();
  }
}

/// Seasonal event data model
class SeasonalEvent {
  final String id;
  final String name;
  final String description;
  final SeasonalEventType type;
  final DateTime startDate;
  final DateTime endDate;
  final List<BiomeType> bonusBiomes;
  final double discoveryMultiplier;
  final List<String> availableCreatures;
  final String iconName;
  final EventRarity rarity;
  final double specialEncounterBonus;
  
  const SeasonalEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.bonusBiomes,
    required this.discoveryMultiplier,
    required this.availableCreatures,
    required this.iconName,
    required this.rarity,
    this.specialEncounterBonus = 0.0,
  });
  
  /// Check if event is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }
  
  /// Get remaining time for event
  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return Duration.zero;
    return endDate.difference(now);
  }
  
  /// Get event color based on rarity
  String get colorHex {
    switch (rarity) {
      case EventRarity.common:
        return '#4CAF50'; // Green
      case EventRarity.uncommon:
        return '#2196F3'; // Blue  
      case EventRarity.rare:
        return '#9C27B0'; // Purple
      case EventRarity.epic:
        return '#FF9800'; // Orange
      case EventRarity.legendary:
        return '#F44336'; // Red
    }
  }
}

/// Types of seasonal events
enum SeasonalEventType {
  migration,
  breeding,
  bloom,
  predatorActivity,
  gathering,
  abundance,
  exploration,
  bioluminescence,
  mystery,
  conservation,
  celebration,
  specialEncounter,
  tidal,
}

/// Event rarity levels
enum EventRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}