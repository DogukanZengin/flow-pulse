import 'package:flutter/material.dart';
import '../models/expedition_result.dart';
import '../../../utils/responsive_helper.dart';

/// Equipment unlock and final summary page
class EquipmentUnlockPage extends StatefulWidget {
  final ExpeditionResult expeditionResult;
  final AnimationController animationController;
  final VoidCallback onComplete;
  final VoidCallback? onSurfaceForBreak;

  const EquipmentUnlockPage({
    super.key,
    required this.expeditionResult,
    required this.animationController,
    required this.onComplete,
    this.onSurfaceForBreak,
  });

  @override
  State<EquipmentUnlockPage> createState() => _EquipmentUnlockPageState();
}

class _EquipmentUnlockPageState extends State<EquipmentUnlockPage> {
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.bounceOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withValues(alpha: 0.9),
                  Colors.indigo.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.purple.withValues(alpha: 0.7), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Completion header
                Text(
                  widget.expeditionResult.hasSignificantAccomplishments
                      ? '🏆 EXPEDITION COMPLETE!'
                      : '⚓ RESEARCH COMPLETE',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title'),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                
                // Summary stats
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSummaryItem('Data Points', '${widget.expeditionResult.dataPointsCollected}', Colors.green),
                      _buildSummaryItem('Streak', '${widget.expeditionResult.currentStreak}', Colors.orange),
                      _buildSummaryItem('Grade', widget.expeditionResult.qualityAssessment.researchGrade, Colors.cyan),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Equipment unlocks (if any)
                if (widget.expeditionResult.unlockedEquipment.isNotEmpty) ...[
                  Text(
                    '🔬 RESEARCH STATION UPGRADED',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle'),
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.expeditionResult.unlockedEquipment.map((equipment) =>
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(equipment.icon, color: Colors.orange, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              equipment.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                
                // Final message
                Text(
                  widget.expeditionResult.hasSignificantAccomplishments
                      ? '🌊 Outstanding research session! Your contributions help protect marine life and advance ocean science.'
                      : '✅ Research session completed successfully. Every data point makes a difference for ocean conservation.',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  children: [
                    if (widget.onSurfaceForBreak != null) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onSurfaceForBreak,
                          icon: const Icon(Icons.wb_sunny, color: Colors.orange),
                          label: const Text('Surface for Break', style: TextStyle(color: Colors.orange)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.orange, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onComplete,
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text('Continue Research', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title'),
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