import 'dart:math' as math;
import '../models/creature.dart';
import 'database_service.dart';

/// Discovery Balance Service - Phase 5 Implementation
/// Dynamically adjusts discovery rates based on user progression and engagement
class DiscoveryBalanceService {
  static DiscoveryBalanceService? _instance;
  static DiscoveryBalanceService get instance => _instance ??= DiscoveryBalanceService._();
  
  DiscoveryBalanceService._();
  
  /// Calculate balanced discovery rate based on user progression
  Future<double> calculateBalancedDiscoveryRate({
    required double baseRate,
    required BiomeType currentBiome,
    required int userLevel,
    required int totalDiscoveries,
    required int consecutiveSessions,
    required DateTime lastDiscoveryTime,
  }) async {
    double adjustedRate = baseRate;
    
    // 1. Progression-based adjustment
    adjustedRate = _applyProgressionBalance(adjustedRate, userLevel, totalDiscoveries);
    
    // 2. Engagement-based adjustment
    adjustedRate = _applyEngagementBalance(adjustedRate, consecutiveSessions, lastDiscoveryTime);
    
    // 3. Biome completion adjustment
    adjustedRate = await _applyBiomeCompletionBalance(adjustedRate, currentBiome);
    
    // 4. Difficulty curve adjustment
    adjustedRate = _applyDifficultyCurveBalance(adjustedRate, userLevel);
    
    // 5. Anti-frustration system
    adjustedRate = _applyAntiFrustrationSystem(adjustedRate, lastDiscoveryTime, consecutiveSessions);
    
    return adjustedRate.clamp(0.01, 0.95); // Min 1%, Max 95%
  }
  
  /// Calculate rarity-specific discovery rates
  Map<CreatureRarity, double> calculateRarityRates({
    required int userLevel,
    required int totalDiscoveries,
    required double sessionQuality, // 0.0 to 1.0
  }) {
    // Base rarity distribution
    Map<CreatureRarity, double> rates = {
      CreatureRarity.common: 0.70,
      CreatureRarity.uncommon: 0.20,
      CreatureRarity.rare: 0.08,
      CreatureRarity.legendary: 0.02,
    };
    
    // Adjust based on user level (experienced users get more rare creatures)
    final levelMultiplier = (userLevel / 100.0).clamp(0.0, 1.0);
    
    rates[CreatureRarity.common] = (0.70 - levelMultiplier * 0.15).clamp(0.30, 0.70);
    rates[CreatureRarity.uncommon] = (0.20 + levelMultiplier * 0.05).clamp(0.20, 0.35);
    rates[CreatureRarity.rare] = (0.08 + levelMultiplier * 0.07).clamp(0.08, 0.25);
    rates[CreatureRarity.legendary] = (0.02 + levelMultiplier * 0.03).clamp(0.02, 0.10);
    
    // Session quality bonus (high quality sessions get better creatures)
    if (sessionQuality > 0.8) {
      rates[CreatureRarity.rare] = rates[CreatureRarity.rare]! * 1.5;
      rates[CreatureRarity.legendary] = rates[CreatureRarity.legendary]! * 2.0;
      
      // Reduce common rate proportionally
      rates[CreatureRarity.common] = rates[CreatureRarity.common]! * 0.8;
    }
    
    // Normalize to ensure total is 1.0
    final total = rates.values.reduce((a, b) => a + b);
    rates.updateAll((key, value) => value / total);
    
    return rates;
  }
  
  /// Get personalized discovery recommendations
  Future<List<String>> getDiscoveryRecommendations(int userLevel) async {
    final recommendations = <String>[];
    final allCreatures = await DatabaseService.getAllCreatures();
    final discoveredIds = allCreatures.where((c) => c.isDiscovered).map((c) => c.id).toSet();
    final undiscovered = allCreatures.where((c) => !discoveredIds.contains(c.id)).toList();
    
    // Prioritize by user level and biome progression
    final availableBiomes = _getAvailableBiomes(userLevel);
    
    for (final biome in availableBiomes) {
      final biomeCreatures = undiscovered
          .where((c) => c.habitat == biome && c.requiredLevel <= userLevel)
          .toList();
          
      if (biomeCreatures.isNotEmpty) {
        // Sort by discovery priority (rarity, level requirement)
        biomeCreatures.sort((a, b) {
          final aScore = _calculateDiscoveryPriority(a, userLevel);
          final bScore = _calculateDiscoveryPriority(b, userLevel);
          return bScore.compareTo(aScore);
        });
        
        // Add top 3 recommendations per biome
        for (int i = 0; i < math.min(3, biomeCreatures.length); i++) {
          final creature = biomeCreatures[i];
          recommendations.add(
            '${creature.name} in ${_getBiomeDisplayName(creature.habitat)} '
            '(${creature.rarity.name} ${_getCreatureTypeDisplayName(creature.type)})'
          );
        }
      }
    }
    
    return recommendations.take(10).toList(); // Limit to top 10 recommendations
  }
  
