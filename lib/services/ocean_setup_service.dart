import '../models/creature.dart';
import '../models/coral.dart';
import '../models/aquarium.dart';
import '../models/ocean_activity.dart';
import 'persistence/persistence_service.dart';
import 'ocean_activity_service.dart';

class OceanSetupService {
  static const String _defaultAquariumId = 'user_aquarium';

  /// Initialize a new user's ocean experience
  static Future<void> initializeNewUserAquarium() async {
    try {
      // 1. Create starter aquarium in Shallow Waters
      final aquarium = Aquarium(
        id: _defaultAquariumId,
        currentBiome: BiomeType.shallowWaters,
        pearlWallet: const PearlWallet(pearls: 100, crystals: 0), // Starter pearls
        ecosystemHealth: 1.0,
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
        unlockedBiomes: const {BiomeType.shallowWaters: true},
        settings: const AquariumSettings(),
        stats: const AquariumStats(),
      );

      await PersistenceService.instance.ocean.saveAquarium(aquarium);

      // 2. Populate creature database (all undiscovered)
      await _createCreatureDatabase();

      // 3. Create welcome activities
      await _createWelcomeActivities();

    } catch (e) {
      throw Exception('Failed to initialize ocean experience: $e');
    }
  }

  /// Check if user aquarium already exists
  static Future<bool> hasExistingAquarium() async {
    final aquarium = await PersistenceService.instance.ocean.getAquarium(_defaultAquariumId);
    return aquarium != null;
  }

  /// Get user's aquarium or create new one if needed
  static Future<Aquarium> getOrCreateAquarium() async {
    var aquarium = await PersistenceService.instance.ocean.getAquarium(_defaultAquariumId);
    
    if (aquarium == null) {
      await initializeNewUserAquarium();
      aquarium = await PersistenceService.instance.ocean.getAquarium(_defaultAquariumId);
    }
    
    return aquarium!;
  }

  /// Create the complete creature database
  static Future<void> _createCreatureDatabase() async {
    final creatures = _generateAllCreatures();
    
    for (final creature in creatures) {
      await PersistenceService.instance.ocean.saveCreature(creature);
    }
  }

  /// Create welcome activities for new users
  static Future<void> _createWelcomeActivities() async {
    // Welcome activity
    final welcomeActivity = OceanActivity(
      id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      type: OceanActivityType.biomeUnlocked,
      title: 'Welcome to Your Ocean Adventure!',
      description: '🌊 Your journey begins in the beautiful Shallow Waters. Start your first focus session to grow coral and attract marine life!',
      metadata: {
        'isWelcome': 'true',
        'startingBiome': 'Shallow Waters',
        'starterPearls': '100',
      },
      priority: ActivityPriority.high,
    );

    await PersistenceService.instance.ocean.saveOceanActivity(welcomeActivity);

    // Tutorial activity
    final tutorialActivity = OceanActivity(
      id: 'tutorial_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now().subtract(const Duration(seconds: 1)),
      type: OceanActivityType.pearlsEarned,
      title: 'Starter Resources Granted',
      description: '💎 You\'ve been granted 100 pearls to begin your ocean exploration. Use them wisely to grow your first coral!',
      metadata: {
        'isTutorial': 'true',
        'amount': '100',
        'source': 'new user bonus',
      },
      priority: ActivityPriority.normal,
    );

    await PersistenceService.instance.ocean.saveOceanActivity(tutorialActivity);
  }

