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

class _SessionResultsPageState extends State<SessionResultsPage> {
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
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
                // Research narrative header
                Text(
                  '📊 RESEARCH DATA COLLECTED',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title'),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                
                // Research narrative
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.expeditionResult.researchNarrative,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                      color: Colors.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Data points display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      icon: Icons.science,
                      label: 'Data Points',
                      value: '${widget.expeditionResult.dataPointsCollected}',
                      color: Colors.green,
                    ),
                    _buildStatItem(
                      icon: Icons.schedule,
                      label: 'Duration',
                      value: '${widget.expeditionResult.sessionDurationMinutes}m',
                      color: Colors.blue,
                    ),
                    _buildStatItem(
                      icon: Icons.straighten,
                      label: 'Max Depth',
                      value: '${widget.expeditionResult.sessionDepthReached.toStringAsFixed(1)}m',
                      color: Colors.cyan,
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Research quality assessment
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.expeditionResult.qualityAssessment.gradeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.expeditionResult.qualityAssessment.gradeColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Research Grade: ${widget.expeditionResult.qualityAssessment.researchGrade}',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle'),
                          fontWeight: FontWeight.bold,
                          color: widget.expeditionResult.qualityAssessment.gradeColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.expeditionResult.qualityAssessment.qualityNarrative,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
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
    );
  }
}