import 'package:cozy_pomodoro/features/timer/data/timer_notification_message.dart';
import 'package:cozy_pomodoro/features/timer/domain/timer_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final config = PomodoroTimerConfig(
    focusDuration: const Duration(minutes: 25),
    shortBreakDuration: const Duration(minutes: 5),
    longBreakDuration: const Duration(minutes: 30),
    focusSessionsBeforeLongBreak: 4,
  );

  PomodoroTimerState runningSession({
    required PomodoroSessionType sessionType,
    int completedFocusSessionsInCycle = 0,
  }) {
    final now = DateTime(2026, 4, 28, 9);
    return PomodoroTimerState(
      sessionType: sessionType,
      status: PomodoroTimerStatus.running,
      startedAt: now,
      endsAt: now.add(config.durationFor(sessionType)),
      pausedRemaining: config.durationFor(sessionType),
      completedFocusSessionsInCycle: completedFocusSessionsInCycle,
    );
  }

  test('describes focus to short break transition', () {
    final message = sessionTransitionNotificationMessage(
      runningSession(sessionType: PomodoroSessionType.focus),
      config,
    );

    expect(message.title, 'Focus session complete');
    expect(message.body, 'Short break has auto-started.');
  });

  test('describes focus to long break transition', () {
    final message = sessionTransitionNotificationMessage(
      runningSession(
        sessionType: PomodoroSessionType.focus,
        completedFocusSessionsInCycle: 3,
      ),
      config,
    );

    expect(message.title, 'Focus session complete');
    expect(message.body, 'Long break has auto-started.');
  });

  test('describes break to focus transition', () {
    final message = sessionTransitionNotificationMessage(
      runningSession(sessionType: PomodoroSessionType.shortBreak),
      config,
    );

    expect(message.title, 'Short break complete');
    expect(message.body, 'Focus session has auto-started.');
  });

  test('detects completed session for an auto-start transition', () {
    final previous = runningSession(sessionType: PomodoroSessionType.focus);
    final current = PomodoroTimerState(
      sessionType: PomodoroSessionType.shortBreak,
      status: PomodoroTimerStatus.running,
      startedAt: previous.endsAt,
      endsAt: previous.endsAt!.add(config.shortBreakDuration),
      pausedRemaining: config.shortBreakDuration,
      completedFocusSessionsInCycle: 1,
    );

    expect(completedSessionForTransition(previous, current), previous);
  });

  test('does not detect transition for start or resume', () {
    final previous = PomodoroTimerState.initial(config);
    final current = runningSession(sessionType: PomodoroSessionType.focus);

    expect(completedSessionForTransition(previous, current), isNull);
  });

  test('does not detect transition when session did not change', () {
    final previous = runningSession(sessionType: PomodoroSessionType.focus);
    final current = previous.copyWith(
      startedAt: DateTime(2026, 4, 28, 9, 1),
      endsAt: DateTime(2026, 4, 28, 9, 26),
    );

    expect(completedSessionForTransition(previous, current), isNull);
  });
}
