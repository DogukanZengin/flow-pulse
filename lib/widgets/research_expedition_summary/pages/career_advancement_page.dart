import 'package:flutter/material.dart';
import '../models/expedition_result.dart';
import '../../../utils/responsive_helper.dart';

/// Career advancement page with marine biology progression
class CareerAdvancementPage extends StatefulWidget {
  final ExpeditionResult expeditionResult;
  final AnimationController animationController;

  const CareerAdvancementPage({
    super.key,
    required this.expeditionResult,
    required this.animationController,
  });

  @override
  State<CareerAdvancementPage> createState() => _CareerAdvancementPageState();
}

class _CareerAdvancementPageState extends State<CareerAdvancementPage> {
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
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.elasticOut,
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
              // High-contrast background for career advancement
              color: Colors.black.withValues(alpha: 0.85), // High opacity for text protection
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.purple.withValues(alpha: 0.8), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 25,
                  spreadRadius: 8,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hero Achievement - Career Title
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // Enhanced contrast for hero achievement
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        const Color(0xFF1B004D).withValues(alpha: 0.85), // Deep purple ocean
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.purple.withValues(alpha: 0.8), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.emoji_events, color: const Color(0xFFFFD700), size: 36), // Brighter gold
                      const SizedBox(height: 8),
                      Text(
                        'PROMOTION EARNED',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle') * 1.2,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFD700), // Bright gold
                          letterSpacing: 0.5,
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
                      const SizedBox(height: 8),
                      Text(
                        widget.expeditionResult.careerProgression.title,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title') * 1.3,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFFFFF), // Pure white
                          shadows: const [
                            Shadow(
                              color: Color(0x90000000),
                              blurRadius: 6.0,
                              offset: Offset(0, 3),
                            ),
                            Shadow(
                              color: Color(0xFFB388FF), // Light purple glow
                              blurRadius: 15.0,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                if (widget.expeditionResult.careerAdvancementNarrative != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1426).withValues(alpha: 0.9), // Deep ocean background
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.withValues(alpha: 0.6), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      _getCondensedNarrative(widget.expeditionResult.careerAdvancementNarrative!),
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body') * 1.1,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFE3F2FD), // Light blue for readability
                        height: 1.4,
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
                  ),
                  const SizedBox(height: 20),
                ],
                
                // Career level display
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.expeditionResult.careerProgression.title,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title'),
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.expeditionResult.careerProgression.description,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Research Capabilities:',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle'),
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.expeditionResult.careerProgression.researchCapabilities,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                          color: Colors.white.withValues(alpha: 0.9),
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

  String _getCondensedNarrative(String fullNarrative) {
    // Extract key impact statement from the narrative (50% reduction)
    final parts = fullNarrative.split('\n\n');
    if (parts.length >= 2) {
      // Take the impact statement (usually the second paragraph)
      return parts[1].trim();
    } else {
      // If no multiple paragraphs, take first sentence
      final sentences = fullNarrative.split('. ');
      return sentences.isNotEmpty ? '${sentences[0]}.' : fullNarrative;
    }
  }
}