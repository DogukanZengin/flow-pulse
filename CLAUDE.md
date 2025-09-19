# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

### Build and run
```bash
# Run the app on a connected device/simulator
flutter run

# Build for specific platforms
flutter build ios
flutter build android
flutter build web
```

### Code quality
```bash
# Run static analysis
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/models/aquarium_test.dart

# Run tests with coverage
flutter test --coverage
```

### Dependencies
```bash
# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade
```

## Architecture Overview

### Core Architecture Pattern
**FlowPulse** is a Flutter productivity app using an ocean-themed gamification system. The app follows a service-based architecture with:

- **Provider State Management**: Single `TimerProvider` for app-wide timer state
- **Singleton Services**: Core services (GamificationService, PersistenceService, etc.) use singleton pattern
- **Research Points (RP) System**: Complex leveling system based on session quality, not just duration
- **Depth-Based Progression**: Users traverse ocean depths (Shallow Waters → Coral Garden → Deep Ocean → Abyssal Zone) based on cumulative RP

### Key Architectural Components

#### Services Layer (`lib/services/`)
- **GamificationService**: Central RP and progression management, streak tracking, achievement unlocks
- **PersistenceService**: SQLite database management for session data, achievements, and user progress
- **Marine Biology Services**: Career progression, creature discovery, research papers - all tied to RP system
- **Mission Service**: Task-based challenges that award RP
- **Depth Traversal Service**: Manages ocean depth progression based on RP thresholds
- **Platform Services**: NotificationService, LiveActivitiesService (iOS), BackgroundTimerService

#### Models (`lib/models/`)
- **ResearchPoints**: Core RP calculation model with quality multipliers, streak bonuses
- **SessionQuality**: Enum-based quality assessment (perfect, excellent, good, poor, abandoned)
- **Marine Biology Models**: Creature, Career, Equipment models that unlock based on RP

#### State Management
- **Provider Pattern**: Used sparingly - only TimerProvider for timer state
- **Service Singletons**: Most state managed through singleton services
- **SharedPreferences**: Settings and lightweight persistence

### Important Implementation Details

#### RP System Complexity
The Research Points system is the core of the app. Key aspects:
- Base RP calculated from session duration: `minutes / 25 * 10`
- Quality multipliers modify base RP (perfect=1.2x, excellent=1.1x, etc.)
- Bonus RP from: streak maintenance, break adherence, perfect sessions
- Daily RP cap at 300 to prevent exploitation
- Cumulative RP never decreases, used for career progression

#### Current Refactoring Context
The codebase is transitioning from duration-based depth access to RP-based progression. See `flowpulse_hybrid_leveling_implementation_plan.md` for details. Key changes involve:
- Removing direct session-duration-to-depth mapping
- Implementing RP thresholds for depth zones
- Adding mission system for varied progression paths

#### Platform Considerations
- **Web Support**: Conditional imports for platform features (notifications, background tasks)
- **iOS Live Activities**: Widget integration for real-time timer display
- **Background Timer**: Efficient background service to maintain timer state

### Critical Files to Understand

1. **lib/services/gamification_service.dart**: Core RP and progression logic
2. **lib/models/research_points.dart**: RP calculation and validation
3. **lib/services/persistence/persistence_service.dart**: Database schema and operations
4. **lib/services/depth_traversal_service.dart**: Ocean depth progression
5. **lib/providers/timer_provider.dart**: Timer state management

## Development Guidelines

### When modifying RP calculations
- Always check `ResearchPointsConstants` for thresholds and limits
- Ensure calculations respect daily caps and anti-exploitation measures
- Update both GamificationService and related UI components

### When adding new features
- Follow singleton pattern for services
- Use dependency injection through service instances
- Ensure web compatibility with platform checks (`!kIsWeb`)

### Database migrations
- PersistenceService handles schema versioning
- Add migration logic in `_onUpgrade` method
- Test migrations thoroughly with existing user data

### Testing approach
- Unit tests for models and RP calculations
- Mock services using Mockito
- Test files follow naming convention: `*_test.dart`