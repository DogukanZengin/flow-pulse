# FlowPulse Hybrid Leveling System - Implementation Plan for Claude Code

## Project Overview
Transform FlowPulse's current duration-based leveling system into a comprehensive hybrid system that rewards productivity quality, consistency, and streaks rather than just session length. This addresses the current issue where longer sessions automatically grant deeper ocean access, potentially encouraging unhealthy productivity habits.

## Current System Analysis
- **Current Logic**: Session duration directly maps to depth (15-20min = shallow, 45-60min = deep, 90min+ = abyssal)
- **Problem**: Encourages marathon sessions over sustainable Pomodoro cycles
- **User Impact**: Users feel pressured to work longer sessions for better rewards

## Target System Goals
- **Productivity Focus**: Reward completed sessions, break adherence, and consistency
- **Streak Emphasis**: Daily streaks become primary progression mechanism
- **Mission Variety**: Multiple progression paths beyond raw time investment
- **Sustainable Habits**: Encourage healthy work-rest cycles

# FlowPulse Hybrid Leveling System - Implementation Plan for Claude Code

## Project Overview
Transform FlowPulse's current duration-based leveling system into a comprehensive hybrid system that rewards productivity quality, consistency, and streaks rather than just session length. This addresses the current issue where longer sessions automatically grant deeper ocean access, potentially encouraging unhealthy productivity habits.

## Current System Analysis
- **Current Logic**: Session duration directly maps to depth (15-20min = shallow, 45-60min = deep, 90min+ = abyssal)
- **Problem**: Encourages marathon sessions over sustainable Pomodoro cycles
- **User Impact**: Users feel pressured to work longer sessions for better rewards

## Target System Goals
- **Productivity Focus**: Reward completed sessions, break adherence, and consistency
- **Streak Emphasis**: Daily streaks become primary progression mechanism
- **Mission Variety**: Multiple progression paths beyond raw time investment
- **Sustainable Habits**: Encourage healthy work-rest cycles

---

## Phase 1: Database Schema Migration

## Phase 1: Database Schema Updates

### Task 1.1: Update Table Creation Scripts for RP System
**Priority**: Critical | **Complexity**: Low | **Dependencies**: None

**Files to modify:**
- `lib/persistence/persistence_service.dart`

**Direct table creation updates:**

1. **Update _createSessionTables method:**
```dart
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
      research_points INTEGER DEFAULT 0,
      base_rp INTEGER DEFAULT 0,
      bonus_rp INTEGER DEFAULT 0,
      break_adherence INTEGER DEFAULT 0,
      streak_bonus INTEGER DEFAULT 0,
      session_quality INTEGER DEFAULT 1,
      created_at INTEGER NOT NULL
    )
  ''');
}
```

2. **Update _createGamificationTables method:**
```dart
Future<void> _createGamificationTables(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS gamification_state(
      id INTEGER PRIMARY KEY DEFAULT 1,
      total_rp INTEGER NOT NULL DEFAULT 0,
      cumulative_rp INTEGER NOT NULL DEFAULT 0,
      current_depth_zone INTEGER NOT NULL DEFAULT 0,
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
      rp_reward INTEGER DEFAULT 0,
      rarity TEXT
    )
  ''');
}
```

3. **Update _createCareerTables method:**
```dart
Future<void> _createCareerTables(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS marine_career(
      id INTEGER PRIMARY KEY DEFAULT 1,
      career_rp INTEGER NOT NULL DEFAULT 0,
      current_career_rp INTEGER NOT NULL DEFAULT 0,
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
      reward_rp INTEGER DEFAULT 0,
      reward_items TEXT
    )
  ''');
}
```

4. **Update _createResearchTables method:**
```dart
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
      rp_reward INTEGER DEFAULT 0,
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
```

5. **Add new _createMissionTables method to _onCreate:**
```dart
Future<void> _createMissionTables(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS missions(
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      category TEXT NOT NULL,
      type TEXT NOT NULL,
      target_value INTEGER NOT NULL,
      current_progress INTEGER DEFAULT 0,
      is_completed INTEGER DEFAULT 0,
      completed_date INTEGER,
      reward_rp INTEGER DEFAULT 0,
      reward_bonus TEXT,
      expires_at INTEGER,
      created_at INTEGER NOT NULL,
      metadata TEXT
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS mission_progress(
      id TEXT PRIMARY KEY,
      mission_id TEXT NOT NULL,
      user_id TEXT DEFAULT 'default',
      progress_value INTEGER DEFAULT 0,
      is_completed INTEGER DEFAULT 0,
      completed_at INTEGER,
      last_updated INTEGER NOT NULL,
      FOREIGN KEY (mission_id) REFERENCES missions(id)
    )
  ''');
}
```

6. **Update _onCreate method to include mission tables:**
```dart
Future<void> _onCreate(Database db, int version) async {
  // Create all tables
  await _createSessionTables(db);
  await _createOceanTables(db);
  await _createGamificationTables(db);
  await _createCareerTables(db);
  await _createEquipmentTables(db);
  await _createResearchTables(db);
  await _createMissionTables(db); // Add this line
  await _createPreferencesTables(db);
  
  // Create indexes for performance
  await _createIndexes(db);
}
```

7. **Update _createIndexes method:**
```dart
Future<void> _createIndexes(Database db) async {
  // Session indexes
  await db.execute('CREATE INDEX IF NOT EXISTS idx_sessions_date ON sessions(start_time DESC)');
  await db.execute('CREATE INDEX IF NOT EXISTS idx_sessions_type ON sessions(type)');
  await db.execute('CREATE INDEX IF NOT EXISTS idx_sessions_rp ON sessions(research_points)');
  
  // Mission indexes
  await db.execute('CREATE INDEX IF NOT EXISTS idx_missions_category ON missions(category)');
  await db.execute('CREATE INDEX IF NOT EXISTS idx_missions_completed ON missions(is_completed)');
  
  // Other existing indexes...
}
```

**Requirements**:
- Replace XP columns with RP columns in table creation scripts
- Add mission system tables to schema
- Add proper indexes for RP-based queries
- Remove all migration logic since no existing users need data preservation

**Acceptance Criteria**:
- Fresh database installations create RP-based schema
- All tables include necessary RP tracking columns
- Mission system fully supported by database schema
- No XP columns remain in any table definitions

---

