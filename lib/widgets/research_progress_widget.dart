import 'package:flutter/material.dart';
import '../themes/ocean_theme.dart';
import '../utils/responsive_helper.dart';
import '../services/marine_biology_career_service.dart';

/// Marine biology research progress display
/// Shows career progression, species discoveries, research papers, and achievement milestones
class ResearchProgressWidget extends StatefulWidget {
  final int speciesDiscoveredInCurrentBiome;
  final int totalSpeciesInCurrentBiome;
  final int totalSpeciesDiscovered; // For reference/tooltip
  final int researchPapersPublished;
  final int cumulativeRP;
  final String currentDepthZone;
  final String currentCareerTitle;

  const ResearchProgressWidget({
    super.key,
    required this.speciesDiscoveredInCurrentBiome,
    required this.totalSpeciesInCurrentBiome,
    required this.totalSpeciesDiscovered,
    required this.researchPapersPublished,
    required this.cumulativeRP,
    required this.currentDepthZone,
    required this.currentCareerTitle,
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

  Color _getDepthZoneColor() {
    switch (widget.currentDepthZone) {
      case 'Abyssal Zone':
        return OceanTheme.rarePurple; // Deep abyss - purple
      case 'Deep Ocean':
        return OceanTheme.diveTeal; // Deep waters - teal
      case 'Coral Garden':
        return OceanTheme.successGreen; // Coral reef - green
      case 'Shallow Waters':
      default:
        return OceanTheme.shallowWaterBlue; // Surface waters - light blue
    }
  }


  Map<String, dynamic>? _getNextCareerMilestone() {
    return MarineBiologyCareerService.getNextCareerMilestone(widget.cumulativeRP);
  }

  double _getCareerProgress() {
    return MarineBiologyCareerService.getCareerProgress(widget.cumulativeRP);
  }

  String _getCareerProgressText() {
    final nextMilestone = _getNextCareerMilestone();
    if (nextMilestone == null) {
      return 'Max Career Level Reached';
    }

    final required = nextMilestone['requiredRP'] as int;
    final needed = required - widget.cumulativeRP;
    return 'Next: ${nextMilestone['title']} ($needed RP needed)';
  }


  @override
  Widget build(BuildContext context) {
    final depthZoneColor = _getDepthZoneColor();
    final careerProgress = _getCareerProgress();
    final speciesProgress = widget.totalSpeciesInCurrentBiome > 0
        ? widget.speciesDiscoveredInCurrentBiome / widget.totalSpeciesInCurrentBiome
        : 0.0;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          constraints: const BoxConstraints(
            maxWidth: 250,
            minWidth: 180,
            maxHeight: 150,
            minHeight: 120,
          ),
          width: MediaQuery.of(context).size.width * 0.45,
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
              color: OceanTheme.successGreen.withValues(alpha: _glowAnimation.value),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: OceanTheme.successGreen.withValues(alpha: 0.3 * _glowAnimation.value),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Academic header
                Row(
                  children: [
                    Icon(
                      Icons.school,
                      color: OceanTheme.successGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'RESEARCH PROGRESS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                          fontWeight: FontWeight.bold,
                          letterSpacing: ResponsiveHelper.isMobile(context) ? 0.6 : 1.0,
                        ),
                      ),
                    ),
                    // Career level indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: OceanTheme.successGreen.withValues(alpha: 0.2),
                        border: Border.all(
                          color: OceanTheme.successGreen.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${widget.cumulativeRP} RP',
                        style: TextStyle(
                          color: OceanTheme.successGreen,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Career title
                Text(
                  widget.currentCareerTitle,
                  style: TextStyle(
                    color: OceanTheme.successGreen,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // Species progress
                Flexible(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text(
                            '${widget.currentDepthZone}: ${widget.speciesDiscoveredInCurrentBiome}/${widget.totalSpeciesInCurrentBiome}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                            ),
                          ),
                          const SizedBox(height: 2),
                          LinearProgressIndicator(
                            value: speciesProgress.clamp(0.0, 1.0),
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              depthZoneColor, // Use biome color for species discovery
                            ),
                            minHeight: ResponsiveHelper.isMobile(context) ? 2 : 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                  ),
                ),

                const SizedBox(height: 8),

                // Papers and career progression
                Flexible(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Papers: ${widget.researchPapersPublished}',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getCareerProgressText(),
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            LinearProgressIndicator(
                              value: careerProgress.clamp(0.0, 1.0),
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(OceanTheme.successGreen),
                              minHeight: ResponsiveHelper.isMobile(context) ? 2 : 3,
                            ),
                          ],
                        ),
                      ),
                      // Career level badge
                      Container(
                        width: ResponsiveHelper.isMobile(context) ? 32 : 36,
                        height: ResponsiveHelper.isMobile(context) ? 32 : 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              OceanTheme.successGreen.withValues(alpha: 0.8),
                              OceanTheme.successGreen.withValues(alpha: 0.4),
                            ],
                          ),
                          border: Border.all(
                            color: OceanTheme.successGreen,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.school,
                            color: Colors.white,
                            size: ResponsiveHelper.isMobile(context) ? 16 : 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}