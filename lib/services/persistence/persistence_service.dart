import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'repositories/session_repository.dart';
import 'repositories/gamification_repository.dart';
import 'repositories/ocean_repository.dart';
import 'repositories/career_repository.dart';
import 'repositories/equipment_repository.dart';
import 'repositories/research_repository.dart';
import '../../data/comprehensive_species_database.dart';

/// Unified persistence service for Flow Pulse
/// Single source of truth for all data storage operations
class PersistenceService {
  static PersistenceService? _instance;
  static PersistenceService get instance {
    _instance ??= PersistenceService._();
    return _instance!;
  }

  PersistenceService._();

  Database? _database;
  static const String _databaseName = 'flowpulse.db';
  static const int _databaseVersion = 3;

  // Repository instances
  SessionRepository? _sessions;
  GamificationRepository? _gamification;
  OceanRepository? _ocean;
  CareerRepository? _career;
  EquipmentRepository? _equipment;
  ResearchRepository? _research;
  bool _repositoriesInitialized = false;

  // Repository getters with auto-initialization
  SessionRepository get sessions {
    _ensureRepositoriesInitialized();
    return _sessions!;
  }

  GamificationRepository get gamification {
    _ensureRepositoriesInitialized();
    return _gamification!;
  }

  OceanRepository get ocean {
    _ensureRepositoriesInitialized();
    return _ocean!;
  }

  CareerRepository get career {
    _ensureRepositoriesInitialized();
    return _career!;
  }

  EquipmentRepository get equipment {
    _ensureRepositoriesInitialized();
    return _equipment!;
  }

  ResearchRepository get research {
    _ensureRepositoriesInitialized();
    return _research!;
  }

  // Initialize the service
  Future<void> initialize() async {
    await _initDatabase();
    _initRepositories();
    
    // Initialize default equipment if needed
    try {
      await equipment.initializeDefaultEquipment();
    } catch (e) {
      debugPrint('Warning: Could not initialize default equipment: $e');
    }
  }

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Ensure repositories are initialized
  void _ensureRepositoriesInitialized() {
    if (!_repositoriesInitialized) {
      _initRepositories();
    }
  }

  // Initialize repositories
  void _initRepositories() {
    _sessions = SessionRepository(this);
    _gamification = GamificationRepository(this);
    _ocean = OceanRepository(this);
    _career = CareerRepository(this);
    _equipment = EquipmentRepository(this);
    _research = ResearchRepository(this);
    _repositoriesInitialized = true;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    try {
      // On web, initialize the database factory and use in-memory database
      if (kIsWeb) {
        if (kDebugMode) {
          print('Initializing database factory for web platform');
        }
        
        // Initialize the web-specific ffi database factory
        databaseFactory = databaseFactoryFfiWeb;
        
        if (kDebugMode) {
          print('Using in-memory database for web platform');
        }
        
        return await databaseFactory.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(
            version: _databaseVersion,
            onCreate: _onCreate,
            onUpgrade: _onUpgrade,
            onOpen: _onOpen,
          ),
        );
      }

      // Native platforms (iOS/Android)
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, _databaseName);

      // Check if database exists for migration purposes
      final exists = await databaseExists(path);
      
