import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import 'auth_service.dart';

class LeaderboardService {
  static final LeaderboardService _instance = LeaderboardService._internal();
  factory LeaderboardService() => _instance;
  LeaderboardService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  /// Get leaderboard for a specific type
  Future<List<LeaderboardEntry>> getLeaderboard(
    LeaderboardType type, {
    int limit = 50,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) async {
    try {
      // Determine the field to sort by based on leaderboard type
      String sortField = _getSortField(type);
      bool isDescending = true;

      Query query = _firestore.collection('users')
          .where('isPublicProfile', isEqualTo: true)
          .orderBy(sortField, descending: isDescending)
          .limit(limit);

      // Add date filters for time-based leaderboards
      if (periodStart != null && periodEnd != null) {
        query = query
            .where('lastActiveAt', isGreaterThanOrEqualTo: Timestamp.fromDate(periodStart))
            .where('lastActiveAt', isLessThanOrEqualTo: Timestamp.fromDate(periodEnd));
      }

      final querySnapshot = await query.get();
      final entries = <LeaderboardEntry>[];

      for (int i = 0; i < querySnapshot.docs.length; i++) {
        final doc = querySnapshot.docs[i];
        final userData = doc.data() as Map<String, dynamic>;
        final user = AppUser.fromMap(userData);
        
        final entry = LeaderboardEntry(
          userId: user.id,
          displayName: user.displayName,
          photoUrl: user.photoUrl,
          value: _getLeaderboardValue(user, type),
          rank: i + 1,
          lastUpdated: user.lastActiveAt,
        );
        entries.add(entry);
      }

      return entries;
    } catch (e) {
      debugPrint('Get leaderboard error: $e');
      return [];
    }
  }

  /// Get friends leaderboard
  Future<List<LeaderboardEntry>> getFriendsLeaderboard(
    LeaderboardType type, {
    int limit = 50,
  }) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null || currentUser.friendIds.isEmpty) {
      return [];
    }

    try {
      String sortField = _getSortField(type);
      
      // Include current user and friends
      final userIds = [currentUser.id, ...currentUser.friendIds];
      
      final querySnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: userIds)
          .orderBy(sortField, descending: true)
          .limit(limit)
          .get();

      final entries = <LeaderboardEntry>[];

      for (int i = 0; i < querySnapshot.docs.length; i++) {
        final doc = querySnapshot.docs[i];
        final userData = doc.data();
        final user = AppUser.fromMap(userData);
        
        final entry = LeaderboardEntry(
          userId: user.id,
          displayName: user.displayName,
          photoUrl: user.photoUrl,
          value: _getLeaderboardValue(user, type),
          rank: i + 1,
          lastUpdated: user.lastActiveAt,
        );
        entries.add(entry);
      }

