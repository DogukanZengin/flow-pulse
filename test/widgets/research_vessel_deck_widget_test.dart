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
        currentBiome: BiomeType.shallowWaters,
        inhabitants: [],
        corals: [],
        pearlWallet: const PearlWallet(pearls: 100, crystals: 0),
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
        settings: const AquariumSettings(),
        stats: const AquariumStats(
          totalCreaturesDiscovered: 0,
          totalCoralsGrown: 0,
          totalFocusTime: 0,
          currentStreak: 0,
          longestStreak: 0,
        ),
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

    testWidgets('should handle break timer display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 600,
              child: ResearchVesselDeckWidget(
                aquarium: testAquarium,
                secondsRemaining: 195, // 3 minutes 15 seconds
                totalBreakSeconds: 300, // 5 minutes total
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

      await tester.pump();

      // Test timer display
      expect(find.text('03:15'), findsOneWidget);
      
      // Test progress bar exists
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should display paused state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 600,
              child: ResearchVesselDeckWidget(
                aquarium: testAquarium,
                secondsRemaining: 165, // 2 minutes 45 seconds
                totalBreakSeconds: 300, // 5 minutes
                isRunning: false, // Paused state
                recentDiscoveries: testCreatures,
                onTap: () {},
                isActualBreakSession: true,
                followsWorkSession: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify paused timer display
      expect(find.text('02:45'), findsOneWidget);
    });

    testWidgets('should handle activity buttons state correctly', (WidgetTester tester) async {
      bool activityCompleted = false;
      String? completedActivity;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 600,
              child: ResearchVesselDeckWidget(
                aquarium: testAquarium,
                secondsRemaining: 300, // 5 minutes
                totalBreakSeconds: 300, // 5 minutes
                isRunning: true,
                recentDiscoveries: testCreatures,
                onTap: () {},
                onActivityComplete: (activity) {
                  activityCompleted = true;
                  completedActivity = activity;
                },
                isActualBreakSession: true,
                followsWorkSession: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Find and tap an activity button
      final equipmentButton = find.widgetWithText(ElevatedButton, 'Equipment Maintenance');
      expect(equipmentButton, findsOneWidget);
      
      await tester.tap(equipmentButton);
      await tester.pump();
      
      expect(activityCompleted, isTrue);
      expect(completedActivity, equals('equipment'));
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
                aquarium: testAquarium,
                secondsRemaining: 240, // 4 minutes
                totalBreakSeconds: 300, // 5 minutes
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

      await tester.pump();

      // Should still display basic elements on mobile
      expect(find.text('Vessel Deck Break'), findsOneWidget); // Shortened title for mobile
      expect(find.text('04:00'), findsOneWidget);
    });

    testWidgets('should handle not actual break session state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 600,
              child: ResearchVesselDeckWidget(
                aquarium: testAquarium,
                secondsRemaining: 300,
                totalBreakSeconds: 300,
                isRunning: true,
                recentDiscoveries: testCreatures,
                onTap: () {},
                isActualBreakSession: false, // Not an actual break
                followsWorkSession: false,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Activities should be disabled when not an actual break session
      final equipmentButton = find.widgetWithText(ElevatedButton, 'Equipment Maintenance');
      expect(equipmentButton, findsOneWidget);
      
      // The button should be disabled (we can check its enabled state)
      final ElevatedButton button = tester.widget(equipmentButton);
      expect(button.onPressed, isNull); // Disabled buttons have null onPressed
    });
  });
}