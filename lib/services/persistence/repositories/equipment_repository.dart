import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../persistence_service.dart';

/// Repository for managing equipment data
class EquipmentRepository {
  final PersistenceService _persistence;
  
  EquipmentRepository(this._persistence);

  // Save equipment item
  Future<void> saveEquipment(Map<String, dynamic> equipment) async {
    final db = await _persistence.database;
    
    await db.insert(
      'equipment',
      equipment,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Save multiple equipment items (batch)
  Future<void> saveEquipmentBatch(List<Map<String, dynamic>> equipmentList) async {
    final db = await _persistence.database;
    final batch = db.batch();
    
    for (final equipment in equipmentList) {
      batch.insert(
        'equipment',
        equipment,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  // Get all equipment
  Future<List<Map<String, dynamic>>> getAllEquipment() async {
    final db = await _persistence.database;
    
    return await db.query(
      'equipment',
      orderBy: 'unlock_level, name',
    );
  }

  // Get unlocked equipment
  Future<List<Map<String, dynamic>>> getUnlockedEquipment() async {
    final db = await _persistence.database;
    
    return await db.query(
      'equipment',
      where: 'is_unlocked = 1',
      orderBy: 'unlock_date DESC',
    );
  }

  // Get equipped items
  Future<List<Map<String, dynamic>>> getEquippedItems() async {
    final db = await _persistence.database;
    
    return await db.query(
      'equipment',
      where: 'is_equipped = 1',
      orderBy: 'category, name',
    );
  }

  // Get equipment by category
  Future<List<Map<String, dynamic>>> getEquipmentByCategory(String category) async {
    final db = await _persistence.database;
    
    return await db.query(
      'equipment',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'unlock_level, name',
    );
  }

  // Get equipment by ID
  Future<Map<String, dynamic>?> getEquipmentById(String id) async {
    final db = await _persistence.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'equipment',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Unlock equipment
  Future<void> unlockEquipment(String equipmentId) async {
    final db = await _persistence.database;
    
    await db.update(
      'equipment',
      {
        'is_unlocked': 1,
        'unlock_date': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [equipmentId],
    );
  }

  // Equip item
  Future<void> equipItem(String equipmentId) async {
    final db = await _persistence.database;
    
    // Get the equipment to check its category
    final equipment = await getEquipmentById(equipmentId);
    if (equipment == null) return;
    
    // Unequip other items in the same category
    await db.update(
      'equipment',
      {'is_equipped': 0},
      where: 'category = ? AND id != ?',
      whereArgs: [equipment['category'], equipmentId],
    );
    
    // Equip the selected item
    await db.update(
      'equipment',
      {'is_equipped': 1},
      where: 'id = ?',
      whereArgs: [equipmentId],
    );
  }

  // Unequip item
  Future<void> unequipItem(String equipmentId) async {
    final db = await _persistence.database;
    
    await db.update(
      'equipment',
      {'is_equipped': 0},
      where: 'id = ?',
      whereArgs: [equipmentId],
    );
  }

  // Get equipment available at level
  Future<List<Map<String, dynamic>>> getEquipmentAvailableAtLevel(int level) async {
    final db = await _persistence.database;
    
    return await db.query(
      'equipment',
      where: 'unlock_level <= ?',
      whereArgs: [level],
      orderBy: 'unlock_level DESC, category, name',
    );
  }

  // Get equipment by rarity
  Future<List<Map<String, dynamic>>> getEquipmentByRarity(String rarity) async {
    final db = await _persistence.database;
    
    return await db.query(
      'equipment',
      where: 'rarity = ?',
      whereArgs: [rarity],
      orderBy: 'unlock_level, name',
    );
  }

  // Check and unlock equipment based on level
  Future<List<String>> checkAndUnlockEquipmentByLevel(int userLevel) async {
    final db = await _persistence.database;
    final unlockedItems = <String>[];
    
    // Find equipment that should be unlocked but isn't
    final toUnlock = await db.query(
      'equipment',
      where: 'unlock_level <= ? AND is_unlocked = 0',
      whereArgs: [userLevel],
    );
    
    for (final equipment in toUnlock) {
      final id = equipment['id'] as String;
      await unlockEquipment(id);
      unlockedItems.add(id);
    }
    
    return unlockedItems;
  }

  // Get total discovery bonus from equipped items
  Future<double> getTotalDiscoveryBonus() async {
    final equipped = await getEquippedItems();
    double totalBonus = 0.0;
    
    for (final item in equipped) {
      totalBonus += (item['discovery_bonus'] as num?)?.toDouble() ?? 0.0;
    }
    
    return totalBonus;
  }

  // Get total session bonus from equipped items
  Future<double> getTotalSessionBonus() async {
    final equipped = await getEquippedItems();
    double totalBonus = 0.0;
    
    for (final item in equipped) {
      totalBonus += (item['session_bonus'] as num?)?.toDouble() ?? 0.0;
    }
    
    return totalBonus;
  }

  // === EQUIPMENT SETS ===
  
  // Save equipment set
  Future<void> saveEquipmentSet(Map<String, dynamic> set) async {
    final db = await _persistence.database;
    
    await db.insert(
      'equipment_sets',
      set,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all equipment sets
  Future<List<Map<String, dynamic>>> getAllEquipmentSets() async {
    final db = await _persistence.database;
    
    return await db.query(
      'equipment_sets',
      orderBy: 'name',
    );
  }

  // Get completed sets
  Future<List<Map<String, dynamic>>> getCompletedSets() async {
    final db = await _persistence.database;
    
    return await db.query(
      'equipment_sets',
      where: 'is_complete = 1',
      orderBy: 'completed_date DESC',
    );
  }

  // Check and complete equipment sets
  Future<List<String>> checkAndCompleteSets() async {
    final db = await _persistence.database;
    final completedSets = <String>[];
    
    // Get all sets
    final sets = await getAllEquipmentSets();
    
    for (final set in sets) {
      if (set['is_complete'] == 1) continue;
      
      final setId = set['id'] as String;
      final itemsJson = set['items'] as String;
      final items = List<String>.from(jsonDecode(itemsJson));
      
      // Check if all items in the set are unlocked
      bool allUnlocked = true;
      for (final itemId in items) {
        final item = await getEquipmentById(itemId);
        if (item == null || item['is_unlocked'] != 1) {
          allUnlocked = false;
          break;
        }
      }
      
      if (allUnlocked) {
        // Complete the set
        await db.update(
          'equipment_sets',
          {
            'is_complete': 1,
            'completed_date': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [setId],
        );
        completedSets.add(setId);
      }
    }
    
    return completedSets;
  }

  // Get equipment statistics
  Future<Map<String, dynamic>> getEquipmentStatistics() async {
    final db = await _persistence.database;
    
    // Total equipment
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM equipment'
    );
    final totalEquipment = totalResult.first['total'] as int;
    
    // Unlocked equipment
    final unlockedResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM equipment WHERE is_unlocked = 1'
    );
    final unlockedEquipment = unlockedResult.first['total'] as int;
    
    // Equipped items
    final equippedResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM equipment WHERE is_equipped = 1'
    );
    final equippedItems = equippedResult.first['total'] as int;
    
    // Equipment by category
    final categoryResult = await db.rawQuery('''
      SELECT category, COUNT(*) as count 
      FROM equipment 
      WHERE is_unlocked = 1 
      GROUP BY category
    ''');
    
    final categoryDistribution = <String, int>{};
    for (final row in categoryResult) {
      categoryDistribution[row['category'] as String] = row['count'] as int;
    }
    
    // Equipment by rarity
    final rarityResult = await db.rawQuery('''
      SELECT rarity, COUNT(*) as count 
      FROM equipment 
      WHERE is_unlocked = 1 
      GROUP BY rarity
    ''');
    
    final rarityDistribution = <String, int>{};
    for (final row in rarityResult) {
      final rarity = row['rarity'] as String?;
      if (rarity != null) {
        rarityDistribution[rarity] = row['count'] as int;
      }
    }
    
    // Completed sets
    final setsResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM equipment_sets WHERE is_complete = 1'
    );
    final completedSets = setsResult.first['total'] as int;
    
    // Total sets
    final totalSetsResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM equipment_sets'
    );
    final totalSets = totalSetsResult.first['total'] as int;
    
    return {
      'totalEquipment': totalEquipment,
      'unlockedEquipment': unlockedEquipment,
      'equippedItems': equippedItems,
      'unlockPercentage': totalEquipment > 0 
          ? (unlockedEquipment / totalEquipment * 100).toStringAsFixed(1)
          : '0.0',
      'categoryDistribution': categoryDistribution,
      'rarityDistribution': rarityDistribution,
      'completedSets': completedSets,
      'totalSets': totalSets,
      'setsCompletionPercentage': totalSets > 0
          ? (completedSets / totalSets * 100).toStringAsFixed(1)
          : '0.0',
    };
  }

  // Initialize default equipment
  Future<void> initializeDefaultEquipment() async {
    final existingEquipment = await getAllEquipment();
    if (existingEquipment.isNotEmpty) return; // Already initialized
    
    // Define default equipment items
    final defaultEquipment = [
      {
        'id': 'mask_snorkel',
        'name': 'Mask & Snorkel',
        'category': 'breathing',
        'description': 'Basic underwater vision for shallow water research',
        'icon': '🤿',
        'is_unlocked': 1, // Start with this unlocked
        'is_equipped': 0,
        'unlock_level': 1,
        'discovery_bonus': 0.0,
        'session_bonus': 0.0,
        'rarity': 'common',
      },
      {
        'id': 'diving_fins',
        'name': 'Diving Fins',
        'category': 'mobility',
        'description': 'Improved movement speed underwater',
        'icon': '🦶',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_level': 3,
        'discovery_bonus': 0.05,
        'session_bonus': 0.0,
        'rarity': 'common',
      },
      {
        'id': 'waterproof_notebook',
        'name': 'Waterproof Research Notebook',
        'category': 'documentation',
        'description': 'Manual species logging and observation notes',
        'icon': '📓',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_level': 5,
        'discovery_bonus': 0.0,
        'session_bonus': 0.1,
        'rarity': 'common',
      },
      {
        'id': 'basic_camera',
        'name': 'Basic Underwater Camera',
        'category': 'documentation',
        'description': 'Document species discoveries with photos',
        'icon': '📷',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_level': 8,
        'discovery_bonus': 0.1,
        'session_bonus': 0.05,
        'rarity': 'common',
      },
      {
        'id': 'scuba_gear',
        'name': 'Scuba Diving Gear',
        'category': 'breathing',
        'description': 'Full scuba equipment for extended underwater research',
        'icon': '🤿',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_level': 10,
        'discovery_bonus': 0.15,
        'session_bonus': 0.2,
        'rarity': 'uncommon',
      },
    ];
    
    await saveEquipmentBatch(defaultEquipment);
  }

  // Reset equipment progress
  Future<void> resetEquipment() async {
    final db = await _persistence.database;
    
    // Reset all equipment to locked and unequipped
    await db.update(
      'equipment',
      {
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_date': null,
      },
    );
    
    // Unlock starting equipment
    await db.update(
      'equipment',
      {
        'is_unlocked': 1,
        'unlock_date': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: ['mask_snorkel'],
    );
    
    // Reset equipment sets
    await db.update(
      'equipment_sets',
      {
        'is_complete': 0,
        'completed_date': null,
      },
    );
  }
}