import 'dart:math';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/creature.dart';
import '../models/coral.dart';
import '../models/aquarium.dart';
import '../models/ocean_activity.dart';
import 'persistence/persistence_service.dart';
import 'persistence/repositories/equipment_repository.dart';
import 'gamification_service.dart';

class CreatureService {
  static final Random _random = Random();

  // Discovery tracking keys
  static const String _lastDiscoveryDateKey = 'last_discovery_date';
  static const String _dailyDiscoveryCountKey = 'daily_discovery_count';

  // RP-based discovery chance multipliers by RP range
  static const Map<int, double> _rpBasedDiscoveryChances = {
    0: 0.15,    // 0-50 RP: 15% base chance
    51: 0.25,   // 51-200 RP: 25% base chance
    201: 0.35,  // 201-500 RP: 35% base chance
    501: 0.45,  // 501+ RP: 45% base chance
  };

  // Streak bonus multipliers
  static const Map<int, double> _streakBonusMultipliers = {
    1: 1.0,     // 1-2 days: no bonus
    3: 1.1,     // 3-6 days: +10%
    7: 1.2,     // 7-13 days: +20%
    14: 1.3,    // 14-29 days: +30%
    30: 1.5,    // 30+ days: +50%
  };

  // Coral type bonuses for creature discovery
  static const Map<CoralType, double> coralDiscoveryBonuses = {
    CoralType.brain: 0.05,      // +5% discovery chance
    CoralType.staghorn: 0.15,   // +15% discovery chance (attracts fish)
    CoralType.table: 0.10,      // +10% discovery chance
    CoralType.soft: 0.08,       // +8% discovery chance
    CoralType.fire: 0.03,       // +3% discovery chance (but other benefits)
  };

  // Legacy rarity chances (kept for backward compatibility)
  static const Map<CreatureRarity, double> rarityChances = {
    CreatureRarity.common: 0.70,     // 70%
    CreatureRarity.uncommon: 0.20,   // 20%
    CreatureRarity.rare: 0.08,       // 8%
    CreatureRarity.legendary: 0.02,  // 2%
  };
  
