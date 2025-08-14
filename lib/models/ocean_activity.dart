class OceanActivity {
  final String id;
  final DateTime timestamp;
  final OceanActivityType type;
  final String title;
  final String description;
  final Map<String, dynamic> metadata;
  final String? imageAsset; // Optional icon/image for the activity
  final ActivityPriority priority;

  const OceanActivity({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.title,
    required this.description,
    this.metadata = const {},
    this.imageAsset,
    this.priority = ActivityPriority.normal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type.index,
      'title': title,
      'description': description,
      'metadata': _encodeMetadata(metadata),
      'image_asset': imageAsset,
      'priority': priority.index,
    };
  }

  factory OceanActivity.fromMap(Map<String, dynamic> map) {
    return OceanActivity(
      id: map['id'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      type: OceanActivityType.values[map['type']],
      title: map['title'],
      description: map['description'],
      metadata: _decodeMetadata(map['metadata']),
      imageAsset: map['image_asset'],
      priority: ActivityPriority.values[map['priority'] ?? 1],
    );
  }

  static String _encodeMetadata(Map<String, dynamic> metadata) {
    // Simple JSON-like encoding for SQLite storage
    final entries = metadata.entries.map((e) => '"${e.key}":"${e.value}"');
    return '{${entries.join(',')}}';
  }

  static Map<String, dynamic> _decodeMetadata(String? encoded) {
    if (encoded == null || encoded.isEmpty) return {};
    
    try {
      // Simple parsing - in production, use proper JSON encoding
      final cleaned = encoded.replaceAll('{', '').replaceAll('}', '');
      final pairs = cleaned.split(',');
      final result = <String, dynamic>{};
      
      for (final pair in pairs) {
        if (pair.isNotEmpty) {
          final keyValue = pair.split(':');
          if (keyValue.length == 2) {
            final key = keyValue[0].replaceAll('"', '');
            final value = keyValue[1].replaceAll('"', '');
            result[key] = value;
          }
        }
      }
      
      return result;
    } catch (e) {
      return {};
    }
  }

  OceanActivity copyWith({
    String? id,
    DateTime? timestamp,
    OceanActivityType? type,
    String? title,
    String? description,
    Map<String, dynamic>? metadata,
    String? imageAsset,
    ActivityPriority? priority,
  }) {
    return OceanActivity(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      imageAsset: imageAsset ?? this.imageAsset,
      priority: priority ?? this.priority,
    );
  }

  // Getters for display
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get typeDisplayName => type.displayName;
  String get priorityDisplayName => priority.displayName;

  // Factory constructors for common activities
  factory OceanActivity.coralPlanted({
    required String coralType,
    required String biome,
    DateTime? timestamp,
  }) {
    return OceanActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: timestamp ?? DateTime.now(),
      type: OceanActivityType.coralPlanted,
      title: 'Coral Planted',
      description: 'Planted $coralType coral in $biome',
      metadata: {
        'coralType': coralType,
        'biome': biome,
      },
      imageAsset: 'assets/icons/coral_planted.png',
      priority: ActivityPriority.normal,
    );
  }

  factory OceanActivity.coralGrown({
    required String coralType,
    required String stage,
    required int sessionMinutes,
    DateTime? timestamp,
  }) {
    return OceanActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: timestamp ?? DateTime.now(),
      type: OceanActivityType.coralGrown,
      title: 'Coral Bloomed',
      description: '🪸 $coralType coral reached $stage stage after ${sessionMinutes}min focus session',
      metadata: {
        'coralType': coralType,
        'stage': stage,
        'sessionMinutes': sessionMinutes.toString(),
      },
      imageAsset: 'assets/icons/coral_bloomed.png',
      priority: ActivityPriority.high,
    );
  }

  factory OceanActivity.creatureDiscovered({
    required String creatureName,
    required String rarity,
    required int pearlsEarned,
    DateTime? timestamp,
  }) {
    return OceanActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: timestamp ?? DateTime.now(),
      type: OceanActivityType.creatureDiscovered,
      title: 'New Species Discovered!',
      description: '🐠 $creatureName ($rarity) discovered! Earned $pearlsEarned pearls',
      metadata: {
        'creatureName': creatureName,
        'rarity': rarity,
        'pearlsEarned': pearlsEarned.toString(),
      },
      imageAsset: 'assets/creatures/${creatureName.toLowerCase()}.png',
      priority: ActivityPriority.high,
    );
  }

  factory OceanActivity.pollutionEvent({
    required String reason,
    required int damageAmount,
    DateTime? timestamp,
  }) {
    return OceanActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: timestamp ?? DateTime.now(),
      type: OceanActivityType.pollutionEvent,
      title: 'Ecosystem Pollution',
      description: '⚠️ $reason - Ecosystem health decreased by $damageAmount%',
      metadata: {
        'reason': reason,
        'damageAmount': damageAmount.toString(),
      },
      imageAsset: 'assets/icons/pollution.png',
      priority: ActivityPriority.urgent,
    );
  }

  factory OceanActivity.biomeUnlocked({
    required String biomeName,
    required int requiredLevel,
    DateTime? timestamp,
  }) {
    return OceanActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: timestamp ?? DateTime.now(),
      type: OceanActivityType.biomeUnlocked,
      title: 'New Biome Unlocked!',
      description: '🌊 $biomeName biome unlocked at level $requiredLevel!',
      metadata: {
        'biomeName': biomeName,
        'requiredLevel': requiredLevel.toString(),
      },
      imageAsset: 'assets/biomes/${biomeName.toLowerCase()}.png',
      priority: ActivityPriority.high,
    );
  }

  factory OceanActivity.pearlsEarned({
    required int amount,
    required String source,
    DateTime? timestamp,
  }) {
    return OceanActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: timestamp ?? DateTime.now(),
      type: OceanActivityType.pearlsEarned,
      title: 'Pearls Earned',
      description: '💎 Earned $amount pearls from $source',
      metadata: {
        'amount': amount.toString(),
        'source': source,
      },
      imageAsset: 'assets/icons/pearls.png',
      priority: ActivityPriority.low,
    );
  }

  factory OceanActivity.streakMilestone({
    required int streakDays,
    required int bonusPearls,
    DateTime? timestamp,
  }) {
    return OceanActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: timestamp ?? DateTime.now(),
      type: OceanActivityType.ecosystemThriving,
      title: 'Ecosystem Thriving!',
      description: '🔥 $streakDays day streak! Bonus: $bonusPearls pearls',
      metadata: {
        'streakDays': streakDays.toString(),
        'bonusPearls': bonusPearls.toString(),
      },
      imageAsset: 'assets/icons/streak.png',
      priority: ActivityPriority.high,
    );
  }

  factory OceanActivity.achievementUnlocked({
    required String achievementName,
    required String achievementDescription,
    required int rewardPearls,
    DateTime? timestamp,
  }) {
    return OceanActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: timestamp ?? DateTime.now(),
      type: OceanActivityType.achievementUnlocked,
      title: 'Achievement Unlocked!',
      description: '🏆 $achievementName - $achievementDescription (+$rewardPearls pearls)',
      metadata: {
        'achievementName': achievementName,
        'achievementDescription': achievementDescription,
        'rewardPearls': rewardPearls.toString(),
      },
      imageAsset: 'assets/icons/achievement.png',
      priority: ActivityPriority.high,
    );
  }
}

