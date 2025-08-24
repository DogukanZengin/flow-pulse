/// Timer-related constants for the FlowPulse application
class TimerConstants {
  // Default timer durations
  static const Duration defaultFocusDuration = Duration(minutes: 25);
  static const Duration shortBreakDuration = Duration(minutes: 5);
  static const Duration longBreakDuration = Duration(minutes: 15);
  
  // Extended focus durations
  static const Duration extendedFocusDuration = Duration(minutes: 50);
  static const Duration deepFocusDuration = Duration(minutes: 90);
  
  // Update intervals
  static const int notificationUpdateIntervalSeconds = 30;
  static const int liveActivityUpdateIntervalSeconds = 10;
  static const int timerUpdateIntervalSeconds = 1;
  
  // Session thresholds
  static const int longSessionThresholdMinutes = 45;
  static const int shortSessionThresholdMinutes = 15;
  
  // Break intervals (Pomodoro technique)
  static const int sessionsBeforeLongBreak = 4;
  
  // UI update intervals
  static const int progressUpdateIntervalMilliseconds = 100;
  static const int animationUpdateIntervalMilliseconds = 16; // ~60fps
  
  // Ocean depth mapping (minutes to meters)
  static const Map<int, int> sessionToDepthMapping = {
    15: 5,   // Shallow Water Research
    20: 10,  // Shallow Water Research
    25: 15,  // Mid-Water Expedition
    30: 20,  // Mid-Water Expedition
    45: 30,  // Deep Sea Research
    50: 35,  // Deep Sea Research
    60: 40,  // Deep Sea Research
    90: 50,  // Abyssal Expedition
  };
  
  // Minimum and maximum session durations (in minutes)
  static const int minimumSessionMinutes = 5;
  static const int maximumSessionMinutes = 120;
  
  // Timer warning thresholds
  static const Duration warningThreshold = Duration(minutes: 5);
  static const Duration criticalThreshold = Duration(minutes: 1);
  
  // Session completion bonus XP
  static const int completedSessionBonusXP = 10;
  static const int perfectSessionBonusXP = 25; // No interruptions
}