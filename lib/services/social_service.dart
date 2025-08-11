import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import '../models/app_user.dart';
import 'auth_service.dart';

class SocialService {
  static final SocialService _instance = SocialService._internal();
  factory SocialService() => _instance;
  SocialService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // ===== FRIEND SYSTEM =====

  /// Send a friend request
  Future<bool> sendFriendRequest(String targetUserId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    if (currentUser.id == targetUserId) {
      throw Exception('Cannot send friend request to yourself');
    }

    try {
      // Check if friendship already exists
      final existingFriendship = await _getFriendship(currentUser.id, targetUserId);
      if (existingFriendship != null) {
        switch (existingFriendship.status) {
          case FriendshipStatus.friends:
            throw Exception('Already friends');
          case FriendshipStatus.requestSent:
            if (existingFriendship.requestedBy == currentUser.id) {
              throw Exception('Friend request already sent');
            }
            break;
          case FriendshipStatus.requestReceived:
            if (existingFriendship.requestedBy != currentUser.id) {
              throw Exception('You have a pending request from this user');
            }
            break;
          case FriendshipStatus.blocked:
            throw Exception('Cannot send request to blocked user');
          default:
            break;
        }
      }

      // Check if target user allows friend requests
      final targetUser = await _authService.getUserById(targetUserId);
      if (targetUser == null || !targetUser.allowFriendRequests) {
        throw Exception('User does not allow friend requests');
      }

      // Create or update friendship document
      final friendshipId = _generateFriendshipId(currentUser.id, targetUserId);
      final friendship = Friendship(
        id: friendshipId,
        userId1: currentUser.id,
        userId2: targetUserId,
        status: FriendshipStatus.requestSent,
        requestedBy: currentUser.id,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('friendships')
          .doc(friendshipId)
          .set(friendship.toMap());

      // TODO: Send push notification to target user
      return true;
    } catch (e) {
      debugPrint('Send friend request error: $e');
      if (e is Exception) rethrow;
      throw Exception('Failed to send friend request');
    }
  }

  /// Accept a friend request
  Future<bool> acceptFriendRequest(String fromUserId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      final friendship = await _getFriendship(currentUser.id, fromUserId);
      if (friendship == null) {
        throw Exception('No friend request found');
      }

      if (friendship.status != FriendshipStatus.requestSent || 
          friendship.requestedBy != fromUserId) {
        throw Exception('No pending request from this user');
      }

      // Update friendship status
      await _firestore
          .collection('friendships')
          .doc(friendship.id)
          .update({
        'status': FriendshipStatus.friends.index,
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      // Add to both users' friend lists
      await _firestore.collection('users').doc(currentUser.id).update({
        'friendIds': FieldValue.arrayUnion([fromUserId]),
      });

      await _firestore.collection('users').doc(fromUserId).update({
        'friendIds': FieldValue.arrayUnion([currentUser.id]),
      });

      // TODO: Send push notification to requester
      return true;
    } catch (e) {
      debugPrint('Accept friend request error: $e');
      if (e is Exception) rethrow;
      throw Exception('Failed to accept friend request');
    }
  }

  /// Decline a friend request
  Future<bool> declineFriendRequest(String fromUserId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      final friendship = await _getFriendship(currentUser.id, fromUserId);
      if (friendship == null) {
        throw Exception('No friend request found');
      }

      // Delete the friendship document
      await _firestore
          .collection('friendships')
          .doc(friendship.id)
          .delete();

      return true;
    } catch (e) {
      debugPrint('Decline friend request error: $e');
      throw Exception('Failed to decline friend request');
    }
  }

  /// Remove a friend
  Future<bool> removeFriend(String friendId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      final friendship = await _getFriendship(currentUser.id, friendId);
      if (friendship == null || friendship.status != FriendshipStatus.friends) {
        throw Exception('Not friends with this user');
      }

      // Delete friendship document
      await _firestore
          .collection('friendships')
          .doc(friendship.id)
          .delete();

      // Remove from both users' friend lists
      await _firestore.collection('users').doc(currentUser.id).update({
        'friendIds': FieldValue.arrayRemove([friendId]),
      });

      await _firestore.collection('users').doc(friendId).update({
        'friendIds': FieldValue.arrayRemove([currentUser.id]),
      });

      return true;
    } catch (e) {
      debugPrint('Remove friend error: $e');
      throw Exception('Failed to remove friend');
    }
  }

