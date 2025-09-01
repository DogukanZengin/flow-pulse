# Implementation Roadmap for Break Screen Improvements

This document provides a task-list style plan for upgrading
`@lib/widgets/research_vessel_deck_widget.dart` (the break session
screen) based on the expert UI/UX recommendations.

------------------------------------------------------------------------

## ⚠️ Constraints

-   Do not add completely new components unless explicitly required.
-   Clearly state what **existing component is being replaced or
    extended**.
-   Each step should be independent and incremental.
-   Keep consistency with the architecture from `ACTIVITY_LOG.md` (e.g.,
    `FullScreenOceanWidget`, `DiveComputerWidget`, `CreatureSystem`,
    `CoralSystem`).

------------------------------------------------------------------------

## 📝 Task List for Break Screen Improvements

### Implementation Status

1.  **[✓] Calm Color Palette Update**
    -   **Replace:** Current static background in `ResearchVesselDeckWidget` (lines 125-137)
    -   **With:** Light aqua + pastel blue gradient using `BoxDecoration`
    -   **Implementation:**
        ```dart
        colors: [
          Color(0xFFE0F7FA), // Light cyan (pastel aqua)
          Color(0xFFB2EBF2), // Cyan 100
          Color(0xFF80DEEA), // Cyan 200
          Color(0xFF4DD0E1), // Cyan 300
        ]
        ```
    -   **Outcome:** Softer, more relaxing atmosphere on break screen

2.  **[✓] Typography Adjustment**
    -   **Replace:** Current bold "Break Time" `Text` widget (lines 337-344)
    -   **With:** Softer rounded font with lighter weight (`FontWeight.w500`)
    -   **Implementation:** Add `letterSpacing: 0.5` for softer feel
    -   **Outcome:** Reduce visual tension and create a calming effect

3.  **[ ] Enhanced Wave Animation**
    -   **Extend:** `WavesPainter` class (lines 601-661)
    -   **With:** Secondary wave layer with phase offset, smoother sine calculations
    -   **Implementation:** Add gentler amplitude variations
    -   **Outcome:** Gentle motion to reinforce relaxation without draining battery

4.  **[ ] Marine Companion Improvements**
    -   **Extend:** `_initializeSurfaceWildlife()` method (lines 86-108)
    -   **Add:** Bezier curve paths, opacity fading at edges, varied speed patterns
    -   **Outcome:** Ambient presence of marine life without clutter

5.  **[ ] Natural Progress Visualization**
    -   **Replace:** Linear progress bar (lines 361-379)
    -   **With:** Sun arc animation or wave-fill animation using `CustomPaint`
    -   **Outcome:** Natural, meditative pacing aligned with break duration

6.  **[ ] Simplified Button Flow**
    -   **Replace:** Dual buttons shown simultaneously (lines 395-412)
    -   **With:** Conditional logic:
        -   Pre-break → Show **Start Break** only
        -   During break → Show **Pause/Resume** and **End Break**
    -   **Outcome:** Cleaner UX, reduces choice overload

7.  **[ ] Rotating Encouragement Messages**
    -   **Replace:** Random message selection (lines 518-528)
    -   **With:** `Timer.periodic` cycling every 30 seconds with fade transitions
    -   **Outcome:** Keeps content fresh and motivating without new UI complexity

8.  **[ ] Testing & Polish**
    -   **Verify:** 60fps performance on all animations
    -   **Test:** Mobile and tablet responsive layouts
    -   **Validate:** Color contrast for accessibility
    -   **Outcome:** Production-ready polished experience

9.  **[ ] Gamified Relaxation Hooks (Optional, Phase 2)**
    -   **Extend:** Current break completion handler
    -   **Add:** Hooks to `GamificationService` for "Relax XP" or coral glow bonuses
    -   **Outcome:** Integration with existing gamification system while keeping relaxation lightweight

------------------------------------------------------------------------

## ✅ Expected End State

-   `ResearchVesselDeckWidget` evolves from static layout into a **calm,
    animated, immersive break screen**.\
-   All improvements reuse or replace existing elements---no redundant
    new components.\
-   Final UX: Contrast with immersive dive screen → restful surface
    experience.