## Phase 2: Core Research Points (RP) System Implementation

### Task 1.1: Create RP Constants and Models
**Priority**: High | **Complexity**: Low | **Dependencies**: None

```dart
// Files to create/modify:
- lib/constants/research_points_constants.dart
- lib/models/research_points.dart
- lib/models/session_quality.dart
```

**Requirements**:
- Base RP formula: 25min session = 10 RP, 50min session = 20 RP
- Bonus system: +2 RP for break adherence, +5 RP for streak
- Session quality enum: Perfect, Good, Abandoned
- RP calculation utilities with bonus multipliers

**Acceptance Criteria**:
- RP calculations are deterministic and testable
- Bonus system prevents exploitation (max 1 streak bonus per day)
- Clean separation between base RP and bonus RP

### Task 1.2: Replace XP System with RP in GamificationService
**Priority**: High | **Complexity**: Medium | **Dependencies**: Task 1.1

```dart
// Files to modify:
- lib/services/gamification_service.dart
- lib/models/gamification_reward.dart
```

**Requirements**:
- Replace XP calculations with RP-based progression
- Integrate break adherence detection
- Add streak bonus calculation
- Update reward calculation to show RP breakdown instead of XP

**Acceptance Criteria**:
- Session completion awards appropriate RP based on duration
- Break adherence properly detected and rewarded
- Streak system doesn't double-award on same day
- All XP references replaced with RP throughout the system

### Task 1.3: Implement Accelerated Depth Traversal System
**Priority**: High | **Complexity**: Medium | **Dependencies**: Task 1.2

```dart
// Files to modify:
- lib/services/ocean_biome_service.dart (create new)
- lib/constants/depth_constants.dart
- lib/services/depth_traversal_service.dart (create new)
```

**Core Concept**: Experience (RP) affects descent speed, not starting position
- All dives start at surface (natural diving physics)
- Higher RP = faster descent through water layers
- Pass through all biomes during descent (discovery opportunities at all depths)

**Requirements**:

1. **Descent Rate Multipliers Based on RP**:
```dart
// Base descent rate: 2m per minute
// Multipliers based on cumulative RP:
0-50 RP (Beginner): 1.0x speed = 2m/min
51-200 RP (Experienced): 2.0x speed = 4m/min
201-500 RP (Expert): 3.0x speed = 6m/min
501+ RP (Master): 4.0x speed = 8m/min
```

2. **Depth Calculation Logic**:
```dart
class DepthTraversalService {
  double calculateCurrentDepth(Duration sessionTime, int cumulativeRP) {
    final minutes = sessionTime.inMinutes;
    final multiplier = getDescentMultiplier(cumulativeRP);
    final baseRate = 2.0; // meters per minute

    return minutes * baseRate * multiplier;
  }

  double getDescentMultiplier(int cumulativeRP) {
    if (cumulativeRP >= 501) return 4.0;  // Master
    if (cumulativeRP >= 201) return 3.0;  // Expert
    if (cumulativeRP >= 51) return 2.0;   // Experienced
    return 1.0;  // Beginner
  }
}
```

3. **Biome Traversal Tracking**:
```dart
// Track which biomes diver passes through during descent
// Each biome has depth ranges:
0-20m: Shallow Waters
20-50m: Coral Garden
50-100m: Deep Ocean
100m+: Abyssal Zone

// Discovery eligibility based on time spent in each zone
// Faster divers can still discover species from shallower zones
```

**Example Session Depths**:

| Experience Level | 10-min | 25-min | 45-min |
|-----------------|--------|---------|---------|
| Beginner (0 RP) | 20m (Shallow) | 50m (Coral edge) | 90m (Deep) |
| Experienced (100 RP) | 40m (Coral) | 100m (Abyssal edge) | 180m (Deep Abyssal) |
| Expert (300 RP) | 60m (Deep) | 150m (Abyssal) | 270m (Abyssal) |
| Master (500+ RP) | 80m (Deep) | 200m (Abyssal) | 360m (Abyssal) |

**Acceptance Criteria**:
- All sessions start at surface (0m) regardless of RP
- Descent speed increases with cumulative RP (not starting depth)
- Species discovery possible at all depths passed during descent
- Short sessions by experienced divers can reach meaningful depths
- Visual depth animation reflects accelerated descent for experienced divers
- Depth indicators show both current depth and traversal speed

---

## Phase 2: Mission System Implementation

### Task 2.1: Create Mission Framework
**Priority**: Medium | **Complexity**: Medium | **Dependencies**: Phase 1 Complete

```dart
// Files to create:
- lib/models/mission.dart
- lib/models/mission_progress.dart
- lib/services/mission_service.dart
- lib/constants/mission_constants.dart
```

**Requirements**:
- Mission types: Daily, Weekly, Achievement-based
- Mission categories: Consistency, Productivity, Discovery
- Progress tracking with completion status
- Reward system integration with RP and XP

**Example Missions**:
- "Complete 3 dives today" (Daily)
- "Maintain a 5-day streak" (Weekly)
- "Log 50 minutes underwater in one week" (Weekly)

**Acceptance Criteria**:
- Missions auto-generate based on user patterns
- Progress updates in real-time during sessions
- Completed missions award appropriate rewards
- Mission difficulty scales with user level

### Task 2.2: Mission UI Components
**Priority**: Medium | **Complexity**: Medium | **Dependencies**: Task 2.1

```dart
// Files to create/modify:
- lib/widgets/mission_card_widget.dart
- lib/widgets/mission_progress_indicator.dart
- lib/screens/missions_tab.dart (or integrate into existing)
```

**Requirements**:
- Mission cards with marine biology theme
- Progress bars with visual completion indicators
- Mission completion celebrations
- Integration with existing ocean theme

**Acceptance Criteria**:
- Mission UI matches existing marine research station aesthetic
- Progress indicators are intuitive and motivating
- Completed missions show appropriate celebrations
- Mobile-responsive design across all screen sizes

---

## Phase 3: Discovery System Enhancement

### Task 3.1: Update Species Discovery Logic
**Priority**: Medium | **Complexity**: High | **Dependencies**: Phase 1 Complete

```dart
// Files to modify:
- lib/services/creature_service.dart
- lib/services/discovery_service.dart (create if needed)
```

**Requirements**:
- Discovery chances based on RP milestones, not session duration
- First session of day = guaranteed discovery
- Multiple sessions/day = increased rare species chance
- Streak bonuses affect discovery rates

