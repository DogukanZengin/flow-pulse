import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/biome_creature.dart';
import '../models/creature.dart';

/// Optimized animation controller for biome-specific creature movement
/// Manages multiple creatures with shared performance optimizations
class BiomeAnimationController extends ChangeNotifier {
  final TickerProvider _vsync;
  final BiomeType _biome;

  late AnimationController _masterController;
  late List<BiomeCreatureAnimation> _creatureAnimations;

  bool _disposed = false;

  BiomeAnimationController({
    required TickerProvider vsync,
    required BiomeType biome,
  }) : _vsync = vsync, _biome = biome {
    _initializeAnimations();
  }

  void _initializeAnimations() {
    final creatureCount = BiomeCreature.getCreatureCount(_biome);
    final baseDuration = BiomeCreature.getAnimationDuration(_biome);

    // Single master controller for performance
    _masterController = AnimationController(
      duration: Duration(seconds: baseDuration),
      vsync: _vsync,
    );

    // Create individual creature animations
    _creatureAnimations = List.generate(
      creatureCount,
      (index) => BiomeCreatureAnimation.create(
        biome: _biome,
        index: index,
        masterController: _masterController,
      ),
    );

    _masterController.repeat();
  }

  /// Get animation data for a specific creature index
  BiomeCreatureAnimation getCreatureAnimation(int index) {
    if (index < 0 || index >= _creatureAnimations.length) {
      return _creatureAnimations.first; // Fallback
    }
    return _creatureAnimations[index];
  }

  /// Get all creature animations for the current biome
  List<BiomeCreatureAnimation> get allAnimations => _creatureAnimations;

  /// Get current biome
  BiomeType get biome => _biome;

  /// Get creature count for current biome
  int get creatureCount => _creatureAnimations.length;

  /// Pause all animations
  void pause() {
    if (!_disposed) {
      _masterController.stop();
    }
  }

  /// Resume all animations
  void resume() {
    if (!_disposed) {
      _masterController.repeat();
    }
  }

  /// Reset all animations
  void reset() {
    if (!_disposed) {
      _masterController.reset();
      _masterController.repeat();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _masterController.dispose();
    super.dispose();
  }
}

/// Individual creature animation data with biome-specific movement
class BiomeCreatureAnimation {
  final BiomeCreature creature;
  final Animation<Offset> positionAnimation;
  final Animation<double> scaleAnimation;
  final Animation<double> opacityAnimation;
  final int creatureIndex;

  BiomeCreatureAnimation._({
    required this.creature,
    required this.positionAnimation,
    required this.scaleAnimation,
    required this.opacityAnimation,
    required this.creatureIndex,
  });

  factory BiomeCreatureAnimation.create({
    required BiomeType biome,
    required int index,
    required AnimationController masterController,
  }) {
    final creature = BiomeCreature.forBiome(biome, index);

    // Create staggered animation start times for natural flow
    final staggerDelay = (index * 0.2) % 1.0;
    final staggeredController = CurvedAnimation(
      parent: masterController,
      curve: Interval(staggerDelay, 1.0, curve: creature.pattern.animationCurve),
    );

    // Position animation with biome-specific movement
    final positionAnimation = _createPositionAnimation(
      creature,
      staggeredController,
      index,
    );

    // Scale animation for breathing/swimming effect
    final scaleAnimation = Tween<double>(
      begin: creature.size.scale * 0.95,
      end: creature.size.scale * 1.05,
    ).animate(CurvedAnimation(
      parent: masterController,
      curve: Curves.easeInOut,
    ));

    // Opacity animation for depth simulation
    final opacityAnimation = _createOpacityAnimation(
      creature,
      staggeredController,
      biome,
    );

    return BiomeCreatureAnimation._(
      creature: creature,
      positionAnimation: positionAnimation,
      scaleAnimation: scaleAnimation,
      opacityAnimation: opacityAnimation,
      creatureIndex: index,
    );
  }

  static Animation<Offset> _createPositionAnimation(
    BiomeCreature creature,
    Animation<double> controller,
    int index,
  ) {
    return Tween<Offset>(
      begin: _getStartPosition(creature, index),
      end: _getEndPosition(creature, index),
    ).animate(controller);
  }

