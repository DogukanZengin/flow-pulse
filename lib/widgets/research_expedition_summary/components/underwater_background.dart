import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../models/creature.dart';
import '../models/celebration_config.dart';
import '../models/expedition_result.dart';
import '../constants/animation_constants.dart';

/// Performance-optimized underwater background with dynamic biome scenes
/// 
/// Optimizations applied:
/// - Shader caching and reuse
/// - Paint object pooling
/// - Path precomputation
/// - RepaintBoundary isolation
/// - Efficient shouldRepaint logic
class UnderwaterBackground extends StatefulWidget {
  final BiomeVisualConfig biomeConfig;
  final AnimationController depthProgress;
  final CelebrationIntensity celebrationIntensity;

  const UnderwaterBackground({
    super.key,
    required this.biomeConfig,
    required this.depthProgress,
    required this.celebrationIntensity,
  });

  @override
  State<UnderwaterBackground> createState() => _UnderwaterBackgroundState();
}

/// Cached shader and paint objects for performance
class _PaintResourceCache {
  static final Map<String, ui.Shader> _shaderCache = {};
  static final List<Paint> _paintPool = [];
  static int _paintPoolIndex = 0;
  
  static ui.Shader getCachedShader(String key, Gradient gradient, Rect bounds) {
    return _shaderCache.putIfAbsent(key, () => gradient.createShader(bounds));
  }
  
  static Paint getPaint() {
    if (_paintPool.isEmpty) {
      // Pre-populate paint pool
      for (int i = 0; i < 10; i++) {
        _paintPool.add(Paint());
      }
    }
    
    final paint = _paintPool[_paintPoolIndex % _paintPool.length];
    _paintPoolIndex = (_paintPoolIndex + 1) % _paintPool.length;
    
    // Reset paint properties
    paint
      ..color = Colors.white
      ..shader = null
      ..blendMode = BlendMode.srcOver
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;
    
    return paint;
  }
  
  static void clearCache() {
    _shaderCache.clear();
  }
}

