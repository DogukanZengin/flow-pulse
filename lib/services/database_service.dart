import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/session.dart';
import '../models/creature.dart';
import '../models/coral.dart';
import '../models/aquarium.dart';
import '../models/ocean_activity.dart';
import 'storage_service.dart';

// Import conditionally
import 'package:sqflite_common_ffi/sqflite_ffi.dart' if (dart.library.io) 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  static Database? _database;
  static const String _tableName = 'sessions';
  static bool _initialized = false;

  // Check if we should use SQLite or SharedPreferences
  static bool get _useSQLite => !kIsWeb;

  static Future<void> _initializeDatabaseFactory() async {
    if (_initialized) return;
    
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      // Initialize FFI for desktop platforms
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _initialized = true;
  }

  static Future<Database> get database async {
    if (!_useSQLite) {
      throw UnsupportedError('SQLite not supported on this platform');
    }
    if (_database != null) return _database!;
    await _initializeDatabaseFactory();
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    if (!_useSQLite) {
      throw UnsupportedError('SQLite not supported on this platform');
    }
    
    try {
      String path = join(await getDatabasesPath(), 'flowpulse.db');
      return await openDatabase(
        path,
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Database initialization error: $e');
      }
      rethrow;
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create original sessions table
    await db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        type INTEGER NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create ocean tables if version 2 or higher
    if (version >= 2) {
      await _createOceanTables(db);
    }
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2 && newVersion >= 2) {
      // Add ocean tables
      await _createOceanTables(db);
    }
  }

  static Future<void> _createOceanTables(Database db) async {
    // Aquarium table
    await db.execute('''
      CREATE TABLE aquariums(
        id TEXT PRIMARY KEY,
        current_biome INTEGER NOT NULL,
        ecosystem_health REAL NOT NULL DEFAULT 1.0,
        created_at INTEGER NOT NULL,
        last_active_at INTEGER NOT NULL,
        pearl_balance INTEGER NOT NULL DEFAULT 0,
        crystal_balance INTEGER NOT NULL DEFAULT 0,
        unlocked_biomes TEXT NOT NULL DEFAULT '0',
        total_creatures_discovered INTEGER NOT NULL DEFAULT 0,
        total_corals_grown INTEGER NOT NULL DEFAULT 0,
        total_focus_time INTEGER NOT NULL DEFAULT 0,
        current_streak INTEGER NOT NULL DEFAULT 0,
        longest_streak INTEGER NOT NULL DEFAULT 0,
        enable_sounds INTEGER NOT NULL DEFAULT 1,
        enable_animations INTEGER NOT NULL DEFAULT 1,
        enable_notifications INTEGER NOT NULL DEFAULT 1,
        water_clarity REAL NOT NULL DEFAULT 1.0
      )
    ''');

    // Creatures table
    await db.execute('''
      CREATE TABLE creatures(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        species TEXT NOT NULL,
        rarity INTEGER NOT NULL,
        type INTEGER NOT NULL,
        habitat INTEGER NOT NULL,
        animation_asset TEXT NOT NULL,
        pearl_value INTEGER NOT NULL,
        required_level INTEGER NOT NULL,
        is_discovered INTEGER NOT NULL DEFAULT 0,
        discovered_at INTEGER,
        description TEXT NOT NULL,
        coral_preferences TEXT,
        discovery_chance REAL NOT NULL
      )
    ''');

    // Corals table
    await db.execute('''
      CREATE TABLE corals(
        id TEXT PRIMARY KEY,
        type INTEGER NOT NULL,
        stage INTEGER NOT NULL,
        growth_progress REAL NOT NULL,
        planted_at INTEGER NOT NULL,
        last_growth_at INTEGER,
        is_healthy INTEGER NOT NULL DEFAULT 1,
        attracted_species TEXT,
        sessions_grown INTEGER NOT NULL DEFAULT 0,
        biome INTEGER NOT NULL,
        position_x REAL NOT NULL DEFAULT 0.5,
        position_y REAL NOT NULL DEFAULT 0.5
      )
    ''');

    // Ocean activities table
    await db.execute('''
      CREATE TABLE ocean_activities(
        id TEXT PRIMARY KEY,
        timestamp INTEGER NOT NULL,
        type INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        metadata TEXT,
        image_asset TEXT,
        priority INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Create indices for better performance
    await db.execute('CREATE INDEX idx_creatures_rarity ON creatures(rarity)');
    await db.execute('CREATE INDEX idx_creatures_habitat ON creatures(habitat)');
    await db.execute('CREATE INDEX idx_creatures_discovered ON creatures(is_discovered)');
    await db.execute('CREATE INDEX idx_corals_stage ON corals(stage)');
    await db.execute('CREATE INDEX idx_corals_biome ON corals(biome)');
    await db.execute('CREATE INDEX idx_activities_timestamp ON ocean_activities(timestamp DESC)');
    await db.execute('CREATE INDEX idx_activities_type ON ocean_activities(type)');
  }

  // Insert a new session
  static Future<int> insertSession(Session session) async {
    if (!_useSQLite) {
      await StorageService.saveSession(session);
      return 1; // Return dummy ID for web
    }
    
    final db = await database;
    return await db.insert(_tableName, session.toMap());
  }

  // Get all sessions
  static Future<List<Session>> getAllSessions() async {
    if (!_useSQLite) {
      return await StorageService.getAllSessions();
    }
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'start_time DESC',
    );
    return List.generate(maps.length, (i) => Session.fromMap(maps[i]));
  }

  // Get sessions for a specific date
  static Future<List<Session>> getSessionsForDate(DateTime date) async {
    if (!_useSQLite) {
      return await StorageService.getSessionsForDate(date);
    }
    
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'start_time >= ? AND start_time < ?',
      whereArgs: [
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
      ],
      orderBy: 'start_time DESC',
    );
    return List.generate(maps.length, (i) => Session.fromMap(maps[i]));
  }

  // Get sessions for the last N days
  static Future<List<Session>> getRecentSessions(int days) async {
    if (!_useSQLite) {
      return await StorageService.getRecentSessions(days);
    }
    
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'start_time >= ?',
      whereArgs: [cutoffDate.millisecondsSinceEpoch],
      orderBy: 'start_time DESC',
    );
    return List.generate(maps.length, (i) => Session.fromMap(maps[i]));
  }

  // Get sessions within a date range
  static Future<List<Session>> getSessionsByDateRange(DateTime startDate, DateTime endDate) async {
    if (!_useSQLite) {
      return await StorageService.getSessionsByDateRange(startDate, endDate);
    }
    
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'start_time >= ? AND start_time < ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'start_time ASC',
    );
    return List.generate(maps.length, (i) => Session.fromMap(maps[i]));
  }

  // Get total focus time for today
  static Future<int> getTodayFocusTime() async {
    if (!_useSQLite) {
      return await StorageService.getTodayFocusTime();
    }
    
    final today = DateTime.now();
    final sessions = await getSessionsForDate(today);
    return sessions
        .where((session) => session.type == SessionType.focus && session.completed)
        .fold<int>(0, (sum, session) => sum + session.duration);
  }

  // Get current streak (consecutive days with at least one completed focus session)
  static Future<int> getCurrentStreak() async {
    if (!_useSQLite) {
      return await StorageService.getCurrentStreak();
    }
    
    int streak = 0;
    DateTime checkDate = DateTime.now();
    
    while (true) {
      final sessions = await getSessionsForDate(checkDate);
      final hasCompletedFocus = sessions.any(
        (session) => session.type == SessionType.focus && session.completed,
      );
      
      if (hasCompletedFocus) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        // If today has no sessions yet, don't break the streak
        if (streak == 0 && checkDate.day == DateTime.now().day) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
      
      // Prevent infinite loop - max reasonable streak
      if (streak > 365) break;
    }
    
    return streak;
  }

  // Get session statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    if (!_useSQLite) {
      return await StorageService.getStatistics();
    }
    
    final sessions = await getRecentSessions(30); // Last 30 days
    
    final totalSessions = sessions.length;
    final completedSessions = sessions.where((s) => s.completed).length;
    final totalFocusTime = sessions
        .where((s) => s.type == SessionType.focus && s.completed)
        .fold<int>(0, (sum, session) => sum + session.duration);
    
    final todayFocusTime = await getTodayFocusTime();
    final currentStreak = await getCurrentStreak();
    
    return {
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'totalFocusTime': totalFocusTime,
      'todayFocusTime': todayFocusTime,
      'currentStreak': currentStreak,
      'completionRate': totalSessions > 0 ? (completedSessions / totalSessions) : 0.0,
    };
  }

  // Delete old sessions (keep only last 90 days)
  static Future<void> cleanupOldSessions() async {
    if (!_useSQLite) {
      // For SharedPreferences, we handle this in the storage service automatically
      return;
    }
    
    final db = await database;
    final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
    
    await db.delete(
      _tableName,
      where: 'start_time < ?',
      whereArgs: [cutoffDate.millisecondsSinceEpoch],
    );
  }

  // Update a session
  static Future<void> updateSession(Session session) async {
    if (!_useSQLite) {
      // For SharedPreferences, just save it (replaces existing)
      await StorageService.saveSession(session);
      return;
    }
    
    final db = await database;
    await db.update(
      _tableName,
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  // Delete a session
  static Future<void> deleteSession(int id) async {
    if (!_useSQLite) {
      // For SharedPreferences, this is more complex and not implemented
      // but since sessions are rarely deleted, this is acceptable
      return;
    }
    
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ OCEAN DATABASE METHODS ============

  // === AQUARIUM METHODS ===
  static Future<void> saveAquarium(Aquarium aquarium) async {
    if (!_useSQLite) return; // TODO: Implement SharedPreferences fallback
    
    final db = await database;
    await db.insert(
      'aquariums',
      aquarium.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Aquarium?> getAquarium(String id) async {
    if (!_useSQLite) return null; // TODO: Implement SharedPreferences fallback
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'aquariums',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Aquarium.fromMap(maps.first);
    }
    return null;
  }

  // === CREATURE METHODS ===
  static Future<void> saveCreature(Creature creature) async {
    if (!_useSQLite) return;
    
    final db = await database;
    await db.insert(
      'creatures',
      creature.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Creature>> getAllCreatures() async {
    if (!_useSQLite) return [];
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('creatures');
    return List.generate(maps.length, (i) => Creature.fromMap(maps[i]));
  }

  static Future<List<Creature>> getCreaturesByBiome(BiomeType biome) async {
    if (!_useSQLite) return [];
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'creatures',
      where: 'habitat = ?',
      whereArgs: [biome.index],
    );
    return List.generate(maps.length, (i) => Creature.fromMap(maps[i]));
  }

  static Future<List<Creature>> getDiscoveredCreatures() async {
    if (!_useSQLite) return [];
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'creatures',
      where: 'is_discovered = 1',
      orderBy: 'discovered_at DESC',
    );
    return List.generate(maps.length, (i) => Creature.fromMap(maps[i]));
  }

  static Future<void> discoverCreature(String creatureId) async {
    if (!_useSQLite) return;
    
    final db = await database;
    await db.update(
      'creatures',
      {
        'is_discovered': 1,
        'discovered_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [creatureId],
    );
  }

  // === CORAL METHODS ===
  static Future<void> saveCoral(Coral coral) async {
    if (!_useSQLite) return;
    
    final db = await database;
    await db.insert(
      'corals',
      coral.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Coral>> getAllCorals() async {
    if (!_useSQLite) return [];
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'corals',
      orderBy: 'planted_at DESC',
    );
    return List.generate(maps.length, (i) => Coral.fromMap(maps[i]));
  }

  static Future<List<Coral>> getCoralsByBiome(BiomeType biome) async {
    if (!_useSQLite) return [];
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'corals',
      where: 'biome = ?',
      whereArgs: [biome.index],
      orderBy: 'planted_at DESC',
    );
    return List.generate(maps.length, (i) => Coral.fromMap(maps[i]));
  }

  static Future<void> updateCoral(Coral coral) async {
    if (!_useSQLite) return;
    
    final db = await database;
    await db.update(
      'corals',
      coral.toMap(),
      where: 'id = ?',
      whereArgs: [coral.id],
    );
  }

  // === OCEAN ACTIVITY METHODS ===
  static Future<void> saveOceanActivity(OceanActivity activity) async {
    if (!_useSQLite) return;
    
    final db = await database;
    await db.insert(
      'ocean_activities',
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<OceanActivity>> getRecentOceanActivities({int limit = 50}) async {
    if (!_useSQLite) return [];
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ocean_activities',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => OceanActivity.fromMap(maps[i]));
  }

  static Future<List<OceanActivity>> getActivitiesByType(OceanActivityType type) async {
    if (!_useSQLite) return [];
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ocean_activities',
      where: 'type = ?',
      whereArgs: [type.index],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => OceanActivity.fromMap(maps[i]));
  }

  static Future<void> cleanupOldOceanActivities() async {
    if (!_useSQLite) return;
    
    final db = await database;
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    
    await db.delete(
      'ocean_activities',
      where: 'timestamp < ?',
      whereArgs: [cutoffDate.millisecondsSinceEpoch],
    );
  }

  // === OCEAN STATISTICS ===
  static Future<Map<String, dynamic>> getOceanStatistics() async {
    if (!_useSQLite) return {};
    
    final db = await database;
    
    // Get total creatures discovered
    final creaturesResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM creatures WHERE is_discovered = 1'
    );
    final totalCreatures = creaturesResult.first['total'] as int;
    
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
    
    return {
      'totalCreatures': totalCreatures,
      'totalCorals': totalCorals,
      'matureCorals': matureCorals,
      'rarityDistribution': rarityDistribution,
    };
  }
}