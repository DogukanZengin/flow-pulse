import 'package:flutter/material.dart';
import '../../services/gamification_service.dart';
import '../../models/creature.dart';
import 'models/expedition_result.dart';
import 'models/celebration_config.dart';
import 'animations/surfacing_animation_layer.dart';
import 'animations/underwater_particle_system.dart';
import 'pages/session_results_page.dart';
import 'pages/career_advancement_page.dart';
import 'pages/species_discovery_page.dart';
import 'pages/equipment_unlock_page.dart';
import 'components/underwater_background.dart';

/// Main orchestration widget that coordinates the entire research expedition summary experience
/// This replaces the monolithic ResearchExpeditionSummaryWidget with a modular architecture
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
  
  // Core data and configuration
  late ExpeditionResult _expeditionResult;
  late CelebrationConfig _celebrationConfig;
  
  // Animation controllers
  late AnimationController _masterController;
  late AnimationController _surfacingController;
  late AnimationController _particleController;
  
  // Animation phases
  late List<AnimationController> _phaseControllers;
  
  // Current state
  CelebrationPhase? _currentPhase;
  int _currentPhaseIndex = 0;
  bool _animationStarted = false;
  bool _canSkip = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _initializeAnimations();
    _startCelebrationSequence();
  }

  void _initializeData() {
    // Convert GamificationReward to enhanced ExpeditionResult
    _expeditionResult = _createExpeditionResult(widget.reward);
    _celebrationConfig = CelebrationConfig.fromExpeditionResult(_expeditionResult);
  }

  void _initializeAnimations() {
    // Master animation controller for overall sequencing
    _masterController = AnimationController(
      duration: _celebrationConfig.totalDuration,
      vsync: this,
    );

    // Specialized controllers for different layers
    _surfacingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: _celebrationConfig.totalDuration,
      vsync: this,
    );

    // Create phase-specific controllers
    _phaseControllers = _celebrationConfig.phases.map((phase) {
      return AnimationController(
        duration: phase.duration,
        vsync: this,
      );
    }).toList();

    // Listen for phase transitions
    _masterController.addListener(_onMasterAnimationTick);
  }

  void _startCelebrationSequence() async {
    if (_animationStarted) return;
    _animationStarted = true;

    // Start with surfacing animation
    _surfacingController.forward();
    
    // Wait for surfacing to complete partially before starting main sequence
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Start main celebration sequence
    _masterController.forward();
    _particleController.forward();
    
    // Start first phase
    if (_celebrationConfig.phases.isNotEmpty) {
      _startPhase(0);
    }
  }

  void _onMasterAnimationTick() {
    final elapsed = Duration(
      milliseconds: (_masterController.value * _celebrationConfig.totalDuration.inMilliseconds).round()
    );
    
    // Check for phase transitions
    for (int i = _currentPhaseIndex; i < _celebrationConfig.phases.length; i++) {
      final phase = _celebrationConfig.phases[i];
      
      if (elapsed >= phase.startTime && 
          elapsed <= phase.endTime && 
          _currentPhase != phase) {
        _startPhase(i);
        break;
      }
    }
  }

  void _startPhase(int phaseIndex) {
    if (phaseIndex >= _celebrationConfig.phases.length) return;
    
    setState(() {
      _currentPhaseIndex = phaseIndex;
      _currentPhase = _celebrationConfig.phases[phaseIndex];
    });
    
    // Start the phase controller
    _phaseControllers[phaseIndex].forward();
  }

  void _skipToEnd() {
    if (!_canSkip) return;
    
    // Fast forward all controllers
    _masterController.animateTo(1.0, duration: const Duration(milliseconds: 300));
    _surfacingController.animateTo(1.0, duration: const Duration(milliseconds: 300));
    _particleController.animateTo(1.0, duration: const Duration(milliseconds: 300));
    
    for (final controller in _phaseControllers) {
      controller.animateTo(1.0, duration: const Duration(milliseconds: 300));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _skipToEnd,
        child: Stack(
          children: [
            // Layer 1: Underwater background with depth transition
            UnderwaterBackground(
              biomeConfig: BiomeVisualConfig.forBiome(_celebrationConfig.primaryBiome),
              depthProgress: _surfacingController,
              celebrationIntensity: _celebrationConfig.intensity,
            ),
            
            // Layer 2: Surfacing animation overlay
            SurfacingAnimationLayer(
              controller: _surfacingController,
              expeditionResult: _expeditionResult,
              celebrationConfig: _celebrationConfig,
            ),
            
            // Layer 3: Particle systems and environmental effects  
            UnderwaterParticleSystem(
              controller: _particleController,
              celebrationConfig: _celebrationConfig,
              currentPhase: _currentPhase,
            ),
            
            // Layer 4: Main content based on current phase
            _buildMainContent(),
            
            // Layer 5: Skip indicator
            if (_canSkip)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.cyan.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, color: Colors.cyan, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Tap to skip',
                        style: TextStyle(
                          color: Colors.cyan,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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

  Widget _buildMainContent() {
    // Show content based on current phase
    if (_currentPhase == null) {
      return const SizedBox.shrink();
    }

    switch (_currentPhase!.name) {
      case 'Surfacing':
        return const SizedBox.shrink(); // Surfacing is handled by overlay
        
      case 'Data Collection':
        return SessionResultsPage(
          expeditionResult: _expeditionResult,
          animationController: _phaseControllers[_currentPhaseIndex],
        );
        
      case 'Career Advancement':
        return CareerAdvancementPage(
          expeditionResult: _expeditionResult,
          animationController: _phaseControllers[_currentPhaseIndex],
        );
        
      case 'Species Discovery':
        return SpeciesDiscoveryPage(
          expeditionResult: _expeditionResult,
          animationController: _phaseControllers[_currentPhaseIndex],
        );
        
      case 'Grand Finale':
        return EquipmentUnlockPage(
          expeditionResult: _expeditionResult,
          animationController: _phaseControllers[_currentPhaseIndex],
          onComplete: widget.onContinue,
          onSurfaceForBreak: widget.onSurfaceForBreak,
        );
        
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    _surfacingController.dispose();
    _particleController.dispose();
    
    for (final controller in _phaseControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }

  /// Convert GamificationReward to enhanced ExpeditionResult with narratives
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
      dataPointsCollected: reward.xpGained,
      researchNarrative: researchNarrative,
      depthDescription: depthDescription,
      careerProgression: careerProgression,
      xpGained: reward.xpGained,
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
      streakBonusXP: reward.streakBonusXP,
      streakMultiplier: reward.streakMultiplier,
      depthBonusXP: reward.depthBonusXP,
      completionBonusXP: reward.completionBonusXP,
      streakBonusNarrative: _generateStreakBonusNarrative(reward),
      nextEquipmentHint: reward.nextEquipmentHint,
      nextAchievementHint: reward.nextAchievementHint,
      nextCareerMilestone: reward.nextCareerMilestone,
      celebrationLevel: CelebrationIntensity.moderate, // Will be calculated
      sessionBiome: reward.sessionDepthReached <= 10 
          ? BiomeType.shallowWaters 
          : BiomeType.deepOcean,
      celebrationEffects: [], // Will be populated by CelebrationConfig
    );
  }

  // Helper methods for narrative generation
  String _generateResearchNarrative(GamificationReward reward) {
    final depth = reward.sessionDepthReached;
    final duration = reward.sessionDurationMinutes;
    final dataPoints = reward.xpGained;
    
    if (depth > 50) {
      return '🌊 Your deep-sea research expedition collected $dataPoints valuable data samples from the ${depth.toStringAsFixed(1)}m abyssal zone during your ${duration}-minute dive.';
    } else if (depth > 20) {
      return '🐋 Your marine research team gathered $dataPoints important observations from the ${depth.toStringAsFixed(1)}m open ocean ecosystem over ${duration} minutes.';
    } else if (depth > 5) {
      return '🐠 Your coral reef study documented $dataPoints significant findings at ${depth.toStringAsFixed(1)}m depth during your ${duration}-minute research session.';
    } else {
      return '🏊 Your shallow water survey collected $dataPoints research data points from the ${depth.toStringAsFixed(1)}m coastal zone over ${duration} minutes.';
    }
  }

  String _generateDepthDescription(double depth) {
    if (depth > 100) return 'Abyssal Research Zone';
    if (depth > 50) return 'Deep Ocean Research Area';
    if (depth > 20) return 'Mid-Water Column Study';
    if (depth > 5) return 'Coral Reef Ecosystem';
    return 'Shallow Coastal Waters';
  }

  String _generateAchievementNarrative(Achievement achievement) {
    // Add research context to achievements
    return '🎓 ${achievement.description} Your consistent research methodology contributes to marine conservation efforts.';
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
    // Generate equipment descriptions based on ID
    return 'Advanced marine research equipment for enhanced data collection and species observation.';
  }

  String _generateStationUpgrade(String equipmentId) {
    return '🔬 Research Station Enhanced: New ${_formatEquipmentName(equipmentId)} laboratory now available for advanced marine studies.';
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
    if (equipmentId.contains('computer') || equipmentId.contains('digital')) return EquipmentCategory.communication;
    return EquipmentCategory.laboratory;
  }

  String _generateCareerAdvancementNarrative(GamificationReward reward) {
    return '🎓 Congratulations on your promotion to ${reward.newCareerTitle}! Your research contributions have earned recognition in the marine biology community.';
  }

  String _generateStreakBonusNarrative(GamificationReward reward) {
    return '🔬 Consistent Research Methodology Bonus: +${reward.streakBonusXP} validated observations from ${reward.currentStreak} days of continuous research.';
  }

  String _generateDiscoveryStory(dynamic creature) {
    if (creature == null) return '';
    return 'During your research dive, you encountered this remarkable species in its natural habitat.';
  }

  String _generateScientificImportance(dynamic creature) {
    if (creature == null) return '';
    return 'This species plays a crucial role in the marine ecosystem and contributes valuable data to ongoing research.';
  }

  String _generateConservationImpact(dynamic creature) {
    if (creature == null) return '';
    return 'Your documentation of this species supports marine conservation efforts and habitat protection initiatives.';
  }
}