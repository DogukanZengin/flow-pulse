import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/celebration_config.dart';
import '../constants/animation_constants.dart';

/// Enhanced underwater particle system with three-layer celebration effects
class UnderwaterParticleSystem extends StatefulWidget {
  final AnimationController controller;
  final CelebrationConfig celebrationConfig;
  final CelebrationPhase? currentPhase;

  const UnderwaterParticleSystem({
    super.key,
    required this.controller,
    required this.celebrationConfig,
    this.currentPhase,
  });

  @override
  State<UnderwaterParticleSystem> createState() => _UnderwaterParticleSystemState();
}

class _UnderwaterParticleSystemState extends State<UnderwaterParticleSystem> 
    with TickerProviderStateMixin {
  AnimationController? _floatController;
  AnimationController? _sparkleController;
  AnimationController? _burstController;
  
  final List<Particle> _particles = [];
  final List<BurstParticle> _burstParticles = [];
  
  // Performance optimization: Object pools and shader cache
  final Map<String, Shader> _shaderCache = {};
  final List<Path> _starPathPool = [];
  static const int _maxStarPaths = 20;
  
  // Cache expensive calculations
  late Size _lastScreenSize;
  late double _widthScale;
  late double _heightScale;
  
  @override
  void initState() {
    super.initState();
    
    _floatController = AnimationController(
      duration: AnimationConstants.particleFloatDuration,
      vsync: this,
    )..repeat();
    
    _sparkleController = AnimationController(
      duration: AnimationConstants.sparkleAnimationDuration,
      vsync: this,
    )..repeat(reverse: true);
    
    _burstController = AnimationController(
      duration: AnimationConstants.burstEffectDuration,
      vsync: this,
    );
    
    _initializeParticles();
    _initializeStarPaths();
    
    // Trigger burst effects on phase changes
    widget.controller.addListener(_checkForPhaseBurst);
  }
  
  void _initializeStarPaths() {
    // Pre-create star paths for object pooling
    for (int i = 0; i < _maxStarPaths; i++) {
      final path = Path();
      for (int j = 0; j < 8; j++) {
        final angle = j * math.pi / 4;
        final radius = j.isEven ? 8.0 : 4.0;
        final point = Offset(
          math.cos(angle) * radius,
          math.sin(angle) * radius,
        );
        
        if (j == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      _starPathPool.add(path);
    }
  }
  
  void _initializeParticles() {
    final biomeConfig = BiomeVisualConfig.forBiome(widget.celebrationConfig.primaryBiome);
    final random = math.Random();
    
    // Initialize background marine snow particles
    for (int i = 0; i < AnimationConstants.marineSnowParticleCount; i++) {
      _particles.add(Particle(
        position: Offset(
          random.nextDouble() * 400, // Will be scaled to actual size
          random.nextDouble() * 800,
        ),
        velocity: Offset(
          random.nextDouble() * 10 - 5,
          random.nextDouble() * 20 + 10,
        ),
        size: random.nextDouble() * 3 + 1,
        color: biomeConfig.particleColors[random.nextInt(biomeConfig.particleColors.length)],
        opacity: random.nextDouble() * 0.5 + 0.3,
        type: ParticleType.marineSnow,
      ));
    }
    
    // Initialize plankton particles
    for (int i = 0; i < AnimationConstants.planktonParticleCount; i++) {
      _particles.add(Particle(
        position: Offset(
          random.nextDouble() * 400,
          random.nextDouble() * 800,
        ),
        velocity: Offset(
          random.nextDouble() * 30 - 15,
          random.nextDouble() * 5,
        ),
        size: random.nextDouble() * 5 + 2,
        color: biomeConfig.dominantColor,
        opacity: random.nextDouble() * 0.4 + 0.4,
        type: ParticleType.bioluminescentPlankton,
      ));
    }
  }
  
  void _checkForPhaseBurst() {
    try {
      if (widget.currentPhase != null && _burstController != null && !_burstController!.isAnimating) {
        _createBurstEffect();
        _burstController!.forward(from: 0);
      }
    } catch (e) {
      // Silently handle animation errors to prevent crash
      debugPrint('Error in phase burst animation: $e');
    }
  }
  
  void _createBurstEffect() {
    final random = math.Random();
    final center = Offset(200, 400); // Will be scaled to actual size
    
    _burstParticles.clear();
    
    for (int i = 0; i < AnimationConstants.burstParticleCount; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final speed = random.nextDouble() * 150 + 50;
      
      _burstParticles.add(BurstParticle(
        startPosition: center,
        velocity: Offset(
          math.cos(angle) * speed,
          math.sin(angle) * speed,
        ),
        color: _getBurstColorForPhase(),
        size: random.nextDouble() * 6 + 2,
      ));
    }
  }
  
  Color _getBurstColorForPhase() {
    if (widget.currentPhase == null) return Colors.cyan;
    
    switch (widget.currentPhase!.name) {
      case 'Career Advancement':
        return const Color(0xFFFFD700); // Gold color
      case 'Species Discovery':
        return Colors.greenAccent;
      case 'Equipment Unlock':
        return Colors.purpleAccent;
      default:
        return Colors.cyanAccent;
    }
  }
  
  @override
  void dispose() {
    try {
      widget.controller.removeListener(_checkForPhaseBurst);
      _floatController?.dispose();
      _sparkleController?.dispose();
      _burstController?.dispose();
      
      // Clear caches to prevent memory leaks
      _shaderCache.clear();
      _particles.clear();
      _burstParticles.clear();
    } catch (e) {
      debugPrint('Error disposing animation controllers: $e');
    } finally {
      _floatController = null;
      _sparkleController = null;
      _burstController = null;
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    try {
      final size = MediaQuery.of(context).size;
      
      // Return empty container if controllers aren't initialized yet
      if (_floatController == null || _sparkleController == null || _burstController == null) {
        return const SizedBox.shrink();
      }
      
      // Safety check for animation values
      if (!_floatController!.value.isFinite || 
          !_sparkleController!.value.isFinite || 
          !_burstController!.value.isFinite) {
        return const SizedBox.shrink();
      }
      
      // Update cached scaling values only when size changes
      if (size != _lastScreenSize) {
        _lastScreenSize = size;
        _widthScale = size.width / 400;
        _heightScale = size.height / 800;
      }
      
      return RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            widget.controller,
            _floatController!,
            _sparkleController!,
            _burstController!,
          ]),
          builder: (context, child) {
            return CustomPaint(
              size: size,
              painter: _ThreeLayerParticlePainter(
                progress: widget.controller.value,
                floatProgress: _floatController!.value,
                sparkleProgress: _sparkleController!.value,
                burstProgress: _burstController!.value,
                particles: _particles,
                burstParticles: _burstParticles,
                celebrationConfig: widget.celebrationConfig,
                currentPhase: widget.currentPhase,
                screenSize: size,
                shaderCache: _shaderCache,
                starPathPool: _starPathPool,
                widthScale: _widthScale,
                heightScale: _heightScale,
              ),
            );
          },
        ),
      );
    } catch (e) {
      // Return error fallback widget
      debugPrint('Error in underwater particle system: $e');
      return Container(
        color: Colors.black.withValues(alpha: 0.1),
        child: const Center(
          child: Icon(
            Icons.error_outline,
            color: Colors.white24,
            size: 32,
          ),
        ),
      );
    }
  }
}

