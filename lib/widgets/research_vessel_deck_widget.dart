import 'package:flutter/material.dart';
import 'dart:math';
import '../models/aquarium.dart';
import '../models/creature.dart';

/// Research vessel deck environment for break sessions
/// Provides a bright, restful surface experience with rewards
class ResearchVesselDeckWidget extends StatefulWidget {
  final Aquarium aquarium;
  final int secondsRemaining;
  final int totalBreakSeconds;
  final bool isRunning;
  final List<Creature> recentDiscoveries;
  final VoidCallback onTap;
  final Function(String activity)? onActivityComplete;
  final bool isActualBreakSession; // true only during legitimate break sessions
  final bool followsWorkSession; // true only if this break follows a completed work session

  const ResearchVesselDeckWidget({
    super.key,
    required this.aquarium,
    required this.secondsRemaining,
    required this.totalBreakSeconds,
    required this.isRunning,
    required this.recentDiscoveries,
    required this.onTap,
    this.onActivityComplete,
    this.isActualBreakSession = true, // default to true for backwards compatibility
    this.followsWorkSession = true, // default to true for backwards compatibility
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
  
  // Activity tracking to prevent exploitation
  final Set<String> _completedActivitiesThisBreak = {};
  bool _breakSessionInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSurfaceWildlife();
    _initializeBreakSession();
  }
  
  void _initializeBreakSession() {
    // Reset activities for this new break session
    _completedActivitiesThisBreak.clear();
    _breakSessionInitialized = true;
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
            Color(0xFF87CEEB), // Sky blue
            Color(0xFFFFF8DC), // Cornsilk
            Color(0xFF00BFFF), // Deep sky blue
            Color(0xFF006994), // Ocean blue
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
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
        padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
        child: Column(
          children: [
            // Compact header
            _buildCompactHeader(),
            
            SizedBox(height: isSmallScreen ? 8 : 12),
            
            // Prominent break timer
            _buildBreakTimer(isSmallScreen),
            
            SizedBox(height: isSmallScreen ? 12 : 16),
            
            // Main content in scrollable area
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Main deck activity area - responsive layout
                    screenSize.width > 400 
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left side - Equipment station
                            Expanded(
                              child: _buildCompactEquipmentStation(),
                            ),
                            
                            const SizedBox(width: 12),
                            
                            // Right side - Observation deck
                            Expanded(
                              child: _buildCompactObservationDeck(),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildCompactEquipmentStation(),
                            const SizedBox(height: 12),
                            _buildCompactObservationDeck(),
                          ],
                        ),
                    
                    const SizedBox(height: 12),
                    
                    // Bottom row - Journal and weather (responsive)
                    screenSize.width > 400
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildCompactResearchJournal()),
                            const SizedBox(width: 12),
                            Expanded(child: _buildCompactWeatherStation()),
                          ],
                        )
                      : Column(
                          children: [
                            _buildCompactResearchJournal(),
                            const SizedBox(height: 12),
                            _buildCompactWeatherStation(),
                          ],
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEquipmentItem(String name, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(name, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWildlifeObservation(String name, String observation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(name, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(
            observation,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWeatherInfo(String condition, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(condition, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _completeActivity(String activityType) {
    // This method should only be called when activities are allowed
    // Button disabling prevents invalid calls, but adding safety check
    if (!_areActivitiesAllowed() || _completedActivitiesThisBreak.contains(activityType)) {
      return; // Silent fail - buttons should be disabled
    }

    // Initialize break session tracking if needed
    if (!_breakSessionInitialized) {
      _breakSessionInitialized = true;
      _completedActivitiesThisBreak.clear();
    }

    // Mark activity as completed for this break
    _completedActivitiesThisBreak.add(activityType);
    
    widget.onActivityComplete?.call(activityType);
    
    // Show only positive feedback for successful completions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_getActivityCompletionMessage(activityType)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  bool _areActivitiesAllowed() {
    // Activities are only allowed during actual break sessions that follow work sessions
    return widget.isActualBreakSession && widget.followsWorkSession;
  }
  
  bool _isActivityCompletedThisBreak(String activityType) {
    return _completedActivitiesThisBreak.contains(activityType);
  }
  
  
  String _getActivityCompletionMessage(String activityType) {
    switch (activityType) {
      case 'equipment_maintenance':
        return '🔧 Equipment maintained! Next dive will have +10% discovery rate';
      case 'wildlife_observation':
        return '🐬 Wildlife observed! +5 Surface Species XP earned';
      case 'journal_review':
        return '📖 Journal reviewed! +10 Research XP earned';
      case 'weather_monitoring':
        return '🌤️ Weather logged! Seasonal migration data unlocked';
      default:
        return '✅ Activity completed! Break rewards earned';
    }
  }

  // Break timer display - the core Pomodoro timer functionality
  Widget _buildBreakTimer(bool isSmallScreen) {
    final minutes = widget.secondsRemaining ~/ 60;
    final seconds = widget.secondsRemaining % 60;
    final progress = widget.secondsRemaining / widget.totalBreakSeconds;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue[400]!.withAlpha(204), // 0.8 opacity
            Colors.teal[300]!.withAlpha(179), // 0.7 opacity
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
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
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          // Large timer display
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: isSmallScreen ? 36 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'monospace',
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          // Progress bar
          Container(
            width: double.infinity,
            height: isSmallScreen ? 6 : 8,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(77), // 0.3 opacity
              borderRadius: BorderRadius.circular(isSmallScreen ? 3 : 4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 3 : 4),
                ),
              ),
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 6 : 8),
          
          // Break session info
          Text(
            'Relax and recharge on deck • ${widget.totalBreakSeconds ~/ 60} min break',
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : 13,
              color: Colors.white.withAlpha(230), // 0.9 opacity
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          // Quick action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionButton(
                widget.isRunning ? '⏸️ Pause' : '▶️ Resume',
                widget.isRunning ? Colors.orange[300]! : Colors.green[300]!,
                widget.onTap,
                isSmall: isSmallScreen,
              ),
              _buildQuickActionButton(
                '🤿 End Break',
                Colors.blue[300]!,
                () => _endBreakEarly(),
                isSmall: isSmallScreen,
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
          horizontal: isSmall ? 12 : 16, 
          vertical: isSmall ? 8 : 10,
        ),
        textStyle: TextStyle(
          fontSize: isSmall ? 11 : 13,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isSmall ? 12 : 15),
        ),
      ),
      child: Text(text),
    );
  }
  
  void _endBreakEarly() {
    // Could implement early break ending logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🤿 Break ended early - back to diving!'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
    widget.onTap(); // End the break
  }

  // Compact responsive methods for mobile screens  
  Widget _buildCompactHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
          const Icon(Icons.wb_sunny, color: Colors.orange, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '🌞 Vessel Deck Break 🌊',
              style: TextStyle(
                fontSize: 13,
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
  
  Widget _buildCompactEquipmentStation() {
    return _buildCompactCard(
      title: '🔧 Equipment',
      child: Column(
        children: [
          _buildEquipmentItem('🤿 Dive Gear', 'Ready', Colors.green),
          _buildEquipmentItem('📷 Camera', 'Clean', Colors.blue),
          const SizedBox(height: 8),
          _buildCompactActivityButton(
            '🔧 Maintain',
            () => _completeActivity('equipment_maintenance'),
            activityType: 'equipment_maintenance',
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompactObservationDeck() {
    return _buildCompactCard(
      title: '🔭 Wildlife',
      child: Column(
        children: [
          _buildWildlifeObservation('🐬 Dolphins', 'Spotted'),
          _buildWildlifeObservation('🐦 Seabirds', 'Flying'),
          const SizedBox(height: 8),
          _buildCompactActivityButton(
            '📝 Observe',
            () => _completeActivity('wildlife_observation'),
            activityType: 'wildlife_observation',
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompactResearchJournal() {
    return _buildCompactCard(
      title: '📖 Journal',
      child: Column(
        children: [
          Text(
            "Today's Discoveries:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          ...widget.recentDiscoveries.take(2).map(
            (creature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Text(
                '🐠 ${creature.name}',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildCompactActivityButton(
            '📖 Review',
            () => _completeActivity('journal_review'),
            activityType: 'journal_review',
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompactWeatherStation() {
    return _buildCompactCard(
      title: '🌤️ Weather',
      child: Column(
        children: [
          _buildWeatherInfo('☀️ Sunny', '78°F'),
          _buildWeatherInfo('🌊 Waves', '1-2ft'),
          const SizedBox(height: 8),
          _buildCompactActivityButton(
            '🌤️ Monitor',
            () => _completeActivity('weather_monitoring'),
            activityType: 'weather_monitoring',
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
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
  
  Widget _buildCompactActivityButton(String title, VoidCallback onTap, {String? activityType}) {
    final isDisabled = !_areActivitiesAllowed() || 
                      (activityType != null && _isActivityCompletedThisBreak(activityType));
    final isCompleted = activityType != null && _isActivityCompletedThisBreak(activityType);
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isCompleted 
              ? Colors.green[400] // Green for completed
              : isDisabled 
                  ? Colors.grey[300] // Light grey for not available
                  : Colors.blue[600], // Blue for available
          foregroundColor: isDisabled ? Colors.grey[600] : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 6),
          textStyle: const TextStyle(fontSize: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: isDisabled ? 0 : 2,
        ),
        child: Text(
          isCompleted ? '$title ✅' : title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isDisabled ? Colors.grey[600] : Colors.white,
          ),
        ),
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
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blue[300]!.withValues(alpha: 0.8),
          Colors.blue[600]!,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    // Create wave pattern
    final waveHeight = size.height * 0.3;
    final waveFrequency = 2 * pi / size.width;
    
    path.moveTo(0, size.height);
    
    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height - waveHeight * 0.5 * (1 + sin(waveFrequency * x + animationValue));
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Add foam/whitecaps
    final foamPaint = Paint()
      ..color = Colors.white.withAlpha(153) // 0.6 opacity
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final foamPath = Path();
    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height - waveHeight * 0.5 * (1 + sin(waveFrequency * x + animationValue)) - 5;
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