  /// Check if a creature should be discovered after a session - RP-based system
  ///
  /// Replaces duration-based discovery with RP milestone-based discovery logic.
  /// Provides guaranteed first discovery of the day and streak bonuses.
  static Future<Creature?> checkForCreatureDiscovery({
    required Aquarium aquarium,
    required int sessionDurationMinutes,
    required bool sessionCompleted,
    required double sessionDepth,
  }) async {
    // Only discover creatures on completed sessions
    if (!sessionCompleted) return null;

    final gamificationService = GamificationService.instance;
    final cumulativeRP = gamificationService.cumulativeRP;
    final currentStreak = gamificationService.currentStreak;

    // Check if this is first session of the day
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';

    final lastDiscoveryDate = prefs.getString(_lastDiscoveryDateKey);
    final dailyDiscoveryCount = prefs.getInt('${_dailyDiscoveryCountKey}_$todayKey') ?? 0;
    final isFirstSessionOfDay = lastDiscoveryDate != todayKey;

    // Get base discovery chance based on RP milestone
    double baseChance = _getBaseChanceFromRP(cumulativeRP);

    // Calculate coral ecosystem bonuses
    final corals = await PersistenceService.instance.ocean.getAllCorals();
    double coralBonus = 0.0;
    for (final coral in corals) {
      if (coral.isHealthy && coral.stage != CoralStage.polyp) {
        coralBonus += coralDiscoveryBonuses[coral.type] ?? 0;

        // Extra bonus for flourishing corals
        if (coral.stage == CoralStage.flourishing) {
          coralBonus += 0.05;
        }
      }
    }

    // Calculate equipment discovery bonuses
    final equipmentRepository = EquipmentRepository(PersistenceService.instance);
    final equipmentBonus = await equipmentRepository.getTotalDiscoveryBonus();

    // Apply streak bonus multiplier
    final streakMultiplier = _getStreakMultiplier(currentStreak);

    // Multiple sessions per day increase rare species chance
    double multiSessionBonus = 0.0;
    if (dailyDiscoveryCount > 0) {
      multiSessionBonus = (dailyDiscoveryCount * 0.1).clamp(0.0, 0.3); // Max +30%
    }

    // Calculate final discovery chance
    double finalChance = (baseChance + coralBonus + equipmentBonus + multiSessionBonus) * streakMultiplier;

    // First session of day gets guaranteed discovery (minimum 90% chance)
    if (isFirstSessionOfDay) {
      finalChance = math.max(finalChance, 0.9);
    }

    // Cap at 95% to maintain some uncertainty
    finalChance = finalChance.clamp(0.0, 0.95);

    // Roll for discovery
    final roll = _random.nextDouble();
    if (roll >= finalChance) {
      return null; // No discovery this time
    }

    // Discovery successful - select creature based on RP tier and depth
    final creature = await _selectCreatureByRPTier(
      aquarium: aquarium,
      sessionDepth: sessionDepth,
      rpMilestone: _getRPMilestone(cumulativeRP),
      sessionCount: dailyDiscoveryCount,
    );

    if (creature != null) {
      // Update daily discovery tracking
      await _updateDiscoveryTracking();

      // Handle discovery aftermath
      await _handleCreatureDiscovery(creature, aquarium);
    }

    return creature;
  }
  
  
  /// Handle creature discovery with RP-based celebration and logging
  static Future<void> _handleCreatureDiscovery(Creature creature, Aquarium aquarium) async {
    // Log the discovery activity with RP-based achievement context
    final activity = OceanActivity.creatureDiscovered(
      creatureName: creature.name,
      rarity: creature.rarity.displayName,
      pearlsEarned: creature.pearlValue,
      timestamp: DateTime.now(),
    );
    await PersistenceService.instance.ocean.saveOceanActivity(activity);

    // Award pearls for discovery
    final updatedWallet = aquarium.pearlWallet.addPearls(creature.pearlValue);
    final updatedStats = aquarium.stats.copyWith(
      totalCreaturesDiscovered: aquarium.stats.totalCreaturesDiscovered + 1,
    );

    // Update aquarium
    final updatedAquarium = aquarium.copyWith(
      pearlWallet: updatedWallet,
      stats: updatedStats,
      lastActiveAt: DateTime.now(),
    );
    await PersistenceService.instance.ocean.saveAquarium(updatedAquarium);
  }

  
  /// Get discovery statistics
  static Future<Map<String, dynamic>> getDiscoveryStats() async {
    final allCreatures = await PersistenceService.instance.ocean.getAllCreatures();
    final discoveredCreatures = await PersistenceService.instance.ocean.getDiscoveredCreatures();
    
    // Calculate stats by rarity
    final statsByRarity = <CreatureRarity, Map<String, int>>{};
    for (final rarity in CreatureRarity.values) {
      final totalOfRarity = allCreatures.where((c) => c.rarity == rarity).length;
      final discoveredOfRarity = discoveredCreatures.where((c) => c.rarity == rarity).length;
      
      statsByRarity[rarity] = {
        'discovered': discoveredOfRarity,
        'total': totalOfRarity,
      };
    }
    
    // Calculate stats by biome
    final statsByBiome = <BiomeType, Map<String, int>>{};
    for (final biome in BiomeType.values) {
      final totalInBiome = allCreatures.where((c) => c.habitat == biome).length;
      final discoveredInBiome = discoveredCreatures.where((c) => c.habitat == biome).length;
      
      statsByBiome[biome] = {
        'discovered': discoveredInBiome,
        'total': totalInBiome,
      };
    }
    
    return {
      'totalCreatures': allCreatures.length,
      'totalDiscovered': discoveredCreatures.length,
      'discoveryPercentage': allCreatures.isNotEmpty 
          ? (discoveredCreatures.length / allCreatures.length * 100).toStringAsFixed(1)
          : '0.0',
      'byRarity': statsByRarity,
      'byBiome': statsByBiome,
      'recentDiscoveries': discoveredCreatures.take(5).map((c) => c.name).toList(),
    };
  }
  