/// Three-layer particle system painter
class _ThreeLayerParticlePainter extends CustomPainter {
  final double progress;
  final double floatProgress;
  final double sparkleProgress;
  final double burstProgress;
  final List<Particle> particles;
  final List<BurstParticle> burstParticles;
  final CelebrationConfig celebrationConfig;
  final CelebrationPhase? currentPhase;
  final Size screenSize;
  final Map<String, Shader> shaderCache;
  final List<Path> starPathPool;
  final double widthScale;
  final double heightScale;

  _ThreeLayerParticlePainter({
    required this.progress,
    required this.floatProgress,
    required this.sparkleProgress,
    required this.burstProgress,
    required this.particles,
    required this.burstParticles,
    required this.celebrationConfig,
    required this.currentPhase,
    required this.screenSize,
    required this.shaderCache,
    required this.starPathPool,
    required this.widthScale,
    required this.heightScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Layer 1: Background marine snow (slow, ambient)
    _drawBackgroundLayer(canvas, size);
    
    // Layer 2: Mid-layer plankton and current effects
    _drawMidLayer(canvas, size);
    
    // Layer 3: Foreground burst effects and highlights
    _drawForegroundLayer(canvas, size);
  }
  
  void _drawBackgroundLayer(Canvas canvas, Size size) {
    final paint = Paint()
      ..blendMode = BlendMode.screen;
    
    // Draw marine snow particles with culling
    for (final particle in particles.where((p) => p.type == ParticleType.marineSnow)) {
      final scaledPos = Offset(
        particle.position.dx * size.width / 400,
        (particle.position.dy + floatProgress * 800) % size.height,
      );
      
      // Cull particles outside visible area with buffer
      if (scaledPos.dx < -AnimationConstants.minRenderDistance || 
          scaledPos.dx > size.width + AnimationConstants.minRenderDistance ||
          scaledPos.dy < -AnimationConstants.minRenderDistance ||
          scaledPos.dy > size.height + AnimationConstants.minRenderDistance) {
        continue;
      }
      
      final effectiveOpacity = particle.opacity * 0.6;
      if (effectiveOpacity < AnimationConstants.particleCullingThreshold) continue;
      
      paint.color = particle.color.withValues(alpha: effectiveOpacity);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 1); // Reduced blur
      
      canvas.drawCircle(scaledPos, particle.size, paint);
    }
  }
  
