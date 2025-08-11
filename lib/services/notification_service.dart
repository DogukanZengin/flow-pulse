import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/app_user.dart';
import 'auth_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize the notification service
  Future<void> initialize() async {
    try {
      // Request permission for notifications
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('User granted notification permission');

        // Get FCM token
        _fcmToken = await _messaging.getToken();
        debugPrint('FCM Token: $_fcmToken');

        if (_fcmToken != null && _authService.currentUser != null) {
          await _saveFCMToken(_fcmToken!);
        }

        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          if (_authService.currentUser != null) {
            _saveFCMToken(newToken);
          }
        });

        // Set up message handlers
        _setupMessageHandlers();
      } else {
        debugPrint('User declined notification permission');
      }
    } catch (e) {
      debugPrint('Initialize notifications error: $e');
    }
  }

  /// Set up message handlers for different app states
  void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received foreground message: ${message.messageId}');
      _handleForegroundMessage(message);
    });

    // Handle messages when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message opened from background: ${message.messageId}');
      _handleMessageTap(message);
    });

    // Check for initial message when app is launched from terminated state
    _checkInitialMessage();
  }

  /// Handle messages when app is in foreground
  void _handleForegroundMessage(RemoteMessage message) {
    if (message.notification != null) {
      // Show in-app notification or custom UI
      _showInAppNotification(message);
    }

    // Handle data payload
    if (message.data.isNotEmpty) {
      _handleNotificationData(message.data);
    }
  }

  /// Handle message tap navigation
  void _handleMessageTap(RemoteMessage message) {
    if (message.data.isNotEmpty) {
      _handleNotificationData(message.data);
      _navigateFromNotification(message.data);
    }
  }

  /// Check for initial message when app is launched
  Future<void> _checkInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App launched from notification: ${initialMessage.messageId}');
      _handleMessageTap(initialMessage);
    }
  }

  /// Save FCM token to user document
  Future<void> _saveFCMToken(String token) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    try {
      await _firestore.collection('users').doc(currentUser.id).update({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Save FCM token error: $e');
    }
  }

  /// Send notification to specific user
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, String>? data,
    NotificationType type = NotificationType.general,
  }) async {
    try {
      // Get user's FCM token
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data()!;
      final fcmToken = userData['fcmToken'] as String?;
      if (fcmToken == null) return;

      // Create notification document for tracking
      await _firestore.collection('notifications').add({
        'recipientId': userId,
        'senderId': _authService.currentUser?.id,
        'title': title,
        'body': body,
        'type': type.toString(),
        'data': data ?? {},
        'status': 'sent',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Note: Actual sending would be done by Cloud Functions
      // This is a placeholder for the notification structure
      debugPrint('Notification queued for user $userId: $title');
    } catch (e) {
      debugPrint('Send notification error: $e');
    }
  }

  /// Send friend request notification
  Future<void> sendFriendRequestNotification(String targetUserId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    await sendNotificationToUser(
      userId: targetUserId,
      title: 'New Friend Request',
      body: '${currentUser.displayName} sent you a friend request',
      data: {
        'type': NotificationType.friendRequest.toString(),
        'senderId': currentUser.id,
        'action': 'friend_request',
      },
      type: NotificationType.friendRequest,
    );
  }

  /// Send team session invite notification
  Future<void> sendTeamSessionInviteNotification({
    required String targetUserId,
    required String sessionName,
    required String sessionId,
  }) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    await sendNotificationToUser(
      userId: targetUserId,
      title: 'Team Session Invite',
      body: '${currentUser.displayName} invited you to join "$sessionName"',
      data: {
        'type': NotificationType.teamInvite.toString(),
        'sessionId': sessionId,
        'sessionName': sessionName,
        'senderId': currentUser.id,
        'action': 'team_invite',
      },
      type: NotificationType.teamInvite,
    );
  }

  /// Send achievement unlock notification
  Future<void> sendAchievementNotification({
    required String title,
    required String description,
    String? achievementId,
  }) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    await sendNotificationToUser(
      userId: currentUser.id,
      title: 'Achievement Unlocked! 🎉',
      body: 'You unlocked "$title"',
      data: {
        'type': NotificationType.achievement.toString(),
        'achievementId': achievementId ?? '',
        'title': title,
        'description': description,
        'action': 'achievement_unlocked',
      },
      type: NotificationType.achievement,
    );
  }

  /// Send session reminder notification
  Future<void> sendSessionReminderNotification() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    await sendNotificationToUser(
      userId: currentUser.id,
      title: 'Time to Focus! ⏰',
      body: "Don't break your streak - start a focus session",
      data: {
        'type': NotificationType.reminder.toString(),
        'action': 'session_reminder',
      },
      type: NotificationType.reminder,
    );
  }

  /// Send leaderboard update notification
  Future<void> sendLeaderboardUpdateNotification({
    required int newRank,
    required String leaderboardType,
  }) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    String message;
    if (newRank <= 3) {
      message = 'You\'re now #$newRank on the $leaderboardType leaderboard! 🏆';
    } else if (newRank <= 10) {
      message = 'You moved up to #$newRank on the $leaderboardType leaderboard! 📈';
    } else {
      message = 'Your rank improved to #$newRank on the $leaderboardType leaderboard!';
    }

    await sendNotificationToUser(
      userId: currentUser.id,
      title: 'Rank Update!',
      body: message,
      data: {
        'type': NotificationType.leaderboard.toString(),
        'rank': newRank.toString(),
        'leaderboardType': leaderboardType,
        'action': 'leaderboard_update',
      },
      type: NotificationType.leaderboard,
    );
  }

  /// Get user's notifications
  Future<List<AppNotification>> getUserNotifications({int limit = 50}) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: currentUser.id)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => AppNotification.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('Get notifications error: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('Mark notification as read error: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    try {
      final batch = _firestore.batch();
      
      final unreadDocs = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: currentUser.id)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in unreadDocs.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Mark all notifications as read error: $e');
    }
  }

  /// Get unread notification count
  Future<int> getUnreadNotificationCount() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return 0;

    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: currentUser.id)
          .where('isRead', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      debugPrint('Get unread count error: $e');
      return 0;
    }
  }

  /// Handle notification data payload
  void _handleNotificationData(Map<String, dynamic> data) {
    final type = data['type'];
    debugPrint('Handling notification data: $type');

    // Store notification data for later use
    // This could trigger UI updates or state changes
  }

  /// Navigate based on notification data
  void _navigateFromNotification(Map<String, dynamic> data) {
    final action = data['action'];
    
    switch (action) {
      case 'friend_request':
        // Navigate to friends screen
        break;
      case 'team_invite':
        // Navigate to team sessions screen
        break;
      case 'achievement_unlocked':
        // Navigate to achievements screen
        break;
      case 'session_reminder':
        // Navigate to timer screen
        break;
      case 'leaderboard_update':
        // Navigate to leaderboards screen
        break;
    }
  }

  /// Show in-app notification (custom implementation)
  void _showInAppNotification(RemoteMessage message) {
    // This would show a custom in-app notification UI
    // For now, it's a placeholder
    debugPrint('Showing in-app notification: ${message.notification?.title}');
  }

  /// Subscribe to topic for broadcast notifications
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Subscribe to topic error: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Unsubscribe from topic error: $e');
    }
  }

  /// Enable/disable notifications
  Future<void> updateNotificationSettings({
    bool? friendRequests,
    bool? teamInvites,
    bool? achievements,
    bool? reminders,
    bool? leaderboardUpdates,
  }) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    try {
      final updates = <String, dynamic>{};
      
      if (friendRequests != null) {
        updates['notificationSettings.friendRequests'] = friendRequests;
      }
      if (teamInvites != null) {
        updates['notificationSettings.teamInvites'] = teamInvites;
      }
      if (achievements != null) {
        updates['notificationSettings.achievements'] = achievements;
      }
      if (reminders != null) {
        updates['notificationSettings.reminders'] = reminders;
      }
      if (leaderboardUpdates != null) {
        updates['notificationSettings.leaderboardUpdates'] = leaderboardUpdates;
      }

      if (updates.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(currentUser.id)
            .update(updates);
      }
    } catch (e) {
      debugPrint('Update notification settings error: $e');
    }
  }

  /// Clear FCM token on sign out
  Future<void> clearToken() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    try {
      await _firestore.collection('users').doc(currentUser.id).update({
        'fcmToken': null,
      });
      
      await _messaging.deleteToken();
      _fcmToken = null;
    } catch (e) {
      debugPrint('Clear FCM token error: $e');
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
}

