import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/creature.dart';
import '../constants/animation_constants.dart';

/// Enhanced rare creature discovery popup with spotlight effects
class RareCreaturePopup extends StatefulWidget {
  final Creature creature;
  final AnimationController controller;
  final VoidCallback? onComplete;

  const RareCreaturePopup({
    super.key,
    required this.creature,
    required this.controller,
    this.onComplete,
  });

  @override
  State<RareCreaturePopup> createState() => _RareCreaturePopupState();
}

class _RareCreaturePopupState extends State<RareCreaturePopup>
    with TickerProviderStateMixin {
  late AnimationController _spotlightController;
  late AnimationController _swimController;
  late AnimationController _sparkleController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _spotlightController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _swimController = AnimationController(
      duration: const Duration(milliseconds: 2000), // was 3000ms - more exciting movement
      vsync: this,
    )..repeat();
    
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1200), // was 1500ms - faster sparkles
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: widget.controller,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _swimController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));
    
    _spotlightController.forward();
    widget.controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }
  
  @override
  void dispose() {
    _spotlightController.dispose();
    _swimController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        // Darkened background
        AnimatedBuilder(
          animation: _spotlightController,
          builder: (context, child) {
            return Container(
              color: Colors.black.withValues(alpha: 
                _spotlightController.value * 0.7),
            );
          },
        ),
        
        // Spotlight effect
        AnimatedBuilder(
          animation: Listenable.merge([
            _spotlightController,
            _sparkleController,
          ]),
          builder: (context, child) {
            return CustomPaint(
              size: size,
              painter: _SpotlightPainter(
                spotlightProgress: _spotlightController.value,
                glowIntensity: _glowAnimation.value,
                creatureRarity: widget.creature.rarity,
              ),
            );
          },
        ),
        
        // Creature swimming across screen
        Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _scaleAnimation,
              _rotationAnimation,
              widget.controller,
            ]),
            builder: (context, child) {
              final swimOffset = math.sin(widget.controller.value * math.pi * 2) * 100;
              
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scale(_scaleAnimation.value)
                  ..rotateZ(_rotationAnimation.value)
                  ..translate(swimOffset, 0),
                child: _buildCreatureCard(),
              );
            },
          ),
        ),
        
        // Particle effects
        AnimatedBuilder(
          animation: _sparkleController,
          builder: (context, child) {
            return CustomPaint(
              size: size,
              painter: _DiscoveryParticlesPainter(
                sparkleProgress: _sparkleController.value,
                creatureRarity: widget.creature.rarity,
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildCreatureCard() {
    final rarityColor = _getRarityColor(widget.creature.rarity);
    
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            rarityColor.withValues(alpha: 0.9),
            rarityColor.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: rarityColor,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: rarityColor.withValues(alpha: 0.6),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getRarityText(widget.creature.rarity),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          
          // Creature icon with glow
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: _glowAnimation.value * 0.8),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Text(
                  _getCreatureEmoji(widget.creature.type),
                  style: TextStyle(
                    fontSize: 60,
                    shadows: [
                      Shadow(
                        color: Colors.white.withValues(alpha: _glowAnimation.value),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          Text(
            widget.creature.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 4),
          
          Text(
            widget.creature.species,
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.science, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${widget.creature.pearlValue} Research Points',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getRarityColor(CreatureRarity rarity) {
    switch (rarity) {
      case CreatureRarity.common:
        return Colors.green;
      case CreatureRarity.uncommon:
        return Colors.blue;
      case CreatureRarity.rare:
        return Colors.purple;
      case CreatureRarity.legendary:
        return Colors.orange;
    }
  }
  
  String _getRarityText(CreatureRarity rarity) {
    switch (rarity) {
      case CreatureRarity.common:
        return 'COMMON DISCOVERY';
      case CreatureRarity.uncommon:
        return 'UNCOMMON DISCOVERY';
      case CreatureRarity.rare:
        return '✨ RARE DISCOVERY ✨';
      case CreatureRarity.legendary:
        return '🌟 LEGENDARY DISCOVERY 🌟';
    }
  }
  
  String _getCreatureEmoji(CreatureType type) {
    switch (type) {
      case CreatureType.starterFish:
        return '🐠';
      case CreatureType.reefBuilder:
        return '🪸';
      case CreatureType.predator:
        return '🦈';
      case CreatureType.deepSeaDweller:
        return '🐙';
      case CreatureType.mythical:
        return '🌊';
    }
  }
}

/// Spotlight effect painter
class _SpotlightPainter extends CustomPainter {
  final double spotlightProgress;
  final double glowIntensity;
  final CreatureRarity creatureRarity;

  _SpotlightPainter({
    required this.spotlightProgress,
    required this.glowIntensity,
    required this.creatureRarity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3 * spotlightProgress;
    
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.8 * glowIntensity * spotlightProgress),
          Colors.white.withValues(alpha: 0.4 * spotlightProgress),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, paint);
    
    // Secondary spotlight for legendary creatures
    if (creatureRarity == CreatureRarity.legendary) {
      final secondaryPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.4 * spotlightProgress),
            Colors.orange.withValues(alpha: 0.1 * spotlightProgress),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.5));
      
      canvas.drawCircle(center, radius * 1.5, secondaryPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return spotlightProgress != oldDelegate.spotlightProgress ||
           glowIntensity != oldDelegate.glowIntensity;
  }
}

/// Discovery particles painter
class _DiscoveryParticlesPainter extends CustomPainter {
  final double sparkleProgress;
  final CreatureRarity creatureRarity;

  _DiscoveryParticlesPainter({
    required this.sparkleProgress,
    required this.creatureRarity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final particleCount = creatureRarity == CreatureRarity.legendary ? AnimationConstants.discoveryParticleCountLegendary : 
                         creatureRarity == CreatureRarity.rare ? AnimationConstants.discoveryParticleCountRare : AnimationConstants.discoveryParticleCountCommon;
    
    final paint = Paint()
      ..blendMode = BlendMode.plus;
    
    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * math.pi * 2;
      final distance = 100 + sparkleProgress * 150 + random.nextDouble() * 50;
      
      final x = size.width / 2 + math.cos(angle) * distance;
      final y = size.height / 2 + math.sin(angle) * distance;
      
      final opacity = (1 - sparkleProgress) * 0.8;
      final particleSize = 2 + random.nextDouble() * 4;
      
      paint.color = _getParticleColor(creatureRarity).withValues(alpha: opacity);
      
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }
  
  Color _getParticleColor(CreatureRarity rarity) {
    switch (rarity) {
      case CreatureRarity.common:
        return Colors.greenAccent;
      case CreatureRarity.uncommon:
        return Colors.lightBlueAccent;
      case CreatureRarity.rare:
        return Colors.purpleAccent;
      case CreatureRarity.legendary:
        return Colors.orangeAccent;
    }
  }

  @override
  bool shouldRepaint(covariant _DiscoveryParticlesPainter oldDelegate) {
    return sparkleProgress != oldDelegate.sparkleProgress;
  }
}