  void _drawMidLayer(Canvas canvas, Size size) {
    final paint = Paint()
      ..blendMode = BlendMode.plus;
    
    // Pre-calculate common values outside loop
    final floatWaveBase = floatProgress * math.pi * 2;
    final sparkleWaveBase = sparkleProgress * math.pi * 2;
    final sparkleScaleFactor = 1 + sparkleProgress * 0.3;
    
    // Draw bioluminescent plankton with sparkle effect
    for (final particle in particles.where((p) => p.type == ParticleType.bioluminescentPlankton)) {
      final horizontalWave = math.sin(floatWaveBase + particle.position.dx) * 20;
      final scaledPos = Offset(
        (particle.position.dx + horizontalWave) * widthScale,
        particle.position.dy * heightScale,
      );
      
      // Early culling for off-screen particles
      if (scaledPos.dx < -50 || scaledPos.dx > size.width + 50 ||
          scaledPos.dy < -50 || scaledPos.dy > size.height + 50) {
        continue;
      }
      
      // Pulsing opacity based on sparkle animation
      final pulseOpacity = particle.opacity * (0.7 + 0.3 * math.sin(sparkleWaveBase));
      
      // Skip nearly invisible particles
      if (pulseOpacity < AnimationConstants.particleCullingThreshold) continue;
      
      // Use cached shader for better performance
      final shaderKey = 'plankton_${particle.size.toStringAsFixed(1)}';
      final shaderRadius = particle.size * 2;
      
      paint.shader = shaderCache.putIfAbsent(shaderKey, () {
        return RadialGradient(
          colors: [
            particle.color.withValues(alpha: pulseOpacity),
            particle.color.withValues(alpha: pulseOpacity * 0.3),
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: shaderRadius));
      });
      
      canvas.drawCircle(scaledPos, particle.size * sparkleScaleFactor, paint);
    }
    
    // Draw current flow lines
    _drawCurrentFlow(canvas, size);
  }
  
