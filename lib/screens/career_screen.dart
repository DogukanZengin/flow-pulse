import 'package:flutter/material.dart';
import '../widgets/achievement_display_widget.dart';
import '../widgets/enhanced_equipment_display_widget.dart';
import '../widgets/research_paper_display_widget.dart';
import '../widgets/missions_display_widget.dart';
import '../services/marine_biology_achievement_service.dart';
import '../services/equipment_progression_service.dart';
import '../services/research_paper_service.dart';
import '../services/gamification_service.dart';
import '../services/persistence/persistence_service.dart';
import '../services/marine_biology_career_service.dart';
import '../utils/responsive_helper.dart';
import '../theme/ocean_theme_colors.dart';

/// Career Screen - Phase 4 Progression Hub
/// Houses achievements, equipment, and research papers
class CareerScreen extends StatefulWidget {
  const CareerScreen({super.key});

  @override
  State<CareerScreen> createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Clean state - no mock data
  List<MarineBiologyAchievement> _achievements = [];
  List<ResearchEquipment> _equipment = [];
  List<ResearchPaper> _availablePapers = [];
  List<ResearchPaper> _publishedPapers = [];
  EquipmentBonuses? _equipmentBonuses;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCareerData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCareerData() async {
    List<MarineBiologyAchievement> achievements = [];

    try {
      // Load discovered creatures from persistence
      final discoveredCreatures = await PersistenceService.instance.ocean.getDiscoveredCreatures();

      // Get gamification data
      final cumulativeRP = GamificationService.instance.cumulativeRP;
      final currentStreak = GamificationService.instance.currentStreak;
      final totalSessions = GamificationService.instance.totalSessions;

      // Calculate research metrics
      final metrics = MarineBiologyCareerService.calculateResearchMetrics(
        discoveredCreatures,
        totalSessions,
        (GamificationService.instance.totalFocusTime / 60.0).round(), // Convert to minutes (int)
      );

      // Load achievements (isolated from equipment/paper loading errors)
      achievements = MarineBiologyAchievementService.getAllAchievements(
        discoveredCreatures,
        cumulativeRP,
        metrics,
        currentStreak,
        totalSessions,
      );

      // Debug logging
      debugPrint('🎯 Career Screen: Loaded ${achievements.length} achievements (${achievements.where((a) => a.isUnlocked).length} unlocked)');

      // Try to load equipment and papers (these might fail but shouldn't affect achievements)
      try {
        // Load equipment data
        final equipmentService = EquipmentProgressionService(PersistenceService.instance.equipment);

        // Safety check: ensure equipment data is initialized
        try {
          await PersistenceService.instance.equipment.initializeDefaultEquipment();
        } catch (e) {
          debugPrint('⚠️ Warning: Could not ensure equipment initialization: $e');
        }

        // Safety check: unlock any equipment that should be unlocked at current level
        try {
          final unlockedEquipment = await PersistenceService.instance.equipment.checkAndUnlockEquipmentByRP(cumulativeRP);
          if (unlockedEquipment.isNotEmpty) {
            debugPrint('🎒 Career screen: Unlocked ${unlockedEquipment.length} equipment items for $cumulativeRP RP');
          }
        } catch (e) {
          debugPrint('❌ Error checking equipment unlocks: $e');
        }

        final equipment = await equipmentService.getAllEquipment(cumulativeRP, discoveredCreatures, []);
        final equipmentBonuses = await equipmentService.calculateEquipmentBonuses([], cumulativeRP, discoveredCreatures);

        // Load research papers
        final availablePapers = ResearchPaperService.getAvailablePapers(discoveredCreatures, cumulativeRP, []);
        final publishedPapers = <ResearchPaper>[]; // Initialize as empty list for now

        if (mounted) {
          setState(() {
            _achievements = achievements;
            _equipment = equipment;
            _equipmentBonuses = equipmentBonuses;
            _availablePapers = availablePapers;
            _publishedPapers = publishedPapers;
          });
        }
      } catch (e) {
        debugPrint('Error loading equipment/papers: $e');
        // Set achievements and fallback equipment state
        if (mounted) {
          setState(() {
            _achievements = achievements; // Preserve achievements
            _equipmentBonuses = const EquipmentBonuses(
              discoveryRateBonus: 0.0,
              sessionXPBonus: 0.0,
              equippedCount: 0,
              availableCount: 0,
              totalCount: 0,
              categoryBonuses: {},
            );
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading core career data: $e');
      // Even if everything fails, try to set achievements if we got them
      if (mounted) {
        setState(() {
          if (achievements.isNotEmpty) {
            _achievements = achievements;
          }
          _equipmentBonuses = const EquipmentBonuses(
            discoveryRateBonus: 0.0,
            sessionXPBonus: 0.0,
            equippedCount: 0,
            availableCount: 0,
            totalCount: 0,
            categoryBonuses: {},
          );
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              OceanThemeColors.deepOceanBlue, // Deep Ocean
              OceanThemeColors.deepOceanAccent, // Ocean Blue
              OceanThemeColors.shallowWatersAccent, // Light Ocean
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Responsive Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(context, 'screen'),
                  vertical: ResponsiveHelper.getResponsiveSpacing(context, 'screen') * 0.75,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [OceanThemeColors.deepOceanBlue, OceanThemeColors.deepOceanAccent],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.military_tech,
                        color: Colors.white,
                        size: ResponsiveHelper.getIconSize(context, 'small'),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Marine Research Career',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title'),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: OceanThemeColors.getReadableTextShadows(),
                            ),
                          ),
                          Text(
                            'Level ${GamificationService.instance.currentLevel} Marine Biologist',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle'),
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              shadows: OceanThemeColors.getReadableTextShadows(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Compact Progress Indicator
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: OceanThemeColors.deepOceanAccent,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '${GamificationService.instance.currentLevel}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Responsive Tab Bar
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(context, 'screen'),
                ),
                height: ResponsiveHelper.responsiveValue(
                  context: context,
                  mobile: 48.0,
                  tablet: 56.0,
                  desktop: 64.0,
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: OceanThemeColors.seafoamGreen,
                  indicatorWeight: 3,
                  indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption') * 0.9,
                    fontWeight: FontWeight.w400,
                  ),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                  tabAlignment: TabAlignment.fill,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.emoji_events, 
                        size: ResponsiveHelper.getIconSize(context, 'small')),
                      text: ResponsiveHelper.responsiveValue(
                        context: context,
                        mobile: 'Awards',
                        tablet: 'Achievements',
                        desktop: 'Achievements',
                      ),
                      height: ResponsiveHelper.responsiveValue(
                        context: context,
                        mobile: 48.0,
                        tablet: 56.0,
                        desktop: 64.0,
                      ),
                    ),
                    Tab(
                      icon: Icon(Icons.construction, 
                        size: ResponsiveHelper.getIconSize(context, 'small')),
                      text: 'Equipment',
                      height: ResponsiveHelper.responsiveValue(
                        context: context,
                        mobile: 48.0,
                        tablet: 56.0,
                        desktop: 64.0,
                      ),
                    ),
                    Tab(
                      icon: Icon(Icons.article, 
                        size: ResponsiveHelper.getIconSize(context, 'small')),
                      text: 'Research',
                      height: ResponsiveHelper.responsiveValue(
                        context: context,
                        mobile: 48.0,
                        tablet: 56.0,
                        desktop: 64.0,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Tab Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom,
                    left: MediaQuery.of(context).size.width * 0.02,
                    right: MediaQuery.of(context).size.width * 0.02,
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Achievements Tab
                      _buildAchievementsTab(),
                      
                      // Equipment Tab
                      _buildEquipmentTab(),
                      
                      // Research Papers Tab
                      _buildPapersTab(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.04,
        right: MediaQuery.of(context).size.width * 0.04,
        top: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Missions Section
          MissionsDisplayWidget(
            compactView: true,
            maxVisible: 3,
          ),
          const SizedBox(height: 24),

          // Quick Stats Card
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  OceanThemeColors.deepOceanBlue.withValues(alpha: 0.3),
                  OceanThemeColors.deepOceanAccent.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: OceanThemeColors.deepOceanAccent.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Unlocked',
                    '${_achievements.where((a) => a.isUnlocked).length}',
                    OceanThemeColors.seafoamGreen,
                    Icons.emoji_events,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Progress',
                    '${_achievements.where((a) => !a.isUnlocked && a.progress > 0).length}',
                    Colors.white.withValues(alpha: 0.8),
                    Icons.trending_up,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    '${_achievements.length}',
                    Colors.white.withValues(alpha: 0.8),
                    Icons.flag,
                  ),
                ),
              ],
            ),
          ),
          AchievementDisplayWidget(
            achievements: _achievements,
            showOnlyUnlocked: false, // Show locked awards as mystery cards for discovery feel
            compactView: false, // Always use full mobile-friendly view
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
            shadows: OceanThemeColors.getReadableTextShadows(),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.8),
            shadows: OceanThemeColors.getReadableTextShadows(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildEquipmentTab() {
    if (_equipmentBonuses == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.cyan,
              strokeWidth: 3,
            ),
            const SizedBox(height: 12),
            Text(
              'Loading Research Equipment...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.04,
        right: MediaQuery.of(context).size.width * 0.04,
        top: 8, // Adjusted bottom padding for tab bar
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Equipment Overview Card
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  OceanThemeColors.deepOceanBlue.withValues(alpha: 0.3),
                  OceanThemeColors.deepOceanAccent.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: OceanThemeColors.deepOceanAccent.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.construction, color: OceanThemeColors.deepOceanAccent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Equipment Status',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildEquipmentStat(
                        'Available',
                        '${_equipment.where((e) => e.isUnlocked).length}',
                        OceanThemeColors.seafoamGreen,
                      ),
                    ),
                    Expanded(
                      child: _buildEquipmentStat(
                        'Discovery Bonus',
                        '+${(_equipmentBonuses!.discoveryRateBonus * 100).toInt()}%',
                        Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          EnhancedEquipmentDisplayWidget(
            equipment: _equipment,
            bonuses: _equipmentBonuses!,
            onEquipmentTap: (equipment) {
              _showMobileEquipmentDetails(equipment);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildEquipmentStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
            shadows: OceanThemeColors.getReadableTextShadows(),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.8),
            shadows: OceanThemeColors.getReadableTextShadows(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPapersTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.04,
        right: MediaQuery.of(context).size.width * 0.04,
        top: 8, // Adjusted bottom padding for tab bar
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Research Overview Card
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  OceanThemeColors.deepOceanBlue.withValues(alpha: 0.3),
                  OceanThemeColors.deepOceanAccent.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: OceanThemeColors.deepOceanAccent.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.article, color: OceanThemeColors.deepOceanAccent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Research Publications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildResearchStat(
                        'Available',
                        '${_availablePapers.length}',
                        Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Expanded(
                      child: _buildResearchStat(
                        'Published',
                        '${_publishedPapers.length}',
                        OceanThemeColors.seafoamGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ResearchPaperDisplayWidget(
            papers: _availablePapers,
            publishedPapers: _publishedPapers.map((p) => p.id).toList(),
            showOnlyAvailable: true,
            onPublishPaper: (paper) async {
              // Award RP for publishing research paper
              try {
                await GamificationService.instance.awardResearchPoints(
                  paper.rpReward,
                  source: 'Research Paper: ${paper.title}',
                );
              } catch (e) {
                debugPrint('Error awarding RP for research paper: $e');
              }

              // Handle paper publication
              setState(() {
                _availablePapers.remove(paper);
                _publishedPapers.add(paper);
              });

              // Show mobile-friendly success feedback
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Published: ${paper.title}\n+${paper.rpReward} RP earned!',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildResearchStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
            shadows: OceanThemeColors.getReadableTextShadows(),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.8),
            shadows: OceanThemeColors.getReadableTextShadows(),
          ),
        ),
      ],
    );
  }
  
  void _showMobileEquipmentDetails(ResearchEquipment equipment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              OceanThemeColors.deepOceanAccent,
              OceanThemeColors.deepOceanBlue,
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: equipment.rarityColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            equipment.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                equipment.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${equipment.effectiveUnlockRP} RP Equipment',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: equipment.rarityColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      equipment.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (equipment.benefits.isNotEmpty) ...[
                      const Text(
                        'Equipment Benefits:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...equipment.benefits.map((benefit) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_right,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              benefit,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                    const Spacer(),
                    if (equipment.isUnlocked) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (equipment.isEquipped) {
                              await _unequipItem(equipment);
                            } else {
                              await _equipItem(equipment);
                            }
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: equipment.isEquipped ? Colors.orange : Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                equipment.isEquipped ? Icons.remove_circle : Icons.add_circle,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(equipment.isEquipped ? 'Unequip' : 'Equip'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _equipItem(ResearchEquipment equipment) async {
    try {
      final equipmentRepository = PersistenceService.instance.equipment;
      await equipmentRepository.equipItem(equipment.id);
      await _loadCareerData(); // Refresh all career data
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to equip ${equipment.name}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unequipItem(ResearchEquipment equipment) async {
    try {
      final equipmentRepository = PersistenceService.instance.equipment;
      await equipmentRepository.unequipItem(equipment.id);
      await _loadCareerData(); // Refresh all career data
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unequip ${equipment.name}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}