enum NotificationType {
  general,
  friendRequest,
  teamInvite,
  achievement,
  reminder,
  leaderboard,
  sessionStart,
  sessionEnd,
}

class AppNotification {
  final String id;
  final String recipientId;
  final String? senderId;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.recipientId,
    this.senderId,
    required this.title,
    required this.body,
    required this.type,
    this.data = const {},
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipientId': recipientId,
      'senderId': senderId,
      'title': title,
      'body': body,
      'type': type.toString(),
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] ?? '',
      recipientId: map['recipientId'] ?? '',
      senderId: map['senderId'],
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => NotificationType.general,
      ),
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class NotificationSettings {
  final bool friendRequests;
  final bool teamInvites;
  final bool achievements;
  final bool reminders;
  final bool leaderboardUpdates;

  NotificationSettings({
    this.friendRequests = true,
    this.teamInvites = true,
    this.achievements = true,
    this.reminders = true,
    this.leaderboardUpdates = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'friendRequests': friendRequests,
      'teamInvites': teamInvites,
      'achievements': achievements,
      'reminders': reminders,
      'leaderboardUpdates': leaderboardUpdates,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      friendRequests: map['friendRequests'] ?? true,
      teamInvites: map['teamInvites'] ?? true,
      achievements: map['achievements'] ?? true,
      reminders: map['reminders'] ?? true,
      leaderboardUpdates: map['leaderboardUpdates'] ?? true,
    );
  }
}