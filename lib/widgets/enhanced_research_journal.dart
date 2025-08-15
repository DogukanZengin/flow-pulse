import 'package:flutter/material.dart';
import '../models/creature.dart';
import '../data/comprehensive_species_database.dart';
import '../services/database_service.dart';

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
      final discovered = await DatabaseService.getDiscoveredCreatures();
      
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
      
      setState(() {
        _discoveredCreatures = discovered;
        _biomeProgress = biomeProgress;
        _rarityProgress = rarityProgress;
        _totalDiscovered = discovered.length;
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
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: const Row(
          children: [
            Icon(Icons.menu_book, color: Colors.white),
            SizedBox(width: 12),
            Text(
              '🔬 Research Journal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.cyan,
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
                valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A237E).withValues(alpha: 0.8),
                  const Color(0xFF3F51B5).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.cyan.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  '🌊 Marine Biology Research Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Overall Progress Circle
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: completionPercentage / 100,
                        strokeWidth: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          completionPercentage > 75 ? Colors.green :
                          completionPercentage > 50 ? Colors.orange :
                          completionPercentage > 25 ? Colors.yellow :
                          Colors.cyan,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${completionPercentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$_totalDiscovered/$totalSpecies',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                Text(
                  _getResearcherTitle(completionPercentage),
                  style: TextStyle(
                    color: Colors.cyan,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Biome Progress Cards
          const Text(
            '🏝️ Biome Exploration Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...BiomeType.values.map((biome) => _buildBiomeProgressCard(biome)),
          
          const SizedBox(height: 24),
          
          // Rarity Statistics
          const Text(
            '⭐ Rarity Collection Status',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
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
            labelColor: Colors.cyan,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
            indicatorColor: Colors.cyan,
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
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color(int.parse(biome.primaryColors.first.substring(1), radix: 16) + 0xFF000000)
              .withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 40,
            decoration: BoxDecoration(
              color: Color(int.parse(biome.primaryColors.first.substring(1), radix: 16) + 0xFF000000),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  biome.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$discoveredInBiome/$totalInBiome species discovered',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(int.parse(biome.primaryColors.first.substring(1), radix: 16) + 0xFF000000),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(progress * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Colors.cyan,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRarityProgressCard(CreatureRarity rarity) {
    final totalOfRarity = ComprehensiveSpeciesDatabase.getSpeciesByRarity(rarity).length;
    final discoveredOfRarity = _rarityProgress[rarity] ?? 0;
    
    Color rarityColor;
    switch (rarity) {
      case CreatureRarity.common:
        rarityColor = Colors.green;
        break;
      case CreatureRarity.uncommon:
        rarityColor = Colors.blue;
        break;
      case CreatureRarity.rare:
        rarityColor = Colors.purple;
        break;
      case CreatureRarity.legendary:
        rarityColor = Colors.orange;
        break;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: rarityColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star,
            color: rarityColor,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '${rarity.displayName}: $discoveredOfRarity/$totalOfRarity',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (discoveredOfRarity > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: rarityColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$discoveredOfRarity',
                style: TextStyle(
                  color: rarityColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailedBiomeCard(BiomeType biome) {
    final biomeSpecies = ComprehensiveSpeciesDatabase.getSpeciesForBiome(biome);
    final discoveredInBiome = _discoveredCreatures.where((c) => c.habitat == biome).length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A237E).withValues(alpha: 0.8),
            Color(int.parse(biome.primaryColors.first.substring(1), radix: 16) + 0xFF000000)
                .withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Color(int.parse(biome.primaryColors.first.substring(1), radix: 16) + 0xFF000000)
              .withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _getBiomeEmoji(biome),
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      biome.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      biome.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Progress: $discoveredInBiome/${biomeSpecies.length} species',
            style: const TextStyle(
              color: Colors.cyan,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Rarity breakdown for this biome
          Wrap(
            spacing: 8,
            children: CreatureRarity.values.map((rarity) {
              final rarityCount = biomeSpecies.where((s) => s.rarity == rarity).length;
              final discoveredCount = _discoveredCreatures
                  .where((c) => c.habitat == biome && c.rarity == rarity)
                  .length;
              
              Color rarityColor;
              switch (rarity) {
                case CreatureRarity.common:
                  rarityColor = Colors.green;
                  break;
                case CreatureRarity.uncommon:
                  rarityColor = Colors.blue;
                  break;
                case CreatureRarity.rare:
                  rarityColor = Colors.purple;
                  break;
                case CreatureRarity.legendary:
                  rarityColor = Colors.orange;
                  break;
              }
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: rarityColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: rarityColor.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${rarity.displayName}: $discoveredCount/$rarityCount',
                  style: TextStyle(
                    color: rarityColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeciesGrid(BiomeType biome) {
    final biomeSpecies = ComprehensiveSpeciesDatabase.getSpeciesForBiome(biome);
    final discoveredIds = _discoveredCreatures.map((c) => c.id).toSet();
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
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
        rarityColor = Colors.green;
        break;
      case CreatureRarity.uncommon:
        rarityColor = Colors.blue;
        break;
      case CreatureRarity.rare:
        rarityColor = Colors.purple;
        break;
      case CreatureRarity.legendary:
        rarityColor = Colors.orange;
        break;
    }
    
    return Container(
      decoration: BoxDecoration(
        color: isDiscovered 
            ? const Color(0xFF1A237E).withValues(alpha: 0.8)
            : Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDiscovered 
              ? rarityColor.withValues(alpha: 0.7)
              : Colors.grey.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Species icon/emoji
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: isDiscovered 
                    ? rarityColor.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  isDiscovered ? _getCreatureEmoji(species.habitat) : '❓',
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Species name
            Text(
              isDiscovered ? species.name : '???',
              style: TextStyle(
                color: isDiscovered ? Colors.white : Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 4),
            
            // Scientific name
            if (isDiscovered)
              Text(
                species.species,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            
            const Spacer(),
            
            // Rarity indicator
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: isDiscovered ? rarityColor : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  isDiscovered ? species.rarity.displayName : 'Unknown',
                  style: TextStyle(
                    color: isDiscovered ? rarityColor : Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
        rarityColor = Colors.green;
        break;
      case CreatureRarity.uncommon:
        rarityColor = Colors.blue;
        break;
      case CreatureRarity.rare:
        rarityColor = Colors.purple;
        break;
      case CreatureRarity.legendary:
        rarityColor = Colors.orange;
        break;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A237E).withValues(alpha: 0.8),
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: rarityColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _getCreatureEmoji(creature.habitat),
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  creature.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  creature.species,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 4),
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
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.place,
                      color: Colors.cyan,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      creature.habitat.displayName,
                      style: const TextStyle(
                        color: Colors.cyan,
                        fontSize: 12,
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
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+${creature.pearlValue} XP',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 10,
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

  String _getResearcherTitle(double completionPercentage) {
    if (completionPercentage >= 100) return '🏆 Master Marine Biologist';
    if (completionPercentage >= 90) return '🎓 Senior Researcher';
    if (completionPercentage >= 75) return '📚 Marine Biology Expert';
    if (completionPercentage >= 50) return '🔬 Research Associate';
    if (completionPercentage >= 25) return '🌊 Marine Biology Student';
    return '🐠 Novice Ocean Explorer';
  }

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

  String _getCreatureEmoji(BiomeType habitat) {
    switch (habitat) {
      case BiomeType.shallowWaters:
        return '🐠';
      case BiomeType.coralGarden:
        return '🐟';
      case BiomeType.deepOcean:
        return '🦈';
      case BiomeType.abyssalZone:
        return '🐙';
    }
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
}