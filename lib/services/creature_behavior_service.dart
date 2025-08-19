import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/creature.dart';

/// Creature Behavior Service - Phase 5 Implementation  
/// Enhanced creature behaviors and movement patterns for immersive marine experience
class CreatureBehaviorService {
  static CreatureBehaviorService? _instance;
  static CreatureBehaviorService get instance => _instance ??= CreatureBehaviorService._();
  
  CreatureBehaviorService._();
  
  static final _random = math.Random();
  
  /// Get behavior pattern for a creature type
  CreatureBehaviorPattern getBehaviorPattern(CreatureType type, CreatureRarity rarity) {
    switch (type) {
      case CreatureType.starterFish:
        return _getStarterFishBehavior(rarity);
      case CreatureType.reefBuilder:
        return _getReefBuilderBehavior(rarity);  
      case CreatureType.predator:
        return _getPredatorBehavior(rarity);
      case CreatureType.deepSeaDweller:
        return _getDeepSeaDwellerBehavior(rarity);
      case CreatureType.mythical:
        return _getMythicalBehavior(rarity);
    }
  }
  
  /// Calculate creature position based on behavior and time
  Offset calculateCreaturePosition({
    required CreatureBehaviorPattern behavior,
    required double screenWidth,
    required double screenHeight,
    required double time, // Continuous time in seconds
    required Offset? lastPosition,
  }) {
    switch (behavior.movementType) {
      case CreatureMovementType.schooling:
        return _calculateSchoolingMovement(screenWidth, screenHeight, time, behavior);
        
      case CreatureMovementType.territorial:
        return _calculateTerritorialMovement(screenWidth, screenHeight, time, behavior, lastPosition);
        
      case CreatureMovementType.predatory:
        return _calculatePredatoryMovement(screenWidth, screenHeight, time, behavior);
        
      case CreatureMovementType.gracefulGliding:
        return _calculateGracefulGlidingMovement(screenWidth, screenHeight, time, behavior);
        
      case CreatureMovementType.mystical:
        return _calculateMysticalMovement(screenWidth, screenHeight, time, behavior);
        
      case CreatureMovementType.deepSeaDrifting:
        return _calculateDeepSeaDriftingMovement(screenWidth, screenHeight, time, behavior);
    }
  }
  
  /// Get interaction behavior when creature encounters user cursor/touch
  CreatureInteraction getCreatureInteraction(CreatureType type, CreatureRarity rarity, Offset userPosition, Offset creaturePosition) {
    final distance = (userPosition - creaturePosition).distance;
    
    // Interaction radius based on rarity (rarer creatures are more sensitive)
    final interactionRadius = _getInteractionRadius(rarity);
    
    if (distance > interactionRadius) {
      return CreatureInteraction.none;
    }
    
    switch (type) {
      case CreatureType.starterFish:
        return _random.nextDouble() < 0.7 ? CreatureInteraction.curious : CreatureInteraction.flee;
        
      case CreatureType.reefBuilder:
        return CreatureInteraction.territorial;
        
      case CreatureType.predator:
        return rarity == CreatureRarity.legendary ? 
          CreatureInteraction.stalk : CreatureInteraction.investigate;
          
      case CreatureType.deepSeaDweller:
        return CreatureInteraction.shy;
        
      case CreatureType.mythical:
        return _random.nextDouble() < 0.3 ? 
          CreatureInteraction.mysticalEncounter : CreatureInteraction.vanish;
    }
  }
  
  /// Private behavior pattern generators
  
  CreatureBehaviorPattern _getStarterFishBehavior(CreatureRarity rarity) {
    return CreatureBehaviorPattern(
      movementType: CreatureMovementType.schooling,
      speed: _getSpeedForRarity(rarity, baseSpeed: 50.0),
      aggressiveness: 0.1,
      curiosity: 0.8,
      socialness: 0.9,
      territorialRadius: 0.0,
      verticalPreference: 0.3, // Prefer upper water
      movementAmplitude: 30.0,
      movementFrequency: 0.5,
    );
  }
  
