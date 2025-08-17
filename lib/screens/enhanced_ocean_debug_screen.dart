import 'package:flutter/material.dart';
import '../models/aquarium.dart';
import '../models/creature.dart';
import '../data/comprehensive_species_database.dart';
import '../services/marine_biology_career_service.dart';
import '../services/creature_service.dart';
import '../widgets/species_discovery_overlay.dart';
import '../widgets/enhanced_research_journal.dart';
import '../widgets/marine_biology_career_widget.dart';
import '../widgets/equipment_indicator_widget.dart';
import '../rendering/advanced_creature_renderer.dart';
import '../rendering/biome_environment_renderer.dart';
import 'dart:math' as math;

/// Enhanced Ocean Debug Screen for Phase 2 & 3 Features
/// Showcases the comprehensive species database, discovery system, career progression, research journal,
/// and Phase 3 advanced graphics including creature rendering, biome environments, and equipment systems
class EnhancedOceanDebugScreen extends StatefulWidget {
  const EnhancedOceanDebugScreen({super.key});

  @override
  State<EnhancedOceanDebugScreen> createState() => _EnhancedOceanDebugScreenState();
}

class _EnhancedOceanDebugScreenState extends State<EnhancedOceanDebugScreen> 
    with TickerProviderStateMixin {
  
  // Core Ocean System
  Aquarium? aquarium;
  List<Creature> discoveredCreatures = [];
  int totalXP = 1250; // Mock XP for career system testing
  int currentLevel = 0;
  String careerTitle = "";
  
  // UI State
  bool isLoading = true;
  String statusMessage = "Initializing Enhanced Ocean System...";
  late TabController _tabController;
  
  // Mock session data for depth-based discovery testing
  double currentSessionDepth = 0.0;
  int currentSessionDuration = 25;
  bool sessionInProgress = false;
  late AnimationController _sessionController;

  // Phase 3 Graphics Testing State
  BiomeType selectedBiome = BiomeType.shallowWaters;
  double graphicsTestDepth = 10.0;
  double animationSpeed = 1.0;
  bool enableParticleEffects = true;
  bool enableAdvancedLighting = true;
  Creature? selectedCreatureForRendering;
  late AnimationController _graphicsController;
  
  // Continuous time tracking for smooth debug animations
  late DateTime _debugStartTime;
  double get _debugContinuousTime => DateTime.now().difference(_debugStartTime).inMilliseconds / 1000.0;

  @override
  void initState() {
    super.initState();
    
    // Initialize continuous time for debug animations
    _debugStartTime = DateTime.now();
    _tabController = TabController(length: 9, vsync: this); // Increased to 9 tabs for Phase 3
    _sessionController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _graphicsController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    _initializeEnhancedOceanSystem();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sessionController.dispose();
    _graphicsController.dispose();
    super.dispose();
  }

  Future<void> _initializeEnhancedOceanSystem() async {
    try {
      setState(() {
        statusMessage = "Loading comprehensive species database...";
      });
      
      // Initialize with comprehensive species database
      await _loadComprehensiveData();
      
      // Calculate career stats
      currentLevel = MarineBiologyCareerService.getLevelFromXP(totalXP);
      careerTitle = MarineBiologyCareerService.getCareerTitle(currentLevel);
      
      setState(() {
        isLoading = false;
        statusMessage = "Enhanced Ocean System loaded! 🌊 ${ComprehensiveSpeciesDatabase.getTotalSpeciesCount()} species available";
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        statusMessage = "Error loading enhanced system: $e";
      });
    }
  }

  Future<void> _loadComprehensiveData() async {
    // Create mock aquarium with enhanced features
    aquarium = Aquarium(
      id: 'enhanced_demo',
      currentBiome: BiomeType.coralGarden,
      pearlWallet: const PearlWallet(pearls: 450, crystals: 12),
      ecosystemHealth: 0.92,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      lastActiveAt: DateTime.now().subtract(const Duration(minutes: 30)),
      unlockedBiomes: const {
        BiomeType.shallowWaters: true,
        BiomeType.coralGarden: true,
        BiomeType.deepOcean: true,
      },
      settings: const AquariumSettings(),
      stats: const AquariumStats(
        totalCreaturesDiscovered: 23,
        totalCoralsGrown: 15,
        totalFocusTime: 1450, // 24+ hours
        currentStreak: 8,
        longestStreak: 15,
      ),
    );

    // Load some discovered species from the comprehensive database
    final allSpecies = ComprehensiveSpeciesDatabase.allSpecies;
    
    // Randomly select some discovered creatures across different rarities and biomes
    final commonSpecies = allSpecies.where((s) => s.rarity == CreatureRarity.common).take(15).toList();
    final uncommonSpecies = allSpecies.where((s) => s.rarity == CreatureRarity.uncommon).take(6).toList();
    final rareSpecies = allSpecies.where((s) => s.rarity == CreatureRarity.rare).take(2).toList();
    
    // Mark them as discovered with realistic discovery times
    discoveredCreatures = [
      ...commonSpecies.map((c) => c.copyWith(
        isDiscovered: true,
        discoveredAt: DateTime.now().subtract(Duration(days: math.Random().nextInt(14))),
      )),
      ...uncommonSpecies.map((c) => c.copyWith(
        isDiscovered: true,
        discoveredAt: DateTime.now().subtract(Duration(days: math.Random().nextInt(10))),
      )),
      ...rareSpecies.map((c) => c.copyWith(
        isDiscovered: true,
        discoveredAt: DateTime.now().subtract(Duration(hours: math.Random().nextInt(72))),
      )),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌊 Enhanced Ocean Debug - Phase 2'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.cyan,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.science), text: 'Species DB'),
            Tab(icon: Icon(Icons.explore), text: 'Discovery'),
            Tab(icon: Icon(Icons.menu_book), text: 'Research Journal'),
            Tab(icon: Icon(Icons.school), text: 'Career'),
            Tab(icon: Icon(Icons.water_drop), text: 'Session Sim'),
            Tab(icon: Icon(Icons.palette), text: 'Graphics Test'),
            Tab(icon: Icon(Icons.build_circle), text: 'Equipment'),
            Tab(icon: Icon(Icons.play_arrow), text: 'Actions'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E), // Deep ocean blue
              Color(0xFF3F51B5), // Medium blue
              Color(0xFF5C6BC0), // Light blue
            ],
          ),
        ),
        child: isLoading
            ? _buildLoadingScreen()
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(),
                  _buildSpeciesDatabaseTab(),
                  _buildDiscoveryTestingTab(),
                  _buildResearchJournalTab(),
                  _buildCareerProgressionTab(),
                  _buildSessionSimulatorTab(),
                  _buildGraphicsTestTab(),
                  _buildEquipmentTab(),
                  _buildActionsTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 24),
          Text(
            statusMessage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            '🐠 Loading comprehensive marine life database...\n🌊 Initializing depth-based discovery system...\n🎓 Setting up career progression...',
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phase 2 Overview
          _buildInfoCard(
            title: '🚀 Phase 2 Features Overview',
            icon: Icons.rocket_launch,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeatureStatus('Comprehensive Species Database', true, '144 species loaded'),
                _buildFeatureStatus('Depth-Based Discovery System', true, 'Master Plan integrated'),
                _buildFeatureStatus('Species Discovery Overlays', true, 'Full-screen celebrations'),
                _buildFeatureStatus('Enhanced Research Journal', true, 'Multi-tab interface'),
                _buildFeatureStatus('Marine Biology Career', true, '100 levels, certifications'),
                _buildFeatureStatus('Advanced XP Calculation', true, 'Multi-factor bonuses'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Database Statistics
          _buildInfoCard(
            title: '📊 Species Database Statistics',
            icon: Icons.analytics,
            child: Column(
              children: [
                _buildStatRow('Total Species', '${ComprehensiveSpeciesDatabase.getTotalSpeciesCount()}'),
                _buildStatRow('Discovered Species', '${discoveredCreatures.length}'),
                _buildStatRow('Discovery Progress', '${(discoveredCreatures.length / ComprehensiveSpeciesDatabase.getTotalSpeciesCount() * 100).toStringAsFixed(1)}%'),
                const Divider(color: Colors.white30),
                ...BiomeType.values.map((biome) {
                  final biomeTotal = ComprehensiveSpeciesDatabase.getSpeciesForBiome(biome).length;
                  final biomeDiscovered = discoveredCreatures.where((c) => c.habitat == biome).length;
                  return _buildBiomeStatRow(biome, biomeDiscovered, biomeTotal);
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Career Overview
          _buildInfoCard(
            title: '🎓 Marine Biology Career Status',
            icon: Icons.school,
            child: Column(
              children: [
                _buildStatRow('Current Level', '$currentLevel'),
                _buildStatRow('Career Title', careerTitle),
                _buildStatRow('Total XP', '$totalXP'),
                _buildStatRow('Specialization', MarineBiologyCareerService.getResearchSpecialization(discoveredCreatures)),
                _buildStatRow('Certifications', '${MarineBiologyCareerService.getCertifications(discoveredCreatures, totalXP, currentLevel).length}'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick Status
          _buildInfoCard(
            title: '🌊 Current Ocean Status',
            icon: Icons.water,
            child: Text(
              statusMessage,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeciesDatabaseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: '🗄️ Comprehensive Species Database',
            icon: Icons.storage,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Browse the complete marine life database with ${ComprehensiveSpeciesDatabase.getTotalSpeciesCount()} scientifically accurate species.',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                
                // Database validation
                Row(
                  children: [
                    Icon(
                      ComprehensiveSpeciesDatabase.validateDatabase() ? Icons.check_circle : Icons.error,
                      color: ComprehensiveSpeciesDatabase.validateDatabase() ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ComprehensiveSpeciesDatabase.validateDatabase() 
                          ? 'Database validation passed ✅'
                          : 'Database validation failed ❌',
                      style: TextStyle(
                        color: ComprehensiveSpeciesDatabase.validateDatabase() ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Biome breakdown
          ...BiomeType.values.map((biome) => _buildBiomeSpeciesCard(biome)),
        ],
      ),
    );
  }

  Widget _buildBiomeSpeciesCard(BiomeType biome) {
    final biomeSpecies = ComprehensiveSpeciesDatabase.getSpeciesForBiome(biome);
    final discoveredInBiome = discoveredCreatures.where((c) => c.habitat == biome).length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: _buildInfoCard(
        title: '${_getBiomeEmoji(biome)} ${biome.displayName}',
        icon: Icons.terrain,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              biome.description,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            
            _buildStatRow('Total Species', '${biomeSpecies.length}'),
            _buildStatRow('Discovered', '$discoveredInBiome'),
            _buildStatRow('Progress', '${(discoveredInBiome / biomeSpecies.length * 100).toStringAsFixed(1)}%'),
            
            const SizedBox(height: 12),
            
            // Rarity breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: CreatureRarity.values.map((rarity) {
                final rarityCount = biomeSpecies.where((s) => s.rarity == rarity).length;
                final rarityDiscovered = discoveredCreatures
                    .where((c) => c.habitat == biome && c.rarity == rarity).length;
                
                return Column(
                  children: [
                    Text(
                      _getRarityStars(rarity),
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '$rarityDiscovered/$rarityCount',
                      style: TextStyle(
                        color: _getRarityColor(rarity),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveryTestingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: '🔬 Discovery System Testing',
            icon: Icons.science,
            child: Column(
              children: [
                const Text(
                  'Test the enhanced discovery system with depth-based spawning and full-screen celebration overlays.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                // Discovery simulation controls
                const Text(
                  '🌊 Depth-Based Discovery Simulation',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                // Depth controls
                Row(
                  children: [
                    const Text('Session Depth: ', style: TextStyle(color: Colors.white70)),
                    Expanded(
                      child: Slider(
                        value: currentSessionDepth,
                        max: 60.0,
                        divisions: 12,
                        activeColor: Colors.cyan,
                        inactiveColor: Colors.cyan.withValues(alpha: 0.3),
                        onChanged: (value) {
                          setState(() {
                            currentSessionDepth = value;
                          });
                        },
                      ),
                    ),
                    Text('${currentSessionDepth.toStringAsFixed(1)}m', 
                         style: const TextStyle(color: Colors.white)),
                  ],
                ),
                
                // Duration controls
                Row(
                  children: [
                    const Text('Session Duration: ', style: TextStyle(color: Colors.white70)),
                    Expanded(
                      child: Slider(
                        value: currentSessionDuration.toDouble(),
                        min: 5,
                        max: 120,
                        divisions: 23,
                        activeColor: Colors.amber,
                        inactiveColor: Colors.amber.withValues(alpha: 0.3),
                        onChanged: (value) {
                          setState(() {
                            currentSessionDuration = value.toInt();
                          });
                        },
                      ),
                    ),
                    Text('${currentSessionDuration}min', 
                         style: const TextStyle(color: Colors.white)),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Expedition type indicator
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.cyan.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    _getExpeditionType(currentSessionDuration, currentSessionDepth),
                    style: const TextStyle(
                      color: Colors.cyan,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Discovery buttons by rarity
          _buildInfoCard(
            title: '🎯 Test Discovery by Rarity',
            icon: Icons.stars,
            child: Column(
              children: [
                const Text(
                  'Trigger discovery celebrations for each rarity tier',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: CreatureRarity.values.map((rarity) {
                    return ElevatedButton.icon(
                      onPressed: () => _testSpeciesDiscovery(rarity),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getRarityColor(rarity),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      icon: Text(_getRarityStars(rarity), style: const TextStyle(fontSize: 16)),
                      label: Text(rarity.displayName),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Random discovery button
                ElevatedButton.icon(
                  onPressed: _testRandomDiscovery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.casino),
                  label: const Text('Random Discovery'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Discovery statistics
          _buildInfoCard(
            title: '📈 Discovery Statistics',
            icon: Icons.analytics,
            child: Column(
              children: [
                _buildStatRow('Total Discoveries', '${discoveredCreatures.length}'),
                _buildStatRow('Recent Discoveries', 
                    '${discoveredCreatures.where((c) => c.discoveredAt != null && DateTime.now().difference(c.discoveredAt!).inHours < 24).length}'),
                _buildStatRow('Rarest Discovery', 
                    discoveredCreatures.isNotEmpty ? _getRarestDiscovery() : 'None'),
                _buildStatRow('XP from Discoveries', 
                    '${discoveredCreatures.fold<int>(0, (sum, c) => sum + c.pearlValue)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResearchJournalTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.menu_book,
            size: 80,
            color: Colors.white70,
          ),
          const SizedBox(height: 24),
          const Text(
            '📖 Enhanced Research Journal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Comprehensive species tracking with multi-tab interface',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          ElevatedButton.icon(
            onPressed: _openResearchJournal,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open Research Journal'),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                const Text(
                  'Features:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Overview tab with research progress\n'
                  '• Biomes tab with exploration status\n'
                  '• Species grid with discovery tracking\n'
                  '• Discoveries log with timestamps\n'
                  '• Career progression integration',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerProgressionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Career widget demo
          MarineBiologyCareerWidget(
            totalXP: totalXP,
            discoveredCreatures: discoveredCreatures,
            onTap: _openCareerDetails,
          ),
          
          const SizedBox(height: 20),
          
          // Career testing controls
          _buildInfoCard(
            title: '🧪 Career Progression Testing',
            icon: Icons.science,
            child: Column(
              children: [
                const Text(
                  'Test the marine biology career system with XP adjustments',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    const Text('Total XP: ', style: TextStyle(color: Colors.white70)),
                    Expanded(
                      child: Slider(
                        value: totalXP.toDouble(),
                        min: 0,
                        max: 10000,
                        divisions: 100,
                        activeColor: Colors.amber,
                        inactiveColor: Colors.amber.withValues(alpha: 0.3),
                        onChanged: (value) {
                          setState(() {
                            totalXP = value.toInt();
                            currentLevel = MarineBiologyCareerService.getLevelFromXP(totalXP);
                            careerTitle = MarineBiologyCareerService.getCareerTitle(currentLevel);
                          });
                        },
                      ),
                    ),
                    Text('$totalXP', style: const TextStyle(color: Colors.white)),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _adjustXP(100),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('+100 XP'),
                    ),
                    ElevatedButton(
                      onPressed: () => _adjustXP(500),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text('+500 XP'),
                    ),
                    ElevatedButton(
                      onPressed: () => _adjustXP(1000),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                      child: const Text('+1000 XP'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                ElevatedButton.icon(
                  onPressed: _openCareerDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.school),
                  label: const Text('View Detailed Career Screen'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // XP calculation demo
          _buildInfoCard(
            title: '🧮 XP Calculation Demo',
            icon: Icons.calculate,
            child: Column(
              children: [
                const Text(
                  'Multi-factor XP calculation based on discovery parameters',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                ...CreatureRarity.values.map((rarity) {
                  final mockCreature = Creature(
                    id: 'test_${rarity.name}',
                    name: 'Test ${rarity.displayName}',
                    species: 'Testicus ${rarity.name}',
                    rarity: rarity,
                    type: CreatureType.starterFish,
                    habitat: BiomeType.shallowWaters,
                    animationAsset: 'test.json',
                    pearlValue: rarity.pearlMultiplier * 10,
                    requiredLevel: 1,
                    description: 'Test creature',
                    discoveryChance: 0.5,
                  );
                  
                  final xp = MarineBiologyCareerService.calculateDiscoveryXP(
                    mockCreature,
                    sessionDepth: currentSessionDepth,
                    sessionDuration: currentSessionDuration,
                    isFirstDiscovery: true,
                    isSessionCompleted: true,
                  );
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getRarityColor(rarity).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _getRarityColor(rarity).withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${rarity.displayName} Discovery',
                          style: TextStyle(
                            color: _getRarityColor(rarity),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '+$xp XP',
                          style: TextStyle(
                            color: _getRarityColor(rarity),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionSimulatorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: '🌊 Depth-Based Session Simulator',
            icon: Icons.water_drop,
            child: Column(
              children: [
                const Text(
                  'Simulate realistic marine biology research expeditions with depth progression',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                // Session controls
                AnimatedBuilder(
                  animation: _sessionController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withValues(alpha: 0.3),
                            Colors.teal.withValues(alpha: 0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sessionInProgress 
                              ? Colors.cyan.withValues(alpha: 0.7)
                              : Colors.white.withValues(alpha: 0.3),
                          width: sessionInProgress ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                sessionInProgress ? Icons.water : Icons.science,
                                color: sessionInProgress ? Colors.cyan : Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                sessionInProgress ? 'Research Expedition In Progress' : 'Ready to Begin Expedition',
                                style: TextStyle(
                                  color: sessionInProgress ? Colors.cyan : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          
                          if (sessionInProgress) ...[
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: _sessionController.value,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Depth: ${(currentSessionDepth * _sessionController.value).toStringAsFixed(1)}m / ${currentSessionDepth.toStringAsFixed(1)}m',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Expedition type buttons
                const Text(
                  '🗺️ Select Expedition Type',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                Column(
                  children: [
                    _buildExpeditionButton('Shallow Water Research', 15, 10, Colors.lightBlue),
                    _buildExpeditionButton('Mid-Water Expedition', 25, 20, Colors.blue),
                    _buildExpeditionButton('Deep Sea Research', 45, 40, Colors.indigo),
                    _buildExpeditionButton('Abyssal Expedition', 90, 60, Colors.deepPurple),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Manual simulation button
                ElevatedButton.icon(
                  onPressed: sessionInProgress ? null : _startSimulatedSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sessionInProgress ? Colors.grey : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  icon: Icon(sessionInProgress ? Icons.hourglass_bottom : Icons.play_arrow),
                  label: Text(sessionInProgress ? 'Session in Progress...' : 'Start Custom Session'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Session results
          if (sessionInProgress)
            _buildInfoCard(
              title: '📊 Real-Time Session Data',
              icon: Icons.analytics,
              child: AnimatedBuilder(
                animation: _sessionController,
                builder: (context, child) {
                  final currentDepth = currentSessionDepth * _sessionController.value;
                  final biome = CreatureService.getBiomeFromDepth(currentDepth);
                  
                  return Column(
                    children: [
                      _buildStatRow('Current Depth', '${currentDepth.toStringAsFixed(1)}m'),
                      _buildStatRow('Current Biome', biome.displayName),
                      _buildStatRow('Session Progress', '${(_sessionController.value * 100).toStringAsFixed(1)}%'),
                      _buildStatRow('Discovery Chance', 
                          '${(CreatureService.applyDepthBasedDiscoveryRates(0.3, currentSessionDuration, currentDepth) * 100).toStringAsFixed(1)}%'),
                    ],
                  );
                },
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick actions
          _buildInfoCard(
            title: '⚡ Quick Test Actions',
            icon: Icons.flash_on,
            child: Column(
              children: [
                const Text(
                  'Perform various actions to test Phase 2 features',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildActionButton('Add Random Species', Icons.add, Colors.green, _addRandomDiscovery),
                    _buildActionButton('Gain XP Boost', Icons.trending_up, Colors.amber, _gainXPBoost),
                    _buildActionButton('Complete Session', Icons.check_circle, Colors.blue, _completeSession),
                    _buildActionButton('Open Journal', Icons.menu_book, Colors.teal, _openResearchJournal),
                    _buildActionButton('View Career', Icons.school, Colors.purple, _openCareerDetails),
                    _buildActionButton('Reset Progress', Icons.refresh, Colors.red, _resetProgress),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // System information
          _buildInfoCard(
            title: '🔧 System Information',
            icon: Icons.info,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Database Status', 
                    ComprehensiveSpeciesDatabase.validateDatabase() ? 'Valid ✅' : 'Invalid ❌'),
                _buildInfoRow('Species Loaded', '${ComprehensiveSpeciesDatabase.getTotalSpeciesCount()}'),
                _buildInfoRow('Discovery Overlays', 'Functional ✅'),
                _buildInfoRow('Career System', 'Active ✅'),
                _buildInfoRow('XP Calculation', 'Multi-factor ✅'),
                _buildInfoRow('Research Journal', 'Enhanced ✅'),
                const SizedBox(height: 12),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                  ),
                  child: const Text(
                    '🌊 Phase 2 Implementation Complete!\nAll major features are functional and ready for testing.',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widgets
  Widget _buildInfoCard({required String title, required IconData icon, required Widget child}) {
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
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildFeatureStatus(String feature, bool isComplete, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isComplete ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature,
                  style: TextStyle(
                    color: isComplete ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: isComplete ? Colors.white70 : Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
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

  Widget _buildBiomeStatRow(BiomeType biome, int discovered, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(_getBiomeEmoji(biome), style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(biome.displayName, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          Text('$discovered/$total', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildExpeditionButton(String name, int duration, double depth, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: () => _setExpeditionParams(duration, depth),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text('$name (${duration}min, ${depth}m)'),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      icon: Icon(icon, size: 16),
      label: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  // Helper methods
  String _getBiomeEmoji(BiomeType biome) {
    switch (biome) {
      case BiomeType.shallowWaters:
        return '🏝️';
      case BiomeType.coralGarden:
        return '🪸';
      case BiomeType.deepOcean:
        return '🌊';
      case BiomeType.abyssalZone:
        return '🕳️';
    }
  }

  String _getRarityStars(CreatureRarity rarity) {
    switch (rarity) {
      case CreatureRarity.common:
        return '⭐';
      case CreatureRarity.uncommon:
        return '⭐⭐';
      case CreatureRarity.rare:
        return '⭐⭐⭐';
      case CreatureRarity.legendary:
        return '⭐⭐⭐⭐';
    }
  }

  Color _getRarityColor(CreatureRarity rarity) {
    switch (rarity) {
      case CreatureRarity.common:
        return Colors.green;
      case CreatureRarity.uncommon:
        return Colors.blue;
      case CreatureRarity.rare:
        return Colors.purple;
      case CreatureRarity.legendary:
        return Colors.orange;
    }
  }

  String _getExpeditionType(int duration, double depth) {
    if (duration >= 15 && duration <= 20 && depth <= 10) {
      return '🏝️ Shallow Water Research (40% discovery bonus)';
    } else if (duration >= 25 && duration <= 30 && depth <= 20) {
      return '🪸 Mid-Water Expedition (25% discovery bonus)';
    } else if (duration >= 45 && duration <= 60 && depth <= 40) {
      return '🌊 Deep Sea Research (15% discovery bonus)';
    } else if (duration >= 90 && depth > 40) {
      return '🕳️ Abyssal Expedition (5% discovery bonus)';
    } else {
      return '🔬 Custom Research Parameters';
    }
  }

  String _getRarestDiscovery() {
    if (discoveredCreatures.isEmpty) return 'None';
    
    final legendary = discoveredCreatures.where((c) => c.rarity == CreatureRarity.legendary);
    if (legendary.isNotEmpty) return legendary.first.name;
    
    final rare = discoveredCreatures.where((c) => c.rarity == CreatureRarity.rare);
    if (rare.isNotEmpty) return rare.first.name;
    
    final uncommon = discoveredCreatures.where((c) => c.rarity == CreatureRarity.uncommon);
    if (uncommon.isNotEmpty) return uncommon.first.name;
    
    return discoveredCreatures.first.name;
  }

  // Action methods
  void _testSpeciesDiscovery(CreatureRarity rarity) {
    // Find undiscovered species of this rarity
    final allSpecies = ComprehensiveSpeciesDatabase.allSpecies;
    final undiscoveredOfRarity = allSpecies
        .where((s) => s.rarity == rarity)
        .where((s) => !discoveredCreatures.any((d) => d.id == s.id))
        .toList();
    
    if (undiscoveredOfRarity.isEmpty) {
      setState(() {
        statusMessage = 'No undiscovered ${rarity.displayName} species available!';
      });
      return;
    }
    
    // Select random species
    final randomSpecies = undiscoveredOfRarity[math.Random().nextInt(undiscoveredOfRarity.length)];
    
    // Show discovery overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SpeciesDiscoveryOverlay(
        discoveredCreature: randomSpecies,
        onDismiss: () {
          Navigator.of(context).pop();
          
          // Add to discovered list
          setState(() {
            discoveredCreatures.add(randomSpecies.copyWith(
              isDiscovered: true,
              discoveredAt: DateTime.now(),
            ));
            
            // Calculate and add XP
            final xp = MarineBiologyCareerService.calculateDiscoveryXP(
              randomSpecies,
              sessionDepth: currentSessionDepth,
              sessionDuration: currentSessionDuration,
              isFirstDiscovery: true,
              isSessionCompleted: true,
            );
            
            totalXP += xp;
            currentLevel = MarineBiologyCareerService.getLevelFromXP(totalXP);
            careerTitle = MarineBiologyCareerService.getCareerTitle(currentLevel);
            
            statusMessage = '🎉 Discovered ${randomSpecies.name}! +$xp XP (Total: $totalXP)';
          });
        },
        onAddToJournal: () {
          Navigator.of(context).pop();
          _openResearchJournal();
        },
      ),
    );
  }

  void _testRandomDiscovery() {
    final rarities = CreatureRarity.values;
    final randomRarity = rarities[math.Random().nextInt(rarities.length)];
    _testSpeciesDiscovery(randomRarity);
  }

  void _setExpeditionParams(int duration, double depth) {
    setState(() {
      currentSessionDuration = duration;
      currentSessionDepth = depth;
      statusMessage = 'Expedition parameters set: ${duration}min, ${depth}m';
    });
  }

  void _startSimulatedSession() {
    setState(() {
      sessionInProgress = true;
      statusMessage = 'Starting research expedition...';
    });
    
    _sessionController.forward().then((_) {
      setState(() {
        sessionInProgress = false;
        statusMessage = 'Research expedition completed! 🌊';
      });
      
      // Simulate potential discovery
      if (math.Random().nextDouble() < 0.6) { // 60% chance
        _testRandomDiscovery();
      }
      
      _sessionController.reset();
    });
  }

  void _openResearchJournal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EnhancedResearchJournal(
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _openCareerDetails() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MarineBiologyCareerScreen(
          totalXP: totalXP,
          discoveredCreatures: discoveredCreatures,
        ),
      ),
    );
  }

  void _adjustXP(int amount) {
    setState(() {
      totalXP += amount;
      currentLevel = MarineBiologyCareerService.getLevelFromXP(totalXP);
      careerTitle = MarineBiologyCareerService.getCareerTitle(currentLevel);
      statusMessage = 'Added $amount XP! New total: $totalXP (Level $currentLevel)';
    });
  }

  void _addRandomDiscovery() {
    _testRandomDiscovery();
  }

  void _gainXPBoost() {
    _adjustXP(250);
  }

  void _completeSession() {
    _adjustXP(100);
    setState(() {
      statusMessage = 'Session completed! +100 XP bonus';
    });
  }

  void _resetProgress() {
    setState(() {
      discoveredCreatures.clear();
      totalXP = 0;
      currentLevel = 1;
      careerTitle = "Marine Biology Intern";
      statusMessage = 'Progress reset! Starting fresh 🌊';
    });
  }

  /// Phase 3: Advanced Graphics Testing Tab
  Widget _buildGraphicsTestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('🎨 Phase 3 Graphics System Testing'),
          const SizedBox(height: 16),
          
          // Graphics Controls Section
          Card(
            color: Colors.black.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Graphics Controls',
                    style: TextStyle(
                      color: Colors.cyan.shade300,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Biome Selection
                  Text('Selected Biome:', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownButton<BiomeType>(
                    value: selectedBiome,
                    isExpanded: true,
                    dropdownColor: Colors.blueGrey.shade800,
                    style: const TextStyle(color: Colors.white),
                    items: BiomeType.values.map((biome) {
                      return DropdownMenuItem(
                        value: biome,
                        child: Text('${biome.displayName} (${biome.requiredLevel}+ level)'),
                      );
                    }).toList(),
                    onChanged: (BiomeType? value) {
                      if (value != null) {
                        setState(() {
                          selectedBiome = value;
                          // Adjust depth based on biome
                          switch (value) {
                            case BiomeType.shallowWaters:
                              graphicsTestDepth = 5.0;
                              break;
                            case BiomeType.coralGarden:
                              graphicsTestDepth = 15.0;
                              break;
                            case BiomeType.deepOcean:
                              graphicsTestDepth = 30.0;
                              break;
                            case BiomeType.abyssalZone:
                              graphicsTestDepth = 50.0;
                              break;
                          }
                        });
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Depth Control
                  Text('Depth: ${graphicsTestDepth.toStringAsFixed(1)}m', 
                       style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Slider(
                    value: graphicsTestDepth,
                    min: 0.0,
                    max: 60.0,
                    divisions: 60,
                    activeColor: Colors.cyan,
                    inactiveColor: Colors.grey,
                    onChanged: (double value) {
                      setState(() {
                        graphicsTestDepth = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Animation Speed Control
                  Text('Animation Speed: ${animationSpeed.toStringAsFixed(1)}x', 
                       style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Slider(
                    value: animationSpeed,
                    min: 0.1,
                    max: 3.0,
                    divisions: 29,
                    activeColor: Colors.orange,
                    inactiveColor: Colors.grey,
                    onChanged: (double value) {
                      setState(() {
                        animationSpeed = value;
                        _graphicsController.duration = Duration(milliseconds: (4000 / value).round());
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Toggle Controls
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: Text('Particle Effects', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          value: enableParticleEffects,
                          activeColor: Colors.green,
                          onChanged: (bool? value) {
                            setState(() {
                              enableParticleEffects = value ?? true;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: Text('Advanced Lighting', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          value: enableAdvancedLighting,
                          activeColor: Colors.yellow,
                          onChanged: (bool? value) {
                            setState(() {
                              enableAdvancedLighting = value ?? true;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Biome Environment Preview
          Card(
            color: Colors.black.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Biome Environment Preview',
                    style: TextStyle(
                      color: Colors.cyan.shade300,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
                    ),
                    child: AnimatedBuilder(
                      animation: _graphicsController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: BiomeEnvironmentTestPainter(
                            biome: selectedBiome,
                            depth: graphicsTestDepth,
                            sessionProgress: 0.6,
                            animationValue: _debugContinuousTime,
                            enableParticles: enableParticleEffects,
                            enableLighting: enableAdvancedLighting,
                          ),
                          size: Size.infinite,
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  Text(
                    'Real-time biome environment rendering with dynamic lighting and particle effects',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Creature Rendering Preview
          Card(
            color: Colors.black.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Advanced Creature Rendering',
                    style: TextStyle(
                      color: Colors.cyan.shade300,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Creature Selection
                  Text('Test Creature:', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownButton<Creature?>(
                    value: selectedCreatureForRendering,
                    hint: Text('Select a creature to test', style: TextStyle(color: Colors.white54)),
                    isExpanded: true,
                    dropdownColor: Colors.blueGrey.shade800,
                    style: const TextStyle(color: Colors.white),
                    items: [
                      const DropdownMenuItem<Creature?>(value: null, child: Text('None')),
                      ...discoveredCreatures.map((creature) {
                        return DropdownMenuItem(
                          value: creature,
                          child: Text('${creature.name} (${creature.rarity.displayName})'),
                        );
                      }),
                    ],
                    onChanged: (Creature? value) {
                      setState(() {
                        selectedCreatureForRendering = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (selectedCreatureForRendering != null) ...[
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.blue.shade900.withValues(alpha: 0.3),
                            Colors.blue.shade700.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                      child: AnimatedBuilder(
                        animation: _graphicsController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: AdvancedCreatureTestPainter(
                              creature: selectedCreatureForRendering!,
                              animationValue: _debugContinuousTime,
                              depth: graphicsTestDepth,
                            ),
                            size: Size.infinite,
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    Text(
                      'Advanced creature rendering with rarity-based complexity levels',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Creature Stats
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedCreatureForRendering!.name,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Species: ${selectedCreatureForRendering!.species}',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            'Rarity: ${selectedCreatureForRendering!.rarity.displayName}',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            'Habitat: ${selectedCreatureForRendering!.habitat.displayName}',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            'Rendering Complexity: ${_getComplexityLevel(selectedCreatureForRendering!.rarity)}',
                            style: TextStyle(color: Colors.cyan.shade300, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                      child: Center(
                        child: Text(
                          'Select a creature to preview advanced rendering',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Performance Metrics
          Card(
            color: Colors.black.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Graphics Performance Metrics',
                    style: TextStyle(
                      color: Colors.cyan.shade300,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard('Biome Rendering', 'Active', Colors.green),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard('Particle Systems', 
                            enableParticleEffects ? 'Enabled' : 'Disabled', 
                            enableParticleEffects ? Colors.green : Colors.orange),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard('Dynamic Lighting', 
                            enableAdvancedLighting ? 'Advanced' : 'Basic', 
                            enableAdvancedLighting ? Colors.green : Colors.blue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard('Animation Speed', 
                            '${animationSpeed.toStringAsFixed(1)}x', 
                            Colors.purple),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Phase 3: Equipment Testing Tab
  Widget _buildEquipmentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('🛠️ Marine Research Equipment System'),
          const SizedBox(height: 16),
          
          // Current Level Equipment
          Card(
            color: Colors.black.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Equipment for Level $currentLevel',
                    style: TextStyle(
                      color: Colors.cyan.shade300,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Equipment Indicator Widget
                  EquipmentIndicatorWidget(
                    userLevel: currentLevel,
                    unlockedEquipment: _getUnlockedEquipment(),
                    showCertifications: true,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Equipment Testing Controls
          Card(
            color: Colors.black.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Equipment Testing Controls',
                    style: TextStyle(
                      color: Colors.cyan.shade300,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text('Test Different Levels:', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [1, 10, 25, 50, 75, 100].map((level) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentLevel == level ? Colors.cyan : Colors.blueGrey.shade700,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            totalXP = MarineBiologyCareerService.getXPRequiredForLevel(level);
                            currentLevel = level;
                            careerTitle = MarineBiologyCareerService.getCareerTitle(level);
                          });
                        },
                        child: Text('Level $level'),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Equipment Progression Chart
          Card(
            color: Colors.black.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Equipment Progression Overview',
                    style: TextStyle(
                      color: Colors.cyan.shade300,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ..._buildEquipmentProgressionList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getComplexityLevel(CreatureRarity rarity) {
    switch (rarity) {
      case CreatureRarity.common:
        return 'Basic (Simple shape, basic animation)';
      case CreatureRarity.uncommon:
        return 'Enhanced (Gradient effects, complex fins)';
      case CreatureRarity.rare:
        return 'Advanced (Shimmer effects, glowing particles)';
      case CreatureRarity.legendary:
        return 'Master (Epic aura, screen-wide effects)';
    }
  }

  List<String> _getUnlockedEquipment() {
    List<String> equipment = [];
    if (currentLevel >= 1) equipment.add('mask_snorkel');
    if (currentLevel >= 2) equipment.add('fins');
    if (currentLevel >= 3) equipment.add('notebook');
    if (currentLevel >= 5) equipment.add('basic_camera');
    if (currentLevel >= 11) equipment.add('scuba_gear');
    if (currentLevel >= 15) equipment.add('digital_camera');
    if (currentLevel >= 26) equipment.add('tech_diving');
    if (currentLevel >= 35) equipment.add('rov');
    if (currentLevel >= 51) equipment.add('submersible');
    if (currentLevel >= 76) equipment.add('ai_assistant');
    return equipment;
  }

  List<Widget> _buildEquipmentProgressionList() {
    final equipmentData = [
      {'name': 'Mask & Snorkel', 'level': 1, 'category': 'Basic'},
      {'name': 'Diving Fins', 'level': 2, 'category': 'Basic'},
      {'name': 'Waterproof Notebook', 'level': 3, 'category': 'Basic'},
      {'name': 'Basic Camera', 'level': 5, 'category': 'Basic'},
      {'name': 'Scuba Gear', 'level': 11, 'category': 'Intermediate'},
      {'name': 'Underwater Lights', 'level': 13, 'category': 'Intermediate'},
      {'name': 'Digital Camera', 'level': 15, 'category': 'Intermediate'},
      {'name': 'Sample Kit', 'level': 18, 'category': 'Intermediate'},
      {'name': 'Tech Diving Gear', 'level': 26, 'category': 'Advanced'},
      {'name': 'Sonar System', 'level': 30, 'category': 'Advanced'},
      {'name': 'ROV Companion', 'level': 35, 'category': 'Advanced'},
      {'name': 'Specimen Lab', 'level': 40, 'category': 'Advanced'},
      {'name': 'Research Submersible', 'level': 51, 'category': 'Expert'},
      {'name': 'Genetic Sequencer', 'level': 60, 'category': 'Expert'},
      {'name': 'Satellite Comm', 'level': 65, 'category': 'Expert'},
      {'name': 'Breeding Facility', 'level': 70, 'category': 'Expert'},
      {'name': 'AI Assistant', 'level': 76, 'category': 'Master'},
      {'name': 'Holographic Display', 'level': 85, 'category': 'Master'},
      {'name': 'Time-lapse Camera', 'level': 90, 'category': 'Master'},
      {'name': 'Quantum Scanner', 'level': 95, 'category': 'Master'},
    ];

    return equipmentData.map((equipment) {
      final isUnlocked = currentLevel >= (equipment['level'] as int);
      final category = equipment['category'] as String;
      Color categoryColor;
      
      switch (category) {
        case 'Basic':
          categoryColor = Colors.green;
          break;
        case 'Intermediate':
          categoryColor = Colors.blue;
          break;
        case 'Advanced':
          categoryColor = Colors.orange;
          break;
        case 'Expert':
          categoryColor = Colors.purple;
          break;
        case 'Master':
          categoryColor = Colors.amber;
          break;
        default:
          categoryColor = Colors.grey;
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnlocked 
              ? categoryColor.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isUnlocked ? categoryColor : Colors.grey,
            width: isUnlocked ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isUnlocked ? Icons.check_circle : Icons.lock,
              color: isUnlocked ? categoryColor : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    equipment['name'] as String,
                    style: TextStyle(
                      color: isUnlocked ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Level ${equipment['level']} • $category',
                    style: TextStyle(
                      color: isUnlocked ? categoryColor : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.cyan.shade600.withValues(alpha: 0.8),
            Colors.blue.shade600.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painters for Graphics Testing
class BiomeEnvironmentTestPainter extends CustomPainter {
  final BiomeType biome;
  final double depth;
  final double sessionProgress;
  final double animationValue;
  final bool enableParticles;
  final bool enableLighting;

  BiomeEnvironmentTestPainter({
    required this.biome,
    required this.depth,
    required this.sessionProgress,
    required this.animationValue,
    required this.enableParticles,
    required this.enableLighting,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (enableLighting || enableParticles) {
      BiomeEnvironmentRenderer.paintBiomeEnvironment(
        canvas,
        size,
        biome,
        depth,
        sessionProgress,
        animationValue,
      );
    } else {
      // Basic rendering without advanced features
      final paint = Paint()..color = _getBasicBiomeColor();
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
  }

  Color _getBasicBiomeColor() {
    switch (biome) {
      case BiomeType.shallowWaters:
        return const Color(0xFF87CEEB);
      case BiomeType.coralGarden:
        return const Color(0xFF40E0D0);
      case BiomeType.deepOcean:
        return const Color(0xFF000080);
      case BiomeType.abyssalZone:
        return const Color(0xFF191970);
    }
  }

  @override
  bool shouldRepaint(BiomeEnvironmentTestPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.depth != depth ||
           oldDelegate.biome != biome ||
           oldDelegate.enableParticles != enableParticles ||
           oldDelegate.enableLighting != enableLighting;
  }
}

class AdvancedCreatureTestPainter extends CustomPainter {
  final Creature creature;
  final double animationValue;
  final double depth;

  AdvancedCreatureTestPainter({
    required this.creature,
    required this.animationValue,
    required this.depth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    AdvancedCreatureRenderer.paintCreature(
      canvas,
      size,
      creature,
      animationValue,
      depth,
    );
  }

  @override
  bool shouldRepaint(AdvancedCreatureTestPainter oldDelegate) {
    return oldDelegate.creature != creature ||
           oldDelegate.animationValue != animationValue ||
           oldDelegate.depth != depth;
  }
}