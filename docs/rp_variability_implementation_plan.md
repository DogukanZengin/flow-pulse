# Research Points (RP) Variability Implementation Plan

## Overview
This document outlines the plan to add excitement and variability to the Research Points system by leveraging existing creature discovery and achievement systems, moving away from the current deterministic RP calculation.

## Problem Statement
Current RP calculation is too predictable:
- Fixed formula: `(minutes / 25 × 10) × quality_multiplier`
- No element of surprise or luck
- Lacks excitement and dopamine rewards
- Every 25-minute session yields exactly 10 base RP

## Solution: Dynamic RP Through Existing Systems

### Core Principle
Maintain 60-70% predictable base RP while adding 30-40% variable rewards through existing game mechanics.

## Implementation Phases

### Phase 1: Creature Discovery RP Bonuses
**Priority: HIGH | Effort: LOW | Impact: HIGH**

#### Current State
- Creatures have `pearlValue` property but it's separate from RP
- Discovery system already has rarity-based probabilities
- Discovery chance influenced by streak and daily bonuses

#### Implementation
```dart
// In GamificationService.completeSession()
int calculateCreatureBonus(List<Creature> discoveredCreatures) {
  int totalBonus = 0;

  for (final creature in discoveredCreatures) {
    // Base bonus from pearl value
    int baseBonus = creature.pearlValue;

    // Add 30% variance for excitement
    int variance = (baseBonus * 0.3).round();
    int actualBonus = baseBonus + Random().nextInt(variance * 2 + 1) - variance;

    // Rarity-based bonus RP
    int rarityBonus = 0;
    switch (creature.rarity) {
      case CreatureRarity.legendary:
        rarityBonus = Random().nextInt(20) + 10; // +10-30 RP
        break;
      case CreatureRarity.rare:
        rarityBonus = Random().nextInt(10) + 5;  // +5-15 RP
        break;
      case CreatureRarity.uncommon:
        rarityBonus = Random().nextInt(5) + 2;   // +2-7 RP
        break;
      case CreatureRarity.common:
        rarityBonus = Random().nextInt(3);       // +0-3 RP
        break;
    }

    totalBonus += actualBonus + rarityBonus;
  }

  return totalBonus;
}
```

#### Expected RP Ranges
- **Common creature**: 3-8 RP
- **Uncommon creature**: 8-15 RP
- **Rare creature**: 20-35 RP
- **Legendary creature**: 40-70 RP

### Phase 2: Achievement Unlock RP Rewards
**Priority: HIGH | Effort: LOW | Impact: MEDIUM**

#### Current State
- Achievements unlock based on conditions
- Provide only visual rewards currently
- No RP incentive for achievement hunting

#### Implementation
```dart
// New achievement RP reward system
class AchievementRPRewards {
  static int getRewardForAchievement(String achievementId) {
    // Base reward + random variance
    final rewards = {
      // Starter achievements
      'first_session': [5, 0],           // 5 RP, no variance
      'first_discovery': [8, 2],         // 8 RP ± 2

      // Streak achievements
      'streak_3': [10, 5],               // 10 RP ± 5
      'streak_7': [20, 10],              // 20 RP ± 10
      'streak_14': [35, 10],             // 35 RP ± 10
      'streak_30': [50, 20],             // 50 RP ± 20
      'streak_100': [100, 30],           // 100 RP ± 30

      // Session milestones
      'sessions_10': [12, 3],            // 12 RP ± 3
      'sessions_25': [20, 5],            // 20 RP ± 5
      'sessions_50': [30, 10],           // 30 RP ± 10
      'sessions_100': [50, 15],          // 50 RP ± 15
      'sessions_500': [150, 50],         // 150 RP ± 50

      // Level achievements
      'level_5': [15, 5],                // 15 RP ± 5
      'level_10': [25, 10],              // 25 RP ± 10
      'level_25': [60, 20],              // 60 RP ± 20
      'level_50': [120, 40],             // 120 RP ± 40

      // Discovery achievements
      'discover_5_creatures': [20, 5],   // 20 RP ± 5
      'discover_all_common': [40, 10],   // 40 RP ± 10
      'discover_first_rare': [30, 10],   // 30 RP ± 10
      'discover_first_legendary': [75, 25], // 75 RP ± 25
    };

    final reward = rewards[achievementId] ?? [10, 0];
    final baseRP = reward[0];
    final variance = reward[1];

    return baseRP + (variance > 0 ? Random().nextInt(variance * 2 + 1) - variance : 0);
  }
}
```

