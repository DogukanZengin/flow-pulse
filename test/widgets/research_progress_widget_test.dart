import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flow_pulse/widgets/research_progress_widget.dart';
import 'package:flow_pulse/providers/timer_provider.dart';
import 'package:flow_pulse/services/gamification_service.dart';

void main() {
  group('ResearchProgressWidget Tests', () {
    setUp(() async {
      // Initialize gamification service for tests
      await GamificationService.instance.initialize();
    });

    testWidgets('should display research progress information correctly', (WidgetTester tester) async {
      // Build the widget with providers
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => TimerProvider(),
          child: MaterialApp(
            home: Scaffold(
              body: ResearchProgressWidget(
                speciesDiscovered: 8,
                totalSpeciesInCurrentBiome: 15,
                researchPapersPublished: 3,
                certificationProgress: 0.75,
              ),
            ),
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify that the research progress displays correct information
      expect(find.text('RESEARCH PROGRESS'), findsOneWidget);
      expect(find.text('Species: 8/15'), findsOneWidget);
      expect(find.text('Papers: 3'), findsOneWidget);
      expect(find.text('Next Cert: 75%'), findsOneWidget);
    });

    testWidgets('should show correct researcher title for different levels', (WidgetTester tester) async {
      // Build widget for low level
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => TimerProvider(),
          child: MaterialApp(
            home: Scaffold(
              body: ResearchProgressWidget(
                speciesDiscovered: 2,
                totalSpeciesInCurrentBiome: 10,
                researchPapersPublished: 0,
                certificationProgress: 0.25,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Should show beginner title for low levels
      expect(find.textContaining('Snorkeling Enthusiast'), findsOneWidget);
    });

    testWidgets('should handle empty species discovery', (WidgetTester tester) async {
      // Build widget with no discoveries
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => TimerProvider(),
          child: MaterialApp(
            home: Scaffold(
              body: ResearchProgressWidget(
                speciesDiscovered: 0,
                totalSpeciesInCurrentBiome: 12,
                researchPapersPublished: 0,
                certificationProgress: 0.0,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify zero state
      expect(find.text('Species: 0/12'), findsOneWidget);
      expect(find.text('Papers: 0'), findsOneWidget);
      expect(find.text('Next Cert: 0%'), findsOneWidget);
    });

    testWidgets('should display progress bars correctly', (WidgetTester tester) async {
      // Build widget with partial progress
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => TimerProvider(),
          child: MaterialApp(
            home: Scaffold(
              body: ResearchProgressWidget(
                speciesDiscovered: 6,
                totalSpeciesInCurrentBiome: 10,
                researchPapersPublished: 2,
                certificationProgress: 0.6,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Find progress indicators
      final progressIndicators = find.byType(LinearProgressIndicator);
      expect(progressIndicators, findsNWidgets(2)); // Species and certification progress
    });
  });
}