import 'package:sqflite/sqflite.dart';
import '../../../models/creature.dart';
import '../../../models/coral.dart';
import '../../../models/aquarium.dart';
import '../../../models/ocean_activity.dart';
import '../persistence_service.dart';

/// Repository for managing ocean-related data
class OceanRepository {
  final PersistenceService _persistence;
  
  OceanRepository(this._persistence);

  // === AQUARIUM METHODS ===
  
  // Save or update aquarium
  Future<void> saveAquarium(Aquarium aquarium) async {
    final db = await _persistence.database;
    
    await db.insert(
      'aquariums',
      aquarium.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get aquarium by ID
  Future<Aquarium?> getAquarium(String id) async {
    final db = await _persistence.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'aquariums',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return Aquarium.fromMap(maps.first);
    }
    return null;
  }

  // Update aquarium stats
  Future<void> updateAquariumStats({
    required String aquariumId,
    int? pearlBalance,
    int? crystalBalance,
    int? totalCreaturesDiscovered,
    int? totalCoralsGrown,
    int? totalFocusTime,
    int? currentStreak,
    int? longestStreak,
  }) async {
    final db = await _persistence.database;
    
    final updates = <String, dynamic>{};
    if (pearlBalance != null) updates['pearl_balance'] = pearlBalance;
    if (crystalBalance != null) updates['crystal_balance'] = crystalBalance;
    if (totalCreaturesDiscovered != null) {
      updates['total_creatures_discovered'] = totalCreaturesDiscovered;
    }
    if (totalCoralsGrown != null) updates['total_corals_grown'] = totalCoralsGrown;
    if (totalFocusTime != null) updates['total_focus_time'] = totalFocusTime;
    if (currentStreak != null) updates['current_streak'] = currentStreak;
    if (longestStreak != null) updates['longest_streak'] = longestStreak;
    updates['last_active_at'] = DateTime.now().millisecondsSinceEpoch;
    
    await db.update(
      'aquariums',
      updates,
      where: 'id = ?',
      whereArgs: [aquariumId],
    );
  }

  // === CREATURE METHODS ===
  
  // Save creature
  Future<void> saveCreature(Creature creature) async {
    final db = await _persistence.database;
    
    await db.insert(
      'creatures',
      creature.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Save multiple creatures (batch operation)
  Future<void> saveCreatures(List<Creature> creatures) async {
    final db = await _persistence.database;
    final batch = db.batch();
    
    for (final creature in creatures) {
      batch.insert(
        'creatures',
        creature.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  // Get all creatures
  Future<List<Creature>> getAllCreatures() async {
    final db = await _persistence.database;
    
    final List<Map<String, dynamic>> maps = await db.query('creatures');
    return List.generate(maps.length, (i) => Creature.fromMap(maps[i]));
  }

  // Get creatures by biome
  Future<List<Creature>> getCreaturesByBiome(BiomeType biome) async {
    final db = await _persistence.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'creatures',
      where: 'habitat = ?',
      whereArgs: [biome.index],
    );
    
    return List.generate(maps.length, (i) => Creature.fromMap(maps[i]));
  }

  // Get discovered creatures
  Future<List<Creature>> getDiscoveredCreatures() async {
    final db = await _persistence.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'creatures',
      where: 'is_discovered = 1',
      orderBy: 'discovered_at DESC',
    );
    
    return List.generate(maps.length, (i) => Creature.fromMap(maps[i]));
  }

  // Get undiscovered creatures
  Future<List<Creature>> getUndiscoveredCreatures() async {
    final db = await _persistence.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'creatures',
      where: 'is_discovered = 0',
      orderBy: 'rarity, name',
    );
    
    return List.generate(maps.length, (i) => Creature.fromMap(maps[i]));
  }

  // Discover a creature
  Future<void> discoverCreature(String creatureId) async {
    final db = await _persistence.database;
    
    await db.update(
      'creatures',
      {
        'is_discovered': 1,
        'discovered_at': DateTime.now().millisecondsSinceEpoch,
        'discovery_count': Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT discovery_count FROM creatures WHERE id = ?',
            [creatureId],
          ),
        )! + 1,
      },
      where: 'id = ?',
      whereArgs: [creatureId],
    );
  }

  // Get creature by ID
  Future<Creature?> getCreatureById(String id) async {
    final db = await _persistence.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'creatures',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return Creature.fromMap(maps.first);
    }
    return null;
  }

