import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math';
import '../models/app_user.dart';
import 'auth_service.dart';

class TeamSessionService {
  static final TeamSessionService _instance = TeamSessionService._internal();
  factory TeamSessionService() => _instance;
  TeamSessionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  
  // Current team session
  TeamSession? _currentSession;
  StreamSubscription<DocumentSnapshot>? _sessionSubscription;
  
  // Stream controllers
  final StreamController<TeamSession?> _sessionController = 
      StreamController<TeamSession?>.broadcast();
  final StreamController<List<AppUser>> _participantsController = 
      StreamController<List<AppUser>>.broadcast();
  final StreamController<int> _timerController = 
      StreamController<int>.broadcast();

  // Streams
  Stream<TeamSession?> get sessionStream => _sessionController.stream;
  Stream<List<AppUser>> get participantsStream => _participantsController.stream;
  Stream<int> get timerStream => _timerController.stream;

  // Current session info
  TeamSession? get currentSession => _currentSession;
  bool get hasActiveSession => _currentSession != null;

  /// Create a new team session
  Future<TeamSession> createTeamSession({
    required String name,
    String? description,
    int duration = 1500, // 25 minutes default
    bool isPrivate = false,
    List<String> inviteUserIds = const [],
  }) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      final sessionId = _firestore.collection('team_sessions').doc().id;
      final inviteCode = _generateInviteCode();
      
      final session = TeamSession(
        id: sessionId,
        name: name,
        description: description,
        createdBy: currentUser.id,
        participantIds: [currentUser.id], // Creator automatically joins
        duration: duration,
        createdAt: DateTime.now(),
        isPrivate: isPrivate,
        inviteCode: inviteCode,
      );

      await _firestore
          .collection('team_sessions')
          .doc(sessionId)
          .set(session.toMap());

      // Update user's current session
      await _firestore.collection('users').doc(currentUser.id).update({
        'currentTeamSessionId': sessionId,
      });

      // Send invites if specified
      if (inviteUserIds.isNotEmpty) {
        await _sendInvites(sessionId, inviteUserIds);
      }

