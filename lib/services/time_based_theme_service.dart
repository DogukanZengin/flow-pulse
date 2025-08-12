import 'package:flutter/material.dart';

class TimeBasedThemeService {
  static TimeBasedThemeService? _instance;
  static TimeBasedThemeService get instance {
    _instance ??= TimeBasedThemeService._();
    return _instance!;
  }
  
  TimeBasedThemeService._();
  
  // Get color scheme based on current time
  TimeOfDayColors getTimeBasedColors(bool isStudySession) {
    final now = DateTime.now();
    final hour = now.hour;
    
    if (hour >= 5 && hour < 9) {
      // Early morning (5 AM - 9 AM)
      return _getMorningColors(isStudySession);
    } else if (hour >= 9 && hour < 12) {
      // Late morning (9 AM - 12 PM)
      return _getLateMorningColors(isStudySession);
    } else if (hour >= 12 && hour < 17) {
      // Afternoon (12 PM - 5 PM)
      return _getAfternoonColors(isStudySession);
    } else if (hour >= 17 && hour < 20) {
      // Evening (5 PM - 8 PM)
      return _getEveningColors(isStudySession);
    } else if (hour >= 20 && hour < 23) {
      // Night (8 PM - 11 PM)
      return _getNightColors(isStudySession);
    } else {
      // Late night (11 PM - 5 AM)
      return _getLateNightColors(isStudySession);
    }
  }
  
  TimeOfDayColors _getMorningColors(bool isStudySession) {
    if (isStudySession) {
      return TimeOfDayColors(
        primaryGradient: [
          const Color(0xFF667eea), // Soft purple-blue
          const Color(0xFF764ba2), // Gentle purple
        ],
        secondaryGradient: [
          const Color(0xFF8E9EAB), // Morning mist
          const Color(0xFFEEF2F3), // Light fog
        ],
        particleColors: [
          Colors.purple.shade200,
          Colors.blue.shade200,
          const Color(0xFFFDB99B), // Morning peach
        ],
        ambientOpacity: 0.3,
        description: 'Morning Focus',
      );
    } else {
      return TimeOfDayColors(
        primaryGradient: [
          const Color(0xFFFDB99B), // Peach
          const Color(0xFFFC9F7F), // Coral peach
        ],
        secondaryGradient: [
          const Color(0xFFFEDA77), // Soft yellow
          const Color(0xFFFFE5B4), // Peach cream
        ],
        particleColors: [
          Colors.orange.shade200,
          Colors.yellow.shade200,
          const Color(0xFFFFD4A3), // Morning glow
        ],
        ambientOpacity: 0.35,
        description: 'Morning Break',
      );
    }
  }
  
  TimeOfDayColors _getLateMorningColors(bool isStudySession) {
    if (isStudySession) {
      return TimeOfDayColors(
        primaryGradient: [
          const Color(0xFF4776E6), // Bright blue
          const Color(0xFF8E54E9), // Vibrant purple
        ],
        secondaryGradient: [
          const Color(0xFF74B9FF), // Sky blue
          const Color(0xFFA29BFE), // Lavender
        ],
        particleColors: [
          Colors.blue.shade300,
          Colors.indigo.shade300,
          Colors.purple.shade200,
        ],
        ambientOpacity: 0.25,
        description: 'Peak Focus',
      );
    } else {
      return TimeOfDayColors(
        primaryGradient: [
          const Color(0xFFFFA502), // Bright orange
          const Color(0xFFFFD32C), // Golden yellow
        ],
        secondaryGradient: [
          const Color(0xFFFFE77A), // Light yellow
          const Color(0xFFFFC048), // Golden
        ],
        particleColors: [
          Colors.yellow.shade300,
          Colors.orange.shade300,
          Colors.amber.shade200,
        ],
        ambientOpacity: 0.3,
        description: 'Energizing Break',
      );
    }
  }
  
  TimeOfDayColors _getAfternoonColors(bool isStudySession) {
    if (isStudySession) {
      return TimeOfDayColors(
        primaryGradient: [
          const Color(0xFF6B5B95), // Default purple
          const Color(0xFF88B0D3), // Default blue
        ],
        secondaryGradient: [
          const Color(0xFF7C6BA0),
          const Color(0xFF98C0E3),
        ],
        particleColors: [
          Colors.purple.shade200,
          Colors.blue.shade200,
          Colors.indigo.shade200,
        ],
        ambientOpacity: 0.28,
        description: 'Afternoon Focus',
      );
    } else {
      return TimeOfDayColors(
        primaryGradient: [
          const Color(0xFFFF6B6B), // Default coral
          const Color(0xFFFECA57), // Default yellow
        ],
        secondaryGradient: [
          const Color(0xFFFF8B8B),
          const Color(0xFFFFDA77),
        ],
        particleColors: [
          Colors.orange.shade200,
          Colors.yellow.shade200,
          Colors.pink.shade200,
        ],
        ambientOpacity: 0.32,
        description: 'Afternoon Recharge',
      );
    }
  }
  
