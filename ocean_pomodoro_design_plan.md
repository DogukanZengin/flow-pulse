# Ocean/Aquarium Pomodoro App - Design Plan

## 🌊 App Overview

**Theme**: Deep Sea Focus - Build thriving coral reefs and collect marine life through focused work sessions
**Core Mechanic**: Each completed Pomodoro session grows coral and attracts new sea creatures to your aquarium
**Failure Mechanic**: Abandoned sessions cause pollution that dims colors and makes creatures flee

## 📱 App Structure

### Core Screens
1. **Main Aquarium View** - Primary screen showing your underwater ecosystem
2. **Timer Screen** - Focus session with growing coral animation
3. **Collection Screen** - Gallery of discovered marine life
4. **Shop Screen** - Purchase new species, decorations, and upgrades
5. **Settings Screen** - Timer customization and app preferences
6. **Progress Screen** - Statistics, achievements, and streaks

## 🎮 Core Gameplay Loop

### Session Flow
1. **Start Session** → Choose coral type to grow
2. **Focus Time** → Watch coral slowly grow with particle effects
3. **Session Complete** → Coral blooms, attracts new marine life
4. **Break Time** → Gentle wave animations, creatures swimming peacefully
5. **Reward** → Unlock new species, earn pearls (currency), gain XP

### Progression System
- **Shallow Waters** (Level 1-10): Basic fish, simple coral
- **Coral Gardens** (Level 11-25): Colorful reef fish, anemones
- **Deep Ocean** (Level 26-50): Sharks, rays, bioluminescent creatures
- **Abyssal Zone** (Level 51+): Mythical sea creatures, underwater cities

## 🐠 Marine Life Collection System

### Creature Categories

#### **Starter Fish (Level 1-5)**
- Clownfish, Angelfish, Tangs
- Appear frequently, low pearl value
- Serve as aquarium "population base"

#### **Reef Builders (Level 6-15)**
- Sea Anemones, Cleaner Wrasse, Parrotfish
- Help maintain coral health
- Provide small daily pearl bonuses

#### **Predators (Level 16-30)**
- Reef Sharks, Moray Eels, Octopus
- Rare appearances, high pearl value
- Require multiple successful sessions to attract

#### **Deep Sea Dwellers (Level 31-45)**
- Manta Rays, Whale Sharks, Bioluminescent Jellyfish
- Spectacular animations and effects
- Unlock special abilities and bonuses

#### **Mythical Creatures (Level 46+)**
- Sea Dragons, Kraken, Mermaids, Atlantean Guardians
- Extremely rare, game-changing rewards
- Require perfect focus streaks to encounter

### Creature Rarity System
- **Common** (70%): Basic reef fish, standard pearls
- **Uncommon** (20%): Interesting species, 2x pearls
- **Rare** (8%): Beautiful/unique creatures, 5x pearls
- **Legendary** (2%): Mythical beings, 10x pearls + special effects

## 🪸 Coral Growth Mechanics

### Coral Types (Each provides different benefits)
- **Brain Coral**: +25% focus session XP
- **Staghorn Coral**: Attracts small fish faster
- **Table Coral**: Provides shelter for larger species
- **Soft Coral**: Creates beautiful particle effects
- **Fire Coral**: Deters negative pollution effects

### Growth Stages
1. **Polyp** (0-25%): Tiny bump on reef floor
2. **Juvenile** (26-50%): Small coral formation
3. **Mature** (51-75%): Full-sized, colorful coral
4. **Flourishing** (76-100%): Particle effects, attracts rare species

## 💎 Currency & Economy

### Pearl System (Primary Currency)
- **Earned by**: Completing sessions, creature discoveries, daily bonuses
- **Spent on**: New coral seeds, aquarium decorations, creature food
- **Exchange rates**: 
  - 25-min session = 10 pearls
  - New species discovery = 50-500 pearls
  - Daily login bonus = 25 pearls

### Rare Crystals (Premium Currency)
- **Earned by**: Achievements, perfect weeks, rare creature encounters
- **Spent on**: Legendary creatures, premium decorations, time skips
- **Can be purchased**: Via in-app purchases

## 🎨 Visual Design Guidelines

