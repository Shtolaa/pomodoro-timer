import '../domain/timer_engine.dart';

class TimerNotificationMessage {
  const TimerNotificationMessage({required this.title, required this.body});

  final String title;
  final String body;
}

TimerNotificationMessage sessionTransitionNotificationMessage(
  PomodoroTimerState state,
  PomodoroTimerConfig config,
) {
  final endedSession = _sessionLabel(state.sessionType);
  final startedSession = _sessionLabel(_nextSessionType(state, config));

  return TimerNotificationMessage(
    title: '$endedSession complete',
    body: '$startedSession has auto-started.',
  );
}

PomodoroTimerState? completedSessionForTransition(
  PomodoroTimerState previousState,
  PomodoroTimerState currentState,
) {
  if (previousState.status != PomodoroTimerStatus.running ||
      currentState.status != PomodoroTimerStatus.running ||
      previousState.endsAt == null ||
      currentState.startedAt == null ||
      previousState.sessionType == currentState.sessionType ||
      currentState.startedAt != previousState.endsAt) {
    return null;
  }

  return previousState;
}

PomodoroSessionType _nextSessionType(
  PomodoroTimerState state,
  PomodoroTimerConfig config,
) {
  if (state.sessionType != PomodoroSessionType.focus) {
    return PomodoroSessionType.focus;
  }

  final completedFocusSessions = state.completedFocusSessionsInCycle + 1;
  if (completedFocusSessions >= config.focusSessionsBeforeLongBreak) {
    return PomodoroSessionType.longBreak;
  }

  return PomodoroSessionType.shortBreak;
}

String _sessionLabel(PomodoroSessionType sessionType) {
  return switch (sessionType) {
    PomodoroSessionType.focus => 'Focus session',
    PomodoroSessionType.shortBreak => 'Short break',
    PomodoroSessionType.longBreak => 'Long break',
  };
}
