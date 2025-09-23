import 'package:flutter/material.dart';
import '../models/expedition_result.dart';
import '../models/achievement_hierarchy.dart' as hierarchy;
import '../../../utils/responsive_helper.dart';

/// Enhanced session results page with research narrative
class SessionResultsPage extends StatefulWidget {
  final ExpeditionResult expeditionResult;
  final AnimationController animationController;
  final hierarchy.AchievementClassification? achievementHierarchy;

  const SessionResultsPage({
    super.key,
    required this.expeditionResult,
    required this.animationController,
    this.achievementHierarchy,
  });

  @override
  State<SessionResultsPage> createState() => _SessionResultsPageState();
}

class _SessionResultsPageState extends State<SessionResultsPage>
    with TickerProviderStateMixin {
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _counterController;
  late Animation<double> _counterAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startCounterAnimation();
  }

  void _initializeAnimations() {
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeOutBack,
    ));

    _counterController = AnimationController(
      duration: const Duration(milliseconds: 1000), // was 1500ms - faster counter
      vsync: this,
    );

    _counterAnimation = Tween<double>(
      begin: 0.0,
      end: widget.expeditionResult.dataPointsCollected.toDouble(),
    ).animate(CurvedAnimation(
      parent: _counterController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startCounterAnimation() {
    Future.delayed(const Duration(milliseconds: 300), () { // was 500ms - faster start
      if (mounted) {
        _counterController.forward();
      }
    });
  }

  @override
  void dispose() {
    _counterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              // Enhanced background overlay for text readability
              color: Colors.black.withValues(alpha: 0.85), // High opacity for text protection
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.cyan.withValues(alpha: 0.8), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 25,
                  spreadRadius: 8,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.cyan.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Achievement Hierarchy Hero or fallback to original hero metric
                widget.achievementHierarchy != null
                    ? hierarchy.AchievementHierarchy.buildHeroAchievement(
                        widget.achievementHierarchy!.primary,
                        widget.expeditionResult,
                      )
                    : _buildHeroMetric(),

                const SizedBox(height: 24),

                // Secondary achievements (if using hierarchy)
                if (widget.achievementHierarchy != null &&
                    widget.achievementHierarchy!.secondary.isNotEmpty) ...[
                  hierarchy.AchievementHierarchy.buildSecondaryAchievements(
                    widget.achievementHierarchy!.secondary,
                    widget.expeditionResult,
                  ),
                  const SizedBox(height: 20),
                ],

                // Quick Stats Bar
                _buildQuickStats(),

                const SizedBox(height: 20),

                // Condensed Research Impact
                _buildResearchImpact(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildHeroMetric() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Enhanced contrast for hero metric
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.8),
            const Color(0xFF0B1426).withValues(alpha: 0.85), // Deep ocean color
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.8), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '🌊 DEEP SEA EXPEDITION',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle') * 1.2, // Increased size
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFD700), // Gold color for better contrast
              shadows: const [
                Shadow(
                  color: Color(0x80000000),
                  blurRadius: 4.0,
                  offset: Offset(0, 2),
                ),
                Shadow(
                  color: Color(0x40000000),
                  blurRadius: 8.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _counterAnimation,
            builder: (context, child) {
              return Text(
                _counterAnimation.value.round().toString(),
                style: TextStyle(
                  fontSize: 56, // Increased for hero emphasis
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700), // Bright gold
                  shadows: const [
                    Shadow(
                      color: Color(0x90000000),
                      blurRadius: 6.0,
                      offset: Offset(0, 3),
                    ),
                    Shadow(
                      color: Color(0xFFFFD700),
                      blurRadius: 15.0,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              );
            },
          ),
          Text(
            'Data Points Collected',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body') * 1.1,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE3F2FD), // Light blue for secondary text
              shadows: const [
                Shadow(
                  color: Color(0x80000000),
                  blurRadius: 3.0,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final expeditionResult = widget.expeditionResult;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildQuickStatItem(
          icon: Icons.schedule,
          value: '${expeditionResult.sessionDurationMinutes}m',
          label: 'Duration',
          color: Colors.blue,
        ),
        _buildQuickStatItem(
          icon: Icons.straighten,
          value: '${expeditionResult.sessionDepthReached.toStringAsFixed(1)}m',
          label: 'Depth',
          color: Colors.cyan,
        ),
        _buildQuickStatItem(
          icon: Icons.star,
          value: expeditionResult.qualityAssessment.researchGrade,
          label: 'Grade',
          color: expeditionResult.qualityAssessment.gradeColor,
        ),
      ],
    );
  }

  Widget _buildQuickStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75), // Darker background for contrast
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle') * 1.15,
              fontWeight: FontWeight.bold,
              color: color,
              shadows: const [
                Shadow(
                  color: Color(0x80000000),
                  blurRadius: 3.0,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption') * 1.1,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFFFFFFF), // Pure white for better readability
              shadows: const [
                Shadow(
                  color: Color(0x80000000),
                  blurRadius: 2.0,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResearchImpact() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // High contrast background for conservation impact text
        color: const Color(0xFF0B1426).withValues(alpha: 0.9), // Deep ocean color
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.eco, color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Text(
                'CONSERVATION IMPACT',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption') * 1.2,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4CAF50), // Bright green for visibility
                  letterSpacing: 0.5,
                  shadows: const [
                    Shadow(
                      color: Color(0x80000000),
                      blurRadius: 3.0,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _generateCondensedConservationImpact(),
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'), // Increased from caption
              fontWeight: FontWeight.w500,
              color: const Color(0xFFFFFFFF), // Pure white
              height: 1.4, // Better line spacing
              shadows: const [
                Shadow(
                  color: Color(0x90000000),
                  blurRadius: 3.0,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _generateCondensedConservationImpact() {
    final sessionMinutes = widget.expeditionResult.sessionDurationMinutes;
    
    // Condensed impact statements (50% shorter as per UX recommendation)
    if (sessionMinutes >= 45) {
      return 'Your expedition data helps protect marine habitats for thousands of species.';
    } else if (sessionMinutes >= 25) {
      return 'Coral reef research like yours improved reef health by 18% in protected areas.';
    } else {
      return 'Every data point helps scientists protect ocean biodiversity.';
    }
  }

}