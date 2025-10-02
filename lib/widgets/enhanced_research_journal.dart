import 'package:flutter/material.dart';
import '../models/creature.dart';
import '../data/comprehensive_species_database.dart';
import '../services/persistence/persistence_service.dart';
import '../services/gamification_service.dart';
import '../services/marine_biology_career_service.dart';
import '../themes/ocean_theme.dart';
import '../utils/responsive_helper.dart';
import '../utils/creature_asset_provider.dart';
import '../theme/ocean_theme_colors.dart';

/// Enhanced Research Journal Widget for Phase 2 of Ocean Gamification Master Plan
/// Provides comprehensive species tracking, discovery statistics, and research progress
class EnhancedResearchJournal extends StatefulWidget {
  final VoidCallback? onClose;

  const EnhancedResearchJournal({
    super.key,
    this.onClose,
  });

  @override
  State<EnhancedResearchJournal> createState() => _EnhancedResearchJournalState();
}

class _EnhancedResearchJournalState extends State<EnhancedResearchJournal>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  List<Creature> _discoveredCreatures = [];
  Map<BiomeType, int> _biomeProgress = {};
  Map<CreatureRarity, int> _rarityProgress = {};
  int _totalDiscovered = 0;
  int _currentRP = 0;
  String _currentCareerTitle = '';
  String _nextCareerMilestone = '';
  double _careerProgress = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 4, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _loadResearchData();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadResearchData() async {
    try {
      final discovered = await PersistenceService.instance.ocean.getDiscoveredCreatures();

      // Calculate progress by biome
      final biomeProgress = <BiomeType, int>{};
      for (final biome in BiomeType.values) {
        final discoveredInBiome = discovered.where((c) => c.habitat == biome).length;
        biomeProgress[biome] = discoveredInBiome;
      }

      // Calculate progress by rarity
      final rarityProgress = <CreatureRarity, int>{};
      for (final rarity in CreatureRarity.values) {
        final discoveredOfRarity = discovered.where((c) => c.rarity == rarity).length;
        rarityProgress[rarity] = discoveredOfRarity;
      }

      // Load RP-based career data
      final currentRP = GamificationService.instance.cumulativeRP;
      final careerTitle = MarineBiologyCareerService.getCareerTitle(currentRP);
      final nextMilestone = MarineBiologyCareerService.getNextCareerMilestone(currentRP);
      final careerProgress = MarineBiologyCareerService.getCareerProgress(currentRP);

      setState(() {
        _discoveredCreatures = discovered;
        _biomeProgress = biomeProgress;
        _rarityProgress = rarityProgress;
        _totalDiscovered = discovered.length;
        _currentRP = currentRP;
        _currentCareerTitle = careerTitle;
        _nextCareerMilestone = nextMilestone != null
          ? '${nextMilestone['title']} (${nextMilestone['requiredRP'] - currentRP} RP needed)'
          : 'Max Career Level Reached';
        _careerProgress = careerProgress;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OceanTheme.abyssal.withValues(alpha: 0.95),
      appBar: AppBar(
        backgroundColor: OceanTheme.deepSeaNavy.withValues(alpha: 0.95),
        title: Row(
          children: [
            Icon(Icons.menu_book, color: Colors.white, size: ResponsiveHelper.getIconSize(context, 'medium')),
            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
            Text(
              '🔬 Research Journal',
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title'),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white, size: ResponsiveHelper.getIconSize(context, 'medium')),
          onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: OceanThemeColors.seafoamGreen,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          tabs: const [
            Tab(
              icon: Icon(Icons.assessment),
              text: 'Overview',
            ),
            Tab(
              icon: Icon(Icons.terrain),
              text: 'Biomes',
            ),
            Tab(
              icon: Icon(Icons.collections),
              text: 'Species',
            ),
            Tab(
              icon: Icon(Icons.star),
              text: 'Discoveries',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(OceanThemeColors.seafoamGreen),
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildBiomesTab(),
                  _buildSpeciesTab(),
                  _buildDiscoveriesTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewTab() {
    final totalSpecies = ComprehensiveSpeciesDatabase.getTotalSpeciesCount();
    final completionPercentage = totalSpecies > 0 ? (_totalDiscovered / totalSpecies * 100) : 0.0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Research Progress Header
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'screen')),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  OceanTheme.deepSeaNavy.withValues(alpha: 0.7),
                  OceanTheme.midOcean.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: OceanThemeColors.seafoamGreen.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.school, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Research Career Progress',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title'),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: OceanThemeColors.seafoamGreen.withValues(alpha: 0.1),
                        border: Border.all(
                          color: OceanThemeColors.seafoamGreen.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$_currentRP RP',
                        style: TextStyle(
                          color: OceanThemeColors.seafoamGreen,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),

                // Career Title
                Text(
                  _currentCareerTitle,
                  style: TextStyle(
                    color: OceanThemeColors.seafoamGreen,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle'),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),

                // Career Progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nextCareerMilestone,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: _careerProgress.clamp(0.0, 1.0),
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(OceanThemeColors.seafoamGreen),
                      minHeight: 3,
                    ),
                  ],
                ),

                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),

                // Species Discovery Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          '$_totalDiscovered',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title'),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Species Discovered',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    Column(
                      children: [
                        Text(
                          '${(completionPercentage).toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title'),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Ocean Catalogued',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
          
          // Biome Progress Cards
          Text(
            '🏝️ Biome Exploration Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title'),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
          
          ...BiomeType.values.map((biome) => _buildBiomeProgressCard(biome)),
          
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
          
          // Rarity Statistics
          Text(
            '⭐ Rarity Collection Status',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title'),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
          
          ...CreatureRarity.values.map((rarity) => _buildRarityProgressCard(rarity)),
        ],
      ),
    );
  }

  Widget _buildBiomesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: BiomeType.values.map((biome) => _buildDetailedBiomeCard(biome)).toList(),
      ),
    );
  }

  Widget _buildSpeciesTab() {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            labelColor: OceanThemeColors.seafoamGreen,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
            indicatorColor: OceanThemeColors.seafoamGreen,
            tabs: BiomeType.values.map((biome) => Tab(text: biome.displayName.split(' ')[0])).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: BiomeType.values.map((biome) => _buildSpeciesGrid(biome)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveriesTab() {
    final recentDiscoveries = _discoveredCreatures
        .where((c) => c.discoveredAt != null)
        .toList()
      ..sort((a, b) => b.discoveredAt!.compareTo(a.discoveredAt!));

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: recentDiscoveries.length,
      itemBuilder: (context, index) {
        final creature = recentDiscoveries[index];
        return _buildDiscoveryCard(creature);
      },
    );
  }

  Widget _buildBiomeProgressCard(BiomeType biome) {
    final totalInBiome = ComprehensiveSpeciesDatabase.getSpeciesForBiome(biome).length;
    final discoveredInBiome = _biomeProgress[biome] ?? 0;
    final progress = totalInBiome > 0 ? discoveredInBiome / totalInBiome : 0.0;
    final isComplete = progress >= 1.0;

    // Get biome-specific colors using ocean theme
    Color biomeColor;
    String biomeIcon;
    switch (biome) {
      case BiomeType.shallowWaters:
        biomeColor = OceanThemeColors.seafoamGreen;
        biomeIcon = '🏝️';
        break;
      case BiomeType.coralGarden:
        biomeColor = OceanThemeColors.seafoamGreen;
        biomeIcon = '🪸';
        break;
      case BiomeType.deepOcean:
        biomeColor = OceanThemeColors.deepOceanBlue;
        biomeIcon = '🌊';
        break;
      case BiomeType.abyssalZone:
        biomeColor = OceanThemeColors.deepOceanBlue;
        biomeIcon = '🕳️';
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'card')),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            OceanTheme.cardBackground.withValues(alpha: 0.7),
            biomeColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: biomeColor.withValues(alpha: 0.4),
          width: isComplete ? 2 : 1,
        ),
        boxShadow: isComplete ? [
          BoxShadow(
            color: biomeColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Row(
        children: [
          // Biome icon with depth indicator
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  biomeColor.withValues(alpha: 0.8),
                  biomeColor.withValues(alpha: 0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: biomeColor.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                biomeIcon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        biome.displayName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isComplete)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: OceanThemeColors.seafoamGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'COMPLETE',
                          style: TextStyle(
                            color: OceanThemeColors.seafoamGreen,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
                Text(
                  '$discoveredInBiome/$totalInBiome species discovered',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(biomeColor),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: biomeColor,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRarityProgressCard(CreatureRarity rarity) {
    final totalOfRarity = ComprehensiveSpeciesDatabase.getSpeciesByRarity(rarity).length;
    final discoveredOfRarity = _rarityProgress[rarity] ?? 0;
    final progress = totalOfRarity > 0 ? discoveredOfRarity / totalOfRarity : 0.0;
    final isComplete = progress >= 1.0;

    Color rarityColor;
    String rarityEmoji;
    switch (rarity) {
      case CreatureRarity.common:
        rarityColor = OceanThemeColors.seafoamGreen;
        rarityEmoji = '🐟'; // Basic fish
        break;
      case CreatureRarity.uncommon:
        rarityColor = OceanThemeColors.deepOceanAccent;
        rarityEmoji = '🐠'; // Tropical fish
        break;
      case CreatureRarity.rare:
        rarityColor = OceanTheme.rarePurple;
        rarityEmoji = '🐡'; // Exotic fish
        break;
      case CreatureRarity.legendary:
        rarityColor = OceanTheme.legendaryOrange;
        rarityEmoji = '🦈'; // Shark (legendary)
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'card')),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            OceanTheme.cardBackground.withValues(alpha: 0.7),
            rarityColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rarityColor.withValues(alpha: 0.4),
          width: isComplete ? 2 : 1,
        ),
        boxShadow: isComplete ? [
          BoxShadow(
            color: rarityColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Rarity icon with glow effect
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      rarityColor.withValues(alpha: 0.8),
                      rarityColor.withValues(alpha: 0.3),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: rarityColor.withValues(alpha: 0.6),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    rarityEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            rarity.displayName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isComplete)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: rarityColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: rarityColor,
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'COMPLETE',
                                  style: TextStyle(
                                    color: rarityColor,
                                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
                    Text(
                      '$discoveredOfRarity/$totalOfRarity discovered',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                      ),
                    ),
                  ],
                ),
              ),
              // Count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: rarityColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: rarityColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  '$discoveredOfRarity',
                  style: TextStyle(
                    color: rarityColor,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
          // Progress bar
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(rarityColor),
                  minHeight: 4,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: rarityColor,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedBiomeCard(BiomeType biome) {
    final biomeSpecies = ComprehensiveSpeciesDatabase.getSpeciesForBiome(biome);
    final discoveredInBiome = _discoveredCreatures.where((c) => c.habitat == biome).length;
    final progress = biomeSpecies.isNotEmpty ? discoveredInBiome / biomeSpecies.length : 0.0;
    final isComplete = progress >= 1.0;

    // Get biome-specific colors and details
    Color biomeColor;
    String biomeIcon;
    String biomeDescription;
    switch (biome) {
      case BiomeType.shallowWaters:
        biomeColor = OceanThemeColors.seafoamGreen;
        biomeIcon = '🏝️';
        biomeDescription = 'Sunlit waters teeming with colorful marine life';
        break;
      case BiomeType.coralGarden:
        biomeColor = OceanThemeColors.seafoamGreen;
        biomeIcon = '🪸';
        biomeDescription = 'Vibrant coral ecosystems hosting diverse species';
        break;
      case BiomeType.deepOcean:
        biomeColor = OceanThemeColors.deepOceanBlue;
        biomeIcon = '🌊';
        biomeDescription = 'Mysterious depths with adapted marine creatures';
        break;
      case BiomeType.abyssalZone:
        biomeColor = OceanThemeColors.deepOceanBlue;
        biomeIcon = '🕳️';
        biomeDescription = 'The deepest realm of extraordinary life forms';
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, ResponsiveHelper.isMobile(context) ? 'card' : 'screen')),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            OceanTheme.cardBackground.withValues(alpha: 0.9),
            biomeColor.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.isMobile(context) ? 12 : 16),
        border: Border.all(
          color: biomeColor.withValues(alpha: 0.4),
          width: isComplete ? 2 : 1,
        ),
        boxShadow: isComplete ? [
          BoxShadow(
            color: biomeColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with biome info
          Row(
            children: [
              Container(
                width: ResponsiveHelper.isMobile(context) ? 60 : 70,
                height: ResponsiveHelper.isMobile(context) ? 60 : 70,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      biomeColor.withValues(alpha: 0.8),
                      biomeColor.withValues(alpha: 0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: biomeColor.withValues(alpha: 0.6),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    biomeIcon,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.isMobile(context) ? 28 : 32,
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            biome.displayName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, ResponsiveHelper.isMobile(context) ? 'subtitle' : 'title'),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isComplete)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.isMobile(context) ? 6 : 8,
                              vertical: ResponsiveHelper.isMobile(context) ? 2 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: OceanThemeColors.seafoamGreen.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: OceanThemeColors.seafoamGreen.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: OceanThemeColors.seafoamGreen,
                                  size: ResponsiveHelper.isMobile(context) ? 12 : 14,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'EXPLORED',
                                  style: TextStyle(
                                    color: OceanThemeColors.seafoamGreen,
                                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
                    Text(
                      biomeDescription,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, ResponsiveHelper.isMobile(context) ? 'caption' : 'body'),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),

          // Progress section
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'card')),
            decoration: BoxDecoration(
              color: biomeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: biomeColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Species Discovery Progress',
                      style: TextStyle(
                        color: biomeColor,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$discoveredInBiome/${biomeSpecies.length}',
                      style: TextStyle(
                        color: biomeColor,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(biomeColor),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: biomeColor,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),

          // Rarity breakdown - responsive layout
          Text(
            'Species by Rarity',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'element')),

          ResponsiveHelper.isMobile(context)
              ? Column(
                  children: CreatureRarity.values.map((rarity) => _buildBiomeRarityChip(biome, rarity, biomeSpecies)).toList(),
                )
              : Wrap(
                  spacing: ResponsiveHelper.getResponsiveSpacing(context, 'element'),
                  runSpacing: ResponsiveHelper.getResponsiveSpacing(context, 'element'),
                  children: CreatureRarity.values.map((rarity) => _buildBiomeRarityChip(biome, rarity, biomeSpecies)).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildBiomeRarityChip(BiomeType biome, CreatureRarity rarity, List<Creature> biomeSpecies) {
    final rarityCount = biomeSpecies.where((s) => s.rarity == rarity).length;
    final discoveredCount = _discoveredCreatures
        .where((c) => c.habitat == biome && c.rarity == rarity)
        .length;
    final progress = rarityCount > 0 ? discoveredCount / rarityCount : 0.0;
    final isComplete = progress >= 1.0;

    Color rarityColor;
    String rarityEmoji;
    switch (rarity) {
      case CreatureRarity.common:
        rarityColor = OceanThemeColors.seafoamGreen;
        rarityEmoji = '🐟';
        break;
      case CreatureRarity.uncommon:
        rarityColor = OceanThemeColors.deepOceanAccent;
        rarityEmoji = '🐠';
        break;
      case CreatureRarity.rare:
        rarityColor = OceanTheme.rarePurple;
        rarityEmoji = '🐡';
        break;
      case CreatureRarity.legendary:
        rarityColor = OceanTheme.legendaryOrange;
        rarityEmoji = '🦈';
        break;
    }

    return Container(
      margin: ResponsiveHelper.isMobile(context)
          ? EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveSpacing(context, 'element'))
          : EdgeInsets.zero,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsiveSpacing(context, 'card'),
        vertical: ResponsiveHelper.getResponsiveSpacing(context, 'element'),
      ),
      decoration: BoxDecoration(
        color: rarityColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: rarityColor.withValues(alpha: 0.3),
          width: isComplete ? 2 : 1,
        ),
      ),
      child: ResponsiveHelper.isMobile(context)
          ? Row(
              children: [
                Text(
                  rarityEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${rarity.displayName}: $discoveredCount/$rarityCount',
                    style: TextStyle(
                      color: rarityColor,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isComplete)
                  Icon(
                    Icons.check_circle,
                    color: rarityColor,
                    size: 16,
                  ),
              ],
            )
          : Text(
              '${rarity.displayName}: $discoveredCount/$rarityCount',
              style: TextStyle(
                color: rarityColor,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildSpeciesGrid(BiomeType biome) {
    final biomeSpecies = ComprehensiveSpeciesDatabase.getSpeciesForBiome(biome);
    final discoveredIds = _discoveredCreatures.map((c) => c.id).toSet();
    
    return GridView.builder(
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'card')),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : (ResponsiveHelper.isTablet(context) ? 3 : 4),
        childAspectRatio: ResponsiveHelper.isMobile(context) ? 0.85 : 0.8,
        crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 'navigation'),
        mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 'navigation'),
      ),
      itemCount: biomeSpecies.length,
      itemBuilder: (context, index) {
        final species = biomeSpecies[index];
        final isDiscovered = discoveredIds.contains(species.id);
        
        return _buildSpeciesCard(species, isDiscovered);
      },
    );
  }

  Widget _buildSpeciesCard(Creature species, bool isDiscovered) {
    Color rarityColor;
    switch (species.rarity) {
      case CreatureRarity.common:
        rarityColor = OceanThemeColors.seafoamGreen;
        break;
      case CreatureRarity.uncommon:
        rarityColor = OceanThemeColors.deepOceanAccent;
        break;
      case CreatureRarity.rare:
        rarityColor = OceanTheme.rarePurple;
        break;
      case CreatureRarity.legendary:
        rarityColor = OceanTheme.legendaryOrange;
        break;
    }

    final bool showDescription = !ResponsiveHelper.isMobile(context) && isDiscovered;
    final String description = isDiscovered ? _getSpeciesDescription(species) : '';
    
    return Container(
      decoration: BoxDecoration(
        gradient: isDiscovered
            ? LinearGradient(
                colors: [
                  OceanTheme.cardBackground.withValues(alpha: 0.9),
                  rarityColor.withValues(alpha: 0.1),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  OceanTheme.cardBackground.withValues(alpha: 0.8),
                  rarityColor.withValues(alpha: 0.05),
                  Colors.black.withValues(alpha: 0.9),
                ],
              ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.isMobile(context) ? 10 : 12),
        border: Border.all(
          color: isDiscovered
              ? rarityColor.withValues(alpha: 0.6)
              : rarityColor.withValues(alpha: 0.2),
          width: isDiscovered ? 2 : 1,
        ),
        boxShadow: isDiscovered ? [
          BoxShadow(
            color: rarityColor.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ] : [
          BoxShadow(
            color: rarityColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Species image using CreatureAssetProvider
            Container(
              width: double.infinity,
              height: ResponsiveHelper.isMobile(context) ? 50 : 60,
              decoration: BoxDecoration(
                gradient: isDiscovered
                    ? LinearGradient(
                        colors: [
                          rarityColor.withValues(alpha: 0.2),
                          rarityColor.withValues(alpha: 0.1),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          rarityColor.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.4),
                        ],
                      ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: rarityColor.withValues(alpha: isDiscovered ? 0.3 : 0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: isDiscovered
                    ? CreatureAssetProvider.buildCreatureImage(
                        creature: species,
                        height: ResponsiveHelper.isMobile(context) ? 50 : 60,
                        fit: BoxFit.contain,
                        showPlaceholder: true,
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          // Mysterious silhouette effect
                          Icon(
                            _getBiomeMysteryIcon(species.habitat),
                            size: ResponsiveHelper.getIconSize(context, 'large'),
                            color: rarityColor.withValues(alpha: 0.3),
                          ),
                          // Overlay scanning effect
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withValues(alpha: 0.05),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
            
            // Species name
            Text(
              isDiscovered ? species.name : _getLockedSpeciesText(species.rarity),
              style: TextStyle(
                color: isDiscovered ? Colors.white : rarityColor.withValues(alpha: 0.8),
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'element')),

            // Scientific name or discovery status
            Text(
              isDiscovered
                  ? species.species
                  : _getDiscoveryStatusText(species.rarity),
              style: TextStyle(
                color: isDiscovered
                    ? Colors.white.withValues(alpha: 0.7)
                    : rarityColor.withValues(alpha: 0.6),
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Description for larger screens
            if (showDescription) ...
              [
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
                Container(
                  padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'element')),
                  decoration: BoxDecoration(
                    color: rarityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: rarityColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                      height: 1.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],

            // Info button for mobile
            if (ResponsiveHelper.isMobile(context) && isDiscovered) ...
              [
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
                GestureDetector(
                  onTap: () => _showSpeciesDetails(species, rarityColor),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: rarityColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: rarityColor.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: rarityColor,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Learn More',
                          style: TextStyle(
                            color: rarityColor,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

            if (!showDescription && !ResponsiveHelper.isMobile(context)) Spacer(),
            if (ResponsiveHelper.isMobile(context)) Spacer(),
            
            // Rarity indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: rarityColor.withValues(alpha: isDiscovered ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: rarityColor.withValues(alpha: isDiscovered ? 0.4 : 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isDiscovered ? Icons.star : Icons.help_outline,
                    color: rarityColor.withValues(alpha: isDiscovered ? 1.0 : 0.7),
                    size: ResponsiveHelper.getIconSize(context, 'small'),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isDiscovered ? species.rarity.displayName : _getRarityHint(species.rarity),
                    style: TextStyle(
                      color: rarityColor.withValues(alpha: isDiscovered ? 1.0 : 0.8),
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveryCard(Creature creature) {
    Color rarityColor;
    switch (creature.rarity) {
      case CreatureRarity.common:
        rarityColor = OceanThemeColors.seafoamGreen;
        break;
      case CreatureRarity.uncommon:
        rarityColor = OceanThemeColors.deepOceanAccent;
        break;
      case CreatureRarity.rare:
        rarityColor = OceanTheme.rarePurple;
        break;
      case CreatureRarity.legendary:
        rarityColor = OceanTheme.legendaryOrange;
        break;
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'card')),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            OceanThemeColors.deepOceanBlue.withValues(alpha: 0.8),
            rarityColor.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rarityColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveHelper.isMobile(context) ? 50 : 60,
            height: ResponsiveHelper.isMobile(context) ? 50 : 60,
            decoration: BoxDecoration(
              color: rarityColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CreatureAssetProvider.buildCreatureImage(
                creature: creature,
                width: ResponsiveHelper.isMobile(context) ? 50 : 60,
                height: ResponsiveHelper.isMobile(context) ? 50 : 60,
                fit: BoxFit.cover,
                showPlaceholder: true,
              ),
            ),
          ),
          
          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  creature.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  creature.species,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: rarityColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      creature.rarity.displayName,
                      style: TextStyle(
                        color: rarityColor,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
                    Icon(
                      Icons.place,
                      color: OceanThemeColors.deepOceanAccent,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      creature.habitat.displayName,
                      style: TextStyle(
                        color: OceanThemeColors.deepOceanAccent,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                creature.discoveredAt != null
                    ? _formatDate(creature.discoveredAt!)
                    : 'Unknown',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                ),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: OceanThemeColors.seafoamGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+${creature.pearlValue} RP',
                  style: TextStyle(
                    color: OceanThemeColors.seafoamGreen,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getSpeciesDescription(Creature species) {
    // Return the creature's description or use real scientific facts
    if (species.description.isNotEmpty) {
      return species.description;
    }

    // Real species descriptions based on scientific research
    return _getRealSpeciesDescription(species.name, species.species, species.habitat, species.rarity);
  }

  String _getRealSpeciesDescription(String name, String scientificName, BiomeType habitat, CreatureRarity rarity) {
    // Real scientific descriptions based on research
    final speciesDescriptions = {
      // Clownfish family (Shallow Waters & Coral Garden)
      'clownfish': 'Lives in symbiotic relationship with sea anemones. Forms size-based social hierarchy with sequential hermaphroditism.',
      'anemonefish': 'Inhabits coral reefs up to 15m depth. Uses mucus layer immunity to live safely among stinging anemone tentacles.',
      'nemo': 'Communicates through popping and clicking sounds. Feeds on algae, copepods, and anemone waste materials.',

      // Blue Tang family (Coral Garden)
      'blue tang': 'Primarily herbivorous, grazing algae to maintain reef health. Forms large schools for communal feeding behavior.',
      'regal tang': 'Can grow up to 38cm and change color from blue to violet-white. Has razor-sharp caudal spine containing toxins.',
      'palette surgeonfish': 'Inhabits crystal-clear coral reef waters with strong currents. Juveniles are bright yellow, adults royal blue.',

      // Seahorse family (Shallow Waters & Coral Garden)
      'seahorse': 'Males give birth after 20-day gestation period. Propels using dorsal fin beating 30-70 times per second.',
      'sea horse': 'Monogamous species with excellent camouflage abilities. Eats 30-50 times daily due to lack of stomach.',
      'hippocampus': 'Territory ranges: males 1m², females 100m². Excellent ambush predators with tubular snouts.',

      // Manta Ray family (Deep Ocean)
      'manta ray': 'World\'s largest ray with 26-foot wingspan. Filter feeds on zooplankton while performing barrel rolls.',
      'giant manta': 'Weighs up to 5,300 pounds and lives over 45 years. Has largest brain-to-body ratio among fish.',
      'devil ray': 'Breaches water surface in aerial displays. Engages in "cyclone feeding" with up to 150 individuals.',

      // Octopus family (All depths)
      'octopus': 'Highly intelligent with three hearts and copper-based blood. Nocturnal hunter with remarkable camouflage abilities.',
      'common octopus': 'Lives 1-2 years, weighs up to 20 pounds. Solitary and territorial, constructing dens with collected objects.',
      'giant octopus': 'Changes color and texture instantly for camouflage. Hunts crabs, lobsters using powerful suction arms.',

      // Shark family (Deep Ocean & Abyssal)
      'shark': 'Apex predator with electroreception abilities. Cartilaginous skeleton allows exceptional maneuverability.',
      'great white': 'Can detect blood from 3 miles away. Breaches water when hunting seals near surface.',
      'tiger shark': 'Known as "wastebasket of the sea" for diverse diet. Excellent night vision for deep water hunting.',

      // Jellyfish family (All depths)
      'jellyfish': 'Composed of 95% water with no brain or heart. Uses jet propulsion and ocean currents for movement.',
      'moon jelly': 'Translucent bell can reach 40cm diameter. Feeds on plankton using stinging tentacles.',
      'sea nettle': 'Powerful neurotoxins in tentacles. Can survive in varying salinity levels from oceans to estuaries.',

      // Tropical fish (Coral Garden)
      'angelfish': 'Territorial species forming monogamous pairs. Grazes on algae and small invertebrates on reef surfaces.',
      'parrotfish': 'Creates coral sand through digestion. Essential for reef health, producing up to 840 pounds sand yearly.',
      'triggerfish': 'Uses powerful jaws to crack shells and coral. Aggressively defends cone-shaped territories.',

      // Deep sea creatures (Deep Ocean & Abyssal)
      'anglerfish': 'Uses bioluminescent lure to attract prey in darkness. Female can be 60 times larger than parasitic male.',
      'lanternfish': 'Comprises 65% of deep sea fish biomass. Vertical migrations following zooplankton prey.',
      'vampire squid': 'Neither squid nor octopus, lives in oxygen minimum zones. Can invert body inside-out when threatened.',
    };

    // Try exact name match first
    final lowerName = name.toLowerCase();
    for (final key in speciesDescriptions.keys) {
      if (lowerName.contains(key)) {
        return speciesDescriptions[key]!;
      }
    }

    // Fallback based on habitat and rarity
    return _getHabitatBasedDescription(habitat, rarity);
  }

  String _getHabitatBasedDescription(BiomeType habitat, CreatureRarity rarity) {
    final descriptions = {
      BiomeType.shallowWaters: {
        CreatureRarity.common: 'Thrives in sunlit shallow waters with abundant food sources. Forms schools for protection.',
        CreatureRarity.uncommon: 'Inhabits seagrass beds and sandy bottoms. Active during dawn and dusk feeding periods.',
        CreatureRarity.rare: 'Seeks shelter in rocky crevices during daylight. Exhibits unique territorial behaviors.',
        CreatureRarity.legendary: 'Ancient species adapted to tidal changes. Appears during specific lunar cycles.',
      },
      BiomeType.coralGarden: {
        CreatureRarity.common: 'Essential for coral reef ecosystem health. Lives symbiotically with coral polyps.',
        CreatureRarity.uncommon: 'Specialized feeder on coral-associated organisms. Maintains cleaning station territories.',
        CreatureRarity.rare: 'Master of coral camouflage with remarkable color-changing abilities. Solitary hunter.',
        CreatureRarity.legendary: 'Guardian of ancient coral formations. Key indicator species for reef health.',
      },
      BiomeType.deepOcean: {
        CreatureRarity.common: 'Adapted to low-light conditions with enhanced sensory organs. Efficient energy conservation.',
        CreatureRarity.uncommon: 'Vertical migrator following daily plankton movements. Specialized pressure adaptations.',
        CreatureRarity.rare: 'Produces bioluminescent displays for communication. Lives near thermal vents.',
        CreatureRarity.legendary: 'Master of deep ocean currents. Rarely observed by human researchers.',
      },
      BiomeType.abyssalZone: {
        CreatureRarity.common: 'Survives extreme pressure and perpetual darkness. Slow metabolism for energy conservation.',
        CreatureRarity.uncommon: 'Scavenges near hydrothermal vents rich in chemosynthetic bacteria.',
        CreatureRarity.rare: 'Exhibits extraordinary adaptations to abyssal conditions. Transparent or bioluminescent.',
        CreatureRarity.legendary: 'Ancient deep-sea guardian species. Evolutionary living fossil.',
      },
    };

    return descriptions[habitat]?[rarity] ?? 'Fascinating marine species with unique ecological adaptations.';
  }

  void _showSpeciesDetails(Creature species, Color rarityColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  OceanTheme.cardBackground.withValues(alpha: 0.98),
                  rarityColor.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: rarityColor.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            rarityColor.withValues(alpha: 0.8),
                            rarityColor.withValues(alpha: 0.4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CreatureAssetProvider.buildCreatureImage(
                          creature: species,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          showPlaceholder: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            species.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            species.species,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Rarity badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: rarityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: rarityColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: rarityColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        species.rarity.displayName,
                        style: TextStyle(
                          color: rarityColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getSpeciesDescription(species),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Additional info
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: OceanThemeColors.deepOceanAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.place,
                              color: OceanThemeColors.deepOceanAccent,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Habitat',
                              style: TextStyle(
                                color: OceanThemeColors.deepOceanAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              species.habitat.displayName,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: OceanThemeColors.seafoamGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.science,
                              color: OceanThemeColors.seafoamGreen,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Research Value',
                              style: TextStyle(
                                color: OceanThemeColors.seafoamGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '${species.pearlValue} RP',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getBiomeMysteryIcon(BiomeType biome) {
    switch (biome) {
      case BiomeType.shallowWaters:
        return Icons.waves; // Simple wave pattern for shallow waters
      case BiomeType.coralGarden:
        return Icons.scatter_plot; // Coral structure hint
      case BiomeType.deepOcean:
        return Icons.blur_on; // Deep mystery symbol
      case BiomeType.abyssalZone:
        return Icons.all_inclusive; // Infinite depths symbol
    }
  }

  String _getLockedSpeciesText(CreatureRarity rarity) {
    switch (rarity) {
      case CreatureRarity.common:
        return 'Species Cataloging...';
      case CreatureRarity.uncommon:
        return 'Research in Progress...';
      case CreatureRarity.rare:
        return 'Classification Pending...';
      case CreatureRarity.legendary:
        return 'Extraordinary Discovery...';
    }
  }

  String _getDiscoveryStatusText(CreatureRarity rarity) {
    switch (rarity) {
      case CreatureRarity.common:
        return 'Continue research sessions';
      case CreatureRarity.uncommon:
        return 'Specimen data incomplete';
      case CreatureRarity.rare:
        return 'Requires extensive fieldwork';
      case CreatureRarity.legendary:
        return 'Legendary species potential';
    }
  }

  String _getRarityHint(CreatureRarity rarity) {
    switch (rarity) {
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
}