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
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withValues(alpha: 0.9),
                  Colors.orange.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.7), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Advancement header
                Text(
                  '🎓 CAREER ADVANCEMENT',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title'),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                
                if (widget.expeditionResult.careerAdvancementNarrative != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.expeditionResult.careerAdvancementNarrative!,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                        color: Colors.white,
                        height: 1.5,
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
}