class _UnderwaterBackgroundState extends State<UnderwaterBackground>
    with TickerProviderStateMixin {
  AnimationController? _waveController;
  AnimationController? _coralGrowthController;
  AnimationController? _particleController;
  
  // Cached gradients to avoid recreation
  LinearGradient? _cachedDepthGradient;
  double _lastDepthProgress = -1.0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _waveController = AnimationController(
      duration: AnimationConstants.waveControllerDuration,
      vsync: this,
    )..repeat();
    
    _coralGrowthController = AnimationController(
      duration: AnimationConstants.coralGrowthDuration,
      vsync: this,
    )..forward();
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 2), // was 5s - more lively environment
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    try {
      _waveController?.dispose();
      _coralGrowthController?.dispose();
      _particleController?.dispose();
      
      // Clear shader cache when widget is disposed to prevent memory leaks
      if (mounted) {
        _PaintResourceCache.clearCache();
      }
    } catch (e) {
      debugPrint('Error disposing underwater background controllers: $e');
    } finally {
      _waveController = null;
      _coralGrowthController = null;
      _particleController = null;
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    try {
      // Return a simple container if controllers aren't initialized yet
      if (_waveController == null || _coralGrowthController == null || _particleController == null) {
        return Container(
          decoration: BoxDecoration(
            gradient: _buildDepthAwareGradient(),
          ),
        );
      }
      
      // Safety check for animation values
      if (!widget.depthProgress.value.isFinite ||
          !_waveController!.value.isFinite ||
          !_coralGrowthController!.value.isFinite ||
          !_particleController!.value.isFinite) {
        return Container(
          decoration: BoxDecoration(
            gradient: _buildDepthAwareGradient(),
          ),
        );
      }
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.depthProgress,
        _waveController!,
        _coralGrowthController!,
        _particleController!,
      ]),
      builder: (context, child) {
        return Stack(
          children: [
            // Layer 1: Dynamic gradient background with RepaintBoundary
            RepaintBoundary(
              child: Container(
                decoration: BoxDecoration(
                  gradient: _buildDepthAwareGradient(),
                ),
              ),
            ),
            
            // Layer 2: Biome-specific environment with RepaintBoundary
            RepaintBoundary(
              child: CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _BiomeEnvironmentPainter(
                  biomeType: widget.biomeConfig.biome,
                  depthProgress: widget.depthProgress.value,
                  waveAnimation: _waveController?.value ?? 0.0,
                  coralGrowth: _coralGrowthController?.value ?? 0.0,
                  intensity: widget.celebrationIntensity,
                ),
              ),
            ),
            
            // Layer 3: Caustic light patterns with RepaintBoundary
            RepaintBoundary(
              child: _buildCausticOverlay(),
            ),
            
            // Layer 4: Floating particles with RepaintBoundary
            RepaintBoundary(
              child: CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _FloatingParticlesPainter(
                  particleAnimation: _particleController?.value ?? 0.0,
                  biomeColors: widget.biomeConfig.particleColors,
                  intensity: widget.celebrationIntensity.index / 3.0,
                ),
              ),
            ),
          ],
        );
      },
    );
    } catch (e) {
      // Return fallback gradient background
      debugPrint('Error in underwater background: $e');
      return Container(
        decoration: BoxDecoration(
          gradient: widget.biomeConfig.backgroundGradient,
        ),
      );
    }
  }

  LinearGradient _buildDepthAwareGradient() {
    final progress = widget.depthProgress.value;
    
    // Cache gradient to avoid recreation on every frame
    if (_cachedDepthGradient == null || (progress - _lastDepthProgress).abs() > 0.01) {
      _cachedDepthGradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: widget.biomeConfig.backgroundGradient.colors
            .map((color) => Color.lerp(
                  color,
                  const Color(0xFF87CEEB), // Surface blue
                  progress * 0.3,
                )!)
            .toList(),
      );
      _lastDepthProgress = progress;
    }
    
    return _cachedDepthGradient!;
  }

  Widget _buildCausticOverlay() {
    return AnimatedBuilder(
      animation: widget.depthProgress,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _CausticOverlayPainter(
            progress: widget.depthProgress.value,
            intensity: widget.celebrationIntensity.index / 3.0,
            lightColor: widget.biomeConfig.dominantColor,
          ),
        );
      },
    );
  }
}

/// Performance-optimized painter for underwater caustic light effects
class _CausticOverlayPainter extends CustomPainter {
  final double progress;
  final double intensity;
  final Color lightColor;
  
  // Static cache for caustic positions to avoid recalculation
  static List<Offset>? _cachedBasePositions;
  static Size? _cachedSize;

  _CausticOverlayPainter({
    required this.progress,
    required this.intensity,
    required this.lightColor,
  });
  
  List<Offset> _getBasePositions(Size size) {
    if (_cachedBasePositions == null || _cachedSize != size) {
      _cachedBasePositions = [];
      _cachedSize = size;
      
      for (int i = 0; i < AnimationConstants.causticGridWidth; i++) {
        for (int j = 0; j < AnimationConstants.causticGridHeight; j++) {
          _cachedBasePositions!.add(Offset(
            i * size.width / 15,
            j * size.height / 8,
          ));
        }
      }
    }
    return _cachedBasePositions!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    try {
      if (intensity < AnimationConstants.particleCullingThreshold) return;
    
      final paint = _PaintResourceCache.getPaint()
        ..blendMode = BlendMode.overlay
        ..strokeWidth = 2.0
        ..style = PaintingStyle.fill;

      // Use cached shader based on intensity level
      final shaderKey = 'caustic_${lightColor.hashCode}_${(intensity * 10).round()}';
      final gradient = RadialGradient(
        colors: [
          lightColor.withValues(alpha: 0.2 * intensity),
          lightColor.withValues(alpha: 0.05 * intensity),
        ],
      );

      final basePositions = _getBasePositions(size);
      final sinProgress = math.sin(progress * math.pi * 2);
      final cosProgress = math.cos(progress * math.pi * 2);
      
      // Batch render caustic circles with precomputed positions
      for (int idx = 0; idx < basePositions.length; idx++) {
        final basePos = basePositions[idx];
        final i = idx ~/ AnimationConstants.causticGridHeight;
        
        final waveOffset = sinProgress * math.sin(i * 0.5) * 20;
        final verticalOffset = cosProgress * math.cos(idx * 0.3) * 10;
        
        final offset = Offset(
          basePos.dx + waveOffset,
          basePos.dy + verticalOffset,
        );
        
        // Cache shader for this position
        paint.shader = _PaintResourceCache.getCachedShader(
          '${shaderKey}_$idx',
          gradient,
          Rect.fromCircle(center: offset, radius: 30),
        );
        
        final radius = 25 + (math.sin(progress * math.pi * 4) * 5);
        canvas.drawCircle(offset, radius, paint);
      }
    } catch (e) {
      // Silently handle painting errors
      debugPrint('Error in caustic overlay painting: $e');
    }
  }

