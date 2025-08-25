class ResponsiveBreakpoints {
  // Screen width breakpoints
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
  static const double wideDesktop = 1920;
  
  // Compact screen detection (current app usage)
  static const double compact = 400;
  
  // Ocean theme specific breakpoints
  static const double narrowScreen = 375; // iPhone SE and similar
  static const double standardScreen = 414; // iPhone Pro
  static const double largeScreen = 428; // iPhone Pro Max
}

class ResponsiveFontSizes {
  // Base font sizes for different screen categories
  static const double mobileBase = 14;
  static const double tabletBase = 16;
  static const double desktopBase = 18;
  
  // Font scale multipliers
  static const double mobileScale = 1.0;
  static const double tabletScale = 1.1;
  static const double desktopScale = 1.2;
  static const double wideDesktopScale = 1.3;
  
  // Specific component font sizes
  static const Map<String, Map<String, double>> componentFonts = {
    'navigation': {
      'mobile': 8,
      'tablet': 10,
      'desktop': 12,
    },
    'title': {
      'mobile': 16,
      'tablet': 18,
      'desktop': 20,
    },
    'subtitle': {
      'mobile': 14,
      'tablet': 16,
      'desktop': 18,
    },
    'body': {
      'mobile': 12,
      'tablet': 14,
      'desktop': 16,
    },
    'caption': {
      'mobile': 10,
      'tablet': 12,
      'desktop': 14,
    },
  };
}

class ResponsiveSpacing {
  // Base spacing units
  static const double baseUnit = 8.0;
  
  // Multipliers for different screen sizes
  static const double mobileMultiplier = 1.0;
  static const double tabletMultiplier = 1.25;
  static const double desktopMultiplier = 1.5;
  
  // Common spacing values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  // Component specific spacing
  static const Map<String, Map<String, double>> componentSpacing = {
    'navigation': {
      'mobile': 4,
      'tablet': 8,
      'desktop': 12,
    },
    'card': {
      'mobile': 12,
      'tablet': 16,
      'desktop': 20,
    },
    'screen': {
      'mobile': 16,
      'tablet': 24,
      'desktop': 32,
    },
  };
}

class ResponsiveDimensions {
  // Button dimensions
  static const Map<String, Map<String, double>> buttonSizes = {
    'small': {
      'mobile': 32,
      'tablet': 36,
      'desktop': 40,
    },
    'medium': {
      'mobile': 44,
      'tablet': 48,
      'desktop': 52,
    },
    'large': {
      'mobile': 56,
      'tablet': 64,
      'desktop': 72,
    },
  };
  
  // Icon sizes
  static const Map<String, Map<String, double>> iconSizes = {
    'small': {
      'mobile': 16,
      'tablet': 18,
      'desktop': 20,
    },
    'medium': {
      'mobile': 24,
      'tablet': 28,
      'desktop': 32,
    },
    'large': {
      'mobile': 32,
      'tablet': 36,
      'desktop': 40,
    },
  };
  
  // Avatar/Image sizes
  static const Map<String, Map<String, double>> avatarSizes = {
    'small': {
      'mobile': 32,
      'tablet': 36,
      'desktop': 40,
    },
    'medium': {
      'mobile': 48,
      'tablet': 56,
      'desktop': 64,
    },
    'large': {
      'mobile': 80,
      'tablet': 96,
      'desktop': 112,
    },
  };
  
  // Navigation bar heights
  static const Map<String, double> navigationHeights = {
    'mobile': 60,
    'tablet': 68,
    'desktop': 76,
  };
  
  // Grid and layout
  static const Map<String, int> gridCrossAxisCount = {
    'mobile': 1,
    'tablet': 2,
    'desktop': 3,
    'wideDesktop': 4,
  };
  
  static const Map<String, double> gridAspectRatios = {
    'mobile': 3.2,
    'tablet': 2.8,
    'desktop': 2.5,
  };
}

class ResponsiveAnimations {
  // Animation durations based on screen size
  static const Map<String, Duration> animationDurations = {
    'mobile': Duration(milliseconds: 200),
    'tablet': Duration(milliseconds: 250),
    'desktop': Duration(milliseconds: 300),
  };
  
  // Stagger delays for list animations
  static const Map<String, Duration> staggerDelays = {
    'mobile': Duration(milliseconds: 50),
    'tablet': Duration(milliseconds: 75),
    'desktop': Duration(milliseconds: 100),
  };
}