import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current Firebase user
  User? get currentFirebaseUser => _auth.currentUser;
  
  // Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Current app user (cached)
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  /// Initialize the auth service
  Future<void> initialize() async {
    // Listen to auth state changes and update current user
    _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        await _loadCurrentUser(firebaseUser.uid);
      } else {
        _currentUser = null;
      }
    });

    // Load current user if already authenticated
    if (_auth.currentUser != null) {
      await _loadCurrentUser(_auth.currentUser!.uid);
    }
  }

  /// Sign in with email and password
  Future<AppUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await _loadCurrentUser(credential.user!.uid);
        await _updateLastActive();
        return _currentUser;
      }
      
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign in error: ${e.message}');
      throw _handleAuthException(e);
    }
  }

  /// Create account with email and password
  Future<AppUser?> createAccountWithEmailAndPassword(
    String email, 
    String password, 
    String displayName,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(displayName);
        
        // Create user document in Firestore
        final appUser = AppUser(
          id: credential.user!.uid,
          email: email,
          displayName: displayName,
          photoUrl: credential.user!.photoURL,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
        );
        
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(appUser.toMap());
        
        _currentUser = appUser;
        return appUser;
      }
      
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Create account error: ${e.message}');
      throw _handleAuthException(e);
    }
  }

  /// Sign in with Google (placeholder - would need google_sign_in package)
  Future<AppUser?> signInWithGoogle() async {
    // TODO: Implement Google Sign In
    // This would require the google_sign_in package and proper configuration
    throw UnimplementedError('Google Sign In not implemented yet');
  }

  /// Sign in with Apple (placeholder - would need sign_in_with_apple package)
  Future<AppUser?> signInWithApple() async {
    // TODO: Implement Apple Sign In  
    // This would require the sign_in_with_apple package and proper configuration
    throw UnimplementedError('Apple Sign In not implemented yet');
  }

  /// Sign in anonymously for demo purposes
  Future<AppUser?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      
      if (credential.user != null) {
        // Create anonymous user document
        final appUser = AppUser(
          id: credential.user!.uid,
          email: 'anonymous@flowpulse.com',
          displayName: 'Anonymous User',
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          isPublicProfile: false, // Anonymous users are private by default
          allowFriendRequests: false,
        );
        
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(appUser.toMap());
        
        _currentUser = appUser;
        return appUser;
      }
      
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Anonymous sign in error: ${e.message}');
      throw _handleAuthException(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser = null;
    } catch (e) {
      debugPrint('Sign out error: $e');
      throw Exception('Failed to sign out');
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint('Reset password error: ${e.message}');
      throw _handleAuthException(e);
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
    String? bio,
    bool? isPublicProfile,
    bool? allowFriendRequests,
    bool? shareAchievements,
  }) async {
    if (_currentUser == null || _auth.currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Update Firebase Auth profile
      if (displayName != null || photoUrl != null) {
        await _auth.currentUser!.updateProfile(
          displayName: displayName,
          photoURL: photoUrl,
        );
      }

      // Update Firestore document
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (bio != null) updates['bio'] = bio;
      if (isPublicProfile != null) updates['isPublicProfile'] = isPublicProfile;
      if (allowFriendRequests != null) updates['allowFriendRequests'] = allowFriendRequests;
      if (shareAchievements != null) updates['shareAchievements'] = shareAchievements;

      if (updates.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(_currentUser!.id)
            .update(updates);
        
        // Reload current user
        await _loadCurrentUser(_currentUser!.id);
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
      throw Exception('Failed to update profile');
    }
  }

  /// Update user stats after completing a session
  Future<void> updateUserStats({
    required int focusTimeMinutes,
    required int sessionsCompleted,
    required int newStreak,
    required int experienceGained,
  }) async {
    if (_currentUser == null) return;

    try {
      await _firestore.collection('users').doc(_currentUser!.id).update({
        'totalFocusTime': FieldValue.increment(focusTimeMinutes),
        'totalSessions': FieldValue.increment(sessionsCompleted),
        'currentStreak': newStreak,
        'longestStreak': newStreak > _currentUser!.longestStreak ? newStreak : _currentUser!.longestStreak,
        'experience': FieldValue.increment(experienceGained),
        'lastActiveAt': FieldValue.serverTimestamp(),
      });

      // Reload user data
      await _loadCurrentUser(_currentUser!.id);
    } catch (e) {
      debugPrint('Update user stats error: $e');
    }
  }

  /// Get user by ID
  Future<AppUser?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Get user error: $e');
      return null;
    }
  }

  /// Search users by display name or email
  Future<List<AppUser>> searchUsers(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];

    try {
      // Search by display name (case insensitive)
      final displayNameQuery = await _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
          .where('isPublicProfile', isEqualTo: true)
          .limit(limit)
          .get();

      // Search by email (exact match)
      final emailQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: query.toLowerCase())
          .where('isPublicProfile', isEqualTo: true)
          .limit(limit)
          .get();

      final users = <AppUser>[];
      final seenIds = <String>{};

      // Add display name results
      for (final doc in displayNameQuery.docs) {
        if (!seenIds.contains(doc.id)) {
          users.add(AppUser.fromMap(doc.data()));
          seenIds.add(doc.id);
        }
      }

      // Add email results
      for (final doc in emailQuery.docs) {
        if (!seenIds.contains(doc.id)) {
          users.add(AppUser.fromMap(doc.data()));
          seenIds.add(doc.id);
        }
      }

      return users;
    } catch (e) {
      debugPrint('Search users error: $e');
      return [];
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null && _currentUser != null;

  /// Check if user allows anonymous mode (for offline usage)
  bool get canUseOffline => !isAuthenticated; // Only allow offline if not authenticated

  /// Load current user from Firestore
  Future<void> _loadCurrentUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _currentUser = AppUser.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('Load current user error: $e');
    }
  }

  /// Update last active timestamp
  Future<void> _updateLastActive() async {
    if (_currentUser == null) return;

    try {
      await _firestore.collection('users').doc(_currentUser!.id).update({
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Update last active error: $e');
    }
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    if (_currentUser == null || _auth.currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Delete user document from Firestore
      await _firestore.collection('users').doc(_currentUser!.id).delete();
      
      // Delete Firebase Auth account
      await _auth.currentUser!.delete();
      
      _currentUser = null;
    } catch (e) {
      debugPrint('Delete account error: $e');
      throw Exception('Failed to delete account');
    }
  }
}