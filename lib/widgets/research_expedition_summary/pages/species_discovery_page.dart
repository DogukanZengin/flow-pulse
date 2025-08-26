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
              gradient: LinearGradient(
                colors: [
                  Colors.teal.withValues(alpha: 0.9),
                  Colors.green.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.teal.withValues(alpha: 0.7), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
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
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title'),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                
                // Discovery count
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Your research expedition documented ${widget.expeditionResult.allDiscoveredCreatures.length} marine species, contributing valuable data to ocean conservation efforts.',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                      color: Colors.white,
                      height: 1.5,
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
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Research Impact',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle'),
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Each species documented contributes to our understanding of marine biodiversity and helps protect ocean ecosystems for future generations.',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                            color: Colors.white.withValues(alpha: 0.9),
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