      return entries;
    } catch (e) {
      debugPrint('Get friends leaderboard error: $e');
      return [];
    }
  }

  /// Get user's rank in global leaderboard
  Future<int> getUserRank(LeaderboardType type) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return 0;

    try {
      String sortField = _getSortField(type);
      int userValue = _getLeaderboardValue(currentUser, type);
      
      final querySnapshot = await _firestore
          .collection('users')
          .where('isPublicProfile', isEqualTo: true)
          .where(sortField, isGreaterThan: userValue)
          .get();

      return querySnapshot.docs.length + 1; // +1 because rank is 1-based
    } catch (e) {
      debugPrint('Get user rank error: $e');
      return 0;
    }
  }

  /// Get today's leaderboard (resets daily)
  Future<List<LeaderboardEntry>> getTodaysLeaderboard({int limit = 20}) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return getLeaderboard(
      LeaderboardType.dailyFocusTime,
      limit: limit,
      periodStart: startOfDay,
      periodEnd: endOfDay,
    );
  }

  /// Get weekly leaderboard
  Future<List<LeaderboardEntry>> getWeeklyLeaderboard({int limit = 20}) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return getLeaderboard(
      LeaderboardType.weeklyFocusTime,
      limit: limit,
      periodStart: startOfWeek,
      periodEnd: endOfWeek,
    );
  }

  /// Get monthly leaderboard
  Future<List<LeaderboardEntry>> getMonthlyLeaderboard({int limit = 20}) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return getLeaderboard(
      LeaderboardType.monthlyFocusTime,
      limit: limit,
      periodStart: startOfMonth,
      periodEnd: endOfMonth,
    );
  }

  /// Create or join a competition
  Future<Competition> createCompetition({
    required String name,
    required String description,
    required CompetitionType type,
    required DateTime startDate,
    required DateTime endDate,
    List<String> participantIds = const [],
    int maxParticipants = 50,
    CompetitionReward? reward,
  }) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      final competitionId = _firestore.collection('competitions').doc().id;
      
      final competition = Competition(
        id: competitionId,
        name: name,
        description: description,
        type: type,
        createdBy: currentUser.id,
        participantIds: [currentUser.id, ...participantIds],
        startDate: startDate,
        endDate: endDate,
        maxParticipants: maxParticipants,
        reward: reward,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('competitions')
          .doc(competitionId)
          .set(competition.toMap());

      return competition;
    } catch (e) {
      debugPrint('Create competition error: $e');
      throw Exception('Failed to create competition');
    }
  }

  /// Join a competition
  Future<void> joinCompetition(String competitionId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      final competitionDoc = await _firestore
          .collection('competitions')
          .doc(competitionId)
          .get();

      if (!competitionDoc.exists) {
        throw Exception('Competition not found');
      }

      final competition = Competition.fromMap(competitionDoc.data()!);
      
      if (competition.participantIds.contains(currentUser.id)) {
        throw Exception('Already joined this competition');
      }

      if (competition.participantIds.length >= competition.maxParticipants) {
        throw Exception('Competition is full');
      }

      if (DateTime.now().isAfter(competition.endDate)) {
        throw Exception('Competition has ended');
      }

      await _firestore
          .collection('competitions')
          .doc(competitionId)
          .update({
        'participantIds': FieldValue.arrayUnion([currentUser.id]),
      });
    } catch (e) {
      debugPrint('Join competition error: $e');
      if (e is Exception) rethrow;
      throw Exception('Failed to join competition');
    }
  }

  /// Get active competitions
  Future<List<Competition>> getActiveCompetitions({int limit = 20}) async {
    try {
      final now = DateTime.now();
      
      final querySnapshot = await _firestore
          .collection('competitions')
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .where('endDate', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('endDate')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => Competition.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Get active competitions error: $e');
      return [];
    }
  }

  /// Get user's competitions
  Future<List<Competition>> getUserCompetitions() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection('competitions')
          .where('participantIds', arrayContains: currentUser.id)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Competition.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Get user competitions error: $e');
      return [];
    }
  }

  /// Get competition leaderboard
  Future<List<LeaderboardEntry>> getCompetitionLeaderboard(String competitionId) async {
    try {
      final competitionDoc = await _firestore
          .collection('competitions')
          .doc(competitionId)
          .get();

      if (!competitionDoc.exists) return [];

      final competition = Competition.fromMap(competitionDoc.data()!);
      
      if (competition.participantIds.isEmpty) return [];

      final userDocs = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: competition.participantIds)
          .get();

      final entries = <LeaderboardEntry>[];
      
      for (final doc in userDocs.docs) {
        final user = AppUser.fromMap(doc.data());
        final value = _getCompetitionValue(user, competition.type, competition.startDate, competition.endDate);
        
        entries.add(LeaderboardEntry(
          userId: user.id,
          displayName: user.displayName,
          photoUrl: user.photoUrl,
          value: value,
          rank: 0, // Will be set after sorting
          lastUpdated: user.lastActiveAt,
        ));
      }

      // Sort by value and assign ranks
      entries.sort((a, b) => b.value.compareTo(a.value));
      for (int i = 0; i < entries.length; i++) {
        entries[i] = LeaderboardEntry(
          userId: entries[i].userId,
          displayName: entries[i].displayName,
          photoUrl: entries[i].photoUrl,
          value: entries[i].value,
          rank: i + 1,
          lastUpdated: entries[i].lastUpdated,
        );
      }

      return entries;
    } catch (e) {
      debugPrint('Get competition leaderboard error: $e');
      return [];
    }
  }

  /// Get Firestore field name for leaderboard type
  String _getSortField(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.dailyFocusTime:
      case LeaderboardType.weeklyFocusTime:
      case LeaderboardType.monthlyFocusTime:
        return 'totalFocusTime';
      case LeaderboardType.totalSessions:
        return 'totalSessions';
      case LeaderboardType.currentStreak:
        return 'currentStreak';
      case LeaderboardType.longestStreak:
        return 'longestStreak';
      case LeaderboardType.level:
        return 'experience'; // Sort by experience since level is calculated
    }
  }

  /// Get leaderboard value from user data
  int _getLeaderboardValue(AppUser user, LeaderboardType type) {
    switch (type) {
      case LeaderboardType.dailyFocusTime:
      case LeaderboardType.weeklyFocusTime:
      case LeaderboardType.monthlyFocusTime:
        return user.totalFocusTime;
      case LeaderboardType.totalSessions:
        return user.totalSessions;
      case LeaderboardType.currentStreak:
        return user.currentStreak;
      case LeaderboardType.longestStreak:
        return user.longestStreak;
      case LeaderboardType.level:
        return user.level;
    }
  }

  /// Get competition-specific value (would require session tracking within date range)
  int _getCompetitionValue(AppUser user, CompetitionType type, DateTime start, DateTime end) {
    // For now, return current values - would need session history for accurate competition tracking
    switch (type) {
      case CompetitionType.mostFocusTime:
        return user.totalFocusTime;
      case CompetitionType.mostSessions:
        return user.totalSessions;
      case CompetitionType.longestStreak:
        return user.currentStreak;
      case CompetitionType.highestLevel:
        return user.level;
    }
  }

  /// Update leaderboard cache (run periodically)
  Future<void> updateLeaderboardCache() async {
    try {
      // This would typically be run by a cloud function
      // For now, it's a placeholder for caching logic
      
      final types = LeaderboardType.values;
      
      for (final type in types) {
        final entries = await getLeaderboard(type, limit: 100);
        
        // Cache the results
        await _firestore
            .collection('leaderboard_cache')
            .doc(type.toString())
            .set({
          'entries': entries.map((e) => e.toMap()).toList(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Update leaderboard cache error: $e');
    }
  }
}

// Competition-related models
class Competition {
  final String id;
  final String name;
  final String description;
  final CompetitionType type;
  final String createdBy;
  final List<String> participantIds;
  final DateTime startDate;
  final DateTime endDate;
  final int maxParticipants;
  final CompetitionStatus status;
  final CompetitionReward? reward;
  final DateTime createdAt;
  final String? winnerId;

  Competition({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.createdBy,
    this.participantIds = const [],
    required this.startDate,
    required this.endDate,
    this.maxParticipants = 50,
    this.status = CompetitionStatus.upcoming,
    this.reward,
    required this.createdAt,
    this.winnerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.index,
      'createdBy': createdBy,
      'participantIds': participantIds,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'maxParticipants': maxParticipants,
      'status': status.index,
      'reward': reward?.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'winnerId': winnerId,
    };
  }

  factory Competition.fromMap(Map<String, dynamic> map) {
    return Competition(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      type: CompetitionType.values[map['type'] ?? 0],
      createdBy: map['createdBy'] ?? '',
      participantIds: List<String>.from(map['participantIds'] ?? []),
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      maxParticipants: map['maxParticipants'] ?? 50,
      status: CompetitionStatus.values[map['status'] ?? 0],
      reward: map['reward'] != null ? CompetitionReward.fromMap(map['reward']) : null,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      winnerId: map['winnerId'],
    );
  }
}

enum CompetitionType {
  mostFocusTime,
  mostSessions,
  longestStreak,
  highestLevel,
}

enum CompetitionStatus {
  upcoming,
  active,
  completed,
  cancelled,
}

class CompetitionReward {
  final String title;
  final String description;
  final RewardType type;
  final int value; // XP, coins, etc.
  final String? imageUrl;

  CompetitionReward({
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type.index,
      'value': value,
      'imageUrl': imageUrl,
    };
  }

  factory CompetitionReward.fromMap(Map<String, dynamic> map) {
    return CompetitionReward(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: RewardType.values[map['type'] ?? 0],
      value: map['value'] ?? 0,
      imageUrl: map['imageUrl'],
    );
  }
}

enum RewardType {
  experience,
  badge,
  title,
  premium,
}