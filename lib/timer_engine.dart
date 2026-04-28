enum PomodoroSessionType { focus, shortBreak, longBreak }

enum PomodoroTimerStatus { idle, running, paused }

class PomodoroTimerConfig {
  const PomodoroTimerConfig({
    this.focusDuration = const Duration(minutes: 25),
    this.shortBreakDuration = const Duration(minutes: 5),
    this.longBreakDuration = const Duration(minutes: 15),
    this.focusSessionsBeforeLongBreak = 4,
  }) : assert(focusSessionsBeforeLongBreak > 0);

  final Duration focusDuration;
  final Duration shortBreakDuration;
  final Duration longBreakDuration;
  final int focusSessionsBeforeLongBreak;

  Duration durationFor(PomodoroSessionType sessionType) {
    return switch (sessionType) {
      PomodoroSessionType.focus => focusDuration,
      PomodoroSessionType.shortBreak => shortBreakDuration,
      PomodoroSessionType.longBreak => longBreakDuration,
    };
  }
}

class PomodoroTimerState {
  const PomodoroTimerState({
    required this.sessionType,
    required this.status,
    required this.startedAt,
    required this.endsAt,
    required this.pausedRemaining,
    required this.completedFocusSessionsInCycle,
  });

  factory PomodoroTimerState.initial(PomodoroTimerConfig config) {
    return PomodoroTimerState(
      sessionType: PomodoroSessionType.focus,
      status: PomodoroTimerStatus.idle,
      startedAt: null,
      endsAt: null,
      pausedRemaining: config.focusDuration,
      completedFocusSessionsInCycle: 0,
    );
  }

  final PomodoroSessionType sessionType;
  final PomodoroTimerStatus status;
  final DateTime? startedAt;
  final DateTime? endsAt;
  final Duration pausedRemaining;
  final int completedFocusSessionsInCycle;

  Duration totalDuration(PomodoroTimerConfig config) {
    return config.durationFor(sessionType);
  }

  Duration remainingAt(DateTime now, PomodoroTimerConfig config) {
    if (status != PomodoroTimerStatus.running || endsAt == null) {
      return pausedRemaining;
    }

    final remaining = endsAt!.difference(now);
    if (remaining.isNegative) {
      return Duration.zero;
    }
    return remaining;
  }

  double progressAt(DateTime now, PomodoroTimerConfig config) {
    final total = totalDuration(config).inMilliseconds;
    if (total <= 0) {
      return 1;
    }

    final remaining = remainingAt(now, config).inMilliseconds.clamp(0, total);
    return 1 - (remaining / total);
  }

  PomodoroTimerState copyWith({
    PomodoroSessionType? sessionType,
    PomodoroTimerStatus? status,
    DateTime? startedAt,
    DateTime? endsAt,
    Duration? pausedRemaining,
    int? completedFocusSessionsInCycle,
    bool clearStartedAt = false,
    bool clearEndsAt = false,
  }) {
    return PomodoroTimerState(
      sessionType: sessionType ?? this.sessionType,
      status: status ?? this.status,
      startedAt: clearStartedAt ? null : startedAt ?? this.startedAt,
      endsAt: clearEndsAt ? null : endsAt ?? this.endsAt,
      pausedRemaining: pausedRemaining ?? this.pausedRemaining,
      completedFocusSessionsInCycle:
          completedFocusSessionsInCycle ?? this.completedFocusSessionsInCycle,
    );
  }
}

class PomodoroTimerEngine {
  const PomodoroTimerEngine({this.config = const PomodoroTimerConfig()});

  final PomodoroTimerConfig config;

  PomodoroTimerState initialState() => PomodoroTimerState.initial(config);

  PomodoroTimerState start(PomodoroTimerState state, DateTime now) {
    if (state.status == PomodoroTimerStatus.running) {
      return advanceTo(state, now);
    }

    final duration = config.durationFor(state.sessionType);
    return state.copyWith(
      status: PomodoroTimerStatus.running,
      startedAt: now,
      endsAt: now.add(duration),
      pausedRemaining: duration,
    );
  }

  PomodoroTimerState pause(PomodoroTimerState state, DateTime now) {
    final advanced = advanceTo(state, now);
    if (advanced.status != PomodoroTimerStatus.running) {
      return advanced;
    }

    return advanced.copyWith(
      status: PomodoroTimerStatus.paused,
      pausedRemaining: advanced.remainingAt(now, config),
      clearStartedAt: true,
      clearEndsAt: true,
    );
  }

  PomodoroTimerState resume(PomodoroTimerState state, DateTime now) {
    if (state.status != PomodoroTimerStatus.paused) {
      return state;
    }

    return state.copyWith(
      status: PomodoroTimerStatus.running,
      startedAt: now,
      endsAt: now.add(state.pausedRemaining),
    );
  }

  PomodoroTimerState reset(PomodoroTimerState state) {
    return PomodoroTimerState.initial(config);
  }

  PomodoroTimerState advanceTo(PomodoroTimerState state, DateTime now) {
    if (state.status != PomodoroTimerStatus.running || state.endsAt == null) {
      return state;
    }

    var current = state;
    var nextStart = current.endsAt!;

    while (!now.isBefore(current.endsAt!)) {
      final nextSession = _nextSessionAfter(current);
      current = current.copyWith(
        sessionType: nextSession.sessionType,
        status: PomodoroTimerStatus.running,
        startedAt: nextStart,
        endsAt: nextStart.add(config.durationFor(nextSession.sessionType)),
        pausedRemaining: config.durationFor(nextSession.sessionType),
        completedFocusSessionsInCycle:
            nextSession.completedFocusSessionsInCycle,
      );
      nextStart = current.endsAt!;
    }

    return current;
  }

  ({PomodoroSessionType sessionType, int completedFocusSessionsInCycle})
      _nextSessionAfter(PomodoroTimerState state) {
    if (state.sessionType != PomodoroSessionType.focus) {
      return (
        sessionType: PomodoroSessionType.focus,
        completedFocusSessionsInCycle: state.completedFocusSessionsInCycle,
      );
    }

    final completedFocusSessions = state.completedFocusSessionsInCycle + 1;
    if (completedFocusSessions >= config.focusSessionsBeforeLongBreak) {
      return (
        sessionType: PomodoroSessionType.longBreak,
        completedFocusSessionsInCycle: 0,
      );
    }

    return (
      sessionType: PomodoroSessionType.shortBreak,
      completedFocusSessionsInCycle: completedFocusSessions,
    );
  }
}