enum OceanActivityType {
  coralPlanted,           // Session started
  coralGrown,             // Session completed  
  creatureDiscovered,     // New species found
  reefExpanded,           // Level up
  pollutionEvent,         // Session abandoned
  pearlsEarned,           // Currency gained
  biomeUnlocked,          // New area unlocked
  achievementUnlocked,    // Achievement gained
  ecosystemThriving,      // Streak milestone
  dailyBonus,             // Daily login reward
  coralPurchased,         // Bought new coral seed
  decorationAdded,        // Added aquarium decoration
}

extension OceanActivityTypeExtension on OceanActivityType {
  String get displayName {
    switch (this) {
      case OceanActivityType.coralPlanted:
        return 'Coral Planted';
      case OceanActivityType.coralGrown:
        return 'Coral Grown';
      case OceanActivityType.creatureDiscovered:
        return 'Creature Discovered';
      case OceanActivityType.reefExpanded:
        return 'Reef Expanded';
      case OceanActivityType.pollutionEvent:
        return 'Pollution Event';
      case OceanActivityType.pearlsEarned:
        return 'Pearls Earned';
      case OceanActivityType.biomeUnlocked:
        return 'Biome Unlocked';
      case OceanActivityType.achievementUnlocked:
        return 'Achievement Unlocked';
      case OceanActivityType.ecosystemThriving:
        return 'Ecosystem Thriving';
      case OceanActivityType.dailyBonus:
        return 'Daily Bonus';
      case OceanActivityType.coralPurchased:
        return 'Coral Purchased';
      case OceanActivityType.decorationAdded:
        return 'Decoration Added';
    }
  }

  String get emoji {
    switch (this) {
      case OceanActivityType.coralPlanted:
        return '🌱';
      case OceanActivityType.coralGrown:
        return '🪸';
      case OceanActivityType.creatureDiscovered:
        return '🐠';
      case OceanActivityType.reefExpanded:
        return '🌊';
      case OceanActivityType.pollutionEvent:
        return '⚠️';
      case OceanActivityType.pearlsEarned:
        return '💎';
      case OceanActivityType.biomeUnlocked:
        return '🗺️';
      case OceanActivityType.achievementUnlocked:
        return '🏆';
      case OceanActivityType.ecosystemThriving:
        return '🔥';
      case OceanActivityType.dailyBonus:
        return '🎁';
      case OceanActivityType.coralPurchased:
        return '🛒';
      case OceanActivityType.decorationAdded:
        return '✨';
    }
  }
}

enum ActivityPriority {
  low,
  normal,
  high,
  urgent,
}

extension ActivityPriorityExtension on ActivityPriority {
  String get displayName {
    switch (this) {
      case ActivityPriority.low:
        return 'Low';
      case ActivityPriority.normal:
        return 'Normal';
      case ActivityPriority.high:
        return 'High';
      case ActivityPriority.urgent:
        return 'Urgent';
    }
  }

  String get color {
    switch (this) {
      case ActivityPriority.low:
        return '#87CEEB'; // Light blue
      case ActivityPriority.normal:
        return '#00A6D6'; // Tropical blue
      case ActivityPriority.high:
        return '#FF8C00'; // Orange
      case ActivityPriority.urgent:
        return '#FF6B6B'; // Red
    }
  }
}