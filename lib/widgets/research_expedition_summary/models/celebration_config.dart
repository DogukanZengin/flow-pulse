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
    final intensity = result.celebrationLevel; // Use calculated intensity from Phase 4 system
    final biome = result.sessionBiome; // Use determined biome
    final depthFactor = (result.sessionDepthReached / 100.0).clamp(0.0, 1.0);
    
    return CelebrationConfig(
      intensity: intensity,
      primaryBiome: biome,
      totalDuration: _getTotalDuration(intensity, result),
      phases: _getCelebrationPhases(result, intensity),
      primaryCurve: _getPrimaryCurve(intensity),
      depthFactor: depthFactor,
      hasLevelUp: result.leveledUp,
      hasDiscoveries: result.allDiscoveredCreatures.isNotEmpty,
      hasAchievements: result.unlockedAchievements.isNotEmpty,
      hasEquipmentUnlock: result.unlockedEquipment.isNotEmpty,
    );
  }


  static Duration _getTotalDuration(CelebrationIntensity intensity, ExpeditionResult result) {
    // Return to user-controlled navigation - duration is for overall timing but not automatic
    switch (intensity) {
      case CelebrationIntensity.maximum:
        return const Duration(milliseconds: 12000); // Extended for all phases
      case CelebrationIntensity.high:
        return const Duration(milliseconds: 11000);
      case CelebrationIntensity.moderate:
        return const Duration(milliseconds: 10000); // Extended for all phases
      case CelebrationIntensity.minimal:
        return const Duration(milliseconds: 8000);
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

  static List<CelebrationPhase> _getCelebrationPhases(ExpeditionResult result, CelebrationIntensity intensity) {
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

    // Phase 3: Career Advancement - scaled by celebration intensity (show if career changed or for testing)
    if (result.leveledUp || result.careerTitleChanged || true) { // Always show for user control
      final careerEffectIntensity = _getIntensityMultiplier(intensity);
      
      phases.add(CelebrationPhase(
        name: 'Career Advancement',
        startTime: const Duration(milliseconds: 4000),
        duration: const Duration(milliseconds: 2000),
        effects: [
          CelebrationEffect(
            type: CelebrationEffectType.badgeShimmer,
            duration: const Duration(milliseconds: 1500),
            intensity: (0.9 * careerEffectIntensity).clamp(0.3, 1.0),
          ),
          CelebrationEffect(
            type: CelebrationEffectType.coralBloom,
            duration: const Duration(milliseconds: 2000),
            intensity: (0.7 * careerEffectIntensity).clamp(0.3, 1.0),
          ),
        ],
      ));
    }

    // Phase 4: Species Discoveries - scaled by rarity and celebration intensity (show for testing)
    if (result.allDiscoveredCreatures.isNotEmpty || true) { // Always show for user control
      final discoveryIntensity = _getDiscoveryIntensity(result, intensity);
      
      phases.add(CelebrationPhase(
        name: 'Species Discovery',
        startTime: const Duration(milliseconds: 6000), // Fixed timing after Career Advancement
        duration: const Duration(milliseconds: 2000),
        effects: [
          CelebrationEffect(
            type: CelebrationEffectType.creatureSpotlight,
            duration: const Duration(milliseconds: 1800),
            intensity: discoveryIntensity,
          ),
          CelebrationEffect(
            type: _getBiomeSpecificEffect(result.sessionBiome),
            duration: const Duration(milliseconds: 2000),
            intensity: (discoveryIntensity * 0.8).clamp(0.3, 1.0),
          ),
        ],
      ));
    }

    // Phase 5: Grand Finale - show for testing with intensity-scaled effects
    if (intensity == CelebrationIntensity.high || intensity == CelebrationIntensity.maximum || true) { // Always show for user control
      final finaleStart = phases.isNotEmpty 
          ? phases.last.startTime + phases.last.duration
          : Duration.zero;
      final finaleIntensity = _getFinaleIntensity(result, intensity);
      
      phases.add(CelebrationPhase(
        name: 'Grand Finale',
        startTime: finaleStart,
        duration: const Duration(milliseconds: 2000),
        effects: [
          CelebrationEffect(
            type: CelebrationEffectType.schoolOfFish,
            duration: const Duration(milliseconds: 2000),
            intensity: finaleIntensity,
          ),
          CelebrationEffect(
            type: CelebrationEffectType.bioluminescentJellyfish,
            duration: const Duration(milliseconds: 1500),
            intensity: (finaleIntensity * 0.9).clamp(0.5, 1.0),
          ),
          CelebrationEffect(
            type: CelebrationEffectType.particleStorm,
            duration: const Duration(milliseconds: 1000),
            intensity: (finaleIntensity * 0.8).clamp(0.4, 1.0),
          ),
        ],
      ));
    }

    return phases;
  }
  
  /// Get intensity multiplier based on celebration intensity level
  static double _getIntensityMultiplier(CelebrationIntensity intensity) {
    switch (intensity) {
      case CelebrationIntensity.maximum:
        return 1.5; // 150% intensity
      case CelebrationIntensity.high:
        return 1.2; // 120% intensity  
      case CelebrationIntensity.moderate:
        return 1.0; // 100% intensity
      case CelebrationIntensity.minimal:
        return 0.7; // 70% intensity
    }
  }
  
  /// Calculate discovery-specific intensity based on creature rarity
  static double _getDiscoveryIntensity(ExpeditionResult result, CelebrationIntensity baseIntensity) {
    double intensity = _getIntensityMultiplier(baseIntensity);
    
    // Boost intensity for rare creature discoveries
    if (result.discoveredCreature != null && result.discoveredCreature is Creature) {
      final creature = result.discoveredCreature as Creature;
      switch (creature.rarity) {
        case CreatureRarity.legendary:
          intensity *= 1.8; // Legendary discoveries get huge boost
          break;
        case CreatureRarity.rare:
          intensity *= 1.4; // Rare discoveries get major boost
          break;
        case CreatureRarity.uncommon:
          intensity *= 1.2; // Uncommon discoveries get moderate boost
          break;
        case CreatureRarity.common:
          intensity *= 1.0; // Common discoveries use base intensity
          break;
      }
    }
    
    return intensity.clamp(0.3, 2.0); // Cap between 30% and 200%
  }
  
  /// Calculate finale intensity for grand celebration moments
  static double _getFinaleIntensity(ExpeditionResult result, CelebrationIntensity baseIntensity) {
    double intensity = _getIntensityMultiplier(baseIntensity);
    
    // Major milestone bonuses
    if (result.careerTitleChanged) intensity *= 1.3;
    if (result.unlockedAchievements.length >= 3) intensity *= 1.2;
    if (result.unlockedEquipment.length >= 2) intensity *= 1.1;
    
    // Streak bonuses for finale
    if (result.currentStreak >= 30) {
      intensity *= 1.4; // Month+ streaks get epic finales
    } else if (result.currentStreak >= 14) {
      intensity *= 1.2; // Two week+ streaks get enhanced finales
    }
    
    return intensity.clamp(0.5, 2.0); // Cap between 50% and 200%
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
  
  /// Remove old intensity method - now using ExpeditionResult's calculated intensity
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