      await _joinSession(sessionId);
      return session;
    } catch (e) {
      debugPrint('Create team session error: $e');
      throw Exception('Failed to create team session');
    }
  }

  /// Join a team session by ID
  Future<void> joinSessionById(String sessionId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      final sessionDoc = await _firestore
          .collection('team_sessions')
          .doc(sessionId)
          .get();

      if (!sessionDoc.exists) {
        throw Exception('Session not found');
      }

      final session = TeamSession.fromMap(sessionDoc.data()!);
      
      if (session.state == SessionState.completed || 
          session.state == SessionState.cancelled) {
        throw Exception('Session has ended');
      }

      await _joinSession(sessionId);
    } catch (e) {
      debugPrint('Join session error: $e');
      if (e is Exception) rethrow;
      throw Exception('Failed to join session');
    }
  }

  /// Join a team session by invite code
  Future<void> joinSessionByCode(String inviteCode) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      final querySnapshot = await _firestore
          .collection('team_sessions')
          .where('inviteCode', isEqualTo: inviteCode)
          .where('state', whereIn: [SessionState.waiting.index, SessionState.active.index])
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Invalid invite code or session has ended');
      }

      final sessionId = querySnapshot.docs.first.id;
      await _joinSession(sessionId);
    } catch (e) {
      debugPrint('Join by code error: $e');
      if (e is Exception) rethrow;
      throw Exception('Failed to join session');
    }
  }

  /// Leave current team session
  Future<void> leaveCurrentSession() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null || _currentSession == null) return;

    try {
      // Remove from participants
      await _firestore
          .collection('team_sessions')
          .doc(_currentSession!.id)
          .update({
        'participantIds': FieldValue.arrayRemove([currentUser.id]),
      });

      // Clear user's current session
      await _firestore.collection('users').doc(currentUser.id).update({
        'currentTeamSessionId': null,
      });

      await _cleanupSession();
    } catch (e) {
      debugPrint('Leave session error: $e');
    }
  }

  /// Start the team session (only creator can start)
  Future<void> startSession() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null || _currentSession == null) {
      throw Exception('No active session');
    }

    if (_currentSession!.createdBy != currentUser.id) {
      throw Exception('Only session creator can start the session');
    }

    if (_currentSession!.state != SessionState.waiting) {
      throw Exception('Session cannot be started in current state');
    }

    try {
      await _firestore
          .collection('team_sessions')
          .doc(_currentSession!.id)
          .update({
        'state': SessionState.starting.index,
        'startedAt': FieldValue.serverTimestamp(),
      });

      // Start countdown timer (3 seconds)
      await _startCountdown();
    } catch (e) {
      debugPrint('Start session error: $e');
      throw Exception('Failed to start session');
    }
  }

  /// Pause the team session
  Future<void> pauseSession() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null || _currentSession == null) return;

    if (_currentSession!.createdBy != currentUser.id) {
      throw Exception('Only session creator can pause the session');
    }

    try {
      await _firestore
          .collection('team_sessions')
          .doc(_currentSession!.id)
          .update({
        'state': SessionState.paused.index,
      });
    } catch (e) {
      debugPrint('Pause session error: $e');
    }
  }

  /// Resume the team session
  Future<void> resumeSession() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null || _currentSession == null) return;

    if (_currentSession!.createdBy != currentUser.id) {
      throw Exception('Only session creator can resume the session');
    }

    try {
      await _firestore
          .collection('team_sessions')
          .doc(_currentSession!.id)
          .update({
        'state': SessionState.active.index,
      });
    } catch (e) {
      debugPrint('Resume session error: $e');
    }
  }

  /// End the team session
  Future<void> endSession() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null || _currentSession == null) return;

    if (_currentSession!.createdBy != currentUser.id) {
      throw Exception('Only session creator can end the session');
    }

    try {
      await _firestore
          .collection('team_sessions')
          .doc(_currentSession!.id)
          .update({
        'state': SessionState.completed.index,
        'endedAt': FieldValue.serverTimestamp(),
      });

      // Award experience points to all participants
      await _awardSessionExperience();
    } catch (e) {
      debugPrint('End session error: $e');
    }
  }

  /// Get available team sessions to join
  Future<List<TeamSession>> getAvailableSessions({int limit = 20}) async {
    try {
      final querySnapshot = await _firestore
          .collection('team_sessions')
          .where('isPrivate', isEqualTo: false)
          .where('state', isEqualTo: SessionState.waiting.index)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => TeamSession.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Get available sessions error: $e');
      return [];
    }
  }

  /// Get user's team session history
  Future<List<TeamSession>> getSessionHistory({int limit = 50}) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection('team_sessions')
          .where('participantIds', arrayContains: currentUser.id)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => TeamSession.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Get session history error: $e');
      return [];
    }
  }

  /// Send invites to users
  Future<void> _sendInvites(String sessionId, List<String> userIds) async {
    try {
      // Create invite documents
      final batch = _firestore.batch();
      
      for (final userId in userIds) {
        final inviteDoc = _firestore.collection('team_invites').doc();
        batch.set(inviteDoc, {
          'sessionId': sessionId,
          'invitedUserId': userId,
          'invitedBy': _authService.currentUser!.id,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // TODO: Send push notifications to invited users
    } catch (e) {
      debugPrint('Send invites error: $e');
    }
  }

  /// Join a session
  Future<void> _joinSession(String sessionId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    try {
      // Leave current session if any
      if (_currentSession != null) {
        await leaveCurrentSession();
      }

      // Add to participants
      await _firestore
          .collection('team_sessions')
          .doc(sessionId)
          .update({
        'participantIds': FieldValue.arrayUnion([currentUser.id]),
      });

      // Update user's current session
      await _firestore.collection('users').doc(currentUser.id).update({
        'currentTeamSessionId': sessionId,
      });

      // Start listening to session updates
      await _startListening(sessionId);
    } catch (e) {
      debugPrint('Join session error: $e');
      throw Exception('Failed to join session');
    }
  }

  /// Start listening to session updates
  Future<void> _startListening(String sessionId) async {
    _sessionSubscription?.cancel();

    _sessionSubscription = _firestore
        .collection('team_sessions')
        .doc(sessionId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _currentSession = TeamSession.fromMap(snapshot.data()!);
        _sessionController.add(_currentSession);
        _loadParticipants();
      } else {
        _currentSession = null;
        _sessionController.add(null);
      }
    });
  }

  /// Load participants data
  Future<void> _loadParticipants() async {
    if (_currentSession == null || _currentSession!.participantIds.isEmpty) {
      _participantsController.add([]);
      return;
    }

    try {
      final userDocs = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: _currentSession!.participantIds)
          .get();

      final participants = userDocs.docs
          .map((doc) => AppUser.fromMap(doc.data()))
          .toList();

      _participantsController.add(participants);
    } catch (e) {
      debugPrint('Load participants error: $e');
      _participantsController.add([]);
    }
  }

  /// Start countdown before session begins
  Future<void> _startCountdown() async {
    for (int i = 3; i > 0; i--) {
      _timerController.add(-i); // Negative values for countdown
      await Future.delayed(const Duration(seconds: 1));
    }

    // Start the actual session
    await _firestore
        .collection('team_sessions')
        .doc(_currentSession!.id)
        .update({
      'state': SessionState.active.index,
    });

    // Start the timer
    await _startTimer();
  }

  /// Start the session timer
  Future<void> _startTimer() async {
    if (_currentSession == null) return;

    int remainingSeconds = _currentSession!.duration;
    
    final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSession?.state != SessionState.active) {
        timer.cancel();
        return;
      }

      remainingSeconds--;
      _timerController.add(remainingSeconds);

      if (remainingSeconds <= 0) {
        timer.cancel();
        _completeSession();
      }
    });
  }

  /// Complete the session automatically when timer reaches zero
  Future<void> _completeSession() async {
    try {
      await _firestore
          .collection('team_sessions')
          .doc(_currentSession!.id)
          .update({
        'state': SessionState.completed.index,
        'endedAt': FieldValue.serverTimestamp(),
      });

      await _awardSessionExperience();
    } catch (e) {
      debugPrint('Complete session error: $e');
    }
  }

  /// Award experience points to session participants
  Future<void> _awardSessionExperience() async {
    if (_currentSession == null) return;

    try {
      final batch = _firestore.batch();
      final baseXp = _currentSession!.duration ~/ 60 * 10; // 10 XP per minute
      final bonusXp = _currentSession!.participantIds.length * 5; // Bonus for team participation
      final totalXp = baseXp + bonusXp;

      for (final participantId in _currentSession!.participantIds) {
        final userRef = _firestore.collection('users').doc(participantId);
        batch.update(userRef, {
          'experience': FieldValue.increment(totalXp),
          'totalSessions': FieldValue.increment(1),
          'totalFocusTime': FieldValue.increment(_currentSession!.duration ~/ 60),
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Award experience error: $e');
    }
  }

  /// Generate random invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Cleanup session listeners and data
  Future<void> _cleanupSession() async {
    _sessionSubscription?.cancel();
    _sessionSubscription = null;
    _currentSession = null;
    _sessionController.add(null);
    _participantsController.add([]);
  }

  /// Initialize the service (call from app startup)
  Future<void> initialize() async {
    final currentUser = _authService.currentUser;
    if (currentUser?.currentTeamSessionId != null) {
      try {
        await _startListening(currentUser!.currentTeamSessionId!);
      } catch (e) {
        debugPrint('Initialize team session error: $e');
        // Clear invalid session reference
        await _firestore.collection('users').doc(currentUser.id).update({
          'currentTeamSessionId': null,
        });
      }
    }
  }

  /// Dispose of the service
  void dispose() {
    _sessionSubscription?.cancel();
    _sessionController.close();
    _participantsController.close();
    _timerController.close();
  }
}