  /// Calculate optimal session length for discovery
  int getOptimalSessionLength({
    required BiomeType targetBiome,
    required CreatureRarity targetRarity,
    required int userLevel,
  }) {
    // Base session lengths by biome
    Map<BiomeType, int> baseLengths = {
      BiomeType.shallowWaters: 20,    // 15-20 min
      BiomeType.coralGarden: 30,      // 25-30 min
      BiomeType.deepOcean: 50,        // 45-60 min
      BiomeType.abyssalZone: 90,      // 90+ min
    };
    
    int baseLength = baseLengths[targetBiome] ?? 25;
    
    // Adjust for rarity (rarer creatures need longer sessions)
    switch (targetRarity) {
      case CreatureRarity.common:
        baseLength = (baseLength * 0.8).round();
        break;
      case CreatureRarity.uncommon:
        baseLength = (baseLength * 1.0).round();
        break;
      case CreatureRarity.rare:
        baseLength = (baseLength * 1.2).round();
        break;
      case CreatureRarity.legendary:
        baseLength = (baseLength * 1.5).round();
        break;
    }
    
    // Adjust for user experience (experienced users can get results faster)
    final experienceMultiplier = 1.0 - (userLevel / 200.0).clamp(0.0, 0.3);
    baseLength = (baseLength * experienceMultiplier).round();
    
    return baseLength.clamp(15, 120); // Min 15 min, Max 2 hours
  }
  
  /// Private helper methods
  
  double _applyProgressionBalance(double rate, int level, int discoveries) {
    // Experienced users get slightly better rates
    final levelBonus = (level / 100.0) * 0.1; // Up to 10% bonus
    
    // But diminishing returns for very high discovery counts
    final discoveryPenalty = discoveries > 50 ? 
        math.log(discoveries - 40) * 0.02 : 0.0;
    
    return rate + levelBonus - discoveryPenalty;
  }
  
  double _applyEngagementBalance(double rate, int consecutiveSessions, DateTime lastDiscovery) {
    // Reward consecutive sessions
    final sessionBonus = math.min(consecutiveSessions * 0.02, 0.15); // Max 15% bonus
    
    // Time since last discovery - increase rate if it's been a while
    final hoursSinceLastDiscovery = DateTime.now().difference(lastDiscovery).inHours;
    final timeBonus = hoursSinceLastDiscovery > 24 ?
        math.min(hoursSinceLastDiscovery / 48.0 * 0.1, 0.25) : 0.0; // Max 25% bonus
    
    return rate + sessionBonus + timeBonus;
  }
  
  Future<double> _applyBiomeCompletionBalance(double rate, BiomeType biome) async {
    final allCreatures = await DatabaseService.getAllCreatures();
    final biomeCreatures = allCreatures.where((c) => c.habitat == biome).toList();
    final discoveredInBiome = biomeCreatures.where((c) => c.isDiscovered).length;
    
    if (biomeCreatures.isEmpty) return rate;
    
    final completionPercent = discoveredInBiome / biomeCreatures.length;
    
    // Increase rate as biome completion gets higher (to avoid getting stuck)
    if (completionPercent > 0.8) {
      return rate * (1.0 + (completionPercent - 0.8) * 2.0); // Up to +40% at 100%
    }
    
    return rate;
  }
  
  double _applyDifficultyCurveBalance(double rate, int level) {
    // Difficulty curve: slightly reduce rates at mid-levels to maintain challenge
    if (level >= 25 && level <= 60) {
      final curveReduction = math.sin((level - 25) / 35.0 * math.pi) * 0.1;
      return rate * (1.0 - curveReduction);
    }
    
    return rate;
  }
  
  double _applyAntiFrustrationSystem(double rate, DateTime lastDiscovery, int consecutiveSessions) {
    final hoursSinceLastDiscovery = DateTime.now().difference(lastDiscovery).inHours;
    
    // Strong boost if user hasn't discovered anything in a long time
    if (hoursSinceLastDiscovery > 48 && consecutiveSessions > 3) {
      return rate * 2.5; // 150% boost to prevent frustration
    } else if (hoursSinceLastDiscovery > 24 && consecutiveSessions > 2) {
      return rate * 1.5; // 50% boost
    }
    
    return rate;
  }
  
  List<BiomeType> _getAvailableBiomes(int level) {
    final biomes = <BiomeType>[];
    
    biomes.add(BiomeType.shallowWaters); // Always available
    
    if (level >= 11) biomes.add(BiomeType.coralGarden);
    if (level >= 26) biomes.add(BiomeType.deepOcean);
    if (level >= 51) biomes.add(BiomeType.abyssalZone);
    
    return biomes;
  }
  
  double _calculateDiscoveryPriority(Creature creature, int userLevel) {
    double score = 0.0;
    
    // Rarity scoring (higher rarity = higher priority for experienced users)
    switch (creature.rarity) {
      case CreatureRarity.common:
        score += userLevel < 20 ? 3.0 : 1.0;
        break;
      case CreatureRarity.uncommon:
        score += 2.0;
        break;
      case CreatureRarity.rare:
        score += userLevel >= 25 ? 4.0 : 1.5;
        break;
      case CreatureRarity.legendary:
        score += userLevel >= 50 ? 5.0 : 1.0;
        break;
    }
    
    // Level appropriateness
    final levelDiff = (creature.requiredLevel - userLevel).abs();
    score += levelDiff <= 5 ? 2.0 : -levelDiff * 0.5;
    
    return score;
  }
  
  String _getBiomeDisplayName(BiomeType biome) {
    switch (biome) {
      case BiomeType.shallowWaters:
        return 'Shallow Waters';
      case BiomeType.coralGarden:
        return 'Coral Garden';
      case BiomeType.deepOcean:
        return 'Deep Ocean';
      case BiomeType.abyssalZone:
        return 'Abyssal Zone';
    }
  }
  
  String _getCreatureTypeDisplayName(CreatureType type) {
    switch (type) {
      case CreatureType.starterFish:
        return 'Fish';
      case CreatureType.reefBuilder:
        return 'Reef Builder';
      case CreatureType.predator:
        return 'Predator';
      case CreatureType.deepSeaDweller:
        return 'Deep Sea Dweller';
      case CreatureType.mythical:
        return 'Mythical Being';
    }
  }
}