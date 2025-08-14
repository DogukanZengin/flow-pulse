import 'creature.dart';
import 'coral.dart';

class Aquarium {
  final String id;
  final BiomeType currentBiome;
  final List<Creature> inhabitants;
  final List<Coral> corals;
  final PearlWallet pearlWallet;
  final double ecosystemHealth; // 0.0 to 1.0
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final AquariumSettings settings;
  final Map<BiomeType, bool> unlockedBiomes;
  final AquariumStats stats;

  const Aquarium({
    required this.id,
    required this.currentBiome,
    this.inhabitants = const [],
    this.corals = const [],
    required this.pearlWallet,
    this.ecosystemHealth = 1.0,
    required this.createdAt,
    required this.lastActiveAt,
    required this.settings,
    this.unlockedBiomes = const {BiomeType.shallowWaters: true},
    required this.stats,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'current_biome': currentBiome.index,
      'ecosystem_health': ecosystemHealth,
      'created_at': createdAt.millisecondsSinceEpoch,
      'last_active_at': lastActiveAt.millisecondsSinceEpoch,
      'pearl_balance': pearlWallet.pearls,
      'crystal_balance': pearlWallet.crystals,
      'unlocked_biomes': unlockedBiomes.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key.index)
          .join(','),
      'total_creatures_discovered': stats.totalCreaturesDiscovered,
      'total_corals_grown': stats.totalCoralsGrown,
      'total_focus_time': stats.totalFocusTime,
      'current_streak': stats.currentStreak,
      'longest_streak': stats.longestStreak,
      // Settings
      'enable_sounds': settings.enableSounds ? 1 : 0,
      'enable_animations': settings.enableAnimations ? 1 : 0,
      'enable_notifications': settings.enableNotifications ? 1 : 0,
      'water_clarity': settings.waterClarity,
    };
  }

  factory Aquarium.fromMap(Map<String, dynamic> map) {
    // Parse unlocked biomes
    Map<BiomeType, bool> unlockedBiomes = {BiomeType.shallowWaters: true};
    if (map['unlocked_biomes'] != null && map['unlocked_biomes'].isNotEmpty) {
      final unlockedIndices = map['unlocked_biomes'].split(',').map(int.parse);
      for (int index in unlockedIndices) {
        unlockedBiomes[BiomeType.values[index]] = true;
      }
    }

    return Aquarium(
      id: map['id'],
      currentBiome: BiomeType.values[map['current_biome']],
      pearlWallet: PearlWallet(
        pearls: map['pearl_balance'] ?? 0,
        crystals: map['crystal_balance'] ?? 0,
      ),
      ecosystemHealth: map['ecosystem_health']?.toDouble() ?? 1.0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      lastActiveAt: DateTime.fromMillisecondsSinceEpoch(map['last_active_at']),
      unlockedBiomes: unlockedBiomes,
      settings: AquariumSettings(
        enableSounds: map['enable_sounds'] == 1,
        enableAnimations: map['enable_animations'] == 1,
        enableNotifications: map['enable_notifications'] == 1,
        waterClarity: map['water_clarity']?.toDouble() ?? 1.0,
      ),
      stats: AquariumStats(
        totalCreaturesDiscovered: map['total_creatures_discovered'] ?? 0,
        totalCoralsGrown: map['total_corals_grown'] ?? 0,
        totalFocusTime: map['total_focus_time'] ?? 0,
        currentStreak: map['current_streak'] ?? 0,
        longestStreak: map['longest_streak'] ?? 0,
      ),
    );
  }

  Aquarium copyWith({
    String? id,
    BiomeType? currentBiome,
    List<Creature>? inhabitants,
    List<Coral>? corals,
    PearlWallet? pearlWallet,
    double? ecosystemHealth,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    AquariumSettings? settings,
    Map<BiomeType, bool>? unlockedBiomes,
    AquariumStats? stats,
  }) {
    return Aquarium(
      id: id ?? this.id,
      currentBiome: currentBiome ?? this.currentBiome,
      inhabitants: inhabitants ?? this.inhabitants,
      corals: corals ?? this.corals,
      pearlWallet: pearlWallet ?? this.pearlWallet,
      ecosystemHealth: ecosystemHealth ?? this.ecosystemHealth,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      settings: settings ?? this.settings,
      unlockedBiomes: unlockedBiomes ?? this.unlockedBiomes,
      stats: stats ?? this.stats,
    );
  }

  // Calculated properties
  int get totalCreatures => inhabitants.where((c) => c.isDiscovered).length;
  int get totalCorals => corals.length;
  int get matureCorals => corals.where((c) => c.stage.index >= 2).length; // Mature or flourishing
  
  List<Creature> get discoveredCreatures => inhabitants.where((c) => c.isDiscovered).toList();
  List<Creature> get undiscoveredCreatures => inhabitants.where((c) => !c.isDiscovered).toList();
  
  List<Coral> get flourishingCorals => corals.where((c) => c.stage == CoralStage.flourishing).toList();
  List<Coral> get healthyCorals => corals.where((c) => c.isHealthy).toList();
  
  bool isBiomeUnlocked(BiomeType biome) => unlockedBiomes[biome] ?? false;
  
  // Calculate daily pearl income from corals
  int get dailyPearlIncome {
    return corals.fold(0, (total, coral) => total + coral.dailyPearlBonus);
  }
  
  // Get creatures available in current biome
  List<Creature> get currentBiomeCreatures {
    return inhabitants.where((c) => c.habitat == currentBiome).toList();
  }
  
  // Calculate ecosystem diversity (0.0 to 1.0)
  double get biodiversityIndex {
    if (inhabitants.isEmpty) return 0.0;
    
    final totalSpecies = inhabitants.length;
    final discoveredSpecies = discoveredCreatures.length;
    
    return discoveredSpecies / totalSpecies;
  }
  
  // Get rarity distribution of discovered creatures
  Map<CreatureRarity, int> get rarityDistribution {
    final distribution = <CreatureRarity, int>{};
    for (final rarity in CreatureRarity.values) {
      distribution[rarity] = discoveredCreatures.where((c) => c.rarity == rarity).length;
    }
    return distribution;
  }
}

