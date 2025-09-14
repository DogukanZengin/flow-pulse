import 'package:flutter_test/flutter_test.dart';
import 'package:flow_pulse/services/marine_biology_career_service.dart';
import 'package:flow_pulse/models/creature.dart';

void main() {
  group('Marine Biology Career Service Tests', () {

    group('RP-based Career Progression', () {
      test('should return correct career titles for RP values', () {
        expect(MarineBiologyCareerService.getCareerTitle(0), equals('Marine Biology Intern'));
        expect(MarineBiologyCareerService.getCareerTitle(50), equals('Junior Research Assistant'));
        expect(MarineBiologyCareerService.getCareerTitle(500), equals('Research Associate'));
        expect(MarineBiologyCareerService.getCareerTitle(1400), equals('Senior Marine Biologist'));
        expect(MarineBiologyCareerService.getCareerTitle(10500), equals('Master Marine Biologist'));
      });

      test('should calculate next career milestone correctly', () {
        final milestone = MarineBiologyCareerService.getNextCareerMilestone(100);
        expect(milestone, isNotNull);
        expect(milestone!['requiredRP'], equals(150));
        expect(milestone['title'], equals('Research Assistant'));
        expect(milestone['rpNeeded'], equals(50));
      });

      test('should return null for max level milestone', () {
        final milestone = MarineBiologyCareerService.getNextCareerMilestone(15000);
        expect(milestone, isNull);
      });

      test('should calculate career progress correctly', () {
        // Progress from Junior Research Assistant (50 RP) to Research Assistant (150 RP)
        final progress = MarineBiologyCareerService.getCareerProgress(100);
        expect(progress, equals(0.5)); // 50 out of 100 RP range
      });

      test('should return 1.0 progress for max level', () {
        final progress = MarineBiologyCareerService.getCareerProgress(15000);
        expect(progress, equals(1.0));
      });
    });

    group('Career Title Edge Cases', () {
      test('should handle edge cases for career titles', () {
        // 0 RP should return first title
        expect(MarineBiologyCareerService.getCareerTitle(0), equals('Marine Biology Intern'));

        // RP above max should return highest title
        expect(MarineBiologyCareerService.getCareerTitle(15000), equals('Master Marine Biologist'));

        // Intermediate RP values should return appropriate titles
        expect(MarineBiologyCareerService.getCareerTitle(75), equals('Junior Research Assistant'));
        expect(MarineBiologyCareerService.getCareerTitle(1200), equals('Marine Biologist'));
      });

      test('should use ResearchPointsConstants thresholds', () {
        // Test key milestones from ResearchPointsConstants
        expect(MarineBiologyCareerService.getCareerTitle(150), equals('Research Assistant'));
        expect(MarineBiologyCareerService.getCareerTitle(750), equals('Field Researcher'));
        expect(MarineBiologyCareerService.getCareerTitle(2750), equals('Principal Investigator'));
        expect(MarineBiologyCareerService.getCareerTitle(5250), equals('Marine Biology Professor'));
      });
    });

    group('Discovery RP Calculation', () {
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

      test('should calculate base RP correctly', () {
        final rp = MarineBiologyCareerService.calculateDiscoveryRP(
          testCreature,
          cumulativeRP: 100,
          sessionDuration: 25,
          isFirstDiscovery: false,
          isSessionCompleted: true,
          currentStreak: 1,
        );

        expect(rp, greaterThan(0));
        expect(rp, lessThanOrEqualTo(15)); // Capped at 15
      });

      test('should apply rarity multipliers', () {
        final commonRP = MarineBiologyCareerService.calculateDiscoveryRP(
          testCreature.copyWith(rarity: CreatureRarity.common),
          cumulativeRP: 100,
          sessionDuration: 25,
        );

        final rareRP = MarineBiologyCareerService.calculateDiscoveryRP(
          testCreature.copyWith(rarity: CreatureRarity.rare),
          cumulativeRP: 100,
          sessionDuration: 25,
        );

        expect(rareRP, greaterThan(commonRP));
      });

      test('should apply RP milestone bonuses', () {
        // Use a higher pearl value creature to see bonus differences more clearly
        final highValueCreature = testCreature.copyWith(pearlValue: 20);

        final beginnerRP = MarineBiologyCareerService.calculateDiscoveryRP(
          highValueCreature,
          cumulativeRP: 25, // Beginner level (1.0x multiplier)
          sessionDuration: 25,
        );

        final assistantRP = MarineBiologyCareerService.calculateDiscoveryRP(
          highValueCreature,
          cumulativeRP: 200, // Research Assistant level (1.3x multiplier)
          sessionDuration: 25,
        );

        final expertRP = MarineBiologyCareerService.calculateDiscoveryRP(
          highValueCreature,
          cumulativeRP: 3000, // Senior Research Scientist level (2.0x multiplier)
          sessionDuration: 25,
        );

        expect(assistantRP, greaterThan(beginnerRP));
        expect(expertRP, greaterThan(assistantRP));
      });

      test('should apply streak bonuses instead of duration bonuses', () {
        final lowStreakRP = MarineBiologyCareerService.calculateDiscoveryRP(
          testCreature,
          cumulativeRP: 100,
          sessionDuration: 25,
          currentStreak: 1,
        );

        final highStreakRP = MarineBiologyCareerService.calculateDiscoveryRP(
          testCreature,
          cumulativeRP: 100,
          sessionDuration: 25,
          currentStreak: 30, // Month+ streak
        );

        expect(highStreakRP, greaterThan(lowStreakRP));
      });

      test('should apply first discovery bonus', () {
        final normalRP = MarineBiologyCareerService.calculateDiscoveryRP(
          testCreature,
          cumulativeRP: 100,
          sessionDuration: 25,
          isFirstDiscovery: false,
        );

        final firstDiscoveryRP = MarineBiologyCareerService.calculateDiscoveryRP(
          testCreature,
          cumulativeRP: 100,
          sessionDuration: 25,
          isFirstDiscovery: true,
        );

        expect(firstDiscoveryRP, greaterThan(normalRP));
      });

      test('should apply session completion penalty', () {
        final completedRP = MarineBiologyCareerService.calculateDiscoveryRP(
          testCreature,
          cumulativeRP: 100,
          sessionDuration: 25,
          isSessionCompleted: true,
        );

        final incompleteRP = MarineBiologyCareerService.calculateDiscoveryRP(
          testCreature,
          cumulativeRP: 100,
          sessionDuration: 25,
          isSessionCompleted: false,
        );

        expect(incompleteRP, lessThan(completedRP));
      });

      test('should enforce RP cap to prevent exploitation', () {
        // Even with max bonuses, should not exceed 15 RP
        final maxRP = MarineBiologyCareerService.calculateDiscoveryRP(
          testCreature.copyWith(rarity: CreatureRarity.legendary, pearlValue: 200),
          cumulativeRP: 10000, // Max career level
          sessionDuration: 120,
          isFirstDiscovery: true,
          isSessionCompleted: true,
          currentStreak: 365, // Max streak
        );

        expect(maxRP, lessThanOrEqualTo(15));
        expect(maxRP, greaterThanOrEqualTo(1));
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

      test('should award RP-based certifications', () {
        final certifications = MarineBiologyCareerService.getCertifications(
          testCreatures,
          1500 // 1500 RP (Senior Marine Biologist level)
        );

        expect(certifications.any((c) => c.name == 'Marine Biology Fundamentals'), isTrue);
        expect(certifications.any((c) => c.name == 'Field Research Certification'), isTrue);
        expect(certifications.any((c) => c.name == 'Senior Researcher Certification'), isTrue);
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
          1000 // 1000 RP
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
          5000 // 5000 RP
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
          10000 // 10000 RP
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
          1500, // 1500 RP
          testMetrics,
        );

        expect(achievements.any((a) => a.name == 'Discovery Milestone'), isTrue);
      });

      test('should award RP milestone achievements', () {
        final achievements = MarineBiologyCareerService.getResearchAchievements(
          testCreatures,
          1500, // 1500 RP (Senior Marine Biologist level)
          testMetrics,
        );

        expect(achievements.any((a) => a.name == 'Career Milestone'), isTrue);
      });

      test('should award efficiency achievements', () {
        final achievements = MarineBiologyCareerService.getResearchAchievements(
          testCreatures,
          1500, // 1500 RP
          testMetrics,
        );

        expect(achievements.any((a) => a.name == 'Research Expert'), isTrue);
        expect(achievements.any((a) => a.name == 'Biodiversity Champion'), isTrue);
      });

      test('should have proper achievement progress', () {
        final achievements = MarineBiologyCareerService.getResearchAchievements(
          testCreatures,
          1500, // 1500 RP
          testMetrics,
        );

        for (final achievement in achievements) {
          expect(achievement.progress, greaterThanOrEqualTo(0.0));
          expect(achievement.progress, lessThanOrEqualTo(1.0));
          // Career milestones and Discovery milestones use counts that can exceed target
          // Only efficiency achievements should strictly have current <= target
          if (achievement.name == 'Research Expert' || achievement.name == 'Biodiversity Champion') {
            expect(achievement.current, lessThanOrEqualTo(achievement.target));
          }
        }
      });
    });
  });
}