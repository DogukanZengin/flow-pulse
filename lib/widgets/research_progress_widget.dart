import 'package:flutter/material.dart';
import '../themes/ocean_theme.dart';
import '../utils/responsive_helper.dart';
import '../services/depth_traversal_service.dart';

/// Marine biology research progress display
/// Shows current RP, career title, species discovered in current biome, papers published, and session depth progress
class ResearchProgressWidget extends StatefulWidget {
  final int speciesDiscoveredInCurrentBiome;
  final int totalSpeciesInCurrentBiome;
  final int totalSpeciesDiscovered; // For reference/tooltip
  final int researchPapersPublished;
  final int cumulativeRP;
  final String currentDepthZone;
  final String currentCareerTitle;
  final int secondsElapsed; // Current session elapsed time in seconds
  final int totalSessionSeconds; // Total session duration in seconds

  const ResearchProgressWidget({
    super.key,
    required this.speciesDiscoveredInCurrentBiome,
    required this.totalSpeciesInCurrentBiome,
    required this.totalSpeciesDiscovered,
    required this.researchPapersPublished,
    required this.cumulativeRP,
    required this.currentDepthZone,
    required this.currentCareerTitle,
    required this.secondsElapsed,
    required this.totalSessionSeconds,
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

  IconData _getDepthZoneIcon() {
    switch (widget.currentDepthZone) {
      case 'Abyssal Zone':
        return Icons.water_drop; // Deep abyss
      case 'Deep Ocean':
        return Icons.waves; // Deep waters
      case 'Coral Garden':
        return Icons.filter_vintage; // Coral reef
      case 'Shallow Waters':
      default:
        return Icons.wb_sunny; // Surface waters
    }
  }

  double _getCurrentDepth() {
    // Use the actual RP-based depth calculation system
    final elapsedTime = Duration(seconds: widget.secondsElapsed);
    return DepthTraversalService.calculateCurrentDepth(elapsedTime, widget.cumulativeRP);
  }

  double _getMaxDepth() {
    // Calculate max depth for full session
    final totalTime = Duration(seconds: widget.totalSessionSeconds);
    return DepthTraversalService.calculateCurrentDepth(totalTime, widget.cumulativeRP);
  }

  double _getSessionDepthProgress() {
    final maxDepth = _getMaxDepth();
    if (maxDepth <= 0) return 0.0;

    final currentDepth = _getCurrentDepth();
    return (currentDepth / maxDepth).clamp(0.0, 1.0);
  }

  String _getDepthStatus() {
    final currentDepth = _getCurrentDepth();
    final maxDepth = _getMaxDepth();
    return '${currentDepth.toStringAsFixed(1)}/${maxDepth.toStringAsFixed(1)}m';
  }


  @override
  Widget build(BuildContext context) {
    final depthZoneColor = _getDepthZoneColor();
    final sessionDepthProgress = _getSessionDepthProgress();
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
              color: depthZoneColor.withValues(alpha: _glowAnimation.value),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: depthZoneColor.withValues(alpha: 0.3 * _glowAnimation.value),
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
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.science,
                      color: depthZoneColor,
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
                  ],
                ),

                const SizedBox(height: 4),

                // RP and career title
                Text(
                  '${widget.cumulativeRP} RP: ${widget.currentCareerTitle}',
                  style: TextStyle(
                    color: depthZoneColor,
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
                              OceanTheme.successGreen,
                            ),
                            minHeight: ResponsiveHelper.isMobile(context) ? 2 : 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Papers and depth zone progress
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
                            const SizedBox(height: 2),
                            Text(
                              'Depth: ${_getDepthStatus()}',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                              ),
                            ),
                            const SizedBox(height: 2),
                            LinearProgressIndicator(
                              value: sessionDepthProgress.clamp(0.0, 1.0),
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(depthZoneColor),
                              minHeight: ResponsiveHelper.isMobile(context) ? 2 : 3,
                            ),
                          ],
                        ),
                      ),
                      // Depth zone badge
                      Container(
                        width: ResponsiveHelper.isMobile(context) ? 32 : 36,
                        height: ResponsiveHelper.isMobile(context) ? 32 : 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              depthZoneColor.withValues(alpha: 0.8),
                              depthZoneColor.withValues(alpha: 0.4),
                            ],
                          ),
                          border: Border.all(
                            color: depthZoneColor,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _getDepthZoneIcon(),
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