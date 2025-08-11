import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  
  // Profile information
  final String? bio;
  final int totalFocusTime; // in minutes
  final int totalSessions;
  final int currentStreak;
  final int longestStreak;
  final int level;
  final int experience;
  
  // Social features
  final List<String> friendIds;
  final bool isPublicProfile;
  final bool allowFriendRequests;
  final bool shareAchievements;
  
  // Team features
  final List<String> teamIds;
  final String? currentTeamSessionId;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.lastActiveAt,
    this.bio,
    this.totalFocusTime = 0,
    this.totalSessions = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.level = 1,
    this.experience = 0,
    this.friendIds = const [],
    this.isPublicProfile = true,
    this.allowFriendRequests = true,
    this.shareAchievements = true,
    this.teamIds = const [],
    this.currentTeamSessionId,
  });

  // Calculate level based on experience points
  static int calculateLevel(int experience) {
    // Level progression: 100, 250, 500, 1000, 1750, 2750, 4000, 5500, 7250, 9250...
    // Formula: level n requires sum of (n * 150) XP
    int level = 1;
    int requiredXp = 0;
    
    while (experience >= requiredXp + (level * 150)) {
      requiredXp += (level * 150);
      level++;
    }
    
    return level;
  }

  // Calculate XP needed for next level
  int get xpForNextLevel {
    final nextLevel = level + 1;
    int requiredXp = 0;
    
    for (int i = 1; i < nextLevel; i++) {
      requiredXp += (i * 150);
    }
    
    return requiredXp;
  }

  int get xpProgress => experience - xpForCurrentLevel;
  int get xpForCurrentLevel {
    int requiredXp = 0;
    
    for (int i = 1; i < level; i++) {
      requiredXp += (i * 150);
    }
    
    return requiredXp;
  }

  int get xpNeededForNext => xpForNextLevel - experience;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
      'bio': bio,
      'totalFocusTime': totalFocusTime,
      'totalSessions': totalSessions,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'level': level,
      'experience': experience,
      'friendIds': friendIds,
      'isPublicProfile': isPublicProfile,
      'allowFriendRequests': allowFriendRequests,
      'shareAchievements': shareAchievements,
      'teamIds': teamIds,
      'currentTeamSessionId': currentTeamSessionId,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveAt: (map['lastActiveAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bio: map['bio'],
      totalFocusTime: map['totalFocusTime'] ?? 0,
      totalSessions: map['totalSessions'] ?? 0,
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      level: calculateLevel(map['experience'] ?? 0),
      experience: map['experience'] ?? 0,
      friendIds: List<String>.from(map['friendIds'] ?? []),
      isPublicProfile: map['isPublicProfile'] ?? true,
      allowFriendRequests: map['allowFriendRequests'] ?? true,
      shareAchievements: map['shareAchievements'] ?? true,
      teamIds: List<String>.from(map['teamIds'] ?? []),
      currentTeamSessionId: map['currentTeamSessionId'],
    );
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    String? bio,
    int? totalFocusTime,
    int? totalSessions,
    int? currentStreak,
    int? longestStreak,
    int? level,
    int? experience,
    List<String>? friendIds,
    bool? isPublicProfile,
    bool? allowFriendRequests,
    bool? shareAchievements,
    List<String>? teamIds,
    String? currentTeamSessionId,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      bio: bio ?? this.bio,
      totalFocusTime: totalFocusTime ?? this.totalFocusTime,
      totalSessions: totalSessions ?? this.totalSessions,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      friendIds: friendIds ?? this.friendIds,
      isPublicProfile: isPublicProfile ?? this.isPublicProfile,
      allowFriendRequests: allowFriendRequests ?? this.allowFriendRequests,
      shareAchievements: shareAchievements ?? this.shareAchievements,
      teamIds: teamIds ?? this.teamIds,
      currentTeamSessionId: currentTeamSessionId ?? this.currentTeamSessionId,
    );
  }
}

enum FriendshipStatus {
  none,
  requestSent,
  requestReceived,
  friends,
  blocked,
}

class Friendship {
  final String id;
  final String userId1;
  final String userId2;
  final FriendshipStatus status;
  final String? requestedBy; // userId who sent the request
  final DateTime createdAt;
  final DateTime? acceptedAt;

  Friendship({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.status,
    this.requestedBy,
    required this.createdAt,
    this.acceptedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId1': userId1,
      'userId2': userId2,
      'status': status.index,
      'requestedBy': requestedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
    };
  }

  factory Friendship.fromMap(Map<String, dynamic> map) {
    return Friendship(
      id: map['id'] ?? '',
      userId1: map['userId1'] ?? '',
      userId2: map['userId2'] ?? '',
      status: FriendshipStatus.values[map['status'] ?? 0],
      requestedBy: map['requestedBy'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      acceptedAt: (map['acceptedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Get the other user's ID
  String getOtherUserId(String currentUserId) {
    return userId1 == currentUserId ? userId2 : userId1;
  }
}

class TeamSession {
  final String id;
  final String name;
  final String createdBy;
  final List<String> participantIds;
  final SessionState state;
  final int duration; // in seconds
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? description;
  final bool isPrivate;
  final String? inviteCode;

  TeamSession({
    required this.id,
    required this.name,
    required this.createdBy,
    this.participantIds = const [],
    this.state = SessionState.waiting,
    this.duration = 1500, // 25 minutes default
    required this.createdAt,
    this.startedAt,
    this.endedAt,
    this.description,
    this.isPrivate = false,
    this.inviteCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdBy': createdBy,
      'participantIds': participantIds,
      'state': state.index,
      'duration': duration,
      'createdAt': Timestamp.fromDate(createdAt),
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
      'description': description,
      'isPrivate': isPrivate,
      'inviteCode': inviteCode,
    };
  }

  factory TeamSession.fromMap(Map<String, dynamic> map) {
    return TeamSession(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      createdBy: map['createdBy'] ?? '',
      participantIds: List<String>.from(map['participantIds'] ?? []),
      state: SessionState.values[map['state'] ?? 0],
      duration: map['duration'] ?? 1500,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startedAt: (map['startedAt'] as Timestamp?)?.toDate(),
      endedAt: (map['endedAt'] as Timestamp?)?.toDate(),
      description: map['description'],
      isPrivate: map['isPrivate'] ?? false,
      inviteCode: map['inviteCode'],
    );
  }
}

enum SessionState {
  waiting,
  starting,
  active,
  paused,
  completed,
  cancelled,
}

class LeaderboardEntry {
  final String userId;
  final String displayName;
  final String? photoUrl;
  final int value;
  final int rank;
  final DateTime lastUpdated;

  LeaderboardEntry({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.value,
    required this.rank,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'value': value,
      'rank': rank,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      userId: map['userId'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      value: map['value'] ?? 0,
      rank: map['rank'] ?? 0,
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

enum LeaderboardType {
  dailyFocusTime,
  weeklyFocusTime,
  monthlyFocusTime,
  totalSessions,
  currentStreak,
  longestStreak,
  level,
}