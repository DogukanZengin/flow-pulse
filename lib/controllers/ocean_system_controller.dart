import 'package:flutter/foundation.dart';
import '../models/aquarium.dart';
import '../models/creature.dart';
import '../models/coral.dart';
import '../services/creature_service.dart';
import '../services/ocean_audio_service.dart';
import '../services/depth_traversal_service.dart';
import '../services/gamification_service.dart';

class OceanSystemController extends ChangeNotifier {
  Aquarium? _aquarium;
  List<Creature> _visibleCreatures = [];
  List<Coral> _visibleCorals = [];
  bool _isOnSurface = false;
  final List<String> _completedBreakActivities = [];
  
  // Getters
  Aquarium? get aquarium => _aquarium;
  List<Creature> get visibleCreatures => _visibleCreatures;
  List<Coral> get visibleCorals => _visibleCorals;
  bool get isOnSurface => _isOnSurface;
  List<String> get completedBreakActivities => _completedBreakActivities;
  
  Future<void> initializeOceanSystem() async {
    try {
      // Create demo aquarium for the UI integration
      final demoAquarium = Aquarium(
        id: 'demo_aquarium',
        currentBiome: BiomeType.shallowWaters,
        pearlWallet: const PearlWallet(pearls: 150, crystals: 2),
        ecosystemHealth: 0.85,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        lastActiveAt: DateTime.now().subtract(const Duration(hours: 2)),
        unlockedBiomes: const {
          BiomeType.shallowWaters: true,
          BiomeType.coralGarden: true,
        },
        settings: const AquariumSettings(),
        stats: const AquariumStats(
          totalCreaturesDiscovered: 3,
          totalCoralsGrown: 2,
          totalFocusTime: 180,
          currentStreak: 4,
          longestStreak: 7,
        ),
      );
      
      // Create some demo creatures
      final demoCreatures = [
        Creature(
          id: 'clownfish',
          name: 'Clownfish',
          species: 'Amphiprioninae',
          rarity: CreatureRarity.common,
          type: CreatureType.starterFish,
          habitat: BiomeType.shallowWaters,
          animationAsset: 'assets/creatures/clownfish.png',
          pearlValue: 10,
          requiredLevel: 1,
          description: 'A friendly orange fish that lives in sea anemones',
          discoveryChance: 0.7,
          isDiscovered: true,
          discoveredAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Creature(
          id: 'blue_tang',
          name: 'Blue Tang',
          species: 'Paracanthurus hepatus',
          rarity: CreatureRarity.common,
          type: CreatureType.starterFish,
          habitat: BiomeType.shallowWaters,
          animationAsset: 'assets/creatures/blue_tang.png',
          pearlValue: 12,
          requiredLevel: 2,
          description: 'A vibrant blue fish with a peaceful nature',
          discoveryChance: 0.7,
          isDiscovered: true,
          discoveredAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
      
      // Create some demo corals
      final demoCorals = [
        Coral(
          id: 'brain_coral_1',
          type: CoralType.brain,
          stage: CoralStage.mature,
          growthProgress: 0.8,
          plantedAt: DateTime.now().subtract(const Duration(days: 3)),
          lastGrowthAt: DateTime.now().subtract(const Duration(hours: 4)),
          biome: BiomeType.shallowWaters,
          sessionsGrown: 3,
        ),
        Coral(
          id: 'staghorn_coral_1',
          type: CoralType.staghorn,
          stage: CoralStage.flourishing,
          growthProgress: 1.0,
          plantedAt: DateTime.now().subtract(const Duration(days: 2)),
          lastGrowthAt: DateTime.now().subtract(const Duration(hours: 1)),
          biome: BiomeType.shallowWaters,
          sessionsGrown: 4,
          attractedSpecies: ['clownfish'],
        ),
      ];
      
      _aquarium = demoAquarium;
      _visibleCreatures = demoCreatures;
      _visibleCorals = demoCorals;
      
      // Initialize ocean audio with current biome
      await initializeOceanAudio();
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing ocean system: $e');
      }
    }
  }
  
  Future<void> initializeOceanAudio() async {
    // Initialize ocean audio with current biome
    final biome = _aquarium?.currentBiome ?? BiomeType.shallowWaters;
    await OceanAudioService.instance.initializeBiomeAudio(biome);
  }
  
  Future<Creature?> checkForCreatureDiscovery(int sessionDuration) async {
    if (_aquarium == null) return null;
    
    // Calculate session depth using the RP-based accelerated traversal system
    final gamificationService = GamificationService.instance;
    final cumulativeRP = gamificationService.cumulativeRP;
    final sessionDepth = DepthTraversalService.calculateCurrentDepth(
      Duration(minutes: sessionDuration),
      cumulativeRP,
    );
    final discoveredCreature = await CreatureService.checkForCreatureDiscovery(
      aquarium: _aquarium!,
      sessionDurationMinutes: sessionDuration,
      sessionCompleted: true,
      sessionDepth: sessionDepth,
    );
    
    if (discoveredCreature != null) {
      // Add to visible creatures
      if (!_visibleCreatures.any((c) => c.id == discoveredCreature.id)) {
        _visibleCreatures.add(discoveredCreature);
        notifyListeners();
      }
    }
    
    return discoveredCreature;
  }
  
  void setOnSurface(bool onSurface) {
    if (_isOnSurface != onSurface) {
      _isOnSurface = onSurface;
      if (onSurface) {
        _completedBreakActivities.clear();
      }
      notifyListeners();
    }
  }
  
  void addCompletedBreakActivity(String activityType) {
    if (!_completedBreakActivities.contains(activityType)) {
      _completedBreakActivities.add(activityType);
      notifyListeners();
    }
  }
  
  void clearBreakActivities() {
    _completedBreakActivities.clear();
    notifyListeners();
  }
}