      if (kDebugMode) {
        print('Initializing database at: $path');
        print('Database exists: $exists');
      }

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: _onOpen,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Database initialization error: $e');
      }
      rethrow;
    }
  }

  // Create database schema
  Future<void> _onCreate(Database db, int version) async {
    if (kDebugMode) {
      print('Creating database schema version $version');
    }

    // Create all tables
    await _createSessionTables(db);
    await _createOceanTables(db);
    await _createGamificationTables(db);
    await _createCareerTables(db);
    await _createEquipmentTables(db);
    await _createResearchTables(db);
    await _createPreferencesTables(db);
    
    // Create indexes for performance
    await _createIndexes(db);
  }

  // Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (kDebugMode) {
      print('Upgrading database from version $oldVersion to $newVersion');
    }

    // Handle migrations based on version
    if (oldVersion < 2) {
      await _migrateToV2(db);
    }
    if (oldVersion < 3) {
      await _migrateToV3(db);
    }
  }

  // Database opened callback
  Future<void> _onOpen(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
    
    // Populate initial creatures if empty
    await _populateInitialCreatures(db);
    
    if (kDebugMode) {
      print('Database opened successfully');
    }
  }

  // Create session tables
  Future<void> _createSessionTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        type INTEGER NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        depth REAL DEFAULT 0,
        creatures_discovered TEXT,
        pearls_earned INTEGER DEFAULT 0,
        xp_earned INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  // Create ocean-related tables
  Future<void> _createOceanTables(Database db) async {
    // Aquarium table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS aquariums(
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
      CREATE TABLE IF NOT EXISTS creatures(
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
        discovery_chance REAL NOT NULL,
        discovery_count INTEGER DEFAULT 0
      )
    ''');

    // Corals table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS corals(
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
      CREATE TABLE IF NOT EXISTS ocean_activities(
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
  }

  // Create gamification tables
  Future<void> _createGamificationTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS gamification_state(
        id INTEGER PRIMARY KEY DEFAULT 1,
        total_xp INTEGER NOT NULL DEFAULT 0,
        current_level INTEGER NOT NULL DEFAULT 1,
        current_streak INTEGER NOT NULL DEFAULT 0,
        longest_streak INTEGER NOT NULL DEFAULT 0,
        last_session_date INTEGER,
        unlocked_themes TEXT,
        unlocked_achievements TEXT,
        total_sessions INTEGER NOT NULL DEFAULT 0,
        total_focus_time INTEGER NOT NULL DEFAULT 0,
        daily_goals TEXT,
        weekly_goals TEXT,
        monthly_goals TEXT,
        last_updated INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS achievements(
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        icon TEXT,
        unlocked INTEGER NOT NULL DEFAULT 0,
        unlocked_date INTEGER,
        progress REAL DEFAULT 0.0,
        target_value INTEGER,
        current_value INTEGER,
        xp_reward INTEGER DEFAULT 0,
        rarity TEXT
      )
    ''');
  }

  // Create marine biology career tables
  Future<void> _createCareerTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS marine_career(
        id INTEGER PRIMARY KEY DEFAULT 1,
        career_xp INTEGER NOT NULL DEFAULT 0,
        career_level INTEGER NOT NULL DEFAULT 1,
        career_title TEXT DEFAULT 'Marine Biology Intern',
        specialization TEXT,
        total_discoveries INTEGER NOT NULL DEFAULT 0,
        research_points INTEGER NOT NULL DEFAULT 0,
        papers_published INTEGER NOT NULL DEFAULT 0,
        certifications_earned TEXT,
        discovery_history TEXT,
        last_updated INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS research_milestones(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        achieved INTEGER NOT NULL DEFAULT 0,
        achieved_date INTEGER,
        category TEXT,
        reward_xp INTEGER DEFAULT 0,
        reward_items TEXT
      )
    ''');
  }

  // Create equipment tables
  Future<void> _createEquipmentTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS equipment(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        icon TEXT,
        is_unlocked INTEGER NOT NULL DEFAULT 0,
        is_equipped INTEGER NOT NULL DEFAULT 0,
        unlock_level INTEGER NOT NULL,
        unlock_date INTEGER,
        discovery_bonus REAL DEFAULT 0,
        session_bonus REAL DEFAULT 0,
        special_effects TEXT,
        rarity TEXT,
        metadata TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS equipment_sets(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        items TEXT NOT NULL,
        bonus_description TEXT,
        is_complete INTEGER NOT NULL DEFAULT 0,
        completed_date INTEGER
      )
    ''');
  }

  // Create research tables
  Future<void> _createResearchTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS research_papers(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        published INTEGER NOT NULL DEFAULT 0,
        published_date INTEGER,
        citations INTEGER DEFAULT 0,
        xp_reward INTEGER DEFAULT 0,
        required_discoveries TEXT,
        required_level INTEGER DEFAULT 1,
        biome TEXT,
        metadata TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS research_certifications(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        earned INTEGER NOT NULL DEFAULT 0,
        earned_date INTEGER,
        requirements TEXT,
        badge_icon TEXT
      )
    ''');
  }

  // Create user preferences table
  Future<void> _createPreferencesTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_preferences(
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  // Create indexes for better performance
  Future<void> _createIndexes(Database db) async {
    // Session indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_sessions_date ON sessions(start_time DESC)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_sessions_type ON sessions(type)');
    
    // Creature indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_creatures_rarity ON creatures(rarity)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_creatures_habitat ON creatures(habitat)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_creatures_discovered ON creatures(is_discovered)');
    
    // Coral indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_corals_stage ON corals(stage)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_corals_biome ON corals(biome)');
    
    // Activity indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_timestamp ON ocean_activities(timestamp DESC)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_type ON ocean_activities(type)');
    
    // Achievement indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_achievements_unlocked ON achievements(unlocked)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_achievements_category ON achievements(category)');
    
    // Equipment indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_equipment_unlocked ON equipment(is_unlocked)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_equipment_equipped ON equipment(is_equipped)');
  }

  // Migrate to version 2
  Future<void> _migrateToV2(Database db) async {
    // Add ocean tables if they don't exist
    await _createOceanTables(db);
  }

  // Migrate to version 3
  Future<void> _migrateToV3(Database db) async {
    // Add new gamification and career tables
    await _createGamificationTables(db);
    await _createCareerTables(db);
    await _createEquipmentTables(db);
    await _createResearchTables(db);
    await _createPreferencesTables(db);
    await _createIndexes(db);
    
    // Migrate existing data if needed
    await _migrateExistingData(db);
  }

  // Migrate existing data from old schema
  Future<void> _migrateExistingData(Database db) async {
    // This would contain logic to migrate data from old tables/structure
    // For now, we'll just ensure default entries exist
    
    // Ensure default gamification state exists
    final gamificationCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM gamification_state')
    ) ?? 0;
    
    if (gamificationCount == 0) {
      await db.insert('gamification_state', {
        'id': 1,
        'total_xp': 0,
        'current_level': 1,
        'current_streak': 0,
        'longest_streak': 0,
        'total_sessions': 0,
        'total_focus_time': 0,
        'last_updated': DateTime.now().millisecondsSinceEpoch,
      });
    }
    
    // Ensure default marine career exists
    final careerCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM marine_career')
    ) ?? 0;
    
    if (careerCount == 0) {
      await db.insert('marine_career', {
        'id': 1,
        'career_xp': 0,
        'career_level': 1,
        'career_title': 'Marine Biology Intern',
        'total_discoveries': 0,
        'research_points': 0,
        'papers_published': 0,
        'last_updated': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  // Populate initial creatures from ComprehensiveSpeciesDatabase
  Future<void> _populateInitialCreatures(Database db) async {
    // Check if creatures table is empty
    final creatureCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM creatures')
    ) ?? 0;
    
    if (creatureCount == 0) {
      if (kDebugMode) {
        print('Populating initial creatures from ComprehensiveSpeciesDatabase...');
      }
      
      // Import the species database
      final allSpecies = ComprehensiveSpeciesDatabase.allSpecies;
      
      // Batch insert all creatures
      final batch = db.batch();
      for (final creature in allSpecies) {
        batch.insert(
          'creatures',
          creature.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      
      await batch.commit(noResult: true);
      
      if (kDebugMode) {
        print('Successfully populated ${allSpecies.length} creatures');
      }
    }
  }

  // Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    final db = await database;
    
    // Get all table names
    final tables = [
      'sessions', 'aquariums', 'creatures', 'corals', 'ocean_activities',
      'gamification_state', 'achievements', 'marine_career', 'research_milestones',
      'equipment', 'equipment_sets', 'research_papers', 'research_certifications',
      'user_preferences'
    ];
    
    // Delete all data from tables
    for (final table in tables) {
      await db.delete(table);
    }
    
    // Re-initialize default data
    await _migrateExistingData(db);
  }

  // Close database connection
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  // Backup database
  Future<void> backupDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final sourcePath = join(databasesPath, _databaseName);
      final backupPath = join(databasesPath, '$_databaseName.backup');
      
      final sourceFile = File(sourcePath);
      if (await sourceFile.exists()) {
        await sourceFile.copy(backupPath);
        if (kDebugMode) {
          print('Database backed up to: $backupPath');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Backup failed: $e');
      }
    }
  }

  // Restore database from backup
  Future<void> restoreDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final sourcePath = join(databasesPath, _databaseName);
      final backupPath = join(databasesPath, '$_databaseName.backup');
      
      final backupFile = File(backupPath);
      if (await backupFile.exists()) {
        // Close current connection
        await close();
        
        // Copy backup over current
        await backupFile.copy(sourcePath);
        
        // Reinitialize
        await initialize();
        
        if (kDebugMode) {
          print('Database restored from backup');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Restore failed: $e');
      }
    }
  }
}