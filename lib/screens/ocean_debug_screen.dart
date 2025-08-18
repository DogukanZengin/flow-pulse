import 'package:flutter/material.dart';
import '../models/aquarium.dart';
import '../models/creature.dart';
import '../models/coral.dart';
import '../models/ocean_activity.dart';
import '../widgets/creature_discovery_animation.dart';
import 'dart:math' as math;

class OceanDebugScreen extends StatefulWidget {
  const OceanDebugScreen({super.key});

  @override
  State<OceanDebugScreen> createState() => _OceanDebugScreenState();
}

class _OceanDebugScreenState extends State<OceanDebugScreen> with SingleTickerProviderStateMixin {
  Aquarium? aquarium;
  List<Creature> allCreatures = [];
  List<Coral> allCorals = [];
  List<OceanActivity> recentActivities = [];
  bool isLoading = true;
  String statusMessage = "Loading ocean system...";
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeOceanSystem();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeOceanSystem() async {
    try {
      setState(() {
        statusMessage = "Initializing ocean system...";
      });

      // Create a mock aquarium for web demo
      await _createMockOceanData();

      setState(() {
        isLoading = false;
        statusMessage = "Ocean system loaded! (Demo mode for web)";
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        statusMessage = "Error loading ocean system: $e";
      });
    }
  }

  Future<void> _createMockOceanData() async {
    // Create a demo aquarium
    aquarium = Aquarium(
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
        totalCreaturesDiscovered: 5,
        totalCoralsGrown: 3,
        totalFocusTime: 180,
        currentStreak: 4,
        longestStreak: 7,
      ),
    );

    // Create demo creatures (mix of discovered and undiscovered)
    allCreatures = [
      // Discovered creatures
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
        discoveredAt: DateTime.now().subtract(const Duration(days: 3)),
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
        discoveredAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Creature(
        id: 'seahorse',
        name: 'Seahorse',
        species: 'Hippocampus',
        rarity: CreatureRarity.rare,
        type: CreatureType.reefBuilder,
        habitat: BiomeType.coralGarden,
        animationAsset: 'assets/creatures/seahorse.png',
        pearlValue: 60,
        requiredLevel: 12,
        description: 'A mystical creature that swims upright',
        discoveryChance: 0.08,
        isDiscovered: true,
        discoveredAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),

      // Undiscovered creatures
      Creature(
        id: 'angelfish',
        name: 'Angelfish',
        species: 'Pomacanthidae',
        rarity: CreatureRarity.common,
        type: CreatureType.starterFish,
        habitat: BiomeType.shallowWaters,
        animationAsset: 'assets/creatures/angelfish.png',
        pearlValue: 15,
        requiredLevel: 3,
        description: 'An elegant fish with flowing fins',
        discoveryChance: 0.7,
        isDiscovered: false,
      ),
      Creature(
        id: 'reef_shark',
        name: 'Reef Shark',
        species: 'Carcharhinus amblyrhynchos',
        rarity: CreatureRarity.rare,
        type: CreatureType.predator,
        habitat: BiomeType.deepOcean,
        animationAsset: 'assets/creatures/reef_shark.png',
        pearlValue: 100,
        requiredLevel: 20,
        description: 'A magnificent predator of the deep',
        discoveryChance: 0.08,
        isDiscovered: false,
      ),
      Creature(
        id: 'whale_shark',
        name: 'Whale Shark',
        species: 'Rhincodon typus',
        rarity: CreatureRarity.legendary,
        type: CreatureType.deepSeaDweller,
        habitat: BiomeType.deepOcean,
        animationAsset: 'assets/creatures/whale_shark.png',
        pearlValue: 400,
        requiredLevel: 40,
        description: 'The gentle giant of the ocean',
        discoveryChance: 0.02,
        isDiscovered: false,
      ),
    ];

    // Create demo corals
    allCorals = [
      Coral(
        id: 'brain_coral_1',
        type: CoralType.brain,
        stage: CoralStage.mature,
        growthProgress: 0.8,
        plantedAt: DateTime.now().subtract(const Duration(days: 5)),
        lastGrowthAt: DateTime.now().subtract(const Duration(hours: 6)),
        biome: BiomeType.shallowWaters,
        sessionsGrown: 4,
      ),
      Coral(
        id: 'staghorn_coral_1',
        type: CoralType.staghorn,
        stage: CoralStage.flourishing,
        growthProgress: 1.0,
        plantedAt: DateTime.now().subtract(const Duration(days: 3)),
        lastGrowthAt: DateTime.now().subtract(const Duration(hours: 2)),
        biome: BiomeType.shallowWaters,
        sessionsGrown: 6,
        attractedSpecies: ['clownfish'],
      ),
    ];

