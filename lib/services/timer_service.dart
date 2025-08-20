import 'dart:async';
import '../models/session.dart';
import 'persistence/persistence_service.dart';
import '../services/notification_service.dart';
import '../services/live_activities_service.dart';

class TimerService {
  static const int notificationUpdateIntervalSeconds = 30;
  static const int liveActivityUpdateIntervalSeconds = 10;
  
  static Future<void> saveSession({
    required DateTime sessionStartTime,
    required bool completed,
    required bool isStudySession,
    required int completedSessions,
    required int sessionsUntilLongBreak,
  }) async {
    final endTime = DateTime.now();
    final actualDuration = endTime.difference(sessionStartTime).inSeconds;
    
    SessionType sessionType;
    if (isStudySession) {
      sessionType = SessionType.focus;
    } else {
      final shouldUseLongBreak = completedSessions > 0 && 
          completedSessions % sessionsUntilLongBreak == 0;
      sessionType = shouldUseLongBreak ? SessionType.longBreak : SessionType.shortBreak;
    }

    final session = Session(
      startTime: sessionStartTime,
      endTime: endTime,
      duration: actualDuration,
      type: sessionType,
      completed: completed,
    );

    await PersistenceService.instance.sessions.saveSession(session);
  }
  
  static void startNotificationUpdates({
    required String sessionTitle,
    required int secondsRemaining,
    required bool isStudySession,
  }) {
    // Show notification with timer controls
    NotificationService().showTimerWithActions(
      title: sessionTitle,
      body: 'Timer running: ${formatTime(secondsRemaining)} remaining',
      isRunning: true,
    );
    
    // Schedule background timer check
    NotificationService().scheduleBackgroundTimerCheck(
      durationSeconds: secondsRemaining,
      isStudySession: isStudySession,
    );
  }
  
  static void updateNotificationIfNeeded({
    required String sessionTitle,
    required int secondsRemaining,
  }) {
    // Update notification every 30 seconds to avoid spam
    if (secondsRemaining % notificationUpdateIntervalSeconds == 0) {
      NotificationService().showTimerWithActions(
        title: sessionTitle,
        body: 'Timer running: ${formatTime(secondsRemaining)} remaining',
        isRunning: true,
      );
    }
  }
  
  static void startLiveActivity({
    required String sessionTitle,
    required int totalSeconds,
    required int remainingSeconds,
    required bool isStudySession,
  }) {
    LiveActivitiesService().startTimerActivity(
      sessionTitle: sessionTitle,
      totalSeconds: totalSeconds,
      remainingSeconds: remainingSeconds,
      isStudySession: isStudySession,
    );
  }
  
  static void updateLiveActivityIfNeeded({
    required String sessionTitle,
    required int totalSeconds,
    required int remainingSeconds,
    required bool isStudySession,
  }) {
    // Update Live Activity every 10 seconds
    if (remainingSeconds % liveActivityUpdateIntervalSeconds == 0) {
      LiveActivitiesService().updateTimerActivity(
        sessionTitle: sessionTitle,
        totalSeconds: totalSeconds,
        remainingSeconds: remainingSeconds,
        isRunning: true,
        isStudySession: isStudySession,
      );
    }
  }
  
  static void pauseNotifications({
    required String sessionTitle,
    required int remainingSeconds,
    required int totalSeconds,
    required bool isStudySession,
  }) {
    // Cancel background timer check
    NotificationService().cancelBackgroundTimerCheck();
    
    // Show paused notification
    NotificationService().showTimerWithActions(
      title: '⏸️ $sessionTitle Paused',
      body: 'Tap to resume: ${formatTime(remainingSeconds)} remaining',
      isRunning: false,
    );
    
    // Update Live Activity to paused state
    LiveActivitiesService().pauseTimerActivity(
      sessionTitle: sessionTitle,
      totalSeconds: totalSeconds,
      remainingSeconds: remainingSeconds,
      isStudySession: isStudySession,
    );
  }
  
  static void stopAllNotifications() {
    // Cancel notifications and background tasks
    NotificationService().cancelBackgroundTimerCheck();
    NotificationService().cancelAllNotifications();
    
    // End Live Activity
    LiveActivitiesService().endTimerActivity();
  }
  
  static void showCompletionNotification({
    required bool wasStudySession,
    required String? discoveredCreatureName,
    required int? discoveredCreaturePearlValue,
  }) {
    final notificationTitle = wasStudySession 
        ? (discoveredCreatureName != null 
            ? '🐠 New Creature Discovered!' 
            : '🪸 Coral Bloomed Beautifully!')
        : '🌊 Peaceful Currents Restored';
    
    final notificationBody = wasStudySession
        ? (discoveredCreatureName != null
            ? 'You discovered a $discoveredCreatureName! +$discoveredCreaturePearlValue pearls earned!'
            : 'Your coral garden is growing! Keep focusing to attract marine life.')
        : 'Ready for another dive into deep focus?';
    
    // Show completion notification
    NotificationService().showTimerNotification(
      title: notificationTitle,
      body: notificationBody,
      payload: 'session_completed',
    );
  }
  
  static void completeLiveActivity({
    required bool isStudySession,
    required String nextSessionType,
  }) {
    LiveActivitiesService().completeTimerActivity(
      isStudySession: isStudySession,
      nextSessionType: nextSessionType,
    );
  }
  
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  static String getSessionTitle(bool isStudySession, bool shouldUseLongBreak) {
    if (isStudySession) {
      return 'Research Dive';
    } else {
      return shouldUseLongBreak ? 'Extended Surface Rest' : 'Vessel Deck Break';
    }
  }
}