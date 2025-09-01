import 'package:flutter/material.dart';
import 'dart:math';
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
  late AnimationController _seabirdsController;
  late Animation<double> _waveAnimation;
  late Animation<double> _cloudsAnimation;
  late Animation<double> _seabirdsAnimation;
  
  // Surface wildlife that appears during breaks
  final List<SurfaceWildlife> _surfaceWildlife = [];
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSurfaceWildlife();
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
    
    _seabirdsController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    
    _waveAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_waveController);
    _cloudsAnimation = Tween<double>(begin: 0, end: 1).animate(_cloudsController);
    _seabirdsAnimation = Tween<double>(begin: 0, end: 1).animate(_seabirdsController);
  }
  
  void _initializeSurfaceWildlife() {
    // Add some seabirds
    _surfaceWildlife.addAll([
      SurfaceWildlife(
        type: SurfaceWildlifeType.pelican,
        position: Offset(0.1, 0.3),
        speed: 0.02,
        size: 0.8,
      ),
      SurfaceWildlife(
        type: SurfaceWildlifeType.seagull,
        position: Offset(0.7, 0.2),
        speed: 0.03,
        size: 0.6,
      ),
      SurfaceWildlife(
        type: SurfaceWildlifeType.dolphin,
        position: Offset(0.4, 0.8),
        speed: 0.01,
        size: 1.0,
      ),
    ]);
  }
  
  @override
  void dispose() {
    _waveController.dispose();
    _cloudsController.dispose();
    _seabirdsController.dispose();
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
          
          // Surface wildlife
          AnimatedBuilder(
            animation: _seabirdsAnimation,
            builder: (context, child) {
              return Stack(
                children: _surfaceWildlife.map((wildlife) {
                  final animatedPosition = _calculateWildlifePosition(wildlife, _seabirdsAnimation.value);
                  return Positioned(
                    left: animatedPosition.dx * screenSize.width,
                    top: animatedPosition.dy * screenSize.height,
                    child: _buildWildlifeWidget(wildlife),
                  );
                }).toList(),
              );
            },
          ),
          
          // Main content - Research vessel deck
          _buildDeckContent(context, screenSize),
        ],
      ),
    );
  }
  
  Offset _calculateWildlifePosition(SurfaceWildlife wildlife, double animationValue) {
    // Move wildlife across screen with gentle bobbing motion
    final progress = (wildlife.position.dx + animationValue * wildlife.speed) % 1.0;
    final bobbing = sin(animationValue * 2 * pi + wildlife.position.dy) * 0.02;
    return Offset(progress, wildlife.position.dy + bobbing);
  }
  
  Widget _buildWildlifeWidget(SurfaceWildlife wildlife) {
    IconData icon;
    Color color;
    
    switch (wildlife.type) {
      case SurfaceWildlifeType.pelican:
        icon = Icons.flutter_dash;
        color = Colors.brown;
        break;
      case SurfaceWildlifeType.seagull:
        icon = Icons.flutter_dash;
        color = Colors.grey[300]!;
        break;
      case SurfaceWildlifeType.dolphin:
        icon = Icons.waves;
        color = Colors.blue[300]!;
        break;
      case SurfaceWildlifeType.flyingFish:
        icon = Icons.air;
        color = Colors.grey[400]!;
        break;
    }
    
    return Icon(
      icon,
      size: 20 * wildlife.size,
      color: color,
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
      padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
      child: Row(
        children: [
          Expanded(
            child: Text(
              activity,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption') * 0.9,
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
          // Break title
          Text(
            '☕ Break Time',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'subtitle'),
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
          
          // Large timer display
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: ResponsiveHelper.isMobile(context) ? 36 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'monospace',
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
          
          // Progress bar
          Container(
            width: double.infinity,
            height: ResponsiveHelper.isMobile(context) ? 6 : 8,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(77), // 0.3 opacity
              borderRadius: BorderRadius.circular(ResponsiveHelper.isMobile(context) ? 3 : 4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(ResponsiveHelper.isMobile(context) ? 3 : 4),
                ),
              ),
            ),
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
          
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
          
          // Quick action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionButton(
                widget.isRunning ? '⏸️ Pause' : (widget.secondsRemaining == widget.totalBreakSeconds ? '▶️ Start' : '▶️ Resume'),
                widget.isRunning ? ResearchVesselDeckWidget._softOrange : ResearchVesselDeckWidget._softGreen,
                widget.onTap,
                isSmall: ResponsiveHelper.isMobile(context),
              ),
              _buildQuickActionButton(
                '🤿 End Break',
                ResearchVesselDeckWidget._cyan300,
                () => _endBreakEarly(),
                isSmall: ResponsiveHelper.isMobile(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActionButton(String text, Color color, VoidCallback onTap, {required bool isSmall}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsiveSpacing(context, isSmall ? 'navigation' : 'card'), 
          vertical: ResponsiveHelper.getResponsiveSpacing(context, 'navigation'),
        ),
        textStyle: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveSpacing(context, 'card')),
        ),
      ),
      child: Text(text),
    );
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
          Icon(Icons.wb_sunny, color: Colors.orange, size: ResponsiveHelper.getIconSize(context, 'small')),
          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
          Flexible(
            child: Text(
              '🌞 Vessel Deck Break 🌊',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
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
      title: '🌱 Step Away from Screen',
      child: Column(
        children: [
          Text(
            'Suggested break activities:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation')),
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
    final messages = [
      '🌊 Rest your mind like calm waters restore their depths',
      '🐠 Even fish need to pause in the current',
      '🌞 The ocean surface brings fresh perspective',
      '⚡ Recharge for your next deep dive',
      '🧠 Your brain processes discoveries during breaks',
    ];
    
    final randomMessage = messages[DateTime.now().millisecond % messages.length];
    
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
          Text(
            randomMessage,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
              color: Colors.blue[800],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
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
      padding: const EdgeInsets.all(8),
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
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'caption'),
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'element')),
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

/// Surface wildlife data model
class SurfaceWildlife {
  final SurfaceWildlifeType type;
  final Offset position;
  final double speed;
  final double size;
  
  SurfaceWildlife({
    required this.type,
    required this.position,
    required this.speed,
    required this.size,
  });
}

enum SurfaceWildlifeType {
  pelican,
  seagull,
  dolphin,
  flyingFish,
}