  /// Get friendship status with another user
  Future<FriendshipStatus> getFriendshipStatus(String otherUserId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return FriendshipStatus.none;

    final friendship = await _getFriendship(currentUser.id, otherUserId);
    if (friendship == null) return FriendshipStatus.none;

    // For request statuses, need to check who requested
    if (friendship.status == FriendshipStatus.requestSent) {
      if (friendship.requestedBy == currentUser.id) {
        return FriendshipStatus.requestSent;
      } else {
        return FriendshipStatus.requestReceived;
      }
    }

    return friendship.status;
  }

  /// Get list of friends
  Future<List<AppUser>> getFriends() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null || currentUser.friendIds.isEmpty) {
      return [];
    }

    try {
      final friendDocs = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: currentUser.friendIds)
          .get();

      return friendDocs.docs
          .map((doc) => AppUser.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Get friends error: $e');
      return [];
    }
  }

  /// Get pending friend requests (received)
  Future<List<AppUser>> getPendingFriendRequests() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return [];

    try {
      final requestDocs = await _firestore
          .collection('friendships')
          .where('userId2', isEqualTo: currentUser.id)
          .where('status', isEqualTo: FriendshipStatus.requestSent.index)
          .get();

      if (requestDocs.docs.isEmpty) return [];

      final requesterIds = requestDocs.docs
          .map((doc) => Friendship.fromMap(doc.data()).requestedBy!)
          .toList();

      final userDocs = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: requesterIds)
          .get();

      return userDocs.docs
          .map((doc) => AppUser.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Get pending requests error: $e');
      return [];
    }
  }

  /// Get sent friend requests
  Future<List<AppUser>> getSentFriendRequests() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return [];

    try {
      final requestDocs = await _firestore
          .collection('friendships')
          .where('userId1', isEqualTo: currentUser.id)
          .where('status', isEqualTo: FriendshipStatus.requestSent.index)
          .where('requestedBy', isEqualTo: currentUser.id)
          .get();

      if (requestDocs.docs.isEmpty) return [];

      final targetIds = requestDocs.docs
          .map((doc) => Friendship.fromMap(doc.data()).userId2)
          .toList();

      final userDocs = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: targetIds)
          .get();

      return userDocs.docs
          .map((doc) => AppUser.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Get sent requests error: $e');
      return [];
    }
  }

  // ===== SOCIAL SHARING =====

  /// Share achievement with friends
  Future<void> shareAchievement(String achievementTitle, String description) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    try {
      final shareText = '🎉 I just unlocked "$achievementTitle" in FlowPulse!\n\n'
          '$description\n\n'
          'Join me in focused productivity! #FlowPulse #Focus #Productivity';

      await Share.share(
        shareText,
        subject: 'FlowPulse Achievement Unlocked!',
      );

      // Optionally log sharing event for analytics
      await _logSharingEvent('achievement', achievementTitle);
    } catch (e) {
      debugPrint('Share achievement error: $e');
    }
  }

  /// Share productivity stats
  Future<void> shareProductivityStats(Map<String, dynamic> stats) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    try {
      final totalTime = stats['totalFocusTime'] ?? 0;
      final sessions = stats['totalSessions'] ?? 0;
      final streak = stats['currentStreak'] ?? 0;

      final shareText = '📊 My FlowPulse Productivity Stats:\n\n'
          '🎯 Total Focus Time: ${_formatTime(totalTime)}\n'
          '⏱️ Sessions Completed: $sessions\n'
          '🔥 Current Streak: $streak days\n\n'
          'Track your focus time with FlowPulse! #FlowPulse #Productivity';

      await Share.share(
        shareText,
        subject: 'My Productivity Journey',
      );

      await _logSharingEvent('stats', 'productivity_summary');
    } catch (e) {
      debugPrint('Share stats error: $e');
    }
  }

  /// Share team session invitation
  Future<void> shareTeamSessionInvite(String sessionName, String inviteCode) async {
    try {
      final shareText = '🤝 Join my focus session on FlowPulse!\n\n'
          'Session: $sessionName\n'
          'Invite Code: $inviteCode\n\n'
          'Let\'s focus together and boost our productivity! #FlowPulse #TeamFocus';

      await Share.share(
        shareText,
        subject: 'Join My Focus Session',
      );

      await _logSharingEvent('team_invite', sessionName);
    } catch (e) {
      debugPrint('Share team invite error: $e');
    }
  }

  // ===== HELPER METHODS =====

  /// Get friendship document between two users
  Future<Friendship?> _getFriendship(String userId1, String userId2) async {
    try {
      final friendshipId = _generateFriendshipId(userId1, userId2);
      final doc = await _firestore
          .collection('friendships')
          .doc(friendshipId)
          .get();

      if (doc.exists) {
        return Friendship.fromMap(doc.data()!);
      }

      return null;
    } catch (e) {
      debugPrint('Get friendship error: $e');
      return null;
    }
  }

  /// Generate consistent friendship document ID
  String _generateFriendshipId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  /// Format time in minutes to human readable string
  String _formatTime(int minutes) {
    if (minutes < 60) return '${minutes}m';
    
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    
    if (hours < 24) {
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }
    
    final days = hours ~/ 24;
    final remainingHours = hours % 24;
    
    return remainingHours > 0 
        ? '${days}d ${remainingHours}h'
        : '${days}d';
  }

  /// Log sharing events for analytics
  Future<void> _logSharingEvent(String type, String content) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    try {
      await _firestore.collection('sharing_events').add({
        'userId': currentUser.id,
        'type': type,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Log sharing event error: $e');
    }
  }

  /// Block a user
  Future<bool> blockUser(String userId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Remove friendship if exists
      final friendship = await _getFriendship(currentUser.id, userId);
      if (friendship != null) {
        await removeFriend(userId);
      }

      // Create blocked relationship
      final friendshipId = _generateFriendshipId(currentUser.id, userId);
      final blockedFriendship = Friendship(
        id: friendshipId,
        userId1: currentUser.id,
        userId2: userId,
        status: FriendshipStatus.blocked,
        requestedBy: currentUser.id, // The blocker
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('friendships')
          .doc(friendshipId)
          .set(blockedFriendship.toMap());

      return true;
    } catch (e) {
      debugPrint('Block user error: $e');
      throw Exception('Failed to block user');
    }
  }

  /// Unblock a user
  Future<bool> unblockUser(String userId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      final friendship = await _getFriendship(currentUser.id, userId);
      if (friendship == null || friendship.status != FriendshipStatus.blocked) {
        throw Exception('User is not blocked');
      }

      // Delete the blocked relationship
      await _firestore
          .collection('friendships')
          .doc(friendship.id)
          .delete();

      return true;
    } catch (e) {
      debugPrint('Unblock user error: $e');
      throw Exception('Failed to unblock user');
    }
  }

  /// Get blocked users
  Future<List<AppUser>> getBlockedUsers() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return [];

    try {
      final blockedDocs = await _firestore
          .collection('friendships')
          .where('userId1', isEqualTo: currentUser.id)
          .where('status', isEqualTo: FriendshipStatus.blocked.index)
          .where('requestedBy', isEqualTo: currentUser.id)
          .get();

      if (blockedDocs.docs.isEmpty) return [];

      final blockedIds = blockedDocs.docs
          .map((doc) => Friendship.fromMap(doc.data()).userId2)
          .toList();

      final userDocs = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: blockedIds)
          .get();

      return userDocs.docs
          .map((doc) => AppUser.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Get blocked users error: $e');
      return [];
    }
  }
}