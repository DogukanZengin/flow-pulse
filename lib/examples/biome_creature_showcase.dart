import 'package:flutter/material.dart';
import '../models/creature.dart';
import '../rendering/simple_biome_creatures.dart';

/// Showcase widget to demonstrate the simplified biome creature system
/// This demonstrates visual distinction between biomes without database complexity
class BiomeCreatureShowcase extends StatefulWidget {
  const BiomeCreatureShowcase({super.key});

  @override
  State<BiomeCreatureShowcase> createState() => _BiomeCreatureShowcaseState();
}

class _BiomeCreatureShowcaseState extends State<BiomeCreatureShowcase>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biome Creature Showcase'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.blue.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Simplified Biome-Specific Creatures',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Each biome displays visually distinct creatures with authentic characteristics:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 24),
            _buildBiomeSection(
              'Shallow Waters',
              'Bright, small, energetic tropical fish',
              BiomeType.shallowWaters,
              const Color(0xFF87CEEB),
              'Fast-moving, colorful fish with bright stripes and fan-shaped tails. High energy movement patterns.',
            ),
            const SizedBox(height: 32),
            _buildBiomeSection(
              'Coral Garden',
              'Medium-sized reef fish with territorial behavior',
              BiomeType.coralGarden,
              const Color(0xFF40E0D0),
              'Angular diamond-shaped bodies with elaborate fins. Moderate swimming speeds with territorial displays.',
            ),
            const SizedBox(height: 32),
            _buildBiomeSection(
              'Deep Ocean',
              'Large, streamlined pelagic species',
              BiomeType.deepOcean,
              const Color(0xFF0077BE),
              'Torpedo-shaped bodies with powerful crescent tails. Slow, efficient movement with subtle bioluminescence.',
            ),
            const SizedBox(height: 32),
            _buildBiomeSection(
              'Abyssal Zone',
              'Mysterious bioluminescent creatures',
              BiomeType.abyssalZone,
              const Color(0xFF191970),
              'Alien shapes: anglerfish with lures, flowing jellyfish, serpentine deep-sea creatures. Hypnotic movement.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiomeSection(String title, String subtitle, BiomeType biome,
      Color backgroundColor, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor.withValues(alpha: 0.1),
            backgroundColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: backgroundColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: backgroundColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: backgroundColor.withValues(alpha: 0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 20),
          // Creature showcase
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: _getBiomeGradient(biome),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: backgroundColor.withValues(alpha: 0.4),
              ),
            ),
            child: Stack(
              children: List.generate(4, (index) {
                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final progress = _animationController.value;
                    final creatureProgress = (progress + index * 0.25) % 1.0;

                    return Positioned(
                      left: creatureProgress * (MediaQuery.of(context).size.width - 120),
                      top: 20 + (index * 20.0) % 80,
                      child: SizedBox(
                        width: 80,
                        height: 60,
                        child: CustomPaint(
                          painter: _BiomeCreatureShowcasePainter(
                            biome: biome,
                            creatureIndex: index,
                            animationValue: _animationController.value * 8,
                            swimDirection: 1,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getBiomeGradient(BiomeType biome) {
    switch (biome) {
      case BiomeType.shallowWaters:
        return LinearGradient(
          colors: [
            const Color(0xFF87CEEB).withValues(alpha: 0.8),
            const Color(0xFF00A6D6).withValues(alpha: 0.6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case BiomeType.coralGarden:
        return LinearGradient(
          colors: [
            const Color(0xFF40E0D0).withValues(alpha: 0.8),
            const Color(0xFF00CED1).withValues(alpha: 0.6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case BiomeType.deepOcean:
        return LinearGradient(
          colors: [
            const Color(0xFF0077BE).withValues(alpha: 0.8),
            const Color(0xFF003366).withValues(alpha: 0.7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case BiomeType.abyssalZone:
        return LinearGradient(
          colors: [
            const Color(0xFF191970).withValues(alpha: 0.9),
            const Color(0xFF000080).withValues(alpha: 0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
    }
  }
}

/// Custom painter for the creature showcase
class _BiomeCreatureShowcasePainter extends CustomPainter {
  final BiomeType biome;
  final int creatureIndex;
  final double animationValue;
  final int swimDirection;

  _BiomeCreatureShowcasePainter({
    required this.biome,
    required this.creatureIndex,
    required this.animationValue,
    required this.swimDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    if (swimDirection < 0) {
      canvas.scale(-1, 1);
      canvas.translate(-size.width, 0);
    }

    // Use our simplified biome creature renderer
    SimpleBiomeCreatures.paintBiomeCreature(
      canvas,
      size,
      biome,
      creatureIndex,
      animationValue,
      20.0, // Mock depth
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_BiomeCreatureShowcasePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.biome != biome ||
           oldDelegate.creatureIndex != creatureIndex;
  }
}