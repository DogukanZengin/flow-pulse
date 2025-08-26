import 'package:flutter/material.dart';
import '../../../models/creature.dart';
import 'expedition_result.dart';

/// Configuration for celebration animations and effects
class CelebrationConfig {
  final CelebrationIntensity intensity;
  final BiomeType primaryBiome;
  final Duration totalDuration;
  final List<CelebrationPhase> phases;
  final Curve primaryCurve;
  final double depthFactor;
  final bool hasLevelUp;
  final bool hasDiscoveries;
  final bool hasAchievements;
  final bool hasEquipmentUnlock;

  const CelebrationConfig({
    required this.intensity,
    required this.primaryBiome,
    required this.totalDuration,
    required this.phases,
    required this.primaryCurve,
    required this.depthFactor,
    required this.hasLevelUp,
    required this.hasDiscoveries,
    required this.hasAchievements,
    required this.hasEquipmentUnlock,
  });

  static CelebrationConfig fromExpeditionResult(ExpeditionResult result) {
    final intensity = _getCelebrationIntensity(result.celebrationIntensity);
    final biome = result.getPrimaryBiome();
    final depthFactor = (result.sessionDepthReached / 100.0).clamp(0.0, 1.0);
    
    return CelebrationConfig(
      intensity: intensity,
      primaryBiome: biome,
      totalDuration: _getTotalDuration(intensity),
      phases: _getCelebrationPhases(result),
      primaryCurve: _getPrimaryCurve(intensity),
      depthFactor: depthFactor,
      hasLevelUp: result.leveledUp,
      hasDiscoveries: result.allDiscoveredCreatures.isNotEmpty,
      hasAchievements: result.unlockedAchievements.isNotEmpty,
      hasEquipmentUnlock: result.unlockedEquipment.isNotEmpty,
    );
  }

  static CelebrationIntensity _getCelebrationIntensity(double value) {
    if (value >= 0.9) return CelebrationIntensity.maximum;
    if (value >= 0.7) return CelebrationIntensity.high;
    if (value >= 0.4) return CelebrationIntensity.moderate;
    return CelebrationIntensity.minimal;
  }

  static Duration _getTotalDuration(CelebrationIntensity intensity) {
    switch (intensity) {
      case CelebrationIntensity.maximum:
        return const Duration(milliseconds: 3000);
      case CelebrationIntensity.high:
        return const Duration(milliseconds: 2500);
      case CelebrationIntensity.moderate:
        return const Duration(milliseconds: 2000);
      case CelebrationIntensity.minimal:
        return const Duration(milliseconds: 1500);
    }
  }

  static Curve _getPrimaryCurve(CelebrationIntensity intensity) {
    switch (intensity) {
      case CelebrationIntensity.maximum:
        return Curves.elasticOut;
      case CelebrationIntensity.high:
        return Curves.bounceOut;
      case CelebrationIntensity.moderate:
        return Curves.easeOutBack;
      case CelebrationIntensity.minimal:
        return Curves.easeInOut;
    }
  }

