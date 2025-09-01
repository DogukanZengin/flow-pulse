import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import '../models/aquarium.dart';
import '../models/creature.dart';
import '../utils/responsive_helper.dart';

/// Research vessel deck environment for break sessions
/// Provides a bright, restful surface experience with rewards
class ResearchVesselDeckWidget extends StatefulWidget {
  // Break screen color palette constants
  static const Color _pastelAqua = Color(0xFFE0F7FA); // Light cyan (pastel aqua)
  static const Color _cyan100 = Color(0xFFB2EBF2); // Cyan 100
  static const Color _cyan200 = Color(0xFF80DEEA); // Cyan 200
  static const Color _cyan300 = Color(0xFF4DD0E1); // Cyan 300
  static const Color _cyan400 = Color(0xFF26C6DA); // Cyan 400
  static const Color _softOrange = Color(0xFFFFB74D); // Soft orange for pause
  static const Color _softGreen = Color(0xFF81C784); // Soft green for play
  
  // Enhanced ocean-themed button colors
  static const Color _warmTurquoise = Color(0xFF4ECDC4); // Start break button
  static const Color _brightCyan = Color(0xFF26D0CE); // Start break accent
  static const Color _oceanBlue = Color(0xFF6BB6FF); // End break button
  static const Color _deepSkyBlue = Color(0xFF4A90E2); // End break accent
  static const Color _offWhite = Color(0xFFF8FFFE); // Softer text color
  final Aquarium aquarium;
  final int secondsRemaining;
  final int totalBreakSeconds;
  final bool isRunning;
  final List<Creature> recentDiscoveries;
  final VoidCallback onTap;
  final VoidCallback? onReset;
  final Function(String activity)? onActivityComplete;
  final bool isActualBreakSession; // true only during legitimate break sessions
  final bool followsWorkSession; // true only if this break follows a completed work session
  final int lastSessionDuration; // Duration of last focus session in minutes
  final int todayFocusTime; // Total focus time today in minutes
  final int focusStreak; // Current focus streak

  const ResearchVesselDeckWidget({
    super.key,
    required this.aquarium,
    required this.secondsRemaining,
    required this.totalBreakSeconds,
    required this.isRunning,
    required this.recentDiscoveries,
    required this.onTap,
    this.onReset,
    this.onActivityComplete,
    this.isActualBreakSession = true, // default to true for backwards compatibility
    this.followsWorkSession = true, // default to true for backwards compatibility
    this.lastSessionDuration = 25, // default 25 minutes
    this.todayFocusTime = 0, // default 0 minutes
    this.focusStreak = 0, // default 0 streak
  });

  @override
  State<ResearchVesselDeckWidget> createState() => _ResearchVesselDeckWidgetState();
}

