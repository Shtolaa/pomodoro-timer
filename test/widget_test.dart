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
    expect(
      tester.getTopLeft(find.text('Timer Preset')).dy,
      lessThan(tester.getTopLeft(find.text('App Theme')).dy),
    );
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
    expect(find.text('25/5 rhythm with 30 min long rests.'), findsOneWidget);
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

  testWidgets('creates a preset and makes it active', (tester) async {
    await tester.pumpWidget(const CozyPomodoroApp());

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('New'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Morning Pages');
    await tester.enterText(find.byType(TextFormField).at(1), '12');
    await tester.enterText(find.byType(TextFormField).at(2), '3');
    await tester.enterText(find.byType(TextFormField).at(3), '9');
    await tester.enterText(find.byType(TextFormField).at(4), '2');
    await tester.ensureVisible(find.text('Create preset'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create preset'));
    await tester.pumpAndSettle();

    expect(find.text('Morning Pages'), findsOneWidget);
    expect(find.text('12 min focus'), findsOneWidget);
    expect(find.text('3 min break'), findsOneWidget);
    expect(find.text('9 min long rest'), findsOneWidget);
    expect(find.text('2 sessions'), findsOneWidget);

    Navigator.of(tester.element(find.text('Configuration'))).pop();
    await tester.pumpAndSettle();

    expect(find.text('12:00'), findsOneWidget);
  });

  testWidgets('edits a preset and resets the active timer', (tester) async {
    await tester.pumpWidget(const CozyPomodoroApp());

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byTooltip('Edit Standard Pomodoro'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit Standard Pomodoro'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Deep Reading');
    await tester.enterText(find.byType(TextFormField).at(1), '40');
    await tester.enterText(find.byType(TextFormField).at(2), '8');
    await tester.enterText(find.byType(TextFormField).at(3), '20');
    await tester.enterText(find.byType(TextFormField).at(4), '3');
    await tester.ensureVisible(find.text('Save preset'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save preset'));
    await tester.pumpAndSettle();

    expect(find.text('Deep Reading'), findsOneWidget);
    expect(find.text('40 min focus'), findsOneWidget);
    expect(find.text('8 min break'), findsOneWidget);
    expect(find.text('20 min long rest'), findsOneWidget);
    expect(find.text('3 sessions'), findsOneWidget);

    Navigator.of(tester.element(find.text('Configuration'))).pop();
    await tester.pumpAndSettle();

    expect(find.text('40:00'), findsOneWidget);
  });

  testWidgets('deletes a preset and hides it from selection', (tester) async {
    await tester.pumpWidget(const CozyPomodoroApp());

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('New'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Tiny Sprint');
    await tester.enterText(find.byType(TextFormField).at(1), '10');
    await tester.enterText(find.byType(TextFormField).at(2), '2');
    await tester.enterText(find.byType(TextFormField).at(3), '6');
    await tester.enterText(find.byType(TextFormField).at(4), '2');
    await tester.ensureVisible(find.text('Create preset'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create preset'));
    await tester.pumpAndSettle();

    expect(find.text('Tiny Sprint'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Delete Tiny Sprint'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete Tiny Sprint'));
    await tester.pumpAndSettle();

    expect(find.text('Delete "Tiny Sprint"?'), findsOneWidget);
    expect(find.text('Tiny Sprint'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Tiny Sprint'), findsNothing);
    expect(find.text('Standard Pomodoro'), findsOneWidget);
  });

  testWidgets('does not offer delete when only one active preset remains',
      (tester) async {
    await tester.pumpWidget(const CozyPomodoroApp());

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    expect(
      find.byTooltip('Delete unavailable: only one preset remains'),
      findsOneWidget,
    );
    expect(find.byTooltip('Delete Standard Pomodoro'), findsNothing);
  });
}
