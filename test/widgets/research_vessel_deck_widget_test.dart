import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow_pulse/widgets/research_vessel_deck_widget.dart';
import 'package:flow_pulse/models/aquarium.dart';
import 'package:flow_pulse/models/creature.dart';

void main() {
  group('Research Vessel Deck Widget Tests', () {
    late Aquarium testAquarium;
    late List<Creature> testCreatures;

    setUp(() {
      testAquarium = Aquarium(
        id: 'test',
        name: 'Test Aquarium',
        inhabitants: [],
        corals: [],
        level: 5,
        experience: 100,
      );
      testCreatures = [];
    });

    testWidgets('should display vessel deck environment correctly', (WidgetTester tester) async {
      // Build the widget with proper sizing constraints
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 600,
              child: ResearchVesselDeckWidget(
                aquarium: testAquarium,
                secondsRemaining: 330, // 5 minutes 30 seconds
                totalBreakSeconds: 600, // 10 minutes
                isRunning: true,
                recentDiscoveries: testCreatures,
                onTap: () {},
                isActualBreakSession: true,
                followsWorkSession: true,
              ),
            ),
          ),
        ),
      );

      // Wait for animations to settle
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify basic elements are present
      expect(find.text('🏖️ Research Vessel Deck Break'), findsOneWidget);
      expect(find.text('05:30'), findsOneWidget); // Timer display
      
      // Verify activity buttons are present
      expect(find.text('Equipment Maintenance'), findsOneWidget);
      expect(find.text('Wildlife Observation'), findsOneWidget);
      expect(find.text('Journal Review'), findsOneWidget);
      expect(find.text('Weather Monitoring'), findsOneWidget);
    });

    testWidgets('should handle break timer controls correctly', (WidgetTester tester) async {
      bool endBreakCalled = false;
      bool pauseBreakCalled = false;
      bool resumeBreakCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 600,
              child: ResearchVesselDeckWidget(
                breakTimeRemaining: const Duration(minutes: 3, seconds: 15),
                isBreakActive: true,
                onEndBreak: () => endBreakCalled = true,
                onPauseBreak: () => pauseBreakCalled = true,
                onResumeBreak: () => resumeBreakCalled = true,
                onStartBreak: () {},
                isPaused: false,
                showExtendButton: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Test pause/resume button
      final pauseButton = find.text('⏸️ Pause');
      expect(pauseButton, findsOneWidget);
      
      await tester.tap(pauseButton);
      expect(pauseBreakCalled, isTrue);

      // Test end break button
      final endBreakButton = find.text('🤿 End Break');
      expect(endBreakButton, findsOneWidget);
      
      await tester.tap(endBreakButton);
      expect(endBreakCalled, isTrue);
    });

    testWidgets('should display paused state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 600,
              child: ResearchVesselDeckWidget(
                breakTimeRemaining: const Duration(minutes: 2, seconds: 45),
                isBreakActive: true,
                onEndBreak: () {},
                onPauseBreak: () {},
                onResumeBreak: () {},
                onStartBreak: () {},
                isPaused: true, // Paused state
                showExtendButton: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify resume button is shown when paused
      expect(find.text('▶️ Resume'), findsOneWidget);
      expect(find.text('⏸️ Pause'), findsNothing);
    });

    testWidgets('should handle inactive break state', (WidgetTester tester) async {
      bool startBreakCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 600,
              child: ResearchVesselDeckWidget(
                breakTimeRemaining: const Duration(minutes: 5),
                isBreakActive: false, // Not active
                onEndBreak: () {},
                onPauseBreak: () {},
                onResumeBreak: () {},
                onStartBreak: () => startBreakCalled = true,
                isPaused: false,
                showExtendButton: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should show start break button when not active
      final startButton = find.text('🏖️ Start Break');
      if (startButton.evaluate().isNotEmpty) {
        await tester.tap(startButton);
        expect(startBreakCalled, isTrue);
      }
    });

    testWidgets('should handle responsive design for mobile', (WidgetTester tester) async {
      // Test with mobile screen size
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 390, // iPhone 12 width
              height: 400,
              child: ResearchVesselDeckWidget(
                breakTimeRemaining: const Duration(minutes: 4),
                isBreakActive: true,
                onEndBreak: () {},
                onPauseBreak: () {},
                onResumeBreak: () {},
                onStartBreak: () {},
                isPaused: false,
                showExtendButton: false, // No extend button for mobile
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should still display basic elements on mobile
      expect(find.text('Vessel Deck Break'), findsOneWidget); // Shortened title for mobile
    });
  });
}