    // Create demo activities
    recentActivities = [
      OceanActivity.creatureDiscovered(
        creatureName: 'Seahorse',
        rarity: 'Rare',
        pearlsEarned: 60,
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      OceanActivity.coralGrown(
        coralType: 'Staghorn Coral',
        stage: 'Flourishing',
        sessionMinutes: 25,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      OceanActivity.pearlsEarned(
        amount: 25,
        source: 'focus session completed',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      OceanActivity.coralPlanted(
        coralType: 'Brain Coral',
        biome: 'Shallow Waters',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
      ),
      OceanActivity.streakMilestone(
        streakDays: 4,
        bonusPearls: 20,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  Future<void> _simulateSession() async {
    if (aquarium == null) return;

    setState(() {
      statusMessage = "Simulating focus session...";
    });

    try {
      // Simulate planting a new coral
      final coralTypes = CoralType.values;
      final randomCoralType = coralTypes[math.Random().nextInt(coralTypes.length)];
      
      final newCoral = Coral(
        id: 'coral_${DateTime.now().millisecondsSinceEpoch}',
        type: randomCoralType,
        stage: CoralStage.mature,
        growthProgress: 0.6 + math.Random().nextDouble() * 0.4, // 60-100% grown
        plantedAt: DateTime.now(),
        lastGrowthAt: DateTime.now(),
        biome: aquarium!.currentBiome,
        sessionsGrown: 1,
      );
      
      allCorals.add(newCoral);
      
      // Maybe discover a creature (40% chance)
      var pearlsEarned = 50;
      var discoveredCreature = '';
      
      if (math.Random().nextDouble() < 0.4) {
        final undiscoveredCreatures = allCreatures.where((c) => !c.isDiscovered).toList();
        if (undiscoveredCreatures.isNotEmpty) {
          final randomCreature = undiscoveredCreatures[math.Random().nextInt(undiscoveredCreatures.length)];
          
          // Mark creature as discovered in our demo data
          final index = allCreatures.indexWhere((c) => c.id == randomCreature.id);
          allCreatures[index] = randomCreature.copyWith(
            isDiscovered: true,
            discoveredAt: DateTime.now(),
          );
          
          pearlsEarned += randomCreature.pearlValue;
          discoveredCreature = randomCreature.name;
          
          // Add creature discovery activity
          recentActivities.insert(0, OceanActivity.creatureDiscovered(
            creatureName: randomCreature.name,
            rarity: randomCreature.rarity.displayName,
            pearlsEarned: randomCreature.pearlValue,
            timestamp: DateTime.now(),
          ));
        }
      }

      // Add coral planting activity
      recentActivities.insert(0, OceanActivity.coralPlanted(
        coralType: randomCoralType.displayName,
        biome: aquarium!.currentBiome.displayName,
        timestamp: DateTime.now(),
      ));

      // Add coral growth activity  
      recentActivities.insert(0, OceanActivity.coralGrown(
        coralType: randomCoralType.displayName,
        stage: newCoral.stage.displayName,
        sessionMinutes: 25,
        timestamp: DateTime.now(),
      ));

      // Add pearls earned activity
      recentActivities.insert(0, OceanActivity.pearlsEarned(
        amount: pearlsEarned,
        source: 'focus session completed',
        timestamp: DateTime.now(),
      ));

      // Update pearl wallet and stats
      final updatedWallet = aquarium!.pearlWallet.addPearls(pearlsEarned);
      final updatedStats = aquarium!.stats.copyWith(
        totalCoralsGrown: aquarium!.stats.totalCoralsGrown + 1,
        totalCreaturesDiscovered: discoveredCreature.isNotEmpty 
            ? aquarium!.stats.totalCreaturesDiscovered + 1 
            : aquarium!.stats.totalCreaturesDiscovered,
        totalFocusTime: aquarium!.stats.totalFocusTime + 25,
        currentStreak: aquarium!.stats.currentStreak + 1,
      );
      
      aquarium = aquarium!.copyWith(
        pearlWallet: updatedWallet,
        stats: updatedStats,
        lastActiveAt: DateTime.now(),
      );
      
      // Keep only recent activities
      if (recentActivities.length > 20) {
        recentActivities = recentActivities.take(20).toList();
      }

      setState(() {
        final discoveryMessage = discoveredCreature.isNotEmpty 
            ? " Discovered $discoveredCreature! 🐠" 
            : "";
        statusMessage = "Focus session completed! Earned $pearlsEarned pearls 💎$discoveryMessage";
      });
    } catch (e) {
      setState(() {
        statusMessage = "Error simulating session: $e";
      });
    }
  }

  Future<void> _refreshData() async {
    // For demo mode, just refresh the UI
    setState(() {
      statusMessage = "Data refreshed! 🔄";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌊 Ocean System Debug'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Aquarium'),
            Tab(icon: Icon(Icons.pets), text: 'Creatures'),
            Tab(icon: Icon(Icons.eco), text: 'Corals'),
            Tab(icon: Icon(Icons.history), text: 'Activities'),
            Tab(icon: Icon(Icons.science), text: 'Actions'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1976D2), // Deep blue
              Color(0xFF42A5F5), // Light blue
              Color(0xFF81C784), // Light green
            ],
          ),
        ),
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      statusMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildAquariumTab(),
                  _buildCreaturesTab(),
                  _buildCoralsTab(),
                  _buildActivitiesTab(),
                  _buildActionsTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildAquariumTab() {
    if (aquarium == null) {
      return const Center(child: Text('No aquarium data', style: TextStyle(color: Colors.white)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: 'Aquarium Status',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Current Biome', aquarium!.currentBiome.displayName),
                _buildInfoRow('Ecosystem Health', '${(aquarium!.ecosystemHealth * 100).toInt()}%'),
                _buildInfoRow('Created', _formatDate(aquarium!.createdAt)),
                _buildInfoRow('Last Active', _formatDate(aquarium!.lastActiveAt)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: '💎 Pearl Wallet',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Pearls', '${aquarium!.pearlWallet.pearls}'),
                _buildInfoRow('Crystals', '${aquarium!.pearlWallet.crystals}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: '🌊 Biome Progress',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final biome in BiomeType.values)
                  _buildBiomeRow(biome, aquarium!.isBiomeUnlocked(biome)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: '📊 Statistics',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Total Creatures', '${aquarium!.totalCreatures}'),
                _buildInfoRow('Total Corals', '${aquarium!.totalCorals}'),
                _buildInfoRow('Biodiversity Index', '${(aquarium!.biodiversityIndex * 100).toInt()}%'),
                _buildInfoRow('Daily Pearl Income', '${aquarium!.dailyPearlIncome}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreaturesTab() {
    final discoveredCreatures = allCreatures.where((c) => c.isDiscovered).toList();
    final undiscoveredCreatures = allCreatures.where((c) => !c.isDiscovered).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: '🐠 Discovered Creatures (${discoveredCreatures.length})',
            child: discoveredCreatures.isEmpty
                ? const Text('No creatures discovered yet. Complete focus sessions to discover marine life!',
                    style: TextStyle(color: Colors.white70))
                : Column(
                    children: discoveredCreatures.map((creature) => _buildCreatureRow(creature, true)).toList(),
                  ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: '❓ Undiscovered Creatures (${undiscoveredCreatures.length})',
            child: Column(
              children: undiscoveredCreatures.take(10).map((creature) => _buildCreatureRow(creature, false)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoralsTab() {
    if (allCorals.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoCard(
              title: '🪸 Your Coral Garden',
              child: const Text(
                'No corals planted yet. Use the Actions tab to simulate planting coral during focus sessions!',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: '📖 Coral Types Available',
              child: Column(
                children: CoralType.values.map((type) => _buildCoralTypeInfo(type)).toList(),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: '🪸 Your Coral Garden (${allCorals.length})',
            child: Column(
              children: allCorals.map((coral) => _buildCoralRow(coral)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab() {
    if (recentActivities.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoCard(
              title: '📜 Ocean Activities',
              child: const Text(
                'No activities yet. Your ocean journey will be logged here as you complete focus sessions!',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: '📜 Recent Ocean Activities (${recentActivities.length})',
            child: Column(
              children: recentActivities.map((activity) => _buildActivityRow(activity)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoCard(
            title: '🧪 Test Ocean System',
            child: Column(
              children: [
                const Text(
                  'Simulate ocean activities to see the system in action!',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _simulateSession,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Simulate Focus Session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Creature Discovery Debug Buttons
                const Divider(color: Colors.white30),
                const Text(
                  '🐠 Test Creature Discovery',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildCreatureDiscoveryButton(CreatureRarity.common, Colors.grey),
                    _buildCreatureDiscoveryButton(CreatureRarity.uncommon, Colors.green),
                    _buildCreatureDiscoveryButton(CreatureRarity.rare, Colors.blue),
                    _buildCreatureDiscoveryButton(CreatureRarity.legendary, Colors.purple),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Quick Actions
                const Divider(color: Colors.white30),
                const Text(
                  '⚡ Quick Actions',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _triggerPollutionEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Pollution Event'),
                    ),
                    ElevatedButton(
                      onPressed: _addRandomActivity,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Random Activity'),
                    ),
                    ElevatedButton(
                      onPressed: _resetAllProgress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Reset Progress'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                ElevatedButton.icon(
                  onPressed: _refreshData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  statusMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildBiomeRow(BiomeType biome, bool isUnlocked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(biome.displayName, style: const TextStyle(color: Colors.white70)),
          Icon(
            isUnlocked ? Icons.check_circle : Icons.lock,
            color: isUnlocked ? Colors.green : Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildCreatureRow(Creature creature, bool isDiscovered) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isDiscovered ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: creature.rarity.color.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: creature.rarity.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                creature.type.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDiscovered ? creature.name : '???',
                  style: TextStyle(
                    color: isDiscovered ? Colors.white : Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isDiscovered ? '${creature.rarity.displayName} • ${creature.habitat.displayName}' : 'Undiscovered',
                  style: TextStyle(
                    color: isDiscovered ? Colors.white70 : Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isDiscovered)
            Text(
              '${creature.pearlValue}💎',
              style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildCoralRow(Coral coral) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: coral.type.color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text('🪸', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coral.type.displayName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${coral.stage.displayName} • ${(coral.growthProgress * 100).toInt()}% grown',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          if (coral.isFullyGrown)
            const Text('✨', style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildCoralTypeInfo(CoralType type) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🪸', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                type.displayName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${type.pearlCost}💎',
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            type.benefit,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(OceanActivity activity) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: activity.priority.uiColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(activity.type.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  activity.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            activity.formattedTime,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  Color _getRarityColor(CreatureRarity rarity) {
    switch (rarity) {
      case CreatureRarity.common:
        return Colors.grey;
      case CreatureRarity.uncommon:
        return Colors.green;
      case CreatureRarity.rare:
        return Colors.blue;
      case CreatureRarity.legendary:
        return Colors.purple;
    }
  }
  
  Widget _buildCreatureDiscoveryButton(CreatureRarity rarity, Color color) {
    return ElevatedButton(
      onPressed: () => _testCreatureDiscovery(rarity),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      child: Text('${rarity.displayName} Discovery'),
    );
  }
  
  void _testCreatureDiscovery(CreatureRarity rarity) {
    // Get color for rarity
    final color = _getRarityColor(rarity);
    
    // Find an undiscovered creature of this rarity
    final candidates = allCreatures.where((c) => 
      !c.isDiscovered && c.rarity == rarity
    ).toList();
    
    if (candidates.isEmpty) {
      setState(() {
        statusMessage = "No undiscovered ${rarity.displayName} creatures available!";
      });
      return;
    }
    
    // Pick a random creature and mark it as discovered
    final creature = candidates[math.Random().nextInt(candidates.length)];
    final index = allCreatures.indexWhere((c) => c.id == creature.id);
    allCreatures[index] = creature.copyWith(
      isDiscovered: true,
      discoveredAt: DateTime.now(),
    );
    
    // Add discovery activity
    recentActivities.insert(0, OceanActivity.creatureDiscovered(
      creatureName: creature.name,
      rarity: creature.rarity.displayName,
      pearlsEarned: creature.pearlValue,
      timestamp: DateTime.now(),
    ));
    
    // Update pearl wallet
    final updatedWallet = aquarium!.pearlWallet.addPearls(creature.pearlValue);
    aquarium = aquarium!.copyWith(
      pearlWallet: updatedWallet,
      stats: aquarium!.stats.copyWith(
        totalCreaturesDiscovered: aquarium!.stats.totalCreaturesDiscovered + 1,
      ),
    );
    
    setState(() {
      statusMessage = "🎉 Discovered ${creature.name} (${rarity.displayName})! +${creature.pearlValue} pearls";
    });
    
    // Show the actual discovery animation
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => CreatureDiscoveryAnimation(
        creature: creature,
        onComplete: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🐠 ${creature.name} added to your collection!'),
              backgroundColor: color,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
  
  void _triggerPollutionEvent() {
    // Add pollution activity
    recentActivities.insert(0, OceanActivity.pollutionEvent(
      reason: 'Debug pollution test',
      damageAmount: 10,
      timestamp: DateTime.now(),
    ));
    
    // Reduce ecosystem health
    final newHealth = (aquarium!.ecosystemHealth - 0.1).clamp(0.0, 1.0);
    aquarium = aquarium!.copyWith(ecosystemHealth: newHealth);
    
    setState(() {
      statusMessage = "⚠️ Pollution event triggered! Ecosystem health: ${(newHealth * 100).toInt()}%";
    });
  }
  
  void _addRandomActivity() {
    final activities = [
      () => OceanActivity.pearlsEarned(
        amount: 25,
        source: 'debug bonus',
        timestamp: DateTime.now(),
      ),
      () => OceanActivity.streakMilestone(
        streakDays: 7,
        bonusPearls: 50,
        timestamp: DateTime.now(),
      ),
      () => OceanActivity(
        id: 'ecosystem_${DateTime.now().millisecondsSinceEpoch}',
        timestamp: DateTime.now(),
        type: OceanActivityType.ecosystemThriving,
        title: 'Ecosystem Flourishing',
        description: '✨ Your reef is thriving beautifully!',
        metadata: {},
        priority: ActivityPriority.normal,
      ),
    ];
    
    final randomActivity = activities[math.Random().nextInt(activities.length)]();
    recentActivities.insert(0, randomActivity);
    
    setState(() {
      statusMessage = "📝 Added random activity: ${randomActivity.title}";
    });
  }
  
  void _resetAllProgress() {
    // Reset all creatures to undiscovered
    allCreatures = allCreatures.map((c) => c.copyWith(
      isDiscovered: false,
      discoveredAt: null,
    )).toList();
    
    // Reset aquarium stats
    aquarium = aquarium!.copyWith(
      pearlWallet: const PearlWallet(pearls: 100, crystals: 0),
      ecosystemHealth: 1.0,
      stats: const AquariumStats(),
    );
    
    // Clear activities and corals
    recentActivities.clear();
    allCorals.clear();
    
    setState(() {
      statusMessage = "🔄 All progress has been reset!";
    });
  }
}

// Extension to add missing properties
extension CreatureTypeEmoji on CreatureType {
  String get emoji {
    switch (this) {
      case CreatureType.starterFish:
        return '🐠';
      case CreatureType.reefBuilder:
        return '🐟';
      case CreatureType.predator:
        return '🦈';
      case CreatureType.deepSeaDweller:
        return '🐋';
      case CreatureType.mythical:
        return '🐉';
    }
  }
}

extension CreatureRarityColor on CreatureRarity {
  Color get color {
    switch (this) {
      case CreatureRarity.common:
        return Colors.grey;
      case CreatureRarity.uncommon:
        return Colors.green;
      case CreatureRarity.rare:
        return Colors.blue;
      case CreatureRarity.legendary:
        return Colors.purple;
    }
  }
}

extension CoralTypeColor on CoralType {
  Color get color {
    switch (this) {
      case CoralType.brain:
        return Colors.pink;
      case CoralType.staghorn:
        return Colors.orange;
      case CoralType.table:
        return Colors.brown;
      case CoralType.soft:
        return Colors.purple;
      case CoralType.fire:
        return Colors.red;
    }
  }
}

extension ActivityPriorityUIColor on ActivityPriority {
  Color get uiColor {
    switch (this) {
      case ActivityPriority.low:
        return const Color(0xFF87CEEB);
      case ActivityPriority.normal:
        return const Color(0xFF00A6D6);
      case ActivityPriority.high:
        return const Color(0xFFFF8C00);
      case ActivityPriority.urgent:
        return const Color(0xFFFF6B6B);
    }
  }
}