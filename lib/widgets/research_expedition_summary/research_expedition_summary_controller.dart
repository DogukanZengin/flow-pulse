import 'package:flutter/material.dart';
import '../../services/gamification_service.dart';
import '../../models/creature.dart';
import 'models/expedition_result.dart';
import 'models/celebration_config.dart';
import '../../animations/surfacing_animation_layer.dart';
import 'pages/unified_dashboard_page.dart';
import 'models/achievement_hierarchy.dart' as hierarchy;

/// Simplified research expedition summary controller that shows the unified dashboard
class ResearchExpeditionSummaryController extends StatefulWidget {
  final GamificationReward reward;
  final VoidCallback onContinue;
  final VoidCallback? onSurfaceForBreak;

  const ResearchExpeditionSummaryController({
    super.key,
    required this.reward,
    required this.onContinue,
    this.onSurfaceForBreak,
  });

  @override
  State<ResearchExpeditionSummaryController> createState() =>
      _ResearchExpeditionSummaryControllerState();
}

class _ResearchExpeditionSummaryControllerState
    extends State<ResearchExpeditionSummaryController>
    with TickerProviderStateMixin {

  // Core data
  late ExpeditionResult _expeditionResult;
  late CelebrationConfig _celebrationConfig;
  late hierarchy.AchievementClassification _achievementHierarchy;

  // Simple animation controllers for unified dashboard
  late AnimationController _masterController;
  late AnimationController _surfacingController;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _initializeAnimations();
    _startDashboardAnimation();
  }

  void _initializeData() {
    // Convert GamificationReward to enhanced ExpeditionResult (using existing method)
    _expeditionResult = _createExpeditionResult(widget.reward);

    // Create simple celebration config for dashboard (no complex phases needed)
    _celebrationConfig = CelebrationConfig.fromExpeditionResult(_expeditionResult);

    // Calculate achievement hierarchy for enhanced visual presentation
    _achievementHierarchy = hierarchy.AchievementHierarchy.calculatePriority(_expeditionResult);

    debugPrint('DEBUG: Achievement hierarchy - Primary: ${_achievementHierarchy.primary?.title}, Secondary: ${_achievementHierarchy.secondary.length}');
  }

  void _initializeAnimations() {
    // Simple animation setup for unified dashboard
    _masterController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _surfacingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  void _startDashboardAnimation() async {
    // Start surfacing animation first
    _surfacingController.forward();

    // Delay before starting main dashboard animation
    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) {
      _masterController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildDashboard(context);
  }

  Widget _buildDashboard(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Surfacing background animation
          RepaintBoundary(
            child: SurfacingAnimationLayer(
              controller: _surfacingController,
              expeditionResult: _expeditionResult,
              celebrationConfig: _celebrationConfig,
            ),
          ),

          // Unified dashboard content with responsive animations
          RepaintBoundary(
            child: UnifiedDashboardPage(
              expeditionResult: _expeditionResult,
              animationController: _masterController,
              achievementHierarchy: _achievementHierarchy,
            ),
          ),

          // Continue button overlay
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            right: 20,
            child: _buildContinueButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF40E0D0), // Turquoise
            Color(0xFF87CEEB), // Sky blue
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF40E0D0).withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onContinue,
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _masterController.dispose();
    _surfacingController.dispose();
    super.dispose();
  }

  /// Convert GamificationReward to enhanced ExpeditionResult with narratives
  /// (Using the existing working implementation from backup)
  ExpeditionResult _createExpeditionResult(GamificationReward reward) {
    // Generate research narrative based on session data
    final researchNarrative = _generateResearchNarrative(reward);
    final depthDescription = _generateDepthDescription(reward.sessionDepthReached);
    final careerProgression = MarineBiologyCareerLevel.fromLevel(reward.newLevel);

    // Convert achievements to enhanced format with narratives
    final enhancedAchievements = reward.unlockedAchievements.map((achievement) {
      return ResearchAchievement(
        id: achievement.id,
        title: achievement.title,
        description: achievement.description,
        researchNarrative: _generateAchievementNarrative(achievement),
        icon: achievement.icon,
        color: achievement.color,
        category: _categorizeAchievement(achievement.id),
      );
    }).toList();

    // Convert equipment unlocks
    final enhancedEquipment = reward.unlockedEquipment.map((equipmentId) {
      return EquipmentUnlock(
        id: equipmentId,
        name: _formatEquipmentName(equipmentId),
        description: _generateEquipmentDescription(equipmentId),
        researchStationUpgrade: _generateStationUpgrade(equipmentId),
        icon: _getEquipmentIcon(equipmentId),
        category: _categorizeEquipment(equipmentId),
      );
    }).toList();

    // Generate species discovery narratives
    final discoveryNarratives = reward.allDiscoveredCreatures.map((creature) {
      return SpeciesDiscoveryNarrative(
        creature: creature,
        discoveryStory: _generateDiscoveryStory(creature),
        scientificImportance: _generateScientificImportance(creature),
        conservationImpact: _generateConservationImpact(creature),
        discoveredAt: DateTime.now(),
      );
    }).toList();

    return ExpeditionResult(
      dataPointsCollected: reward.rpGained,
      researchNarrative: researchNarrative,
      depthDescription: depthDescription,
      careerProgression: careerProgression,
      rpGained: reward.rpGained,
      baseRP: reward.baseRP,
      bonusRP: reward.breakAdherenceBonus + reward.streakBonusRP + reward.qualityBonus,
      leveledUp: reward.leveledUp,
      oldLevel: reward.oldLevel,
      newLevel: reward.newLevel,
      currentStreak: reward.currentStreak,
      oldCareerTitle: reward.oldCareerTitle,
      newCareerTitle: reward.newCareerTitle,
      careerTitleChanged: reward.careerTitleChanged,
      careerAdvancementNarrative: reward.careerTitleChanged
          ? _generateCareerAdvancementNarrative(reward)
          : null,
      unlockedThemes: reward.unlockedThemes,
      unlockedAchievements: enhancedAchievements,
      unlockedEquipment: enhancedEquipment,
      discoveredCreature: reward.discoveredCreature,
      allDiscoveredCreatures: reward.allDiscoveredCreatures,
      discoveryNarratives: discoveryNarratives,
      researchPapersUnlocked: reward.researchPapersUnlocked,
      researchPaperIds: reward.researchPaperIds,
      sessionDurationMinutes: reward.sessionDurationMinutes,
      sessionDepthReached: reward.sessionDepthReached,
      sessionCompleted: reward.sessionCompleted,
      isStudySession: reward.isStudySession,
      researchEfficiency: reward.researchEfficiency,
      qualityAssessment: SessionQualityAssessment.fromEfficiency(reward.researchEfficiency),
      streakBonusRP: reward.streakBonusRP,
      breakAdherenceBonus: reward.breakAdherenceBonus,
      qualityBonus: reward.qualityBonus,
      cumulativeRP: reward.cumulativeRP,
      currentDepthZone: reward.currentDepthZone,
      streakBonusNarrative: _generateStreakBonusNarrative(reward),
      nextEquipmentHint: reward.nextEquipmentHint,
      nextAchievementHint: reward.nextAchievementHint,
      nextCareerMilestone: reward.nextCareerMilestone,
      celebrationLevel: _calculateCelebrationIntensity(reward),
      sessionBiome: _determineBiome(reward.sessionDepthReached),
      celebrationEffects: [],
    );
  }

  // Helper methods for narrative generation (keeping existing implementations)
  String _generateResearchNarrative(GamificationReward reward) {
    final depth = reward.sessionDepthReached;
    final duration = reward.sessionDurationMinutes;
    final dataPoints = reward.rpGained;
    final streakBonus = reward.streakBonusRP;

    String baseNarrative;
    String conservationImpact;

    if (depth > 50) {
      baseNarrative = 'Your dive team collected $dataPoints new data samples from the ${depth.toStringAsFixed(1)}m abyssal research zone';
      conservationImpact = 'These deep-sea observations contribute to protecting mysterious ocean depths that are home to unique species found nowhere else on Earth.';
    } else if (depth > 20) {
      baseNarrative = 'Marine researchers documented $dataPoints valuable observations from the ${depth.toStringAsFixed(1)}m open ocean ecosystem';
      conservationImpact = 'Your research helps protect migratory routes of whales, dolphins, and sea turtles that depend on healthy open ocean environments.';
    } else if (depth > 5) {
      baseNarrative = 'Your coral reef research team recorded $dataPoints significant findings at ${depth.toStringAsFixed(1)}m depth';
      conservationImpact = 'This research directly supports coral conservation efforts - healthy reefs provide homes for 25% of all marine species.';
    } else {
      baseNarrative = 'Your coastal survey team gathered $dataPoints research data points from the ${depth.toStringAsFixed(1)}m shallow waters';
      conservationImpact = 'Coastal research is vital for protecting nursery habitats where young marine animals begin their lives.';
    }

    String streakNarrative = '';
    if (streakBonus > 0) {
      streakNarrative = '\n\nConsistent research methodology bonus: +$streakBonus validated observations from your dedication to daily marine research.';
    }

    return '$baseNarrative during your $duration-minute expedition.\n\n$conservationImpact$streakNarrative';
  }

  String _generateDepthDescription(double depth) {
    if (depth > 100) return 'Abyssal Research Zone';
    if (depth > 50) return 'Deep Ocean Research Area';
    if (depth > 20) return 'Mid-Water Column Study';
    if (depth > 5) return 'Coral Reef Ecosystem';
    return 'Shallow Coastal Waters';
  }

  String _generateAchievementNarrative(Achievement achievement) {
    if (achievement.id.contains('streak')) {
      return 'Scientific Recognition: Consistent Research Methodology Award. Your daily dedication has contributed to a 127% increase in coral formation health monitoring.';
    } else if (achievement.id.contains('discovery')) {
      return 'Research Milestone: Species Documentation Excellence. Your discoveries help scientists understand biodiversity patterns critical for ocean protection.';
    } else if (achievement.id.contains('depth')) {
      return 'Exploration Achievement: Deep-Sea Research Pioneer. Your deep water research explores habitats that may hold keys to climate resilience.';
    } else if (achievement.id.contains('session') || achievement.id.contains('focus')) {
      return 'Productivity Recognition: Research Session Dedication. Consistent research sessions like yours have led to breakthroughs in marine protection strategies.';
    } else {
      return '${achievement.description} Your research methodology contributes to protecting marine ecosystems that support millions of species worldwide.';
    }
  }

  AchievementCategory _categorizeAchievement(String id) {
    if (id.contains('streak') || id.contains('consistency')) return AchievementCategory.consistency;
    if (id.contains('discovery') || id.contains('species')) return AchievementCategory.discovery;
    if (id.contains('exploration') || id.contains('depth')) return AchievementCategory.exploration;
    if (id.contains('conservation') || id.contains('protection')) return AchievementCategory.conservation;
    return AchievementCategory.research;
  }

  String _formatEquipmentName(String equipmentId) {
    return equipmentId
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _generateEquipmentDescription(String equipmentId) {
    return 'Advanced marine research equipment for enhanced data collection and species observation.';
  }

  String _generateStationUpgrade(String equipmentId) {
    final equipmentName = _formatEquipmentName(equipmentId);

    if (equipmentId.contains('camera') || equipmentId.contains('photo')) {
      return 'Research Station Upgraded: Deep-Sea Photography Lab now available. Document rare species with professional-grade underwater imaging equipment.';
    } else if (equipmentId.contains('sonar') || equipmentId.contains('radar')) {
      return 'Research Station Upgraded: Sonar Mapping Laboratory established. Map ocean floor topography and track marine animal migration patterns.';
    } else if (equipmentId.contains('sampler') || equipmentId.contains('collection')) {
      return 'Research Station Upgraded: Specimen Analysis Lab operational. Collect and analyze water samples, plankton, and genetic material safely.';
    } else {
      return 'Research Station Upgraded: $equipmentName Laboratory now available. Your expanded capabilities enable more comprehensive marine research.';
    }
  }

  IconData _getEquipmentIcon(String equipmentId) {
    if (equipmentId.contains('camera')) return Icons.photo_camera;
    if (equipmentId.contains('sonar')) return Icons.radar;
    if (equipmentId.contains('sampler')) return Icons.science;
    return Icons.build_circle;
  }

  EquipmentCategory _categorizeEquipment(String equipmentId) {
    if (equipmentId.contains('mask') || equipmentId.contains('scuba')) return EquipmentCategory.diving;
    if (equipmentId.contains('camera') || equipmentId.contains('photo')) return EquipmentCategory.photography;
    if (equipmentId.contains('sampler') || equipmentId.contains('collection')) return EquipmentCategory.sampling;
    if (equipmentId.contains('sonar') || equipmentId.contains('radar')) return EquipmentCategory.navigation;
    return EquipmentCategory.laboratory;
  }

  String _generateCareerAdvancementNarrative(GamificationReward reward) {
    return 'Career advancement from ${reward.oldCareerTitle} to ${reward.newCareerTitle}. Your research expertise contributes to marine conservation efforts worldwide.';
  }

  String _generateStreakBonusNarrative(GamificationReward reward) {
    if (reward.streakBonusRP > 0) {
      return 'Your ${reward.currentStreak}-day research consistency has earned +${reward.streakBonusRP} bonus research points.';
    }
    return '';
  }

  BiomeType _determineBiome(double depth) {
    if (depth >= 100) return BiomeType.abyssalZone;
    if (depth >= 30) return BiomeType.deepOcean;
    if (depth >= 10) return BiomeType.coralGarden;
    return BiomeType.shallowWaters;
  }

  CelebrationIntensity _calculateCelebrationIntensity(GamificationReward reward) {
    if (reward.leveledUp || reward.discoveredCreature != null || reward.streakBonusRP > 5) {
      return CelebrationIntensity.high;
    } else if (reward.rpGained > 10) {
      return CelebrationIntensity.moderate;
    } else {
      return CelebrationIntensity.minimal;
    }
  }

  String _generateDiscoveryStory(dynamic creature) {
    return 'During deep-sea exploration, researchers documented this remarkable species in its natural habitat.';
  }

  String _generateScientificImportance(dynamic creature) {
    return 'This species contributes valuable data to our understanding of marine biodiversity and ecosystem health.';
  }

  String _generateConservationImpact(dynamic creature) {
    return 'Documentation of this species supports conservation efforts to protect critical marine habitats.';
  }
}