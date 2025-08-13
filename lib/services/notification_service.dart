import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static const String _timerChannelId = 'timer_channel';
  static const String _timerChannelName = 'Timer Notifications';
  static const String _timerChannelDescription = 'Notifications for timer updates';
  
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Android notification settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS notification settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestProvisionalPermission: false,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    await _createNotificationChannels();
    await _requestPermissions();
    
    // Initialize workmanager for background tasks
    if (!kIsWeb) {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: kDebugMode,
      );
    }
    
    _isInitialized = true;
  }
  
  Future<void> _createNotificationChannels() async {
    if (kIsWeb) return; // Skip notification channels on web
    
    const androidChannel = AndroidNotificationChannel(
      _timerChannelId,
      _timerChannelName,
      description: _timerChannelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );
    
    try {
      if (Platform.isAndroid) {
        await _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(androidChannel);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating notification channels: $e');
      }
    }
  }
  
  Future<void> _requestPermissions() async {
    if (kIsWeb) return; // Skip permissions on web
    
    try {
      if (Platform.isIOS) {
        await _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      } else if (Platform.isAndroid) {
        final androidImplementation = _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        await androidImplementation?.requestExactAlarmsPermission();
        await androidImplementation?.requestNotificationsPermission();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting permissions: $e');
      }
    }
  }
  
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // Handle notification tap - could navigate to specific screen
      if (kDebugMode) {
        print('Notification tapped with payload: $payload');
      }
    }
  }
  
  Future<void> showTimerNotification({
    required String title,
    required String body,
    String? payload,
    bool ongoing = false,
  }) async {
    if (kIsWeb) return; // Skip notifications on web
    if (!_isInitialized) await initialize();
    
    final androidDetails = AndroidNotificationDetails(
      _timerChannelId,
      _timerChannelName,
      channelDescription: _timerChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: ongoing,
      autoCancel: !ongoing,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );
    
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      0, // Use ID 0 for timer notifications to replace previous ones
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
  
  Future<void> showTimerWithActions({
    required String title,
    required String body,
    required bool isRunning,
    String? payload,
  }) async {
    if (kIsWeb) return; // Skip notifications on web
    if (!_isInitialized) await initialize();
    
    final androidDetails = AndroidNotificationDetails(
      _timerChannelId,
      _timerChannelName,
      channelDescription: _timerChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      actions: [
        AndroidNotificationAction(
          isRunning ? 'pause' : 'play',
          isRunning ? '⏸️ Pause' : '▶️ Play',
          allowGeneratedReplies: false,
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          'reset',
          '🔄 Reset',
          allowGeneratedReplies: false,
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          'open',
          '📱 Open App',
          allowGeneratedReplies: false,
          showsUserInterface: true,
        ),
      ],
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );
    
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      1, // Use ID 1 for timer with actions
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
  
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
  
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
  
  // Schedule background timer check
  Future<void> scheduleBackgroundTimerCheck({
    required int durationSeconds,
    required bool isStudySession,
  }) async {
    if (kIsWeb) return; // Background tasks not supported on web
    
    await Workmanager().registerOneOffTask(
      'timer_check',
      'timerCheck',
      inputData: {
        'duration': durationSeconds,
        'isStudySession': isStudySession,
        'startTime': DateTime.now().millisecondsSinceEpoch,
      },
      initialDelay: Duration(seconds: durationSeconds),
    );
  }
  
  Future<void> cancelBackgroundTimerCheck() async {
    if (kIsWeb) return;
    await Workmanager().cancelByUniqueName('timer_check');
  }
}

// Background task callback - runs when app is closed
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'timerCheck') {
      final duration = inputData?['duration'] as int? ?? 0;
      final isStudySession = inputData?['isStudySession'] as bool? ?? true;
      final startTime = inputData?['startTime'] as int? ?? 0;
      
      final elapsed = DateTime.now().millisecondsSinceEpoch - startTime;
      final remainingMs = (duration * 1000) - elapsed;
      
      if (remainingMs <= 0) {
        // Timer completed - show completion notification
        await NotificationService().showTimerNotification(
          title: 'Timer Completed! 🎉',
          body: isStudySession 
              ? 'Great work! Time for a well-deserved break.'
              : 'Break time is over. Ready to focus again?',
          payload: 'timer_completed',
        );
      }
      
      return Future.value(true);
    }
    
    return Future.value(false);
  });
}