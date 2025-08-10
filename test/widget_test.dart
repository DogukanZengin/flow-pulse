// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:flow_pulse/main.dart';

void main() {
  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory. 
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('FlowPulse app loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FlowPulseApp());
    
    // Wait for providers to initialize
    await tester.pump();

    // Verify that our timer app loads correctly
    expect(find.text('FlowPulse'), findsOneWidget);
  });
}
