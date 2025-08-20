import 'package:flutter_test/flutter_test.dart';
import 'package:flow_pulse/services/fast_forward_service.dart';

void main() {
  group('FastForwardService', () {
    late FastForwardService fastForward;

    setUp(() {
      fastForward = FastForwardService.instance;
      fastForward.reset(); // Ensure clean state
    });

    test('should start disabled with normal speed', () {
      expect(fastForward.isEnabled, false);
      expect(fastForward.speedMultiplier, 1.0);
      expect(fastForward.getTimerIntervalMs(), 1000);
      expect(fastForward.getSecondsPerTick(), 1);
    });

    test('should enable with specified multiplier', () {
      fastForward.enable(multiplier: 5.0);
      
      expect(fastForward.isEnabled, true);
      expect(fastForward.speedMultiplier, 5.0);
      expect(fastForward.currentPresetName, 'Fast (5x)');
    });

    test('should calculate correct timer intervals for fast forward', () {
      fastForward.enable(multiplier: 10.0);
      
      // 10x speed should tick every 100ms
      expect(fastForward.getTimerIntervalMs(), 100);
      expect(fastForward.getSecondsPerTick(), 1);
    });

    test('should calculate correct timer intervals for extreme speeds', () {
      fastForward.enable(multiplier: 60.0);
      
      // 60x speed should subtract 60 seconds per tick
      expect(fastForward.getSecondsPerTick(), 60);
    });

    test('should format time with fast forward indicator', () {
      // Normal speed
      expect(fastForward.formatTimeWithIndicator(125), '02:05');
      
      // Fast forward enabled
      fastForward.enable(multiplier: 5.0);
      expect(fastForward.formatTimeWithIndicator(125), '02:05 ⚡5.0x');
    });

    test('should apply speed presets correctly', () {
      fastForward.applyPreset('Very Fast (10x)');
      
      expect(fastForward.isEnabled, true);
      expect(fastForward.speedMultiplier, 10.0);
      expect(fastForward.currentPresetName, 'Very Fast (10x)');
    });

    test('should toggle on and off', () {
      expect(fastForward.isEnabled, false);
      
      fastForward.toggle();
      expect(fastForward.isEnabled, true);
      expect(fastForward.speedMultiplier, 5.0); // Default toggle speed
      
      fastForward.toggle();
      expect(fastForward.isEnabled, false);
    });

    test('should calculate effective session duration', () {
      fastForward.enable(multiplier: 10.0);
      
      // 1 minute accelerated = 10 minutes effective
      final acceleratedDuration = const Duration(minutes: 1);
      final effectiveDuration = fastForward.getEffectiveSessionDuration(acceleratedDuration);
      
      expect(effectiveDuration.inMinutes, 10);
    });

    test('should provide appropriate warning messages', () {
      // No warning for normal speed
      expect(fastForward.getWarningMessage(), '');
      
      // Warning for fast speeds
      fastForward.enable(multiplier: 10.0);
      expect(fastForward.getWarningMessage(), contains('FAST MODE'));
      
      // Warning for extreme speeds
      fastForward.enable(multiplier: 100.0);
      expect(fastForward.getWarningMessage(), contains('EXTREME SPEED'));
    });

    test('should handle edge cases properly', () {
      // Negative multiplier should throw error
      expect(() => fastForward.enable(multiplier: -1.0), throwsA(isA<ArgumentError>()));
      
      // Zero multiplier should throw error
      expect(() => fastForward.setSpeedMultiplier(0.0), throwsA(isA<ArgumentError>()));
      
      // Very small interval should be clamped to 10ms minimum
      fastForward.enable(multiplier: 10000.0);
      expect(fastForward.getTimerIntervalMs(), 10);
    });

    test('should reset to normal speed', () {
      fastForward.enable(multiplier: 30.0);
      expect(fastForward.isEnabled, true);
      
      fastForward.reset();
      expect(fastForward.isEnabled, false);
      expect(fastForward.speedMultiplier, 1.0);
    });

    test('should auto-enable when setting speed > 1.0', () {
      expect(fastForward.isEnabled, false);
      
      fastForward.setSpeedMultiplier(5.0);
      expect(fastForward.isEnabled, true);
      expect(fastForward.speedMultiplier, 5.0);
    });

    test('should auto-disable when setting speed to 1.0', () {
      fastForward.enable(multiplier: 5.0);
      expect(fastForward.isEnabled, true);
      
      fastForward.setSpeedMultiplier(1.0);
      expect(fastForward.isEnabled, false);
    });
  });
}