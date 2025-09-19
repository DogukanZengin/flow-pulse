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
  final String currentBiome; // Current biome name for context

  const DiveComputerWidget({
    super.key,
    required this.currentDepthMeters,
    required this.targetDepthMeters,
    this.oxygenTimeNotifier,
    required this.oxygenTimeSeconds,
    required this.isDiving,
    required this.diveStatus,
    required this.depthProgress,
    required this.currentBiome,
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
                  // Technical header
                  Row(
                    children: [
                      Icon(
                        Icons.dashboard,
                        color: _getDepthColor(),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'DIVE COMPUTER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontFamily: 'monospace', // Technical font
                          ),
                        ),
                      ),
                      // Status indicator
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isDiving ? Colors.green : Colors.grey,
                          boxShadow: widget.isDiving
                              ? [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.6),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Session depth progression
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.currentDepthMeters}m → ${widget.targetDepthMeters}m',
                              style: TextStyle(
                                color: _getDepthColor(),
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Session progress bar
                            LinearProgressIndicator(
                              value: widget.depthProgress.clamp(0.0, 1.0),
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(_getDepthColor()),
                              minHeight: ResponsiveHelper.isMobile(context) ? 3 : 4,
                            ),
                          ],
                        ),
                      ),
                      // Session progress percentage
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: _getDepthColor().withValues(alpha: 0.2),
                          border: Border.all(
                            color: _getDepthColor().withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${(widget.depthProgress * 100).round()}%',
                          style: TextStyle(
                            color: _getDepthColor(),
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Critical oxygen time
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: widget.oxygenTimeSeconds < TimerConstants.warningThreshold.inSeconds
                          ? OceanTheme.warningOrange.withValues(alpha: 0.1)
                          : OceanTheme.oxygenBlue.withValues(alpha: 0.1),
                      border: Border.all(
                        color: widget.oxygenTimeSeconds < TimerConstants.warningThreshold.inSeconds
                            ? OceanTheme.warningOrange.withValues(alpha: 0.3)
                            : OceanTheme.oxygenBlue.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.oxygenTimeSeconds < TimerConstants.criticalThreshold.inSeconds
                              ? Icons.warning
                              : Icons.air,
                          color: widget.oxygenTimeSeconds < TimerConstants.warningThreshold.inSeconds
                              ? OceanTheme.warningOrange
                              : OceanTheme.oxygenBlue,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: widget.oxygenTimeNotifier != null
                              ? ValueListenableBuilder<int>(
                                  valueListenable: widget.oxygenTimeNotifier!,
                                  builder: (context, oxygenTime, child) {
                                    return Text(
                                      'O₂: ${_formatTime(oxygenTime)}',
                                      style: TextStyle(
                                        color: oxygenTime < TimerConstants.warningThreshold.inSeconds
                                            ? OceanTheme.warningOrange
                                            : OceanTheme.oxygenBlue,
                                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                )
                              : Text(
                                  'O₂: ${_formatTime(widget.oxygenTimeSeconds)}',
                                  style: TextStyle(
                                    color: widget.oxygenTimeSeconds < TimerConstants.warningThreshold.inSeconds
                                        ? OceanTheme.warningOrange
                                        : OceanTheme.oxygenBlue,
                                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        if (widget.oxygenTimeSeconds < TimerConstants.criticalThreshold.inSeconds)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: OceanTheme.warningOrange,
                            ),
                            child: Text(
                              'CRITICAL',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Status with biome context
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
                      Expanded(
                        child: Text(
                          '${widget.diveStatus} • ${widget.currentBiome}',
                          style: TextStyle(
                            color: widget.isDiving ? Colors.green : Colors.grey,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
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