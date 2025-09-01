# 🌊 FlowPulse – Revised Leveling & Discovery Framework

## 🔄 Refactoring Goal
Replace the current **duration-based depth and progression system** (longer sessions = deeper biomes, rarer discoveries, higher XP) with a **productivity- and consistency-based system**.

---

## 📝 Replacement Tasks

### 1. Replace Depth Progression Logic
- **Current:** Depth tied directly to session duration (e.g., 90min = Abyssal Zone).
- **New:** Depth tied to cumulative **Research Points (RP)** from multiple sessions.

**Task:** Refactor `DepthProgressionService` to calculate based on RP totals instead of session length.

---

### 2. Implement Research Points (RP)
- **Current:** XP awarded only by duration.
- **New:** Introduce RP as the universal metric.  
  - 25min session = 10 RP  
  - 50min session = 20 RP  
  - +2 RP for proper break  
  - +5 RP for daily streak  

**Task:** Create `ResearchPointService` that assigns RP after each completed session.

---

### 3. Modify Discovery System
- **Current:** Rarity tied to depth from a single long session.
- **New:** Rarity tied to **consistency and streaks**.  
  - First session daily = guaranteed discovery  
  - Multiple sessions/day = +10% rare chance  
  - 5-day streak = biome event  
  - 30-day streak = guaranteed legendary

**Task:** Update `CreatureService` discovery chance calculations to use session count & streak state.

---

### 4. Update Career Progression
- **Current:** Career tied to depth/duration milestones.
- **New:** Career tied to total RP + streak milestones.  
  - Research Assistant = 100 RP or 10 sessions  
  - Senior Researcher = 500 RP + 5-day streak  
  - Professor = 1500 RP + 30-day streak  
  - Master = 3000 RP + complete species log

**Task:** Refactor `MarineBiologyCareerService` to calculate promotions from RP + streaks.

---

### 5. Add Dive Ratings (Session Quality Feedback)
- 🌟 Perfect Dive = Full RP + Bonus  
- ⚓ Safe Ascent = Standard RP  
- 🚫 Early Ascent = No RP, no discovery

**Task:** Extend `SessionResultWidget` to display Dive Ratings and feed rating into RP calculation.

---

## 📊 New Leveling Framework

### 1. Core Unit → Research Points (RP)
- Every completed session earns RP, not raw time.  

### 2. Depth Progression → Cumulative Research
| Depth Zone         | Unlock Requirement |
|---------------------|--------------------|
| Shallow Waters 🌊   | 0 – 50 RP          |
| Coral Garden 🪸     | 51 – 200 RP        |
| Deep Ocean 🐠       | 201 – 500 RP       |
| Abyssal Zone 🦑     | 501+ RP            |

### 3. Discovery System → Consistency Rewards
| Condition | Discovery Chance Modifier |
|-----------|----------------------------|
| First session daily | Guaranteed discovery |
| 2+ sessions same day | +10% rare chance |
| 5-day streak | Unlocks unique biome event |
| 30-day streak | Legendary species guaranteed |

### 4. Career Progression → Milestones
| Career Title                | Unlock Condition |
|------------------------------|------------------|
| Marine Biology Intern 🧑‍🎓   | First completed session |
| Research Assistant 📘        | 100 RP or 10 completed sessions |
| Senior Researcher 🔬         | 500 RP + 5-day streak |
| Professor 🧑‍🏫               | 1500 RP + 30-day streak |
| Master Marine Biologist 🐋   | 3000 RP + Complete species log |

### 5. Dive Ratings
| Dive Rating    | Condition | Reward |
|----------------|-----------|--------|
| 🌟 Perfect Dive | Completed without abandoning | +Bonus RP |
| ⚓ Safe Ascent | Completed with minor pause | Standard RP |
| 🚫 Early Ascent | Abandoned | No RP, no discovery |

---

## ⚖️ Why This Works
- Encourages sustainable Pomodoro cycles (3×25min > 1×90min).  
- Rewards consistency & streaks over raw endurance.  
- Keeps discovery exciting on daily basis.  
- Aligns career growth with productivity, not time spent.

