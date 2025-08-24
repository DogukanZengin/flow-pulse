import 'package:flutter/material.dart';

/// Ocean-themed color constants and gradients for the FlowPulse application
class OceanTheme {
  // Base ocean colors
  static const Color deepOceanBlue = Color(0xFF1B4D72);
  static const Color oceanSurface = Color(0xFF5DADE2);
  static const Color oceanCyan = Color(0xFF87CEEB);
  static const Color abyssal = Color(0xFF0B1426);
  static const Color midOcean = Color(0xFF2E86AB);
  
  // Biome-specific colors
  static const Color shallowWaterBlue = Color(0xFF87CEEB);
  static const Color coralGardenTeal = Color(0xFF48A38A);
  static const Color deepSeaNavy = Color(0xFF1B4D72);
  static const Color abyssalBlack = Color(0xFF0B1426);
  
  // Creature rarity colors
  static const Color commonGreen = Color(0xFF4CAF50);
  static const Color uncommonBlue = Color(0xFF2196F3);
  static const Color rarePurple = Color(0xFF9C27B0);
  static const Color legendaryOrange = Color(0xFFFF9800);
  
  // UI accent colors
  static const Color diveTeal = Color(0xFF26A69A);
  static const Color oxygenBlue = Color(0xFF42A5F5);
  static const Color warningOrange = Color(0xFFFF7043);
  static const Color dangerRed = Color(0xFFEF5350);
  static const Color successGreen = Color(0xFF66BB6A);
  
  // Focus and break session gradients
  static final List<Color> focusGradient = [
    deepOceanBlue,
    midOcean,
    oceanSurface,
  ];
  
  static final List<Color> breakGradient = [
    coralGardenTeal,
    Color(0xFF81C7D4),
    shallowWaterBlue,
  ];
  
  // Biome-specific gradients
  static final List<Color> shallowWaterGradient = [
    shallowWaterBlue,
    Color(0xFFA8E6CF),
    Color(0xFFE0F6FF),
  ];
  
  static final List<Color> coralGardenGradient = [
    coralGardenTeal,
    Color(0xFF7DD3C0),
    Color(0xFFB8F2E6),
  ];
  
  static final List<Color> deepOceanGradient = [
    deepOceanBlue,
    Color(0xFF2C5F7A),
    Color(0xFF3E7B99),
  ];
  
  static final List<Color> abyssalGradient = [
    abyssal,
    Color(0xFF1A2F4A),
    Color(0xFF2E4A6B),
  ];
  
  // Surface (break session) gradients
  static final List<Color> skyGradient = [
    Color(0xFF87CEEB), // Sky blue
    Color(0xFFB0E0E6), // Powder blue
    Color(0xFFE0F6FF), // Alice blue
  ];
  
  static final List<Color> sunsetGradient = [
    Color(0xFFFFB74D), // Orange
    Color(0xFFFF8A65), // Deep orange
    Color(0xFFFF7043), // Red orange
  ];
  
  // Research station UI gradients
  static final List<Color> equipmentGradient = [
    Color(0xFF263238), // Blue grey
    Color(0xFF37474F),
    Color(0xFF455A64),
  ];
  
  static final List<Color> researchGradient = [
    Color(0xFF1565C0), // Blue
    Color(0xFF1976D2),
    Color(0xFF1E88E5),
  ];
  
  static final List<Color> analyticsGradient = [
    Color(0xFF00695C), // Teal
    Color(0xFF00796B),
    Color(0xFF00897B),
  ];
  
  // Timer state colors
  static const Color timerNormal = Colors.white;
  static const Color timerWarning = warningOrange;
  static const Color timerCritical = dangerRed;
  static const Color timerPaused = Color(0xFFBDBDBD);
  
  // Depth indicator colors
  static final Map<String, Color> depthColors = {
    'shallow': shallowWaterBlue,
    'coral': coralGardenTeal,
    'deep': deepOceanBlue,
    'abyssal': abyssal,
  };
  
  // Achievement and rarity colors
  static final Map<String, Color> rarityColors = {
    'common': commonGreen,
    'uncommon': uncommonBlue,
    'rare': rarePurple,
    'legendary': legendaryOrange,
  };
  
  // Progress and completion colors
  static const Color progressBackground = Color(0xFF263238);
  static const Color progressForeground = oceanCyan;
  static const Color completedTask = successGreen;
  static const Color pendingTask = Color(0xFF757575);
  
  // Ocean particle colors
  static const Color planktonParticle = Color(0xFFE8F5E8);
  static const Color marineSnowParticle = Color(0xFFF0F8F0);
  static const Color bioluminescentParticle = Color(0xFF00FFFF);
  static const Color deepWaterParticle = Color(0xFF4A90A4);
  
  // Navigation and tab colors
  static const Color selectedTab = oceanCyan;
  static const Color unselectedTab = Color(0xFF90A4AE);
  static const Color tabBackground = Color(0xFF37474F);
  
  // Card and container colors
  static const Color cardBackground = Color(0x80263238); // 50% opacity
  static const Color containerBackground = Color(0xCC1B4D72); // 80% opacity
  static const Color overlayBackground = Color(0xE6000000); // 90% opacity
}