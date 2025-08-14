import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/aquarium.dart';
import '../models/creature.dart';
import '../models/coral.dart';

class AquariumWidget extends StatefulWidget {
  final Aquarium aquarium;
  final double progress; // 0.0 to 1.0, timer progress
  final bool isRunning;
  final bool isStudySession;
  final List<Creature> visibleCreatures;
  final List<Coral> visibleCorals;
  final VoidCallback onTap;

  const AquariumWidget({
    super.key,
    required this.aquarium,
    required this.progress,
    required this.isRunning,
    required this.isStudySession,
    required this.visibleCreatures,
    required this.visibleCorals,
    required this.onTap,
  });

  @override
  State<AquariumWidget> createState() => _AquariumWidgetState();
}

class _AquariumWidgetState extends State<AquariumWidget>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _bubbleController;
  late List<AnimationController> _fishControllers;
  late List<Animation<Offset>> _fishAnimations;

  @override
  void initState() {
    super.initState();
    
    // Water wave animation
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Bubble animation
    _bubbleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Initialize fish animations
    _initializeFishAnimations();
  }

  void _initializeFishAnimations() {
    _fishControllers = [];
    _fishAnimations = [];

    for (int i = 0; i < widget.visibleCreatures.length; i++) {
      final controller = AnimationController(
        duration: Duration(seconds: 5 + i * 2), // Vary swimming speed
        vsync: this,
      );

      final animation = Tween<Offset>(
        begin: Offset(-0.2, 0.3 + (i * 0.15) % 0.5),
        end: Offset(1.2, 0.3 + (i * 0.15) % 0.5),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.linear,
      ));

      _fishControllers.add(controller);
      _fishAnimations.add(animation);
      
      controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AquariumWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update fish animations if creatures changed
    if (oldWidget.visibleCreatures.length != widget.visibleCreatures.length) {
      for (final controller in _fishControllers) {
        controller.dispose();
      }
      _initializeFishAnimations();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _bubbleController.dispose();
    for (final controller in _fishControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 360,
        height: 360,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _getAquariumGradient(),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipOval(
          child: Stack(
            children: [
              // Background water effect
              _buildWaterBackground(),
              
              // Progress indicator (depth change)
              _buildDepthIndicator(),
              
              // Coral reef
              _buildCoralReef(),
              
              // Swimming creatures
              _buildSwimmingCreatures(),
              
              // Bubbles
              _buildBubbles(),
              
              // Timer and controls overlay
              _buildTimerOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _getAquariumGradient() {
    final biome = widget.aquarium.currentBiome;
    switch (biome) {
      case BiomeType.shallowWaters:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF87CEEB), // Light blue
            Color(0xFF00A6D6), // Tropical blue
            Color(0xFF006994), // Deep blue
          ],
        );
      case BiomeType.coralGarden:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF40E0D0), // Turquoise
            Color(0xFF00CED1), // Dark turquoise
            Color(0xFF008B8B), // Dark cyan
          ],
        );
      case BiomeType.deepOcean:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0077BE), // Deep ocean blue
            Color(0xFF003366), // Navy blue
            Color(0xFF001122), // Very dark blue
          ],
        );
      case BiomeType.abyssalZone:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF191970), // Midnight blue
            Color(0xFF000080), // Navy
            Color(0xFF000000), // Black
          ],
        );
    }
  }

  Widget _buildWaterBackground() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          painter: WaterEffectPainter(
            progress: _waveController.value,
            biome: widget.aquarium.currentBiome,
          ),
          size: const Size(360, 360),
        );
      },
    );
  }

  Widget _buildDepthIndicator() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.1 + (widget.progress * 0.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildCoralReef() {
    return Stack(
      children: widget.visibleCorals.asMap().entries.map((entry) {
        final index = entry.key;
        final coral = entry.value;
        final position = _getCoralPosition(index);
        
        return Positioned(
          left: position.dx,
          bottom: position.dy,
          child: _buildCoral(coral),
        );
      }).toList(),
    );
  }

  Offset _getCoralPosition(int index) {
    final angles = [0.2, 0.8, 0.5, 0.1, 0.9]; // Predefined positions
    final angle = angles[index % angles.length];
    final radius = 120 + (index % 3) * 20; // Vary distance from center
    
    return Offset(
      180 + math.cos(angle * 2 * math.pi) * radius - 20, // Offset for coral width
      20 + math.sin(angle * 2 * math.pi).abs() * 30, // Bottom positioning
    );
  }

  Widget _buildCoral(Coral coral) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: 40 + (coral.growthProgress * 20),
      height: 30 + (coral.growthProgress * 25),
      child: CustomPaint(
        painter: CoralPainter(
          coral: coral,
          isGrowing: widget.isRunning && widget.isStudySession,
        ),
      ),
    );
  }

  Widget _buildSwimmingCreatures() {
    return Stack(
      children: widget.visibleCreatures.asMap().entries.map((entry) {
        final index = entry.key;
        final creature = entry.value;
        
        if (index >= _fishAnimations.length) return const SizedBox.shrink();
        
        return AnimatedBuilder(
          animation: _fishAnimations[index],
          builder: (context, child) {
            return Positioned(
              left: _fishAnimations[index].value.dx * 320 - 20,
              top: _fishAnimations[index].value.dy * 320,
              child: _buildCreature(creature, index),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildCreature(Creature creature, int index) {
    return Container(
      width: 40,
      height: 30,
      child: CustomPaint(
        painter: CreaturePainter(
          creature: creature,
          swimDirection: _fishAnimations[index].value.dx > 0.5 ? 1 : -1,
        ),
      ),
    );
  }

  Widget _buildBubbles() {
    return AnimatedBuilder(
      animation: _bubbleController,
      builder: (context, child) {
        return CustomPaint(
          painter: BubblePainter(
            progress: _bubbleController.value,
            isActive: widget.isRunning,
          ),
          size: const Size(360, 360),
        );
      },
    );
  }

  Widget _buildTimerOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pearl count at top
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💎', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '${widget.aquarium.pearlWallet.pearls}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Play/Pause button with ocean theme
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  widget.isStudySession 
                    ? Colors.teal.withOpacity(0.8)
                    : Colors.orange.withOpacity(0.8),
                  widget.isStudySession 
                    ? Colors.cyan.withOpacity(0.8)
                    : Colors.red.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isStudySession 
                    ? Colors.teal.withOpacity(0.4)
                    : Colors.orange.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              widget.isRunning ? Icons.pause : Icons.play_arrow,
              size: 36,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Current biome indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.aquarium.currentBiome.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const Spacer(),
        ],
      ),
    );
  }
}

// Custom painters for aquarium elements
class WaterEffectPainter extends CustomPainter {
  final double progress;
  final BiomeType biome;

  WaterEffectPainter({required this.progress, required this.biome});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw gentle water movement
    final path = Path();
    for (double i = 0; i < size.width; i += 5) {
      final y = size.height * 0.3 + 
                 math.sin((i / size.width * 4 * math.pi) + (progress * 2 * math.pi)) * 8;
      if (i == 0) {
        path.moveTo(i, y);
      } else {
        path.lineTo(i, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WaterEffectPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class CoralPainter extends CustomPainter {
  final Coral coral;
  final bool isGrowing;

  CoralPainter({required this.coral, required this.isGrowing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _getCoralColor()
      ..style = PaintingStyle.fill;

    // Draw coral based on type
    switch (coral.type) {
      case CoralType.brain:
        _drawBrainCoral(canvas, size, paint);
        break;
      case CoralType.staghorn:
        _drawStaghornCoral(canvas, size, paint);
        break;
      case CoralType.table:
        _drawTableCoral(canvas, size, paint);
        break;
      case CoralType.soft:
        _drawSoftCoral(canvas, size, paint);
        break;
      case CoralType.fire:
        _drawFireCoral(canvas, size, paint);
        break;
    }

    // Add growing effect
    if (isGrowing) {
      final glowPaint = Paint()
        ..color = _getCoralColor().withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width / 2,
        glowPaint,
      );
    }
  }

  Color _getCoralColor() {
    switch (coral.type) {
      case CoralType.brain:
        return Colors.pink.withOpacity(0.8);
      case CoralType.staghorn:
        return Colors.orange.withOpacity(0.8);
      case CoralType.table:
        return Colors.brown.withOpacity(0.8);
      case CoralType.soft:
        return Colors.purple.withOpacity(0.8);
      case CoralType.fire:
        return Colors.red.withOpacity(0.8);
    }
  }

  void _drawBrainCoral(Canvas canvas, Size size, Paint paint) {
    // Simple rounded coral shape
    canvas.drawOval(
      Rect.fromLTWH(0, size.height * 0.3, size.width, size.height * 0.7),
      paint,
    );
  }

  void _drawStaghornCoral(Canvas canvas, Size size, Paint paint) {
    // Branch-like coral
    final path = Path();
    path.moveTo(size.width * 0.5, size.height);
    path.lineTo(size.width * 0.3, size.height * 0.3);
    path.lineTo(size.width * 0.7, size.height * 0.3);
    path.lineTo(size.width * 0.5, size.height);
    
    paint.strokeWidth = 8;
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  void _drawTableCoral(Canvas canvas, Size size, Paint paint) {
    // Flat table-like coral
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3),
      paint,
    );
  }

  void _drawSoftCoral(Canvas canvas, Size size, Paint paint) {
    // Wavy soft coral
    final path = Path();
    path.moveTo(size.width * 0.2, size.height);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.2, size.width * 0.8, size.height);
    
    paint.strokeWidth = 15;
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  void _drawFireCoral(Canvas canvas, Size size, Paint paint) {
    // Spiky fire coral
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final x = (i / 4) * size.width;
      path.moveTo(x, size.height);
      path.lineTo(x, size.height * 0.2);
    }
    
    paint.strokeWidth = 6;
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CoralPainter oldDelegate) {
    return oldDelegate.coral != coral || oldDelegate.isGrowing != isGrowing;
  }
}

class CreaturePainter extends CustomPainter {
  final Creature creature;
  final int swimDirection; // 1 for right, -1 for left

  CreaturePainter({required this.creature, required this.swimDirection});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _getCreatureColor()
      ..style = PaintingStyle.fill;

    // Save canvas state for flipping
    canvas.save();
    
    if (swimDirection < 0) {
      // Flip horizontally for left swimming
      canvas.scale(-1, 1);
      canvas.translate(-size.width, 0);
    }

    // Draw simple fish shape
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.2, size.width * 0.8, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.8, size.width * 0.2, size.height * 0.5);
    
    // Tail
    path.moveTo(0, size.height * 0.3);
    path.lineTo(size.width * 0.2, size.height * 0.5);
    path.lineTo(0, size.height * 0.7);
    
    canvas.drawPath(path, paint);

    // Eye
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.4),
      3,
      eyePaint,
    );
    
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.4),
      1.5,
      pupilPaint,
    );

    canvas.restore();
  }

  Color _getCreatureColor() {
    switch (creature.rarity) {
      case CreatureRarity.common:
        return Colors.blue;
      case CreatureRarity.uncommon:
        return Colors.green;
      case CreatureRarity.rare:
        return Colors.purple;
      case CreatureRarity.legendary:
        return Colors.amber;
    }
  }

  @override
  bool shouldRepaint(CreaturePainter oldDelegate) {
    return oldDelegate.creature != creature || oldDelegate.swimDirection != swimDirection;
  }
}

class BubblePainter extends CustomPainter {
  final double progress;
  final bool isActive;

  BubblePainter({required this.progress, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) return;

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Draw bubbles at different positions
    final bubblePositions = [
      Offset(size.width * 0.3, size.height * 0.8),
      Offset(size.width * 0.7, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.9),
    ];

    for (int i = 0; i < bubblePositions.length; i++) {
      final pos = bubblePositions[i];
      final bubbleProgress = (progress + i * 0.3) % 1.0;
      final y = pos.dy - (bubbleProgress * size.height * 0.8);
      
      if (y > 0) {
        canvas.drawCircle(
          Offset(pos.dx, y),
          2 + (bubbleProgress * 3),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(BubblePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isActive != isActive;
  }
}