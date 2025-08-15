import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow_pulse/widgets/dive_computer_widget.dart';

void main() {
  group('DiveComputerWidget Tests', () {
    testWidgets('should display dive computer information correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiveComputerWidget(
              currentDepthMeters: 15,
              targetDepthMeters: 25,
              oxygenTimeSeconds: 1800, // 30 minutes
              isDiving: true,
              diveStatus: 'Diving',
              depthProgress: 0.6,
            ),
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify that the dive computer displays correct information
      expect(find.text('DIVE COMPUTER'), findsOneWidget);
      expect(find.text('Current: 15m'), findsOneWidget);
      expect(find.text('Target: 25m'), findsOneWidget);
      expect(find.text('O₂ Time: 30:00'), findsOneWidget);
      expect(find.text('Diving'), findsOneWidget);
    });

    testWidgets('should show low oxygen warning', (WidgetTester tester) async {
      // Build the widget with low oxygen
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiveComputerWidget(
              currentDepthMeters: 20,
              targetDepthMeters: 25,
              oxygenTimeSeconds: 240, // 4 minutes - should trigger warning
              isDiving: true,
              diveStatus: 'Diving',
              depthProgress: 0.8,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify low oxygen display
      expect(find.text('O₂ Time: 04:00'), findsOneWidget);
    });

    testWidgets('should handle surface status correctly', (WidgetTester tester) async {
      // Build the widget at surface
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiveComputerWidget(
              currentDepthMeters: 0,
              targetDepthMeters: 25,
              oxygenTimeSeconds: 1500,
              isDiving: false,
              diveStatus: 'Surface',
              depthProgress: 0.0,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify surface status
      expect(find.text('Current: 0m'), findsOneWidget);
      expect(find.text('Surface'), findsOneWidget);
    });

    testWidgets('should display depth gauge correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiveComputerWidget(
              currentDepthMeters: 10,
              targetDepthMeters: 20,
              oxygenTimeSeconds: 1200,
              isDiving: true,
              diveStatus: 'Diving',
              depthProgress: 0.5,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Allow more time for animations and custom painters to complete
      await tester.pumpAndSettle();

      // Verify depth gauge shows 50% (the text is rendered by CustomPaint)
      expect(find.text('50%'), findsOneWidget);
    });
  });
}