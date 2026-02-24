// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:th2_smart_note/main.dart';
import 'package:th2_smart_note/viewmodels/note_viewmodel.dart';

// Top-level test subclass to avoid local-class extension issues in test runner
class TestNoteViewModel extends NoteViewModel {
  @override
  Future<void> loadNotes() async {
    // no-op for tests
  }
}

void main() {
  // Lightweight test subclass moved to top-level to avoid local class issues
  // (ensures subclassing works across libraries during tests)
  // See: TestNoteViewModel below.

  testWidgets('App builds and shows home title and FAB',
      (WidgetTester tester) async {
    // Build the app wrapped with the provider used in production
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<NoteViewModel>(
              create: (_) => TestNoteViewModel()),
        ],
        child: const SmartNoteApp(),
      ),
    );

    // Let any post-frame callbacks run
    await tester.pumpAndSettle();

    // Verify app bar title exists and FAB is present
    expect(find.textContaining('Smart Note'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
