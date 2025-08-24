import 'package:flutter/material.dart';
import '../services/gamification_service.dart';
import '../themes/ocean_theme.dart';

/// Marine biology research progress display
/// Shows current research level, species discovered, papers published, and certification progress
class ResearchProgressWidget extends StatefulWidget {
  final int speciesDiscovered;
  final int totalSpeciesInCurrentBiome;
  final int researchPapersPublished;
  final double certificationProgress; // 0.0 to 1.0

  const ResearchProgressWidget({
    super.key,
    required this.speciesDiscovered,
    required this.totalSpeciesInCurrentBiome,
    required this.researchPapersPublished,
    required this.certificationProgress,
  });

  @override
  State<ResearchProgressWidget> createState() => _ResearchProgressWidgetState();
}

class _ResearchProgressWidgetState extends State<ResearchProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(
      begin: 0.4,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  String _getResearcherTitle() {
    final level = GamificationService.instance.currentLevel;
    if (level >= 76) return 'Ocean Explorer';
    if (level >= 51) return 'Marine Biologist';
    if (level >= 26) return 'Deep Water Researcher';
    if (level >= 11) return 'Open Water Diver';
    return 'Snorkeling Enthusiast';
  }

  Color _getLevelColor() {
    final level = GamificationService.instance.currentLevel;
    if (level >= 76) return OceanTheme.rarePurple; // Master level - purple
    if (level >= 51) return OceanTheme.uncommonBlue; // Expert level - blue
    if (level >= 26) return OceanTheme.diveTeal; // Advanced level - teal
    if (level >= 11) return OceanTheme.successGreen; // Intermediate level - green
    return OceanTheme.shallowWaterBlue; // Beginner level - light blue
  }

  @override
  Widget build(BuildContext context) {
    final level = GamificationService.instance.currentLevel;
    final levelColor = _getLevelColor();
    final speciesProgress = widget.totalSpeciesInCurrentBiome > 0 
        ? widget.speciesDiscovered / widget.totalSpeciesInCurrentBiome 
        : 0.0;

    // Make responsive to screen width - balance with DiveComputer size
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - 40; // Account for left/right padding  
    final diveComputerWidth = screenWidth * 0.45;
    final maxWidth = availableWidth - diveComputerWidth - 16; // Space for Spacer
    final widgetWidth = maxWidth.clamp(160.0, 200.0);

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: widgetWidth,
          height: MediaQuery.of(context).size.height * 0.18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                OceanTheme.cardBackground.withValues(alpha: 0.9),
                OceanTheme.containerBackground.withValues(alpha: 0.9),
              ],
            ),
            border: Border.all(
              color: levelColor.withValues(alpha: _glowAnimation.value),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: levelColor.withValues(alpha: 0.3 * _glowAnimation.value),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.science,
                      color: levelColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widgetWidth < 190 ? 'RESEARCH' : 'RESEARCH PROGRESS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widgetWidth < 190 ? 10 : 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: widgetWidth < 190 ? 0.6 : 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Level and title
                Text(
                  'Level $level: ${_getResearcherTitle()}',
                  style: TextStyle(
                    color: levelColor,
                    fontSize: widgetWidth < 190 ? 11 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // Species progress
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Species: ${widget.speciesDiscovered}/${widget.totalSpeciesInCurrentBiome}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 3),
                          LinearProgressIndicator(
                            value: speciesProgress.clamp(0.0, 1.0),
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              OceanTheme.successGreen,
                            ),
                            minHeight: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 3),
                
                // Papers and certification
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Papers: ${widget.researchPapersPublished}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Next Level: ${(widget.certificationProgress * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 3),
                          LinearProgressIndicator(
                            value: widget.certificationProgress.clamp(0.0, 1.0),
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                            minHeight: 2,
                          ),
                        ],
                      ),
                    ),
                    // Level badge
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            levelColor.withValues(alpha: 0.8),
                            levelColor.withValues(alpha: 0.4),
                          ],
                        ),
                        border: Border.all(
                          color: levelColor,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$level',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
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
}