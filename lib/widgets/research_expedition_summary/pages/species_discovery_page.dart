import 'package:flutter/material.dart';
import '../models/expedition_result.dart';
import '../../../utils/responsive_helper.dart';

/// Species discovery page with creature narratives
class SpeciesDiscoveryPage extends StatefulWidget {
  final ExpeditionResult expeditionResult;
  final AnimationController animationController;

  const SpeciesDiscoveryPage({
    super.key,
    required this.expeditionResult,
    required this.animationController,
  });

  @override
  State<SpeciesDiscoveryPage> createState() => _SpeciesDiscoveryPageState();
}

class _SpeciesDiscoveryPageState extends State<SpeciesDiscoveryPage> {
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
      begin: const Offset(-0.5, 0),
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
              // High-contrast background for species discovery
              color: Colors.black.withValues(alpha: 0.85), // High opacity for text protection
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.teal.withValues(alpha: 0.8), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 25,
                  spreadRadius: 8,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.teal.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Discovery header
                Text(
                  '🐠 SPECIES DISCOVERED',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title') * 1.3,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00E5FF), // Bright cyan for marine theme
                    letterSpacing: 0.5,
                    shadows: const [
                      Shadow(
                        color: Color(0x80000000),
                        blurRadius: 4.0,
                        offset: Offset(0, 2),
                      ),
                      Shadow(
                        color: Color(0xFF00E5FF),
                        blurRadius: 15.0,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                
                // Discovery count
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1426).withValues(alpha: 0.9), // Deep ocean background
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.withValues(alpha: 0.6), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Your research expedition documented ${widget.expeditionResult.allDiscoveredCreatures.length} marine species, contributing valuable data to ocean conservation efforts.',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body') * 1.15,
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
                ),
                
                const SizedBox(height: 20),
                
                // Discoveries list (simplified for now)
                if (widget.expeditionResult.discoveryNarratives.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75), // Better contrast for inner container
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.5), width: 1),
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
                        Text(
                          'Research Impact',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle') * 1.2,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4CAF50), // Bright green
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
                        Text(
                          'Each species documented contributes to our understanding of marine biodiversity and helps protect ocean ecosystems for future generations.',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body') * 1.1,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFFFFFFF), // Pure white for maximum contrast
                            height: 1.4,
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
                  ),
                
                const SizedBox(height: 20),
                
                // Total research value
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.eco, color: Colors.green, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Conservation Impact: +${widget.expeditionResult.totalResearchValue} points',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle'),
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
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
}