import '../../timer/domain/timer_engine.dart';
import 'preset_color_key.dart';
import 'preset_icon_key.dart';

class TimerPreset {
  TimerPreset({
    required this.id,
    required this.name,
    required this.focusDuration,
    required this.shortBreakDuration,
    required this.longBreakDuration,
    required this.sessionsBeforeLongBreak,
    required this.iconKey,
    required this.cardColorKey,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  })  : assert(id > 0),
        assert(name.trim().isNotEmpty),
        assert(focusDuration > Duration.zero),
        assert(shortBreakDuration > Duration.zero),
        assert(longBreakDuration > Duration.zero),
        assert(sessionsBeforeLongBreak > 0),
        assert(!updatedAt.isBefore(createdAt)),
        assert(deletedAt == null || !deletedAt.isBefore(createdAt));

  final int id;
  final String name;
  final Duration focusDuration;
  final Duration shortBreakDuration;
  final Duration longBreakDuration;
  final int sessionsBeforeLongBreak;
  final PresetIconKey iconKey;
  final PresetColorKey cardColorKey;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  PomodoroTimerConfig toTimerConfig() {
    return PomodoroTimerConfig(
      focusDuration: focusDuration,
      shortBreakDuration: shortBreakDuration,
      longBreakDuration: longBreakDuration,
      focusSessionsBeforeLongBreak: sessionsBeforeLongBreak,
    );
  }

  TimerPreset copyWith({
    int? id,
    String? name,
    Duration? focusDuration,
    Duration? shortBreakDuration,
    Duration? longBreakDuration,
    int? sessionsBeforeLongBreak,
    PresetIconKey? iconKey,
    PresetColorKey? cardColorKey,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return TimerPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      focusDuration: focusDuration ?? this.focusDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      sessionsBeforeLongBreak:
          sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      iconKey: iconKey ?? this.iconKey,
      cardColorKey: cardColorKey ?? this.cardColorKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
    );
  }
}

int nextPresetId(Iterable<TimerPreset> presets) {
  var nextId = 1;

  for (final preset in presets) {
    if (preset.id >= nextId) {
      nextId = preset.id + 1;
    }
  }

  return nextId;
}