class PearlWallet {
  final int pearls;
  final int crystals; // Premium currency
  
  const PearlWallet({
    this.pearls = 0,
    this.crystals = 0,
  });
  
  PearlWallet copyWith({
    int? pearls,
    int? crystals,
  }) {
    return PearlWallet(
      pearls: pearls ?? this.pearls,
      crystals: crystals ?? this.crystals,
    );
  }
  
  PearlWallet addPearls(int amount) {
    return copyWith(pearls: pearls + amount);
  }
  
  PearlWallet spendPearls(int amount) {
    return copyWith(pearls: (pearls - amount).clamp(0, double.infinity).toInt());
  }
  
  PearlWallet addCrystals(int amount) {
    return copyWith(crystals: crystals + amount);
  }
  
  PearlWallet spendCrystals(int amount) {
    return copyWith(crystals: (crystals - amount).clamp(0, double.infinity).toInt());
  }
  
  bool canAfford(int pearlCost, [int crystalCost = 0]) {
    return pearls >= pearlCost && crystals >= crystalCost;
  }
}

class AquariumSettings {
  final bool enableSounds;
  final bool enableAnimations;
  final bool enableNotifications;
  final double waterClarity; // 0.0 (murky) to 1.0 (crystal clear)
  
  const AquariumSettings({
    this.enableSounds = true,
    this.enableAnimations = true,
    this.enableNotifications = true,
    this.waterClarity = 1.0,
  });
  
  AquariumSettings copyWith({
    bool? enableSounds,
    bool? enableAnimations,
    bool? enableNotifications,
    double? waterClarity,
  }) {
    return AquariumSettings(
      enableSounds: enableSounds ?? this.enableSounds,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      waterClarity: waterClarity ?? this.waterClarity,
    );
  }
}

class AquariumStats {
  final int totalCreaturesDiscovered;
  final int totalCoralsGrown;
  final int totalFocusTime; // in minutes
  final int currentStreak; // days
  final int longestStreak; // days
  final DateTime? lastSessionAt;
  final Map<CreatureRarity, int> discoveryCount;
  
  const AquariumStats({
    this.totalCreaturesDiscovered = 0,
    this.totalCoralsGrown = 0,
    this.totalFocusTime = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastSessionAt,
    this.discoveryCount = const {},
  });
  
  AquariumStats copyWith({
    int? totalCreaturesDiscovered,
    int? totalCoralsGrown,
    int? totalFocusTime,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastSessionAt,
    Map<CreatureRarity, int>? discoveryCount,
  }) {
    return AquariumStats(
      totalCreaturesDiscovered: totalCreaturesDiscovered ?? this.totalCreaturesDiscovered,
      totalCoralsGrown: totalCoralsGrown ?? this.totalCoralsGrown,
      totalFocusTime: totalFocusTime ?? this.totalFocusTime,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastSessionAt: lastSessionAt ?? this.lastSessionAt,
      discoveryCount: discoveryCount ?? this.discoveryCount,
    );
  }
  
  // Formatted getters
  String get formattedFocusTime {
    final hours = totalFocusTime ~/ 60;
    final minutes = totalFocusTime % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
  
  double get averageSessionLength {
    if (totalCoralsGrown == 0) return 0.0;
    return totalFocusTime / totalCoralsGrown;
  }
}