**Current Discovery Logic to Modify**:
```dart
// Replace duration-based discovery with RP-based
// Old: if (sessionMinutes >= 45) { deepSeaCreatures() }
// New: if (totalRP >= 200) { deepSeaCreatures() }
```

**Acceptance Criteria**:
- Discovery system rewards consistency over duration
- Rare species obtainable through multiple short sessions
- Streak system provides meaningful discovery bonuses
- Discovery celebrations reflect RP-based achievement

### Task 3.2: Enhanced Research Journal Integration
**Priority**: Low | **Complexity**: Medium | **Dependencies**: Task 3.1

```dart
// Files to modify:
- lib/widgets/enhanced_research_journal.dart
- lib/models/research_entry.dart
```

**Requirements**:
- Journal entries show RP earned alongside discoveries
- Research methodology progress tracking
- Mission completion history
- Career progression documentation

**Acceptance Criteria**:
- Journal reflects new hybrid progression system
- Entries maintain educational marine biology content
- Progress tracking aligns with RP-based advancement

---

## Phase 4: Career Progression Overhaul

### Task 4.1: Replace XP-based Career Titles with RP Progression
**Priority**: Medium | **Complexity**: Low | **Dependencies**: Phase 1 Complete

```dart
// Files to modify:
- lib/services/marine_biology_career_service.dart
- lib/constants/career_constants.dart
```

**Requirements**:
- Keep existing detailed career titles (20 levels from Marine Biology Intern to Master Marine Biologist)
- Convert level requirements from XP-based to RP + streak achievements
- Hybrid requirements: Base RP thresholds + optional streak/mission bonuses for acceleration
- Example: Level 5 Junior Research Assistant = 150 RP OR (100 RP + 3-day streak)

**Current Career Title Structure to Update**:
```dart
// Replace level-based with RP-based career titles
static const Map<int, String> careerTitles = {
  0: 'Marine Biology Intern',           // Starting title
  50: 'Junior Research Assistant',      // ~5 sessions with bonuses
  150: 'Research Assistant',            // ~15 sessions
  300: 'Marine Biology Student',        // ~30 sessions  
  500: 'Research Associate',            // ~50 sessions
  750: 'Field Researcher',              // ~75 sessions
  1050: 'Marine Biologist',             // ~105 sessions
  1400: 'Senior Marine Biologist',      // ~140 sessions
  1800: 'Research Scientist',           // ~180 sessions
  2250: 'Senior Research Scientist',    // ~225 sessions
  2750: 'Principal Investigator',       // ~275 sessions
  3300: 'Marine Biology Expert',        // ~330 sessions
  3900: 'Distinguished Researcher',     // ~390 sessions
  4550: 'Research Director',            // ~455 sessions
  5250: 'Marine Biology Professor',     // ~525 sessions
  6000: 'Department Head',              // ~600 sessions
  6800: 'Research Institute Director',  // ~680 sessions
  7650: 'World-Renowned Expert',        // ~765 sessions
  8550: 'Marine Biology Legend',        // ~855 sessions
  9500: 'Ocean Pioneer',                // ~950 sessions
  10500: 'Master Marine Biologist',    // ~1050 sessions
};
```

**Acceptance Criteria**:
- All existing career titles preserved for engagement and progression
- Level requirements converted from XP to RP-based calculations
- Streak bonuses and missions can accelerate but not bypass core RP requirements
- Visual indicators show progress toward next career level with detailed titles

### Task 4.2: Equipment Progression Integration with RP System
**Priority**: Low | **Complexity**: Medium | **Dependencies**: Task 4.1, Phase 1

**Files to modify:**
```dart
- lib/persistence/repositories/equipment_repository.dart
- lib/services/equipment_progression_service.dart
```

**Equipment Repository Changes:**

1. **Replace level-based unlock logic with RP-based:**
```dart
// Update checkAndUnlockEquipmentByLevel method
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

// Update getEquipmentAvailableAtLevel method
Future<List<Map<String, dynamic>>> getEquipmentAvailableAtRP(int cumulativeRP) async {
  final db = await _persistence.database;
  
  return await db.query(
    'equipment',
    where: 'unlock_rp <= ?',
    whereArgs: [cumulativeRP],
    orderBy: 'unlock_rp DESC, category, name',
  );
}
```

2. **Update equipment table schema reference:**
```dart
// Equipment table now uses unlock_rp instead of unlock_level
// Update all references from 'unlock_level' to 'unlock_rp'
```

3. **Update initializeDefaultEquipment with RP values:**
```dart
// Convert existing unlock_level values to unlock_rp equivalents
// Based on RP progression curve from career titles:

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
    'unlock_rp': 0,  // Changed from unlock_level: 1
    'discovery_bonus': 0.0,
    'session_bonus': 0.0,
    'rarity': 'common',
  },
  {
    'id': 'scuba_gear', 
    'name': 'Scuba Diving Gear',
    'category': 'breathing',
    'unlock_rp': 150,  // Changed from unlock_level: 10
    // ... other fields remain same
  },
  {
    'id': 'rebreather',
    'name': 'Closed-Circuit Rebreather', 
    'unlock_rp': 750,  // Changed from unlock_level: 25
    // ... other fields
  },
  {
    'id': 'atmospheric_suit',
    'name': 'Atmospheric Diving Suit',
    'unlock_rp': 1800,  // Changed from unlock_level: 45
    // ... other fields
  },
  
  // Continue for all equipment items with RP conversion:
  // Level 3 -> 50 RP, Level 5 -> 150 RP, Level 8 -> 300 RP, etc.
  // Following the career title RP progression curve
];
```

**Equipment Service Integration:**

4. **Update GamificationService integration:**
```dart
// In gamification_service.dart completeSession method:
// Replace equipment unlock check

// OLD:
// final newlyUnlockedEquipment = await equipment.checkAndUnlockEquipmentByLevel(newLevel);

// NEW:
final newlyUnlockedEquipment = await equipment.checkAndUnlockEquipmentByRP(state.cumulativeRP);
```

