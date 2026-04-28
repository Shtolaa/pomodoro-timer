import '../../presets/domain/preset_color_key.dart';
import '../../presets/domain/preset_icon_key.dart';
import '../../presets/domain/timer_preset.dart';
import '../../timer/domain/timer_engine.dart';

class FocusSessionRecord {
  FocusSessionRecord({
    required this.id,
    required this.presetId,
    required this.presetNameSnapshot,
    required this.presetIconSnapshot,
    required this.presetColorSnapshot,
    required this.durationSeconds,
    required this.startedAt,
    required this.completedAt,
  })  : assert(id > 0),
        assert(presetId == null || presetId > 0),
        assert(presetNameSnapshot.trim().isNotEmpty),
        assert(durationSeconds > 0),
        assert(!completedAt.isBefore(startedAt));

  final int id;
  final int? presetId;
  final String presetNameSnapshot;
  final PresetIconKey presetIconSnapshot;
  final PresetColorKey presetColorSnapshot;
  final int durationSeconds;
  final DateTime startedAt;
  final DateTime completedAt;
}

class FocusSessionPresetSummary {
  const FocusSessionPresetSummary({
    required this.presetId,
    required this.presetNameSnapshot,
    required this.presetIconSnapshot,
    required this.presetColorSnapshot,
    required this.sessionsCompleted,
    required this.totalDuration,
  });

  final int? presetId;
  final String presetNameSnapshot;
  final PresetIconKey presetIconSnapshot;
  final PresetColorKey presetColorSnapshot;
  final int sessionsCompleted;
  final Duration totalDuration;
}

int nextFocusSessionRecordId(Iterable<FocusSessionRecord> records) {
  var nextId = 1;

  for (final record in records) {
    if (record.id >= nextId) {
      nextId = record.id + 1;
    }
  }

  return nextId;
}

int completedFocusSessionCount(Iterable<FocusSessionRecord> records) {
  return records.length;
}

Duration totalFocusDuration(Iterable<FocusSessionRecord> records) {
  var seconds = 0;
  for (final record in records) {
    seconds += record.durationSeconds;
  }
  return Duration(seconds: seconds);
}

List<FocusSessionPresetSummary> focusSessionSummariesByPreset(
  Iterable<FocusSessionRecord> records,
) {
  final summaries = <String, FocusSessionPresetSummary>{};

  for (final record in records) {
    final key = [
      record.presetId?.toString() ?? 'deleted',
      record.presetNameSnapshot,
      record.presetIconSnapshot.name,
      record.presetColorSnapshot.name,
    ].join('|');
    final existing = summaries[key];
    summaries[key] = FocusSessionPresetSummary(
      presetId: record.presetId,
      presetNameSnapshot: record.presetNameSnapshot,
      presetIconSnapshot: record.presetIconSnapshot,
      presetColorSnapshot: record.presetColorSnapshot,
      sessionsCompleted: (existing?.sessionsCompleted ?? 0) + 1,
      totalDuration: (existing?.totalDuration ?? Duration.zero) +
          Duration(seconds: record.durationSeconds),
    );
  }

  final result = summaries.values.toList(growable: false);
  result.sort((a, b) {
    final durationComparison = b.totalDuration.compareTo(a.totalDuration);
    if (durationComparison != 0) {
      return durationComparison;
    }
    return a.presetNameSnapshot.compareTo(b.presetNameSnapshot);
  });
  return result;
}

List<FocusSessionRecord> focusSessionRecordsCompletedBy(
  PomodoroTimerState state,
  DateTime now, {
  required PomodoroTimerConfig config,
  required TimerPreset preset,
  required Iterable<FocusSessionRecord> existingRecords,
}) {
  if (state.status != PomodoroTimerStatus.running ||
      state.startedAt == null ||
      state.endsAt == null ||
      !state.endsAt!.isAfter(state.startedAt!)) {
    return const [];
  }

  var current = state;
  var nextStart = current.endsAt!;
  var nextRecordId = nextFocusSessionRecordId(existingRecords);
  final newRecords = <FocusSessionRecord>[];

  while (!now.isBefore(current.endsAt!)) {
    final completedSessionDuration = config.durationFor(current.sessionType);
    final completedSessionStartedAt =
        current.endsAt!.subtract(completedSessionDuration);
    if (current.sessionType == PomodoroSessionType.focus &&
        !_hasFocusSessionRecord(
          existingRecords.followedBy(newRecords),
          presetId: preset.id,
          startedAt: completedSessionStartedAt,
          completedAt: current.endsAt!,
        )) {
      newRecords.add(
        FocusSessionRecord(
          id: nextRecordId,
          presetId: preset.id,
          presetNameSnapshot: preset.name,
          presetIconSnapshot: preset.iconKey,
          presetColorSnapshot: preset.cardColorKey,
          durationSeconds: completedSessionDuration.inSeconds,
          startedAt: completedSessionStartedAt,
          completedAt: current.endsAt!,
        ),
      );
      nextRecordId += 1;
    }

    final nextSession = _nextSessionAfter(current, config);
    current = current.copyWith(
      sessionType: nextSession.sessionType,
      status: PomodoroTimerStatus.running,
      startedAt: nextStart,
      endsAt: nextStart.add(config.durationFor(nextSession.sessionType)),
      pausedRemaining: config.durationFor(nextSession.sessionType),
      completedFocusSessionsInCycle: nextSession.completedFocusSessionsInCycle,
    );
    nextStart = current.endsAt!;
  }

  return newRecords;
}

bool _hasFocusSessionRecord(
  Iterable<FocusSessionRecord> records, {
  required int presetId,
  required DateTime startedAt,
  required DateTime completedAt,
}) {
  return records.any(
    (record) =>
        record.presetId == presetId &&
        record.startedAt == startedAt &&
        record.completedAt == completedAt,
  );
}

({PomodoroSessionType sessionType, int completedFocusSessionsInCycle})
    _nextSessionAfter(
  PomodoroTimerState state,
  PomodoroTimerConfig config,
) {
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
