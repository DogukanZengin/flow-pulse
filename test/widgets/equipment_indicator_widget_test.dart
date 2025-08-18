import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow_pulse/widgets/equipment_indicator_widget.dart';

void main() {
  group('Equipment Indicator Widget Tests', () {
    testWidgets('should display equipment grid', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EquipmentIndicatorWidget(
              userLevel: 25,
              unlockedEquipment: ['mask', 'fins', 'scuba_gear'],
              showCertifications: true,
            ),
          ),
        ),
      );

      expect(find.byType(EquipmentIndicatorWidget), findsOneWidget);
      expect(find.text('Research Equipment'), findsOneWidget);
    });

    testWidgets('should show certifications when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EquipmentIndicatorWidget(
              userLevel: 50,
              unlockedEquipment: [],
              showCertifications: true,
            ),
          ),
        ),
      );

      expect(find.text('Certifications'), findsOneWidget);
    });

    testWidgets('should hide certifications when disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EquipmentIndicatorWidget(
              userLevel: 10,
              unlockedEquipment: [],
              showCertifications: false,
            ),
          ),
        ),
      );

      expect(find.text('Certifications'), findsNothing);
    });

    testWidgets('should display correct level information', (WidgetTester tester) async {
      const testLevel = 42;
      const testEquipmentCount = 5;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EquipmentIndicatorWidget(
              userLevel: testLevel,
              unlockedEquipment: ['item1', 'item2', 'item3', 'item4', 'item5'],
              showCertifications: false,
            ),
          ),
        ),
      );

      expect(find.text('Level $testLevel • $testEquipmentCount items'), findsOneWidget);
    });

    testWidgets('should handle low level user', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EquipmentIndicatorWidget(
              userLevel: 1,
              unlockedEquipment: [],
              showCertifications: true,
            ),
          ),
        ),
      );

      expect(find.text('No certifications earned yet'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('should handle high level user', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EquipmentIndicatorWidget(
              userLevel: 100,
              unlockedEquipment: [],
              showCertifications: true,
            ),
          ),
        ),
      );

      await tester.pump();

      // Should show multiple certifications for high level user
      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('should animate equipment items', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EquipmentIndicatorWidget(
              userLevel: 20,
              unlockedEquipment: [],
              showCertifications: false,
            ),
          ),
        ),
      );

      // Wait for animations to settle
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('should handle empty equipment list', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EquipmentIndicatorWidget(
              userLevel: 15,
              unlockedEquipment: [],
              showCertifications: true,
            ),
          ),
        ),
      );

      expect(find.text('Level 15 • 0 items'), findsOneWidget);
    });

    group('Equipment Data Tests', () {
      testWidgets('should display equipment grid items', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EquipmentIndicatorWidget(
                userLevel: 50,
                unlockedEquipment: [],
                showCertifications: false,
              ),
            ),
          ),
        );

        // Should find equipment grid
        expect(find.byType(GridView), findsOneWidget);
        
        // Should find multiple equipment items
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('should show unlocked equipment differently', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EquipmentIndicatorWidget(
                userLevel: 30,
                unlockedEquipment: [],
                showCertifications: false,
              ),
            ),
          ),
        );

        await tester.pump();

        // Equipment items should be rendered
        expect(find.byType(Icon), findsWidgets);
      });
    });

    group('Certification Badge Tests', () {
      testWidgets('should display earned certifications', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EquipmentIndicatorWidget(
                userLevel: 75,
                unlockedEquipment: [],
                showCertifications: true,
              ),
            ),
          ),
        );

        await tester.pump();

        // Should show certification badges
        expect(find.byType(Wrap), findsOneWidget);
      });

      testWidgets('should animate certification badges', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EquipmentIndicatorWidget(
                userLevel: 50,
                unlockedEquipment: [],
                showCertifications: true,
              ),
            ),
          ),
        );

        // Let animations run for a bit
        await tester.pump(const Duration(seconds: 1));

        expect(find.byType(AnimatedBuilder), findsWidgets);
      });
    });

    group('Performance Tests', () {
      testWidgets('should handle rapid level changes', (WidgetTester tester) async {
        Widget buildWidget(int level) {
          return MaterialApp(
            home: Scaffold(
              body: EquipmentIndicatorWidget(
                userLevel: level,
                unlockedEquipment: [],
                showCertifications: true,
              ),
            ),
          );
        }

        for (int level = 1; level <= 100; level += 10) {
          await tester.pumpWidget(buildWidget(level));
          await tester.pump();
        }

        // Should complete without errors
        expect(find.byType(EquipmentIndicatorWidget), findsOneWidget);
      });

      testWidgets('should handle many equipment items', (WidgetTester tester) async {
        final manyItems = List.generate(50, (index) => 'item_$index');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EquipmentIndicatorWidget(
                userLevel: 100,
                unlockedEquipment: manyItems,
                showCertifications: true,
              ),
            ),
          ),
        );

        expect(find.text('Level 100 • 50 items'), findsOneWidget);
      });
    });

    group('Edge Case Tests', () {
      testWidgets('should handle level 0', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EquipmentIndicatorWidget(
                userLevel: 0,
                unlockedEquipment: [],
                showCertifications: true,
              ),
            ),
          ),
        );

        expect(find.text('Level 0 • 0 items'), findsOneWidget);
        expect(find.text('No certifications earned yet'), findsOneWidget);
      });

      testWidgets('should handle maximum level', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EquipmentIndicatorWidget(
                userLevel: 999,
                unlockedEquipment: [],
                showCertifications: true,
              ),
            ),
          ),
        );

        expect(find.text('Level 999 • 0 items'), findsOneWidget);
      });

      testWidgets('should handle widget rebuild', (WidgetTester tester) async {
        const key = Key('equipment_widget');

        Widget buildWidget(int level) {
          return MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 600,
                child: EquipmentIndicatorWidget(
                  key: key,
                  userLevel: level,
                  unlockedEquipment: [],
                  showCertifications: true,
                ),
              ),
            ),
          );
        }

        await tester.pumpWidget(buildWidget(10));
        await tester.pump();
        expect(find.text('Level 10 • 0 items'), findsOneWidget);

        await tester.pumpWidget(buildWidget(25));
        await tester.pump();
        expect(find.text('Level 25 • 0 items'), findsOneWidget);

        await tester.pumpWidget(buildWidget(50));
        await tester.pump();
        expect(find.text('Level 50 • 0 items'), findsOneWidget);
      });
    });
  });
}