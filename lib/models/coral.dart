import 'creature.dart';

class Coral {
  final String id;
  final CoralType type;
  final CoralStage stage;
  final double growthProgress; // 0.0 to 1.0
  final DateTime plantedAt;
  final DateTime? lastGrowthAt;
  final bool isHealthy;
  final List<String> attractedSpecies; // IDs of creatures this coral has attracted
  final int sessionsGrown; // Number of focus sessions that grew this coral
  final BiomeType biome;
  final Map<String, dynamic> position; // x, y coordinates in aquarium

  const Coral({
    required this.id,
    required this.type,
    required this.stage,
    required this.growthProgress,
    required this.plantedAt,
    this.lastGrowthAt,
    this.isHealthy = true,
    this.attractedSpecies = const [],
    this.sessionsGrown = 0,
    required this.biome,
    this.position = const {'x': 0.5, 'y': 0.5}, // Default center position
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'stage': stage.index,
      'growth_progress': growthProgress,
      'planted_at': plantedAt.millisecondsSinceEpoch,
      'last_growth_at': lastGrowthAt?.millisecondsSinceEpoch,
      'is_healthy': isHealthy ? 1 : 0,
      'attracted_species': attractedSpecies.join(','),
      'sessions_grown': sessionsGrown,
      'biome': biome.index,
      'position_x': position['x'],
      'position_y': position['y'],
    };
  }

  factory Coral.fromMap(Map<String, dynamic> map) {
    return Coral(
      id: map['id'],
      type: CoralType.values[map['type']],
      stage: CoralStage.values[map['stage']],
      growthProgress: map['growth_progress'].toDouble(),
      plantedAt: DateTime.fromMillisecondsSinceEpoch(map['planted_at']),
      lastGrowthAt: map['last_growth_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['last_growth_at'])
          : null,
      isHealthy: map['is_healthy'] == 1,
      attractedSpecies: map['attracted_species'] != null && map['attracted_species'].isNotEmpty
          ? map['attracted_species'].split(',')
          : [],
      sessionsGrown: map['sessions_grown'] ?? 0,
      biome: BiomeType.values[map['biome']],
      position: {
        'x': map['position_x'] ?? 0.5,
        'y': map['position_y'] ?? 0.5,
      },
    );
  }

  Coral copyWith({
    String? id,
    CoralType? type,
    CoralStage? stage,
    double? growthProgress,
    DateTime? plantedAt,
    DateTime? lastGrowthAt,
    bool? isHealthy,
    List<String>? attractedSpecies,
    int? sessionsGrown,
    BiomeType? biome,
    Map<String, dynamic>? position,
  }) {
    return Coral(
      id: id ?? this.id,
      type: type ?? this.type,
      stage: stage ?? this.stage,
      growthProgress: growthProgress ?? this.growthProgress,
      plantedAt: plantedAt ?? this.plantedAt,
      lastGrowthAt: lastGrowthAt ?? this.lastGrowthAt,
      isHealthy: isHealthy ?? this.isHealthy,
      attractedSpecies: attractedSpecies ?? this.attractedSpecies,
      sessionsGrown: sessionsGrown ?? this.sessionsGrown,
      biome: biome ?? this.biome,
      position: position ?? this.position,
    );
  }

  // Growth method - called when a focus session completes
  Coral growFromSession(int sessionDurationMinutes) {
    final growthAmount = _calculateGrowthAmount(sessionDurationMinutes);
    final newProgress = (growthProgress + growthAmount).clamp(0.0, 1.0);
    final newStage = _calculateStageFromProgress(newProgress);
    
    return copyWith(
      growthProgress: newProgress,
      stage: newStage,
      lastGrowthAt: DateTime.now(),
      sessionsGrown: sessionsGrown + 1,
    );
  }

  // Calculate growth based on session duration and coral type benefits
  double _calculateGrowthAmount(int sessionMinutes) {
    // Base growth per minute
    double baseGrowth = 0.04; // 25 minutes = 100% growth
    
    // Apply coral type benefits
    double multiplier = type.growthMultiplier;
    
    return baseGrowth * sessionMinutes * multiplier;
  }

  CoralStage _calculateStageFromProgress(double progress) {
    if (progress < 0.25) return CoralStage.polyp;
    if (progress < 0.50) return CoralStage.juvenile;
    if (progress < 0.75) return CoralStage.mature;
    return CoralStage.flourishing;
  }

  bool get isFullyGrown => growthProgress >= 1.0;
  bool get canAttractRareSpecies => stage == CoralStage.flourishing;
  
  String get displayName => type.displayName;
  String get stageName => stage.displayName;
  String get typeDescription => type.description;
  String get benefit => type.benefit;

  // Calculate the pearl bonus this coral provides daily
  int get dailyPearlBonus {
    if (!isFullyGrown) return 0;
    return type.dailyPearlBonus * stage.bonusMultiplier;
  }
}

enum CoralType {
  brain,      // +25% focus session XP
  staghorn,   // Attracts small fish faster
  table,      // Provides shelter for larger species
  soft,       // Creates beautiful particle effects
  fire,       // Deters negative pollution effects
}

extension CoralTypeExtension on CoralType {
  String get displayName {
    switch (this) {
      case CoralType.brain:
        return 'Brain Coral';
      case CoralType.staghorn:
        return 'Staghorn Coral';
      case CoralType.table:
        return 'Table Coral';
      case CoralType.soft:
        return 'Soft Coral';
      case CoralType.fire:
        return 'Fire Coral';
    }
  }

