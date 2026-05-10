// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inatel_app_challenge/core/app_widget.dart';

void main() {
  testWidgets('renders account type chooser', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AppWidget());

    expect(find.textContaining('Choose a Account'), findsOneWidget);
    expect(find.text('Installer'), findsOneWidget);
    expect(find.text('User'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('starts in installer mode and toggles to user mode',
      (tester) async {
    await tester.pumpWidget(const AppWidget());

    final switchFinder = find.byType(CupertinoSwitch);
    expect(tester.widget<CupertinoSwitch>(switchFinder).value, isFalse);

    await tester.tap(switchFinder);
    await tester.pump();

    expect(tester.widget<CupertinoSwitch>(switchFinder).value, isTrue);
  });
}
