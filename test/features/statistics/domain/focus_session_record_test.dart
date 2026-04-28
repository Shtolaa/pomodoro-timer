import 'package:cozy_pomodoro/features/presets/domain/preset_color_key.dart';
import 'package:cozy_pomodoro/features/presets/domain/preset_icon_key.dart';
import 'package:cozy_pomodoro/features/presets/domain/timer_preset.dart';
import 'package:cozy_pomodoro/features/statistics/domain/focus_session_record.dart';
import 'package:cozy_pomodoro/features/timer/domain/timer_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final startedAt = DateTime(2026, 4, 28, 9);
  final completedAt = DateTime(2026, 4, 28, 9, 25);

  TimerPreset preset() {
    return TimerPreset(
      id: 3,
      name: 'Deep Work',
      focusDuration: const Duration(minutes: 25),
      shortBreakDuration: const Duration(minutes: 5),
      longBreakDuration: const Duration(minutes: 30),
      sessionsBeforeLongBreak: 4,
      iconKey: PresetIconKey.laptop,
      cardColorKey: PresetColorKey.powderBlue,
      createdAt: DateTime(2026, 4, 28),
      updatedAt: DateTime(2026, 4, 28),
    );
  }

  FocusSessionRecord record({
    int id = 1,
    int? presetId = 3,
    String presetNameSnapshot = 'Deep Work',
    PresetIconKey presetIconSnapshot = PresetIconKey.laptop,
    PresetColorKey presetColorSnapshot = PresetColorKey.powderBlue,
    int durationSeconds = 1500,
  }) {
    return FocusSessionRecord(
      id: id,
      presetId: presetId,
      presetNameSnapshot: presetNameSnapshot,
      presetIconSnapshot: presetIconSnapshot,
      presetColorSnapshot: presetColorSnapshot,
      durationSeconds: durationSeconds,
      startedAt: startedAt,
      completedAt: completedAt,
    );
  }

  test('creates a valid focus session record', () {
    final focusRecord = record();

    expect(focusRecord.id, 1);
    expect(focusRecord.presetId, 3);
    expect(focusRecord.presetNameSnapshot, 'Deep Work');
    expect(focusRecord.durationSeconds, 1500);
  });

  test('validates record fields', () {
    expect(() => record(id: 0), throwsAssertionError);
    expect(() => record(presetId: 0), throwsAssertionError);
    expect(() => record(presetNameSnapshot: '  '), throwsAssertionError);
    expect(() => record(durationSeconds: 0), throwsAssertionError);
    expect(
      () => FocusSessionRecord(
        id: 1,
        presetId: 1,
        presetNameSnapshot: 'Broken',
        presetIconSnapshot: PresetIconKey.book,
        presetColorSnapshot: PresetColorKey.peach,
        durationSeconds: 60,
        startedAt: completedAt,
        completedAt: startedAt,
      ),
      throwsAssertionError,
    );
  });

  test('calculates next record id without reuse', () {
    expect(nextFocusSessionRecordId([]), 1);
    expect(nextFocusSessionRecordId([record(id: 2), record(id: 7)]), 8);
  });

  test('summarizes totals and preset breakdowns', () {
    final records = [
      record(id: 1, durationSeconds: 1500),
      record(id: 2, durationSeconds: 900),
      record(
        id: 3,
        presetId: 4,
        presetNameSnapshot: 'Reading',
        presetIconSnapshot: PresetIconKey.book,
        presetColorSnapshot: PresetColorKey.honey,
        durationSeconds: 1800,
      ),
    ];

    final summaries = focusSessionSummariesByPreset(records);

    expect(completedFocusSessionCount(records), 3);
    expect(totalFocusDuration(records), const Duration(minutes: 70));
    expect(summaries, hasLength(2));
    expect(summaries.first.presetNameSnapshot, 'Deep Work');
    expect(summaries.first.sessionsCompleted, 2);
    expect(summaries.first.totalDuration, const Duration(minutes: 40));
    expect(summaries.last.presetNameSnapshot, 'Reading');
    expect(summaries.last.sessionsCompleted, 1);
  });

  test('records only completed focus sessions during elapsed timer advance',
      () {
    final config = PomodoroTimerConfig(
      focusDuration: const Duration(minutes: 25),
      shortBreakDuration: const Duration(minutes: 5),
      longBreakDuration: const Duration(minutes: 30),
      focusSessionsBeforeLongBreak: 4,
    );
    final running = PomodoroTimerState(
      sessionType: PomodoroSessionType.focus,
      status: PomodoroTimerStatus.running,
      startedAt: startedAt,
      endsAt: completedAt,
      pausedRemaining: config.focusDuration,
      completedFocusSessionsInCycle: 0,
    );

    final records = focusSessionRecordsCompletedBy(
      running,
      completedAt.add(config.shortBreakDuration).add(config.focusDuration),
      config: config,
      preset: preset(),
      existingRecords: const [],
    );

    expect(records, hasLength(2));
    expect(records.every((record) => record.presetNameSnapshot == 'Deep Work'),
        isTrue);
  });

  test('does not record completed break sessions', () {
    final config = PomodoroTimerConfig(
      focusDuration: const Duration(minutes: 25),
      shortBreakDuration: const Duration(minutes: 5),
      longBreakDuration: const Duration(minutes: 30),
      focusSessionsBeforeLongBreak: 4,
    );
    final breakStartedAt = completedAt;
    final breakState = PomodoroTimerState(
      sessionType: PomodoroSessionType.shortBreak,
      status: PomodoroTimerStatus.running,
      startedAt: breakStartedAt,
      endsAt: breakStartedAt.add(config.shortBreakDuration),
      pausedRemaining: config.shortBreakDuration,
      completedFocusSessionsInCycle: 1,
    );

    final records = focusSessionRecordsCompletedBy(
      breakState,
      breakStartedAt.add(config.shortBreakDuration),
      config: config,
      preset: preset(),
      existingRecords: const [],
    );

    expect(records, isEmpty);
  });

  test('deduplicates already-recorded focus sessions', () {
    final config = PomodoroTimerConfig(
      focusDuration: const Duration(minutes: 25),
      shortBreakDuration: const Duration(minutes: 5),
      longBreakDuration: const Duration(minutes: 30),
      focusSessionsBeforeLongBreak: 4,
    );
    final running = PomodoroTimerState(
      sessionType: PomodoroSessionType.focus,
      status: PomodoroTimerStatus.running,
      startedAt: startedAt,
      endsAt: completedAt,
      pausedRemaining: config.focusDuration,
      completedFocusSessionsInCycle: 0,
    );

    final records = focusSessionRecordsCompletedBy(
      running,
      completedAt,
      config: config,
      preset: preset(),
      existingRecords: [record()],
    );

    expect(records, isEmpty);
  });

  test('uses configured focus duration for restored or resumed sessions', () {
    final config = PomodoroTimerConfig(
      focusDuration: const Duration(minutes: 25),
      shortBreakDuration: const Duration(minutes: 5),
      longBreakDuration: const Duration(minutes: 30),
      focusSessionsBeforeLongBreak: 4,
    );
    final resumedAt = DateTime(2026, 4, 28, 9, 10);
    final endsAt = DateTime(2026, 4, 28, 9, 25);
    final running = PomodoroTimerState(
      sessionType: PomodoroSessionType.focus,
      status: PomodoroTimerStatus.running,
      startedAt: resumedAt,
      endsAt: endsAt,
      pausedRemaining: const Duration(minutes: 15),
      completedFocusSessionsInCycle: 0,
    );

    final records = focusSessionRecordsCompletedBy(
      running,
      endsAt,
      config: config,
      preset: preset(),
      existingRecords: const [],
    );

    expect(records.single.durationSeconds, 1500);
    expect(records.single.startedAt, DateTime(2026, 4, 28, 9));
    expect(records.single.completedAt, endsAt);
  });
}
