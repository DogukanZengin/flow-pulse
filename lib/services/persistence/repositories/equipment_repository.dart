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
      orderBy: 'unlock_rp, name',
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
      orderBy: 'unlock_rp, name',
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

  // Get equipment available at RP threshold
  Future<List<Map<String, dynamic>>> getEquipmentAvailableAtRP(int cumulativeRP) async {
    final db = await _persistence.database;
    
    return await db.query(
      'equipment',
      where: 'unlock_rp <= ?',
      whereArgs: [cumulativeRP],
      orderBy: 'unlock_rp DESC, category, name',
    );
  }

  // Get equipment by rarity
  Future<List<Map<String, dynamic>>> getEquipmentByRarity(String rarity) async {
    final db = await _persistence.database;
    
    return await db.query(
      'equipment',
      where: 'rarity = ?',
      whereArgs: [rarity],
      orderBy: 'unlock_rp, name',
    );
  }

  // Check and unlock equipment based on RP
  Future<List<String>> checkAndUnlockEquipmentByRP(int cumulativeRP) async {
    final db = await _persistence.database;
    final unlockedItems = <String>[];
    
    // Find equipment that should be unlocked but isn't based on RP
    final toUnlock = await db.query(
      'equipment',
      where: 'unlock_rp <= ? AND is_unlocked = 0',
      whereArgs: [cumulativeRP],
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
    
    // Define comprehensive equipment items across all categories
    final defaultEquipment = [
      // BREATHING SYSTEMS
      {
        'id': 'mask_snorkel',
        'name': 'Mask & Snorkel',
        'category': 'breathing',
        'description': 'Basic underwater vision for shallow water research',
        'icon': '🤿',
        'is_unlocked': 1,
        'is_equipped': 0,
        'unlock_rp': 0,
        'discovery_bonus': 0.0,
        'session_bonus': 0.0,
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
        'unlock_rp': 150,
        'discovery_bonus': 0.15,
        'session_bonus': 0.2,
        'rarity': 'uncommon',
      },
      {
        'id': 'rebreather',
        'name': 'Closed-Circuit Rebreather',
        'category': 'breathing',
        'description': 'Advanced breathing system for long-duration research',
        'icon': '⚙️',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 750,
        'discovery_bonus': 0.25,
        'session_bonus': 0.35,
        'rarity': 'rare',
      },
      {
        'id': 'atmospheric_suit',
        'name': 'Atmospheric Diving Suit',
        'category': 'breathing',
        'description': 'Pressurized suit for deep ocean exploration',
        'icon': '🤖',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 1800,
        'discovery_bonus': 0.4,
        'session_bonus': 0.5,
        'rarity': 'epic',
      },

      // MOBILITY EQUIPMENT
      {
        'id': 'diving_fins',
        'name': 'Diving Fins',
        'category': 'mobility',
        'description': 'Improved movement speed underwater',
        'icon': '🦶',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 50,
        'discovery_bonus': 0.05,
        'session_bonus': 0.0,
        'rarity': 'common',
      },
      {
        'id': 'monofin',
        'name': 'Professional Monofin',
        'category': 'mobility',
        'description': 'High-efficiency swimming for marine biologists',
        'icon': '🐋',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 300,
        'discovery_bonus': 0.1,
        'session_bonus': 0.1,
        'rarity': 'uncommon',
      },
      {
        'id': 'dpv',
        'name': 'Diver Propulsion Vehicle',
        'category': 'mobility',
        'description': 'Underwater scooter for covering large research areas',
        'icon': '🛴',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 500,
        'discovery_bonus': 0.2,
        'session_bonus': 0.15,
        'rarity': 'rare',
      },
      {
        'id': 'jetpack',
        'name': 'Underwater Jetpack',
        'category': 'mobility',
        'description': 'Advanced propulsion for rapid underwater exploration',
        'icon': '🚀',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 1400,
        'discovery_bonus': 0.3,
        'session_bonus': 0.25,
        'rarity': 'epic',
      },

      // DOCUMENTATION TOOLS
      {
        'id': 'waterproof_notebook',
        'name': 'Waterproof Research Notebook',
        'category': 'documentation',
        'description': 'Manual species logging and observation notes',
        'icon': '📓',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 50,
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
        'unlock_rp': 150,
        'discovery_bonus': 0.1,
        'session_bonus': 0.05,
        'rarity': 'common',
      },
      {
        'id': 'dslr_housing',
        'name': 'Professional DSLR Housing',
        'category': 'documentation',
        'description': 'High-quality underwater photography system',
        'icon': '📸',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 300,
        'discovery_bonus': 0.15,
        'session_bonus': 0.1,
        'rarity': 'uncommon',
      },
      {
        'id': 'video_system',
        'name': '4K Video Documentation System',
        'category': 'documentation',
        'description': 'Professional underwater video recording',
        'icon': '🎥',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 750,
        'discovery_bonus': 0.2,
        'session_bonus': 0.15,
        'rarity': 'rare',
      },

      // VISIBILITY ENHANCEMENT
      {
        'id': 'basic_light',
        'name': 'Basic Diving Light',
        'category': 'visibility',
        'description': 'Essential illumination for underwater research',
        'icon': '🔦',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 50,
        'discovery_bonus': 0.08,
        'session_bonus': 0.0,
        'rarity': 'common',
      },
      {
        'id': 'led_array',
        'name': 'High-Power LED Array',
        'category': 'visibility',
        'description': 'Powerful lighting system for detailed observation',
        'icon': '💡',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 300,
        'discovery_bonus': 0.15,
        'session_bonus': 0.05,
        'rarity': 'uncommon',
      },
      {
        'id': 'laser_scanner',
        'name': 'Underwater Laser Scanner',
        'category': 'visibility',
        'description': '3D mapping and measurement system',
        'icon': '⚡',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 1050,
        'discovery_bonus': 0.25,
        'session_bonus': 0.2,
        'rarity': 'epic',
      },

      // SAFETY EQUIPMENT
      {
        'id': 'safety_whistle',
        'name': 'Emergency Whistle',
        'category': 'safety',
        'description': 'Basic surface signaling device',
        'icon': '🔔',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 50,
        'discovery_bonus': 0.0,
        'session_bonus': 0.05,
        'rarity': 'common',
      },
      {
        'id': 'dive_computer',
        'name': 'Advanced Dive Computer',
        'category': 'safety',
        'description': 'Monitors depth, time, and decompression status',
        'icon': '⌚',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 300,
        'discovery_bonus': 0.1,
        'session_bonus': 0.15,
        'rarity': 'uncommon',
      },
      {
        'id': 'emergency_beacon',
        'name': 'Underwater Emergency Beacon',
        'category': 'safety',
        'description': 'GPS-enabled emergency rescue system',
        'icon': '📡',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 750,
        'discovery_bonus': 0.05,
        'session_bonus': 0.25,
        'rarity': 'rare',
      },

      // SAMPLING EQUIPMENT
      {
        'id': 'sample_bags',
        'name': 'Mesh Sample Bags',
        'category': 'sampling',
        'description': 'Basic specimen collection containers',
        'icon': '🎒',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 50,
        'discovery_bonus': 0.05,
        'session_bonus': 0.08,
        'rarity': 'common',
      },
      {
        'id': 'vacuum_sampler',
        'name': 'Underwater Vacuum Sampler',
        'category': 'sampling',
        'description': 'Gentle collection of small marine organisms',
        'icon': '🔌',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 300,
        'discovery_bonus': 0.15,
        'session_bonus': 0.1,
        'rarity': 'uncommon',
      },
      {
        'id': 'coring_system',
        'name': 'Sediment Coring System',
        'category': 'sampling',
        'description': 'Advanced seafloor sediment collection',
        'icon': '🔧',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 1050,
        'discovery_bonus': 0.2,
        'session_bonus': 0.15,
        'rarity': 'rare',
      },

      // DETECTION SYSTEMS
      {
        'id': 'metal_detector',
        'name': 'Underwater Metal Detector',
        'category': 'detection',
        'description': 'Locate metallic objects and shipwrecks',
        'icon': '🔍',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 150,
        'discovery_bonus': 0.12,
        'session_bonus': 0.0,
        'rarity': 'common',
      },
      {
        'id': 'sonar_system',
        'name': 'Portable Sonar System',
        'category': 'detection',
        'description': 'Sound-based underwater mapping and detection',
        'icon': '📊',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 500,
        'discovery_bonus': 0.18,
        'session_bonus': 0.1,
        'rarity': 'uncommon',
      },
      {
        'id': 'multibeam_sonar',
        'name': 'Multibeam Sonar Array',
        'category': 'detection',
        'description': 'Advanced 3D seafloor mapping system',
        'icon': '🌊',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 1400,
        'discovery_bonus': 0.3,
        'session_bonus': 0.2,
        'rarity': 'epic',
      },

      // ANALYSIS EQUIPMENT
      {
        'id': 'ph_meter',
        'name': 'Underwater pH Meter',
        'category': 'analysis',
        'description': 'Real-time water chemistry analysis',
        'icon': '🧪',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 150,
        'discovery_bonus': 0.08,
        'session_bonus': 0.12,
        'rarity': 'common',
      },
      {
        'id': 'spectrometer',
        'name': 'Portable Spectrometer',
        'category': 'analysis',
        'description': 'Chemical composition analysis of samples',
        'icon': '🔬',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 500,
        'discovery_bonus': 0.15,
        'session_bonus': 0.18,
        'rarity': 'uncommon',
      },
      {
        'id': 'dna_sequencer',
        'name': 'Portable DNA Sequencer',
        'category': 'analysis',
        'description': 'Field-based genetic analysis of specimens',
        'icon': '🧬',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 1800,
        'discovery_bonus': 0.35,
        'session_bonus': 0.3,
        'rarity': 'epic',
      },

      // RESEARCH PLATFORMS
      {
        'id': 'dive_float',
        'name': 'Research Dive Float',
        'category': 'platform',
        'description': 'Surface platform for equipment and safety',
        'icon': '🛟',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 50,
        'discovery_bonus': 0.03,
        'session_bonus': 0.1,
        'rarity': 'common',
      },
      {
        'id': 'inflatable_boat',
        'name': 'Research Inflatable Boat',
        'category': 'platform',
        'description': 'Mobile research base with equipment storage',
        'icon': '🚤',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 300,
        'discovery_bonus': 0.1,
        'session_bonus': 0.2,
        'rarity': 'uncommon',
      },
      {
        'id': 'research_vessel',
        'name': 'Dedicated Research Vessel',
        'category': 'platform',
        'description': 'Fully equipped marine research ship',
        'icon': '🚢',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 2750,
        'discovery_bonus': 0.5,
        'session_bonus': 0.4,
        'rarity': 'legendary',
      },

      // COMMUNICATION SYSTEMS
      {
        'id': 'hand_signals',
        'name': 'Underwater Hand Signals',
        'category': 'communication',
        'description': 'Basic underwater communication method',
        'icon': '👋',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 50,
        'discovery_bonus': 0.0,
        'session_bonus': 0.05,
        'rarity': 'common',
      },
      {
        'id': 'underwater_radio',
        'name': 'Through-Water Communication System',
        'category': 'communication',
        'description': 'Radio communication underwater',
        'icon': '📻',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 300,
        'discovery_bonus': 0.05,
        'session_bonus': 0.15,
        'rarity': 'uncommon',
      },
      {
        'id': 'satellite_comm',
        'name': 'Satellite Communication Array',
        'category': 'communication',
        'description': 'Global research data transmission',
        'icon': '🛰️',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 1400,
        'discovery_bonus': 0.1,
        'session_bonus': 0.3,
        'rarity': 'rare',
      },

      // CONSERVATION TOOLS
      {
        'id': 'cleanup_bag',
        'name': 'Marine Debris Collection Bag',
        'category': 'conservation',
        'description': 'Remove harmful debris during research',
        'icon': '♻️',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 500,
        'discovery_bonus': 0.05,
        'session_bonus': 0.1,
        'rarity': 'common',
      },
      {
        'id': 'tagging_kit',
        'name': 'Species Tagging Kit',
        'category': 'conservation',
        'description': 'Non-invasive marine animal tagging system',
        'icon': '🏷️',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 750,
        'discovery_bonus': 0.12,
        'session_bonus': 0.18,
        'rarity': 'uncommon',
      },
      {
        'id': 'restoration_kit',
        'name': 'Coral Restoration Kit',
        'category': 'conservation',
        'description': 'Tools for coral reef restoration projects',
        'icon': '🪸',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 1800,
        'discovery_bonus': 0.2,
        'session_bonus': 0.25,
        'rarity': 'epic',
      },

      // VISUALIZATION SYSTEMS
      {
        'id': 'magnifying_glass',
        'name': 'Underwater Magnifying Glass',
        'category': 'visualization',
        'description': 'Close-up examination of small specimens',
        'icon': '🔍',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 500,
        'discovery_bonus': 0.1,
        'session_bonus': 0.08,
        'rarity': 'common',
      },
      {
        'id': 'microscope',
        'name': 'Waterproof Microscope',
        'category': 'visualization',
        'description': 'Field microscopy for detailed species study',
        'icon': '🔬',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 1050,
        'discovery_bonus': 0.18,
        'session_bonus': 0.15,
        'rarity': 'uncommon',
      },
      {
        'id': 'holographic_display',
        'name': 'Holographic Species Display',
        'category': 'visualization',
        'description': 'Advanced 3D visualization of marine life',
        'icon': '✨',
        'is_unlocked': 0,
        'is_equipped': 0,
        'unlock_rp': 2250,
        'discovery_bonus': 0.4,
        'session_bonus': 0.35,
        'rarity': 'legendary',
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