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
    
    debugPrint('DEBUG: Created ${_celebrationConfig.phases.length} phases:');
    for (int i = 0; i < _celebrationConfig.phases.length; i++) {
      final phase = _celebrationConfig.phases[i];
      debugPrint('  Phase $i: ${phase.name} (${phase.startTime.inMilliseconds}ms - ${phase.endTime.inMilliseconds}ms)');
    }
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

    // Master controller is now only used for overall timing, not automatic transitions
  }

  void _startCelebrationSequence() async {
    if (_animationStarted) return;
    _animationStarted = true;

    // Start with surfacing animation
    _surfacingController.forward();
    
    // Start particle effects
    _particleController.forward();
    
    // Wait for surfacing animation to complete, then show first content page automatically
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Start with phase 1 (Data Collection) instead of phase 0 (Surfacing)
    if (_celebrationConfig.phases.length > 1 && mounted) {
      _startPhase(1);
    }
  }

  // Removed automatic phase transitions - now purely user controlled

  void _startPhase(int phaseIndex) {
    if (phaseIndex >= _celebrationConfig.phases.length) return;
    
    debugPrint('DEBUG: Starting phase $phaseIndex: ${_celebrationConfig.phases[phaseIndex].name}');
    
    setState(() {
      _currentPhaseIndex = phaseIndex;
      _currentPhase = _celebrationConfig.phases[phaseIndex];
    });
    
    // Start the phase controller
    _phaseControllers[phaseIndex].forward();
  }

  void _skipToEnd() {
    if (!_canSkip) return;
    
    debugPrint('DEBUG: User tapped - current phase: $_currentPhaseIndex/${_celebrationConfig.phases.length - 1}');
    
    // Advance to next phase or complete if we're on the last phase
    if (_currentPhaseIndex < _celebrationConfig.phases.length - 1) {
      // Advance to next phase
      final nextPhaseIndex = _currentPhaseIndex + 1;
      debugPrint('DEBUG: Advancing to phase $nextPhaseIndex');
      
      // Complete current phase controller
      _phaseControllers[_currentPhaseIndex].animateTo(1.0, duration: const Duration(milliseconds: 200));
      
      // Start the next phase
      _startPhase(nextPhaseIndex);
      
      // Temporarily disable skip to prevent rapid tapping
      setState(() {
        _canSkip = false;
      });
      
      // Re-enable skip after a short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _canSkip = true;
          });
        }
      });
    } else {
      // We're on the last phase, complete everything
      setState(() {
        _canSkip = false;
      });
      
      // Complete all controllers
      _surfacingController.animateTo(1.0, duration: const Duration(milliseconds: 200));
      _particleController.animateTo(1.0, duration: const Duration(milliseconds: 200));
      
      for (final controller in _phaseControllers) {
        controller.animateTo(1.0, duration: const Duration(milliseconds: 200));
      }
      
      // Complete the sequence
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          widget.onContinue();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Layer 1: Underwater background with depth transition
          RepaintBoundary(
            child: UnderwaterBackground(
              biomeConfig: BiomeVisualConfig.forBiome(_celebrationConfig.primaryBiome),
              depthProgress: _surfacingController,
              celebrationIntensity: _celebrationConfig.intensity,
            ),
          ),
          
          // Layer 2: Surfacing animation overlay
          RepaintBoundary(
            child: SurfacingAnimationLayer(
              controller: _surfacingController,
              expeditionResult: _expeditionResult,
              celebrationConfig: _celebrationConfig,
            ),
          ),
          
          // Layer 3: Particle systems and environmental effects  
          RepaintBoundary(
            child: UnderwaterParticleSystem(
              controller: _particleController,
              celebrationConfig: _celebrationConfig,
              currentPhase: _currentPhase,
            ),
          ),
          
          // Layer 4: Main content based on current phase
          RepaintBoundary(
            child: _buildMainContent(),
          ),
          
          // Layer 5: Invisible tap detector overlay (on top of everything)
          Positioned.fill(
            child: GestureDetector(
              onTap: _skipToEnd,
              behavior: HitTestBehavior.translucent,
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
            
          // Layer 6: Progress Indicator - show current phase progress
          if (_currentPhase != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: _buildProgressIndicator(),
            ),
            
          // Layer 7: Skip indicator (visual only) - only show after first phase starts
          if (_canSkip && _currentPhase != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.cyan.withValues(alpha: 0.7), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.touch_app, color: Colors.cyan, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _currentPhaseIndex < _celebrationConfig.phases.length - 1 
                          ? 'Tap to advance'
                          : 'Tap to continue',
                      style: const TextStyle(
                        color: Colors.cyan,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildMainContent() {
    // Show content based on current phase
    if (_currentPhase == null) {
      debugPrint('DEBUG: No current phase - showing empty content');
      return const SizedBox.shrink();
    }

    debugPrint('DEBUG: Building content for phase: ${_currentPhase!.name} (index: $_currentPhaseIndex)');

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

  Widget _buildProgressIndicator() {
    // Calculate content phases (excluding surfacing)
    final contentPhases = _celebrationConfig.phases.where((phase) => phase.name != 'Surfacing').toList();
    final currentContentPhaseIndex = _currentPhaseIndex > 0 ? _currentPhaseIndex - 1 : 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${currentContentPhaseIndex + 1} of ${contentPhases.length}',
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          ...List.generate(contentPhases.length, (index) {
            final isCompleted = index < currentContentPhaseIndex;
            final isCurrent = index == currentContentPhaseIndex;
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? Colors.amber
                    : isCurrent
                        ? Colors.amber.withValues(alpha: 0.7)
                        : Colors.grey.withValues(alpha: 0.4),
              ),
            );
          }),
        ],
      ),
    );
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
    final streakBonus = reward.streakBonusXP;
    
    String baseNarrative;
    String conservationImpact;
    
    // Enhanced depth-based narratives with conservation impact
    if (depth > 50) {
      baseNarrative = '📊 Your dive team collected $dataPoints new data samples from the ${depth.toStringAsFixed(1)}m abyssal research zone';
      conservationImpact = 'These deep-sea observations contribute to protecting mysterious ocean depths that are home to unique species found nowhere else on Earth.';
    } else if (depth > 20) {
      baseNarrative = '🐋 Marine researchers documented $dataPoints valuable observations from the ${depth.toStringAsFixed(1)}m open ocean ecosystem';
      conservationImpact = 'Your research helps protect migratory routes of whales, dolphins, and sea turtles that depend on healthy open ocean environments.';
    } else if (depth > 5) {
      baseNarrative = '🐠 Your coral reef research team recorded $dataPoints significant findings at ${depth.toStringAsFixed(1)}m depth';
      conservationImpact = 'This research directly supports coral conservation efforts - healthy reefs provide homes for 25% of all marine species.';
    } else {
      baseNarrative = '🏊 Your coastal survey team gathered $dataPoints research data points from the ${depth.toStringAsFixed(1)}m shallow waters';
      conservationImpact = 'Coastal research is vital for protecting nursery habitats where young marine animals begin their lives.';
    }
    
    // Add streak bonus narrative
    String streakNarrative = '';
    if (streakBonus > 0) {
      streakNarrative = '\n\n🔬 Consistent research methodology bonus: +$streakBonus validated observations from your dedication to daily marine research.';
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
    // Generate conservation-focused achievement narratives
    if (achievement.id.contains('streak')) {
      return '🏆 Scientific Recognition: Consistent Research Methodology Award. Your daily dedication has contributed to a 127% increase in coral formation health monitoring.';
    } else if (achievement.id.contains('discovery')) {
      return '🎓 Research Milestone: Species Documentation Excellence. Your discoveries help scientists understand biodiversity patterns critical for ocean protection.';
    } else if (achievement.id.contains('depth')) {
      return '⚡ Exploration Achievement: Deep-Sea Research Pioneer. Your deep water research explores habitats that may hold keys to climate resilience.';
    } else if (achievement.id.contains('session') || achievement.id.contains('focus')) {
      return '⏰ Productivity Recognition: Research Session Dedication. Consistent research sessions like yours have led to breakthroughs in marine protection strategies.';
    } else {
      return '🎓 ${achievement.description} Your research methodology contributes to protecting marine ecosystems that support millions of species worldwide.';
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
    // Generate equipment descriptions based on ID
    return 'Advanced marine research equipment for enhanced data collection and species observation.';
  }

  String _generateStationUpgrade(String equipmentId) {
    final equipmentName = _formatEquipmentName(equipmentId);
    
    // Generate specific station upgrade narratives based on equipment type
    if (equipmentId.contains('camera') || equipmentId.contains('photo')) {
      return '🎥 Research Station Upgraded: Deep-Sea Photography Lab now available. Document rare species with professional-grade underwater imaging equipment.';
    } else if (equipmentId.contains('sonar') || equipmentId.contains('radar')) {
      return '📡 Research Station Upgraded: Sonar Mapping Laboratory established. Map ocean floor topography and track marine animal migration patterns.';
    } else if (equipmentId.contains('sampler') || equipmentId.contains('collection')) {
      return '🧪 Research Station Upgraded: Specimen Analysis Lab operational. Collect and analyze water samples, plankton, and genetic material safely.';
    } else if (equipmentId.contains('computer') || equipmentId.contains('digital')) {
      return '💻 Research Station Upgraded: Digital Analysis Center online. Process vast amounts of marine data with AI-assisted pattern recognition.';
    } else if (equipmentId.contains('submersible') || equipmentId.contains('rov')) {
      return '🚁 Research Station Upgraded: Deep-Sea Vehicle Bay constructed. Deploy remotely operated vehicles to explore previously unreachable depths.';
    } else {
      return '🔬 Research Station Upgraded: $equipmentName Laboratory now available. Your expanded capabilities enable more comprehensive marine research.';
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
    if (equipmentId.contains('computer') || equipmentId.contains('digital')) return EquipmentCategory.communication;
    return EquipmentCategory.laboratory;
  }

  String _generateCareerAdvancementNarrative(GamificationReward reward) {
    final oldTitle = reward.oldCareerTitle ?? 'Research Intern';
    final newTitle = reward.newCareerTitle ?? 'Marine Biologist';
    final newLevel = reward.newLevel;
    
    // Generate impact-focused advancement narrative based on level ranges
    String impactStatement;
    String nextCapabilities;
    
    if (newLevel >= 16) {
      impactStatement = 'Your groundbreaking research has influenced marine conservation policy worldwide. As a Master Marine Biologist, your discoveries protect entire ocean ecosystems.';
      nextCapabilities = 'You now have access to research vessels, quantum scanners, and can lead international conservation initiatives.';
    } else if (newLevel >= 11) {
      impactStatement = 'Your leadership in marine research has directly resulted in the protection of critical marine habitats. Coral reefs are 15% healthier thanks to research like yours.';
      nextCapabilities = 'As Research Director, you can now conduct deep-sea expeditions and mentor junior researchers.';
    } else if (newLevel >= 6) {
      impactStatement = 'Your certified research has contributed to identifying new species and protecting vulnerable marine populations. Three endangered species have improved survival rates due to your work.';
      nextCapabilities = 'As a Certified Marine Biologist, you can now use advanced underwater equipment and publish peer-reviewed papers.';
    } else {
      impactStatement = 'Your dedicated research is building the foundation for marine conservation. Every observation helps us better understand and protect ocean life.';
      nextCapabilities = 'Your expanded research capabilities will help document species behavior and ecosystem health.';
    }
    
    return '🎓 Career Advancement: $oldTitle → $newTitle\n\n$impactStatement\n\n$nextCapabilities';
  }

  String _generateStreakBonusNarrative(GamificationReward reward) {
    return '🔬 Consistent Research Methodology Bonus: +${reward.streakBonusXP} validated observations from ${reward.currentStreak} days of continuous research.';
  }

  String _generateDiscoveryStory(dynamic creature) {
    if (creature == null) return '';
    
    if (creature is Creature) {
      switch (creature.rarity) {
        case CreatureRarity.legendary:
          return '🌟 Extraordinary Discovery: You encountered this legendary species during a deep research expedition. This represents a once-in-a-lifetime research opportunity that few marine biologists experience.';
        case CreatureRarity.rare:
          return '✨ Significant Find: Your careful observation technique allowed you to document this rare species. This sighting provides crucial data for understanding threatened marine populations.';
        case CreatureRarity.uncommon:
          return '🔍 Valuable Observation: During your research dive, you successfully identified and documented this uncommon species, contributing to biodiversity mapping efforts.';
        case CreatureRarity.common:
          return '📝 Essential Documentation: You recorded important behavioral data for this species, contributing to baseline studies that help us understand healthy marine ecosystems.';
      }
    }
    
    return 'During your research dive, you encountered this remarkable species in its natural habitat.';
  }

  String _generateScientificImportance(dynamic creature) {
    if (creature == null) return '';
    
    if (creature is Creature) {
      switch (creature.rarity) {
        case CreatureRarity.legendary:
          return 'This legendary species discovery may unlock secrets of deep-sea adaptation and provide breakthrough insights for marine biology. Your documentation contributes to global scientific databases.';
        case CreatureRarity.rare:
          return 'This rare species sighting helps scientists understand population dynamics and breeding patterns essential for species survival and recovery programs.';
        case CreatureRarity.uncommon:
          return 'Documentation of this uncommon species contributes to understanding ecosystem balance and the interconnected relationships within marine food webs.';
        case CreatureRarity.common:
          return 'This common species serves as an important indicator of ecosystem health. Your observations help establish baseline data for long-term conservation monitoring.';
      }
    }
    
    return 'This species plays a crucial role in the marine ecosystem and contributes valuable data to ongoing research.';
  }

  String _generateConservationImpact(dynamic creature) {
    if (creature == null) return '';
    
    if (creature is Creature) {
      switch (creature.rarity) {
        case CreatureRarity.legendary:
          return '🌊 Your documentation of this legendary species directly influences international marine protection policies. This discovery may result in new protected marine areas and species preservation programs.';
        case CreatureRarity.rare:
          return '🛡️ Your rare species documentation supports emergency conservation measures. Data like yours has contributed to preventing three marine species extinctions in the past decade.';
        case CreatureRarity.uncommon:
          return '🌱 Your observation helps maintain biodiversity by supporting habitat protection initiatives. Marine protected areas are 23% more effective when guided by research like yours.';
        case CreatureRarity.common:
          return '💚 Your research contributes to ecosystem stability monitoring. Healthy populations of common species like this indicate thriving marine environments that support all ocean life.';
      }
    }
    
    return 'Your documentation of this species supports marine conservation efforts and habitat protection initiatives.';
  }
}