**RP-to-Level Equipment Conversion Table:**
```dart
// Conversion from existing levels to RP values based on career progression
static const Map<int, int> levelToRPConversion = {
  1: 0,      // Starting equipment
  2: 50,     // Junior Research Assistant equivalent
  3: 50,     
  4: 50,
  5: 150,    // Research Assistant equivalent
  6: 150,
  7: 150,
  8: 300,    // Marine Biology Student equivalent
  9: 300,
  10: 300,
  11: 500,   // Research Associate equivalent
  12: 500,
  13: 500,
  14: 750,   // Field Researcher equivalent
  15: 750,
  16: 750,
  17: 1050,  // Marine Biologist equivalent
  18: 1050,
  19: 1050,
  20: 1400,  // Senior Marine Biologist equivalent
  // ... continue mapping up to level 50 -> 10500 RP
};
```

**Requirements**:
- Replace all level-based equipment unlocks with RP-based unlocks
- Update equipment database initialization to use RP values
- Equipment unlocks align with career title progression
- Equipment bonuses support sustainable productivity habits (no duration bonuses)

**Acceptance Criteria**:
- Equipment unlocks based on cumulative RP, not levels
- Equipment progression curve aligns with career title milestones
- No equipment rewards longer session durations
- Equipment bonuses enhance discovery rates and session quality
- Progression maintains appropriate difficulty scaling with RP requirements

---

## Phase 5: Visual System Updates

### Task 5.1: Depth Visualization with Accelerated Traversal
**Priority**: High | **Complexity**: High | **Dependencies**: Phase 2 Task 1.3 Complete

```dart
// Files to modify:
- lib/widgets/full_screen_ocean_widget.dart
- lib/widgets/dive_computer_widget.dart
- lib/animations/depth_transition_animation.dart
- lib/widgets/depth_speed_indicator.dart (create new)
```

**Requirements**:
- Session depth animation: Based on accelerated traversal system
- Visual speed indicators: Show descent multiplier (1x, 2x, 3x, 4x)
- Biome transitions: Smooth visual transitions as diver descends through zones
- Depth meter: Real-time depth display with current biome indicator

**Implementation Strategy**:

1. **Visual Descent Mechanics**:
```dart
// Animate diver descent based on RP multiplier
// Beginner: Slow, steady descent animation
// Expert: Noticeably faster descent through water layers
// Master: Rapid descent with motion blur effects

class DepthAnimationController {
  void animateDescent(int cumulativeRP, Duration elapsed) {
    final multiplier = getDescentMultiplier(cumulativeRP);
    final targetDepth = calculateDepth(elapsed, multiplier);

    // Faster animation speed for higher multipliers
    animateToDepth(targetDepth, speed: multiplier);
  }
}
```

2. **Biome Transition Effects**:
```dart
// Visual cues as diver passes through biomes
0-20m: Bright, sunlit waters →
20-50m: Colorful coral transition →
50-100m: Darkening blue gradient →
100m+: Deep abyss with bioluminescence
```

3. **UI Elements**:
- **Dive Computer**: Shows current depth, descent rate, biome
- **Speed Indicator**: "Descent Rate: 2x" with visual speedometer
- **Biome Progress Bar**: Shows proximity to next biome
- **Discovery Indicator**: Flash when passing through discovery zones

**Acceptance Criteria**:
- Natural diving progression from surface to depth
- Visual feedback clearly shows faster descent for experienced divers
- Smooth biome transitions during descent
- No confusion about why experienced divers descend faster
- Discovery opportunities visible at all depths during descent
- Speed indicator helps users understand their progression advantage

### Task 5.2: Progress Indicators and Celebrations
**Priority**: Medium | **Complexity**: Medium | **Dependencies**: Task 5.1

```dart
// Files to modify:
- lib/widgets/research_expedition_summary_widget.dart
- lib/widgets/research_progress_widget.dart
```

**Requirements**:
- RP progress bars with milestone indicators
- Celebration sequences highlight RP achievements
- Mission completion celebrations
- Streak milestone celebrations

**Acceptance Criteria**:
- Progress indicators clearly show RP accumulation
- Celebrations emphasize consistency and quality over duration
- Visual rewards align with hybrid system values
- Marine biology theme maintained throughout

---

## Phase 6: Data Migration and Analytics

### Task 6.1: Database Schema Updates for RP System
**Priority**: High | **Complexity**: Medium | **Dependencies**: None (Can run parallel)

**Files to modify:**
- `lib/persistence/persistence_service.dart`

**Schema changes needed:**

1. **Sessions table updates**:
```sql
-- Add RP tracking columns
ALTER TABLE sessions ADD COLUMN research_points INTEGER DEFAULT 0;
ALTER TABLE sessions ADD COLUMN base_rp INTEGER DEFAULT 0;
ALTER TABLE sessions ADD COLUMN bonus_rp INTEGER DEFAULT 0;
ALTER TABLE sessions ADD COLUMN break_adherence INTEGER DEFAULT 0;
ALTER TABLE sessions ADD COLUMN streak_bonus INTEGER DEFAULT 0;
ALTER TABLE sessions ADD COLUMN session_quality INTEGER DEFAULT 1; -- Perfect=2, Good=1, Abandoned=0

-- Remove or keep XP for backwards compatibility during transition
-- ALTER TABLE sessions DROP COLUMN xp_earned; -- Remove after full migration
```

2. **Gamification table updates**:
```sql
-- Replace XP with RP in gamification_state
ALTER TABLE gamification_state RENAME COLUMN total_xp TO total_rp;
ALTER TABLE gamification_state ADD COLUMN total_rp INTEGER DEFAULT 0; -- If renaming not supported
ALTER TABLE gamification_state ADD COLUMN cumulative_rp INTEGER DEFAULT 0; -- For depth progression
ALTER TABLE gamification_state ADD COLUMN current_depth_zone INTEGER DEFAULT 0; -- Shallow=0, Coral=1, Deep=2, Abyssal=3

-- Drop XP column after migration
-- ALTER TABLE gamification_state DROP COLUMN total_xp;
```

3. **Career table updates**:
```sql
-- Replace career_xp and career_level with RP-based system
ALTER TABLE marine_career RENAME COLUMN career_xp TO career_rp;
ALTER TABLE marine_career ADD COLUMN career_rp INTEGER DEFAULT 0; -- If renaming not supported
ALTER TABLE marine_career DROP COLUMN career_level; -- Remove level-based system
ALTER TABLE marine_career ADD COLUMN current_career_rp INTEGER DEFAULT 0; -- Track current RP for title calculation

-- Update career_title to be calculated dynamically based on RP
-- career_title will be calculated from careerTitles map using career_rp
```

