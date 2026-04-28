import 'package:cozy_pomodoro/app/cozy_pomodoro_app.dart';
import 'package:cozy_pomodoro/app/local_pomodoro_storage.dart';
import 'package:cozy_pomodoro/features/app_theme/domain/pomodoro_theme.dart';
import 'package:cozy_pomodoro/features/presets/domain/preset_color_key.dart';
import 'package:cozy_pomodoro/features/presets/domain/preset_icon_key.dart';
import 'package:cozy_pomodoro/features/presets/domain/timer_preset.dart';
import 'package:cozy_pomodoro/features/timer/data/timer_state_codec.dart';
import 'package:cozy_pomodoro/features/timer/domain/timer_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  TimerPreset standardPreset({DateTime? deletedAt}) {
    return TimerPreset(
      id: 1,
      name: 'Standard Pomodoro',
      focusDuration: const Duration(minutes: 25),
      shortBreakDuration: const Duration(minutes: 5),
      longBreakDuration: const Duration(minutes: 30),
      sessionsBeforeLongBreak: 4,
      iconKey: PresetIconKey.book,
      cardColorKey: PresetColorKey.peach,
      createdAt: DateTime(2026, 4, 28),
      updatedAt: deletedAt ?? DateTime(2026, 4, 28),
      deletedAt: deletedAt,
    );
  }

  TimerPreset customPreset({DateTime? deletedAt}) {
    return TimerPreset(
      id: 2,
      name: 'Saved Flow',
      focusDuration: const Duration(minutes: 12),
      shortBreakDuration: const Duration(minutes: 3),
      longBreakDuration: const Duration(minutes: 9),
      sessionsBeforeLongBreak: 2,
      iconKey: PresetIconKey.palette,
      cardColorKey: PresetColorKey.lavender,
      createdAt: DateTime(2026, 4, 28, 9),
      updatedAt: deletedAt ?? DateTime(2026, 4, 28, 9),
      deletedAt: deletedAt,
    );
  }

  Future<void> seedStorage({
    PomodoroThemeOption? theme,
    List<TimerPreset>? presets,
    int? activePresetId,
    PersistedTimerState? timerState,
  }) async {
    final storage = await LocalPomodoroStorage.load();
    if (theme != null) {
      await storage.saveSelectedTheme(theme);
    }
    if (presets != null) {
      await storage.savePresets(presets);
    }
    if (activePresetId != null) {
      await storage.saveActivePresetId(activePresetId);
    }
    if (timerState != null) {
      await storage.saveTimerState(timerState);
    }
  }

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

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const CozyPomodoroApp());
    await tester.pumpAndSettle();

    expect(find.text('12:00'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Morning Pages'), findsOneWidget);
    expect(find.text('12 min focus'), findsOneWidget);
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

  testWidgets('reloads saved theme', (tester) async {
    await seedStorage(theme: PomodoroThemeOption.themes[2]);

    await tester.pumpWidget(const CozyPomodoroApp());
    await tester.pumpAndSettle();

    expect(find.text('Cafe Pomodoro'), findsOneWidget);
    expect(find.text('Warm focus with a sweet table glow'), findsOneWidget);
  });

  testWidgets('reloads saved preset and active timer duration', (tester) async {
    await seedStorage(
      presets: [standardPreset(), customPreset()],
      activePresetId: 2,
    );

    await tester.pumpWidget(const CozyPomodoroApp());
    await tester.pumpAndSettle();

    expect(find.text('12:00'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Saved Flow'), findsOneWidget);
    expect(find.text('12 min focus'), findsOneWidget);
    expect(find.text('3 min break'), findsOneWidget);
    expect(find.text('9 min long rest'), findsOneWidget);
  });

  testWidgets('hides soft-deleted persisted presets after reload',
      (tester) async {
    final deletedAt = DateTime(2026, 4, 29, 9);
    await seedStorage(
      presets: [standardPreset(), customPreset(deletedAt: deletedAt)],
      activePresetId: 1,
    );

    await tester.pumpWidget(const CozyPomodoroApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Standard Pomodoro'), findsOneWidget);
    expect(find.text('Saved Flow'), findsNothing);

    final storage = await LocalPomodoroStorage.load();
    expect(storage.loadPresets()!.last.deletedAt, deletedAt);
  });

  testWidgets('keeps delete disabled after reload with one active preset',
      (tester) async {
    await seedStorage(
      presets: [
        standardPreset(),
        customPreset(deletedAt: DateTime(2026, 4, 29, 9)),
      ],
      activePresetId: 1,
    );

    await tester.pumpWidget(const CozyPomodoroApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    expect(
      find.byTooltip('Delete unavailable: only one preset remains'),
      findsOneWidget,
    );
  });

  testWidgets('reloads paused timer state without background catch-up',
      (tester) async {
    await seedStorage(
      presets: [standardPreset()],
      activePresetId: 1,
      timerState: PersistedTimerState(
        activePresetId: 1,
        state: PomodoroTimerState(
          sessionType: PomodoroSessionType.focus,
          status: PomodoroTimerStatus.paused,
          startedAt: null,
          endsAt: null,
          pausedRemaining: const Duration(minutes: 10),
          completedFocusSessionsInCycle: 0,
        ),
      ),
    );

    await tester.pumpWidget(const CozyPomodoroApp());
    await tester.pumpAndSettle();

    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
  });

  testWidgets('reloads running timer remaining time without catch-up',
      (tester) async {
    final savedAt = DateTime(2026, 4, 28, 9);
    await seedStorage(
      presets: [standardPreset()],
      activePresetId: 1,
      timerState: PersistedTimerState(
        activePresetId: 1,
        state: PomodoroTimerState(
          sessionType: PomodoroSessionType.focus,
          status: PomodoroTimerStatus.running,
          startedAt: savedAt,
          endsAt: savedAt.add(const Duration(minutes: 10)),
          pausedRemaining: const Duration(minutes: 10),
          completedFocusSessionsInCycle: 0,
        ),
      ),
    );

    await tester.pumpWidget(const CozyPomodoroApp());
    await tester.pump();

    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);
  });
}