  @override
  bool shouldRepaint(covariant _CausticOverlayPainter oldDelegate) {
    // Only repaint if there's a meaningful change in progress or intensity
    return (progress - oldDelegate.progress).abs() > 0.016 || // ~60fps threshold
           (intensity - oldDelegate.intensity).abs() > 0.1;
  }
}

/// Performance-optimized painter for biome-specific environmental elements
class _BiomeEnvironmentPainter extends CustomPainter {
  final BiomeType biomeType;
  final double depthProgress;
  final double waveAnimation;
  final double coralGrowth;
  final CelebrationIntensity intensity;
  
  // Static caches for paths and positions
  static final Map<String, Path> _pathCache = {};
  static final Map<String, List<Offset>> _positionCache = {};

  _BiomeEnvironmentPainter({
    required this.biomeType,
    required this.depthProgress,
    required this.waveAnimation,
    required this.coralGrowth,
    required this.intensity,
  });
  
  Path _getCachedRipplePath(String key, Size size, double yPos) {
    return _pathCache.putIfAbsent(key, () {
      return Path()
        ..moveTo(0, yPos)
        ..quadraticBezierTo(
          size.width * 0.25, yPos - 10,
          size.width * 0.5, yPos,
        )
        ..quadraticBezierTo(
          size.width * 0.75, yPos + 10,
          size.width, yPos,
        );
    });
  }
  
  List<Offset> _getCachedCoralPositions(String key, Size size) {
    return _positionCache.putIfAbsent(key, () {
      final positions = <Offset>[];
      for (int i = 0; i < 20; i++) {
        final x = math.Random(i).nextDouble() * size.width;
        final y = size.height * 0.75 + math.Random(i * 2).nextDouble() * 50;
        positions.add(Offset(x, y));
      }
      return positions;
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    switch (biomeType) {
      case BiomeType.shallowWaters:
        _drawShallowWatersScene(canvas, size);
        break;
      case BiomeType.coralGarden:
        _drawCoralGardenScene(canvas, size);
        break;
      case BiomeType.deepOcean:
        _drawDeepOceanScene(canvas, size);
        break;
      case BiomeType.abyssalZone:
        _drawAbyssalZoneScene(canvas, size);
        break;
    }
  }

  void _drawShallowWatersScene(Canvas canvas, Size size) {
    final paint = _PaintResourceCache.getPaint();
    
    // Sandy bottom with ripples using cached shader
    final shaderRect = Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3);
    
    paint.shader = _PaintResourceCache.getCachedShader(
      'shallow_sandy_bottom', 
      LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.yellow.shade100.withValues(alpha: 0.3),
          Colors.amber.shade200.withValues(alpha: 0.5),
        ],
      ), 
      shaderRect,
    );
    
    // Use cached paths for ripple patterns
    for (int i = 0; i < 5; i++) {
      final baseY = size.height * 0.8 + (i * 15);
      final y = baseY + math.sin(waveAnimation * math.pi * 2 + i) * 5;
      
      final pathKey = 'ripple_$i';
      final path = _getCachedRipplePath(pathKey, size, y);
      
      canvas.save();
      canvas.translate(0, y - baseY); // Translate for wave animation
      canvas.drawPath(path, paint);
      canvas.restore();
    }
    