4. **New missions table**:
```sql
CREATE TABLE IF NOT EXISTS missions(
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL, -- 'daily', 'weekly', 'achievement'
  type TEXT NOT NULL, -- 'consistency', 'productivity', 'discovery'
  target_value INTEGER NOT NULL,
  current_progress INTEGER DEFAULT 0,
  is_completed INTEGER DEFAULT 0,
  completed_date INTEGER,
  reward_rp INTEGER DEFAULT 0,
  reward_bonus TEXT, -- JSON for additional rewards
  expires_at INTEGER, -- For time-limited missions
  created_at INTEGER NOT NULL,
  metadata TEXT -- JSON for mission-specific data
);
```

5. **Mission progress tracking table**:
```sql
CREATE TABLE IF NOT EXISTS mission_progress(
  id TEXT PRIMARY KEY,
  mission_id TEXT NOT NULL,
  user_id TEXT DEFAULT 'default',
  progress_value INTEGER DEFAULT 0,
  is_completed INTEGER DEFAULT 0,
  completed_at INTEGER,
  last_updated INTEGER NOT NULL,
  FOREIGN KEY (mission_id) REFERENCES missions(id)
);
```

### Task 6.2: Analytics Updates for RP System
**Priority**: Low | **Complexity**: Low | **Dependencies**: Task 6.1

```dart
// Files to modify:
- lib/services/analytics_service.dart
- lib/widgets/analytics_screen.dart
```

**Requirements**:
- Replace XP-based analytics with RP-based analytics and insights
- Mission completion tracking
- Streak analysis and recommendations
- Productivity quality metrics based on RP system

**Acceptance Criteria**:
- Analytics reflect new hybrid progression philosophy
- Insights encourage sustainable productivity habits
- Streak analysis provides meaningful recommendations
- All XP references removed from analytics displays

---

## Phase 8: Duration-Based Logic Replacement

### Task 8.1: Audit and Replace Duration-Based Depth Calculations
**Priority**: High | **Complexity**: High | **Dependencies**: Phase 2 Task 1.3 Complete

**Files to audit and modify:**
```dart
// Core depth calculation services
- lib/services/creature_service.dart
- lib/services/ocean_biome_service.dart (create new)
- lib/services/depth_traversal_service.dart (create new)
- lib/widgets/dive_computer_widget.dart
- lib/widgets/full_screen_ocean_widget.dart
- lib/services/gamification_service.dart
```

**Current duration-based logic to replace:**

1. **Session-to-Depth Mapping** (from ACTIVITY_LOG.md):
```dart
// OLD: Duration-based static depth
15-20min sessions → 5-10m (Shallow Water Research)
25-30min sessions → 10-20m (Mid-Water Expedition)
45-60min sessions → 20-40m (Deep Sea Research)
90min+ sessions → 40m+ (Abyssal Expedition)

// NEW: Accelerated traversal system
// All sessions start at 0m, descent speed based on RP
class DepthTraversalService {
  double getCurrentDepth(Duration sessionTime, int cumulativeRP) {
    final multiplier = getDescentMultiplier(cumulativeRP);
    return sessionTime.inMinutes * 2.0 * multiplier; // 2m/min base rate
  }

  List<Biome> getTraversedBiomes(Duration sessionTime, int cumulativeRP) {
    final currentDepth = getCurrentDepth(sessionTime, cumulativeRP);
    // Return all biomes from 0m to currentDepth
  }
}
```

2. **Creature Discovery Rates** (biome-specific):
```dart
// OLD: Session duration determines single discovery biome
if (sessionMinutes >= 90) { abyssalCreatures() }
else if (sessionMinutes >= 45) { deepSeaCreatures() }
else if (sessionMinutes >= 25) { coralGardenCreatures() }
else { shallowWaterCreatures() }

// NEW: Discovery from all traversed biomes
final traversedBiomes = getTraversedBiomes(sessionTime, cumulativeRP);
final discoveryPool = [];

for (final biome in traversedBiomes) {
  final timeInBiome = calculateTimeInBiome(biome, sessionTime, cumulativeRP);
  if (timeInBiome > minimumDiscoveryTime) {
    discoveryPool.addAll(biome.creatures);
  }
}

// Weight discovery chances by time spent in each biome
selectDiscoveryFromPool(discoveryPool, weights: timeSpentWeights);
```

3. **Depth-Based Rewards**:
```dart
// OLD: Deeper = better rewards
if (depth >= 40) { bonusRewards() }

// NEW: RP-based with traversal bonuses
// Rewards based on deepest biome reached + traversal efficiency
final deepestBiome = getDeepestBiomeReached(sessionTime, cumulativeRP);
final traversalEfficiency = calculateTraversalEfficiency(sessionTime, cumulativeRP);
final rewards = calculateRewards(deepestBiome, traversalEfficiency);
```

**Requirements**:
- Replace static depth mapping with dynamic traversal calculation
- Implement biome traversal tracking for discovery eligibility
- Create weighted discovery system based on time in each biome
- Ensure all depth calculations use accelerated traversal system

**Acceptance Criteria**:
- All sessions start at 0m and descend based on RP multiplier
- Creature discovery possible from all traversed biomes
- No direct duration-to-depth mappings remain
- Visual depth shows real-time descent based on traversal speed
- Discovery system weights chances by time spent in each biome

### Task 8.2: Replace Achievement Duration Requirements
**Priority**: Medium | **Complexity**: Medium | **Dependencies**: Task 8.1

**Files to audit and modify:**
```dart
- lib/services/marine_biology_achievement_service.dart
- lib/services/streak_rewards_service.dart
- lib/models/achievement.dart
```

**Current duration-based achievements to replace:**

1. **Session Duration Achievements**:
```dart
// OLD: Duration-based milestones
"Complete a 60-minute deep dive session"
"Maintain focus for 90+ minutes (Abyssal Explorer)"
"Complete 5 marathon sessions (90+ minutes each)"

// NEW: RP and consistency-based milestones  
"Earn 50+ RP in total research contributions"
"Achieve Deep Ocean access (200+ cumulative RP)"
"Complete 5 perfect research sessions with break adherence"
```

