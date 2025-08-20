import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/aquarium.dart';
import '../models/creature.dart';
import '../models/coral.dart';
import '../widgets/dive_computer_widget.dart';
import '../widgets/research_progress_widget.dart';
import '../widgets/timer_display.dart';
import '../services/gamification_service.dart';
import '../services/persistence/persistence_service.dart';
import '../rendering/advanced_creature_renderer.dart';
import '../rendering/biome_environment_renderer.dart';
import '../widgets/enhanced_research_journal.dart';
import '../data/comprehensive_species_database.dart';

/// Full-screen marine biology research station and ocean environment
/// Replaces the circular timer with an immersive underwater experience
class FullScreenOceanWidget extends StatefulWidget {
  final Aquarium aquarium;
  final double sessionProgress; // 0.0 to 1.0, session progress
  final bool isRunning;
  final bool isStudySession;
  final List<Creature> visibleCreatures;
  final List<Coral> visibleCorals;
  final int secondsRemaining;
  final int totalSessionSeconds;
  final VoidCallback onTap;
  
  // Optional ValueNotifiers for efficient updates
  final ValueNotifier<int>? secondsRemainingNotifier;
  final ValueNotifier<bool>? isRunningNotifier;

  const FullScreenOceanWidget({
    super.key,
    required this.aquarium,
    required this.sessionProgress,
    required this.isRunning,
    required this.isStudySession,
    required this.visibleCreatures,
    required this.visibleCorals,
    required this.secondsRemaining,
    required this.totalSessionSeconds,
    required this.onTap,
    this.secondsRemainingNotifier,
    this.isRunningNotifier,
  });

  @override
  State<FullScreenOceanWidget> createState() => _FullScreenOceanWidgetState();
}

