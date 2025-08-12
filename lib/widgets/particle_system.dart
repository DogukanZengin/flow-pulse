import 'package:flutter/material.dart';
import 'dart:math' as math;

class ParticleSystem extends StatefulWidget {
  final bool isRunning;
  final bool isStudySession;
  final Size screenSize;
  final List<Color>? timeBasedColors;
  
  const ParticleSystem({
    super.key,
    required this.isRunning,
    required this.isStudySession,
    required this.screenSize,
    this.timeBasedColors,
  });

  @override
  State<ParticleSystem> createState() => _ParticleSystemState();
}

class _ParticleSystemState extends State<ParticleSystem>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();
  
  // Particle configuration based on session type
  int get _particleCount => widget.isStudySession ? 30 : 40;
  double get _baseSpeed => widget.isRunning ? 1.5 : 0.5;
  double get _particleOpacity => widget.isStudySession ? 0.3 : 0.4;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    
    // Initialize particles
    _initializeParticles();
    
    _animationController.addListener(_updateParticles);
  }
  
  void _initializeParticles() {
    _particles.clear();
    
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(Particle(
        x: _random.nextDouble() * widget.screenSize.width,
        y: _random.nextDouble() * widget.screenSize.height,
        size: _random.nextDouble() * 3 + 2, // Size between 2-5
        speedX: (_random.nextDouble() - 0.5) * _baseSpeed,
        speedY: (_random.nextDouble() - 0.5) * _baseSpeed,
        opacity: _random.nextDouble() * _particleOpacity + 0.1,
        color: _getParticleColor(),
        pulsePhase: _random.nextDouble() * math.pi * 2,
      ));
    }
  }
  
  Color _getParticleColor() {
    // Use time-based colors if available
    if (widget.timeBasedColors != null && widget.timeBasedColors!.isNotEmpty) {
      final colors = [...widget.timeBasedColors!, Colors.white.withOpacity(0.6)];
      return colors[_random.nextInt(colors.length)];
    }
    
    // Fallback to default colors
    if (widget.isStudySession) {
      // Purple to blue particles for focus mode
      final colors = [
        Colors.purple.shade200,
        Colors.blue.shade200,
        Colors.indigo.shade200,
        Colors.white.withOpacity(0.6),
      ];
      return colors[_random.nextInt(colors.length)];
    } else {
      // Warm colors for break mode
      final colors = [
        Colors.orange.shade200,
        Colors.yellow.shade200,
        Colors.pink.shade200,
        Colors.white.withOpacity(0.6),
      ];
      return colors[_random.nextInt(colors.length)];
    }
  }
  
  void _updateParticles() {
    if (!mounted) return;
    
    setState(() {
      final deltaTime = 0.033; // ~30fps for better performance
      
      for (var particle in _particles) {
        // Update position
        particle.x += particle.speedX * _baseSpeed;
        particle.y += particle.speedY * _baseSpeed;
        
        // Add floating motion
        particle.pulsePhase += deltaTime * 2;
        final floatOffset = math.sin(particle.pulsePhase) * 0.5;
        particle.y += floatOffset;
        
        // Wrap around screen edges
        if (particle.x < -10) {
          particle.x = widget.screenSize.width + 10;
        } else if (particle.x > widget.screenSize.width + 10) {
          particle.x = -10;
        }
        
        if (particle.y < -10) {
          particle.y = widget.screenSize.height + 10;
        } else if (particle.y > widget.screenSize.height + 10) {
          particle.y = -10;
        }
        
        // Update opacity for pulsing effect
        particle.currentOpacity = particle.opacity * 
            (0.7 + 0.3 * math.sin(particle.pulsePhase));
      }
    });
  }
  
  @override
  void didUpdateWidget(ParticleSystem oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reinitialize particles if session type changes
    if (oldWidget.isStudySession != widget.isStudySession) {
      _initializeParticles();
    }
  }
  
  @override
  void dispose() {
    _animationController.removeListener(_updateParticles);
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widget.screenSize,
      painter: ParticlePainter(
        particles: _particles,
        isRunning: widget.isRunning,
      ),
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speedX;
  double speedY;
  double opacity;
  double currentOpacity;
  Color color;
  double pulsePhase;
  
  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.opacity,
    required this.color,
    required this.pulsePhase,
  }) : currentOpacity = opacity;
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final bool isRunning;
  
  ParticlePainter({
    required this.particles,
    required this.isRunning,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.currentOpacity)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal, 
          isRunning ? 3.0 : 2.0,
        );
      
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
      
      // Add glow effect for larger particles
      if (particle.size > 3) {
        final glowPaint = Paint()
          ..color = particle.color.withOpacity(particle.currentOpacity * 0.3)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
        
        canvas.drawCircle(
          Offset(particle.x, particle.y),
          particle.size * 2,
          glowPaint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return true; // Always repaint for animation
  }
}