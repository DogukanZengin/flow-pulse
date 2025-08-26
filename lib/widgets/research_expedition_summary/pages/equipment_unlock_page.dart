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
              // High-contrast background for grand finale
              color: Colors.black.withValues(alpha: 0.85), // High opacity for text protection
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.indigo.withValues(alpha: 0.8), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 25,
                  spreadRadius: 8,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.indigo.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
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
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title') * 1.3,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFD700), // Bright gold for completion
                    letterSpacing: 0.5,
                    shadows: const [
                      Shadow(
                        color: Color(0x80000000),
                        blurRadius: 4.0,
                        offset: Offset(0, 2),
                      ),
                      Shadow(
                        color: Color(0xFFFFD700),
                        blurRadius: 20.0,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                
                // Summary stats
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75), // Better contrast
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.indigo.withValues(alpha: 0.5), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle') * 1.2,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFC107), // Bright amber
                      letterSpacing: 0.4,
                      shadows: const [
                        Shadow(
                          color: Color(0x80000000),
                          blurRadius: 3.0,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.expeditionResult.unlockedEquipment.map((equipment) =>
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B004D).withValues(alpha: 0.8), // Deep purple ocean
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.5), width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(equipment.icon, color: Colors.orange, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              equipment.name,
                              style: TextStyle(
                                color: const Color(0xFFFFFFFF), // Pure white
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body') * 1.1,
                                fontWeight: FontWeight.w600,
                                shadows: const [
                                  Shadow(
                                    color: Color(0x80000000),
                                    blurRadius: 2.0,
                                    offset: Offset(0, 1),
                                  ),
                                ],
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
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body') * 1.1,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFE3F2FD), // Light blue for readability
                    height: 1.5,
                    letterSpacing: 0.3,
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
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title') * 1.2,
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
            color: const Color(0xFFE3F2FD), // Light blue for secondary text
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
    );
  }
}