  static List<CelebrationPhase> _getCelebrationPhases(ExpeditionResult result) {
    final List<CelebrationPhase> phases = [];
    
    // Phase 1: Surfacing Animation (always present)
    phases.add(const CelebrationPhase(
      name: 'Surfacing',
      startTime: Duration.zero,
      duration: Duration(milliseconds: 2000),
      effects: [
        CelebrationEffect(
          type: CelebrationEffectType.depthTransition,
          duration: Duration(milliseconds: 1500),
          intensity: 1.0,
        ),
        CelebrationEffect(
          type: CelebrationEffectType.bubbleTrail,
          duration: Duration(milliseconds: 1200),
          intensity: 0.8,
        ),
      ],
    ));

    // Phase 2: Data Collection Display
    phases.add(const CelebrationPhase(
      name: 'Data Collection',
      startTime: Duration(milliseconds: 2000),
      duration: Duration(milliseconds: 2000),
      effects: [
        CelebrationEffect(
          type: CelebrationEffectType.waterCaustics,
          duration: Duration(milliseconds: 2000),
          intensity: 0.6,
        ),
      ],
    ));

    // Phase 3: Career Advancement (if applicable)
    if (result.leveledUp || result.careerTitleChanged) {
      phases.add(const CelebrationPhase(
        name: 'Career Advancement',
        startTime: Duration(milliseconds: 4000),
        duration: Duration(milliseconds: 2000),
        effects: [
          CelebrationEffect(
            type: CelebrationEffectType.badgeShimmer,
            duration: Duration(milliseconds: 1500),
            intensity: 0.9,
          ),
          CelebrationEffect(
            type: CelebrationEffectType.coralBloom,
            duration: Duration(milliseconds: 2000),
            intensity: 0.7,
          ),
        ],
      ));
    }

    // Phase 4: Species Discoveries (if any)
    if (result.allDiscoveredCreatures.isNotEmpty) {
      phases.add(CelebrationPhase(
        name: 'Species Discovery',
        startTime: Duration(milliseconds: result.leveledUp ? 6000 : 4000),
        duration: const Duration(milliseconds: 2000),
        effects: [
          const CelebrationEffect(
            type: CelebrationEffectType.creatureSpotlight,
            duration: Duration(milliseconds: 1800),
            intensity: 1.0,
          ),
          CelebrationEffect(
            type: _getBiomeSpecificEffect(result.getPrimaryBiome()),
            duration: const Duration(milliseconds: 2000),
            intensity: 0.8,
          ),
        ],
      ));
    }

    // Phase 5: Grand Finale (for high intensity celebrations)
    if (result.celebrationIntensity > 0.7) {
      final finaleStart = phases.isNotEmpty 
          ? phases.last.startTime + phases.last.duration
          : Duration.zero;
      
      phases.add(CelebrationPhase(
        name: 'Grand Finale',
        startTime: finaleStart,
        duration: const Duration(milliseconds: 2000),
        effects: [
          const CelebrationEffect(
            type: CelebrationEffectType.schoolOfFish,
            duration: Duration(milliseconds: 2000),
            intensity: 1.0,
          ),
          const CelebrationEffect(
            type: CelebrationEffectType.bioluminescentJellyfish,
            duration: Duration(milliseconds: 1500),
            intensity: 0.9,
          ),
          const CelebrationEffect(
            type: CelebrationEffectType.particleStorm,
            duration: Duration(milliseconds: 1000),
            intensity: 0.8,
          ),
        ],
      ));
    }

    return phases;
  }

  static CelebrationEffectType _getBiomeSpecificEffect(BiomeType biome) {
    switch (biome) {
      case BiomeType.shallowWaters:
        return CelebrationEffectType.schoolOfFish;
      case BiomeType.coralGarden:
        return CelebrationEffectType.coralBloom;
      case BiomeType.deepOcean:
        return CelebrationEffectType.bioluminescentJellyfish;
      case BiomeType.abyssalZone:
        return CelebrationEffectType.particleStorm;
    }
  }
}

/// A phase within the celebration sequence
class CelebrationPhase {
  final String name;
  final Duration startTime;
  final Duration duration;
  final List<CelebrationEffect> effects;

  const CelebrationPhase({
    required this.name,
    required this.startTime,
    required this.duration,
    required this.effects,
  });

  Duration get endTime => startTime + duration;
}

/// Animation controller configuration
class AnimationControllerConfig {
  final String name;
  final Duration duration;
  final Curve curve;
  final bool repeat;
  final bool reverse;

  const AnimationControllerConfig({
    required this.name,
    required this.duration,
    required this.curve,
    this.repeat = false,
    this.reverse = false,
  });
}

/// Biome-specific visual configuration
class BiomeVisualConfig {
  final BiomeType biome;
  final LinearGradient backgroundGradient;
  final List<Color> particleColors;
  final List<String> ambientSounds;
  final double lightIntensity;
  final Color dominantColor;

  const BiomeVisualConfig({
    required this.biome,
    required this.backgroundGradient,
    required this.particleColors,
    required this.ambientSounds,
    required this.lightIntensity,
    required this.dominantColor,
  });

