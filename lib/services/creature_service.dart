import 'dart:math';
import '../models/creature.dart';
import '../models/coral.dart';
import '../models/aquarium.dart';
import '../models/ocean_activity.dart';
import 'persistence/persistence_service.dart';
import 'seasonal_events_service.dart';

class CreatureService {
  static final Random _random = Random();
  
  // Rarity spawn rates
  static const Map<CreatureRarity, double> rarityChances = {
    CreatureRarity.common: 0.70,     // 70%
    CreatureRarity.uncommon: 0.20,   // 20%
    CreatureRarity.rare: 0.08,       // 8%
    CreatureRarity.legendary: 0.02,  // 2%
  };
  
  // Base discovery chance per session (modified by coral types)
  static const double baseDiscoveryChance = 0.3; // 30% base chance
  
  // Coral type bonuses for creature discovery
  static const Map<CoralType, double> coralDiscoveryBonuses = {
    CoralType.brain: 0.05,      // +5% discovery chance
    CoralType.staghorn: 0.15,   // +15% discovery chance (attracts fish)
    CoralType.table: 0.10,      // +10% discovery chance
    CoralType.soft: 0.08,       // +8% discovery chance
    CoralType.fire: 0.03,       // +3% discovery chance (but other benefits)
  };
  
  /// Check if a creature should be discovered after a session with depth-based spawning
  static Future<Creature?> checkForCreatureDiscovery({
    required Aquarium aquarium,
    required int sessionDurationMinutes,
    required bool sessionCompleted,
    required double sessionDepth, // New parameter for depth-based discovery
  }) async {
    // Only discover creatures on completed sessions
    if (!sessionCompleted) return null;
    
    // Calculate discovery chance based on corals
    double discoveryChance = baseDiscoveryChance;
    
    // Add bonuses from corals
    final corals = await PersistenceService.instance.ocean.getAllCorals();
    for (final coral in corals) {
      if (coral.isHealthy && coral.stage != CoralStage.polyp) {
        discoveryChance += coralDiscoveryBonuses[coral.type] ?? 0;
        
        // Extra bonus for flourishing corals
        if (coral.stage == CoralStage.flourishing) {
          discoveryChance += 0.05;
        }
      }
    }
    
    // Apply depth-based discovery bonuses according to Master Plan
    discoveryChance = applyDepthBasedDiscoveryRates(discoveryChance, sessionDurationMinutes, sessionDepth);
    
    // Apply seasonal events bonuses - Phase 5 Enhancement
    final currentBiome = getBiomeFromDepth(sessionDepth);
    final seasonalBonus = SeasonalEventsService.instance.getSeasonalDiscoveryBonus(currentBiome);
    discoveryChance *= seasonalBonus;
    
    // Cap discovery chance at 90% (increased due to seasonal events)
    discoveryChance = discoveryChance.clamp(0.0, 0.9);
    
    // Roll for discovery
    if (_random.nextDouble() > discoveryChance) {
      return null; // No discovery this time
    }
    
    // A creature will be discovered! Determine which one based on depth
    return await _selectCreatureToDiscover(aquarium, sessionDepth, sessionDurationMinutes);
  }
  
  /// Select which creature to discover based on rarity, biome, and depth
  static Future<Creature?> _selectCreatureToDiscover(Aquarium aquarium, double depth, int sessionDuration) async {
    // Get all undiscovered creatures
    final allCreatures = await PersistenceService.instance.ocean.getAllCreatures();
    final undiscoveredCreatures = allCreatures
        .where((c) => !c.isDiscovered)
        .where((c) => aquarium.isBiomeUnlocked(c.habitat))
        .toList();
    
    if (undiscoveredCreatures.isEmpty) {
      // All creatures discovered in unlocked biomes!
      return null;
    }
    
    // Determine rarity based on biome depth (deeper = higher rarity chances)
    final rarity = _selectRarityForBiome(getBiomeFromDepth(depth));
    
    // Filter creatures by selected rarity
    final candidateCreatures = undiscoveredCreatures
        .where((c) => c.rarity == rarity)
        .toList();
    
    // If no creatures of this rarity, try to find any creature
    if (candidateCreatures.isEmpty) {
      // Fall back to any undiscovered creature
      return undiscoveredCreatures[_random.nextInt(undiscoveredCreatures.length)];
    }
    
    // Select random creature from candidates
    final selectedCreature = candidateCreatures[_random.nextInt(candidateCreatures.length)];
    
    // Mark creature as discovered
    await _discoverCreature(selectedCreature, aquarium);
    
    return selectedCreature;
  }
  

