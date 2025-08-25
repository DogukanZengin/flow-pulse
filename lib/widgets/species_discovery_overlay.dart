import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/creature.dart';
import '../themes/ocean_theme.dart';
import '../utils/responsive_helper.dart';

/// Full-screen discovery celebration overlay according to Master Plan
class SpeciesDiscoveryOverlay extends StatefulWidget {
  final Creature discoveredCreature;
  final VoidCallback onDismiss;
  final VoidCallback? onAddToJournal;

  const SpeciesDiscoveryOverlay({
    super.key,
    required this.discoveredCreature,
    required this.onDismiss,
    this.onAddToJournal,
  });

  @override
  State<SpeciesDiscoveryOverlay> createState() => _SpeciesDiscoveryOverlayState();
}

class _SpeciesDiscoveryOverlayState extends State<SpeciesDiscoveryOverlay>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _sparkleController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize animations
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.linear,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
    _sparkleController.repeat();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  Color _getRarityColor() {
    switch (widget.discoveredCreature.rarity) {
      case CreatureRarity.common:
        return OceanTheme.commonGreen;
      case CreatureRarity.uncommon:
        return OceanTheme.uncommonBlue;
      case CreatureRarity.rare:
        return OceanTheme.rarePurple;
      case CreatureRarity.legendary:
        return OceanTheme.legendaryOrange;
    }
  }

  String _getRarityStars() {
    switch (widget.discoveredCreature.rarity) {
      case CreatureRarity.common:
        return '⭐';
      case CreatureRarity.uncommon:
        return '⭐⭐';
      case CreatureRarity.rare:
        return '⭐⭐⭐';
      case CreatureRarity.legendary:
        return '⭐⭐⭐⭐';
    }
  }

  String _getRarityTitle() {
    switch (widget.discoveredCreature.rarity) {
      case CreatureRarity.common:
        return '🐠 NEW DISCOVERY! 🐠';
      case CreatureRarity.uncommon:
        return '🌟 UNCOMMON FIND! 🌟';
      case CreatureRarity.rare:
        return '💎 RARE SPECIES! 💎';
      case CreatureRarity.legendary:
        return '✨ LEGENDARY! ✨';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final rarityColor = _getRarityColor();

    return Scaffold(
      backgroundColor: OceanTheme.overlayBackground,
      body: AnimatedBuilder(
        animation: Listenable.merge([_fadeAnimation, _slideAnimation, _scaleAnimation, _sparkleAnimation]),
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Stack(
              children: [
                // Animated background particles
                ...List.generate(50, (index) {
                  final random = (index * 0.1 + _sparkleAnimation.value) % 1.0;
                  final x = (index * 37) % screenSize.width;
                  final y = (index * 73 + _sparkleAnimation.value * 100) % screenSize.height;
                  return Positioned(
                    left: x,
                    top: y,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: rarityColor.withValues(alpha: random * 0.7),
                      ),
                    ),
                  );
                }),

                // Main discovery card
                Center(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: ResponsiveHelper.isMobile(context) ? screenSize.width * 0.95 : screenSize.width * 0.9,
                        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'screen')),
                        margin: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'card')),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF1A237E).withValues(alpha: 0.95),
                              const Color(0xFF3F51B5).withValues(alpha: 0.95),
                              rarityColor.withValues(alpha: 0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: rarityColor.withValues(alpha: 0.7),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: rarityColor.withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title with sparkle effect
                            AnimatedBuilder(
                              animation: _sparkleController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1.0 + (0.05 * math.sin(_sparkleController.value * 2 * math.pi)),
                                  child: Text(
                                    _getRarityTitle(),
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'title'),
                                      fontWeight: FontWeight.bold,
                                      color: rarityColor,
                                      shadows: [
                                        Shadow(
                                          color: rarityColor.withValues(alpha: 0.8),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),

                            // Creature icon/representation
                            Container(
                              width: ResponsiveHelper.isMobile(context) ? 100 : 120,
                              height: ResponsiveHelper.isMobile(context) ? 100 : 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    rarityColor.withValues(alpha: 0.3),
                                    rarityColor.withValues(alpha: 0.1),
                                  ],
                                ),
                                border: Border.all(
                                  color: rarityColor.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: AnimatedBuilder(
                                  animation: _sparkleController,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _sparkleController.value * 0.1,
                                      child: Text(
                                        _getCreatureEmoji(),
                                        style: TextStyle(fontSize: ResponsiveHelper.getIconSize(context, 'hero')),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),

                            // Creature name
                            Text(
                              widget.discoveredCreature.name,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'hero'),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),

                            // Scientific name
                            Text(
                              widget.discoveredCreature.species,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle'),
                                fontStyle: FontStyle.italic,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),

                            // Rarity indicator
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getResponsiveSpacing(context, 'card'), vertical: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
                              decoration: BoxDecoration(
                                color: rarityColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: rarityColor.withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Rarity: ${widget.discoveredCreature.rarity.displayName} ${_getRarityStars()}',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                                  fontWeight: FontWeight.w600,
                                  color: rarityColor,
                                ),
                              ),
                            ),

                            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),

                            // Habitat info
                            Text(
                              'Habitat: ${widget.discoveredCreature.habitat.displayName}',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                                color: Colors.white,
                              ),
                            ),

                            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),

                            // Description
                            Text(
                              widget.discoveredCreature.description,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),

                            // Research value
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getResponsiveSpacing(context, 'card'), vertical: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.amber.withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('💎', style: TextStyle(fontSize: 16)),
                                  SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
                                  Text(
                                    'Research Value: +${widget.discoveredCreature.pearlValue} XP',
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'screen')),

                            // Action buttons
                            Row(
                              children: [
                                if (widget.onAddToJournal != null)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: widget.onAddToJournal,
                                      icon: const Icon(Icons.book, color: Colors.white),
                                      label: Text(
                                        'Add to Journal',
                                        style: TextStyle(color: Colors.white, fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body')),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal,
                                        padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (widget.onAddToJournal != null) const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: widget.onDismiss,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: rarityColor,
                                      padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: const Text(
                                      'Continue Research',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getCreatureEmoji() {
    // Return appropriate emoji based on creature type/habitat
    switch (widget.discoveredCreature.habitat) {
      case BiomeType.shallowWaters:
        return '🐠'; // Tropical fish
      case BiomeType.coralGarden:
        return '🐟'; // Fish
      case BiomeType.deepOcean:
        return '🦈'; // Shark
      case BiomeType.abyssalZone:
        return '🐙'; // Octopus
    }
  }
}

/// Real-time species detection panel (appears during sessions)
class SpeciesDetectionPanel extends StatefulWidget {
  final Creature? detectedCreature;
  final double estimatedTimeSeconds;
  final VoidCallback? onFocusToApproach;

  const SpeciesDetectionPanel({
    super.key,
    this.detectedCreature,
    required this.estimatedTimeSeconds,
    this.onFocusToApproach,
  });

  @override
  State<SpeciesDetectionPanel> createState() => _SpeciesDetectionPanelState();
}

class _SpeciesDetectionPanelState extends State<SpeciesDetectionPanel>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'card')),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A237E).withValues(alpha: 0.9),
                const Color(0xFF3F51B5).withValues(alpha: 0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.cyan.withValues(alpha: _pulseAnimation.value),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.withValues(alpha: 0.3 * _pulseAnimation.value),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.radar,
                    color: Colors.cyan.withValues(alpha: _pulseAnimation.value),
                    size: 20,
                  ),
                  SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
                  Text(
                    '🔍 SPECIES DETECTED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
              
              if (widget.detectedCreature != null) ...[
                Text(
                  'Sonar Contact: ${widget.detectedCreature!.name}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Species: ${widget.detectedCreature!.species}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ] else ...[
                const Text(
                  'Sonar Contact: Unknown Species',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Species: Unidentified',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
              
              // Focus to approach button
              if (widget.onFocusToApproach != null)
                ElevatedButton.icon(
                  onPressed: widget.onFocusToApproach,
                  icon: Icon(Icons.center_focus_strong, color: Colors.white, size: ResponsiveHelper.getIconSize(context, 'medium')),
                  label: Text(
                    '🎯 Focus to Approach',
                    style: TextStyle(color: Colors.white, fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body')),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
              
              // Estimated time
              Text(
                'Estimated in: ${_formatTime(widget.estimatedTimeSeconds)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}