import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../themes/ocean_theme.dart';
import '../constants/timer_constants.dart';
import '../utils/responsive_helper.dart';

/// Marine biology research dive computer component
/// Displays depth progression, oxygen supply (time), and dive status
class DiveComputerWidget extends StatefulWidget {
  final int currentDepthMeters;
  final int targetDepthMeters;
  final ValueNotifier<int>? oxygenTimeNotifier; // New efficient parameter
  final int oxygenTimeSeconds; // Keep for backwards compatibility
  final bool isDiving;
  final String diveStatus;
  final double depthProgress; // 0.0 to 1.0

  const DiveComputerWidget({
    super.key,
    required this.currentDepthMeters,
    required this.targetDepthMeters,
    this.oxygenTimeNotifier,
    required this.oxygenTimeSeconds,
    required this.isDiving,
    required this.diveStatus,
    required this.depthProgress,
  });

  @override
  State<DiveComputerWidget> createState() => _DiveComputerWidgetState();
}

class _DiveComputerWidgetState extends State<DiveComputerWidget>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Glow animation for dive computer screen
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation when diving
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isDiving) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(DiveComputerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isDiving && !oldWidget.isDiving) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isDiving && oldWidget.isDiving) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getDepthColor() {
    if (widget.currentDepthMeters >= 40) {
      return OceanTheme.abyssal; // Abyssal zone
    } else if (widget.currentDepthMeters >= 20) {
      return OceanTheme.deepOceanBlue; // Deep ocean
    } else if (widget.currentDepthMeters >= 10) {
      return OceanTheme.coralGardenTeal; // Coral garden
    } else {
      return OceanTheme.shallowWaterBlue; // Shallow waters
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isDiving ? _pulseAnimation.value : 1.0,
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 250,
              minWidth: 180,
              maxHeight: 150,
              minHeight: 120,
            ),
            width: MediaQuery.of(context).size.width * 0.45,
            height: MediaQuery.of(context).size.height * 0.18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  OceanTheme.cardBackground.withValues(alpha: 0.9),
                  OceanTheme.containerBackground.withValues(alpha: 0.9),
                ],
              ),
              border: Border.all(
                color: _getDepthColor().withValues(alpha: _glowAnimation.value),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getDepthColor().withValues(alpha: 0.3 * _glowAnimation.value),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.speed,
                        color: _getDepthColor(),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'DIVE COMPUTER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Depth information
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current: ${widget.currentDepthMeters}m',
                              style: TextStyle(
                                color: _getDepthColor(),
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Target: ${widget.targetDepthMeters}m',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Depth gauge
                      SizedBox(
                        width: ResponsiveHelper.responsiveValue(
                          context: context,
                          mobile: 60.0,
                          tablet: 70.0,
                          desktop: 80.0,
                        ),
                        height: ResponsiveHelper.responsiveValue(
                          context: context,
                          mobile: 40.0,
                          tablet: 45.0,
                          desktop: 50.0,
                        ),
                        child: CustomPaint(
                          painter: DepthGaugePainter(
                            progress: widget.depthProgress,
                            color: _getDepthColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Oxygen time
                  Row(
                    children: [
                      Icon(
                        Icons.air,
                        color: widget.oxygenTimeSeconds < TimerConstants.warningThreshold.inSeconds 
                            ? OceanTheme.warningOrange 
                            : OceanTheme.oxygenBlue,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      widget.oxygenTimeNotifier != null
                          ? ValueListenableBuilder<int>(
                              valueListenable: widget.oxygenTimeNotifier!,
                              builder: (context, oxygenTime, child) {
                                return Text(
                                  'O₂ Time: ${_formatTime(oxygenTime)}',
                                  style: TextStyle(
                                    color: oxygenTime < TimerConstants.warningThreshold.inSeconds 
                                        ? OceanTheme.warningOrange 
                                        : OceanTheme.oxygenBlue,
                                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              },
                            )
                          : Text(
                              'O₂ Time: ${_formatTime(widget.oxygenTimeSeconds)}',
                              style: TextStyle(
                                color: widget.oxygenTimeSeconds < TimerConstants.warningThreshold.inSeconds 
                            ? OceanTheme.warningOrange 
                            : OceanTheme.oxygenBlue,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ],
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Status
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isDiving ? Colors.green : Colors.grey,
                          boxShadow: widget.isDiving
                              ? [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.6),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.diveStatus,
                        style: TextStyle(
                          color: widget.isDiving ? Colors.green : Colors.grey,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for the depth gauge display
class DepthGaugePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color color;

  DepthGaugePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 2;

    // Background arc
    final backgroundPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi,
      false,
      backgroundPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * progress,
      false,
      progressPaint,
    );

    // Progress percentage text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(progress * 100).round()}%',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(DepthGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}