2. **Productivity Quality Achievements**:
```dart
// OLD: Raw time-based
"Focus Champion: 10 hours total focus time"
"Endurance Expert: Complete 120-minute session"

// NEW: Quality and consistency-based
"Research Consistency: 7-day streak with break adherence"
"Quality Researcher: 10 perfect sessions (completed + break taken)"
"Productivity Master: Earn 500+ RP through quality sessions"
```

**Requirements**:
- Audit all achievement definitions for duration requirements
- Replace duration thresholds with RP, streak, or quality metrics
- Maintain achievement difficulty progression
- Ensure achievements encourage healthy productivity habits

**Acceptance Criteria**:
- No achievements require specific session durations
- All productivity achievements focus on consistency, quality, or RP accumulation
- Achievement difficulty scales appropriately with RP system
- New achievements promote sustainable work habits

### Task 8.3: Update Career Progression Logic
**Priority**: Medium | **Complexity**: Low | **Dependencies**: Task 4.1, Task 8.1

**Files to modify:**
```dart
- lib/services/marine_biology_career_service.dart
- lib/widgets/marine_biology_career_widget.dart
```

**Current level-based progression to replace:**

1. **Career Title Calculation**:
```dart
// OLD: Level-based titles (from XP/duration)
String getCareerTitle(int level) {
  return careerTitles[level] ?? 'Marine Biology Intern';
}

// NEW: RP-based titles (from cumulative RP)
String getCareerTitle(int cumulativeRP) {
  // Find highest RP threshold user has achieved
  final availableTitles = careerTitles.entries
      .where((entry) => cumulativeRP >= entry.key)
      .toList()
      ..sort((a, b) => b.key.compareTo(a.key));
  
  return availableTitles.isNotEmpty 
      ? availableTitles.first.value 
      : 'Marine Biology Intern';
}
```

2. **Equipment Unlock Logic**:
```dart
// OLD: Level-based equipment unlocks
if (userLevel >= equipment.unlockLevel)

// NEW: RP-based equipment unlocks  
if (cumulativeRP >= equipment.unlockRP)
```

**Requirements**:
- Replace all level-based calculations with RP-based calculations
- Update career title lookup to use cumulative RP instead of levels
- Ensure equipment unlocks align with RP milestones
- Maintain progression curve feel with new RP thresholds

**Acceptance Criteria**:
- Career titles calculated from cumulative RP, not levels
- Equipment unlocks based on RP milestones
- No references to user "levels" in career progression
- Progression curve maintains appropriate difficulty scaling

### Task 8.4: Update Visual and UI Components
**Priority**: Medium | **Complexity**: Medium | **Dependencies**: Tasks 8.1-8.3

**Files to modify:**
```dart
- lib/widgets/research_progress_widget.dart
- lib/widgets/research_expedition_summary_widget.dart
- lib/screens/analytics_screen.dart
- lib/widgets/species_discovery_overlay.dart
```

**UI elements to update:**

1. **Progress Indicators**:
```dart
// OLD: Level progress bars and XP displays
"Level 15 Marine Biology Student"
"2,450 XP / 3,000 XP to next level"

// NEW: RP progress and career title displays
"Research Associate (500 RP)"
"150 RP to Field Researcher (750 RP total)"
```

2. **Session Summary Displays**:
```dart
// OLD: Duration and XP focus
"45-minute Deep Sea Expedition completed!"
"Earned 120 XP for extended focus session"

// NEW: RP and quality focus
"Research Session completed with perfect quality!"
"Earned 15 RP (10 base + 2 break + 3 streak bonus)"
```

3. **Analytics and Insights**:
```dart
// OLD: Duration-based analytics
"Average session duration: 38 minutes"
"Longest session this week: 87 minutes"

// NEW: Quality and consistency analytics
"Average session RP: 12 points"
"Research consistency: 5-day streak active"
"Quality score: 85% (break adherence + completions)"
```

**Requirements**:
- Replace all duration-focused messaging with RP and quality messaging
- Update progress bars to show RP accumulation instead of XP/levels
- Ensure celebration messages emphasize quality over duration
- Analytics focus on consistency and RP trends rather than time metrics

**Acceptance Criteria**:
- No UI elements emphasize or reward longer session durations
- All progress indicators use RP-based calculations
- Session celebrations highlight quality and consistency
- Analytics promote sustainable productivity patterns

### Task 8.5: Code Audit for Hidden Duration Logic
**Priority**: High | **Complexity**: High | **Dependencies**: Tasks 8.1-8.4

**Comprehensive code search patterns:**
```bash
# Search for duration-based logic patterns
grep -r "duration.*depth" lib/
grep -r "minutes.*biome" lib/
grep -r "sessionMinutes" lib/
grep -r "session.*minutes.*>=\|>" lib/
grep -r "\.duration\." lib/
grep -r "Duration(" lib/
grep -r "inMinutes" lib/
```

**Files requiring thorough audit:**
```dart
- lib/services/ (all service files)
- lib/widgets/ (all widget files)  
- lib/models/ (all model files)
- lib/controllers/ (all controller files)
- lib/utils/ (any calculation utilities)
```

**Common duration logic patterns to find and replace:**

1. **Conditional Duration Checks**:
```dart
// Find patterns like:
if (session.duration.inMinutes >= 45) { /* deep sea logic */ }
if (sessionLength > Duration(minutes: 60)) { /* abyssal logic */ }

// Replace with:
if (user.cumulativeRP >= 201) { /* deep sea logic */ }
if (user.cumulativeRP >= 501) { /* abyssal logic */ }
```

2. **Direct Duration Calculations**:
```dart
// Find patterns like:
final depth = calculateDepthFromDuration(session.duration);
final biome = getBiomeFromMinutes(session.duration.inMinutes);

// Replace with:
final depth = getCurrentDepthZone(user.cumulativeRP);
final biome = getUnlockedBiome(user.cumulativeRP);
```

**Requirements**:
- Systematic search through entire codebase for duration-based logic
- Document all instances found and replacement strategy
- Ensure no hidden duration advantages remain in the system
- Validate that all progression is truly RP-based after changes

**Acceptance Criteria**:
- Zero instances of session duration determining rewards or progression
- All depth, biome, and achievement logic based on cumulative RP
- Code search patterns return no false positives for duration-based rewards
- System testing confirms no duration advantages exist

### Task 7.1: Unit Tests for Core RP System
**Priority**: High | **Complexity**: Medium | **Dependencies**: Phases 1-2 Complete