  /// Generate all creatures for the database
  static List<Creature> _generateAllCreatures() {
    final creatures = <Creature>[];

    // Shallow Waters creatures (Level 1-10)
    creatures.addAll([
      _createCreature('clownfish', 'Clownfish', 'Amphiprioninae', CreatureRarity.common, CreatureType.starterFish, BiomeType.shallowWaters, 1, 10),
      _createCreature('angelfish', 'Angelfish', 'Pomacanthidae', CreatureRarity.common, CreatureType.starterFish, BiomeType.shallowWaters, 2, 15),
      _createCreature('blue_tang', 'Blue Tang', 'Paracanthurus hepatus', CreatureRarity.common, CreatureType.starterFish, BiomeType.shallowWaters, 3, 12),
      _createCreature('damselfish', 'Damselfish', 'Pomacentridae', CreatureRarity.common, CreatureType.starterFish, BiomeType.shallowWaters, 1, 8),
      _createCreature('butterflyfish', 'Butterflyfish', 'Chaetodontidae', CreatureRarity.uncommon, CreatureType.starterFish, BiomeType.shallowWaters, 5, 25),
      _createCreature('yellow_tang', 'Yellow Tang', 'Zebrasoma flavescens', CreatureRarity.common, CreatureType.starterFish, BiomeType.shallowWaters, 4, 18),
    ]);

    // Coral Garden creatures (Level 11-25)
    creatures.addAll([
      _createCreature('sea_anemone', 'Sea Anemone', 'Actiniaria', CreatureRarity.uncommon, CreatureType.reefBuilder, BiomeType.coralGarden, 6, 30),
      _createCreature('cleaner_wrasse', 'Cleaner Wrasse', 'Labroides dimidiatus', CreatureRarity.uncommon, CreatureType.reefBuilder, BiomeType.coralGarden, 8, 35),
      _createCreature('parrotfish', 'Parrotfish', 'Scaridae', CreatureRarity.uncommon, CreatureType.reefBuilder, BiomeType.coralGarden, 10, 40),
      _createCreature('grouper', 'Grouper', 'Epinephelinae', CreatureRarity.rare, CreatureType.reefBuilder, BiomeType.coralGarden, 15, 75),
      _createCreature('seahorse', 'Seahorse', 'Hippocampus', CreatureRarity.rare, CreatureType.reefBuilder, BiomeType.coralGarden, 12, 60),
      _createCreature('coral_trout', 'Coral Trout', 'Plectropomus leopardus', CreatureRarity.uncommon, CreatureType.reefBuilder, BiomeType.coralGarden, 14, 50),
    ]);

    // Deep Ocean creatures (Level 26-50)
    creatures.addAll([
      _createCreature('reef_shark', 'Reef Shark', 'Carcharhinus amblyrhynchos', CreatureRarity.rare, CreatureType.predator, BiomeType.deepOcean, 20, 100),
      _createCreature('moray_eel', 'Moray Eel', 'Muraenidae', CreatureRarity.rare, CreatureType.predator, BiomeType.deepOcean, 25, 120),
      _createCreature('giant_octopus', 'Giant Pacific Octopus', 'Enteroctopus dofleini', CreatureRarity.rare, CreatureType.predator, BiomeType.deepOcean, 30, 150),
      _createCreature('manta_ray', 'Manta Ray', 'Mobula birostris', CreatureRarity.legendary, CreatureType.deepSeaDweller, BiomeType.deepOcean, 35, 300),
      _createCreature('whale_shark', 'Whale Shark', 'Rhincodon typus', CreatureRarity.legendary, CreatureType.deepSeaDweller, BiomeType.deepOcean, 40, 400),
      _createCreature('hammerhead_shark', 'Hammerhead Shark', 'Sphyrnidae', CreatureRarity.rare, CreatureType.predator, BiomeType.deepOcean, 32, 180),
    ]);

    // Abyssal Zone creatures (Level 51+)
    creatures.addAll([
      _createCreature('bioluminescent_jellyfish', 'Bioluminescent Jellyfish', 'Atolla wyvillei', CreatureRarity.legendary, CreatureType.deepSeaDweller, BiomeType.abyssalZone, 45, 500),
      _createCreature('giant_squid', 'Giant Squid', 'Architeuthis dux', CreatureRarity.legendary, CreatureType.deepSeaDweller, BiomeType.abyssalZone, 50, 600),
      _createCreature('sea_dragon', 'Mythical Sea Dragon', 'Draco marinus', CreatureRarity.legendary, CreatureType.mythical, BiomeType.abyssalZone, 60, 1000),
      _createCreature('kraken', 'Ancient Kraken', 'Kraken giganteus', CreatureRarity.legendary, CreatureType.mythical, BiomeType.abyssalZone, 70, 2000),
      _createCreature('ocean_guardian', 'Ocean Guardian', 'Guardianus aquaticus', CreatureRarity.legendary, CreatureType.mythical, BiomeType.abyssalZone, 80, 5000),
      _createCreature('atlantean_guardian', 'Atlantean Guardian', 'Atlanticus mysticus', CreatureRarity.legendary, CreatureType.mythical, BiomeType.abyssalZone, 90, 10000),
    ]);

    return creatures;
  }