class _ResearchVesselDeckWidgetState extends State<ResearchVesselDeckWidget> 
    with TickerProviderStateMixin {
  
  late AnimationController _waveController;
  late AnimationController _cloudsController;
  late Animation<double> _waveAnimation;
  late Animation<double> _cloudsAnimation;
  
  // Rotating encouragement messages
  late AnimationController _messageController;
  late Animation<double> _messageAnimation;
  Timer? _messageRotationTimer;
  int _currentMessageIndex = 0;
  
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _cloudsController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    _waveAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_waveController);
    _cloudsAnimation = Tween<double>(begin: 0, end: 1).animate(_cloudsController);
    
    // Initialize message fade animation controller
    _messageController = AnimationController(
      duration: const Duration(milliseconds: 500), // 500ms fade transition
      vsync: this,
    );
    _messageAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _messageController, curve: Curves.easeInOut)
    );
    
    // Start with first message visible
    _messageController.forward();
    
    // Start rotating messages every 30 seconds
    _startMessageRotation();
  }
  
  
  void _startMessageRotation() {
    _messageRotationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _rotateToNextMessage();
    });
  }
  
  void _rotateToNextMessage() {
    // Fade out current message
    _messageController.reverse().then((_) {
      // Change to next message
      setState(() {
        _currentMessageIndex = (_currentMessageIndex + 1) % _getEncouragementMessages().length;
      });
      // Fade in new message
      _messageController.forward();
    });
  }
  
  List<String> _getEncouragementMessages() {
    return [
      '🌊 Rest your mind like calm waters restore their depths',
      '🐠 Even fish need to pause in the current',
      '🌞 The ocean surface brings fresh perspective',
      '⚓ Anchor yourself in this moment of peace',
      '🧠 Your brain processes discoveries during breaks',
      '🐚 Every shell holds the memory of peaceful tides',
      '🌅 Dawn breaks with new possibilities awaiting',
      '💨 Breathe deeply, like the ocean\'s gentle rhythm',
      '🚢 Your vessel needs maintenance between voyages',
      '🌺 Coral reefs grow strongest in calm waters',
      '⭐ Stars reflect clearest in still ocean nights',
      '🏝️ Islands of rest make journeys sustainable',
      '🐢 Move slowly and deliberately, like ancient sea turtles',
      '🌙 Lunar tides remind us rest is natural',
      '🦋 Transformation happens in moments of stillness',
      '🍃 Let go like seaweed dancing with currents',
      '💎 Pressure creates pearls, but rest reveals them',
      '🕊️ Peace flows from accepting this pause',
      '🌸 Blossoming requires seasons of quiet growth',
      '🎋 Bend like bamboo, rest like the wise',
    ];
  }

  @override
  void dispose() {
    _waveController.dispose();
    _cloudsController.dispose();
    _messageController.dispose();
    _messageRotationTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ResearchVesselDeckWidget._pastelAqua,
            ResearchVesselDeckWidget._cyan100,
            ResearchVesselDeckWidget._cyan200,
            ResearchVesselDeckWidget._cyan300,
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Animated clouds
          AnimatedBuilder(
            animation: _cloudsAnimation,
            builder: (context, child) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: CloudsPainter(_cloudsAnimation.value),
                ),
              );
            },
          ),
          
          // Animated waves at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: screenSize.height * 0.3,
            child: AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavesPainter(_waveAnimation.value),
                );
              },
            ),
          ),
          
          // Main content - Research vessel deck
          _buildDeckContent(context, screenSize),
        ],
      ),
    );
  }
  
  
  Widget _buildDeckContent(BuildContext context, Size screenSize) {
    final isSmallScreen = screenSize.height < 700;
    
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, isSmallScreen ? 'navigation' : 'card')),
        child: Column(
          children: [
            // Compact header
            _buildCompactHeader(),
            
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
            
            // Prominent break timer
            _buildBreakTimer(isSmallScreen),
            
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
            
            // Main content in scrollable area
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Screen-away break activities
                    _buildScreenAwayActivities(),
                    
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'card')),
                    
                    // Break encouragement message
                    _buildBreakEncouragementMessage(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActivitySuggestion(String activity, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2), // Much tighter spacing
      child: Row(
        children: [
          Expanded(
            child: Text(
              activity,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'), // Increased from caption to body
                fontWeight: FontWeight.w400, // Lighter weight for calmer feel
                letterSpacing: 0.5, // Softer feel
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body') * 0.9, // Increased base size
                color: Colors.blue[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // Removed activity completion system as we're focusing on screen-away breaks
  // No more clickable activities that provide in-app rewards

  // Break timer display - the core Pomodoro timer functionality
  Widget _buildBreakTimer(bool isSmallScreen) {
    final minutes = widget.secondsRemaining ~/ 60;
    final seconds = widget.secondsRemaining % 60;
    final progress = widget.secondsRemaining / widget.totalBreakSeconds;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 'screen')),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ResearchVesselDeckWidget._cyan300.withAlpha(204), // 0.8 opacity
            ResearchVesselDeckWidget._cyan400.withAlpha(179), // 0.7 opacity
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveSpacing(context, 'screen')),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38), // 0.15 opacity
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withAlpha(77), // 0.3 opacity
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Break title - softer typography for calming effect
          Text(
            'Break Time',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle'),
              fontWeight: FontWeight.w300, // Much lighter weight for softer feel
              color: ResearchVesselDeckWidget._offWhite,
              letterSpacing: 1.2, // Increased letter spacing for airiness
              height: 1.3, // Better line height for readability
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
          
          // Sun arc progress visualization with centered timer
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate dynamic height with same bounds checking as painter
              final margin = constraints.maxWidth * 0.05;
              final availableWidth = constraints.maxWidth - (margin * 2);
              final maxRadius = availableWidth / 2;
              final radius = (maxRadius * 0.8).clamp(20.0, maxRadius);
              final rayExtension = radius * 0.22; // Max extension for sun rays
              final containerHeight = radius + margin + rayExtension; // Proper height calculation
              
              return SizedBox(
                width: double.infinity,
                height: containerHeight,
                child: Stack(
                  children: [
                    // Sun arc background
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _waveAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: SunArcProgressPainter(
                              progress: progress,
                              animationValue: _waveAnimation.value,
                            ),
                          );
                        },
                      ),
                    ),
                    // Centered timer
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
                        child: Text(
                          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.isMobile(context) ? 36 : 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'monospace',
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black.withAlpha(77), // 0.3 opacity
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
          
          // Break session info
          Text(
            'Relax and recharge on deck • ${widget.totalBreakSeconds ~/ 60} min break',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
              color: Colors.white.withAlpha(230), // 0.9 opacity
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Quick action buttons - simplified flow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buildConditionalButtons(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActionButton(String text, Color primaryColor, Color accentColor, VoidCallback onTap, {required bool isSmall}) {
    final buttonHeight = isSmall ? 54.0 : 60.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = min(screenWidth * 0.7, 280.0);
    
    return _AnimatedOceanButton(
      text: text,
      primaryColor: primaryColor,
      accentColor: accentColor,
      onTap: onTap,
      height: buttonHeight,
      width: buttonWidth,
    );
  }
  
  List<Widget> _buildConditionalButtons() {
    // Pre-break state: Show Start Break only
    if (widget.secondsRemaining == widget.totalBreakSeconds) {
      return [
        _buildQuickActionButton(
          '🌅 Start Break',
          ResearchVesselDeckWidget._warmTurquoise,
          ResearchVesselDeckWidget._brightCyan,
          widget.onTap,
          isSmall: ResponsiveHelper.isMobile(context),
        ),
      ];
    }
    
    // During break: Show End Break only (no pause/resume)
    return [
      _buildQuickActionButton(
        '🤿 End Break',
        ResearchVesselDeckWidget._oceanBlue,
        ResearchVesselDeckWidget._deepSkyBlue,
        () => _endBreakEarly(),
        isSmall: ResponsiveHelper.isMobile(context),
      ),
    ];
  }
  
  void _endBreakEarly() {
    // End break early and reset timer to prepare for next work session
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🤿 Break ended early - ready for next dive!'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
    
    // Call the reset function if available to reset the timer
    widget.onReset?.call();
  }

  // Compact responsive methods for mobile screens  
  Widget _buildCompactHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.getResponsiveSpacing(context, 'navigation'), 
        horizontal: ResponsiveHelper.getResponsiveSpacing(context, 'card')
      ),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(153), // 0.6 opacity to show background
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20), // 0.08 opacity
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
          Flexible(
            child: Text(
              '🌞 Vessel Deck Break 🌊',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
  
  
  Widget _buildScreenAwayActivities() {
    return _buildCompactCard(
      title: '',
      child: Column(
        children: [
          _buildActivitySuggestion('🚶‍♂️ Take a walk', 'Fresh air & movement'),
          _buildActivitySuggestion('💧 Hydrate', 'Drink water or tea'),
          _buildActivitySuggestion('👀 Look outside', '20 feet away for 20 seconds'),
          _buildActivitySuggestion('🧘 Deep breathing', '5 deep breaths'),
          _buildActivitySuggestion('🤸‍♂️ Stretch', 'Gentle body movement'),
        ],
      ),
    );
  }
  
  Widget _buildBreakEncouragementMessage() {
    final messages = _getEncouragementMessages();
    final currentMessage = messages[_currentMessageIndex];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ResearchVesselDeckWidget._pastelAqua.withAlpha(230), // 0.9 opacity
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ResearchVesselDeckWidget._cyan100,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.eco,
            color: Colors.green[600],
            size: 16,
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
          // Animated message with fade transitions
          AnimatedBuilder(
            animation: _messageAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _messageAnimation.value,
                child: Text(
                  currentMessage,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                    color: Colors.blue[800],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  
  Widget _buildCompactCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8), // Removed top padding
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(153), // 0.6 opacity to show background
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15), // 0.06 opacity
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
          ],
          child,
        ],
      ),
    );
  }
  
}

/// Custom painter for animated ocean waves at the bottom
class WavesPainter extends CustomPainter {
  final double animationValue;
  
  WavesPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    // Primary wave layer
    final primaryPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ResearchVesselDeckWidget._cyan200.withValues(alpha: 0.6),
          ResearchVesselDeckWidget._cyan300.withValues(alpha: 0.9),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    
    // Secondary wave layer (background wave)
    final secondaryPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ResearchVesselDeckWidget._cyan100.withValues(alpha: 0.4),
          ResearchVesselDeckWidget._cyan200.withValues(alpha: 0.7),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    
    // Draw secondary wave (background) first
    final secondaryPath = Path();
    final secondaryWaveHeight = size.height * 0.25;
    final secondaryWaveFrequency = 1.5 * pi / size.width;
    final secondaryPhaseOffset = animationValue * 0.7 + pi / 3; // Different speed and phase
    
    secondaryPath.moveTo(0, size.height);
    
    for (double x = 0; x <= size.width; x += 1) {
      // Gentler amplitude with smoother sine calculation
      final amplitude = secondaryWaveHeight * 0.4;
      final baseY = size.height - secondaryWaveHeight * 0.6;
      final waveY = amplitude * sin(secondaryWaveFrequency * x + secondaryPhaseOffset);
      final y = baseY - waveY;
      secondaryPath.lineTo(x, y);
    }
    
    secondaryPath.lineTo(size.width, size.height);
    secondaryPath.lineTo(0, size.height);
    secondaryPath.close();
    
    canvas.drawPath(secondaryPath, secondaryPaint);
    
    // Draw primary wave (foreground)
    final primaryPath = Path();
    final primaryWaveHeight = size.height * 0.3;
    final primaryWaveFrequency = 2 * pi / size.width;
    
    primaryPath.moveTo(0, size.height);
    
    for (double x = 0; x <= size.width; x += 1) {
      // Varying amplitude for more natural motion
      final amplitudeVariation = 0.8 + 0.2 * sin(animationValue * 0.3 + x * 0.01);
      final amplitude = primaryWaveHeight * 0.5 * amplitudeVariation;
      final baseY = size.height - primaryWaveHeight * 0.5;
      
      // Smoother sine calculation with gentler motion
      final waveY = amplitude * sin(primaryWaveFrequency * x + animationValue);
      final y = baseY - waveY;
      primaryPath.lineTo(x, y);
    }
    
    primaryPath.lineTo(size.width, size.height);
    primaryPath.lineTo(0, size.height);
    primaryPath.close();
    
    canvas.drawPath(primaryPath, primaryPaint);
    
    // Add subtle foam/whitecaps with varying opacity
    final foamPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    final foamPath = Path();
    for (double x = 0; x <= size.width; x += 1) {
      final amplitudeVariation = 0.8 + 0.2 * sin(animationValue * 0.3 + x * 0.01);
      final amplitude = primaryWaveHeight * 0.5 * amplitudeVariation;
      final baseY = size.height - primaryWaveHeight * 0.5;
      final waveY = amplitude * sin(primaryWaveFrequency * x + animationValue);
      final y = baseY - waveY - 3;
      
      // Vary foam opacity based on wave height
      final foamOpacity = (0.4 + 0.3 * sin(primaryWaveFrequency * x + animationValue)).clamp(0.2, 0.7);
      foamPaint.color = Colors.white.withValues(alpha: foamOpacity);
      
      if (x == 0) {
        foamPath.moveTo(x, y);
      } else {
        foamPath.lineTo(x, y);
      }
    }
    
    canvas.drawPath(foamPath, foamPaint);
  }
  
  @override
  bool shouldRepaint(WavesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Custom painter for sun arc progress visualization
class SunArcProgressPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final double animationValue;
  
  SunArcProgressPainter({
    required this.progress,
    required this.animationValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Responsive radius calculation with proper bounds checking
    final margin = size.width * 0.05; // 5% margin on each side
    final availableWidth = size.width - (margin * 2);
    final maxRadius = availableWidth / 2; // Maximum radius that fits
    final radius = (maxRadius * 0.8).clamp(20.0, maxRadius); // 80% of max, with safe minimum
    final center = Offset(size.width / 2, radius + margin); // Center with proper margin
    
    // Responsive sizing for all elements
    final strokeWidth = (size.width * 0.008).clamp(2.0, 6.0); // Responsive stroke width
    final sunRadius = radius * 0.12; // Sun size scales with arc
    final baseGlowRadius = sunRadius * 1.4; // Glow scales with sun
    final rayLength = sunRadius * 1.8; // Rays scale with sun
    final rayOffset = sunRadius * 1.5; // Ray start position
    
    // Background arc (horizon)
    final backgroundPaint = Paint()
      ..color = Colors.white.withAlpha(77) // 0.3 opacity
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    // Progress arc (sun path)
    final progressPaint = Paint()
      ..color = Colors.orange.withAlpha(204) // 0.8 opacity
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.25
      ..strokeCap = StrokeCap.round;
    
    // Sun circle
    final sunPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    
    // Sun glow effect
    final glowPaint = Paint()
      ..color = Colors.orange.withAlpha(51) // 0.2 opacity
      ..style = PaintingStyle.fill;
    
    // Draw background arc (full semi-circle)
    final backgroundRect = Rect.fromCenter(
      center: center,
      width: radius * 2,
      height: radius * 2,
    );
    canvas.drawArc(
      backgroundRect,
      pi, // Start at left (180 degrees)
      pi, // Draw semi-circle (180 degrees)
      false,
      backgroundPaint,
    );
    
    // Draw progress arc
    final progressAngle = pi * progress; // Progress along the arc
    canvas.drawArc(
      backgroundRect,
      pi, // Start at left
      progressAngle, // Progress amount
      false,
      progressPaint,
    );
    
    // Calculate sun position along the arc
    final sunAngle = pi + progressAngle; // Start from left side of arc
    final sunX = center.dx + radius * cos(sunAngle);
    final sunY = center.dy + radius * sin(sunAngle);
    final sunCenter = Offset(sunX, sunY);
    
    // Draw sun glow (responsive pulsing effect)
    final glowRadius = baseGlowRadius + (sunRadius * 0.3) * sin(animationValue * 4);
    canvas.drawCircle(sunCenter, glowRadius, glowPaint);
    
    // Draw sun
    canvas.drawCircle(sunCenter, sunRadius, sunPaint);
    
    // Add subtle sun rays (responsive)
    final rayPaint = Paint()
      ..color = Colors.orange.withAlpha(128) // 0.5 opacity
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.5
      ..strokeCap = StrokeCap.round;
    
    // Draw 8 rays around the sun
    for (int i = 0; i < 8; i++) {
      final rayAngle = (i * pi / 4) + animationValue * 0.5; // Slowly rotating rays
      final rayStart = Offset(
        sunCenter.dx + rayOffset * cos(rayAngle),
        sunCenter.dy + rayOffset * sin(rayAngle),
      );
      final rayEnd = Offset(
        sunCenter.dx + rayLength * cos(rayAngle),
        sunCenter.dy + rayLength * sin(rayAngle),
      );
      canvas.drawLine(rayStart, rayEnd, rayPaint);
    }
  }
  
  @override
  bool shouldRepaint(SunArcProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.animationValue != animationValue;
  }
}

/// Custom painter for animated clouds
class CloudsPainter extends CustomPainter {
  final double animationValue;
  
  CloudsPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(204) // 0.8 opacity
      ..style = PaintingStyle.fill;
    
    // Draw several clouds moving across the sky
    final cloudPositions = [
      Offset(size.width * ((0.1 + animationValue * 0.5) % 1.2 - 0.1), size.height * 0.1),
      Offset(size.width * ((0.4 + animationValue * 0.3) % 1.2 - 0.1), size.height * 0.15),
      Offset(size.width * ((0.7 + animationValue * 0.4) % 1.2 - 0.1), size.height * 0.08),
    ];
    
    for (final position in cloudPositions) {
      _drawCloud(canvas, position, paint, 60);
    }
  }
  
  void _drawCloud(Canvas canvas, Offset center, Paint paint, double radius) {
    // Draw a cloud using multiple circles
    final cloudCircles = [
      Offset(center.dx - radius * 0.5, center.dy),
      Offset(center.dx + radius * 0.5, center.dy),
      Offset(center.dx, center.dy - radius * 0.3),
      Offset(center.dx - radius * 0.2, center.dy - radius * 0.5),
      Offset(center.dx + radius * 0.2, center.dy - radius * 0.5),
    ];
    
    for (final circleCenter in cloudCircles) {
      canvas.drawCircle(circleCenter, radius * 0.4, paint);
    }
  }
  
  @override
  bool shouldRepaint(CloudsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Animated ocean-themed button with gentle micro-interactions
class _AnimatedOceanButton extends StatefulWidget {
  final String text;
  final Color primaryColor;
  final Color accentColor;
  final VoidCallback onTap;
  final double height;
  final double width;

  const _AnimatedOceanButton({
    required this.text,
    required this.primaryColor,
    required this.accentColor,
    required this.onTap,
    required this.height,
    required this.width,
  });

  @override
  State<_AnimatedOceanButton> createState() => _AnimatedOceanButtonState();
}

class _AnimatedOceanButtonState extends State<_AnimatedOceanButton>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _pressController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Breathing animation (gentle pulsing)
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _breathingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    // Press animation
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeOut,
    ));

    // Start breathing animation
    _breathingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _pressController.reverse();
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathingAnimation, _scaleAnimation]),
      builder: (context, child) {
        final breathingScale = _breathingAnimation.value;
        final pressScale = _scaleAnimation.value;
        final combinedScale = breathingScale * pressScale;

        return Transform.scale(
          scale: combinedScale,
          child: Container(
            height: widget.height,
            width: widget.width,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                onTap: widget.onTap,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.primaryColor,
                        widget.accentColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: widget.primaryColor.withAlpha(64), // 25% opacity shadow
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withAlpha(51), // Subtle water surface effect
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'body'),
                        fontWeight: FontWeight.w600, // Softer than bold
                        color: ResearchVesselDeckWidget._offWhite,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

