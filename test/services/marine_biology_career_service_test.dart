import 'package:flutter_test/flutter_test.dart';
import 'package:flow_pulse/services/marine_biology_career_service.dart';
import 'package:flow_pulse/models/creature.dart';

void main() {
  group('Marine Biology Career Service Tests', () {
    
    group('Level and XP Calculations', () {
      test('should calculate correct XP requirements for levels', () {
        // Level 1 should require 0 XP
        expect(MarineBiologyCareerService.getXPRequiredForLevel(1), equals(0));
        
        // Level 2 should require 100 XP
        expect(MarineBiologyCareerService.getXPRequiredForLevel(2), equals(100));
        
        // Higher levels should require progressively more XP
        final level5XP = MarineBiologyCareerService.getXPRequiredForLevel(5);
        final level10XP = MarineBiologyCareerService.getXPRequiredForLevel(10);
        final level25XP = MarineBiologyCareerService.getXPRequiredForLevel(25);
        
        expect(level5XP, lessThan(level10XP));
        expect(level10XP, lessThan(level25XP));
        
        // Should follow exponential growth
        expect(level25XP, greaterThan(level10XP * 2));
      });

      test('should calculate correct level from XP', () {
        expect(MarineBiologyCareerService.getLevelFromXP(0), equals(1));
        expect(MarineBiologyCareerService.getLevelFromXP(50), equals(1));
        expect(MarineBiologyCareerService.getLevelFromXP(100), equals(2));
        expect(MarineBiologyCareerService.getLevelFromXP(1000), greaterThan(5));
      });

      test('should have consistent level/XP relationship', () {
        for (int level = 1; level <= 20; level++) {
          final xpRequired = MarineBiologyCareerService.getXPRequiredForLevel(level);
          final calculatedLevel = MarineBiologyCareerService.getLevelFromXP(xpRequired);
          expect(calculatedLevel, equals(level));
        }
      });
    });

    group('Career Titles', () {
      test('should return correct career titles for levels', () {
        expect(MarineBiologyCareerService.getCareerTitle(1), equals('Marine Biology Intern'));
        expect(MarineBiologyCareerService.getCareerTitle(5), equals('Junior Research Assistant'));
        expect(MarineBiologyCareerService.getCareerTitle(25), equals('Field Researcher'));
        expect(MarineBiologyCareerService.getCareerTitle(50), equals('Principal Investigator'));
        expect(MarineBiologyCareerService.getCareerTitle(100), equals('Master Marine Biologist'));
      });

      test('should handle edge cases for career titles', () {
        // Level 0 should return first title
        expect(MarineBiologyCareerService.getCareerTitle(0), equals('Marine Biology Intern'));
        
        // Level above max should return highest title
        expect(MarineBiologyCareerService.getCareerTitle(150), equals('Master Marine Biologist'));
        
        // Intermediate levels should return appropriate titles
        expect(MarineBiologyCareerService.getCareerTitle(7), equals('Junior Research Assistant'));
        expect(MarineBiologyCareerService.getCareerTitle(23), equals('Research Associate'));
      });
    });

    group('Discovery XP Calculation', () {
      final testCreature = Creature(
        id: 'test_001',
        name: 'Test Fish',
        species: 'Testicus marinus',
        rarity: CreatureRarity.common,
        type: CreatureType.starterFish,
        habitat: BiomeType.shallowWaters,
        animationAsset: 'test.json',
        pearlValue: 10,
        requiredLevel: 1,
        description: 'Test creature for unit tests',
        discoveryChance: 0.5,
      );

      test('should calculate base XP correctly', () {
        final xp = MarineBiologyCareerService.calculateDiscoveryXP(
          testCreature,
          sessionDepth: 5.0,
          sessionDuration: 15,
          isFirstDiscovery: false,
          isSessionCompleted: true,
        );
        
        expect(xp, greaterThan(0));
        expect(xp, equals(testCreature.pearlValue * 1.0 * 1.0 * 1.0 * 1.0 * 1.2)); // Base * rarity * depth * completion * first * duration
      });

      test('should apply rarity multipliers', () {
        final commonXP = MarineBiologyCareerService.calculateDiscoveryXP(
          testCreature.copyWith(rarity: CreatureRarity.common),
          sessionDepth: 5.0,
          sessionDuration: 15,
        );
        
        final rareXP = MarineBiologyCareerService.calculateDiscoveryXP(
          testCreature.copyWith(rarity: CreatureRarity.rare),
          sessionDepth: 5.0,
          sessionDuration: 15,
        );
        
        expect(rareXP, greaterThan(commonXP));
      });

      test('should apply depth bonuses', () {
        final shallowXP = MarineBiologyCareerService.calculateDiscoveryXP(
          testCreature,
          sessionDepth: 5.0,
          sessionDuration: 15,
        );
        
        final deepXP = MarineBiologyCareerService.calculateDiscoveryXP(
          testCreature,
          sessionDepth: 25.0,
          sessionDuration: 15,
        );
        
        final abyssalXP = MarineBiologyCareerService.calculateDiscoveryXP(
          testCreature,
          sessionDepth: 45.0,
          sessionDuration: 90,
        );
        
        expect(deepXP, greaterThan(shallowXP));
        expect(abyssalXP, greaterThan(deepXP));
      });

      test('should apply session duration bonuses', () {
        final shortSessionXP = MarineBiologyCareerService.calculateDiscoveryXP(
          testCreature,
          sessionDepth: 5.0,
          sessionDuration: 10,
        );
        
        final longSessionXP = MarineBiologyCareerService.calculateDiscoveryXP(
          testCreature,
          sessionDepth: 5.0,
          sessionDuration: 60,
        );
        
        expect(longSessionXP, greaterThan(shortSessionXP));
      });

      test('should apply first discovery bonus', () {
        final normalXP = MarineBiologyCareerService.calculateDiscoveryXP(
          testCreature,
          sessionDepth: 5.0,
          sessionDuration: 15,
          isFirstDiscovery: false,
        );
        
        final firstDiscoveryXP = MarineBiologyCareerService.calculateDiscoveryXP(
          testCreature,
          sessionDepth: 5.0,
          sessionDuration: 15,
          isFirstDiscovery: true,
        );
        
        expect(firstDiscoveryXP, equals(normalXP * 2));
      });

      test('should apply session completion penalty', () {
        final completedXP = MarineBiologyCareerService.calculateDiscoveryXP(
          testCreature,
          sessionDepth: 5.0,
          sessionDuration: 15,
          isSessionCompleted: true,
        );
        
        final incompleteXP = MarineBiologyCareerService.calculateDiscoveryXP(
          testCreature,
          sessionDepth: 5.0,
          sessionDuration: 15,
          isSessionCompleted: false,
        );
        
        expect(incompleteXP, equals(completedXP ~/ 2));
      });
    });

    group('Research Specialization', () {
      test('should determine specialization from discoveries', () {
        // No discoveries should return general
        expect(MarineBiologyCareerService.getResearchSpecialization([]), 
               equals('General Marine Biology'));
        
        // Mostly shallow water discoveries
        final shallowCreatures = List.generate(10, (index) => Creature(
          id: 'shallow_$index',
          name: 'Shallow Fish $index',
          species: 'Shallowicus test',
          rarity: CreatureRarity.common,
          type: CreatureType.starterFish,
          habitat: BiomeType.shallowWaters,
          animationAsset: 'test.json',
          pearlValue: 10,
          requiredLevel: 1,
          description: 'Test creature',
          discoveryChance: 0.5,
        ));
        
        expect(MarineBiologyCareerService.getResearchSpecialization(shallowCreatures),
               equals('Coral Reef Ecology'));
        
        // Mostly deep ocean discoveries
        final deepCreatures = List.generate(10, (index) => Creature(
          id: 'deep_$index',
          name: 'Deep Fish $index',
          species: 'Deepicus test',
          rarity: CreatureRarity.common,
          type: CreatureType.predator,
          habitat: BiomeType.deepOcean,
          animationAsset: 'test.json',
          pearlValue: 50,
          requiredLevel: 30,
          description: 'Test creature',
          discoveryChance: 0.3,
        ));
        
        expect(MarineBiologyCareerService.getResearchSpecialization(deepCreatures),
               equals('Deep Sea Biology'));
      });
    });

    group('Certifications', () {
      final testCreatures = [
        Creature(
          id: 'test_001',
          name: 'Test Fish 1',
          species: 'Testicus first',
          rarity: CreatureRarity.common,
          type: CreatureType.starterFish,
          habitat: BiomeType.shallowWaters,
          animationAsset: 'test.json',
          pearlValue: 10,
          requiredLevel: 1,
          description: 'Test creature',
          discoveryChance: 0.5,
        ),
        Creature(
          id: 'test_002',
          name: 'Test Fish 2',
          species: 'Testicus second',
          rarity: CreatureRarity.rare,
          type: CreatureType.predator,
          habitat: BiomeType.deepOcean,
          animationAsset: 'test.json',
          pearlValue: 100,
          requiredLevel: 30,
          description: 'Test creature',
          discoveryChance: 0.1,
        ),
      ];

      test('should award level-based certifications', () {
        final certifications = MarineBiologyCareerService.getCertifications(
          testCreatures, 
          1000, 
          10
        );
        
        expect(certifications.any((c) => c.name == 'Marine Biology Fundamentals'), isTrue);
      });

      test('should award discovery-based certifications', () {
        // Create 15 shallow water discoveries to trigger biome explorer certification
        final shallowCreatures = List.generate(15, (index) => Creature(
          id: 'shallow_$index',
          name: 'Shallow Fish $index',
          species: 'Shallowicus test',
          rarity: CreatureRarity.common,
          type: CreatureType.starterFish,
          habitat: BiomeType.shallowWaters,
          animationAsset: 'test.json',
          pearlValue: 10,
          requiredLevel: 1,
          description: 'Test creature',
          discoveryChance: 0.5,
        ));
        
        final certifications = MarineBiologyCareerService.getCertifications(
          shallowCreatures, 
          1000, 
          25
        );
        
        expect(certifications.any((c) => c.name.contains('Shallow Waters Explorer')), isTrue);
      });

      test('should award rarity-based certifications', () {
        final rareCreatures = List.generate(6, (index) => Creature(
          id: 'rare_$index',
          name: 'Rare Fish $index',
          species: 'Rareicus test',
          rarity: CreatureRarity.rare,
          type: CreatureType.predator,
          habitat: BiomeType.deepOcean,
          animationAsset: 'test.json',
          pearlValue: 100,
          requiredLevel: 30,
          description: 'Test creature',
          discoveryChance: 0.1,
        ));
        
        final certifications = MarineBiologyCareerService.getCertifications(
          rareCreatures, 
          5000, 
          50
        );
        
        expect(certifications.any((c) => c.name == 'Rare Species Hunter'), isTrue);
      });

      test('should award milestone certifications', () {
        final manyCreatures = List.generate(55, (index) => Creature(
          id: 'creature_$index',
          name: 'Fish $index',
          species: 'Testicus many',
          rarity: CreatureRarity.common,
          type: CreatureType.starterFish,
          habitat: BiomeType.shallowWaters,
          animationAsset: 'test.json',
          pearlValue: 10,
          requiredLevel: 1,
          description: 'Test creature',
          discoveryChance: 0.5,
        ));
        
        final certifications = MarineBiologyCareerService.getCertifications(
          manyCreatures, 
          10000, 
          75
        );
        
        expect(certifications.any((c) => c.name == 'Species Catalog Contributor'), isTrue);
      });
    });

    group('Research Metrics', () {
      final testCreatures = [
        Creature(
          id: 'test_001',
          name: 'Test Fish 1',
          species: 'Testicus first',
          rarity: CreatureRarity.common,
          type: CreatureType.starterFish,
          habitat: BiomeType.shallowWaters,
          animationAsset: 'test.json',
          pearlValue: 10,
          requiredLevel: 1,
          description: 'Test creature',
          discoveryChance: 0.5,
          discoveredAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Creature(
          id: 'test_002',
          name: 'Test Fish 2',
          species: 'Testicus second',
          rarity: CreatureRarity.uncommon,
          type: CreatureType.reefBuilder,
          habitat: BiomeType.coralGarden,
          animationAsset: 'test.json',
          pearlValue: 25,
          requiredLevel: 10,
          description: 'Test creature',
          discoveryChance: 0.3,
          discoveredAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];

      test('should calculate discoveries per session', () {
        final metrics = MarineBiologyCareerService.calculateResearchMetrics(
          testCreatures,
          10, // 10 sessions
          600, // 10 hours
        );
        
        expect(metrics.discoveriesPerSession, equals(0.2)); // 2 discoveries / 10 sessions
      });

      test('should calculate discoveries per hour', () {
        final metrics = MarineBiologyCareerService.calculateResearchMetrics(
          testCreatures,
          10,
          600, // 10 hours in minutes
        );
        
        expect(metrics.discoveriesPerHour, equals(0.2)); // 2 discoveries / 10 hours
      });

      test('should calculate recent discoveries', () {
        final metrics = MarineBiologyCareerService.calculateResearchMetrics(
          testCreatures,
          10,
          600,
        );
        
        expect(metrics.recentDiscoveries, equals(2)); // Both discoveries within 7 days
      });

      test('should calculate diversity index', () {
        final metrics = MarineBiologyCareerService.calculateResearchMetrics(
          testCreatures,
          10,
          600,
        );
        
        // Should be > 0 since we have creatures from different biomes
        expect(metrics.diversityIndex, greaterThan(0.0));
        expect(metrics.diversityIndex, lessThanOrEqualTo(1.0));
      });

      test('should calculate research efficiency', () {
        final metrics = MarineBiologyCareerService.calculateResearchMetrics(
          testCreatures,
          10,
          600,
        );
        
        expect(metrics.researchEfficiency, greaterThan(0.0));
      });

      test('should handle edge cases', () {
        // No sessions
        final metrics1 = MarineBiologyCareerService.calculateResearchMetrics(
          testCreatures,
          0,
          0,
        );
        expect(metrics1.discoveriesPerSession, equals(0.0));
        expect(metrics1.discoveriesPerHour, equals(0.0));
        
        // No discoveries
        final metrics2 = MarineBiologyCareerService.calculateResearchMetrics(
          [],
          10,
          600,
        );
        expect(metrics2.totalDiscoveries, equals(0));
        expect(metrics2.diversityIndex, equals(0.0));
      });
    });

    group('Research Achievements', () {
      final testCreatures = List.generate(15, (index) => Creature(
        id: 'test_$index',
        name: 'Test Fish $index',
        species: 'Testicus achievement',
        rarity: CreatureRarity.common,
        type: CreatureType.starterFish,
        habitat: BiomeType.shallowWaters,
        animationAsset: 'test.json',
        pearlValue: 10,
        requiredLevel: 1,
        description: 'Test creature',
        discoveryChance: 0.5,
      ));

      final testMetrics = ResearchMetrics(
        totalDiscoveries: 15,
        discoveriesPerSession: 1.5,
        discoveriesPerHour: 2.0,
        recentDiscoveries: 5,
        diversityIndex: 0.85,
        researchEfficiency: 12.0,
        averageSessionTime: 45.0,
      );

      test('should award discovery milestone achievements', () {
        final achievements = MarineBiologyCareerService.getResearchAchievements(
          testCreatures,
          25,
          testMetrics,
        );
        
        expect(achievements.any((a) => a.name == 'Discovery Milestone'), isTrue);
      });

      test('should award level milestone achievements', () {
        final achievements = MarineBiologyCareerService.getResearchAchievements(
          testCreatures,
          25,
          testMetrics,
        );
        
        expect(achievements.any((a) => a.name == 'Career Milestone'), isTrue);
      });

      test('should award efficiency achievements', () {
        final achievements = MarineBiologyCareerService.getResearchAchievements(
          testCreatures,
          25,
          testMetrics,
        );
        
        expect(achievements.any((a) => a.name == 'Research Expert'), isTrue);
        expect(achievements.any((a) => a.name == 'Biodiversity Champion'), isTrue);
      });

      test('should have proper achievement progress', () {
        final achievements = MarineBiologyCareerService.getResearchAchievements(
          testCreatures,
          25,
          testMetrics,
        );
        
        for (final achievement in achievements) {
          expect(achievement.progress, greaterThanOrEqualTo(0.0));
          expect(achievement.progress, lessThanOrEqualTo(1.0));
          expect(achievement.current, lessThanOrEqualTo(achievement.target));
        }
      });
    });
  });
}