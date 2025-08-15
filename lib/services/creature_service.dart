import 'dart:math';
import '../models/creature.dart';
import '../models/coral.dart';
import '../models/aquarium.dart';
import '../models/ocean_activity.dart';
import 'database_service.dart';

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
    final corals = await DatabaseService.getAllCorals();
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
    
    // Cap discovery chance at 80%
    discoveryChance = discoveryChance.clamp(0.0, 0.8);
    
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
    final allCreatures = await DatabaseService.getAllCreatures();
    final undiscoveredCreatures = allCreatures
        .where((c) => !c.isDiscovered)
        .where((c) => aquarium.isBiomeUnlocked(c.habitat))
        .toList();
    
    if (undiscoveredCreatures.isEmpty) {
      // All creatures discovered in unlocked biomes!
      return null;
    }
    
    // Determine rarity based on weighted random
    final rarity = _selectRarity();
    
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
  
  /// Select rarity based on weighted random
  static CreatureRarity _selectRarity() {
    final roll = _random.nextDouble();
    double cumulative = 0.0;
    
    for (final entry in rarityChances.entries) {
      cumulative += entry.value;
      if (roll < cumulative) {
        return entry.key;
      }
    }
    
    // Fallback to common (should never reach here)
    return CreatureRarity.common;
  }
  
  /// Mark a creature as discovered and handle related logic
  static Future<void> _discoverCreature(Creature creature, Aquarium aquarium) async {
    // Update creature in database
    await DatabaseService.discoverCreature(creature.id);
    
    // Log the discovery activity
    final activity = OceanActivity.creatureDiscovered(
      creatureName: creature.name,
      rarity: creature.rarity.displayName,
      pearlsEarned: creature.pearlValue,
      timestamp: DateTime.now(),
    );
    await DatabaseService.saveOceanActivity(activity);
    
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
    await DatabaseService.saveAquarium(updatedAquarium);
  }
  
  /// Get discovery statistics
  static Future<Map<String, dynamic>> getDiscoveryStats() async {
    final allCreatures = await DatabaseService.getAllCreatures();
    final discoveredCreatures = await DatabaseService.getDiscoveredCreatures();
    
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

  /// Apply depth-based discovery rates according to Master Plan
  static double applyDepthBasedDiscoveryRates(double baseChance, int sessionDuration, double depth) {
    double discoveryChance = baseChance;
    
    // Expedition type bonuses based on Master Plan
    if (sessionDuration >= 15 && sessionDuration <= 20 && depth <= 10) {
      // Shallow Water Research (15-20min, 5-10m depth)
      discoveryChance += 0.40; // High discovery rate (40% chance)
    } else if (sessionDuration >= 25 && sessionDuration <= 30 && depth <= 20) {
      // Mid-Water Expedition (25-30min, 10-20m depth)  
      discoveryChance += 0.25; // Medium discovery rate (25% chance)
    } else if (sessionDuration >= 45 && sessionDuration <= 60 && depth <= 40) {
      // Deep Sea Research (45-60min, 20-40m depth)
      discoveryChance += 0.15; // Low but valuable (15% chance)
    } else if (sessionDuration >= 90 && depth > 40) {
      // Abyssal Expedition (90min+, 40m+ depth)
      discoveryChance += 0.05; // Very rare but legendary (5% chance)
    }
    
    return discoveryChance.clamp(0.0, 0.8);
  }

  /// Get biome type based on session depth
  static BiomeType getBiomeFromDepth(double depth) {
    if (depth <= 10) {
      return BiomeType.shallowWaters;
    } else if (depth <= 20) {
      return BiomeType.coralGarden;
    } else if (depth <= 40) {
      return BiomeType.deepOcean;
    } else {
      return BiomeType.abyssalZone;
    }
  }

  /// Calculate depth progression based on session progress (0.0 to 1.0)
  static double calculateSessionDepth(int sessionDurationMinutes, double progress) {
    // Target depth based on session duration (Master Plan)
    double targetDepth;
    if (sessionDurationMinutes <= 20) {
      targetDepth = 10; // Shallow Water Research (5-10m)
    } else if (sessionDurationMinutes <= 30) {
      targetDepth = 20; // Mid-Water Expedition (10-20m)
    } else if (sessionDurationMinutes <= 60) {
      targetDepth = 40; // Deep Sea Research (20-40m)
    } else {
      targetDepth = 60; // Abyssal Expedition (40m+)
    }
    
    // Return current depth based on session progress
    return targetDepth * progress;
  }
}