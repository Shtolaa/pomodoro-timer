import 'dart:convert';

import '../../presets/data/timer_preset_codec.dart';
import '../domain/timer_engine.dart';

class PersistedTimerState {
  const PersistedTimerState(
      {required this.activePresetId, required this.state});

  final int activePresetId;
  final PomodoroTimerState state;
}

String encodeTimerState(PersistedTimerState timerState) {
  return jsonEncode(timerStateToJson(timerState));
}

PersistedTimerState? decodeTimerState(String value) {
  try {
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, Object?>) {
      return null;
    }
    return timerStateFromJson(decoded);
  } catch (_) {
    return null;
  }
}

Map<String, Object?> timerStateToJson(PersistedTimerState timerState) {
  final state = timerState.state;
  return {
    'activePresetId': timerState.activePresetId,
    'sessionType': state.sessionType.name,
    'status': state.status.name,
    'startedAt': state.startedAt?.toIso8601String(),
    'endsAt': state.endsAt?.toIso8601String(),
    'pausedRemainingSeconds': state.pausedRemaining.inSeconds,
    'completedFocusSessionsInCycle': state.completedFocusSessionsInCycle,
  };
}

PersistedTimerState? timerStateFromJson(Map<String, Object?> json) {
  try {
    final activePresetId = json['activePresetId'];
    final sessionType =
        enumByName(PomodoroSessionType.values, json['sessionType']);
    final status = enumByName(PomodoroTimerStatus.values, json['status']);
    final startedAt = parseNullableDateTime(json['startedAt']);
    final endsAt = parseNullableDateTime(json['endsAt']);
    final pausedRemainingSeconds = json['pausedRemainingSeconds'];
    final completedFocusSessionsInCycle = json['completedFocusSessionsInCycle'];

    if (activePresetId is! int ||
        sessionType == null ||
        status == null ||
        pausedRemainingSeconds is! int ||
        completedFocusSessionsInCycle is! int ||
        pausedRemainingSeconds <= 0 ||
        completedFocusSessionsInCycle < 0) {
      return null;
    }

    return PersistedTimerState(
      activePresetId: activePresetId,
      state: PomodoroTimerState(
        sessionType: sessionType,
        status: status,
        startedAt: status == PomodoroTimerStatus.running ? startedAt : null,
        endsAt: status == PomodoroTimerStatus.running ? endsAt : null,
        pausedRemaining: Duration(seconds: pausedRemainingSeconds),
        completedFocusSessionsInCycle: completedFocusSessionsInCycle,
      ),
    );
  } catch (_) {
    return null;
  }
}
