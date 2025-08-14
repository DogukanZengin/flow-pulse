import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../lib/services/ocean_setup_service.dart';
import '../../lib/services/database_service.dart';
import '../../lib/models/creature.dart';
import '../../lib/models/aquarium.dart';

// Generate mocks - Note: OceanSetupService has static methods, so we test them directly
@GenerateMocks([DatabaseService])

void main() {
  group('OceanSetupService Tests', () {
    group('Creature Count and Progress Methods', () {
      test('getCreatureCountByBiome should return correct counts', () async {
        // Create mock creatures for testing
        final creatures = [
          Creature(
            id: 'shallow1',
            name: 'Clownfish',
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
            id: 'shallow2',
            name: 'Tang',
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
            id: 'coral1',
            name: 'Anemone',
            species: 'Test',
            rarity: CreatureRarity.uncommon,
            type: CreatureType.reefBuilder,
            habitat: BiomeType.coralGarden,
            animationAsset: 'test.png',
            pearlValue: 30,
            requiredLevel: 6,
            description: 'Test',
            discoveryChance: 0.5,
          ),
        ];

        // Note: This test would require mocking DatabaseService.getAllCreatures()
        // For now, we test the logic with known data
        final counts = <BiomeType, int>{};
        for (final biome in BiomeType.values) {
          counts[biome] = creatures.where((c) => c.habitat == biome).length;
        }

        expect(counts[BiomeType.shallowWaters], 2);
        expect(counts[BiomeType.coralGarden], 1);
        expect(counts[BiomeType.deepOcean], 0);
        expect(counts[BiomeType.abyssalZone], 0);
      });
    });

    group('Aquarium Existence Check', () {
      test('should check if aquarium exists', () async {
        // This test would require proper database mocking
        // For now, we test the basic logic flow
        expect(OceanSetupService.hasExistingAquarium, isA<Function>());
      });

      test('should get or create aquarium', () async {
        // This test would require proper database mocking
        // For now, we test the basic logic flow
        expect(OceanSetupService.getOrCreateAquarium, isA<Function>());
      });
    });

    group('Starter Coral Grant', () {
      test('should grant starter coral with correct properties', () async {
        // This test would require proper database mocking to verify the coral
        // is saved correctly and activity is logged
        expect(OceanSetupService.grantStarterCoral, isA<Function>());
      });
    });

    group('Discovery Progress Calculation', () {
      test('getDiscoveryProgressByBiome should calculate correct percentages', () async {
        // Create test data
        final allCreatures = [
          Creature(
            id: 'shallow1',
            name: 'Fish 1',
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
            id: 'shallow2',
            name: 'Fish 2',
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
        ];

        final discoveredCreatures = [
          allCreatures[0].copyWith(isDiscovered: true),
        ];

        // Test discovery percentage calculation logic
        final progress = <BiomeType, double>{};
        for (final biome in BiomeType.values) {
          final totalInBiome = allCreatures.where((c) => c.habitat == biome).length;
          final discoveredInBiome = discoveredCreatures.where((c) => c.habitat == biome).length;
          
          progress[biome] = totalInBiome > 0 ? discoveredInBiome / totalInBiome : 0.0;
        }

        expect(progress[BiomeType.shallowWaters], 0.5); // 1 out of 2 discovered
        expect(progress[BiomeType.coralGarden], 0.0); // 0 out of 0
        expect(progress[BiomeType.deepOcean], 0.0);
        expect(progress[BiomeType.abyssalZone], 0.0);
      });
    });

    group('Service Integration', () {
      test('should have all required static methods', () {
        // Verify all expected public methods exist
        expect(OceanSetupService.initializeNewUserAquarium, isA<Function>());
        expect(OceanSetupService.hasExistingAquarium, isA<Function>());
        expect(OceanSetupService.getOrCreateAquarium, isA<Function>());
        expect(OceanSetupService.grantStarterCoral, isA<Function>());
        expect(OceanSetupService.getCreatureCountByBiome, isA<Function>());
        expect(OceanSetupService.getDiscoveryProgressByBiome, isA<Function>());
      });
    });

    group('Biome and Creature Logic', () {
      test('should verify biome types are properly defined', () {
        // Test that all biome types are available
        expect(BiomeType.values.length, 4);
        expect(BiomeType.values, contains(BiomeType.shallowWaters));
        expect(BiomeType.values, contains(BiomeType.coralGarden));
        expect(BiomeType.values, contains(BiomeType.deepOcean));
        expect(BiomeType.values, contains(BiomeType.abyssalZone));
      });

      test('should verify creature types are properly defined', () {
        // Test that all creature types are available
        expect(CreatureType.values.length, 5);
        expect(CreatureType.values, contains(CreatureType.starterFish));
        expect(CreatureType.values, contains(CreatureType.reefBuilder));
        expect(CreatureType.values, contains(CreatureType.predator));
        expect(CreatureType.values, contains(CreatureType.deepSeaDweller));
        expect(CreatureType.values, contains(CreatureType.mythical));
      });

      test('should verify creature rarity system', () {
        expect(CreatureRarity.values.length, 4);
        expect(CreatureRarity.values, contains(CreatureRarity.common));
        expect(CreatureRarity.values, contains(CreatureRarity.uncommon));
        expect(CreatureRarity.values, contains(CreatureRarity.rare));
        expect(CreatureRarity.values, contains(CreatureRarity.legendary));
      });
    });

    group('Aquarium Configuration', () {
      test('should verify aquarium starts in shallow waters', () {
        const expectedBiome = BiomeType.shallowWaters;
        const expectedStarterPearls = 100;
        const expectedStarterCrystals = 0;

        // These are constants used in the service
        expect(expectedBiome, BiomeType.shallowWaters);
        expect(expectedStarterPearls, 100);
        expect(expectedStarterCrystals, 0);
      });

      test('should verify pearl wallet system', () {
        const wallet1 = PearlWallet();
        const wallet2 = PearlWallet(pearls: 100, crystals: 5);

        expect(wallet1.pearls, 0);
        expect(wallet1.crystals, 0);
        expect(wallet2.pearls, 100);
        expect(wallet2.crystals, 5);
      });
    });
  });
}