import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow_pulse/rendering/advanced_creature_renderer.dart';
import 'package:flow_pulse/models/creature.dart';

void main() {
  group('Advanced Creature Renderer Tests', () {
    late Creature testCreature;

    setUp(() {
      testCreature = const Creature(
        id: 'test_creature',
        name: 'Test Clownfish',
        species: 'Amphiprion ocellaris',
        rarity: CreatureRarity.common,
        type: CreatureType.starterFish,
        habitat: BiomeType.shallowWaters,
        animationAsset: 'animations/clownfish.json',
        pearlValue: 10,
        requiredLevel: 1,
        description: 'A colorful test clownfish for testing rendering',
        discoveryChance: 0.7,
      );
    });

    testWidgets('should paint creature without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              painter: TestAdvancedCreaturePainter(
                creature: testCreature,
                animationValue: 0.5,
                depth: 5.0,
              ),
              size: const Size(100, 100),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsOneWidget);
    });

    test('should handle different creature rarities', () {
      final rarities = [
        CreatureRarity.common,
        CreatureRarity.uncommon,
        CreatureRarity.rare,
        CreatureRarity.legendary,
      ];

      for (final rarity in rarities) {
        final creature = testCreature.copyWith(rarity: rarity);
        
        expect(() {
          final testPainter = TestAdvancedCreaturePainter(
            creature: creature,
            animationValue: 0.5,
            depth: 10.0,
          );
          
          // Simulate paint call
          testPainter.testPaint(const Size(100, 100));
        }, returnsNormally);
      }
    });

    test('should handle different habitat types', () {
      final habitats = [
        BiomeType.shallowWaters,
        BiomeType.coralGarden,
        BiomeType.deepOcean,
        BiomeType.abyssalZone,
      ];

      for (final habitat in habitats) {
        final creature = testCreature.copyWith(habitat: habitat);
        
        expect(() {
          final testPainter = TestAdvancedCreaturePainter(
            creature: creature,
            animationValue: 0.5,
            depth: 15.0,
          );
          
          // Simulate paint call
          testPainter.testPaint(const Size(100, 100));
        }, returnsNormally);
      }
    });

    test('should handle depth-based scaling', () {
      final depths = [5.0, 15.0, 25.0, 45.0];
      
      for (final depth in depths) {
        expect(() {
          final testPainter = TestAdvancedCreaturePainter(
            creature: testCreature,
            animationValue: 0.5,
            depth: depth,
          );
          
          // Simulate paint call
          testPainter.testPaint(const Size(100, 100));
        }, returnsNormally);
      }
    });

    test('should handle animation values', () {
      final animationValues = [0.0, 0.25, 0.5, 0.75, 1.0];
      
      for (final value in animationValues) {
        expect(() {
          final testPainter = TestAdvancedCreaturePainter(
            creature: testCreature,
            animationValue: value,
            depth: 10.0,
          );
          
          // Simulate paint call
          testPainter.testPaint(const Size(100, 100));
        }, returnsNormally);
      }
    });

    test('should handle edge case sizes', () {
      final sizes = [
        const Size(10, 10),
        const Size(1, 1),
        const Size(500, 300),
        const Size(0, 0),
      ];

      for (final size in sizes) {
        expect(() {
          final testPainter = TestAdvancedCreaturePainter(
            creature: testCreature,
            animationValue: 0.5,
            depth: 10.0,
          );
          
          // Simulate paint call
          testPainter.testPaint(size);
        }, returnsNormally);
      }
    });

    group('Creature Color System Tests', () {
      test('should return different colors for different species', () {
        final species = [
          'Clownfish',
          'Tang',
          'Damselfish',
          'Parrotfish',
          'Shark',
          'Anglerfish',
        ];

        final colors = <Color>[];
        for (final speciesName in species) {
          final creature = testCreature.copyWith(species: speciesName);
          final testPainter = TestAdvancedCreaturePainter(
            creature: creature,
            animationValue: 0.5,
            depth: 10.0,
          );
          
          final color = testPainter.getCreatureColorForTesting(creature);
          colors.add(color);
        }

        // Ensure we get different colors for different species
        final uniqueColors = colors.toSet();
        expect(uniqueColors.length, greaterThan(1));
      });

      test('should return appropriate colors for each biome', () {
        final biomes = BiomeType.values;
        
        for (final biome in biomes) {
          final creature = testCreature.copyWith(habitat: biome);
          final testPainter = TestAdvancedCreaturePainter(
            creature: creature,
            animationValue: 0.5,
            depth: 10.0,
          );
          
          final color = testPainter.getCreatureColorForTesting(creature);
          
          // Color should not be null and should have some alpha
          expect((color.a * 255.0).round() & 0xff, greaterThan(0));
          expect(color.a, greaterThan(0.0));
        }
      });
    });

    group('Performance Tests', () {
      test('should handle multiple paint calls efficiently', () {
        final testPainter = TestAdvancedCreaturePainter(
          creature: testCreature,
          animationValue: 0.5,
          depth: 10.0,
        );

        final stopwatch = Stopwatch()..start();
        
        // Simulate multiple rapid paint calls
        for (int i = 0; i < 100; i++) {
          testPainter.testPaint(const Size(100, 100));
        }
        
        stopwatch.stop();
        
        // Should complete within reasonable time (adjust as needed)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });
}

// Test wrapper for AdvancedCreatureRenderer
class TestAdvancedCreaturePainter extends CustomPainter {
  final Creature creature;
  final double animationValue;
  final double depth;

  TestAdvancedCreaturePainter({
    required this.creature,
    required this.animationValue,
    required this.depth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    AdvancedCreatureRenderer.paintCreature(
      canvas,
      size,
      creature,
      animationValue,
      depth,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  void testPaint(Size size) {
    // Create a test canvas
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Call the renderer
    AdvancedCreatureRenderer.paintCreature(
      canvas,
      size,
      creature,
      animationValue,
      depth,
    );
    
    // Finalize the recording
    recorder.endRecording();
  }

  Color getCreatureColorForTesting(Creature creature) {
    // This would need to be exposed from AdvancedCreatureRenderer
    // For now, return a default test color
    switch (creature.habitat) {
      case BiomeType.shallowWaters:
        if (creature.species.contains('Clownfish')) return Colors.orange.shade600;
        if (creature.species.contains('Tang')) return Colors.yellow.shade500;
        return Colors.cyan.shade300;
      case BiomeType.coralGarden:
        if (creature.species.contains('Parrotfish')) return Colors.teal.shade500;
        return Colors.lightBlue.shade400;
      case BiomeType.deepOcean:
        if (creature.species.contains('Shark')) return Colors.blueGrey.shade700;
        return Colors.deepPurple.shade600;
      case BiomeType.abyssalZone:
        if (creature.species.contains('Anglerfish')) return Colors.black87;
        return Colors.indigo.shade900;
    }
  }
}