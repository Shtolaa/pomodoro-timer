import 'package:cozy_pomodoro/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('switches full app themes from configuration', (tester) async {
    await tester.pumpWidget(const CozyPomodoroApp());

    expect(find.text('Moonlit Pomodoro'), findsOneWidget);
    expect(find.text('18:42'), findsOneWidget);
    expect(find.text('Palette + Type'), findsOneWidget);
    expect(find.text('Peach Cafe'), findsNothing);

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Configuration'), findsOneWidget);
    expect(find.text('App Theme'), findsOneWidget);
    expect(find.text('Cottage Calm'), findsOneWidget);
    expect(find.text('Peach Cafe'), findsOneWidget);
    expect(find.text('Cloud Nap'), findsOneWidget);

    await tester.ensureVisible(find.text('Peach Cafe'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Peach Cafe'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Configuration'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Cafe Pomodoro'), findsOneWidget);
    expect(find.text('Warm focus with a sweet table glow'), findsOneWidget);
  });
}