  /// Calculate ecosystem biodiversity bonus
  static double calculateBiodiversityBonus(List<Creature> discoveredCreatures) {
    if (discoveredCreatures.isEmpty) return 1.0;
    
    // Bonus based on variety of species discovered
    final uniqueTypes = discoveredCreatures.map((c) => c.type).toSet().length;
    final uniqueBiomes = discoveredCreatures.map((c) => c.habitat).toSet().length;
    final rarityVariety = discoveredCreatures.map((c) => c.rarity).toSet().length;
    
    // Calculate multiplier (1.0 to 2.0)
    double bonus = 1.0;
    bonus += uniqueTypes * 0.05;      // +5% per unique type
    bonus += uniqueBiomes * 0.1;      // +10% per unique biome
    bonus += rarityVariety * 0.05;    // +5% per rarity tier discovered
    
    // Milestone bonuses
    if (discoveredCreatures.length >= 10) bonus += 0.1;
    if (discoveredCreatures.length >= 20) bonus += 0.15;
    if (discoveredCreatures.any((c) => c.rarity == CreatureRarity.legendary)) bonus += 0.2;
    
    return bonus.clamp(1.0, 2.0);
  }
  
  /// Get creatures that are attracted to specific coral types
  static List<Creature> getCreaturesAttractedToCoral(
    CoralType coralType,
    List<Creature> availableCreatures,
  ) {
    // Different corals attract different creatures
    switch (coralType) {
      case CoralType.brain:
        // Brain coral attracts intelligent species
        return availableCreatures.where((c) => 
          c.type == CreatureType.reefBuilder ||
          c.name.toLowerCase().contains('octopus') ||
          c.name.toLowerCase().contains('dolphin')
        ).toList();
        
      case CoralType.staghorn:
        // Staghorn attracts small reef fish
        return availableCreatures.where((c) => 
          c.type == CreatureType.starterFish ||
          c.rarity == CreatureRarity.common
        ).toList();
        
      case CoralType.table:
        // Table coral provides shelter for larger fish
        return availableCreatures.where((c) => 
          c.type == CreatureType.predator ||
          c.rarity == CreatureRarity.rare
        ).toList();
        
      case CoralType.soft:
        // Soft coral attracts colorful species
        return availableCreatures.where((c) => 
          c.type == CreatureType.reefBuilder ||
          c.rarity == CreatureRarity.uncommon
        ).toList();
        
      case CoralType.fire:
        // Fire coral attracts hardy species
        return availableCreatures.where((c) => 
          c.type == CreatureType.deepSeaDweller ||
          c.rarity == CreatureRarity.legendary
        ).toList();
    }
  }


  /// Get biome type based on session depth
  /// Updated to match the accelerated depth traversal system boundaries
  static BiomeType getBiomeFromDepth(double depth) {
    if (depth < 20) {
      return BiomeType.shallowWaters;  // 0-20m
    } else if (depth < 50) {
      return BiomeType.coralGarden;    // 20-50m
    } else if (depth < 100) {
      return BiomeType.deepOcean;      // 50-100m
    } else {
      return BiomeType.abyssalZone;    // 100m+
    }
  }

  // Note: Session depth calculation is now handled by DepthTraversalService
  // which uses the RP-based accelerated traversal system for dynamic depth calculation

  /// Private helper methods for RP-based discovery system

  /// Select creature based on RP tier and depth with enhanced rarity chances
  static Future<Creature?> _selectCreatureByRPTier({
    required Aquarium aquarium,
    required double sessionDepth,
    required int rpMilestone,
    required int sessionCount,
  }) async {
    final allCreatures = await PersistenceService.instance.ocean.getAllCreatures();
    final undiscoveredCreatures = allCreatures
        .where((c) => !c.isDiscovered)
        .where((c) => aquarium.isBiomeUnlocked(c.habitat))
        .toList();

    if (undiscoveredCreatures.isEmpty) return null;

    // Enhanced rarity selection based on RP milestones
    final rarity = _selectRarityBasedOnRP(rpMilestone, sessionCount, sessionDepth);

    // Filter by rarity and biome
    final biome = getBiomeFromDepth(sessionDepth);
    var candidates = undiscoveredCreatures
        .where((c) => c.rarity == rarity && c.habitat == biome)
        .toList();

    // Fallback to any creature in biome if no candidates of target rarity
    if (candidates.isEmpty) {
      candidates = undiscoveredCreatures
          .where((c) => c.habitat == biome)
          .toList();
    }

    // Final fallback to any undiscovered creature
    if (candidates.isEmpty) {
      candidates = undiscoveredCreatures;
    }

    if (candidates.isEmpty) return null;

    // Select random candidate
    final selectedCreature = candidates[_random.nextInt(candidates.length)];

    // Mark as discovered
    await PersistenceService.instance.ocean.discoverCreature(selectedCreature.id);

    return selectedCreature;
  }