  static Animation<double> _createOpacityAnimation(
    BiomeCreature creature,
    Animation<double> controller,
    BiomeType biome,
  ) {
    double minOpacity, maxOpacity;

    switch (biome) {
      case BiomeType.shallowWaters:
        minOpacity = 0.9;
        maxOpacity = 1.0;
        break;
      case BiomeType.coralGarden:
        minOpacity = 0.8;
        maxOpacity = 0.95;
        break;
      case BiomeType.deepOcean:
        minOpacity = 0.7;
        maxOpacity = 0.9;
        break;
      case BiomeType.abyssalZone:
        minOpacity = 0.5;
        maxOpacity = 0.8;
        break;
    }

    return Tween<double>(
      begin: minOpacity,
      end: maxOpacity,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }

  static Offset _getStartPosition(BiomeCreature creature, int index) {
    switch (creature.pattern) {
      case MovementPattern.schoolingDart:
        // Start from left, varying heights
        return Offset(-0.1, 0.2 + (index * 0.15) % 0.6);

      case MovementPattern.territorialWeave:
        // Start from various edges
        final startSide = index % 4;
        switch (startSide) {
          case 0: return Offset(-0.1, 0.3 + (index * 0.1) % 0.4);
          case 1: return Offset(1.1, 0.3 + (index * 0.1) % 0.4);
          case 2: return Offset(0.2 + (index * 0.2) % 0.6, -0.1);
          default: return Offset(0.2 + (index * 0.2) % 0.6, 1.1);
        }

      case MovementPattern.gracefulCruise:
        // Large creatures start from deep left
        return Offset(-0.2, 0.4 + (index * 0.2) % 0.4);

      case MovementPattern.mysteriousFloat:
        // Start from bottom depths
        return Offset(0.1 + (index * 0.3) % 0.8, 1.2);
    }
  }

  static Offset _getEndPosition(BiomeCreature creature, int index) {
    switch (creature.pattern) {
      case MovementPattern.schoolingDart:
        // Quick dart to right with small vertical variation
        final verticalVariation = math.sin(index.toDouble()) * creature.pattern.verticalAmplitude;
        return Offset(1.1, 0.2 + (index * 0.15) % 0.6 + verticalVariation);

      case MovementPattern.territorialWeave:
        // Weaving territorial movement
        final startSide = index % 4;
        final weaveAmplitude = creature.pattern.verticalAmplitude;
        final weaveOffset = math.sin(index * 2.0) * weaveAmplitude;

        switch (startSide) {
          case 0: return Offset(1.1, 0.3 + (index * 0.1) % 0.4 + weaveOffset);
          case 1: return Offset(-0.1, 0.3 + (index * 0.1) % 0.4 + weaveOffset);
          case 2: return Offset(0.2 + (index * 0.2) % 0.6 + weaveOffset, 1.1);
          default: return Offset(0.2 + (index * 0.2) % 0.6 + weaveOffset, -0.1);
        }

      case MovementPattern.gracefulCruise:
        // Large graceful arcs
        final arcHeight = 0.4 + (index * 0.2) % 0.4;
        final arcVariation = math.sin(index * 1.5) * creature.pattern.verticalAmplitude;
        return Offset(1.2, arcHeight + arcVariation);

      case MovementPattern.mysteriousFloat:
        // Slow vertical float with minimal horizontal movement
        final horizontalDrift = (index * 0.1) % 0.3;
        return Offset(0.1 + (index * 0.3) % 0.8 + horizontalDrift, -0.2);
    }
  }

  /// Get current position value
  Offset get currentPosition => positionAnimation.value;

  /// Get current scale value
  double get currentScale => scaleAnimation.value;

  /// Get current opacity value
  double get currentOpacity => opacityAnimation.value;

  /// Get swimming direction (-1 for left, 1 for right)
  int get swimDirection {
    final start = _getStartPosition(creature, creatureIndex);
    final end = _getEndPosition(creature, creatureIndex);
    return end.dx > start.dx ? 1 : -1;
  }

  /// Check if creature should be visible on screen
  bool get isVisible {
    final pos = currentPosition;
    return pos.dx >= -0.2 && pos.dx <= 1.2 && pos.dy >= -0.2 && pos.dy <= 1.2;
  }
}