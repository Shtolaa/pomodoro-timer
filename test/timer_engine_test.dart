import 'package:cozy_pomodoro/features/timer/domain/timer_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final config = PomodoroTimerConfig(
    focusDuration: Duration(minutes: 25),
    shortBreakDuration: Duration(minutes: 5),
    longBreakDuration: Duration(minutes: 15),
    focusSessionsBeforeLongBreak: 4,
  );
  final engine = PomodoroTimerEngine(config: config);
  final now = DateTime(2026, 4, 28, 9);

  test('validates configured durations are positive', () {
    expect(
      () => PomodoroTimerConfig(focusDuration: Duration.zero),
      throwsAssertionError,
    );
    expect(
      () => PomodoroTimerConfig(shortBreakDuration: Duration.zero),
      throwsAssertionError,
    );
    expect(
      () => PomodoroTimerConfig(longBreakDuration: Duration.zero),
      throwsAssertionError,
    );
    expect(
      () => PomodoroTimerConfig(focusDuration: const Duration(seconds: -1)),
      throwsAssertionError,
    );
    expect(
      () => PomodoroTimerConfig(
        shortBreakDuration: const Duration(seconds: -1),
      ),
      throwsAssertionError,
    );
    expect(
      () => PomodoroTimerConfig(
        longBreakDuration: const Duration(seconds: -1),
      ),
      throwsAssertionError,
    );
  });

  test('formats remaining time with ceil-style seconds', () {
    expect(formatRemainingForDisplay(const Duration(minutes: 25)), '25:00');
    expect(
      formatRemainingForDisplay(
        const Duration(minutes: 24, seconds: 59, milliseconds: 1),
      ),
      '25:00',
    );
    expect(
      formatRemainingForDisplay(
        const Duration(minutes: 24, seconds: 58, milliseconds: 999),
      ),
      '24:59',
    );
    expect(formatRemainingForDisplay(Duration.zero), '00:00');
    expect(
        formatRemainingForDisplay(const Duration(milliseconds: -1)), '00:00');
  });

  test('starts a focus countdown', () {
    final state = engine.start(engine.initialState(), now);

    expect(state.sessionType, PomodoroSessionType.focus);
    expect(state.status, PomodoroTimerStatus.running);
    expect(state.startedAt, now);
    expect(state.endsAt, now.add(config.focusDuration));
    expect(state.remainingAt(now.add(const Duration(minutes: 3)), config),
        const Duration(minutes: 22));
  });

  test('pauses and preserves remaining time', () {
    final running = engine.start(engine.initialState(), now);
    final paused = engine.pause(running, now.add(const Duration(minutes: 7)));

    expect(paused.status, PomodoroTimerStatus.paused);
    expect(paused.pausedRemaining, const Duration(minutes: 18));
    expect(paused.remainingAt(now.add(const Duration(minutes: 20)), config),
        const Duration(minutes: 18));
  });

  test('resumes from paused remaining time', () {
    final running = engine.start(engine.initialState(), now);
    final paused = engine.pause(running, now.add(const Duration(minutes: 7)));
    final resumed = engine.resume(paused, now.add(const Duration(minutes: 10)));

    expect(resumed.status, PomodoroTimerStatus.running);
    expect(resumed.startedAt, now.add(const Duration(minutes: 10)));
    expect(resumed.endsAt, now.add(const Duration(minutes: 28)));
  });

  test('resets to idle focus session', () {
    final running = engine.start(engine.initialState(), now);
    final reset = engine.reset(running);

    expect(reset.sessionType, PomodoroSessionType.focus);
    expect(reset.status, PomodoroTimerStatus.idle);
    expect(reset.pausedRemaining, config.focusDuration);
    expect(reset.completedFocusSessionsInCycle, 0);
    expect(reset.startedAt, isNull);
    expect(reset.endsAt, isNull);
  });

  test('auto-starts short break after completed focus session', () {
    final running = engine.start(engine.initialState(), now);
    final advanced = engine.advanceTo(running, now.add(config.focusDuration));

    expect(advanced.sessionType, PomodoroSessionType.shortBreak);
    expect(advanced.status, PomodoroTimerStatus.running);
    expect(advanced.startedAt, now.add(config.focusDuration));
    expect(advanced.endsAt,
        now.add(config.focusDuration).add(config.shortBreakDuration));
    expect(advanced.completedFocusSessionsInCycle, 1);
  });

  test('auto-starts focus after completed break', () {
    final running = engine.start(engine.initialState(), now);
    final breakState = engine.advanceTo(running, now.add(config.focusDuration));
    final focusState = engine.advanceTo(
      breakState,
      now.add(config.focusDuration).add(config.shortBreakDuration),
    );

    expect(focusState.sessionType, PomodoroSessionType.focus);
    expect(focusState.status, PomodoroTimerStatus.running);
    expect(focusState.completedFocusSessionsInCycle, 1);
  });

  test('auto-starts long break after configured focus sessions', () {
    var state = engine.start(engine.initialState(), now);
    var cursor = now;

    for (var i = 0; i < config.focusSessionsBeforeLongBreak - 1; i += 1) {
      cursor = cursor.add(config.focusDuration);
      state = engine.advanceTo(state, cursor);
      expect(state.sessionType, PomodoroSessionType.shortBreak);

      cursor = cursor.add(config.shortBreakDuration);
      state = engine.advanceTo(state, cursor);
      expect(state.sessionType, PomodoroSessionType.focus);
    }

    cursor = cursor.add(config.focusDuration);
    state = engine.advanceTo(state, cursor);

    expect(state.sessionType, PomodoroSessionType.longBreak);
    expect(state.status, PomodoroTimerStatus.running);
    expect(state.completedFocusSessionsInCycle, 0);
  });

  test('advances through multiple auto-started sessions after time jump', () {
    final running = engine.start(engine.initialState(), now);
    final advanced = engine.advanceTo(
      running,
      now
          .add(config.focusDuration)
          .add(config.shortBreakDuration)
          .add(const Duration(minutes: 2)),
    );

    expect(advanced.sessionType, PomodoroSessionType.focus);
    expect(advanced.status, PomodoroTimerStatus.running);
    expect(advanced.completedFocusSessionsInCycle, 1);
    expect(
        advanced.remainingAt(
          now
              .add(config.focusDuration)
              .add(config.shortBreakDuration)
              .add(const Duration(minutes: 2)),
          config,
        ),
        const Duration(minutes: 23));
  });
}
