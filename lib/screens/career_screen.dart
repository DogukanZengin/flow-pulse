import 'package:flutter/material.dart';
import '../widgets/achievement_display_widget.dart';
import '../widgets/enhanced_equipment_display_widget.dart';
import '../widgets/research_paper_display_widget.dart';
import '../services/marine_biology_achievement_service.dart';
import '../services/equipment_progression_service.dart';
import '../services/research_paper_service.dart';
import '../services/gamification_service.dart';
import '../services/marine_biology_career_service.dart';
import '../models/creature.dart';

/// Career Screen - Phase 4 Progression Hub
/// Houses achievements, equipment, and research papers
class CareerScreen extends StatefulWidget {
  const CareerScreen({super.key});

  @override
  State<CareerScreen> createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock data for demonstration - in production, this would come from providers/services
  final List<MarineBiologyAchievement> _achievements = [];
  final List<ResearchEquipment> _equipment = [];
  final List<ResearchPaper> _availablePapers = [];
  final List<ResearchPaper> _publishedPapers = [];
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
    // In production, these would fetch from actual services/databases
    final userLevel = GamificationService.instance.currentLevel;
    final discoveredCreatures = <Creature>[]; // Would come from CreatureService
    final unlockedEquipment = <String>[]; // Would come from user preferences
    
    // Create mock ResearchMetrics for achievements
    final metrics = ResearchMetrics(
      totalDiscoveries: discoveredCreatures.length,
      discoveriesPerSession: 0.5,
      discoveriesPerHour: 1.0,
      recentDiscoveries: 5,
      diversityIndex: 0.75,
      researchEfficiency: 0.85,
      averageSessionTime: 25.0,
    );
    
    setState(() {
      // Load achievements
      _achievements.addAll(MarineBiologyAchievementService.getAllAchievements(
        discoveredCreatures,
        userLevel,
        1000, // Mock total XP
        metrics,
        GamificationService.instance.currentStreak,
        50, // Mock total sessions
      ));
      
      // Load equipment
      _equipment.addAll(EquipmentProgressionService.getAllEquipment(
        userLevel,
        discoveredCreatures,
        unlockedEquipment,
      ));
      
      // Calculate equipment bonuses
      _equipmentBonuses = EquipmentProgressionService.calculateEquipmentBonuses(
        unlockedEquipment,
        userLevel,
        discoveredCreatures,
      );
      
      // Load research papers  
      _availablePapers.addAll(ResearchPaperService.getAvailablePapers(
        discoveredCreatures,
        userLevel,
        _publishedPapers.map((p) => p.id).toList(),
      ));
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A1628), // Deep Ocean
              Color(0xFF1E3A5F), // Ocean Blue
              Color(0xFF2E5A7A), // Light Ocean
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.military_tech,
                          color: Colors.amber,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Research Career',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Track your marine biology journey',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Career Level Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.cyan, Colors.blue],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Level ${GamificationService.instance.currentLevel}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.cyan,
                  indicatorWeight: 3,
                  labelColor: Colors.cyan,
                  unselectedLabelColor: Colors.white60,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.cyan.withValues(alpha: 0.2),
                  ),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.emoji_events, size: 20),
                      text: 'Achievements',
                    ),
                    Tab(
                      icon: Icon(Icons.construction, size: 20),
                      text: 'Equipment',
                    ),
                    Tab(
                      icon: Icon(Icons.article, size: 20),
                      text: 'Papers',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tab Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
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
      padding: const EdgeInsets.all(16),
      child: AchievementDisplayWidget(
        achievements: _achievements,
        showOnlyUnlocked: false,
        compactView: false,
      ),
    );
  }
  
  Widget _buildEquipmentTab() {
    if (_equipmentBonuses == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.cyan),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: EnhancedEquipmentDisplayWidget(
        equipment: _equipment,
        bonuses: _equipmentBonuses!,
        onEquipmentTap: (equipment) {
          // Show equipment details dialog
          showDialog(
            context: context,
            builder: (context) => EquipmentDetailsDialog(equipment: equipment),
          );
        },
      ),
    );
  }
  
  Widget _buildPapersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ResearchPaperDisplayWidget(
        papers: _availablePapers,
        publishedPapers: _publishedPapers.map((p) => p.id).toList(),
        showOnlyAvailable: true,
        onPublishPaper: (paper) async {
          // Handle paper publication
          setState(() {
            _availablePapers.remove(paper);
            _publishedPapers.add(paper);
          });
          
          // Show success feedback
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Published: ${paper.title}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }
  
  void _showAchievementDetails(MarineBiologyAchievement achievement) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E3A5F),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                achievement.rarityColor.withValues(alpha: 0.3),
                achievement.rarityColor.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: achievement.rarityColor.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                achievement.icon.toString(),
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),
              Text(
                achievement.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                achievement.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (achievement.isUnlocked) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Achievement Unlocked!',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ),
              ] else ...[
                LinearProgressIndicator(
                  value: achievement.progress,
                  backgroundColor: Colors.grey.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(achievement.rarityColor),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(achievement.progress * 100).toInt()}% Complete',
                  style: TextStyle(
                    color: achievement.rarityColor,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showPaperDetails(ResearchPaper paper) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E3A5F),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2E5A7A),
                Color(0xFF1E3A5F),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.cyan.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.article, color: Colors.cyan, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      paper.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                paper.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Requirements:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Level ${paper.requiredLevel} • ${paper.requiredDiscoveries} discoveries required',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              if (paper.requiredSpecies.isNotEmpty)
                Text(
                  'Required species: ${paper.requiredSpecies.join(", ")}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              /*...paper.requirementDescriptions.map((req) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        req,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              )),*/
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Research Value: ${paper.researchValue}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Citations: ${paper.citations}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}