  TimeOfDayColors _getEveningColors(bool isStudySession) {
    if (isStudySession) {
      return TimeOfDayColors(
        primaryGradient: [
          const Color(0xFF834d9b), // Deep purple
          const Color(0xFFd04ed6), // Magenta purple
        ],
        secondaryGradient: [
          const Color(0xFF9D50BB), // Purple sunset
          const Color(0xFF6E48AA), // Deep violet
        ],
        particleColors: [
          Colors.purple.shade300,
          Colors.pink.shade300,
          Colors.deepPurple.shade200,
        ],
        ambientOpacity: 0.35,
        description: 'Evening Deep Work',
      );
    } else {
      return TimeOfDayColors(
        primaryGradient: [
          const Color(0xFFFF512F), // Sunset red
          const Color(0xFFDD2476), // Pink red
        ],
        secondaryGradient: [
          const Color(0xFFFF6B6B),
          const Color(0xFFFF8E53),
        ],
        particleColors: [
          Colors.red.shade200,
          Colors.orange.shade300,
          Colors.pink.shade200,
        ],
        ambientOpacity: 0.38,
        description: 'Sunset Relaxation',
      );
    }
  }
  
  TimeOfDayColors _getNightColors(bool isStudySession) {
    if (isStudySession) {
      return TimeOfDayColors(
        primaryGradient: [
          const Color(0xFF434343), // Dark grey
          const Color(0xFF2C3E50), // Dark blue-grey
        ],
        secondaryGradient: [
          const Color(0xFF1e3c72), // Deep blue
          const Color(0xFF2a5298), // Night blue
        ],
        particleColors: [
          Colors.blue.shade900.withOpacity(0.5),
          Colors.indigo.shade900.withOpacity(0.5),
          Colors.grey.shade700.withOpacity(0.5),
        ],
        ambientOpacity: 0.2,
        description: 'Night Focus',
      );
    } else {
      return TimeOfDayColors(
        primaryGradient: [
          const Color(0xFF536976), // Soft grey-blue
          const Color(0xFF292E49), // Dark purple-blue
        ],
        secondaryGradient: [
          const Color(0xFF373B44),
          const Color(0xFF4286f4),
        ],
        particleColors: [
          Colors.blue.shade800.withOpacity(0.5),
          Colors.grey.shade600.withOpacity(0.5),
          Colors.indigo.shade800.withOpacity(0.5),
        ],
        ambientOpacity: 0.25,
        description: 'Night Rest',
      );
    }
  }
  
  TimeOfDayColors _getLateNightColors(bool isStudySession) {
    if (isStudySession) {
      return TimeOfDayColors(
        primaryGradient: [
          const Color(0xFF0F2027), // Very dark blue
          const Color(0xFF203A43), // Dark teal
        ],
        secondaryGradient: [
          const Color(0xFF2C5364), // Midnight blue
          const Color(0xFF0F2027),
        ],
        particleColors: [
          Colors.blue.shade900.withOpacity(0.3),
          Colors.grey.shade900.withOpacity(0.3),
          Colors.indigo.shade900.withOpacity(0.3),
        ],
        ambientOpacity: 0.15,
        description: 'Midnight Focus',
      );
    } else {
      return TimeOfDayColors(
        primaryGradient: [
          const Color(0xFF141E30), // Deep night blue
          const Color(0xFF243B55), // Dark slate
        ],
        secondaryGradient: [
          const Color(0xFF1D2B64), // Deep indigo
          const Color(0xFF1e3c72),
        ],
        particleColors: [
          Colors.blue.shade900.withOpacity(0.3),
          Colors.indigo.shade900.withOpacity(0.3),
          Colors.purple.shade900.withOpacity(0.3),
        ],
        ambientOpacity: 0.18,
        description: 'Midnight Rest',
      );
    }
  }
  
  String getTimeOfDayMessage() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 9) {
      return 'Good morning! Start your day with focus';
    } else if (hour >= 9 && hour < 12) {
      return 'Peak productivity hours ahead';
    } else if (hour >= 12 && hour < 17) {
      return 'Keep the momentum going';
    } else if (hour >= 17 && hour < 20) {
      return 'Evening deep work session';
    } else if (hour >= 20 && hour < 23) {
      return 'Wind down with mindful focus';
    } else {
      return 'Late night productivity mode';
    }
  }
}

class TimeOfDayColors {
  final List<Color> primaryGradient;
  final List<Color> secondaryGradient;
  final List<Color> particleColors;
  final double ambientOpacity;
  final String description;
  
  TimeOfDayColors({
    required this.primaryGradient,
    required this.secondaryGradient,
    required this.particleColors,
    required this.ambientOpacity,
    required this.description,
  });
}