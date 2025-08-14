import 'dart:math' as math;
import '../models/ocean_activity.dart';
import '../models/session.dart';
import '../models/creature.dart';
import '../models/coral.dart';
import 'database_service.dart';

class OceanActivityService {
  static const int _maxActivities = 200; // Keep last 200 activities

  /// Log coral planting when a session starts
  static Future<void> logCoralPlanted({
    required CoralType coralType,
    required BiomeType biome,
  }) async {
    final activity = OceanActivity.coralPlanted(
      coralType: coralType.displayName,
      biome: biome.displayName,
    );
    
    await DatabaseService.saveOceanActivity(activity);
    await _cleanupOldActivities();
  }

  /// Log coral growth when a session completes successfully
  static Future<void> logCoralGrowth({
    required CoralType coralType,
    required CoralStage finalStage,
    required int sessionDurationMinutes,
    List<Creature> discoveredCreatures = const [],
    int pearlsEarned = 0,
  }) async {
    // Log coral growth
    final coralActivity = OceanActivity.coralGrown(
      coralType: coralType.displayName,
      stage: finalStage.displayName,
      sessionMinutes: sessionDurationMinutes,
    );
    await DatabaseService.saveOceanActivity(coralActivity);

    // Log creature discoveries
    for (final creature in discoveredCreatures) {
      final discoveryActivity = OceanActivity.creatureDiscovered(
        creatureName: creature.name,
        rarity: creature.rarity.displayName,
        pearlsEarned: creature.pearlValue,
      );
      await DatabaseService.saveOceanActivity(discoveryActivity);
    }

    // Log pearl earnings if any
    if (pearlsEarned > 0) {
      final pearlActivity = OceanActivity.pearlsEarned(
        amount: pearlsEarned,
        source: 'coral growth session',
      );
      await DatabaseService.saveOceanActivity(pearlActivity);
    }

    await _cleanupOldActivities();
  }

  /// Log pollution events when sessions are abandoned
  static Future<void> logPollutionEvent({
    required String reason,
    required double ecosystemDamage, // 0.0 to 1.0
  }) async {
    final damagePercent = (ecosystemDamage * 100).round();
    
    final activity = OceanActivity.pollutionEvent(
      reason: reason,
      damageAmount: damagePercent,
    );
    
    await DatabaseService.saveOceanActivity(activity);
    await _cleanupOldActivities();
  }

  /// Log when user levels up and unlocks new biomes
  static Future<void> logBiomeUnlocked({
    required BiomeType biome,
    required int levelReached,
  }) async {
    final activity = OceanActivity.biomeUnlocked(
      biomeName: biome.displayName,
      requiredLevel: levelReached,
    );
    
    await DatabaseService.saveOceanActivity(activity);
    await _cleanupOldActivities();
  }

  /// Log achievement unlocks with ocean theme
  static Future<void> logAchievementUnlocked({
    required String achievementName,
    required String description,
    required int pearlReward,
  }) async {
    final activity = OceanActivity.achievementUnlocked(
      achievementName: _convertToOceanAchievement(achievementName),
      achievementDescription: _convertAchievementDescription(description),
      rewardPearls: pearlReward,
    );
    
    await DatabaseService.saveOceanActivity(activity);
    await _cleanupOldActivities();
  }

  /// Log streak milestones with ecosystem health theme
  static Future<void> logStreakMilestone({
    required int streakDays,
    required int bonusPearls,
  }) async {
    final activity = OceanActivity.streakMilestone(
      streakDays: streakDays,
      bonusPearls: bonusPearls,
    );
    
    await DatabaseService.saveOceanActivity(activity);
    await _cleanupOldActivities();
  }

  /// Log daily login bonuses
  static Future<void> logDailyBonus({
    required int pearlsEarned,
    required int consecutiveDays,
  }) async {
    String description = '🎁 Daily ecosystem check completed! Earned $pearlsEarned pearls';
    if (consecutiveDays > 1) {
      description += ' ($consecutiveDays days in a row!)';
    }

    final activity = OceanActivity(
      id: 'daily_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      type: OceanActivityType.dailyBonus,
      title: 'Daily Ocean Care',
      description: description,
      metadata: {
        'pearls': pearlsEarned.toString(),
        'consecutiveDays': consecutiveDays.toString(),
      },
      priority: ActivityPriority.normal,
    );
    
    await DatabaseService.saveOceanActivity(activity);
    await _cleanupOldActivities();
  }

  /// Log coral purchases from shop
  static Future<void> logCoralPurchase({
    required CoralType coralType,
    required int pearlCost,
    required BiomeType targetBiome,
  }) async {
    final activity = OceanActivity(
      id: 'coral_purchase_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      type: OceanActivityType.coralPurchased,
      title: 'New Coral Seed Acquired',
      description: '🛒 Purchased ${coralType.displayName} seed for $pearlCost pearls',
      metadata: {
        'coralType': coralType.displayName,
        'cost': pearlCost.toString(),
        'targetBiome': targetBiome.displayName,
      },
      priority: ActivityPriority.low,
    );
    
    await DatabaseService.saveOceanActivity(activity);
    await _cleanupOldActivities();
  }

  /// Log major ecosystem events
  static Future<void> logEcosystemEvent({
    required String title,
    required String description,
    OceanActivityType type = OceanActivityType.ecosystemThriving,
    ActivityPriority priority = ActivityPriority.normal,
    Map<String, dynamic>? metadata,
  }) async {
    final activity = OceanActivity(
      id: 'ecosystem_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      type: type,
      title: title,
      description: description,
      metadata: metadata ?? {},
      priority: priority,
    );
    
    await DatabaseService.saveOceanActivity(activity);
    await _cleanupOldActivities();
  }

