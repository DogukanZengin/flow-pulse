import 'package:flutter_test/flutter_test.dart';
import '../../lib/models/creature.dart';

void main() {
  group('Creature Model Tests', () {
    group('Creature Creation', () {
      test('should create creature with all required fields', () {
        final creature = Creature(
          id: 'clownfish',
          name: 'Clownfish',
          species: 'Amphiprioninae',
          rarity: CreatureRarity.common,
          type: CreatureType.starterFish,
          habitat: BiomeType.shallowWaters,
          animationAsset: 'assets/creatures/clownfish.png',
          pearlValue: 10,
          requiredLevel: 1,
          description: 'A friendly clownfish',
          discoveryChance: 0.7,
        );

        expect(creature.id, 'clownfish');
        expect(creature.name, 'Clownfish');
        expect(creature.species, 'Amphiprioninae');
        expect(creature.rarity, CreatureRarity.common);
        expect(creature.type, CreatureType.starterFish);
        expect(creature.habitat, BiomeType.shallowWaters);
        expect(creature.pearlValue, 10);
        expect(creature.requiredLevel, 1);
        expect(creature.isDiscovered, false); // Default value
        expect(creature.discoveryChance, 0.7);
      });

      test('should create discovered creature with discovery timestamp', () {
        final discoveryTime = DateTime.now();
        final creature = Creature(
          id: 'angelfish',
          name: 'Angelfish',
          species: 'Pomacanthidae',
          rarity: CreatureRarity.uncommon,
          type: CreatureType.starterFish,
          habitat: BiomeType.shallowWaters,
          animationAsset: 'assets/creatures/angelfish.png',
          pearlValue: 15,
          requiredLevel: 2,
          description: 'A beautiful angelfish',
          discoveryChance: 0.2,
          isDiscovered: true,
          discoveredAt: discoveryTime,
        );

        expect(creature.isDiscovered, true);
        expect(creature.discoveredAt, discoveryTime);
      });
    });

    group('Creature Serialization', () {
      test('should convert creature to map correctly', () {
        final creature = Creature(
          id: 'seahorse',
          name: 'Seahorse',
          species: 'Hippocampus',
          rarity: CreatureRarity.rare,
          type: CreatureType.reefBuilder,
          habitat: BiomeType.coralGarden,
          animationAsset: 'assets/creatures/seahorse.png',
          pearlValue: 60,
          requiredLevel: 12,
          description: 'A mystical seahorse',
          discoveryChance: 0.08,
          coralPreferences: ['brain', 'soft'],
        );

        final map = creature.toMap();

        expect(map['id'], 'seahorse');
        expect(map['name'], 'Seahorse');
        expect(map['rarity'], CreatureRarity.rare.index);
        expect(map['type'], CreatureType.reefBuilder.index);
        expect(map['habitat'], BiomeType.coralGarden.index);
        expect(map['pearl_value'], 60);
        expect(map['required_level'], 12);
        expect(map['is_discovered'], 0); // False = 0
        expect(map['coral_preferences'], 'brain,soft');
        expect(map['discovery_chance'], 0.08);
      });

      test('should create creature from map correctly', () {
        final map = {
          'id': 'whale_shark',
          'name': 'Whale Shark',
          'species': 'Rhincodon typus',
          'rarity': CreatureRarity.legendary.index,
          'type': CreatureType.deepSeaDweller.index,
          'habitat': BiomeType.deepOcean.index,
          'animation_asset': 'assets/creatures/whale_shark.png',
          'pearl_value': 400,
          'required_level': 40,
          'is_discovered': 1,
          'discovered_at': DateTime.now().millisecondsSinceEpoch,
          'description': 'A gentle giant of the deep',
          'coral_preferences': 'table,fire',
          'discovery_chance': 0.02,
        };

        final creature = Creature.fromMap(map);

        expect(creature.id, 'whale_shark');
        expect(creature.name, 'Whale Shark');
        expect(creature.rarity, CreatureRarity.legendary);
        expect(creature.type, CreatureType.deepSeaDweller);
        expect(creature.habitat, BiomeType.deepOcean);
        expect(creature.pearlValue, 400);
        expect(creature.requiredLevel, 40);
        expect(creature.isDiscovered, true);
        expect(creature.coralPreferences, ['table', 'fire']);
        expect(creature.discoveryChance, 0.02);
      });

      test('should handle null values in map correctly', () {
        final map = {
          'id': 'basic_fish',
          'name': 'Basic Fish',
          'species': 'Fishicus basicicus',
          'rarity': CreatureRarity.common.index,
          'type': CreatureType.starterFish.index,
          'habitat': BiomeType.shallowWaters.index,
          'animation_asset': 'assets/creatures/basic.png',
          'pearl_value': 5,
          'required_level': 1,
          'is_discovered': 0,
          'discovered_at': null,
          'description': 'A basic fish',
          'coral_preferences': null,
          'discovery_chance': 0.7,
        };

        final creature = Creature.fromMap(map);

        expect(creature.discoveredAt, null);
        expect(creature.coralPreferences, []);
        expect(creature.isDiscovered, false);
      });
    });

    group('Creature copyWith', () {
      test('should copy creature with modified fields', () {
        final original = Creature(
          id: 'original',
          name: 'Original Fish',
          species: 'Originalus fishicus',
          rarity: CreatureRarity.common,
          type: CreatureType.starterFish,
          habitat: BiomeType.shallowWaters,
          animationAsset: 'assets/original.png',
          pearlValue: 10,
          requiredLevel: 1,
          description: 'Original description',
          discoveryChance: 0.5,
        );

        final discoveryTime = DateTime.now();
        final modified = original.copyWith(
          isDiscovered: true,
          discoveredAt: discoveryTime,
          pearlValue: 20,
        );

        expect(modified.id, original.id);
        expect(modified.name, original.name);
        expect(modified.isDiscovered, true);
        expect(modified.discoveredAt, discoveryTime);
        expect(modified.pearlValue, 20);
        expect(original.isDiscovered, false); // Original unchanged
        expect(original.pearlValue, 10); // Original unchanged
      });
    });

    group('Creature Display Properties', () {
      test('should return correct display names', () {
        final creature = Creature(
          id: 'test',
          name: 'Test Creature',
          species: 'Testicus',
          rarity: CreatureRarity.legendary,
          type: CreatureType.mythical,
          habitat: BiomeType.abyssalZone,
          animationAsset: 'test.png',
          pearlValue: 1000,
          requiredLevel: 50,
          description: 'Test creature',
          discoveryChance: 0.01,
        );

        expect(creature.rarityName, 'Legendary');
        expect(creature.typeName, 'Mythical Creature');
        expect(creature.habitatName, 'Abyssal Zone');
      });
    });
  });

  group('CreatureRarity Tests', () {
    test('should have correct display names', () {
      expect(CreatureRarity.common.displayName, 'Common');
      expect(CreatureRarity.uncommon.displayName, 'Uncommon');
      expect(CreatureRarity.rare.displayName, 'Rare');
      expect(CreatureRarity.legendary.displayName, 'Legendary');
    });

    test('should have correct base discovery chances', () {
      expect(CreatureRarity.common.baseDiscoveryChance, 0.70);
      expect(CreatureRarity.uncommon.baseDiscoveryChance, 0.20);
      expect(CreatureRarity.rare.baseDiscoveryChance, 0.08);
      expect(CreatureRarity.legendary.baseDiscoveryChance, 0.02);
    });

    test('should have correct pearl multipliers', () {
      expect(CreatureRarity.common.pearlMultiplier, 1);
      expect(CreatureRarity.uncommon.pearlMultiplier, 2);
      expect(CreatureRarity.rare.pearlMultiplier, 5);
      expect(CreatureRarity.legendary.pearlMultiplier, 10);
    });
  });

  group('CreatureType Tests', () {
    test('should have correct display names', () {
      expect(CreatureType.starterFish.displayName, 'Starter Fish');
      expect(CreatureType.reefBuilder.displayName, 'Reef Builder');
      expect(CreatureType.predator.displayName, 'Predator');
      expect(CreatureType.deepSeaDweller.displayName, 'Deep Sea Dweller');
      expect(CreatureType.mythical.displayName, 'Mythical Creature');
    });

    test('should have correct level ranges', () {
      expect(CreatureType.starterFish.minLevel, 1);
      expect(CreatureType.starterFish.maxLevel, 5);
      
      expect(CreatureType.reefBuilder.minLevel, 6);
      expect(CreatureType.reefBuilder.maxLevel, 15);
      
      expect(CreatureType.predator.minLevel, 16);
      expect(CreatureType.predator.maxLevel, 30);
      
      expect(CreatureType.deepSeaDweller.minLevel, 31);
      expect(CreatureType.deepSeaDweller.maxLevel, 45);
      
      expect(CreatureType.mythical.minLevel, 46);
      expect(CreatureType.mythical.maxLevel, 999);
    });
  });

  group('BiomeType Tests', () {
    test('should have correct display names', () {
      expect(BiomeType.shallowWaters.displayName, 'Shallow Waters');
      expect(BiomeType.coralGarden.displayName, 'Coral Garden');
      expect(BiomeType.deepOcean.displayName, 'Deep Ocean');
      expect(BiomeType.abyssalZone.displayName, 'Abyssal Zone');
    });

    test('should have correct descriptions', () {
      expect(BiomeType.shallowWaters.description, 'Sunlit waters perfect for beginner marine life');
      expect(BiomeType.coralGarden.description, 'Vibrant coral reefs teeming with colorful fish');
      expect(BiomeType.deepOcean.description, 'Mysterious depths home to magnificent predators');
      expect(BiomeType.abyssalZone.description, 'The deepest mysteries of the ocean floor');
    });

    test('should have correct required levels', () {
      expect(BiomeType.shallowWaters.requiredLevel, 1);
      expect(BiomeType.coralGarden.requiredLevel, 11);
      expect(BiomeType.deepOcean.requiredLevel, 26);
      expect(BiomeType.abyssalZone.requiredLevel, 51);
    });

    test('should have correct primary colors', () {
      expect(BiomeType.shallowWaters.primaryColors, ['#87CEEB', '#00A6D6']);
      expect(BiomeType.coralGarden.primaryColors, ['#FF7F7F', '#FF8C00', '#DDA0DD']);
      expect(BiomeType.deepOcean.primaryColors, ['#0077BE', '#191970']);
      expect(BiomeType.abyssalZone.primaryColors, ['#000080', '#4B0082', '#8A2BE2']);
    });
  });
}