    // Growing coral polyps with cached positions
    _drawCoralPolyps(canvas, size, Colors.pink.shade300, coralGrowth);
  }

  void _drawCoralGardenScene(Canvas canvas, Size size) {
    final paint = _PaintResourceCache.getPaint();
    
    // Branching corals with cached colors
    final coralColors = [
      Colors.pink.shade400.withValues(alpha: 0.7),
      Colors.orange.shade400.withValues(alpha: 0.7),
      Colors.purple.shade400.withValues(alpha: 0.7),
      Colors.red.shade400.withValues(alpha: 0.7),
    ];
    
    for (int i = 0; i < 8; i++) {
      final x = (i + 1) * size.width / 9;
      final baseY = size.height * 0.7;
      final height = 100 + (i * 20);
      
      paint.color = coralColors[i % 4];
      _drawBranchingCoral(canvas, Offset(x, baseY), height * coralGrowth, paint);
    }
    
    // Swaying anemones
    _drawAnemones(canvas, size, waveAnimation);
  }

  void _drawDeepOceanScene(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Massive rock formations
    paint.color = Colors.blueGrey.shade900.withValues(alpha: 0.6);
    for (int i = 0; i < 3; i++) {
      final rect = Rect.fromLTWH(
        i * size.width / 3 + size.width * 0.1,
        size.height * 0.6,
        size.width * 0.2,
        size.height * 0.4,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(20)),
        paint,
      );
    }
    
    // Artificial dive lights
    _drawDiveLights(canvas, size, depthProgress);
  }

  void _drawAbyssalZoneScene(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Ancient coral cities
    paint.shader = RadialGradient(
      colors: [
        Colors.purple.shade900.withValues(alpha: 0.5),
        Colors.black.withValues(alpha: 0.8),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    // Mysterious structures
    for (int i = 0; i < 5; i++) {
      final x = (i + 1) * size.width / 6;
      final y = size.height * 0.5 + math.sin(i + waveAnimation) * 30;
      
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, y),
          width: 40,
          height: 150 * coralGrowth,
        ),
        paint,
      );
    }
    
    // Bioluminescent orbs
    _drawBioluminescentOrbs(canvas, size, waveAnimation);
  }

  void _drawCoralPolyps(Canvas canvas, Size size, Color color, double growth) {
    final paint = _PaintResourceCache.getPaint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    
    // Use cached coral positions
    final positions = _getCachedCoralPositions('coral_polyps', size);
    final radius = 3 + growth * 5;
    
    for (final position in positions) {
      canvas.drawCircle(position, radius, paint);
    }
  }

  void _drawBranchingCoral(Canvas canvas, Offset base, double height, Paint paint) {
    // Cache coral branch path by height
    final pathKey = 'coral_branch_${height.round()}';
    final path = _pathCache.putIfAbsent(pathKey, () {
      return Path()
        ..moveTo(0, 0)
        ..lineTo(-10, -height * 0.3)
        ..moveTo(0, 0)
        ..lineTo(0, -height)
        ..moveTo(0, 0)
        ..lineTo(10, -height * 0.3);
    });
    
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.drawPath(path, paint..style = PaintingStyle.stroke..strokeWidth = 4);
    canvas.restore();
  }

  void _drawAnemones(Canvas canvas, Size size, double wave) {
    final paint = _PaintResourceCache.getPaint();
    
    // Cache anemone gradient shader
    final gradient = RadialGradient(
      colors: [
        Colors.teal.shade300.withValues(alpha: 0.7),
        Colors.teal.shade700.withValues(alpha: 0.3),
      ],
    );
    
    for (int i = 0; i < 6; i++) {
      final x = (i + 1) * size.width / 7;
      final y = size.height * 0.65;
      
      paint.shader = _PaintResourceCache.getCachedShader(
        'anemone_$i',
        gradient,
        Rect.fromCircle(center: Offset(x, y), radius: 30),
      );
      
      paint.strokeWidth = 2;
      
      // Draw tentacles with reduced complexity
      for (int j = 0; j < 12; j += 2) { // Skip every other tentacle for performance
        final angle = j * math.pi * 2 / 12;
        final tentacleEnd = Offset(
          x + math.cos(angle + wave) * 25,
          y + math.sin(angle + wave) * 25 - 10,
        );
        
        canvas.drawLine(Offset(x, y), tentacleEnd, paint);
      }
    }
  }

  void _drawDiveLights(Canvas canvas, Size size, double progress) {
    final paint = Paint();
    
    for (int i = 0; i < 2; i++) {
      final x = size.width * (0.3 + i * 0.4);
      final y = size.height * 0.2;
      
      paint.shader = RadialGradient(
        colors: [
          Colors.yellow.withValues(alpha: 0.6),
          Colors.yellow.withValues(alpha: 0.1),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(x, y + progress * 100),
        radius: 80,
      ));
      
      canvas.drawCircle(Offset(x, y + progress * 100), 80, paint);
    }
  }

  void _drawBioluminescentOrbs(Canvas canvas, Size size, double wave) {
    final paint = Paint();
    
    for (int i = 0; i < 8; i++) {
      final x = size.width * 0.2 + (i * size.width * 0.1);
      final y = size.height * 0.4 + math.sin(wave * 2 + i) * 50;
      
      paint.shader = RadialGradient(
        colors: [
          Colors.cyanAccent.withValues(alpha: 0.8),
          Colors.cyanAccent.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: 15));
      
      canvas.drawCircle(Offset(x, y), 15 + math.sin(wave * 3) * 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BiomeEnvironmentPainter oldDelegate) {
    // Optimize repaint logic with meaningful thresholds
    const double threshold = 0.016; // ~60fps threshold
    const double coralThreshold = 0.05; // Coral growth is slower
    
    return (depthProgress - oldDelegate.depthProgress).abs() > threshold ||
           (waveAnimation - oldDelegate.waveAnimation).abs() > threshold ||
           (coralGrowth - oldDelegate.coralGrowth).abs() > coralThreshold ||
           biomeType != oldDelegate.biomeType ||
           intensity != oldDelegate.intensity;
  }
}

/// Performance-optimized painter for floating marine particles
class _FloatingParticlesPainter extends CustomPainter {
  final double particleAnimation;
  final List<Color> biomeColors;
  final double intensity;
  
  // Static cache for particle data
  static List<_ParticleData>? _cachedParticles;
  static int _lastParticleCount = -1;

  _FloatingParticlesPainter({
    required this.particleAnimation,
    required this.biomeColors,
    required this.intensity,
  });
  
  void _generateParticleCache(int count, Size size) {
    if (_cachedParticles == null || _lastParticleCount != count) {
      _cachedParticles = [];
      _lastParticleCount = count;
      
      final random = math.Random(AnimationConstants.fixedParticleSeed);
      
      for (int i = 0; i < count; i++) {
        _cachedParticles!.add(_ParticleData(
          baseX: random.nextDouble() * size.width,
          baseY: random.nextDouble() * size.height,
          radius: 1 + random.nextDouble() * 3,
          colorIndex: i % biomeColors.length,
          alpha: 0.3 + random.nextDouble() * 0.3,
        ));
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity < AnimationConstants.particleCullingThreshold) return;
    
    final effectiveParticleCount = (AnimationConstants.maxFloatingParticleIntensity * intensity).round();
    _generateParticleCache(effectiveParticleCount, size);
    
    final paint = _PaintResourceCache.getPaint();
    
    // Batch render particles with cached data
    for (final particle in _cachedParticles!) {
      final y = (particle.baseY + particleAnimation * size.height) % size.height;
      
      paint.color = biomeColors[particle.colorIndex].withValues(alpha: particle.alpha);
      canvas.drawCircle(
        Offset(particle.baseX, y), 
        particle.radius, 
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingParticlesPainter oldDelegate) {
    // Use 60fps threshold for smooth animation
    const double threshold = 0.016;
    return (particleAnimation - oldDelegate.particleAnimation).abs() > threshold ||
           (intensity - oldDelegate.intensity).abs() > 0.1;
  }
}

/// Data class for cached particle information
class _ParticleData {
  final double baseX;
  final double baseY;
  final double radius;
  final int colorIndex;
  final double alpha;

  const _ParticleData({
    required this.baseX,
    required this.baseY,
    required this.radius,
    required this.colorIndex,
    required this.alpha,
  });
}