  void _drawCurrentFlow(Canvas canvas, Size size) {
    if (celebrationConfig.intensity.index < 2) return; // Only for moderate+ intensity
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.cyan.withValues(alpha: 0.2);
    
    final currentFlowCount = celebrationConfig.intensity.index < 2 ? 3 : 5; // Reduce for lower intensity
    for (int i = 0; i < currentFlowCount; i++) {
      final path = Path();
      final y = size.height * (0.2 + i * 0.15);
      path.moveTo(-50, y);
      
      for (double x = 0; x <= size.width + 50; x += 50) {
        final waveY = y + math.sin((x / 100) + floatProgress * math.pi * 2) * 20;
        path.lineTo(x, waveY);
      }
      
      canvas.drawPath(path, paint);
    }
  }
  
  void _drawForegroundLayer(Canvas canvas, Size size) {
    if (!burstProgress.isFinite || burstProgress == 0) return;
    
    final paint = Paint()
      ..blendMode = BlendMode.plus;
    
    // Draw burst particles
    for (final particle in burstParticles) {
      final t = Curves.easeOutCubic.transform(burstProgress);
      final position = particle.startPosition + (particle.velocity * t);
      final scaledPos = Offset(
        position.dx * widthScale,
        position.dy * heightScale,
      );
      
      final opacity = (1 - burstProgress) * 0.8;
      final scale = 1 + burstProgress * 2;
      
      // Use cached shader for burst particles
      final shaderKey = 'burst_${particle.size.toStringAsFixed(1)}_${scale.toStringAsFixed(1)}';
      paint.shader = shaderCache.putIfAbsent(shaderKey, () {
        return RadialGradient(
          colors: [
            particle.color.withValues(alpha: opacity),
            particle.color.withValues(alpha: opacity * 0.1),
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: particle.size * scale));
      });
      
      canvas.drawCircle(scaledPos, particle.size * scale, paint);
    }
    
    // Draw achievement sparkles
    if (currentPhase != null && celebrationConfig.hasAchievements) {
      _drawAchievementSparkles(canvas, size);
    }
  }
  
  void _drawAchievementSparkles(Canvas canvas, Size size) {
    final paint = Paint()
      ..blendMode = BlendMode.plus;
    
    final random = math.Random(42); // Fixed seed for consistent sparkles
    
    for (int i = 0; i < AnimationConstants.maxAchievementSparkles; i++) {
      final sparklePhase = (sparkleProgress + i / AnimationConstants.maxAchievementSparkles) % 1.0;
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      
      final opacity = math.sin(sparklePhase * math.pi) * 0.8;
      if (opacity < AnimationConstants.particleCullingThreshold) continue;
      
      paint.color = Colors.white.withValues(alpha: opacity);
      
      // Use pre-created star path from object pool
      final pathIndex = i % starPathPool.length;
      final starPath = starPathPool[pathIndex];
      
      // Transform the path to the sparkle position
      canvas.save();
      canvas.translate(x, y);
      canvas.drawPath(starPath, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ThreeLayerParticlePainter oldDelegate) {
    return progress != oldDelegate.progress ||
           floatProgress != oldDelegate.floatProgress ||
           sparkleProgress != oldDelegate.sparkleProgress ||
           burstProgress != oldDelegate.burstProgress ||
           currentPhase != oldDelegate.currentPhase;
  }
}

/// Individual particle data
class Particle {
  final Offset position;
  final Offset velocity;
  final double size;
  final Color color;
  final double opacity;
  final ParticleType type;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.opacity,
    required this.type,
  });
}

/// Burst particle for celebration effects
class BurstParticle {
  final Offset startPosition;
  final Offset velocity;
  final Color color;
  final double size;

  BurstParticle({
    required this.startPosition,
    required this.velocity,
    required this.color,
    required this.size,
  });
}

/// Particle types for different layers
enum ParticleType {
  marineSnow,
  bioluminescentPlankton,
  currentDebris,
  celebrationBurst,
}