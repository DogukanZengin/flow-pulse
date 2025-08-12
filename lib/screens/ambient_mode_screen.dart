import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../widgets/particle_system.dart';
import '../widgets/gradient_mesh_background.dart';
import '../widgets/rolling_timer.dart';
import '../services/time_based_theme_service.dart';

class AmbientModeScreen extends StatefulWidget {
  final bool isRunning;
  final bool isStudySession;
  final int secondsRemaining;
  final double progress;
  final String sessionTitle;
  final VoidCallback onTap;
  final VoidCallback onBack;
  
  const AmbientModeScreen({
    super.key,
    required this.isRunning,
    required this.isStudySession,
    required this.secondsRemaining,
    required this.progress,
    required this.sessionTitle,
    required this.onTap,
    required this.onBack,
  });

  @override
  State<AmbientModeScreen> createState() => _AmbientModeScreenState();
}

class _AmbientModeScreenState extends State<AmbientModeScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _breathingController;
  late AnimationController _glowController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _glowAnimation;
  
  bool _showUI = true;
  
  @override
  void initState() {
    super.initState();
    
    // Enter fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _breathingAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    // Hide UI after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showUI = false;
        });
      }
    });
  }
  
  @override
  void dispose() {
    // Exit fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _breathingController.dispose();
    _glowController.dispose();
    super.dispose();
  }
  
  void _toggleUI() {
    setState(() {
      _showUI = !_showUI;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final timeColors = TimeBasedThemeService.instance.getTimeBasedColors(widget.isStudySession);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleUI,
        child: Stack(
          children: [
            // Animated gradient background
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      ...timeColors.primaryGradient,
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            
            // Gradient mesh background
            Positioned.fill(
              child: GradientMeshBackground(
                isStudySession: widget.isStudySession,
                isEnabled: true,
              ),
            ),
            
            // Enhanced particle system
            Positioned.fill(
              child: ParticleSystem(
                isRunning: widget.isRunning,
                isStudySession: widget.isStudySession,
                screenSize: screenSize,
                timeBasedColors: timeColors.particleColors,
              ),
            ),
            
            // Aurora-like background effect
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: AuroraPainter(
                      animationValue: _glowAnimation.value,
                      isStudySession: widget.isStudySession,
                      timeColors: timeColors,
                    ),
                  );
                },
              ),
            ),
            
            // Central timer display
            Center(
              child: AnimatedBuilder(
                animation: _breathingAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.isRunning ? _breathingAnimation.value : 1.0,
                    child: Container(
                      width: screenSize.width * 0.7,
                      height: screenSize.width * 0.7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.transparent,
                            timeColors.primaryGradient[0].withOpacity(0.1),
                            timeColors.primaryGradient[1].withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Progress ring
                          SizedBox(
                            width: screenSize.width * 0.6,
                            height: screenSize.width * 0.6,
                            child: CustomPaint(
                              painter: AmbientCircularProgressPainter(
                                progress: widget.progress,
                                isStudySession: widget.isStudySession,
                                timeColors: timeColors,
                                glowIntensity: _glowAnimation.value,
                              ),
                            ),
                          ),
                          
                          // Timer text
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RollingTimer(
                                seconds: widget.secondsRemaining,
                                textStyle: TextStyle(
                                  fontSize: screenSize.width * 0.12,
                                  fontWeight: FontWeight.w200,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(0, 4),
                                      blurRadius: 20,
                                      color: timeColors.primaryGradient[0].withOpacity(0.6),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.sessionTitle,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(0, 2),
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // UI Controls (shown/hidden)
            AnimatedOpacity(
              opacity: _showUI ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Top bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: widget.onBack,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              TimeBasedThemeService.instance.getTimeOfDayMessage(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Bottom controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: widget.onTap,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.3),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: timeColors.primaryGradient[0].withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.isRunning ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            
            // Tap to show controls hint
            if (!_showUI)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: 0.6,
                  duration: const Duration(seconds: 2),
                  child: Center(
                    child: Text(
                      'Tap screen to show controls',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AmbientCircularProgressPainter extends CustomPainter {
  final double progress;
  final bool isStudySession;
  final TimeOfDayColors timeColors;
  final double glowIntensity;
  
  AmbientCircularProgressPainter({
    required this.progress,
    required this.isStudySession,
    required this.timeColors,
    required this.glowIntensity,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 6.0;
    final glowStrokeWidth = strokeWidth + (glowIntensity * 20);
    
    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    // Glow effect
    final glowPaint = Paint()
      ..color = timeColors.primaryGradient[0].withOpacity(0.3 * glowIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = glowStrokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15 * glowIntensity);
    
    // Progress paint
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          ...timeColors.primaryGradient,
          Colors.white.withOpacity(0.8),
        ],
        stops: const [0.0, 0.7, 1.0],
        startAngle: -math.pi / 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    if (progress > 0) {
      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;
      
      // Draw glow
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
      
      // Draw progress
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(AmbientCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.glowIntensity != glowIntensity ||
           oldDelegate.isStudySession != isStudySession;
  }
}

class AuroraPainter extends CustomPainter {
  final double animationValue;
  final bool isStudySession;
  final TimeOfDayColors timeColors;
  
  AuroraPainter({
    required this.animationValue,
    required this.isStudySession,
    required this.timeColors,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
    
    // Draw flowing aurora-like gradients
    for (int i = 0; i < 3; i++) {
      final waveOffset = animationValue * 2 * math.pi + (i * math.pi / 3);
      final y = size.height * (0.3 + 0.3 * math.sin(waveOffset));
      
      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          timeColors.primaryGradient[i % timeColors.primaryGradient.length]
              .withOpacity(0.1 + (animationValue * 0.1)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, y - 100, size.width, 200));
      
      final path = Path();
      path.moveTo(0, y);
      
      for (double x = 0; x <= size.width; x += 10) {
        final waveY = y + 30 * math.sin((x / size.width) * 4 * math.pi + waveOffset);
        path.lineTo(x, waveY);
      }
      
      path.lineTo(size.width, y + 100);
      path.lineTo(0, y + 100);
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }
  
  @override
  bool shouldRepaint(AuroraPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.isStudySession != isStudySession;
  }
}