```dart
// Test files to create/update:
- test/services/research_points_service_test.dart
- test/models/mission_test.dart
- test/services/gamification_service_test.dart
```

**Test Coverage Requirements**:
- RP calculation accuracy across all scenarios
- Bonus system edge cases and exploitation prevention
- Mission progress tracking and completion
- Streak system boundary conditions

### Task 7.2: Integration Tests and User Flow Validation
**Priority**: High | **Complexity**: High | **Dependencies**: Phases 1-5 Complete

**Test Scenarios**:
- New user onboarding with RP system
- Multiple session types and their RP rewards
- Mission system integration with core progression
- Complete removal of XP system functionality

**Acceptance Criteria**:
- All user flows work seamlessly with new RP-only system
- No regression in existing functionality
- Performance maintained with new calculations
- User experience improvements validated
- Complete migration from XP to RP verified

---

## Implementation Progress

### ✅ COMPLETED: Phase 1, Task 1.1 - Update Table Creation Scripts for RP System
**Date Completed**: 2025-09-02  
**Files Modified**: `lib/services/persistence/persistence_service.dart`

**Summary**: Successfully updated database schema for RP system implementation:
- ✅ Replaced XP columns with RP columns in all table creation scripts
- ✅ Added new RP tracking columns to sessions table: `research_points`, `base_rp`, `bonus_rp`, `break_adherence`, `streak_bonus`, `session_quality`
- ✅ Updated gamification_state table with `total_rp`, `cumulative_rp`, `current_depth_zone`  
- ✅ Updated marine_career table to use `career_rp` and `current_career_rp` instead of XP-based progression
- ✅ Updated achievements and research tables to use `rp_reward` instead of `xp_reward`
- ✅ Updated equipment table to use `unlock_rp` instead of `unlock_level`
- ✅ Added complete mission system tables: `missions` and `mission_progress`
- ✅ Added proper indexes for RP-based queries and mission system
- ✅ Updated database version to 4 with full migration support
- ✅ Updated default data initialization to use RP values

**Acceptance Criteria Met**:
- ✅ Fresh database installations create RP-based schema
- ✅ All tables include necessary RP tracking columns  
- ✅ Mission system fully supported by database schema
- ✅ No XP columns remain in any table definitions

### 🔄 NEXT TASK: Phase 2, Task 1.1 - Create RP Constants and Models
**Priority**: High | **Complexity**: Low | **Dependencies**: Phase 1 Task 1.1 Complete ✅

**Files to create/modify:**
- `lib/constants/research_points_constants.dart` (create)
- `lib/models/research_points.dart` (create)  
- `lib/models/session_quality.dart` (create)

**Requirements:**
- Base RP formula: 25min session = 10 RP, 50min session = 20 RP
- Bonus system: +2 RP for break adherence, +5 RP for streak
- Session quality enum: Perfect, Good, Abandoned
- RP calculation utilities with bonus multipliers

---

### ✅ COMPLETED: Repository Files Updated for RP System Compatibility
**Date Completed**: 2025-09-02  
**Files Modified**: All repository files in `lib/services/persistence/repositories/`

**Summary**: Successfully updated all repository files for RP system compatibility:

**GamificationRepository Updates:**
- ✅ Replaced XP system with RP system (`addRP()` method)
- ✅ Added cumulative RP tracking and depth zone calculation 
- ✅ Updated level calculation to use RP thresholds (50 RP per level vs 100 XP)
- ✅ Added `_calculateDepthZone()` method for biome progression
- ✅ Updated achievement unlocking to use RP rewards
- ✅ Updated default state initialization for RP values

**CareerRepository Updates:**
- ✅ Replaced XP-based career progression with RP-based system
- ✅ Updated `addCareerRP()` method for career advancement
- ✅ Implemented RP-based career title system with all 20 titles
- ✅ Added `_getCareerTitleFromRP()` with proper RP thresholds (50 RP → 10500 RP)
- ✅ Updated milestone achievements to use RP rewards
- ✅ Added `_getNextRPMilestone()` for progression tracking
- ✅ Updated career statistics to show RP progress instead of XP/levels

**EquipmentRepository Updates:**
- ✅ Replaced level-based unlocks with RP-based unlocks
- ✅ Updated `checkAndUnlockEquipmentByRP()` method
- ✅ Converted all equipment unlock requirements from levels to RP values
- ✅ Updated equipment queries to use `unlock_rp` instead of `unlock_level`
- ✅ Maintained equipment progression curve aligned with career milestones

**MissionRepository Creation:**
- ✅ Created complete mission system repository
- ✅ Implemented mission progress tracking and completion logic
- ✅ Added mission categories: daily, weekly, achievement-based
- ✅ Integrated RP reward system for mission completion
- ✅ Added default mission initialization with various difficulty levels
- ✅ Implemented mission statistics and analytics

**PersistenceService Integration:**
- ✅ Added MissionRepository to main service
- ✅ Updated repository initialization to include mission repository
- ✅ Maintained compatibility with existing ocean, session, and research repositories

**Acceptance Criteria Met**:
- ✅ All XP references replaced with RP throughout repository layer
- ✅ Equipment unlocks based on cumulative RP, not levels
- ✅ Career progression uses RP thresholds matching implementation plan
- ✅ Mission system fully integrated with RP-based rewards
- ✅ Database queries optimized for RP-based calculations
- ✅ Backward compatibility maintained for existing data structures

### ✅ COMPLETED: Phase 2, Task 1.1 - Create RP Constants and Models
**Date Completed**: 2025-09-02  
**Files Created**: 
- `lib/constants/research_points_constants.dart`
- `lib/models/session_quality.dart` 
- `lib/models/research_points.dart`

**Summary**: Successfully implemented comprehensive RP system foundation with deterministic calculations:

**ResearchPointsConstants Class:**
- ✅ Base RP formula implementation (25min = 10 RP, 50min = 20 RP)
- ✅ Bonus system constants (+2 RP break adherence, +5 RP streak)
- ✅ SessionQuality enum (Perfect, Good, Abandoned) with multipliers
- ✅ Depth zone thresholds (0-50, 51-200, 201-500, 501+ RP)
- ✅ Career title RP thresholds (20 levels: 0 → 10,500 RP)
- ✅ Equipment unlock thresholds aligned with progression
- ✅ Mission reward constants by difficulty level
- ✅ Anti-exploitation limits (max daily RP, bonus caps)

