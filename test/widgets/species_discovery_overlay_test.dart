import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow_pulse/widgets/species_discovery_overlay.dart';
import 'package:flow_pulse/models/creature.dart';

void main() {
  group('Species Discovery Overlay Tests', () {
    late Creature testCreature;

    setUp(() {
      testCreature = const Creature(
        id: 'test_001',
        name: 'Test Clownfish',
        species: 'Amphiprion testicus',
        rarity: CreatureRarity.uncommon,
        type: CreatureType.starterFish,
        habitat: BiomeType.shallowWaters,
        animationAsset: 'animations/clownfish.json',
        pearlValue: 45,
        requiredLevel: 5,
        description: 'A beautiful test clownfish for unit testing purposes.',
        coralPreferences: ['staghorn', 'soft'],
        discoveryChance: 0.20,
      );
    });

    group('SpeciesDiscoveryOverlay Widget', () {
      testWidgets('should render discovery overlay with creature information', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SpeciesDiscoveryOverlay(
              discoveredCreature: testCreature,
              onDismiss: () {},
              onAddToJournal: () {},
            ),
          ),
        );

        await tester.pump();

        // Check if creature name is displayed
        expect(find.text('Test Clownfish'), findsOneWidget);
        
        // Check if scientific name is displayed
        expect(find.text('Amphiprion testicus'), findsOneWidget);
        
        // Check if description is displayed
        expect(find.textContaining('A beautiful test clownfish'), findsOneWidget);
        
        // Check if rarity is displayed
        expect(find.textContaining('Uncommon'), findsOneWidget);
        
        // Check if habitat is displayed
        expect(find.textContaining('Shallow Waters'), findsOneWidget);
        
        // Check if research value is displayed
        expect(find.textContaining('45 XP'), findsOneWidget);
      });

      testWidgets('should display correct rarity indicators', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SpeciesDiscoveryOverlay(
              discoveredCreature: testCreature,
              onDismiss: () {},
            ),
          ),
        );

        await tester.pump();

        // Should show uncommon rarity with 2 stars
        expect(find.text('⭐⭐'), findsOneWidget);
        expect(find.text('🌟 UNCOMMON FIND! 🌟'), findsOneWidget);
      });

      testWidgets('should display correct rarity for different rarities', (WidgetTester tester) async {
        // Test common rarity
        final commonCreature = testCreature.copyWith(rarity: CreatureRarity.common);
        await tester.pumpWidget(
          MaterialApp(
            home: SpeciesDiscoveryOverlay(
              discoveredCreature: commonCreature,
              onDismiss: () {},
            ),
          ),
        );
        await tester.pump();
        
        expect(find.text('⭐'), findsOneWidget);
        expect(find.text('🐠 NEW DISCOVERY! 🐠'), findsOneWidget);

        // Test rare rarity
        final rareCreature = testCreature.copyWith(rarity: CreatureRarity.rare);
        await tester.pumpWidget(
          MaterialApp(
            home: SpeciesDiscoveryOverlay(
              discoveredCreature: rareCreature,
              onDismiss: () {},
            ),
          ),
        );
        await tester.pump();
        
        expect(find.text('⭐⭐⭐'), findsOneWidget);
        expect(find.text('💎 RARE SPECIES! 💎'), findsOneWidget);

        // Test legendary rarity
        final legendaryCreature = testCreature.copyWith(rarity: CreatureRarity.legendary);
        await tester.pumpWidget(
          MaterialApp(
            home: SpeciesDiscoveryOverlay(
              discoveredCreature: legendaryCreature,
              onDismiss: () {},
            ),
          ),
        );
        await tester.pump();
        
        expect(find.text('⭐⭐⭐⭐'), findsOneWidget);
        expect(find.text('✨ LEGENDARY! ✨'), findsOneWidget);
      });

      testWidgets('should call dismiss callback when continue button is tapped', (WidgetTester tester) async {
        bool dismissCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: SpeciesDiscoveryOverlay(
              discoveredCreature: testCreature,
              onDismiss: () => dismissCalled = true,
            ),
          ),
        );

        await tester.pump();

        // Find and tap the continue button
        final continueButton = find.text('Continue Research');
        expect(continueButton, findsOneWidget);
        
        await tester.tap(continueButton);
        await tester.pump();

        expect(dismissCalled, isTrue);
      });

      testWidgets('should call add to journal callback when journal button is tapped', (WidgetTester tester) async {
        bool addToJournalCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: SpeciesDiscoveryOverlay(
              discoveredCreature: testCreature,
              onDismiss: () {},
              onAddToJournal: () => addToJournalCalled = true,
            ),
          ),
        );

        await tester.pump();

        // Find and tap the add to journal button
        final journalButton = find.text('Add to Journal');
        expect(journalButton, findsOneWidget);
        
        await tester.tap(journalButton);
        await tester.pump();

        expect(addToJournalCalled, isTrue);
      });

      testWidgets('should not display journal button when callback is null', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SpeciesDiscoveryOverlay(
              discoveredCreature: testCreature,
              onDismiss: () {},
              // onAddToJournal not provided
            ),
          ),
        );

        await tester.pump();

        expect(find.text('Add to Journal'), findsNothing);
      });

      testWidgets('should display appropriate creature emoji based on habitat', (WidgetTester tester) async {
        // Test different habitats
        final shallowCreature = testCreature.copyWith(habitat: BiomeType.shallowWaters);
        await tester.pumpWidget(
          MaterialApp(
            home: SpeciesDiscoveryOverlay(
              discoveredCreature: shallowCreature,
              onDismiss: () {},
            ),
          ),
        );
        await tester.pump();
        expect(find.text('🐠'), findsOneWidget);

        final coralCreature = testCreature.copyWith(habitat: BiomeType.coralGarden);
        await tester.pumpWidget(
          MaterialApp(
            home: SpeciesDiscoveryOverlay(
              discoveredCreature: coralCreature,
              onDismiss: () {},
            ),
          ),
        );
        await tester.pump();
        expect(find.text('🐟'), findsOneWidget);

        final deepCreature = testCreature.copyWith(habitat: BiomeType.deepOcean);
        await tester.pumpWidget(
          MaterialApp(
            home: SpeciesDiscoveryOverlay(
              discoveredCreature: deepCreature,
              onDismiss: () {},
            ),
          ),
        );
        await tester.pump();
        expect(find.text('🦈'), findsOneWidget);

        final abyssalCreature = testCreature.copyWith(habitat: BiomeType.abyssalZone);
        await tester.pumpWidget(
          MaterialApp(
            home: SpeciesDiscoveryOverlay(
              discoveredCreature: abyssalCreature,
              onDismiss: () {},
            ),
          ),
        );
        await tester.pump();
        expect(find.text('🐙'), findsOneWidget);
      });

      testWidgets('should animate overlay entrance', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SpeciesDiscoveryOverlay(
              discoveredCreature: testCreature,
              onDismiss: () {},
            ),
          ),
        );

        // Initially should be transparent
        await tester.pump(Duration.zero);
        
        // Animation should be in progress
        await tester.pump(const Duration(milliseconds: 100));
        
        // Animation should complete
        await tester.pump(const Duration(milliseconds: 1500));
        
        // Verify the overlay is fully visible
        expect(find.byType(SpeciesDiscoveryOverlay), findsOneWidget);
      });
    });

    group('SpeciesDetectionPanel Widget', () {
      testWidgets('should render detection panel with creature information', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SpeciesDetectionPanel(
                detectedCreature: testCreature,
                estimatedTimeSeconds: 120,
              ),
            ),
          ),
        );

        await tester.pump();

        // Check if detection header is displayed
        expect(find.text('🔍 SPECIES DETECTED'), findsOneWidget);
        
        // Check if creature name is displayed
        expect(find.textContaining('Test Clownfish'), findsOneWidget);
        
        // Check if scientific name is displayed
        expect(find.textContaining('Amphiprion testicus'), findsOneWidget);
        
        // Check if estimated time is displayed
        expect(find.textContaining('02:00'), findsOneWidget);
      });

      testWidgets('should display unknown species when creature is null', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SpeciesDetectionPanel(
                detectedCreature: null,
                estimatedTimeSeconds: 60,
              ),
            ),
          ),
        );

        await tester.pump();

        expect(find.text('Sonar Contact: Unknown Species'), findsOneWidget);
        expect(find.text('Species: Unidentified'), findsOneWidget);
        expect(find.textContaining('01:00'), findsOneWidget);
      });

      testWidgets('should call focus callback when button is tapped', (WidgetTester tester) async {
        bool focusCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SpeciesDetectionPanel(
                detectedCreature: testCreature,
                estimatedTimeSeconds: 30,
                onFocusToApproach: () => focusCalled = true,
              ),
            ),
          ),
        );

        await tester.pump();

        final focusButton = find.text('🎯 Focus to Approach');
        expect(focusButton, findsOneWidget);
        
        await tester.tap(focusButton);
        await tester.pump();

        expect(focusCalled, isTrue);
      });

      testWidgets('should not display focus button when callback is null', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SpeciesDetectionPanel(
                detectedCreature: testCreature,
                estimatedTimeSeconds: 30,
                // onFocusToApproach not provided
              ),
            ),
          ),
        );

        await tester.pump();

        expect(find.text('🎯 Focus to Approach'), findsNothing);
      });

      testWidgets('should format time correctly', (WidgetTester tester) async {
        // Test various time formats
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SpeciesDetectionPanel(
                detectedCreature: testCreature,
                estimatedTimeSeconds: 65, // 1 minute 5 seconds
              ),
            ),
          ),
        );
        await tester.pump();
        expect(find.textContaining('01:05'), findsOneWidget);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SpeciesDetectionPanel(
                detectedCreature: testCreature,
                estimatedTimeSeconds: 3661, // 1 hour 1 minute 1 second
              ),
            ),
          ),
        );
        await tester.pump();
        expect(find.textContaining('61:01'), findsOneWidget);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SpeciesDetectionPanel(
                detectedCreature: testCreature,
                estimatedTimeSeconds: 5, // 5 seconds
              ),
            ),
          ),
        );
        await tester.pump();
        expect(find.textContaining('00:05'), findsOneWidget);
      });

      testWidgets('should animate pulsing effect', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SpeciesDetectionPanel(
                detectedCreature: testCreature,
                estimatedTimeSeconds: 60,
              ),
            ),
          ),
        );

        // Initial render
        await tester.pump();
        
        // Animation should be running
        await tester.pump(const Duration(milliseconds: 750));
        
        // Animation should continue
        await tester.pump(const Duration(milliseconds: 750));
        
        // Verify panel is still visible and animating
        expect(find.byType(SpeciesDetectionPanel), findsOneWidget);
      });
    });

    group('Widget Integration', () {
      testWidgets('should handle widget disposal properly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SpeciesDiscoveryOverlay(
              discoveredCreature: testCreature,
              onDismiss: () {},
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(SpeciesDiscoveryOverlay), findsOneWidget);

        // Navigate away to trigger disposal
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Text('Different Screen'),
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(SpeciesDiscoveryOverlay), findsNothing);
      });

      testWidgets('should handle long creature descriptions', (WidgetTester tester) async {
        final longDescriptionCreature = testCreature.copyWith(
          description: 'This is a very long description that should be properly handled by the widget and not cause any overflow issues. It contains multiple sentences and should test the text overflow behavior of the widget layout system.',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SpeciesDiscoveryOverlay(
              discoveredCreature: longDescriptionCreature,
              onDismiss: () {},
            ),
          ),
        );

        await tester.pump();
        
        // Should not throw any overflow errors
        expect(find.byType(SpeciesDiscoveryOverlay), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle long creature names', (WidgetTester tester) async {
        final longNameCreature = testCreature.copyWith(
          name: 'Super Long Scientific Marine Biology Test Creature Name That Should Not Cause Layout Issues',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SpeciesDiscoveryOverlay(
              discoveredCreature: longNameCreature,
              onDismiss: () {},
            ),
          ),
        );

        await tester.pump();
        // Wait for all animations to complete
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 300));
        
        expect(find.byType(SpeciesDiscoveryOverlay), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}