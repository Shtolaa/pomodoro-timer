import 'package:cozy_pomodoro/features/timer/data/timer_state_codec.dart';
import 'package:cozy_pomodoro/features/timer/domain/timer_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes and deserializes timer state', () {
    final startedAt = DateTime(2026, 4, 28, 9);
    final state = PomodoroTimerState(
      sessionType: PomodoroSessionType.shortBreak,
      status: PomodoroTimerStatus.running,
      startedAt: startedAt,
      endsAt: startedAt.add(const Duration(minutes: 5)),
      pausedRemaining: const Duration(minutes: 4),
      completedFocusSessionsInCycle: 2,
    );

    final decoded = decodeTimerState(
      encodeTimerState(PersistedTimerState(activePresetId: 3, state: state)),
    );

    expect(decoded!.activePresetId, 3);
    expect(decoded.state.sessionType, PomodoroSessionType.shortBreak);
    expect(decoded.state.status, PomodoroTimerStatus.running);
    expect(decoded.state.startedAt, startedAt);
    expect(decoded.state.endsAt, startedAt.add(const Duration(minutes: 5)));
    expect(decoded.state.pausedRemaining, const Duration(minutes: 4));
    expect(decoded.state.completedFocusSessionsInCycle, 2);
  });
}