  static Creature _createCreature(
    String id,
    String name,
    String species,
    CreatureRarity rarity,
    CreatureType type,
    BiomeType habitat,
    int requiredLevel,
    int pearlValue,
  ) {
    return Creature(
      id: id,
      name: name,
      species: species,
      rarity: rarity,
      type: type,
      habitat: habitat,
      animationAsset: 'assets/creatures/$id.png',
      pearlValue: pearlValue,
      requiredLevel: requiredLevel,
      description: _getCreatureDescription(name, species, habitat),
      discoveryChance: rarity.baseDiscoveryChance,
      coralPreferences: _getCoralPreferences(type),
    );
  }

  static String _getCreatureDescription(String name, String species, BiomeType habitat) {
    final habitatDesc = habitat.description.toLowerCase();
    return 'A beautiful $name ($species) that thrives in the $habitatDesc of your aquarium ecosystem.';
  }

  static List<String> _getCoralPreferences(CreatureType type) {
    switch (type) {
      case CreatureType.starterFish:
        return ['brain', 'staghorn', 'soft'];
      case CreatureType.reefBuilder:
        return ['brain', 'table', 'soft'];
      case CreatureType.predator:
        return ['table', 'fire'];
      case CreatureType.deepSeaDweller:
        return ['table', 'fire', 'brain'];
      case CreatureType.mythical:
        return ['fire', 'brain']; // Prefer special corals
    }
  }

  /// Create a starter coral for new users (optional - they can choose their first coral)
  static Future<void> grantStarterCoral({CoralType type = CoralType.brain}) async {
    final coral = Coral(
      id: 'starter_coral_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      stage: CoralStage.polyp,
      growthProgress: 0.0,
      plantedAt: DateTime.now(),
      biome: BiomeType.shallowWaters,
      position: {'x': 0.5, 'y': 0.6}, // Center-bottom position
    );

    await PersistenceService.instance.ocean.saveCoral(coral);

    // Log coral planting activity
    await OceanActivityService.logCoralPlanted(
      coralType: type,
      biome: BiomeType.shallowWaters,
    );
  }

  /// Get total creature count by biome (for UI display)
  static Future<Map<BiomeType, int>> getCreatureCountByBiome() async {
    final creatures = await PersistenceService.instance.ocean.getAllCreatures();
    final counts = <BiomeType, int>{};
    
    for (final biome in BiomeType.values) {
      counts[biome] = creatures.where((c) => c.habitat == biome).length;
    }
    
    return counts;
  }

  /// Get discovered creatures percentage by biome
  static Future<Map<BiomeType, double>> getDiscoveryProgressByBiome() async {
    final allCreatures = await PersistenceService.instance.ocean.getAllCreatures();
    final discoveredCreatures = await PersistenceService.instance.ocean.getDiscoveredCreatures();
    
    final progress = <BiomeType, double>{};
    
    for (final biome in BiomeType.values) {
      final totalInBiome = allCreatures.where((c) => c.habitat == biome).length;
      final discoveredInBiome = discoveredCreatures.where((c) => c.habitat == biome).length;
      
      progress[biome] = totalInBiome > 0 ? discoveredInBiome / totalInBiome : 0.0;
    }
    
    return progress;
  }
}