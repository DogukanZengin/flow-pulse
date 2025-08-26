import 'package:flutter/material.dart';
import '../models/expedition_result.dart';
import '../../../utils/responsive_helper.dart';

/// Enhanced session results page with research narrative
class SessionResultsPage extends StatefulWidget {
  final ExpeditionResult expeditionResult;
  final AnimationController animationController;

  const SessionResultsPage({
    super.key,
    required this.expeditionResult,
    required this.animationController,
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
      duration: const Duration(milliseconds: 1500),
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
    Future.delayed(const Duration(milliseconds: 500), () {
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
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withValues(alpha: 0.9),
                  Colors.teal.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.cyan.withValues(alpha: 0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hero Metric: Animated Data Points Counter
                _buildHeroMetric(),
                
                const SizedBox(height: 24),
                
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
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.3),
            Colors.orange.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.6), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '🌊 DEEP SEA EXPEDITION',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle'),
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _counterAnimation,
            builder: (context, child) {
              return Text(
                _counterAnimation.value.round().toString(),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                  shadows: [
                    Shadow(
                      color: Colors.amber.withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              );
            },
          ),
          Text(
            'Data Points Collected',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
              color: Colors.white,
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
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle'),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
              color: Colors.white.withValues(alpha: 0.8),
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
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.3),
            Colors.teal.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 0,
            spreadRadius: 0,
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
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _generateCondensedConservationImpact(),
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
              color: Colors.white,
              height: 1.3,
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