  // Get creatures by rarity
  Future<List<Creature>> getCreaturesByRarity(CreatureRarity rarity) async {
    final db = await _persistence.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'creatures',
      where: 'rarity = ?',
      whereArgs: [rarity.index],
      orderBy: 'name',
    );
    
    return List.generate(maps.length, (i) => Creature.fromMap(maps[i]));
  }

  // === CORAL METHODS ===
  
  // Save coral
  Future<void> saveCoral(Coral coral) async {
    final db = await _persistence.database;
    
    await db.insert(
      'corals',
      coral.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all corals
  Future<List<Coral>> getAllCorals() async {
    final db = await _persistence.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'corals',
      orderBy: 'planted_at DESC',
    );
    
    return List.generate(maps.length, (i) => Coral.fromMap(maps[i]));
  }

  // Get corals by biome
  Future<List<Coral>> getCoralsByBiome(BiomeType biome) async {
    final db = await _persistence.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'corals',
      where: 'biome = ?',
      whereArgs: [biome.index],
      orderBy: 'planted_at DESC',
    );
    
    return List.generate(maps.length, (i) => Coral.fromMap(maps[i]));
  }

  // Update coral
  Future<void> updateCoral(Coral coral) async {
    final db = await _persistence.database;
    
    await db.update(
      'corals',
      coral.toMap(),
      where: 'id = ?',
      whereArgs: [coral.id],
    );
  }

  // Delete coral
  Future<void> deleteCoral(String coralId) async {
    final db = await _persistence.database;
    
    await db.delete(
      'corals',
      where: 'id = ?',
      whereArgs: [coralId],
    );
  }

  // Get healthy corals
  Future<List<Coral>> getHealthyCorals() async {
    final db = await _persistence.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'corals',
      where: 'is_healthy = 1',
      orderBy: 'stage DESC, planted_at DESC',
    );
    
    return List.generate(maps.length, (i) => Coral.fromMap(maps[i]));
  }

  // === OCEAN ACTIVITY METHODS ===
  
  // Save ocean activity
  Future<void> saveOceanActivity(OceanActivity activity) async {
    final db = await _persistence.database;
    
    await db.insert(
      'ocean_activities',
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get recent ocean activities
  Future<List<OceanActivity>> getRecentOceanActivities({int limit = 50}) async {
    final db = await _persistence.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'ocean_activities',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    
    return List.generate(maps.length, (i) => OceanActivity.fromMap(maps[i]));
  }

  // Get activities by type
  Future<List<OceanActivity>> getActivitiesByType(OceanActivityType type) async {
    final db = await _persistence.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'ocean_activities',
      where: 'type = ?',
      whereArgs: [type.index],
      orderBy: 'timestamp DESC',
    );
    
    return List.generate(maps.length, (i) => OceanActivity.fromMap(maps[i]));
  }

  // Clean up old ocean activities
  Future<void> cleanupOldOceanActivities({int daysToKeep = 30}) async {
    final db = await _persistence.database;
    
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    
    await db.delete(
      'ocean_activities',
      where: 'timestamp < ?',
      whereArgs: [cutoffDate.millisecondsSinceEpoch],
    );
  }

  // === OCEAN STATISTICS ===
  
  // Get ocean statistics
  Future<Map<String, dynamic>> getOceanStatistics() async {
    final db = await _persistence.database;
    
    // Get total creatures discovered
    final creaturesResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM creatures WHERE is_discovered = 1'
    );
    final totalCreatures = creaturesResult.first['total'] as int;
    
    // Get total creatures
    final allCreaturesResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM creatures'
    );
    final totalAllCreatures = allCreaturesResult.first['total'] as int;
    
    // Get total corals grown
    final coralsResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM corals'
    );
    final totalCorals = coralsResult.first['total'] as int;
    
    // Get mature corals
    final matureCoralsResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM corals WHERE stage >= 2'
    );
    final matureCorals = matureCoralsResult.first['total'] as int;
    
    // Get healthy corals
    final healthyCoralsResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM corals WHERE is_healthy = 1'
    );
    final healthyCorals = healthyCoralsResult.first['total'] as int;
    
    // Get rarity distribution
    final rarityResult = await db.rawQuery('''
      SELECT rarity, COUNT(*) as count 
      FROM creatures 
      WHERE is_discovered = 1 
      GROUP BY rarity
    ''');
    
    final rarityDistribution = <String, int>{};
    for (final row in rarityResult) {
      final rarity = CreatureRarity.values[row['rarity'] as int].displayName;
      rarityDistribution[rarity] = row['count'] as int;
    }
    
    // Get biome distribution
    final biomeResult = await db.rawQuery('''
      SELECT habitat, COUNT(*) as count 
      FROM creatures 
      WHERE is_discovered = 1 
      GROUP BY habitat
    ''');
    
    final biomeDistribution = <String, int>{};
    for (final row in biomeResult) {
      final biome = BiomeType.values[row['habitat'] as int].displayName;
      biomeDistribution[biome] = row['count'] as int;
    }
    
    return {
      'totalCreatures': totalCreatures,
      'totalAllCreatures': totalAllCreatures,
      'discoveryPercentage': totalAllCreatures > 0 
          ? (totalCreatures / totalAllCreatures * 100).toStringAsFixed(1)
          : '0.0',
      'totalCorals': totalCorals,
      'matureCorals': matureCorals,
      'healthyCorals': healthyCorals,
      'rarityDistribution': rarityDistribution,
      'biomeDistribution': biomeDistribution,
    };
  }

  // Get discovery progress by biome
  Future<Map<BiomeType, Map<String, int>>> getDiscoveryProgressByBiome() async {
    final db = await _persistence.database;
    
    final progress = <BiomeType, Map<String, int>>{};
    
    for (final biome in BiomeType.values) {
      final totalResult = await db.rawQuery(
        'SELECT COUNT(*) as total FROM creatures WHERE habitat = ?',
        [biome.index],
      );
      
      final discoveredResult = await db.rawQuery(
        'SELECT COUNT(*) as total FROM creatures WHERE habitat = ? AND is_discovered = 1',
        [biome.index],
      );
      
      progress[biome] = {
        'total': totalResult.first['total'] as int,
        'discovered': discoveredResult.first['total'] as int,
      };
    }
    
    return progress;
  }

  // Get recent discoveries
  Future<List<Creature>> getRecentDiscoveries({int limit = 10}) async {
    final db = await _persistence.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'creatures',
      where: 'is_discovered = 1',
      orderBy: 'discovered_at DESC',
      limit: limit,
    );
    
    return List.generate(maps.length, (i) => Creature.fromMap(maps[i]));
  }

  // Check if all creatures in biome discovered
  Future<bool> isBiomeComplete(BiomeType biome) async {
    final db = await _persistence.database;
    
    final result = await db.rawQuery('''
      SELECT 
        (SELECT COUNT(*) FROM creatures WHERE habitat = ?) as total,
        (SELECT COUNT(*) FROM creatures WHERE habitat = ? AND is_discovered = 1) as discovered
    ''', [biome.index, biome.index]);
    
    if (result.isNotEmpty) {
      final total = result.first['total'] as int;
      final discovered = result.first['discovered'] as int;
      return total > 0 && total == discovered;
    }
    
    return false;
  }
}