  /// Enhanced rarity selection based on RP progression and session activity
  static CreatureRarity _selectRarityBasedOnRP(int rpMilestone, int sessionCount, double depth) {
    final roll = _random.nextDouble();

    // Base rarity chances by RP milestone
    Map<CreatureRarity, double> rarityChances;

    switch (rpMilestone) {
      case >= 501: // Abyssal tier
        rarityChances = {
          CreatureRarity.common: 0.25,
          CreatureRarity.uncommon: 0.35,
          CreatureRarity.rare: 0.25,
          CreatureRarity.legendary: 0.15,
        };
        break;
      case >= 201: // Deep ocean tier
        rarityChances = {
          CreatureRarity.common: 0.40,
          CreatureRarity.uncommon: 0.35,
          CreatureRarity.rare: 0.20,
          CreatureRarity.legendary: 0.05,
        };
        break;
      case >= 51: // Coral garden tier
        rarityChances = {
          CreatureRarity.common: 0.60,
          CreatureRarity.uncommon: 0.25,
          CreatureRarity.rare: 0.12,
          CreatureRarity.legendary: 0.03,
        };
        break;
      default: // Shallow waters
        rarityChances = {
          CreatureRarity.common: 0.75,
          CreatureRarity.uncommon: 0.18,
          CreatureRarity.rare: 0.06,
          CreatureRarity.legendary: 0.01,
        };
    }

    // Multiple sessions per day boost rare species chance
    if (sessionCount > 0) {
      final boostFactor = (sessionCount * 0.1).clamp(0.0, 0.4);
      rarityChances[CreatureRarity.legendary] = rarityChances[CreatureRarity.legendary]! * (1 + boostFactor);
      rarityChances[CreatureRarity.rare] = rarityChances[CreatureRarity.rare]! * (1 + boostFactor * 0.5);

      // Normalize to ensure total is 1.0
      final total = rarityChances.values.reduce((a, b) => a + b);
      rarityChances = rarityChances.map((key, value) => MapEntry(key, value / total));
    }

    // Select rarity based on weighted roll
    double cumulative = 0.0;
    for (final entry in rarityChances.entries) {
      cumulative += entry.value;
      if (roll < cumulative) {
        return entry.key;
      }
    }

    return CreatureRarity.common; // Fallback
  }

  /// Update daily discovery tracking
  static Future<void> _updateDiscoveryTracking() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';

    // Update last discovery date
    await prefs.setString(_lastDiscoveryDateKey, todayKey);

    // Increment daily discovery count
    final currentCount = prefs.getInt('${_dailyDiscoveryCountKey}_$todayKey') ?? 0;
    await prefs.setInt('${_dailyDiscoveryCountKey}_$todayKey', currentCount + 1);
  }

  /// Get base discovery chance from cumulative RP
  static double _getBaseChanceFromRP(int cumulativeRP) {
    for (final entry in _rpBasedDiscoveryChances.entries.toList().reversed) {
      if (cumulativeRP >= entry.key) {
        return entry.value;
      }
    }
    return _rpBasedDiscoveryChances[0]!;
  }

  /// Get streak multiplier based on current streak
  static double _getStreakMultiplier(int streak) {
    for (final entry in _streakBonusMultipliers.entries.toList().reversed) {
      if (streak >= entry.key) {
        return entry.value;
      }
    }
    return 1.0;
  }

  /// Get RP milestone tier for display purposes
  static int _getRPMilestone(int cumulativeRP) {
    if (cumulativeRP >= 501) return 501;
    if (cumulativeRP >= 201) return 201;
    if (cumulativeRP >= 51) return 51;
    return 0;
  }
}