  /// Select rarity based on biome depth (deeper biomes have higher rare species chances)
  static CreatureRarity _selectRarityForBiome(BiomeType biome) {
    final roll = _random.nextDouble();
    Map<CreatureRarity, double> biomeRarityChances;

    switch (biome) {
      case BiomeType.shallowWaters:
        // Higher chance of common species
        biomeRarityChances = {
          CreatureRarity.common: 0.80,     // 80%
          CreatureRarity.uncommon: 0.15,   // 15%
          CreatureRarity.rare: 0.04,       // 4%
          CreatureRarity.legendary: 0.01,  // 1%
        };
        break;
      case BiomeType.coralGarden:
        // Balanced distribution
        biomeRarityChances = {
          CreatureRarity.common: 0.65,     // 65%
          CreatureRarity.uncommon: 0.25,   // 25%
          CreatureRarity.rare: 0.08,       // 8%
          CreatureRarity.legendary: 0.02,  // 2%
        };
        break;
      case BiomeType.deepOcean:
        // Higher chance of rare species
        biomeRarityChances = {
          CreatureRarity.common: 0.50,     // 50%
          CreatureRarity.uncommon: 0.30,   // 30%
          CreatureRarity.rare: 0.15,       // 15%
          CreatureRarity.legendary: 0.05,  // 5%
        };
        break;
      case BiomeType.abyssalZone:
        // Highest chance of legendary species
        biomeRarityChances = {
          CreatureRarity.common: 0.30,     // 30%
          CreatureRarity.uncommon: 0.35,   // 35%
          CreatureRarity.rare: 0.25,       // 25%
          CreatureRarity.legendary: 0.10,  // 10%
        };
        break;
    }

    double cumulative = 0.0;
    for (final entry in biomeRarityChances.entries) {
      cumulative += entry.value;
      if (roll < cumulative) {
        return entry.key;
      }
    }

    // Fallback to common
    return CreatureRarity.common;
  }
  
  /// Mark a creature as discovered and handle related logic
  static Future<void> _discoverCreature(Creature creature, Aquarium aquarium) async {
    // Update creature in database
    await PersistenceService.instance.ocean.discoverCreature(creature.id);
    
    // Log the discovery activity
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

  /// Apply biome-based discovery rates using the new depth system
  /// Rewards reaching deeper biomes regardless of session duration
  static double applyDepthBasedDiscoveryRates(double baseChance, int sessionDuration, double depth) {
    double discoveryChance = baseChance;

    // Biome-based discovery bonuses (encourages depth progression, not duration)
    final biome = getBiomeFromDepth(depth);

    switch (biome) {
      case BiomeType.shallowWaters:
        // Common species, high discovery rate
        discoveryChance += 0.30; // +30% chance
        break;
      case BiomeType.coralGarden:
        // Diverse ecosystem, good discovery rate
        discoveryChance += 0.25; // +25% chance
        break;
      case BiomeType.deepOcean:
        // Fewer but more valuable species
        discoveryChance += 0.15; // +15% chance
        break;
      case BiomeType.abyssalZone:
        // Very rare but legendary species
        discoveryChance += 0.08; // +8% chance, but higher rarity
        break;
    }

    return discoveryChance.clamp(0.0, 0.8);
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
}