class Creature {
  final String id;
  final String name;
  final String species;
  final CreatureRarity rarity;
  final CreatureType type;
  final BiomeType habitat;
  final String animationAsset;
  final int pearlValue;
  final int requiredLevel;
  final bool isDiscovered;
  final DateTime? discoveredAt;
  final String description;
  final List<String> coralPreferences; // Which corals attract this creature
  final double discoveryChance; // Base chance of discovery (0.0 - 1.0)

  const Creature({
    required this.id,
    required this.name,
    required this.species,
    required this.rarity,
    required this.type,
    required this.habitat,
    required this.animationAsset,
    required this.pearlValue,
    required this.requiredLevel,
    this.isDiscovered = false,
    this.discoveredAt,
    required this.description,
    this.coralPreferences = const [],
    required this.discoveryChance,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'rarity': rarity.index,
      'type': type.index,
      'habitat': habitat.index,
      'animation_asset': animationAsset,
      'pearl_value': pearlValue,
      'required_level': requiredLevel,
      'is_discovered': isDiscovered ? 1 : 0,
      'discovered_at': discoveredAt?.millisecondsSinceEpoch,
      'description': description,
      'coral_preferences': coralPreferences.join(','),
      'discovery_chance': discoveryChance,
    };
  }

  factory Creature.fromMap(Map<String, dynamic> map) {
    return Creature(
      id: map['id'],
      name: map['name'],
      species: map['species'],
      rarity: CreatureRarity.values[map['rarity']],
      type: CreatureType.values[map['type']],
      habitat: BiomeType.values[map['habitat']],
      animationAsset: map['animation_asset'],
      pearlValue: map['pearl_value'],
      requiredLevel: map['required_level'],
      isDiscovered: map['is_discovered'] == 1,
      discoveredAt: map['discovered_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['discovered_at'])
          : null,
      description: map['description'],
      coralPreferences: map['coral_preferences'] != null 
          ? map['coral_preferences'].split(',')
          : [],
      discoveryChance: map['discovery_chance'],
    );
  }

  Creature copyWith({
    String? id,
    String? name,
    String? species,
    CreatureRarity? rarity,
    CreatureType? type,
    BiomeType? habitat,
    String? animationAsset,
    int? pearlValue,
    int? requiredLevel,
    bool? isDiscovered,
    DateTime? discoveredAt,
    String? description,
    List<String>? coralPreferences,
    double? discoveryChance,
  }) {
    return Creature(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      rarity: rarity ?? this.rarity,
      type: type ?? this.type,
      habitat: habitat ?? this.habitat,
      animationAsset: animationAsset ?? this.animationAsset,
      pearlValue: pearlValue ?? this.pearlValue,
      requiredLevel: requiredLevel ?? this.requiredLevel,
      isDiscovered: isDiscovered ?? this.isDiscovered,
      discoveredAt: discoveredAt ?? this.discoveredAt,
      description: description ?? this.description,
      coralPreferences: coralPreferences ?? this.coralPreferences,
      discoveryChance: discoveryChance ?? this.discoveryChance,
    );
  }

  String get rarityName => rarity.displayName;
  String get typeName => type.displayName;
  String get habitatName => habitat.displayName;
}

enum CreatureRarity {
  common,
  uncommon,
  rare,
  legendary,
}

extension CreatureRarityExtension on CreatureRarity {
  String get displayName {
    switch (this) {
      case CreatureRarity.common:
        return 'Common';
      case CreatureRarity.uncommon:
        return 'Uncommon';
      case CreatureRarity.rare:
        return 'Rare';
      case CreatureRarity.legendary:
        return 'Legendary';
    }
  }

  double get baseDiscoveryChance {
    switch (this) {
      case CreatureRarity.common:
        return 0.70; // 70% chance
      case CreatureRarity.uncommon:
        return 0.20; // 20% chance
      case CreatureRarity.rare:
        return 0.08; // 8% chance
      case CreatureRarity.legendary:
        return 0.02; // 2% chance
    }
  }

