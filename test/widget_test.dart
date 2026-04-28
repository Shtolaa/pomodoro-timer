import 'package:cozy_pomodoro/app/cozy_pomodoro_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('switches full app themes from configuration', (tester) async {
    await tester.pumpWidget(const CozyPomodoroApp());

    expect(find.text('Moonlit Pomodoro'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Palette + Type'), findsOneWidget);
    expect(find.text('Peach Cafe'), findsNothing);

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Configuration'), findsOneWidget);
    expect(find.text('App Theme'), findsOneWidget);
    expect(find.text('Timer Preset'), findsOneWidget);
    expect(find.text('Standard Pomodoro'), findsOneWidget);
    expect(find.text('25 min focus'), findsOneWidget);
    expect(find.text('5 min break'), findsOneWidget);
    expect(find.text('30 min long rest'), findsOneWidget);
    expect(find.text('4 sessions'), findsOneWidget);
    expect(find.text('Cottage Calm'), findsOneWidget);
    expect(find.text('Peach Cafe'), findsOneWidget);
    expect(find.text('Cloud Nap'), findsOneWidget);

    await tester.ensureVisible(find.text('Peach Cafe'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Peach Cafe'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Configuration'));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text('Configuration'))).pop();
    await tester.pumpAndSettle();

    expect(find.text('Cafe Pomodoro'), findsOneWidget);
    expect(find.text('Warm focus with a sweet table glow'), findsOneWidget);
  });

  testWidgets('shows standard pomodoro preset in configuration',
      (tester) async {
    await tester.pumpWidget(const CozyPomodoroApp());

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Timer Preset'), findsOneWidget);
    expect(find.text('Standard Pomodoro'), findsOneWidget);
    expect(find.text('Classic 25/5 focus rhythm with a generous long rest.'),
        findsOneWidget);
    expect(find.text('25 min focus'), findsOneWidget);
    expect(find.text('5 min break'), findsOneWidget);
    expect(find.text('30 min long rest'), findsOneWidget);
    expect(find.text('4 sessions'), findsOneWidget);

    await tester.ensureVisible(find.text('Standard Pomodoro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Standard Pomodoro'));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text('Configuration'))).pop();
    await tester.pumpAndSettle();

    expect(find.text('25:00'), findsOneWidget);
  });
}
