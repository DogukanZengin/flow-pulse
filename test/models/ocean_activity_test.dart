import 'package:flutter_test/flutter_test.dart';
import '../../lib/models/ocean_activity.dart';

void main() {
  group('OceanActivity Model Tests', () {
    group('OceanActivity Creation', () {
      test('should create ocean activity with all required fields', () {
        final timestamp = DateTime.now();
        final activity = OceanActivity(
          id: 'test_activity',
          timestamp: timestamp,
          type: OceanActivityType.coralPlanted,
          title: 'Test Activity',
          description: 'This is a test activity',
          metadata: {'test': 'data'},
          imageAsset: 'test_image.png',
          priority: ActivityPriority.high,
        );

        expect(activity.id, 'test_activity');
        expect(activity.timestamp, timestamp);
        expect(activity.type, OceanActivityType.coralPlanted);
        expect(activity.title, 'Test Activity');
        expect(activity.description, 'This is a test activity');
        expect(activity.metadata['test'], 'data');
        expect(activity.imageAsset, 'test_image.png');
        expect(activity.priority, ActivityPriority.high);
      });

      test('should create activity with default values', () {
        final activity = OceanActivity(
          id: 'default_test',
          timestamp: DateTime.now(),
          type: OceanActivityType.pearlsEarned,
          title: 'Default Test',
          description: 'Test with defaults',
        );

        expect(activity.metadata, {});
        expect(activity.imageAsset, null);
        expect(activity.priority, ActivityPriority.normal);
      });
    });

    group('OceanActivity Serialization', () {
      test('should convert activity to map correctly', () {
        final timestamp = DateTime.now();
        final activity = OceanActivity(
          id: 'serialize_test',
          timestamp: timestamp,
          type: OceanActivityType.creatureDiscovered,
          title: 'Creature Discovered',
          description: 'Found a new creature!',
          metadata: {'creature': 'clownfish', 'rarity': 'common'},
          imageAsset: 'creatures/clownfish.png',
          priority: ActivityPriority.high,
        );

        final map = activity.toMap();

        expect(map['id'], 'serialize_test');
        expect(map['timestamp'], timestamp.millisecondsSinceEpoch);
        expect(map['type'], OceanActivityType.creatureDiscovered.index);
        expect(map['title'], 'Creature Discovered');
        expect(map['description'], 'Found a new creature!');
        expect(map['metadata'], contains('creature'));
        expect(map['image_asset'], 'creatures/clownfish.png');
        expect(map['priority'], ActivityPriority.high.index);
      });

      test('should create activity from map correctly', () {
        final timestamp = DateTime.now();
        final map = {
          'id': 'from_map_test',
          'timestamp': timestamp.millisecondsSinceEpoch,
          'type': OceanActivityType.biomeUnlocked.index,
          'title': 'New Biome',
          'description': 'Unlocked Deep Ocean!',
          'metadata': '{"biome":"Deep Ocean","level":"26"}',
          'image_asset': 'biomes/deep_ocean.png',
          'priority': ActivityPriority.urgent.index,
        };

        final activity = OceanActivity.fromMap(map);

        expect(activity.id, 'from_map_test');
        expect(activity.timestamp.millisecondsSinceEpoch, timestamp.millisecondsSinceEpoch);
        expect(activity.type, OceanActivityType.biomeUnlocked);
        expect(activity.title, 'New Biome');
        expect(activity.description, 'Unlocked Deep Ocean!');
        expect(activity.metadata['biome'], 'Deep Ocean');
        expect(activity.metadata['level'], '26');
        expect(activity.imageAsset, 'biomes/deep_ocean.png');
        expect(activity.priority, ActivityPriority.urgent);
      });

      test('should handle null values in map correctly', () {
        final timestamp = DateTime.now();
        final map = {
          'id': 'null_test',
          'timestamp': timestamp.millisecondsSinceEpoch,
          'type': OceanActivityType.dailyBonus.index,
          'title': 'Daily Bonus',
          'description': 'Earned daily pearls',
          'metadata': null,
          'image_asset': null,
          'priority': null, // Should default to normal
        };

        final activity = OceanActivity.fromMap(map);

        expect(activity.metadata, {});
        expect(activity.imageAsset, null);
        expect(activity.priority, ActivityPriority.normal);
      });

      test('should handle empty metadata string', () {
        final map = {
          'id': 'empty_meta',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'type': OceanActivityType.pearlsEarned.index,
          'title': 'Test',
          'description': 'Test',
          'metadata': '',
          'image_asset': null,
          'priority': ActivityPriority.normal.index,
        };

        final activity = OceanActivity.fromMap(map);
        expect(activity.metadata, {});
      });
    });

    group('OceanActivity copyWith', () {
      test('should copy activity with modified fields', () {
        final original = OceanActivity(
          id: 'original',
          timestamp: DateTime.now(),
          type: OceanActivityType.coralPlanted,
          title: 'Original Title',
          description: 'Original description',
          priority: ActivityPriority.normal,
        );

        final modified = original.copyWith(
          title: 'Modified Title',
          priority: ActivityPriority.high,
          metadata: {'new': 'data'},
        );

        expect(modified.id, original.id);
        expect(modified.title, 'Modified Title');
        expect(modified.priority, ActivityPriority.high);
        expect(modified.metadata['new'], 'data');
        expect(modified.description, original.description); // Unchanged
        expect(original.title, 'Original Title'); // Original unchanged
      });
    });

    group('OceanActivity Display Properties', () {
      test('should format time correctly', () {
        final now = DateTime.now();
        
        final justNow = OceanActivity(
          id: 'just_now',
          timestamp: now,
          type: OceanActivityType.pearlsEarned,
          title: 'Just Now',
          description: 'Just happened',
        );

        final minutesAgo = OceanActivity(
          id: 'minutes_ago',
          timestamp: now.subtract(const Duration(minutes: 5)),
          type: OceanActivityType.pearlsEarned,
          title: 'Minutes Ago',
          description: '5 minutes ago',
        );

        final hoursAgo = OceanActivity(
          id: 'hours_ago',
          timestamp: now.subtract(const Duration(hours: 2)),
          type: OceanActivityType.pearlsEarned,
          title: 'Hours Ago',
          description: '2 hours ago',
        );

        final daysAgo = OceanActivity(
          id: 'days_ago',
          timestamp: now.subtract(const Duration(days: 3)),
          type: OceanActivityType.pearlsEarned,
          title: 'Days Ago',
          description: '3 days ago',
        );

        final weeksAgo = OceanActivity(
          id: 'weeks_ago',
          timestamp: now.subtract(const Duration(days: 10)),
          type: OceanActivityType.pearlsEarned,
          title: 'Weeks Ago',
          description: '10 days ago',
        );

        expect(justNow.formattedTime, 'Just now');
        expect(minutesAgo.formattedTime, '5m ago');
        expect(hoursAgo.formattedTime, '2h ago');
        expect(daysAgo.formattedTime, '3d ago');
        expect(weeksAgo.formattedTime, contains('/'));
      });

      test('should return correct display names', () {
        final activity = OceanActivity(
          id: 'display_test',
          timestamp: DateTime.now(),
          type: OceanActivityType.achievementUnlocked,
          title: 'Achievement',
          description: 'Got achievement',
          priority: ActivityPriority.high,
        );

        expect(activity.typeDisplayName, 'Achievement Unlocked');
        expect(activity.priorityDisplayName, 'High');
      });
    });

    group('Factory Constructors', () {
      test('should create coral planted activity correctly', () {
        final activity = OceanActivity.coralPlanted(
          coralType: 'Brain Coral',
          biome: 'Shallow Waters',
        );

        expect(activity.type, OceanActivityType.coralPlanted);
        expect(activity.title, 'Coral Planted');
        expect(activity.description, 'Planted Brain Coral coral in Shallow Waters');
        expect(activity.metadata['coralType'], 'Brain Coral');
        expect(activity.metadata['biome'], 'Shallow Waters');
        expect(activity.priority, ActivityPriority.normal);
      });

      test('should create coral grown activity correctly', () {
        final activity = OceanActivity.coralGrown(
          coralType: 'Staghorn Coral',
          stage: 'Flourishing',
          sessionMinutes: 25,
        );

        expect(activity.type, OceanActivityType.coralGrown);
        expect(activity.title, 'Coral Bloomed');
        expect(activity.description, '🪸 Staghorn Coral coral reached Flourishing stage after 25min focus session');
        expect(activity.metadata['coralType'], 'Staghorn Coral');
        expect(activity.metadata['stage'], 'Flourishing');
        expect(activity.metadata['sessionMinutes'], '25');
        expect(activity.priority, ActivityPriority.high);
      });

      test('should create creature discovered activity correctly', () {
        final activity = OceanActivity.creatureDiscovered(
          creatureName: 'Whale Shark',
          rarity: 'Legendary',
          pearlsEarned: 400,
        );

        expect(activity.type, OceanActivityType.creatureDiscovered);
        expect(activity.title, 'New Species Discovered!');
        expect(activity.description, '🐠 Whale Shark (Legendary) discovered! Earned 400 pearls');
        expect(activity.metadata['creatureName'], 'Whale Shark');
        expect(activity.metadata['rarity'], 'Legendary');
        expect(activity.metadata['pearlsEarned'], '400');
        expect(activity.priority, ActivityPriority.high);
      });

      test('should create pollution event activity correctly', () {
        final activity = OceanActivity.pollutionEvent(
          reason: 'Session abandoned',
          damageAmount: 10,
        );

        expect(activity.type, OceanActivityType.pollutionEvent);
        expect(activity.title, 'Ecosystem Pollution');
        expect(activity.description, '⚠️ Session abandoned - Ecosystem health decreased by 10%');
        expect(activity.metadata['reason'], 'Session abandoned');
        expect(activity.metadata['damageAmount'], '10');
        expect(activity.priority, ActivityPriority.urgent);
      });

      test('should create biome unlocked activity correctly', () {
        final activity = OceanActivity.biomeUnlocked(
          biomeName: 'Deep Ocean',
          requiredLevel: 26,
        );

        expect(activity.type, OceanActivityType.biomeUnlocked);
        expect(activity.title, 'New Biome Unlocked!');
        expect(activity.description, '🌊 Deep Ocean biome unlocked at level 26!');
        expect(activity.metadata['biomeName'], 'Deep Ocean');
        expect(activity.metadata['requiredLevel'], '26');
        expect(activity.priority, ActivityPriority.high);
      });

      test('should create pearls earned activity correctly', () {
        final activity = OceanActivity.pearlsEarned(
          amount: 50,
          source: 'completed session',
        );

        expect(activity.type, OceanActivityType.pearlsEarned);
        expect(activity.title, 'Pearls Earned');
        expect(activity.description, '💎 Earned 50 pearls from completed session');
        expect(activity.metadata['amount'], '50');
        expect(activity.metadata['source'], 'completed session');
        expect(activity.priority, ActivityPriority.low);
      });

      test('should create streak milestone activity correctly', () {
        final activity = OceanActivity.streakMilestone(
          streakDays: 7,
          bonusPearls: 35,
        );

        expect(activity.type, OceanActivityType.ecosystemThriving);
        expect(activity.title, 'Ecosystem Thriving!');
        expect(activity.description, '🔥 7 day streak! Bonus: 35 pearls');
        expect(activity.metadata['streakDays'], '7');
        expect(activity.metadata['bonusPearls'], '35');
        expect(activity.priority, ActivityPriority.high);
      });

      test('should create achievement unlocked activity correctly', () {
        final activity = OceanActivity.achievementUnlocked(
          achievementName: 'Deep Sea Explorer',
          achievementDescription: 'Complete 50 focus sessions',
          rewardPearls: 100,
        );

        expect(activity.type, OceanActivityType.achievementUnlocked);
        expect(activity.title, 'Achievement Unlocked!');
        expect(activity.description, '🏆 Deep Sea Explorer - Complete 50 focus sessions (+100 pearls)');
        expect(activity.metadata['achievementName'], 'Deep Sea Explorer');
        expect(activity.metadata['achievementDescription'], 'Complete 50 focus sessions');
        expect(activity.metadata['rewardPearls'], '100');
        expect(activity.priority, ActivityPriority.high);
      });

      test('should create activities with custom timestamps', () {
        final customTime = DateTime(2024, 1, 15, 10, 30);
        
        final activity = OceanActivity.coralPlanted(
          coralType: 'Fire Coral',
          biome: 'Deep Ocean',
          timestamp: customTime,
        );

        expect(activity.timestamp, customTime);
      });
    });
  });

  group('OceanActivityType Tests', () {
    test('should have correct display names', () {
      expect(OceanActivityType.coralPlanted.displayName, 'Coral Planted');
      expect(OceanActivityType.coralGrown.displayName, 'Coral Grown');
      expect(OceanActivityType.creatureDiscovered.displayName, 'Creature Discovered');
      expect(OceanActivityType.reefExpanded.displayName, 'Reef Expanded');
      expect(OceanActivityType.pollutionEvent.displayName, 'Pollution Event');
      expect(OceanActivityType.pearlsEarned.displayName, 'Pearls Earned');
      expect(OceanActivityType.biomeUnlocked.displayName, 'Biome Unlocked');
      expect(OceanActivityType.achievementUnlocked.displayName, 'Achievement Unlocked');
      expect(OceanActivityType.ecosystemThriving.displayName, 'Ecosystem Thriving');
      expect(OceanActivityType.dailyBonus.displayName, 'Daily Bonus');
      expect(OceanActivityType.coralPurchased.displayName, 'Coral Purchased');
      expect(OceanActivityType.decorationAdded.displayName, 'Decoration Added');
    });

    test('should have correct emojis', () {
      expect(OceanActivityType.coralPlanted.emoji, '🌱');
      expect(OceanActivityType.coralGrown.emoji, '🪸');
      expect(OceanActivityType.creatureDiscovered.emoji, '🐠');
      expect(OceanActivityType.reefExpanded.emoji, '🌊');
      expect(OceanActivityType.pollutionEvent.emoji, '⚠️');
      expect(OceanActivityType.pearlsEarned.emoji, '💎');
      expect(OceanActivityType.biomeUnlocked.emoji, '🗺️');
      expect(OceanActivityType.achievementUnlocked.emoji, '🏆');
      expect(OceanActivityType.ecosystemThriving.emoji, '🔥');
      expect(OceanActivityType.dailyBonus.emoji, '🎁');
      expect(OceanActivityType.coralPurchased.emoji, '🛒');
      expect(OceanActivityType.decorationAdded.emoji, '✨');
    });
  });

  group('ActivityPriority Tests', () {
    test('should have correct display names', () {
      expect(ActivityPriority.low.displayName, 'Low');
      expect(ActivityPriority.normal.displayName, 'Normal');
      expect(ActivityPriority.high.displayName, 'High');
      expect(ActivityPriority.urgent.displayName, 'Urgent');
    });

    test('should have correct colors', () {
      expect(ActivityPriority.low.color, '#87CEEB'); // Light blue
      expect(ActivityPriority.normal.color, '#00A6D6'); // Tropical blue
      expect(ActivityPriority.high.color, '#FF8C00'); // Orange
      expect(ActivityPriority.urgent.color, '#FF6B6B'); // Red
    });
  });

  group('Metadata Encoding/Decoding Tests', () {
    test('should encode and decode metadata correctly', () {
      final activity = OceanActivity(
        id: 'metadata_test',
        timestamp: DateTime.now(),
        type: OceanActivityType.creatureDiscovered,
        title: 'Test',
        description: 'Test metadata',
        metadata: {
          'creature': 'clownfish',
          'rarity': 'common',
          'pearls': '10',
        },
      );

      final map = activity.toMap();
      final decoded = OceanActivity.fromMap(map);

      expect(decoded.metadata['creature'], 'clownfish');
      expect(decoded.metadata['rarity'], 'common');
      expect(decoded.metadata['pearls'], '10');
    });

    test('should handle empty metadata', () {
      final activity = OceanActivity(
        id: 'empty_metadata',
        timestamp: DateTime.now(),
        type: OceanActivityType.pearlsEarned,
        title: 'Empty Metadata',
        description: 'No metadata',
      );

      final map = activity.toMap();
      final decoded = OceanActivity.fromMap(map);

      expect(decoded.metadata, {});
    });

    test('should handle malformed metadata gracefully', () {
      final map = {
        'id': 'malformed_test',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'type': OceanActivityType.pearlsEarned.index,
        'title': 'Test',
        'description': 'Test',
        'metadata': 'malformed{data:broken}',
        'image_asset': null,
        'priority': ActivityPriority.normal.index,
      };

      final activity = OceanActivity.fromMap(map);
      expect(activity.metadata, {}); // Should gracefully handle malformed data
    });
  });
}