  CreatureBehaviorPattern _getReefBuilderBehavior(CreatureRarity rarity) {
    return CreatureBehaviorPattern(
      movementType: CreatureMovementType.territorial,
      speed: _getSpeedForRarity(rarity, baseSpeed: 25.0),
      aggressiveness: 0.4,
      curiosity: 0.6,
      socialness: 0.3,
      territorialRadius: 100.0,
      verticalPreference: 0.4,
      movementAmplitude: 20.0,
      movementFrequency: 0.3,
    );
  }
  
  CreatureBehaviorPattern _getPredatorBehavior(CreatureRarity rarity) {
    return CreatureBehaviorPattern(
      movementType: CreatureMovementType.predatory,
      speed: _getSpeedForRarity(rarity, baseSpeed: 75.0),
      aggressiveness: 0.8,
      curiosity: 0.4,
      socialness: 0.1,
      territorialRadius: 150.0,
      verticalPreference: 0.5, // Mid-water hunters
      movementAmplitude: 50.0,
      movementFrequency: 0.8,
    );
  }
  
  CreatureBehaviorPattern _getDeepSeaDwellerBehavior(CreatureRarity rarity) {
    return CreatureBehaviorPattern(
      movementType: CreatureMovementType.gracefulGliding,
      speed: _getSpeedForRarity(rarity, baseSpeed: 40.0),
      aggressiveness: 0.2,
      curiosity: 0.3,
      socialness: 0.2,
      territorialRadius: 200.0,
      verticalPreference: 0.8, // Prefer deeper water
      movementAmplitude: 80.0,
      movementFrequency: 0.2,
    );
  }
  
  CreatureBehaviorPattern _getMythicalBehavior(CreatureRarity rarity) {
    return CreatureBehaviorPattern(
      movementType: CreatureMovementType.mystical,
      speed: _getSpeedForRarity(rarity, baseSpeed: 35.0),
      aggressiveness: 0.1,
      curiosity: 0.9,
      socialness: 0.0,
      territorialRadius: 300.0,
      verticalPreference: 0.6,
      movementAmplitude: 100.0,
      movementFrequency: 0.15, // Very slow, mystical movement
    );
  }
  
  /// Movement calculation methods
  
  Offset _calculateSchoolingMovement(double width, double height, double time, CreatureBehaviorPattern behavior) {
    // Schooling fish move in coordinated sine waves
    final x = width * 0.1 + (width * 0.8) * ((math.sin(time * behavior.movementFrequency) + 1) / 2);
    final y = height * (0.2 + behavior.verticalPreference * 0.6) + 
              behavior.movementAmplitude * math.sin(time * behavior.movementFrequency * 2);
    
    return Offset(x, y.clamp(0, height));
  }
  
  Offset _calculateTerritorialMovement(double width, double height, double time, CreatureBehaviorPattern behavior, Offset? lastPosition) {
    // Territorial creatures stay in a specific area
    final territoryCenter = lastPosition ?? Offset(width * 0.3, height * 0.5);
    final radius = behavior.territorialRadius;
    
    final angle = time * behavior.movementFrequency;
    final x = territoryCenter.dx + radius * 0.3 * math.cos(angle);
    final y = territoryCenter.dy + radius * 0.2 * math.sin(angle * 1.5);
    
    return Offset(
      x.clamp(0, width), 
      y.clamp(0, height)
    );
  }
  
  Offset _calculatePredatoryMovement(double width, double height, double time, CreatureBehaviorPattern behavior) {
    // Predators patrol in larger, more irregular patterns
    final patrolX = width * 0.2 + (width * 0.6) * ((math.sin(time * behavior.movementFrequency) + 1) / 2);
    final huntY = height * 0.3 + (height * 0.4) * ((math.cos(time * behavior.movementFrequency * 0.7) + 1) / 2);
    
    // Add hunting lunges
    final lungeX = behavior.movementAmplitude * math.sin(time * behavior.movementFrequency * 3) * 
                   (math.sin(time * 0.1) > 0.8 ? 1.0 : 0.0);
    
    return Offset((patrolX + lungeX).clamp(0, width), huntY.clamp(0, height));
  }
  
