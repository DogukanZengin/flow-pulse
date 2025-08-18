import 'package:flutter_test/flutter_test.dart';
import 'package:flow_pulse/models/coral.dart';
import 'package:flow_pulse/models/creature.dart';

void main() {
  group('Coral Model Tests', () {
    group('Coral Creation', () {
      test('should create coral with all required fields', () {
        final plantedTime = DateTime.now();
        final coral = Coral(
          id: 'brain_coral_1',
          type: CoralType.brain,
          stage: CoralStage.polyp,
          growthProgress: 0.0,
          plantedAt: plantedTime,
          biome: BiomeType.shallowWaters,
        );

        expect(coral.id, 'brain_coral_1');
        expect(coral.type, CoralType.brain);
        expect(coral.stage, CoralStage.polyp);
        expect(coral.growthProgress, 0.0);
        expect(coral.plantedAt, plantedTime);
        expect(coral.biome, BiomeType.shallowWaters);
        expect(coral.isHealthy, true); // Default value
        expect(coral.attractedSpecies, []); // Default value
        expect(coral.sessionsGrown, 0); // Default value
      });

      test('should create mature coral with attracted species', () {
        final plantedTime = DateTime.now();
        final lastGrowthTime = DateTime.now();
        
        final coral = Coral(
          id: 'staghorn_coral_1',
          type: CoralType.staghorn,
          stage: CoralStage.mature,
          growthProgress: 0.75,
          plantedAt: plantedTime,
          lastGrowthAt: lastGrowthTime,
          biome: BiomeType.coralGarden,
          attractedSpecies: ['clownfish', 'angelfish'],
          sessionsGrown: 3,
          position: {'x': 0.3, 'y': 0.7},
        );

        expect(coral.stage, CoralStage.mature);
        expect(coral.growthProgress, 0.75);
        expect(coral.attractedSpecies, ['clownfish', 'angelfish']);
        expect(coral.sessionsGrown, 3);
        expect(coral.position['x'], 0.3);
        expect(coral.position['y'], 0.7);
      });
    });

    group('Coral Growth', () {
      test('should grow coral from session with correct progress increase', () {
        final coral = Coral(
          id: 'test_coral',
          type: CoralType.brain,
          stage: CoralStage.polyp,
          growthProgress: 0.0,
          plantedAt: DateTime.now(),
          biome: BiomeType.shallowWaters,
        );

        final grownCoral = coral.growFromSession(25); // 25 minute session

        expect(grownCoral.growthProgress, greaterThan(coral.growthProgress));
        expect(grownCoral.sessionsGrown, 1);
        expect(grownCoral.lastGrowthAt, isNotNull);
        expect(grownCoral.stage, CoralStage.flourishing); // Should be fully grown after 25 min
      });

      test('should not exceed 100% growth progress', () {
        final coral = Coral(
          id: 'test_coral',
          type: CoralType.brain,
          stage: CoralStage.mature,
          growthProgress: 0.95, // Already almost fully grown
          plantedAt: DateTime.now(),
          biome: BiomeType.shallowWaters,
        );

        final grownCoral = coral.growFromSession(30); // Long session

        expect(grownCoral.growthProgress, lessThanOrEqualTo(1.0));
        expect(grownCoral.stage, CoralStage.flourishing);
      });

      test('should apply coral type growth multipliers correctly', () {
        final brainCoral = Coral(
          id: 'brain',
          type: CoralType.brain,
          stage: CoralStage.polyp,
          growthProgress: 0.0,
          plantedAt: DateTime.now(),
          biome: BiomeType.shallowWaters,
        );

        final staghornCoral = Coral(
          id: 'staghorn',
          type: CoralType.staghorn,
          stage: CoralStage.polyp,
          growthProgress: 0.0,
          plantedAt: DateTime.now(),
          biome: BiomeType.shallowWaters,
        );

        final grownBrain = brainCoral.growFromSession(10);
        final grownStaghorn = staghornCoral.growFromSession(10);

        // Staghorn grows 20% faster (1.2x multiplier)
        expect(grownStaghorn.growthProgress, greaterThan(grownBrain.growthProgress));
      });
    });

    group('Coral Serialization', () {
      test('should convert coral to map correctly', () {
        final plantedTime = DateTime.now();
        final lastGrowthTime = DateTime.now();
        
        final coral = Coral(
          id: 'fire_coral_1',
          type: CoralType.fire,
          stage: CoralStage.flourishing,
          growthProgress: 1.0,
          plantedAt: plantedTime,
          lastGrowthAt: lastGrowthTime,
          biome: BiomeType.deepOcean,
          attractedSpecies: ['reef_shark', 'moray_eel'],
          sessionsGrown: 5,
          position: {'x': 0.8, 'y': 0.2},
        );

        final map = coral.toMap();

        expect(map['id'], 'fire_coral_1');
        expect(map['type'], CoralType.fire.index);
        expect(map['stage'], CoralStage.flourishing.index);
        expect(map['growth_progress'], 1.0);
        expect(map['planted_at'], plantedTime.millisecondsSinceEpoch);
        expect(map['last_growth_at'], lastGrowthTime.millisecondsSinceEpoch);
        expect(map['biome'], BiomeType.deepOcean.index);
        expect(map['attracted_species'], 'reef_shark,moray_eel');
        expect(map['sessions_grown'], 5);
        expect(map['position_x'], 0.8);
        expect(map['position_y'], 0.2);
      });

      test('should create coral from map correctly', () {
        final plantedTime = DateTime.now();
        final map = {
          'id': 'soft_coral_test',
          'type': CoralType.soft.index,
          'stage': CoralStage.juvenile.index,
          'growth_progress': 0.35,
          'planted_at': plantedTime.millisecondsSinceEpoch,
          'last_growth_at': null,
          'is_healthy': 1,
          'attracted_species': 'butterflyfish',
          'sessions_grown': 1,
          'biome': BiomeType.coralGarden.index,
          'position_x': 0.5,
          'position_y': 0.6,
        };

        final coral = Coral.fromMap(map);

        expect(coral.id, 'soft_coral_test');
        expect(coral.type, CoralType.soft);
        expect(coral.stage, CoralStage.juvenile);
        expect(coral.growthProgress, 0.35);
        expect(coral.plantedAt.millisecondsSinceEpoch, plantedTime.millisecondsSinceEpoch);
        expect(coral.lastGrowthAt, null);
        expect(coral.attractedSpecies, ['butterflyfish']);
        expect(coral.sessionsGrown, 1);
        expect(coral.position['x'], 0.5);
        expect(coral.position['y'], 0.6);
      });
    });

    group('Coral Properties', () {
      test('should correctly identify fully grown coral', () {
        final grownCoral = Coral(
          id: 'grown',
          type: CoralType.brain,
          stage: CoralStage.flourishing,
          growthProgress: 1.0,
          plantedAt: DateTime.now(),
          biome: BiomeType.shallowWaters,
        );

        final growingCoral = Coral(
          id: 'growing',
          type: CoralType.brain,
          stage: CoralStage.mature,
          growthProgress: 0.6,
          plantedAt: DateTime.now(),
          biome: BiomeType.shallowWaters,
        );

        expect(grownCoral.isFullyGrown, true);
        expect(growingCoral.isFullyGrown, false);
      });

      test('should correctly identify corals that can attract rare species', () {
        final flourishingCoral = Coral(
          id: 'flourishing',
          type: CoralType.table,
          stage: CoralStage.flourishing,
          growthProgress: 0.9,
          plantedAt: DateTime.now(),
          biome: BiomeType.deepOcean,
        );

        final youngCoral = Coral(
          id: 'young',
          type: CoralType.table,
          stage: CoralStage.polyp,
          growthProgress: 0.1,
          plantedAt: DateTime.now(),
          biome: BiomeType.deepOcean,
        );

        expect(flourishingCoral.canAttractRareSpecies, true);
        expect(youngCoral.canAttractRareSpecies, false);
      });

      test('should calculate daily pearl bonus correctly', () {
        final matureCoral = Coral(
          id: 'mature',
          type: CoralType.brain,
          stage: CoralStage.mature,
          growthProgress: 1.0,
          plantedAt: DateTime.now(),
          biome: BiomeType.shallowWaters,
        );

        final youngCoral = Coral(
          id: 'young',
          type: CoralType.brain,
          stage: CoralStage.polyp,
          growthProgress: 0.3,
          plantedAt: DateTime.now(),
          biome: BiomeType.shallowWaters,
        );

        expect(matureCoral.dailyPearlBonus, greaterThan(0));
        expect(youngCoral.dailyPearlBonus, 0); // Not fully grown
      });
    });

    group('Coral copyWith', () {
      test('should copy coral with modified fields', () {
        final original = Coral(
          id: 'original',
          type: CoralType.brain,
          stage: CoralStage.polyp,
          growthProgress: 0.2,
          plantedAt: DateTime.now(),
          biome: BiomeType.shallowWaters,
        );

        final modified = original.copyWith(
          stage: CoralStage.mature,
          growthProgress: 0.7,
          sessionsGrown: 3,
        );

        expect(modified.id, original.id);
        expect(modified.type, original.type);
        expect(modified.stage, CoralStage.mature);
        expect(modified.growthProgress, 0.7);
        expect(modified.sessionsGrown, 3);
        expect(original.stage, CoralStage.polyp); // Original unchanged
        expect(original.growthProgress, 0.2); // Original unchanged
      });
    });
  });

  group('CoralType Tests', () {
    test('should have correct display names', () {
      expect(CoralType.brain.displayName, 'Brain Coral');
      expect(CoralType.staghorn.displayName, 'Staghorn Coral');
      expect(CoralType.table.displayName, 'Table Coral');
      expect(CoralType.soft.displayName, 'Soft Coral');
      expect(CoralType.fire.displayName, 'Fire Coral');
    });

    test('should have correct benefits', () {
      expect(CoralType.brain.benefit, '+25% focus session XP');
      expect(CoralType.staghorn.benefit, 'Attracts small fish faster');
      expect(CoralType.table.benefit, 'Shelter for larger species');
      expect(CoralType.soft.benefit, 'Beautiful particle effects');
      expect(CoralType.fire.benefit, 'Reduces pollution effects');
    });

    test('should have correct growth multipliers', () {
      expect(CoralType.brain.growthMultiplier, 1.0);
      expect(CoralType.staghorn.growthMultiplier, 1.2); // 20% faster
      expect(CoralType.table.growthMultiplier, 0.8); // 20% slower
      expect(CoralType.soft.growthMultiplier, 1.1); // 10% faster
      expect(CoralType.fire.growthMultiplier, 0.9); // 10% slower
    });

    test('should have correct XP multipliers', () {
      expect(CoralType.brain.xpMultiplier, 1.25); // +25% XP
      expect(CoralType.staghorn.xpMultiplier, 1.0);
      expect(CoralType.table.xpMultiplier, 1.0);
      expect(CoralType.soft.xpMultiplier, 1.0);
      expect(CoralType.fire.xpMultiplier, 1.0);
    });

    test('should have correct pearl costs', () {
      expect(CoralType.brain.pearlCost, 50);
      expect(CoralType.staghorn.pearlCost, 25);
      expect(CoralType.table.pearlCost, 100);
      expect(CoralType.soft.pearlCost, 40);
      expect(CoralType.fire.pearlCost, 75);
    });

    test('should have correct preferred creature types', () {
      expect(CoralType.brain.preferredCreatureTypes, ['starterFish', 'reefBuilder']);
      expect(CoralType.staghorn.preferredCreatureTypes, ['starterFish']);
      expect(CoralType.table.preferredCreatureTypes, ['predator', 'deepSeaDweller']);
      expect(CoralType.soft.preferredCreatureTypes, ['reefBuilder', 'starterFish']);
      expect(CoralType.fire.preferredCreatureTypes, ['predator']);
    });
  });

  group('CoralStage Tests', () {
    test('should have correct display names', () {
      expect(CoralStage.polyp.displayName, 'Polyp');
      expect(CoralStage.juvenile.displayName, 'Juvenile');
      expect(CoralStage.mature.displayName, 'Mature');
      expect(CoralStage.flourishing.displayName, 'Flourishing');
    });

    test('should have correct progress ranges', () {
      expect(CoralStage.polyp.minProgress, 0.0);
      expect(CoralStage.polyp.maxProgress, 0.25);
      
      expect(CoralStage.juvenile.minProgress, 0.25);
      expect(CoralStage.juvenile.maxProgress, 0.50);
      
      expect(CoralStage.mature.minProgress, 0.50);
      expect(CoralStage.mature.maxProgress, 0.75);
      
      expect(CoralStage.flourishing.minProgress, 0.75);
      expect(CoralStage.flourishing.maxProgress, 1.0);
    });

    test('should have correct bonus multipliers', () {
      expect(CoralStage.polyp.bonusMultiplier, 1);
      expect(CoralStage.juvenile.bonusMultiplier, 1);
      expect(CoralStage.mature.bonusMultiplier, 2);
      expect(CoralStage.flourishing.bonusMultiplier, 3);
    });

    test('should correctly identify particle effects capability', () {
      expect(CoralStage.polyp.hasParticleEffects, false);
      expect(CoralStage.juvenile.hasParticleEffects, false);
      expect(CoralStage.mature.hasParticleEffects, false);
      expect(CoralStage.flourishing.hasParticleEffects, true);
    });

    test('should correctly identify rare species attraction capability', () {
      expect(CoralStage.polyp.canAttractRareSpecies, false);
      expect(CoralStage.juvenile.canAttractRareSpecies, false);
      expect(CoralStage.mature.canAttractRareSpecies, true);
      expect(CoralStage.flourishing.canAttractRareSpecies, true);
    });
  });
}