### Color Palette
- **Primary Blues**: Deep ocean (#0077BE), Tropical (#00A6D6), Light blue (#87CEEB)
- **Coral Accents**: Coral pink (#FF7F7F), Orange (#FF8C00), Purple (#DDA0DD)
- **Neutral Tones**: Sandy beige (#F5DEB3), Pearl white (#F8F8F8)
- **Pollution Effects**: Murky brown (#8B4513), Sickly green (#9ACD32)

### Animation Principles
- **Fluid Motion**: All movement should feel underwater (slower, flowing)
- **Particle Effects**: Bubbles, plankton, light rays filtering down
- **Breathing UI**: Gentle pulsing for buttons and coral growth
- **Parallax Scrolling**: Multiple depth layers for immersion

### UI Design Language
- **Organic Shapes**: Rounded corners, flowing lines, avoid harsh angles
- **Glass Morphism**: Semi-transparent panels with blur effects
- **Depth Layering**: Clear foreground/background separation
- **Gentle Shadows**: Soft, diffused lighting throughout

## 🚀 Flutter Implementation Plan

### Project Structure
```
lib/
├── main.dart
├── models/
│   ├── creature.dart
│   ├── coral.dart
│   ├── user_progress.dart
│   └── session.dart
├── screens/
│   ├── aquarium_screen.dart
│   ├── timer_screen.dart
│   ├── collection_screen.dart
│   ├── shop_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── animated_creature.dart
│   ├── coral_growth_widget.dart
│   ├── timer_display.dart
│   └── background_animation.dart
├── services/
│   ├── timer_service.dart
│   ├── progress_service.dart
│   └── notification_service.dart
├── animations/
│   ├── swimming_animations.dart
│   ├── particle_system.dart
│   └── coral_growth_animations.dart
└── utils/
    ├── constants.dart
    ├── theme.dart
    └── helpers.dart
```

### Key Dependencies
```yaml
dependencies:
  flutter: sdk: flutter
  provider: ^6.0.5           # State management
  shared_preferences: ^2.0.15 # Data persistence
  flutter_local_notifications: ^13.0.0 # Session reminders
  lottie: ^2.3.2            # Complex animations
  audioplayers: ^4.1.0      # Ocean sounds/effects
  flutter_animate: ^4.2.0   # Easy animations
  flame: ^1.7.3             # Game engine for particles
```

### Core Models

#### Creature Model
```dart
class Creature {
  final String id;
  final String name;
  final String species;
  final CreatureRarity rarity;
  final CreatureType type;
  final String animationAsset;
  final List<String> habitats;
  final int pearlValue;
  final bool isDiscovered;
  final DateTime? discoveredAt;
}
```

#### Coral Model
```dart
class Coral {
  final String id;
  final CoralType type;
  final CoralStage stage;
  final double growthProgress;
  final DateTime plantedAt;
  final bool isHealthy;
  final List<String> attractedSpecies;
}
```

## 🎯 Key Features Implementation

### 1. Animated Aquarium Background
- **Parallax scrolling** with multiple depth layers
- **Particle system** for bubbles and floating plankton
- **Dynamic lighting** that changes based on time of day
- **Coral swaying** animations with subtle movement

### 2. Timer Integration
- **Visual coral growth** during focus sessions
- **Pollution effects** when sessions are abandoned
- **Creature attraction** based on session completion
- **Peaceful break animations** between work periods

### 3. Collection & Discovery System
- **Pokédex-style** creature collection interface
- **Photography mode** for discovered creatures
- **Rarity indicators** with special visual effects
- **Discovery celebrations** with particle effects

### 4. Progression & Achievements
- **Level-based unlocks** for new biomes and creatures
- **Streak tracking** with visual indicators
- **Achievement system** with pearl rewards
- **Daily challenges** for engagement

## 📊 Gamification Elements

### Achievement Categories
- **Consistency**: "Deep Diver" (7-day streak), "Ocean Explorer" (30-day streak)
- **Discovery**: "Marine Biologist" (50 species), "Creature Whisperer" (rare encounters)
- **Building**: "Reef Builder" (100 corals), "Ecosystem Architect" (complete biomes)
- **Focus**: "Zen Master" (100 perfect sessions), "Deep Focus" (2+ hour sessions)

### Social Features
- **Aquarium sharing** with friends
- **Daily creature of the day** global event
- **Leaderboards** for longest streaks and rarest collections
- **Collaborative coral reef** where all users contribute

## 🔊 Audio Design

### Ambient Sounds
- **Gentle wave sounds** during work sessions
- **Bubble effects** for UI interactions
- **Whale songs** for deep ocean levels
- **Coral reef ambiance** with subtle fish sounds

### Feedback Sounds
- **Success chimes** (like sonar pings) for completed sessions
- **Discovery jingles** for new creatures
- **Warning sounds** (like submarine alerts) for abandoned sessions
- **Peaceful bell tones** for break time

## 📈 Analytics & Progression Tracking

### User Metrics
- **Focus session completion rate**
- **Average session length and quality**
- **Creature discovery rate and preferences**
- **Feature engagement and retention**

### Progression Indicators
- **Ecosystem health score** (0-100%)
- **Species diversity index**
- **Coral garden maturity level**
- **Weekly/monthly focus statistics**

## 🚀 Development Phases

### Phase 1: Core Functionality (2-3 weeks)
- Basic timer with simple coral growth
- Fundamental creature collection system
- Essential screens and navigation
- Local data persistence

### Phase 2: Visual Polish (2-3 weeks)
- Advanced animations and particle effects
- Beautiful creature swimming behaviors
- Polished UI with ocean theme
- Sound effects and ambient audio

### Phase 3: Gamification (2-3 weeks)
- Achievement system implementation
- Advanced progression mechanics
- Social features and sharing
- Push notifications and reminders

### Phase 4: Advanced Features (2-3 weeks)
- Mythical creatures and special events
- Premium features and monetization
- Advanced analytics and optimization
- Beta testing and feedback integration

## 💡 Unique Selling Points

1. **Immersive underwater experience** with realistic marine ecosystem
2. **Scientific accuracy** in creature behaviors and coral growth
3. **Meditation-like focus** with calming ocean ambiance
4. **Educational value** teaching marine biology through gameplay
5. **Stunning visuals** that make productivity beautiful and engaging

This design plan provides a comprehensive roadmap for building an engaging ocean-themed Pomodoro app that transforms focus sessions into an underwater adventure!