# FlowPulse

A beautifully fluid focus timer app that helps you maintain peak productivity using the Pomodoro Technique. Built with Flutter for seamless performance across iOS, Android, and Web.

## Features

- **Smooth Animations**: Mesmerizing circular progress indicator with gentle pulse effects
- **Pomodoro Technique**: 25-minute focus sessions, 5-minute energizing breaks
- **Session Management**: Automatic transitions between focus and break periods
- **Modern Design**: Material 3 design with adaptive light/dark themes
- **Cross-Platform**: Native performance on iOS, Android, and Web
- **Fluid Experience**: 60+ FPS animations for a premium feel

## Getting Started

### Prerequisites

- Flutter SDK (3.27.1 or higher)
- Dart SDK
- iOS/Android development environment set up

### Installation

1. Clone the repository:
```bash
git clone https://github.com/dogukanzengin/flow-pulse.git
cd flow_pulse
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For Chrome/Web
flutter run -d chrome

# For iOS Simulator
open -a Simulator
flutter run

# For Android Emulator
flutter emulators --launch <emulator_name>
flutter run

# For physical device
flutter run
```

## Usage

- **Start/Pause**: Tap the large pulsing button to begin your focus session
- **Reset**: Tap the refresh icon to reset the current timer
- **Switch Mode**: Tap the brain/coffee icon to manually toggle between focus and break modes

## Design Philosophy

FlowPulse is designed around the concept of maintaining your flow state while providing gentle visual cues to keep you motivated. The pulsing animation creates a meditative rhythm that helps you stay focused without being distracting.

## App Structure

- `lib/main.dart` - Complete app implementation featuring:
  - Fluid timer logic with state management
  - Custom circular progress painter
  - Smooth animation controllers
  - Session management with completion alerts

## Customization

Adjust session durations by modifying these constants in `main.dart`:
```dart
static const int studyDurationMinutes = 25;  // Focus session length
static const int breakDurationMinutes = 5;   // Break session length
```

## Theme Support

FlowPulse automatically adapts to your system's appearance preferences, providing beautiful light and dark themes using Material 3 design principles.

## Contributing

We welcome contributions! Please feel free to submit issues and enhancement requests.

## License

This project is open source and available under the MIT License.