class _FullScreenOceanWidgetState extends State<FullScreenOceanWidget>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _bubbleController;
  late AnimationController _depthController;
  late AnimationController _timerPulseController;
  late Animation<double> _timerPulseAnimation;
  late AnimationController _journalExpandController;
  late Animation<double> _journalExpandAnimation;
  late List<AnimationController> _fishControllers;
  late List<Animation<Offset>> _fishAnimations;
  
  // State for journal expansion
  bool _isJournalExpanded = false;
  
  // State for dive computer hover
  bool _isDiveComputerHovered = false;
  
  // State for discovered creatures (for research journal)
  List<Creature> _discoveredCreatures = [];
  int _publishedPapersCount = 0;
  
  // Continuous time tracking for smooth animations
  late DateTime _startTime;
  double get _continuousTime => DateTime.now().difference(_startTime).inMilliseconds / 1000.0;

  @override
  void initState() {
    super.initState();
    
    // Initialize continuous time
    _startTime = DateTime.now();
    
    // Water wave animation
    _waveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Bubble animation
    _bubbleController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    // Depth progression animation (mimics diving deeper during session)
    _depthController = AnimationController(
      duration: Duration(seconds: widget.totalSessionSeconds),
      vsync: this,
    );

    // Timer pulse animation for visibility
    _timerPulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _timerPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _timerPulseController,
      curve: Curves.easeInOut,
    ));

    // Journal expand animation
    _journalExpandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _journalExpandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _journalExpandController,
      curve: Curves.easeOutBack,
    ));

    // Initialize creature animations
    _initializeFishAnimations();

    // Start depth progression if session is running
    if (widget.isRunning) {
      _depthController.forward();
      _timerPulseController.repeat(reverse: true);
    }
    
    // Load discovered creatures for research journal
    _loadDiscoveredCreatures();
    // Load published papers count
    _loadPublishedPapersCount();
  }
  
  /// Load discovered creatures from persistence service
  Future<void> _loadDiscoveredCreatures() async {
    try {
      final discovered = await PersistenceService.instance.ocean.getDiscoveredCreatures();
      if (mounted) {
        setState(() {
          _discoveredCreatures = discovered;
        });
      }
    } catch (e) {
      // Handle error silently - research journal will show empty state
    }
  }
  
  /// Load published papers count from research repository
  Future<void> _loadPublishedPapersCount() async {
    try {
      final publishedPapers = await PersistenceService.instance.research.getPublishedPapers();
      if (mounted) {
        setState(() {
          _publishedPapersCount = publishedPapers.length;
        });
      }
    } catch (e) {
      // Handle error silently - will show 0 papers
    }
  }
  
  /// Open the full research journal
  void _openResearchJournal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EnhancedResearchJournal(),
        fullscreenDialog: true,
      ),
    );
  }

  void _initializeFishAnimations() {
    _fishControllers = [];
    _fishAnimations = [];

    for (int i = 0; i < widget.visibleCreatures.length; i++) {
      final controller = AnimationController(
        duration: Duration(seconds: 8 + i * 3), // Vary swimming speed
        vsync: this,
      );

      // Create more realistic swimming patterns
      final startY = 0.2 + (i * 0.15) % 0.6;
      final endY = startY + (math.sin(i.toDouble()) * 0.1);
      
      final animation = Tween<Offset>(
        begin: Offset(-0.1, startY),
        end: Offset(1.1, endY),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.linear,
      ));

      _fishControllers.add(controller);
      _fishAnimations.add(animation);
      
      controller.repeat();
    }
  }

  @override
  void didUpdateWidget(FullScreenOceanWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update fish animations if creatures changed
    if (oldWidget.visibleCreatures.length != widget.visibleCreatures.length) {
      for (final controller in _fishControllers) {
        controller.dispose();
      }
      _initializeFishAnimations();
    }

    // Update depth progression based on session state
    if (widget.isRunning && !oldWidget.isRunning) {
      _depthController.forward();
      _timerPulseController.repeat(reverse: true);
    } else if (!widget.isRunning && oldWidget.isRunning) {
      _depthController.stop();
      _timerPulseController.stop();
      _timerPulseController.reset();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _bubbleController.dispose();
    _depthController.dispose();
    _timerPulseController.dispose();
    _journalExpandController.dispose();
    for (final controller in _fishControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Calculate current depth based on session progress and session type
  int _getCurrentDepth() {
    final baseDepth = widget.sessionProgress * _getTargetDepth();
    return baseDepth.round();
  }

  /// Get target depth based on session duration (diving expedition type)
  int _getTargetDepth() {
    final sessionMinutes = widget.totalSessionSeconds / 60;
    
    if (sessionMinutes >= 90) {
      return 50; // Abyssal expedition
    } else if (sessionMinutes >= 45) {
      return 35; // Deep sea research
    } else if (sessionMinutes >= 25) {
      return 20; // Mid-water expedition
    } else {
      return 10; // Shallow water research
    }
  }

  BiomeType _getCurrentBiome() {
    final depth = _getCurrentDepth();
    if (depth >= 40) return BiomeType.abyssalZone;
    if (depth >= 20) return BiomeType.deepOcean;
    if (depth >= 10) return BiomeType.coralGarden;
    return BiomeType.shallowWaters;
  }

  LinearGradient _getDepthGradient() {
    final biome = _getCurrentBiome();
    final depthIntensity = widget.sessionProgress;
    
    switch (biome) {
      case BiomeType.shallowWaters:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF87CEEB).withValues(alpha: 0.8 + depthIntensity * 0.2),
            const Color(0xFF00A6D6).withValues(alpha: 0.9 + depthIntensity * 0.1),
            const Color(0xFF006994),
          ],
        );
      case BiomeType.coralGarden:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF40E0D0).withValues(alpha: 0.7 + depthIntensity * 0.3),
            const Color(0xFF00CED1),
            const Color(0xFF008B8B),
          ],
        );
      case BiomeType.deepOcean:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0077BE).withValues(alpha: 0.6 + depthIntensity * 0.4),
            const Color(0xFF003366),
            const Color(0xFF001122),
          ],
        );
      case BiomeType.abyssalZone:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF191970).withValues(alpha: 0.8),
            const Color(0xFF000080),
            const Color(0xFF000000),
          ],
        );
    }
  }

  String _getDiveStatus() {
    if (!widget.isRunning) return 'Surface';
    if (widget.isStudySession) return 'Diving';
    return 'Ascending';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final currentDepth = _getCurrentDepth();
    final targetDepth = _getTargetDepth();

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: BoxDecoration(
          gradient: _getDepthGradient(),
        ),
        child: Stack(
          children: [
            // Underwater environment background
            _buildWaterBackground(screenSize),
            
            // Depth-based particle effects
            _buildDepthParticles(screenSize),
            
            // Coral reef
            _buildCoralReef(screenSize),
            
            // Swimming creatures
            _buildSwimmingCreatures(screenSize),
            
            // Bubbles from equipment
            _buildBubbles(screenSize),
            
            // Prominent Timer Display at the top center
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: _buildProminentTimer(),
              ),
            ),
            
            // Research Station UI Elements (with smooth transitions for distraction-free mode)
            Positioned(
              top: 220,
              left: 20,
              right: 20,
              child: AnimatedOpacity(
                opacity: _isActiveStudySession() ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 500),
                child: Row(
                  children: [
                    // Dive Computer
                    DiveComputerWidget(
                      currentDepthMeters: currentDepth,
                      targetDepthMeters: targetDepth,
                      oxygenTimeNotifier: widget.secondsRemainingNotifier,
                      oxygenTimeSeconds: widget.secondsRemaining,
                      isDiving: widget.isRunning,
                      diveStatus: _getDiveStatus(),
                      depthProgress: widget.sessionProgress,
                    ),
                    
                    const Spacer(),
                    
                    // Research Progress - hidden during study sessions
                    ResearchProgressWidget(
                      speciesDiscovered: _discoveredCreatures.length,
                      totalSpeciesInCurrentBiome: ComprehensiveSpeciesDatabase.getSpeciesForBiome(_getCurrentBiome()).length,
                      researchPapersPublished: _publishedPapersCount,
                      certificationProgress: GamificationService.instance.getLevelProgress(),
                    ),
                  ],
                ),
              ),
            ),
            
            // Floating Dive Computer during active study sessions (with smooth entrance)
            if (_isActiveStudySession())
              _buildFloatingDiveComputer(currentDepth.toDouble(), targetDepth.toDouble()),
            
            // Central play/pause control with ocean theme
            _buildCentralControl(screenSize),
            
            // Research journal (bottom right)
            _buildResearchJournal(),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterBackground(Size screenSize) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          painter: AdvancedBiomeEnvironmentPainter(
            progress: _continuousTime,
            biome: _getCurrentBiome(),
            depth: _getCurrentDepth().toDouble(),
            sessionProgress: widget.sessionProgress,
          ),
          size: screenSize,
        );
      },
    );
  }

  Widget _buildDepthParticles(Size screenSize) {
    return AnimatedBuilder(
      animation: _bubbleController,
      builder: (context, child) {
        return CustomPaint(
          painter: DepthParticlesPainter(
            progress: _bubbleController.value,
            depth: _getCurrentDepth(),
            isActive: widget.isRunning,
          ),
          size: screenSize,
        );
      },
    );
  }

  Widget _buildCoralReef(Size screenSize) {
    return Stack(
      children: widget.visibleCorals.asMap().entries.map((entry) {
        final index = entry.key;
        final coral = entry.value;
        final position = _getCoralPosition(index, screenSize);
        
        return Positioned(
          left: position.dx,
          bottom: position.dy,
          child: _buildCoral(coral),
        );
      }).toList(),
    );
  }

  Offset _getCoralPosition(int index, Size screenSize) {
    final angles = [0.1, 0.3, 0.7, 0.9, 0.5]; // Distributed positions
    final angle = angles[index % angles.length];
    
    return Offset(
      screenSize.width * angle - 30, // Offset for coral width
      30 + (index % 3) * 20, // Bottom positioning with variation
    );
  }

  Widget _buildCoral(Coral coral) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      width: 50 + (coral.growthProgress * 30),
      height: 40 + (coral.growthProgress * 35),
      child: CustomPaint(
        painter: EnhancedCoralPainter(
          coral: coral,
          isGrowing: widget.isRunning && widget.isStudySession,
          sessionProgress: widget.sessionProgress,
        ),
      ),
    );
  }

  Widget _buildSwimmingCreatures(Size screenSize) {
    return Stack(
      children: widget.visibleCreatures.asMap().entries.map((entry) {
        final index = entry.key;
        final creature = entry.value;
        
        if (index >= _fishAnimations.length) return const SizedBox.shrink();
        
        return AnimatedBuilder(
          animation: _fishAnimations[index],
          builder: (context, child) {
            return Positioned(
              left: _fishAnimations[index].value.dx * screenSize.width - 40,
              top: _fishAnimations[index].value.dy * screenSize.height,
              child: _buildCreature(creature, index),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildCreature(Creature creature, int index) {
    return SizedBox(
      width: 60,
      height: 45,
      child: CustomPaint(
        painter: AdvancedCreaturePainter(
          creature: creature,
          swimDirection: _fishAnimations[index].value.dx > 0.5 ? 1 : -1,
          depthLevel: _getCurrentDepth(),
          animationValue: _fishControllers[index].value,
        ),
      ),
    );
  }

  Widget _buildBubbles(Size screenSize) {
    return AnimatedBuilder(
      animation: _bubbleController,
      builder: (context, child) {
        return CustomPaint(
          painter: ResearchBubblesPainter(
            progress: _bubbleController.value,
            isActive: widget.isRunning,
            screenSize: screenSize,
          ),
          size: screenSize,
        );
      },
    );
  }

  Widget _buildProminentTimer() {
    final minutes = widget.secondsRemaining ~/ 60;
    final seconds = widget.secondsRemaining % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    // Determine urgency level for visual feedback
    final urgencyColor = widget.secondsRemaining < 60 
      ? Colors.redAccent 
      : widget.secondsRemaining < 300 
        ? Colors.orange 
        : Colors.white;
    
    return AnimatedBuilder(
      animation: _timerPulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isRunning ? _timerPulseAnimation.value : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.black.withValues(alpha: 0.3),
                ],
              ),
              border: Border.all(
                color: urgencyColor.withValues(alpha: 0.6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: urgencyColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Session type label
                Text(
                  widget.isStudySession ? 'DIVE SESSION' : 'SURFACE BREAK',
                  style: TextStyle(
                    color: urgencyColor.withValues(alpha: 0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                // Large timer display
                Text(
                  timeString,
                  style: TextStyle(
                    color: urgencyColor,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    shadows: [
                      Shadow(
                        color: urgencyColor.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                // Progress bar
                const SizedBox(height: 4),
                widget.secondsRemainingNotifier != null
                    ? TimerProgressBar(
                        secondsRemainingNotifier: widget.secondsRemainingNotifier!,
                        totalSeconds: widget.totalSessionSeconds,
                        width: 150,
                        height: 3,
                      )
                    : Container(
                        width: 150,
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 1.0 - widget.sessionProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              gradient: LinearGradient(
                                colors: [
                                  urgencyColor,
                                  urgencyColor.withValues(alpha: 0.7),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: urgencyColor.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCentralControl(Size screenSize) {
    return Positioned(
      bottom: screenSize.height * 0.25,
      left: screenSize.width / 2 - 40,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              widget.isStudySession 
                ? const Color(0xFF00CED1).withValues(alpha: 0.9)
                : const Color(0xFFFF8C00).withValues(alpha: 0.9),
              widget.isStudySession 
                ? const Color(0xFF008B8B).withValues(alpha: 0.7)
                : const Color(0xFFFF6347).withValues(alpha: 0.7),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.6),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: (widget.isStudySession 
                ? const Color(0xFF00CED1)
                : const Color(0xFFFF8C00)).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          widget.isRunning ? Icons.pause : Icons.play_arrow,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildResearchJournal() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: MouseRegion(
        onEnter: (_) {
          if (!_isJournalExpanded) {
            setState(() {
              _isJournalExpanded = true;
            });
            _journalExpandController.forward();
          }
        },
        onExit: (_) {
          if (_isJournalExpanded) {
            setState(() {
              _isJournalExpanded = false;
            });
            _journalExpandController.reverse();
          }
        },
        child: GestureDetector(
          onTap: _openResearchJournal,
          child: AnimatedBuilder(
            animation: _journalExpandAnimation,
            builder: (context, child) {
              return Container(
                width: _isJournalExpanded ? 200 : 56,
                height: _isJournalExpanded ? null : 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_isJournalExpanded ? 16 : 28),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1A1A2E).withValues(alpha: 0.8),
                      const Color(0xFF16213E).withValues(alpha: 0.8),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: _isJournalExpanded
                    ? _buildExpandedJournal()
                    : _buildCollapsedJournal(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedJournal() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.book,
            color: Colors.amber,
            size: 28,
          ),
          if (_discoveredCreatures.isNotEmpty)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Center(
                  child: Text(
                    '${_discoveredCreatures.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandedJournal() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.book,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Research Journal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.close,
                color: Colors.white.withValues(alpha: 0.6),
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_discoveredCreatures.isNotEmpty) ...[
            const Text(
              'Recent Discovery:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black.withValues(alpha: 0.3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _discoveredCreatures.last.name,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.water,
                        color: Colors.lightBlue.withValues(alpha: 0.8),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _discoveredCreatures.last.habitat.displayName,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.green.withValues(alpha: 0.8),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _discoveredCreatures.last.rarity.displayName,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Discoveries: ${_discoveredCreatures.length}',
              style: TextStyle(
                color: Colors.amber.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black.withValues(alpha: 0.2),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.white38,
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No discoveries yet',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Start diving to find marine life!',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Determines if current session is an active study session (focus session that is running)
  bool _isActiveStudySession() {
    return widget.isRunning && widget.isStudySession;
  }

  /// Builds a floating dive computer button for distraction-free study mode
  Widget _buildFloatingDiveComputer(double currentDepth, double targetDepth) {
    return Positioned(
      bottom: 20, // Moved closer to navigation bar
      left: 20,
      child: AnimatedScale(
        scale: widget.isRunning ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: () {
            // Absorb tap events to prevent session pause
          },
          child: MouseRegion(
            onEnter: (_) {
              setState(() {
                _isDiveComputerHovered = true;
              });
            },
            onExit: (_) {
              setState(() {
                _isDiveComputerHovered = false;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              width: _isDiveComputerHovered ? 200 : 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.blue.shade900.withValues(alpha: 0.9), // Ocean theme
                borderRadius: BorderRadius.circular(_isDiveComputerHovered ? 16 : 28),
                border: Border.all(
                  color: Colors.cyan.withValues(alpha: 0.8),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 3,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isDiveComputerHovered 
                ? _buildExpandedDiveInfo(currentDepth, targetDepth)
                : _buildCompactDiveButton(currentDepth),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the compact dive computer button (non-hovered state)
  Widget _buildCompactDiveButton(double currentDepth) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.speed,
          color: Colors.cyan,
          size: 20,
        ),
        const SizedBox(height: 2),
        Text(
          '${currentDepth.toInt()}m',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          _getDiveStatus().substring(0, 3),
          style: TextStyle(
            color: Colors.cyan,
            fontSize: 7,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Builds the expanded dive computer info (hovered state)
  Widget _buildExpandedDiveInfo(double currentDepth, double targetDepth) {
    final minutes = widget.secondsRemaining ~/ 60;
    final seconds = widget.secondsRemaining % 60;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Icon
          Icon(
            Icons.speed,
            color: Colors.cyan,
            size: 18,
          ),
          const SizedBox(width: 8),
          // Expanded info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Depth: ${currentDepth.toInt()}m → ${targetDepth.toInt()}m',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'O₂: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: Colors.cyan,
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _getDiveStatus(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Advanced painters using Phase 3 rendering systems

class AdvancedBiomeEnvironmentPainter extends CustomPainter {
  final double progress;
  final BiomeType biome;
  final double depth;
  final double sessionProgress;

  AdvancedBiomeEnvironmentPainter({
    required this.progress,
    required this.biome,
    required this.depth,
    required this.sessionProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Use our advanced biome environment renderer
    BiomeEnvironmentRenderer.paintBiomeEnvironment(
      canvas,
      size,
      biome,
      depth,
      sessionProgress,
      progress,
    );
  }

  @override
  bool shouldRepaint(AdvancedBiomeEnvironmentPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.depth != depth ||
           oldDelegate.sessionProgress != sessionProgress;
  }
}

class AdvancedCreaturePainter extends CustomPainter {
  final Creature creature;
  final int swimDirection;
  final int depthLevel;
  final double animationValue;

  AdvancedCreaturePainter({
    required this.creature,
    required this.swimDirection,
    required this.depthLevel,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    
    if (swimDirection < 0) {
      canvas.scale(-1, 1);
      canvas.translate(-size.width, 0);
    }

    // Use our advanced creature renderer
    AdvancedCreatureRenderer.paintCreature(
      canvas,
      size,
      creature,
      animationValue,
      depthLevel.toDouble(),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(AdvancedCreaturePainter oldDelegate) {
    return oldDelegate.creature != creature ||
           oldDelegate.swimDirection != swimDirection ||
           oldDelegate.depthLevel != depthLevel ||
           oldDelegate.animationValue != animationValue;
  }
}

// Enhanced painters for full-screen experience

class FullScreenWaterPainter extends CustomPainter {
  final double progress;
  final BiomeType biome;
  final double depthProgress;

  FullScreenWaterPainter({
    required this.progress,
    required this.biome,
    required this.depthProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05 + depthProgress * 0.1)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw multiple water layers for depth effect
    for (int layer = 0; layer < 3; layer++) {
      final path = Path();
      final layerOffset = layer * 0.3;
      
      for (double i = 0; i < size.width; i += 8) {
        final y = size.height * (0.2 + layer * 0.15) + 
                   math.sin((i / size.width * 6 * math.pi) + 
                           ((progress + layerOffset) * 2 * math.pi)) * 
                   (12 - layer * 3);
        if (i == 0) {
          path.moveTo(i, y);
        } else {
          path.lineTo(i, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(FullScreenWaterPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.depthProgress != depthProgress;
  }
}

class DepthParticlesPainter extends CustomPainter {
  final double progress;
  final int depth;
  final bool isActive;

  DepthParticlesPainter({
    required this.progress,
    required this.depth,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) return;

    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Plankton/debris particles
    for (int i = 0; i < 15; i++) {
      final offset = (progress + i * 0.1) % 1.0;
      final x = size.width * (0.1 + i * 0.06);
      final y = offset * size.height;
      
      // Vary particle appearance based on depth
      if (depth < 15) {
        // Shallow water - small bright particles (plankton)
        paint.color = Colors.yellow.withValues(alpha: 0.4);
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      } else if (depth < 30) {
        // Mid water - marine snow
        paint.color = Colors.white.withValues(alpha: 0.3);
        canvas.drawCircle(Offset(x, y), 1, paint);
      } else {
        // Deep water - bioluminescent particles
        paint.color = Colors.cyan.withValues(alpha: 0.6);
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DepthParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.depth != depth;
  }
}

class EnhancedCoralPainter extends CustomPainter {
  final Coral coral;
  final bool isGrowing;
  final double sessionProgress;

  EnhancedCoralPainter({
    required this.coral,
    required this.isGrowing,
    required this.sessionProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _getCoralColor()
      ..style = PaintingStyle.fill;

    // Enhanced coral growth based on session progress
    final growthScale = coral.growthProgress + (isGrowing ? sessionProgress * 0.2 : 0.0);
    
    canvas.save();
    canvas.scale(growthScale.clamp(0.3, 1.0));
    
    // Draw coral based on type with more detail
    switch (coral.type) {
      case CoralType.brain:
        _drawEnhancedBrainCoral(canvas, size, paint);
        break;
      case CoralType.staghorn:
        _drawEnhancedStaghornCoral(canvas, size, paint);
        break;
      case CoralType.table:
        _drawEnhancedTableCoral(canvas, size, paint);
        break;
      case CoralType.soft:
        _drawEnhancedSoftCoral(canvas, size, paint);
        break;
      case CoralType.fire:
        _drawEnhancedFireCoral(canvas, size, paint);
        break;
    }

    canvas.restore();

    // Add growing effect with enhanced glow
    if (isGrowing) {
      final glowPaint = Paint()
        ..color = _getCoralColor().withValues(alpha: 0.4 + sessionProgress * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width / 2 + sessionProgress * 10,
        glowPaint,
      );
    }
  }

  Color _getCoralColor() {
    // Enhanced colors with better visual appeal
    switch (coral.type) {
      case CoralType.brain:
        return const Color(0xFFFF69B4).withValues(alpha: 0.9); // Hot pink
      case CoralType.staghorn:
        return const Color(0xFFFF8C00).withValues(alpha: 0.9); // Dark orange
      case CoralType.table:
        return const Color(0xFFD2691E).withValues(alpha: 0.9); // Chocolate
      case CoralType.soft:
        return const Color(0xFF9370DB).withValues(alpha: 0.9); // Medium purple
      case CoralType.fire:
        return const Color(0xFFDC143C).withValues(alpha: 0.9); // Crimson
    }
  }

  void _drawEnhancedBrainCoral(Canvas canvas, Size size, Paint paint) {
    // Draw brain coral with ridged texture
    final path = Path();
    path.addOval(Rect.fromLTWH(0, size.height * 0.3, size.width, size.height * 0.7));
    canvas.drawPath(path, paint);
    
    // Add brain-like ridges
    final ridgePaint = Paint()
      ..color = paint.color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    for (int i = 0; i < 3; i++) {
      final ridgePath = Path();
      ridgePath.moveTo(size.width * 0.2, size.height * (0.4 + i * 0.15));
      ridgePath.quadraticBezierTo(
        size.width * 0.5, size.height * (0.35 + i * 0.15),
        size.width * 0.8, size.height * (0.4 + i * 0.15),
      );
      canvas.drawPath(ridgePath, ridgePaint);
    }
  }

  void _drawEnhancedStaghornCoral(Canvas canvas, Size size, Paint paint) {
    // Enhanced branching staghorn coral
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 12;
    paint.strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.5, size.height);
    path.lineTo(size.width * 0.3, size.height * 0.2);
    path.moveTo(size.width * 0.5, size.height);
    path.lineTo(size.width * 0.7, size.height * 0.2);
    path.moveTo(size.width * 0.5, size.height);
    path.lineTo(size.width * 0.5, size.height * 0.1);
    
    canvas.drawPath(path, paint);
  }

  void _drawEnhancedTableCoral(Canvas canvas, Size size, Paint paint) {
    // Table coral with more realistic shape
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, paint);
    
    // Add support stem
    final stemPaint = Paint()
      ..color = paint.color.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.4, size.height * 0.8, size.width * 0.2, size.height * 0.2),
      stemPaint,
    );
  }

  void _drawEnhancedSoftCoral(Canvas canvas, Size size, Paint paint) {
    // Flowing soft coral
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 18;
    paint.strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.2, size.height);
    path.quadraticBezierTo(
      size.width * 0.4, size.height * 0.5,
      size.width * 0.3, size.height * 0.1,
    );
    
    path.moveTo(size.width * 0.8, size.height);
    path.quadraticBezierTo(
      size.width * 0.6, size.height * 0.5,
      size.width * 0.7, size.height * 0.1,
    );
    
    canvas.drawPath(path, paint);
  }

  void _drawEnhancedFireCoral(Canvas canvas, Size size, Paint paint) {
    // Spiky fire coral with more branches
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 8;
    paint.strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < 7; i++) {
      final x = (i / 6) * size.width;
      final height = size.height * (0.2 + (i % 3) * 0.1);
      path.moveTo(x, size.height);
      path.lineTo(x, height);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(EnhancedCoralPainter oldDelegate) {
    return oldDelegate.coral != coral || 
           oldDelegate.isGrowing != isGrowing ||
           oldDelegate.sessionProgress != sessionProgress;
  }
}

class EnhancedCreaturePainter extends CustomPainter {
  final Creature creature;
  final int swimDirection;
  final int depthLevel;

  EnhancedCreaturePainter({
    required this.creature,
    required this.swimDirection,
    required this.depthLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _getCreatureColor()
      ..style = PaintingStyle.fill;

    canvas.save();
    
    if (swimDirection < 0) {
      canvas.scale(-1, 1);
      canvas.translate(-size.width, 0);
    }

    // Enhanced fish shape with depth-based modifications
    final bodyPath = Path();
    final bodyScale = _getDepthSizeModifier();
    
    bodyPath.moveTo(size.width * 0.15, size.height * 0.5);
    bodyPath.quadraticBezierTo(
      size.width * (0.75 * bodyScale), size.height * 0.15,
      size.width * (0.75 * bodyScale), size.height * 0.5,
    );
    bodyPath.quadraticBezierTo(
      size.width * (0.75 * bodyScale), size.height * 0.85,
      size.width * 0.15, size.height * 0.5,
    );
    
    // Tail
    bodyPath.moveTo(0, size.height * 0.25);
    bodyPath.lineTo(size.width * 0.15, size.height * 0.5);
    bodyPath.lineTo(0, size.height * 0.75);
    
    canvas.drawPath(bodyPath, paint);

    // Enhanced eye with depth-based lighting
    final eyeSize = 4.0 * bodyScale;
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.35),
      eyeSize,
      eyePaint,
    );
    
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.35),
      eyeSize * 0.5,
      pupilPaint,
    );

    // Add fins for more realistic appearance
    final finPaint = Paint()
      ..color = paint.color.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    
    // Dorsal fin
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.4, size.height * 0.2)
        ..lineTo(size.width * 0.5, size.height * 0.05)
        ..lineTo(size.width * 0.6, size.height * 0.2),
      finPaint,
    );

    canvas.restore();
  }

  Color _getCreatureColor() {
    // Depth-based color modification
    Color baseColor;
    switch (creature.rarity) {
      case CreatureRarity.common:
        baseColor = const Color(0xFF4FC3F7); // Light blue
        break;
      case CreatureRarity.uncommon:
        baseColor = const Color(0xFF66BB6A); // Light green
        break;
      case CreatureRarity.rare:
        baseColor = const Color(0xFF9C27B0); // Purple
        break;
      case CreatureRarity.legendary:
        baseColor = const Color(0xFFFFB74D); // Amber
        break;
    }

    // Modify color based on depth (deeper = more muted)
    final depthFactor = (depthLevel / 50.0).clamp(0.0, 1.0);
    final darkeningFactor = 1.0 - (depthFactor * 0.4);
    
    return Color.fromRGBO(
      ((baseColor.r * 255.0) * darkeningFactor).round(),
      ((baseColor.g * 255.0) * darkeningFactor).round(),
      ((baseColor.b * 255.0) * darkeningFactor).round(),
      baseColor.a,
    );
  }

  double _getDepthSizeModifier() {
    // Deep sea creatures tend to be larger
    if (depthLevel > 30) return 1.3;
    if (depthLevel > 15) return 1.1;
    return 1.0;
  }

  @override
  bool shouldRepaint(EnhancedCreaturePainter oldDelegate) {
    return oldDelegate.creature != creature || 
           oldDelegate.swimDirection != swimDirection ||
           oldDelegate.depthLevel != depthLevel;
  }
}

class ResearchBubblesPainter extends CustomPainter {
  final double progress;
  final bool isActive;
  final Size screenSize;

  ResearchBubblesPainter({
    required this.progress,
    required this.isActive,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) return;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Equipment bubbles from dive computer area
    final equipmentBubbles = [
      Offset(screenSize.width * 0.15, screenSize.height * 0.8),
      Offset(screenSize.width * 0.18, screenSize.height * 0.75),
      Offset(screenSize.width * 0.12, screenSize.height * 0.85),
    ];

    for (int i = 0; i < equipmentBubbles.length; i++) {
      final pos = equipmentBubbles[i];
      final bubbleProgress = (progress + i * 0.4) % 1.0;
      final y = pos.dy - (bubbleProgress * screenSize.height * 0.7);
      final x = pos.dx + math.sin(bubbleProgress * math.pi * 4) * 20;
      
      if (y > 0) {
        final bubbleSize = 2 + (bubbleProgress * 4);
        canvas.drawCircle(
          Offset(x, y),
          bubbleSize,
          paint,
        );
      }
    }

    // Research station ambient bubbles
    for (int i = 0; i < 12; i++) {
      final offset = (progress + i * 0.12) % 1.0;
      final x = screenSize.width * (0.1 + i * 0.07);
      final y = screenSize.height * (1.0 - offset);
      final radius = 1.5 + (i % 4);
      
      if (y > 0 && y < screenSize.height) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(ResearchBubblesPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isActive != isActive;
  }
}