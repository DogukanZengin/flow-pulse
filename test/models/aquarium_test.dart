import 'package:flutter_test/flutter_test.dart';
import 'package:flow_pulse/models/aquarium.dart';
import 'package:flow_pulse/models/creature.dart';
import 'package:flow_pulse/models/coral.dart';

void main() {
  group('Aquarium Model Tests', () {
    group('Aquarium Creation', () {
      test('should create aquarium with all required fields', () {
        final createdTime = DateTime.now();
        final aquarium = Aquarium(
          id: 'test_aquarium',
          currentBiome: BiomeType.shallowWaters,
          pearlWallet: const PearlWallet(pearls: 100, crystals: 5),
          ecosystemHealth: 0.85,
          createdAt: createdTime,
          lastActiveAt: createdTime,
          settings: const AquariumSettings(),
          stats: const AquariumStats(),
        );

        expect(aquarium.id, 'test_aquarium');
        expect(aquarium.currentBiome, BiomeType.shallowWaters);
        expect(aquarium.pearlWallet.pearls, 100);
        expect(aquarium.pearlWallet.crystals, 5);
        expect(aquarium.ecosystemHealth, 0.85);
        expect(aquarium.createdAt, createdTime);
        expect(aquarium.inhabitants, []); // Default empty
        expect(aquarium.corals, []); // Default empty
        expect(aquarium.unlockedBiomes[BiomeType.shallowWaters], true); // Default unlocked
      });

      test('should create aquarium with inhabitants and corals', () {
        final creatures = [
          Creature(
            id: 'clownfish',
            name: 'Clownfish',
            species: 'Amphiprioninae',
            rarity: CreatureRarity.common,
            type: CreatureType.starterFish,
            habitat: BiomeType.shallowWaters,
            animationAsset: 'test.png',
            pearlValue: 10,
            requiredLevel: 1,
            description: 'Test fish',
            discoveryChance: 0.7,
            isDiscovered: true,
          ),
        ];

        final corals = [
          Coral(
            id: 'brain_coral',
            type: CoralType.brain,
            stage: CoralStage.mature,
            growthProgress: 0.8,
            plantedAt: DateTime.now(),
            biome: BiomeType.shallowWaters,
          ),
        ];

        final aquarium = Aquarium(
          id: 'populated_aquarium',
          currentBiome: BiomeType.coralGarden,
          inhabitants: creatures,
          corals: corals,
          pearlWallet: const PearlWallet(pearls: 500),
          ecosystemHealth: 1.0,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          settings: const AquariumSettings(),
          stats: const AquariumStats(totalCreaturesDiscovered: 1, totalCoralsGrown: 1),
        );

        expect(aquarium.inhabitants.length, 1);
        expect(aquarium.corals.length, 1);
        expect(aquarium.totalCreatures, 1); // Discovered creatures
        expect(aquarium.totalCorals, 1);
      });
    });

    group('Aquarium Serialization', () {
      test('should convert aquarium to map correctly', () {
        final createdTime = DateTime.now();
        final lastActiveTime = DateTime.now();
        
        final aquarium = Aquarium(
          id: 'serialization_test',
          currentBiome: BiomeType.deepOcean,
          pearlWallet: const PearlWallet(pearls: 1500, crystals: 25),
          ecosystemHealth: 0.92,
          createdAt: createdTime,
          lastActiveAt: lastActiveTime,
          unlockedBiomes: const {
            BiomeType.shallowWaters: true,
            BiomeType.coralGarden: true,
            BiomeType.deepOcean: true,
          },
          settings: const AquariumSettings(
            enableSounds: false,
            waterClarity: 0.8,
          ),
          stats: const AquariumStats(
            totalCreaturesDiscovered: 15,
            totalCoralsGrown: 8,
            totalFocusTime: 420,
            currentStreak: 7,
            longestStreak: 12,
          ),
        );

        final map = aquarium.toMap();

        expect(map['id'], 'serialization_test');
        expect(map['current_biome'], BiomeType.deepOcean.index);
        expect(map['pearl_balance'], 1500);
        expect(map['crystal_balance'], 25);
        expect(map['ecosystem_health'], 0.92);
        expect(map['created_at'], createdTime.millisecondsSinceEpoch);
        expect(map['unlocked_biomes'], contains('0')); // Shallow waters
        expect(map['unlocked_biomes'], contains('1')); // Coral garden  
        expect(map['unlocked_biomes'], contains('2')); // Deep ocean
        expect(map['enable_sounds'], 0); // False
        expect(map['water_clarity'], 0.8);
        expect(map['total_creatures_discovered'], 15);
        expect(map['current_streak'], 7);
      });

      test('should create aquarium from map correctly', () {
        final createdTime = DateTime.now();
        final map = {
          'id': 'from_map_test',
          'current_biome': BiomeType.coralGarden.index,
          'ecosystem_health': 0.75,
          'created_at': createdTime.millisecondsSinceEpoch,
          'last_active_at': createdTime.millisecondsSinceEpoch,
          'pearl_balance': 750,
          'crystal_balance': 10,
          'unlocked_biomes': '0,1', // Shallow waters and coral garden
          'total_creatures_discovered': 8,
          'total_corals_grown': 5,
          'total_focus_time': 180,
          'current_streak': 3,
          'longest_streak': 8,
          'enable_sounds': 1,
          'enable_animations': 0,
          'enable_notifications': 1,
          'water_clarity': 0.95,
        };

        final aquarium = Aquarium.fromMap(map);

        expect(aquarium.id, 'from_map_test');
        expect(aquarium.currentBiome, BiomeType.coralGarden);
        expect(aquarium.ecosystemHealth, 0.75);
        expect(aquarium.pearlWallet.pearls, 750);
        expect(aquarium.pearlWallet.crystals, 10);
        expect(aquarium.isBiomeUnlocked(BiomeType.shallowWaters), true);
        expect(aquarium.isBiomeUnlocked(BiomeType.coralGarden), true);
        expect(aquarium.isBiomeUnlocked(BiomeType.deepOcean), false);
        expect(aquarium.settings.enableSounds, true);
        expect(aquarium.settings.enableAnimations, false);
        expect(aquarium.settings.waterClarity, 0.95);
        expect(aquarium.stats.totalCreaturesDiscovered, 8);
        expect(aquarium.stats.currentStreak, 3);
      });
    });

    group('Aquarium Properties', () {
      test('should calculate discovered creatures correctly', () {
        final creatures = [
          Creature(
            id: 'discovered1',
            name: 'Discovered Fish 1',
            species: 'Test',
            rarity: CreatureRarity.common,
            type: CreatureType.starterFish,
            habitat: BiomeType.shallowWaters,
            animationAsset: 'test.png',
            pearlValue: 10,
            requiredLevel: 1,
            description: 'Test',
            discoveryChance: 0.7,
            isDiscovered: true,
          ),
          Creature(
            id: 'undiscovered1',
            name: 'Undiscovered Fish 1',
            species: 'Test',
            rarity: CreatureRarity.common,
            type: CreatureType.starterFish,
            habitat: BiomeType.shallowWaters,
            animationAsset: 'test.png',
            pearlValue: 10,
            requiredLevel: 1,
            description: 'Test',
            discoveryChance: 0.7,
            isDiscovered: false,
          ),
          Creature(
            id: 'discovered2',
            name: 'Discovered Fish 2',
            species: 'Test',
            rarity: CreatureRarity.rare,
            type: CreatureType.starterFish,
            habitat: BiomeType.shallowWaters,
            animationAsset: 'test.png',
            pearlValue: 50,
            requiredLevel: 1,
            description: 'Test',
            discoveryChance: 0.08,
            isDiscovered: true,
          ),
        ];

        final aquarium = Aquarium(
          id: 'test',
          currentBiome: BiomeType.shallowWaters,
          inhabitants: creatures,
          pearlWallet: const PearlWallet(),
          ecosystemHealth: 1.0,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          settings: const AquariumSettings(),
          stats: const AquariumStats(),
        );

        expect(aquarium.totalCreatures, 2); // Only discovered ones
        expect(aquarium.discoveredCreatures.length, 2);
        expect(aquarium.undiscoveredCreatures.length, 1);
      });

      test('should calculate coral statistics correctly', () {
        final corals = [
          Coral(
            id: 'young_coral',
            type: CoralType.brain,
            stage: CoralStage.polyp,
            growthProgress: 0.2,
            plantedAt: DateTime.now(),
            biome: BiomeType.shallowWaters,
          ),
          Coral(
            id: 'mature_coral1',
            type: CoralType.staghorn,
            stage: CoralStage.mature,
            growthProgress: 0.7,
            plantedAt: DateTime.now(),
            biome: BiomeType.shallowWaters,
          ),
          Coral(
            id: 'mature_coral2',
            type: CoralType.fire,
            stage: CoralStage.flourishing,
            growthProgress: 1.0,
            plantedAt: DateTime.now(),
            biome: BiomeType.shallowWaters,
          ),
        ];

        final aquarium = Aquarium(
          id: 'coral_test',
          currentBiome: BiomeType.shallowWaters,
          corals: corals,
          pearlWallet: const PearlWallet(),
          ecosystemHealth: 1.0,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          settings: const AquariumSettings(),
          stats: const AquariumStats(),
        );

        expect(aquarium.totalCorals, 3);
        expect(aquarium.matureCorals, 2); // Mature and flourishing stages
        expect(aquarium.flourishingCorals.length, 1);
        expect(aquarium.healthyCorals.length, 3); // All healthy by default
      });

      test('should calculate daily pearl income correctly', () {
        final corals = [
          Coral(
            id: 'brain_coral',
            type: CoralType.brain,
            stage: CoralStage.flourishing,
            growthProgress: 1.0,
            plantedAt: DateTime.now(),
            biome: BiomeType.shallowWaters,
          ),
          Coral(
            id: 'staghorn_coral',
            type: CoralType.staghorn,
            stage: CoralStage.mature,
            growthProgress: 0.8,
            plantedAt: DateTime.now(),
            biome: BiomeType.shallowWaters,
          ),
          Coral(
            id: 'young_coral',
            type: CoralType.table,
            stage: CoralStage.polyp,
            growthProgress: 0.1,
            plantedAt: DateTime.now(),
            biome: BiomeType.shallowWaters,
          ),
        ];

        final aquarium = Aquarium(
          id: 'income_test',
          currentBiome: BiomeType.shallowWaters,
          corals: corals,
          pearlWallet: const PearlWallet(),
          ecosystemHealth: 1.0,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          settings: const AquariumSettings(),
          stats: const AquariumStats(),
        );

        // Should include income from mature/flourishing corals only
        expect(aquarium.dailyPearlIncome, greaterThan(0));
        // Young coral shouldn't contribute (not fully grown)
      });

      test('should calculate biodiversity index correctly', () {
        final creatures = List.generate(10, (i) => 
          Creature(
            id: 'creature_$i',
            name: 'Creature $i',
            species: 'Test',
            rarity: CreatureRarity.common,
            type: CreatureType.starterFish,
            habitat: BiomeType.shallowWaters,
            animationAsset: 'test.png',
            pearlValue: 10,
            requiredLevel: 1,
            description: 'Test',
            discoveryChance: 0.7,
            isDiscovered: i < 3, // Only first 3 discovered
          ),
        );

        final aquarium = Aquarium(
          id: 'biodiversity_test',
          currentBiome: BiomeType.shallowWaters,
          inhabitants: creatures,
          pearlWallet: const PearlWallet(),
          ecosystemHealth: 1.0,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          settings: const AquariumSettings(),
          stats: const AquariumStats(),
        );

        expect(aquarium.biodiversityIndex, 0.3); // 3 out of 10 discovered
      });

      test('should get current biome creatures correctly', () {
        final creatures = [
          Creature(
            id: 'shallow_fish',
            name: 'Shallow Fish',
            species: 'Test',
            rarity: CreatureRarity.common,
            type: CreatureType.starterFish,
            habitat: BiomeType.shallowWaters,
            animationAsset: 'test.png',
            pearlValue: 10,
            requiredLevel: 1,
            description: 'Test',
            discoveryChance: 0.7,
          ),
          Creature(
            id: 'deep_fish',
            name: 'Deep Fish',
            species: 'Test',
            rarity: CreatureRarity.rare,
            type: CreatureType.predator,
            habitat: BiomeType.deepOcean,
            animationAsset: 'test.png',
            pearlValue: 100,
            requiredLevel: 30,
            description: 'Test',
            discoveryChance: 0.08,
          ),
        ];

        final aquarium = Aquarium(
          id: 'biome_test',
          currentBiome: BiomeType.shallowWaters,
          inhabitants: creatures,
          pearlWallet: const PearlWallet(),
          ecosystemHealth: 1.0,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          settings: const AquariumSettings(),
          stats: const AquariumStats(),
        );

        final currentBiomeCreatures = aquarium.currentBiomeCreatures;
        expect(currentBiomeCreatures.length, 1);
        expect(currentBiomeCreatures.first.id, 'shallow_fish');
      });

      test('should get rarity distribution correctly', () {
        final creatures = [
          Creature(
            id: 'common1',
            name: 'Common 1',
            species: 'Test',
            rarity: CreatureRarity.common,
            type: CreatureType.starterFish,
            habitat: BiomeType.shallowWaters,
            animationAsset: 'test.png',
            pearlValue: 10,
            requiredLevel: 1,
            description: 'Test',
            discoveryChance: 0.7,
            isDiscovered: true,
          ),
          Creature(
            id: 'common2',
            name: 'Common 2',
            species: 'Test',
            rarity: CreatureRarity.common,
            type: CreatureType.starterFish,
            habitat: BiomeType.shallowWaters,
            animationAsset: 'test.png',
            pearlValue: 10,
            requiredLevel: 1,
            description: 'Test',
            discoveryChance: 0.7,
            isDiscovered: true,
          ),
          Creature(
            id: 'rare1',
            name: 'Rare 1',
            species: 'Test',
            rarity: CreatureRarity.rare,
            type: CreatureType.predator,
            habitat: BiomeType.deepOcean,
            animationAsset: 'test.png',
            pearlValue: 100,
            requiredLevel: 30,
            description: 'Test',
            discoveryChance: 0.08,
            isDiscovered: true,
          ),
        ];

        final aquarium = Aquarium(
          id: 'rarity_test',
          currentBiome: BiomeType.shallowWaters,
          inhabitants: creatures,
          pearlWallet: const PearlWallet(),
          ecosystemHealth: 1.0,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          settings: const AquariumSettings(),
          stats: const AquariumStats(),
        );

        final distribution = aquarium.rarityDistribution;
        expect(distribution[CreatureRarity.common], 2);
        expect(distribution[CreatureRarity.rare], 1);
        expect(distribution[CreatureRarity.uncommon], 0);
        expect(distribution[CreatureRarity.legendary], 0);
      });
    });

    group('Aquarium copyWith', () {
      test('should copy aquarium with modified fields', () {
        final original = Aquarium(
          id: 'original',
          currentBiome: BiomeType.shallowWaters,
          pearlWallet: const PearlWallet(pearls: 100),
          ecosystemHealth: 1.0,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          settings: const AquariumSettings(),
          stats: const AquariumStats(),
        );

        final modified = original.copyWith(
          currentBiome: BiomeType.coralGarden,
          ecosystemHealth: 0.8,
          pearlWallet: const PearlWallet(pearls: 200, crystals: 5),
        );

        expect(modified.id, original.id);
        expect(modified.currentBiome, BiomeType.coralGarden);
        expect(modified.ecosystemHealth, 0.8);
        expect(modified.pearlWallet.pearls, 200);
        expect(modified.pearlWallet.crystals, 5);
        expect(original.currentBiome, BiomeType.shallowWaters); // Original unchanged
        expect(original.ecosystemHealth, 1.0); // Original unchanged
      });
    });
  });

  group('PearlWallet Tests', () {
    test('should create wallet with correct initial values', () {
      const wallet1 = PearlWallet();
      const wallet2 = PearlWallet(pearls: 100, crystals: 5);

      expect(wallet1.pearls, 0);
      expect(wallet1.crystals, 0);
      expect(wallet2.pearls, 100);
      expect(wallet2.crystals, 5);
    });

    test('should add pearls correctly', () {
      const wallet = PearlWallet(pearls: 50);
      final updated = wallet.addPearls(25);

      expect(updated.pearls, 75);
      expect(wallet.pearls, 50); // Original unchanged
    });

    test('should spend pearls correctly', () {
      const wallet = PearlWallet(pearls: 100);
      final updated = wallet.spendPearls(30);

      expect(updated.pearls, 70);
      expect(wallet.pearls, 100); // Original unchanged
    });

    test('should not allow negative pearl balance', () {
      const wallet = PearlWallet(pearls: 20);
      final updated = wallet.spendPearls(30);

      expect(updated.pearls, 0); // Clamped to 0
    });

    test('should handle crystals correctly', () {
      const wallet = PearlWallet(crystals: 10);
      final added = wallet.addCrystals(5);
      final spent = added.spendCrystals(8);

      expect(added.crystals, 15);
      expect(spent.crystals, 7);
    });

    test('should check affordability correctly', () {
      const wallet = PearlWallet(pearls: 100, crystals: 5);

      expect(wallet.canAfford(50), true); // Just pearls
      expect(wallet.canAfford(150), false); // Not enough pearls
      expect(wallet.canAfford(50, 3), true); // Pearls + crystals
      expect(wallet.canAfford(50, 10), false); // Not enough crystals
      expect(wallet.canAfford(200, 3), false); // Not enough pearls
    });
  });

  group('AquariumSettings Tests', () {
    test('should create settings with default values', () {
      const settings = AquariumSettings();

      expect(settings.enableSounds, true);
      expect(settings.enableAnimations, true);
      expect(settings.enableNotifications, true);
      expect(settings.waterClarity, 1.0);
    });

    test('should copy settings with modified values', () {
      const original = AquariumSettings();
      final modified = original.copyWith(
        enableSounds: false,
        waterClarity: 0.7,
      );

      expect(modified.enableSounds, false);
      expect(modified.waterClarity, 0.7);
      expect(modified.enableAnimations, true); // Unchanged
      expect(original.enableSounds, true); // Original unchanged
    });
  });

  group('AquariumStats Tests', () {
    test('should create stats with default values', () {
      const stats = AquariumStats();

      expect(stats.totalCreaturesDiscovered, 0);
      expect(stats.totalCoralsGrown, 0);
      expect(stats.totalFocusTime, 0);
      expect(stats.currentStreak, 0);
      expect(stats.longestStreak, 0);
      expect(stats.lastSessionAt, null);
    });

    test('should format focus time correctly', () {
      const stats1 = AquariumStats(totalFocusTime: 45); // 45 minutes
      const stats2 = AquariumStats(totalFocusTime: 150); // 2 hours 30 minutes

      expect(stats1.formattedFocusTime, '45m');
      expect(stats2.formattedFocusTime, '2h 30m');
    });

    test('should calculate average session length correctly', () {
      const stats1 = AquariumStats(totalFocusTime: 100, totalCoralsGrown: 4);
      const stats2 = AquariumStats(totalFocusTime: 0, totalCoralsGrown: 0);

      expect(stats1.averageSessionLength, 25.0); // 100 / 4
      expect(stats2.averageSessionLength, 0.0); // Avoid division by zero
    });

    test('should copy stats with modified values', () {
      const original = AquariumStats();
      final modified = original.copyWith(
        totalCreaturesDiscovered: 10,
        currentStreak: 5,
        totalFocusTime: 120,
      );

      expect(modified.totalCreaturesDiscovered, 10);
      expect(modified.currentStreak, 5);
      expect(modified.totalFocusTime, 120);
      expect(modified.totalCoralsGrown, 0); // Unchanged
      expect(original.totalCreaturesDiscovered, 0); // Original unchanged
    });
  });
}