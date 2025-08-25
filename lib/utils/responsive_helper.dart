import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/responsive_constants.dart';

class ResponsiveHelper {
  // Screen size detection methods
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < ResponsiveBreakpoints.mobile;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= ResponsiveBreakpoints.mobile && 
           width < ResponsiveBreakpoints.tablet;
  }
  
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= ResponsiveBreakpoints.tablet && 
           width < ResponsiveBreakpoints.wideDesktop;
  }
  
  static bool isWideDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= ResponsiveBreakpoints.wideDesktop;
  }
  
  // Current app specific methods (maintaining existing behavior)
  static bool isCompactScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < ResponsiveBreakpoints.compact;
  }
  
  static bool isNarrowScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < ResponsiveBreakpoints.narrowScreen;
  }
  
  // Get current device category
  static DeviceScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < ResponsiveBreakpoints.mobile) {
      return DeviceScreenType.mobile;
    } else if (width < ResponsiveBreakpoints.tablet) {
      return DeviceScreenType.tablet;
    } else if (width < ResponsiveBreakpoints.wideDesktop) {
      return DeviceScreenType.desktop;
    } else {
      return DeviceScreenType.wideDesktop;
    }
  }
  
  // Font size helpers
  static double getResponsiveFontSize(BuildContext context, String component, {double? fallback}) {
    final screenType = getScreenType(context);
    final componentFonts = ResponsiveFontSizes.componentFonts[component];
    
    if (componentFonts == null) {
      return fallback ?? ResponsiveFontSizes.mobileBase;
    }
    
    switch (screenType) {
      case DeviceScreenType.mobile:
        return componentFonts['mobile'] ?? fallback ?? ResponsiveFontSizes.mobileBase;
      case DeviceScreenType.tablet:
        return componentFonts['tablet'] ?? fallback ?? ResponsiveFontSizes.tabletBase;
      case DeviceScreenType.desktop:
      case DeviceScreenType.wideDesktop:
        return componentFonts['desktop'] ?? fallback ?? ResponsiveFontSizes.desktopBase;
    }
  }
  
  static double getScaledFontSize(BuildContext context, double baseSize) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case DeviceScreenType.mobile:
        return baseSize * ResponsiveFontSizes.mobileScale;
      case DeviceScreenType.tablet:
        return baseSize * ResponsiveFontSizes.tabletScale;
      case DeviceScreenType.desktop:
        return baseSize * ResponsiveFontSizes.desktopScale;
      case DeviceScreenType.wideDesktop:
        return baseSize * ResponsiveFontSizes.wideDesktopScale;
    }
  }
  
  // Spacing helpers
  static double getResponsiveSpacing(BuildContext context, String component, {double? fallback}) {
    final screenType = getScreenType(context);
    final componentSpacing = ResponsiveSpacing.componentSpacing[component];
    
    if (componentSpacing == null) {
      return fallback ?? ResponsiveSpacing.md;
    }
    
    switch (screenType) {
      case DeviceScreenType.mobile:
        return componentSpacing['mobile'] ?? fallback ?? ResponsiveSpacing.md;
      case DeviceScreenType.tablet:
        return componentSpacing['tablet'] ?? fallback ?? ResponsiveSpacing.lg;
      case DeviceScreenType.desktop:
      case DeviceScreenType.wideDesktop:
        return componentSpacing['desktop'] ?? fallback ?? ResponsiveSpacing.xl;
    }
  }
  
  static double getScaledSpacing(BuildContext context, double baseSpacing) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case DeviceScreenType.mobile:
        return baseSpacing * ResponsiveSpacing.mobileMultiplier;
      case DeviceScreenType.tablet:
        return baseSpacing * ResponsiveSpacing.tabletMultiplier;
      case DeviceScreenType.desktop:
      case DeviceScreenType.wideDesktop:
        return baseSpacing * ResponsiveSpacing.desktopMultiplier;
    }
  }
  
  // Dimension helpers
  static double getButtonSize(BuildContext context, String size) {
    final screenType = getScreenType(context);
    final buttonSizes = ResponsiveDimensions.buttonSizes[size];
    
    if (buttonSizes == null) {
      return 44; // Default medium mobile size
    }
    
    switch (screenType) {
      case DeviceScreenType.mobile:
        return buttonSizes['mobile'] ?? 44;
      case DeviceScreenType.tablet:
        return buttonSizes['tablet'] ?? 48;
      case DeviceScreenType.desktop:
      case DeviceScreenType.wideDesktop:
        return buttonSizes['desktop'] ?? 52;
    }
  }
  
  static double getIconSize(BuildContext context, String size) {
    final screenType = getScreenType(context);
    final iconSizes = ResponsiveDimensions.iconSizes[size];
    
    if (iconSizes == null) {
      return 24; // Default medium mobile size
    }
    
    switch (screenType) {
      case DeviceScreenType.mobile:
        return iconSizes['mobile'] ?? 24;
      case DeviceScreenType.tablet:
        return iconSizes['tablet'] ?? 28;
      case DeviceScreenType.desktop:
      case DeviceScreenType.wideDesktop:
        return iconSizes['desktop'] ?? 32;
    }
  }
  
  static double getNavigationHeight(BuildContext context) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case DeviceScreenType.mobile:
        return ResponsiveDimensions.navigationHeights['mobile'] ?? 60;
      case DeviceScreenType.tablet:
        return ResponsiveDimensions.navigationHeights['tablet'] ?? 68;
      case DeviceScreenType.desktop:
      case DeviceScreenType.wideDesktop:
        return ResponsiveDimensions.navigationHeights['desktop'] ?? 76;
    }
  }
  
  // Grid layout helpers
  static int getGridCrossAxisCount(BuildContext context) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case DeviceScreenType.mobile:
        return ResponsiveDimensions.gridCrossAxisCount['mobile'] ?? 1;
      case DeviceScreenType.tablet:
        return ResponsiveDimensions.gridCrossAxisCount['tablet'] ?? 2;
      case DeviceScreenType.desktop:
        return ResponsiveDimensions.gridCrossAxisCount['desktop'] ?? 3;
      case DeviceScreenType.wideDesktop:
        return ResponsiveDimensions.gridCrossAxisCount['wideDesktop'] ?? 4;
    }
  }
  
  static double getGridAspectRatio(BuildContext context) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case DeviceScreenType.mobile:
        return ResponsiveDimensions.gridAspectRatios['mobile'] ?? 3.2;
      case DeviceScreenType.tablet:
        return ResponsiveDimensions.gridAspectRatios['tablet'] ?? 2.8;
      case DeviceScreenType.desktop:
      case DeviceScreenType.wideDesktop:
        return ResponsiveDimensions.gridAspectRatios['desktop'] ?? 2.5;
    }
  }
  
  // Animation helpers
  static Duration getAnimationDuration(BuildContext context) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case DeviceScreenType.mobile:
        return ResponsiveAnimations.animationDurations['mobile'] ?? 
               const Duration(milliseconds: 200);
      case DeviceScreenType.tablet:
        return ResponsiveAnimations.animationDurations['tablet'] ?? 
               const Duration(milliseconds: 250);
      case DeviceScreenType.desktop:
      case DeviceScreenType.wideDesktop:
        return ResponsiveAnimations.animationDurations['desktop'] ?? 
               const Duration(milliseconds: 300);
    }
  }
  
  static Duration getStaggerDelay(BuildContext context) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case DeviceScreenType.mobile:
        return ResponsiveAnimations.staggerDelays['mobile'] ?? 
               const Duration(milliseconds: 50);
      case DeviceScreenType.tablet:
        return ResponsiveAnimations.staggerDelays['tablet'] ?? 
               const Duration(milliseconds: 75);
      case DeviceScreenType.desktop:
      case DeviceScreenType.wideDesktop:
        return ResponsiveAnimations.staggerDelays['desktop'] ?? 
               const Duration(milliseconds: 100);
    }
  }
  
  // Utility methods for common responsive patterns
  static Widget responsiveBuilder({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
    Widget? wideDesktop,
  }) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case DeviceScreenType.mobile:
        return mobile;
      case DeviceScreenType.tablet:
        return tablet ?? mobile;
      case DeviceScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceScreenType.wideDesktop:
        return wideDesktop ?? desktop ?? tablet ?? mobile;
    }
  }
  
  static T responsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? wideDesktop,
  }) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case DeviceScreenType.mobile:
        return mobile;
      case DeviceScreenType.tablet:
        return tablet ?? mobile;
      case DeviceScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceScreenType.wideDesktop:
        return wideDesktop ?? desktop ?? tablet ?? mobile;
    }
  }
  
  // ScreenUtil integration helpers
  static double setWidth(double width) {
    return ScreenUtil().setWidth(width);
  }
  
  static double setHeight(double height) {
    return ScreenUtil().setHeight(height);
  }
  
  static double setSp(double fontSize) {
    return ScreenUtil().setSp(fontSize);
  }
  
  static double setRadius(double radius) {
    return ScreenUtil().radius(radius);
  }
}

enum DeviceScreenType {
  mobile,
  tablet,
  desktop,
  wideDesktop,
}