  int get pearlMultiplier {
    switch (this) {
      case CreatureRarity.common:
        return 1;
      case CreatureRarity.uncommon:
        return 2;
      case CreatureRarity.rare:
        return 5;
      case CreatureRarity.legendary:
        return 10;
    }
  }
}

enum CreatureType {
  starterFish,    // Clownfish, Angelfish, Tangs (Level 1-5)
  reefBuilder,    // Anemones, Cleaner Wrasse, Parrotfish (Level 6-15)
  predator,       // Reef Sharks, Moray Eels, Octopus (Level 16-30)
  deepSeaDweller, // Manta Rays, Whale Sharks, Bioluminescent Jellyfish (Level 31-45)
  mythical,       // Sea Dragons, Kraken, Mermaids (Level 46+)
}

extension CreatureTypeExtension on CreatureType {
  String get displayName {
    switch (this) {
      case CreatureType.starterFish:
        return 'Starter Fish';
      case CreatureType.reefBuilder:
        return 'Reef Builder';
      case CreatureType.predator:
        return 'Predator';
      case CreatureType.deepSeaDweller:
        return 'Deep Sea Dweller';
      case CreatureType.mythical:
        return 'Mythical Creature';
    }
  }

  int get minLevel {
    switch (this) {
      case CreatureType.starterFish:
        return 1;
      case CreatureType.reefBuilder:
        return 6;
      case CreatureType.predator:
        return 16;
      case CreatureType.deepSeaDweller:
        return 31;
      case CreatureType.mythical:
        return 46;
    }
  }

  int get maxLevel {
    switch (this) {
      case CreatureType.starterFish:
        return 5;
      case CreatureType.reefBuilder:
        return 15;
      case CreatureType.predator:
        return 30;
      case CreatureType.deepSeaDweller:
        return 45;
      case CreatureType.mythical:
        return 999; // No upper limit
    }
  }
}

enum BiomeType {
  shallowWaters,  // Level 1-10: Basic fish, simple coral
  coralGarden,    // Level 11-25: Colorful reef fish, anemones
  deepOcean,      // Level 26-50: Sharks, rays, bioluminescent creatures
  abyssalZone,    // Level 51+: Mythical sea creatures, underwater cities
}

extension BiomeTypeExtension on BiomeType {
  String get displayName {
    switch (this) {
      case BiomeType.shallowWaters:
        return 'Shallow Waters';
      case BiomeType.coralGarden:
        return 'Coral Garden';
      case BiomeType.deepOcean:
        return 'Deep Ocean';
      case BiomeType.abyssalZone:
        return 'Abyssal Zone';
    }
  }

  String get description {
    switch (this) {
      case BiomeType.shallowWaters:
        return 'Sunlit waters perfect for beginner marine life';
      case BiomeType.coralGarden:
        return 'Vibrant coral reefs teeming with colorful fish';
      case BiomeType.deepOcean:
        return 'Mysterious depths home to magnificent predators';
      case BiomeType.abyssalZone:
        return 'The deepest mysteries of the ocean floor';
    }
  }

  int get requiredLevel {
    switch (this) {
      case BiomeType.shallowWaters:
        return 1;
      case BiomeType.coralGarden:
        return 11;
      case BiomeType.deepOcean:
        return 26;
      case BiomeType.abyssalZone:
        return 51;
    }
  }

  List<String> get primaryColors {
    switch (this) {
      case BiomeType.shallowWaters:
        return ['#87CEEB', '#00A6D6']; // Light blue, tropical blue
      case BiomeType.coralGarden:
        return ['#FF7F7F', '#FF8C00', '#DDA0DD']; // Coral pink, orange, purple
      case BiomeType.deepOcean:
        return ['#0077BE', '#191970']; // Deep ocean blue, midnight blue
      case BiomeType.abyssalZone:
        return ['#000080', '#4B0082', '#8A2BE2']; // Navy, indigo, blue violet
    }
  }
}