  Offset _calculateGracefulGlidingMovement(double width, double height, double time, CreatureBehaviorPattern behavior) {
    // Large graceful creatures like manta rays
    final sweepX = width * 0.1 + (width * 0.8) * ((math.sin(time * behavior.movementFrequency * 0.5) + 1) / 2);
    final glideY = height * (behavior.verticalPreference + 0.1 * math.sin(time * behavior.movementFrequency * 0.3));
    
    return Offset(sweepX, glideY.clamp(0, height));
  }
  
  Offset _calculateMysticalMovement(double width, double height, double time, CreatureBehaviorPattern behavior) {
    // Mystical creatures have ethereal, unpredictable movement
    final spiralRadius = behavior.movementAmplitude;
    final spiralX = width * 0.5 + spiralRadius * math.cos(time * behavior.movementFrequency * 2);
    final spiralY = height * 0.5 + spiralRadius * math.sin(time * behavior.movementFrequency * 3) * 0.5;
    
    // Add mystical "teleportation" effect
    final mysticalJump = math.sin(time * 0.05) > 0.95 ? 
        Offset(_random.nextDouble() * width * 0.3, _random.nextDouble() * height * 0.2) : 
        Offset.zero;
    
    return Offset(
      (spiralX + mysticalJump.dx).clamp(0, width),
      (spiralY + mysticalJump.dy).clamp(0, height)
    );
  }
  
  Offset _calculateDeepSeaDriftingMovement(double width, double height, double time, CreatureBehaviorPattern behavior) {
    // Slow, deep sea drifting with current effects
    final currentX = width * 0.2 + (width * 0.6) * ((math.sin(time * behavior.movementFrequency * 0.3) + 1) / 2);
    final driftY = height * (0.6 + 0.3 * math.sin(time * behavior.movementFrequency * 0.2));
    
    // Add deep sea "pressure wave" effects
    final pressureWaveX = 20 * math.sin(time * 0.1);
    final pressureWaveY = 15 * math.cos(time * 0.15);
    
    return Offset(
      (currentX + pressureWaveX).clamp(0, width),
      (driftY + pressureWaveY).clamp(0, height)
    );
  }
  
  /// Helper methods
  
  double _getSpeedForRarity(CreatureRarity rarity, {required double baseSpeed}) {
    switch (rarity) {
      case CreatureRarity.common:
        return baseSpeed * 0.8;
      case CreatureRarity.uncommon:
        return baseSpeed * 1.0;
      case CreatureRarity.rare:
        return baseSpeed * 1.3;
      case CreatureRarity.legendary:
        return baseSpeed * 1.6;
    }
  }
  
  double _getInteractionRadius(CreatureRarity rarity) {
    switch (rarity) {
      case CreatureRarity.common:
        return 60.0;
      case CreatureRarity.uncommon:
        return 80.0;
      case CreatureRarity.rare:
        return 100.0;
      case CreatureRarity.legendary:
        return 150.0;
    }
  }
}

/// Data models for creature behavior

class CreatureBehaviorPattern {
  final CreatureMovementType movementType;
  final double speed;
  final double aggressiveness;
  final double curiosity;
  final double socialness;
  final double territorialRadius;
  final double verticalPreference; // 0.0 = surface, 1.0 = bottom
  final double movementAmplitude;
  final double movementFrequency;
  
  const CreatureBehaviorPattern({
    required this.movementType,
    required this.speed,
    required this.aggressiveness,
    required this.curiosity,
    required this.socialness,
    required this.territorialRadius,
    required this.verticalPreference,
    required this.movementAmplitude,
    required this.movementFrequency,
  });
}

enum CreatureMovementType {
  schooling,        // Small fish moving in coordinated groups
  territorial,      // Fish defending specific areas
  predatory,        // Hunting patterns with stalking behavior
  gracefulGliding,  // Large peaceful creatures like rays
  mystical,         // Unpredictable, ethereal movement
  deepSeaDrifting,  // Slow movement with current effects
}

enum CreatureInteraction {
  none,                // No interaction
  curious,             // Approaches user
  flee,                // Swims away quickly
  territorial,         // Aggressive defensive behavior
  investigate,         // Circles around user
  stalk,              // Follows user menacingly
  shy,                // Slowly moves away
  mysticalEncounter,  // Special interaction for mythical creatures
  vanish,             // Disappears mysteriously
}