  /// Convert existing session completion to ocean activities
  static Future<void> logSessionCompletion({
    required Session session,
    required CoralType coralTypeUsed,
    required BiomeType currentBiome,
    List<Creature> newDiscoveries = const [],
    int pearlsEarned = 0,
    bool hadPollution = false,
  }) async {
    if (session.completed) {
      // Log successful coral growth
      await logCoralGrowth(
        coralType: coralTypeUsed,
        finalStage: CoralStage.flourishing,
        sessionDurationMinutes: session.duration ~/ 60,
        discoveredCreatures: newDiscoveries,
        pearlsEarned: pearlsEarned,
      );
    } else {
      // Log pollution event
      await logPollutionEvent(
        reason: 'Focus session abandoned',
        ecosystemDamage: 0.1, // 10% damage
      );
    }
  }

  /// Get recent activities for display in UI
  static Future<List<OceanActivity>> getRecentActivities({int limit = 20}) async {
    return await DatabaseService.getRecentOceanActivities(limit: limit);
  }

  /// Get activities by type for specific filtering
  static Future<List<OceanActivity>> getActivitiesByType(OceanActivityType type) async {
    return await DatabaseService.getActivitiesByType(type);
  }

  /// Get activity statistics for analytics
  static Future<Map<String, dynamic>> getActivityStatistics() async {
    final allActivities = await DatabaseService.getRecentOceanActivities(limit: 1000);
    
    final typeDistribution = <String, int>{};
    final priorityDistribution = <String, int>{};
    final dailyActivity = <String, int>{};

    for (final activity in allActivities) {
      // Type distribution
      final typeName = activity.type.displayName;
      typeDistribution[typeName] = (typeDistribution[typeName] ?? 0) + 1;
      
      // Priority distribution
      final priorityName = activity.priority.displayName;
      priorityDistribution[priorityName] = (priorityDistribution[priorityName] ?? 0) + 1;
      
      // Daily activity (last 7 days)
      final dayKey = '${activity.timestamp.day}/${activity.timestamp.month}';
      final now = DateTime.now();
      if (now.difference(activity.timestamp).inDays <= 7) {
        dailyActivity[dayKey] = (dailyActivity[dayKey] ?? 0) + 1;
      }
    }

    return {
      'totalActivities': allActivities.length,
      'typeDistribution': typeDistribution,
      'priorityDistribution': priorityDistribution,
      'dailyActivity': dailyActivity,
      'mostActiveDay': _getMostActiveDay(dailyActivity),
    };
  }

  // ============ HELPER METHODS ============

  /// Clean up old activities to prevent database bloat
  static Future<void> _cleanupOldActivities() async {
    final activities = await DatabaseService.getRecentOceanActivities(limit: _maxActivities + 50);
    
    if (activities.length > _maxActivities) {
      // Use database cleanup to maintain activity limits
      await DatabaseService.cleanupOldOceanActivities();
    }
  }

  /// Convert standard achievements to ocean-themed versions
  static String _convertToOceanAchievement(String originalName) {
    final oceanAchievements = {
      'Focus Master': 'Deep Sea Explorer',
      'Streak Champion': 'Ecosystem Guardian',
      'Time Warrior': 'Coral Cultivator',
      'Consistency King': 'Marine Biologist',
      'Productivity Pro': 'Ocean Conservation Expert',
      'Session Starter': 'Reef Builder',
      'Break Taker': 'Tide Watcher',
      'Goal Crusher': 'Current Rider',
      'Weekly Winner': 'Seven Seas Navigator',
      'Monthly Master': 'Deep Ocean Diver',
    };
    
    return oceanAchievements[originalName] ?? originalName;
  }

  /// Convert achievement descriptions to ocean theme
  static String _convertAchievementDescription(String originalDescription) {
    return originalDescription
        .replaceAll('focus session', 'coral growth session')
        .replaceAll('productivity', 'ecosystem health')
        .replaceAll('work', 'reef building')
        .replaceAll('task', 'marine conservation')
        .replaceAll('goal', 'ocean exploration milestone');
  }

  static String? _getMostActiveDay(Map<String, int> dailyActivity) {
    if (dailyActivity.isEmpty) return null;
    
    var maxCount = 0;
    String? mostActiveDay;
    
    dailyActivity.forEach((day, count) {
      if (count > maxCount) {
        maxCount = count;
        mostActiveDay = day;
      }
    });
    
    return mostActiveDay;
  }

  /// Create activity for random ecosystem events (for engagement)
  static Future<void> createRandomEcosystemEvent() async {
    final random = math.Random();
    final eventTypes = [
      'Gentle ocean currents bring new nutrients to your reef',
      'Sunlight filters beautifully through the crystal-clear water',
      'A school of fish swims peacefully through your coral garden',
      'The ecosystem shows signs of remarkable health and balance',
      'Marine life activity increases around your thriving corals',
    ];

    if (random.nextDouble() < 0.1) { // 10% chance
      final selectedEvent = eventTypes[random.nextInt(eventTypes.length)];
      
      await logEcosystemEvent(
        title: 'Ecosystem Flourishing',
        description: '✨ $selectedEvent',
        type: OceanActivityType.ecosystemThriving,
        priority: ActivityPriority.low,
      );
    }
  }
}