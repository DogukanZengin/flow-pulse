import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow_pulse/rendering/biome_environment_renderer.dart';
import 'package:flow_pulse/models/creature.dart';

void main() {
  group('Biome Environment Renderer Tests', () {
    testWidgets('should paint biome environment without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              painter: TestBiomeEnvironmentPainter(
                biome: BiomeType.shallowWaters,
                depth: 5.0,
                sessionProgress: 0.5,
                animationValue: 0.5,
              ),
              size: const Size(300, 300),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsOneWidget);
    });

    test('should handle all biome types', () {
      final biomes = BiomeType.values;
      
      for (final biome in biomes) {
        expect(() {
          final testPainter = TestBiomeEnvironmentPainter(
            biome: biome,
            depth: 10.0,
            sessionProgress: 0.5,
            animationValue: 0.5,
          );
          
          testPainter.testPaint(const Size(300, 300));
        }, returnsNormally);
      }
    });

    test('should handle different depth levels', () {
      final depths = [0.0, 5.0, 15.0, 25.0, 45.0, 100.0];
      
      for (final depth in depths) {
        expect(() {
          final testPainter = TestBiomeEnvironmentPainter(
            biome: BiomeType.deepOcean,
            depth: depth,
            sessionProgress: 0.5,
            animationValue: 0.5,
          );
          
          testPainter.testPaint(const Size(300, 300));
        }, returnsNormally);
      }
    });

    test('should handle session progress values', () {
      final progressValues = [0.0, 0.25, 0.5, 0.75, 1.0];
      
      for (final progress in progressValues) {
        expect(() {
          final testPainter = TestBiomeEnvironmentPainter(
            biome: BiomeType.coralGarden,
            depth: 15.0,
            sessionProgress: progress,
            animationValue: 0.5,
          );
          
          testPainter.testPaint(const Size(300, 300));
        }, returnsNormally);
      }
    });

    test('should handle animation values', () {
      final animationValues = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0];
      
      for (final value in animationValues) {
        expect(() {
          final testPainter = TestBiomeEnvironmentPainter(
            biome: BiomeType.abyssalZone,
            depth: 50.0,
            sessionProgress: 0.5,
            animationValue: value,
          );
          
          testPainter.testPaint(const Size(300, 300));
        }, returnsNormally);
      }
    });

    test('should handle edge case canvas sizes', () {
      final sizes = [
        const Size(1, 1),
        const Size(10, 10),
        const Size(500, 200),
        const Size(200, 500),
        const Size(1000, 1000),
      ];

      for (final size in sizes) {
        expect(() {
          final testPainter = TestBiomeEnvironmentPainter(
            biome: BiomeType.shallowWaters,
            depth: 10.0,
            sessionProgress: 0.5,
            animationValue: 0.5,
          );
          
          testPainter.testPaint(size);
        }, returnsNormally);
      }
    });

    group('Biome-Specific Feature Tests', () {
      test('should render shallow water features correctly', () {
        expect(() {
          final testPainter = TestBiomeEnvironmentPainter(
            biome: BiomeType.shallowWaters,
            depth: 5.0,
            sessionProgress: 0.8,
            animationValue: 0.3,
          );
          
          testPainter.testPaint(const Size(400, 400));
        }, returnsNormally);
      });

      test('should render coral garden features correctly', () {
        expect(() {
          final testPainter = TestBiomeEnvironmentPainter(
            biome: BiomeType.coralGarden,
            depth: 15.0,
            sessionProgress: 0.6,
            animationValue: 0.7,
          );
          
          testPainter.testPaint(const Size(400, 400));
        }, returnsNormally);
      });

      test('should render deep ocean features correctly', () {
        expect(() {
          final testPainter = TestBiomeEnvironmentPainter(
            biome: BiomeType.deepOcean,
            depth: 30.0,
            sessionProgress: 0.4,
            animationValue: 0.9,
          );
          
          testPainter.testPaint(const Size(400, 400));
        }, returnsNormally);
      });

      test('should render abyssal zone features correctly', () {
        expect(() {
          final testPainter = TestBiomeEnvironmentPainter(
            biome: BiomeType.abyssalZone,
            depth: 50.0,
            sessionProgress: 0.9,
            animationValue: 0.1,
          );
          
          testPainter.testPaint(const Size(400, 400));
        }, returnsNormally);
      });
    });

    group('Dynamic Lighting Tests', () {
      test('should handle surface lighting', () {
        expect(() {
          final testPainter = TestBiomeEnvironmentPainter(
            biome: BiomeType.shallowWaters,
            depth: 8.0,
            sessionProgress: 0.3,
            animationValue: 0.5,
          );
          
          testPainter.testPaint(const Size(300, 300));
        }, returnsNormally);
      });

      test('should handle filtered lighting', () {
        expect(() {
          final testPainter = TestBiomeEnvironmentPainter(
            biome: BiomeType.coralGarden,
            depth: 18.0,
            sessionProgress: 0.6,
            animationValue: 0.4,
          );
          
          testPainter.testPaint(const Size(300, 300));
        }, returnsNormally);
      });

      test('should handle artificial lighting', () {
        expect(() {
          final testPainter = TestBiomeEnvironmentPainter(
            biome: BiomeType.deepOcean,
            depth: 25.0,
            sessionProgress: 0.8,
            animationValue: 0.7,
          );
          
          testPainter.testPaint(const Size(300, 300));
        }, returnsNormally);
      });

      test('should handle bioluminescent lighting', () {
        expect(() {
          final testPainter = TestBiomeEnvironmentPainter(
            biome: BiomeType.abyssalZone,
            depth: 45.0,
            sessionProgress: 0.7,
            animationValue: 0.2,
          );
          
          testPainter.testPaint(const Size(300, 300));
        }, returnsNormally);
      });
    });

    group('Particle System Tests', () {
      test('should render plankton particles', () {
        expect(() {
          final testPainter = TestBiomeEnvironmentPainter(
            biome: BiomeType.shallowWaters,
            depth: 5.0,
            sessionProgress: 0.5,
            animationValue: 0.8,
          );
          
          testPainter.testPaint(const Size(400, 400));
        }, returnsNormally);
      });

      test('should render marine snow particles', () {
        expect(() {
          final testPainter = TestBiomeEnvironmentPainter(
            biome: BiomeType.coralGarden,
            depth: 12.0,
            sessionProgress: 0.4,
            animationValue: 0.6,
          );
          
          testPainter.testPaint(const Size(400, 400));
        }, returnsNormally);
      });

      test('should render bioluminescent particles', () {
        expect(() {
          final testPainter = TestBiomeEnvironmentPainter(
            biome: BiomeType.abyssalZone,
            depth: 40.0,
            sessionProgress: 0.8,
            animationValue: 0.3,
          );
          
          testPainter.testPaint(const Size(400, 400));
        }, returnsNormally);
      });
    });

    group('Performance Tests', () {
      test('should handle multiple rapid paint calls', () {
        final testPainter = TestBiomeEnvironmentPainter(
          biome: BiomeType.deepOcean,
          depth: 25.0,
          sessionProgress: 0.5,
          animationValue: 0.5,
        );

        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 50; i++) {
          testPainter.testPaint(const Size(300, 300));
        }
        
        stopwatch.stop();
        
        // Should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });

      test('should handle complex animations efficiently', () {
        final animationValues = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0];
        
        final stopwatch = Stopwatch()..start();
        
        for (final value in animationValues) {
          final testPainter = TestBiomeEnvironmentPainter(
            biome: BiomeType.abyssalZone,
            depth: 50.0,
            sessionProgress: 0.7,
            animationValue: value,
          );
          
          testPainter.testPaint(const Size(500, 500));
        }
        
        stopwatch.stop();
        
        expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      });
    });
  });
}

class TestBiomeEnvironmentPainter extends CustomPainter {
  final BiomeType biome;
  final double depth;
  final double sessionProgress;
  final double animationValue;

  TestBiomeEnvironmentPainter({
    required this.biome,
    required this.depth,
    required this.sessionProgress,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    BiomeEnvironmentRenderer.paintBiomeEnvironment(
      canvas,
      size,
      biome,
      depth,
      sessionProgress,
      animationValue,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  void testPaint(Size size) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    BiomeEnvironmentRenderer.paintBiomeEnvironment(
      canvas,
      size,
      biome,
      depth,
      sessionProgress,
      animationValue,
    );
    
    recorder.endRecording();
  }
}