  String get description {
    switch (this) {
      case CoralType.brain:
        return 'Wrinkled surface resembles brain tissue';
      case CoralType.staghorn:
        return 'Branching arms provide fish shelter';
      case CoralType.table:
        return 'Flat table-like structure for large fish';
      case CoralType.soft:
        return 'Flexible coral that sways with currents';
      case CoralType.fire:
        return 'Protective coral that deters threats';
    }
  }

  String get benefit {
    switch (this) {
      case CoralType.brain:
        return '+25% focus session XP';
      case CoralType.staghorn:
        return 'Attracts small fish faster';
      case CoralType.table:
        return 'Shelter for larger species';
      case CoralType.soft:
        return 'Beautiful particle effects';
      case CoralType.fire:
        return 'Reduces pollution effects';
    }
  }

  double get growthMultiplier {
    switch (this) {
      case CoralType.brain:
        return 1.0; // Standard growth rate
      case CoralType.staghorn:
        return 1.2; // 20% faster growth
      case CoralType.table:
        return 0.8; // 20% slower but attracts rare species
      case CoralType.soft:
        return 1.1; // 10% faster growth
      case CoralType.fire:
        return 0.9; // 10% slower but provides protection
    }
  }

  int get dailyPearlBonus {
    switch (this) {
      case CoralType.brain:
        return 5;
      case CoralType.staghorn:
        return 3;
      case CoralType.table:
        return 8; // Higher bonus for slower growth
      case CoralType.soft:
        return 4;
      case CoralType.fire:
        return 6;
    }
  }

  double get xpMultiplier {
    switch (this) {
      case CoralType.brain:
        return 1.25; // +25% XP bonus
      case CoralType.staghorn:
        return 1.0;
      case CoralType.table:
        return 1.0;
      case CoralType.soft:
        return 1.0;
      case CoralType.fire:
        return 1.0;
    }
  }

  // Which creatures are more likely to be attracted to this coral type
  List<String> get preferredCreatureTypes {
    switch (this) {
      case CoralType.brain:
        return ['starterFish', 'reefBuilder'];
      case CoralType.staghorn:
        return ['starterFish']; // Attracts small fish
      case CoralType.table:
        return ['predator', 'deepSeaDweller']; // Large species
      case CoralType.soft:
        return ['reefBuilder', 'starterFish'];
      case CoralType.fire:
        return ['predator']; // Brave species only
    }
  }

  int get pearlCost {
    switch (this) {
      case CoralType.brain:
        return 50;
      case CoralType.staghorn:
        return 25;
      case CoralType.table:
        return 100;
      case CoralType.soft:
        return 40;
      case CoralType.fire:
        return 75;
    }
  }
}

enum CoralStage {
  polyp,       // 0-25%: Tiny bump on reef floor
  juvenile,    // 26-50%: Small coral formation
  mature,      // 51-75%: Full-sized, colorful coral
  flourishing, // 76-100%: Particle effects, attracts rare species
}

extension CoralStageExtension on CoralStage {
  String get displayName {
    switch (this) {
      case CoralStage.polyp:
        return 'Polyp';
      case CoralStage.juvenile:
        return 'Juvenile';
      case CoralStage.mature:
        return 'Mature';
      case CoralStage.flourishing:
        return 'Flourishing';
    }
  }

  String get description {
    switch (this) {
      case CoralStage.polyp:
        return 'Tiny bump on reef floor';
      case CoralStage.juvenile:
        return 'Small coral formation';
      case CoralStage.mature:
        return 'Full-sized, colorful coral';
      case CoralStage.flourishing:
        return 'Particle effects, attracts rare species';
    }
  }

  double get minProgress {
    switch (this) {
      case CoralStage.polyp:
        return 0.0;
      case CoralStage.juvenile:
        return 0.25;
      case CoralStage.mature:
        return 0.50;
      case CoralStage.flourishing:
        return 0.75;
    }
  }

  double get maxProgress {
    switch (this) {
      case CoralStage.polyp:
        return 0.25;
      case CoralStage.juvenile:
        return 0.50;
      case CoralStage.mature:
        return 0.75;
      case CoralStage.flourishing:
        return 1.0;
    }
  }

  int get bonusMultiplier {
    switch (this) {
      case CoralStage.polyp:
        return 1;
      case CoralStage.juvenile:
        return 1;
      case CoralStage.mature:
        return 2;
      case CoralStage.flourishing:
        return 3;
    }
  }

  bool get hasParticleEffects {
    return this == CoralStage.flourishing;
  }

  bool get canAttractRareSpecies {
    return this == CoralStage.flourishing || this == CoralStage.mature;
  }
}