  static BiomeVisualConfig forBiome(BiomeType biome) {
    switch (biome) {
      case BiomeType.shallowWaters:
        return const BiomeVisualConfig(
          biome: BiomeType.shallowWaters,
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB), // Sky blue
              Color(0xFF4682B4), // Steel blue
              Color(0xFF1E90FF), // Dodger blue
            ],
          ),
          particleColors: [Colors.cyan, Colors.lightBlue, Colors.white],
          ambientSounds: ['tropical_fish', 'gentle_waves'],
          lightIntensity: 0.9,
          dominantColor: Colors.cyan,
        );
      
      case BiomeType.coralGarden:
        return const BiomeVisualConfig(
          biome: BiomeType.coralGarden,
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF20B2AA), // Light sea green
              Color(0xFF008B8B), // Dark cyan
              Color(0xFF2F4F4F), // Dark slate gray
            ],
          ),
          particleColors: [Colors.teal, Colors.green, Colors.orange],
          ambientSounds: ['coral_reef', 'tropical_ambience'],
          lightIntensity: 0.7,
          dominantColor: Colors.teal,
        );
      
      case BiomeType.deepOcean:
        return const BiomeVisualConfig(
          biome: BiomeType.deepOcean,
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF191970), // Midnight blue
              Color(0xFF0000CD), // Medium blue
              Color(0xFF000080), // Navy
            ],
          ),
          particleColors: [Colors.blue, Colors.indigo, Colors.purple],
          ambientSounds: ['deep_ocean', 'whale_songs'],
          lightIntensity: 0.4,
          dominantColor: Colors.blue,
        );
      
      case BiomeType.abyssalZone:
        return const BiomeVisualConfig(
          biome: BiomeType.abyssalZone,
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000080), // Navy
              Color(0xFF000033), // Very dark blue
              Color(0xFF000000), // Black
            ],
          ),
          particleColors: [Colors.purple, Colors.pink, Colors.white],
          ambientSounds: ['abyss_ambience', 'bioluminescent_creatures'],
          lightIntensity: 0.2,
          dominantColor: Colors.purple,
        );
    }
  }
}

/// Particle system configuration
class ParticleSystemConfig {
  final int particleCount;
  final double minSize;
  final double maxSize;
  final double speed;
  final List<Color> colors;
  final BlendMode blendMode;
  final Curve movementCurve;

  const ParticleSystemConfig({
    required this.particleCount,
    required this.minSize,
    required this.maxSize,
    required this.speed,
    required this.colors,
    this.blendMode = BlendMode.screen,
    this.movementCurve = Curves.linear,
  });

  static ParticleSystemConfig forEffect(CelebrationEffectType effect, double intensity) {
    switch (effect) {
      case CelebrationEffectType.bubbleTrail:
        return ParticleSystemConfig(
          particleCount: (15 * intensity).round(),
          minSize: 2.0,
          maxSize: 8.0,
          speed: 0.5,
          colors: [Colors.cyan.withValues(alpha: 0.6), Colors.white.withValues(alpha: 0.4)],
          blendMode: BlendMode.screen,
          movementCurve: Curves.easeOut,
        );
      
      case CelebrationEffectType.schoolOfFish:
        return ParticleSystemConfig(
          particleCount: (20 * intensity).round(),
          minSize: 3.0,
          maxSize: 6.0,
          speed: 1.2,
          colors: [Colors.orange, Colors.yellow, Colors.lightBlue],
          blendMode: BlendMode.multiply,
          movementCurve: Curves.easeInOut,
        );
      
      case CelebrationEffectType.bioluminescentJellyfish:
        return ParticleSystemConfig(
          particleCount: (8 * intensity).round(),
          minSize: 8.0,
          maxSize: 15.0,
          speed: 0.3,
          colors: [Colors.purple.withValues(alpha: 0.8), Colors.pink.withValues(alpha: 0.6)],
          blendMode: BlendMode.screen,
          movementCurve: Curves.elasticOut,
        );
      
      case CelebrationEffectType.particleStorm:
        return ParticleSystemConfig(
          particleCount: (50 * intensity).round(),
          minSize: 1.0,
          maxSize: 4.0,
          speed: 2.0,
          colors: [Colors.cyan, Colors.teal, Colors.lightBlue, Colors.white],
          blendMode: BlendMode.screen,
          movementCurve: Curves.linear,
        );
      
      default:
        return ParticleSystemConfig(
          particleCount: (10 * intensity).round(),
          minSize: 2.0,
          maxSize: 5.0,
          speed: 1.0,
          colors: [Colors.cyan.withValues(alpha: 0.7)],
          blendMode: BlendMode.screen,
          movementCurve: Curves.linear,
        );
    }
  }
}