### Phase 3: Session Quality Discovery Modifiers
**Priority: MEDIUM | Effort: MEDIUM | Impact: MEDIUM**

#### Implementation
```dart
// In CreatureService.checkForCreatureDiscovery()
double calculateDiscoveryChance(SessionQuality quality, CreatureRarity targetRarity) {
  // Base chance from rarity
  double baseChance = targetRarity.baseDiscoveryChance;

  // Quality modifier
  double qualityModifier = 1.0;
  switch (quality) {
    case SessionQuality.perfect:
      qualityModifier = 2.0;    // 2x discovery chance
      break;
    case SessionQuality.excellent:
      qualityModifier = 1.5;    // 1.5x discovery chance
      break;
    case SessionQuality.good:
      qualityModifier = 1.2;    // 1.2x discovery chance
      break;
    case SessionQuality.poor:
      qualityModifier = 0.8;    // 0.8x discovery chance
      break;
    case SessionQuality.abandoned:
      return 0;                 // No discoveries
  }

  // Streak modifier (up to +50% at 30-day streak)
  double streakModifier = 1.0 + min(currentStreak / 60, 0.5);

  // Depth modifier (deeper = rarer creatures)
  double depthModifier = 1.0 + (sessionDepth / 100) * 0.3;

  return min(baseChance * qualityModifier * streakModifier * depthModifier, 0.95);
}
```

### Phase 4: Critical Research Events
**Priority: LOW | Effort: MEDIUM | Impact: HIGH**

#### Implementation
```dart
// 5% chance for special session events
class CriticalResearchEvent {
  static ResearchEvent? rollForEvent() {
    if (Random().nextDouble() > 0.05) return null; // 95% no event

    final events = [
      PerfectConditions(),      // 2x total RP
      ResearchBreakthrough(),   // +50% RP + guaranteed rare discovery
      UnexpectedMigration(),    // 3 guaranteed creature discoveries
      EquipmentMalfunction(),   // -30% RP but next session guaranteed rare
      StormDisruption(),        // -50% RP but +100% discovery chance next 3 sessions
    ];

    return events[Random().nextInt(events.length)];
  }
}
```

## Balance Mechanisms

### Daily Cap System
```dart
class EnhancedDailyCap {
  static const int SOFT_CAP = 300;     // Normal daily limit
  static const int HARD_CAP = 400;     // Absolute maximum with bonuses
  static const int OVERFLOW_CAP = 450; // Only for legendary discoveries

  static int applyDailyCap(int earnedRP, int todayTotalRP) {
    if (todayTotalRP < SOFT_CAP) {
      return earnedRP; // 100% RP
    } else if (todayTotalRP < HARD_CAP) {
      return (earnedRP * 0.5).round(); // 50% RP
    } else if (todayTotalRP < OVERFLOW_CAP && hasLegendaryDiscovery) {
      return (earnedRP * 0.25).round(); // 25% RP only for legendary
    } else {
      return 0; // No more RP
    }
  }
}
```

### Bad Luck Protection
```dart
class BadLuckProtection {
  // Pity system for discoveries
  int sessionsSinceLastDiscovery = 0;
  int sessionsSinceRareDiscovery = 0;
  int sessionsSinceLegendary = 0;

  double getPityBonus() {
    double bonus = 0;

    // No discovery for 5 sessions: +20% chance
    if (sessionsSinceLastDiscovery >= 5) {
      bonus += 0.2;
    }

    // No rare for 20 sessions: +50% rare chance
    if (sessionsSinceRareDiscovery >= 20) {
      bonus += 0.5;
    }

    // No legendary for 100 sessions: +100% legendary chance
    if (sessionsSinceLegendary >= 100) {
      bonus += 1.0;
    }

    return bonus;
  }

  // Minimum RP guarantee
  static int ensureMinimumRP(int totalRP, int sessionMinutes) {
    int expectedMinimum = (sessionMinutes / 25 * 5).round(); // 50% of base
    return max(totalRP, expectedMinimum);
  }
}
```

## UI/UX Updates