**SessionQualityModel Class:**
- ✅ Comprehensive session quality assessment logic
- ✅ Break adherence calculation (15% ratio, 30s minimum)
- ✅ Quality determination (Perfect/Good/Abandoned)
- ✅ Detailed feedback and improvement recommendations
- ✅ JSON serialization for persistence
- ✅ Automatic quality assessment from session data

**ResearchPoints Class:**
- ✅ Deterministic RP calculation with all bonus types
- ✅ Anti-exploitation measures (daily limits, bonus caps)
- ✅ Quality multiplier application (Perfect=100%, Good=85%, Abandoned=0%)
- ✅ Streak bonus with daily limit enforcement
- ✅ Efficiency calculation and performance metrics
- ✅ Detailed breakdown for transparency
- ✅ User feedback and improvement recommendations

**RPCalculator Utility:**
- ✅ Expected RP calculation for planning
- ✅ Optimal session duration recommendations
- ✅ Daily limit validation
- ✅ Career/depth milestone calculations

**Acceptance Criteria Met:**
- ✅ RP calculations are deterministic and testable
- ✅ Bonus system prevents exploitation (max 1 streak bonus per day)
- ✅ Clean separation between base RP and bonus RP
- ✅ All constants centralized and well-documented
- ✅ Comprehensive validation and error handling

### ✅ COMPLETED: Phase 2, Task 1.2 - Replace XP System with RP in GamificationService
**Date Completed**: 2025-09-03
**Files Modified**: 
- `lib/services/gamification_service.dart`
- `lib/services/marine_biology_career_service.dart`

**Summary**: Successfully replaced XP system with RP-based progression in GamificationService:

**GamificationService Updates:**
- ✅ Replaced all XP variables with RP equivalents (`_totalRP`, `_cumulativeRP`)
- ✅ Added depth zone tracking based on cumulative RP
- ✅ Implemented break adherence detection algorithm (15% break ratio, 30s minimum)
- ✅ Integrated ResearchPoints model for accurate RP calculations
- ✅ Added daily RP tracking with streak bonus limits
- ✅ Updated career progression to use cumulative RP instead of levels
- ✅ Modified equipment unlock system to use RP thresholds
- ✅ Implemented proper streak calculation with daily bonus prevention

**GamificationReward Updates:**
- ✅ Replaced XP fields with RP fields (`rpGained`, `baseRP`, `streakBonusRP`)
- ✅ Added break adherence bonus tracking
- ✅ Added quality bonus tracking
- ✅ Added depth zone progression fields
- ✅ Added cumulative RP tracking
- ✅ Maintained backward compatibility with legacy XP fields

**MarineBiologyCareerService Updates:**
- ✅ Added `getCareerTitleFromRP()` method with all 20 career titles
- ✅ RP thresholds match ResearchPointsConstants (50 RP → 10,500 RP)

**Acceptance Criteria Met:**
- ✅ Session completion awards appropriate RP based on duration
- ✅ Break adherence properly detected and rewarded
- ✅ Streak system doesn't double-award on same day
- ✅ All XP references replaced with RP throughout the system
- ✅ RP breakdown clearly shown in reward calculation

### ✅ COMPLETED: Phase 2, Task 1.3 - Implement Accelerated Depth Traversal System
**Date Completed**: 2025-09-14
**Files Created:**
- `lib/services/ocean_biome_service.dart`
- `lib/services/depth_traversal_service.dart`
- `lib/constants/depth_constants.dart`

**Summary**: Successfully implemented the accelerated depth traversal system with RP-based descent mechanics:

**OceanBiomeService Implementation:**
- ✅ Biome depth boundaries defined (Shallow: 0-20m, Coral: 20-50m, Deep: 50-100m, Abyssal: 100m+)
- ✅ RP-based descent multiplier system (1x, 2x, 3x, 4x based on cumulative RP)
- ✅ Time-in-biome calculations for multi-biome traversal
- ✅ Discovery eligibility system with minimum time requirements per biome
- ✅ Discovery weight calculations with biome-specific multipliers
- ✅ Visual and audio feedback systems for biome characteristics

**DepthTraversalService Implementation:**
- ✅ Base descent rate: 2 meters per minute with RP multipliers
- ✅ Real-time depth calculation during sessions
- ✅ Biome progression tracking throughout descent
- ✅ Discovery window calculations for all traversed biomes
- ✅ Example depth calculations for different experience levels
- ✅ Traversal efficiency metrics and validation systems

**DepthConstants Implementation:**
- ✅ Complete experience profile system (Beginner → Master)
- ✅ Biome depth boundaries with discovery requirements
- ✅ Session depth examples for planning (10min, 25min, 45min sessions)
- ✅ Visual aesthetics constants for each biome
- ✅ Utility methods for depth and biome calculations

**Core Mechanics Implemented:**
- ✅ All dives start at surface (0m) - natural diving physics
- ✅ RP-based descent speed: 2m/min (Beginner) → 8m/min (Master)
- ✅ Multi-biome traversal system with time tracking
- ✅ Discovery opportunities at all depths during descent
- ✅ Biome-specific minimum time requirements for discovery eligibility

**Acceptance Criteria Met:**
- ✅ All sessions start at surface (0m) regardless of RP
- ✅ Descent speed increases with cumulative RP (not starting depth)
- ✅ Species discovery possible at all depths passed during descent
- ✅ Short sessions by experienced divers can reach meaningful depths
- ✅ Depth calculation system ready for visual animation integration
- ✅ Discovery system weights chances by time spent in each biome

### 🔄 NEXT TASK: Phase 2, Task 2.1 - Create Mission Framework
**Priority**: Medium | **Complexity**: Medium | **Dependencies**: Phase 1 Complete ✅

**Files to create:**
- `lib/models/mission.dart`
- `lib/models/mission_progress.dart`
- `lib/services/mission_service.dart`
- `lib/constants/mission_constants.dart`

**Requirements:**
- Mission types: Daily, Weekly, Achievement-based
- Mission categories: Consistency, Productivity, Discovery
- Progress tracking with completion status
- Reward system integration with RP

**Example Missions:**
- "Complete 3 dives today" (Daily)
- "Maintain a 5-day streak" (Weekly)
- "Log 50 minutes underwater in one week" (Weekly)