### Enhanced Session Results Display
```
═══════════════════════════════════════
         RESEARCH EXPEDITION
═══════════════════════════════════════
📊 Base Data Collection:          10 RP
⚡ Quality Modifier (Perfect):    +2 RP
🔥 Daily Streak (7 days):         +5 RP
───────────────────────────────────────
🐠 MARINE DISCOVERIES:
   Common Clownfish              +4 RP
   Uncommon Sea Turtle          +12 RP
   ✨ RARE Blue Tang!           +28 RP
   [Animated celebration for rare+]
───────────────────────────────────────
🏆 ACHIEVEMENTS UNLOCKED:
   "Week Warrior" (7-day streak) +22 RP
   "First Rare Discovery"        +35 RP
───────────────────────────────────────
🎯 CRITICAL EVENT:
   ⚡ Perfect Research Conditions!
   All RP doubled this session!
───────────────────────────────────────
TOTAL RESEARCH POINTS:          236 RP
                         (2x = 118 RP)
═══════════════════════════════════════

[Particle effects scale with total RP]
[Special animations for 50+ RP sessions]
```

### Visual Feedback Improvements
1. **Discovery Anticipation**: "Analyzing samples..." with spinner
2. **Rarity Celebration**: Particle effects scale with creature rarity
3. **Achievement Fanfare**: Special animation for achievement unlocks
4. **RP Counter**: Animated counting with acceleration for large numbers
5. **Lucky Streak Indicator**: Visual indicator when on a "hot streak"

## Expected Outcomes

### Session RP Distribution
- **Unlucky session** (10%): 8-12 RP (base only, no discoveries)
- **Average session** (60%): 15-25 RP (base + common discovery)
- **Lucky session** (25%): 30-50 RP (base + uncommon/achievement)
- **Jackpot session** (5%): 60-150 RP (rare/legendary + achievements)

### Player Psychology Benefits
1. **Anticipation**: Every session could be special
2. **Loss Aversion**: Bad luck protection prevents frustration
3. **Achievement Hunting**: RP rewards incentivize completion
4. **Discovery Excitement**: Creature finds feel valuable
5. **Streak Motivation**: Better rewards for consistency

## Implementation Timeline

### Week 1: Foundation
- [ ] Add creature discovery RP bonuses to GamificationService
- [ ] Update SessionResultsPage to show discovery bonuses
- [ ] Test balance with common creatures

### Week 2: Achievements
- [ ] Implement achievement RP reward system
- [ ] Add achievement celebration to UI
- [ ] Create achievement RP lookup table

### Week 3: Quality Modifiers
- [ ] Add quality-based discovery chance modifiers
- [ ] Implement streak-based luck improvements
- [ ] Add depth-based creature availability

### Week 4: Polish & Events
- [ ] Add critical research events (optional)
- [ ] Implement bad luck protection
- [ ] Add visual celebrations and animations
- [ ] Balance testing and adjustment

## Testing Checklist

### Balance Testing
- [ ] Verify daily cap prevents exploitation
- [ ] Confirm minimum RP guarantees work
- [ ] Test pity system triggers appropriately
- [ ] Validate achievement rewards are one-time only

### User Experience
- [ ] Discovery animations feel rewarding
- [ ] RP variance feels fair not frustrating
- [ ] Lucky sessions feel special
- [ ] Unlucky sessions still progress

### Edge Cases
- [ ] Multiple discoveries in one session
- [ ] Achievement + discovery combo
- [ ] Daily cap overflow handling
- [ ] Streak loss doesn't feel punishing

## Metrics to Track

1. **Average RP per session** (should remain ~20-25)
2. **RP variance** (standard deviation should increase)
3. **Discovery rates** (should match probability tables)
4. **Player retention** (excitement should improve)
5. **Session completion rate** (should increase)

## Rollback Plan

If the system needs adjustment:
1. Variance can be reduced by lowering bonus ranges
2. Daily caps can be adjusted
3. Discovery rates can be tweaked
4. Can revert to pure deterministic with one flag

## Future Enhancements

1. **Seasonal Events**: Special creatures with bonus RP
2. **Community Goals**: Shared discovery milestones
3. **Lucky Hours**: Announced high-discovery periods
4. **Prestige System**: Reset for permanent luck bonuses
5. **Discovery Chains**: Bonus for finding related species