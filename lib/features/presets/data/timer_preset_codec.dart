import 'dart:convert';

import '../domain/preset_color_key.dart';
import '../domain/preset_icon_key.dart';
import '../domain/timer_preset.dart';

String encodeTimerPresets(List<TimerPreset> presets) {
  return jsonEncode(presets.map(timerPresetToJson).toList());
}

List<TimerPreset>? decodeTimerPresets(String value) {
  try {
    final decoded = jsonDecode(value);
    if (decoded is! List) {
      return null;
    }

    final presets = <TimerPreset>[];
    for (final item in decoded) {
      if (item is! Map<String, Object?>) {
        return null;
      }
      final preset = timerPresetFromJson(item);
      if (preset == null) {
        return null;
      }
      presets.add(preset);
    }
    return presets;
  } catch (_) {
    return null;
  }
}

Map<String, Object?> timerPresetToJson(TimerPreset preset) {
  return {
    'id': preset.id,
    'name': preset.name,
    'focusSeconds': preset.focusDuration.inSeconds,
    'shortBreakSeconds': preset.shortBreakDuration.inSeconds,
    'longBreakSeconds': preset.longBreakDuration.inSeconds,
    'sessionsBeforeLongBreak': preset.sessionsBeforeLongBreak,
    'iconKey': preset.iconKey.name,
    'cardColorKey': preset.cardColorKey.name,
    'createdAt': preset.createdAt.toIso8601String(),
    'updatedAt': preset.updatedAt.toIso8601String(),
    'deletedAt': preset.deletedAt?.toIso8601String(),
  };
}

TimerPreset? timerPresetFromJson(Map<String, Object?> json) {
  try {
    final id = json['id'];
    final name = json['name'];
    final focusSeconds = json['focusSeconds'];
    final shortBreakSeconds = json['shortBreakSeconds'];
    final longBreakSeconds = json['longBreakSeconds'];
    final sessionsBeforeLongBreak = json['sessionsBeforeLongBreak'];
    final iconKey = enumByName(PresetIconKey.values, json['iconKey']);
    final cardColorKey =
        enumByName(PresetColorKey.values, json['cardColorKey']);
    final createdAt = parseDateTime(json['createdAt']);
    final updatedAt = parseDateTime(json['updatedAt']);
    final deletedAt = parseNullableDateTime(json['deletedAt']);

    if (id is! int ||
        name is! String ||
        focusSeconds is! int ||
        shortBreakSeconds is! int ||
        longBreakSeconds is! int ||
        sessionsBeforeLongBreak is! int ||
        iconKey == null ||
        cardColorKey == null ||
        createdAt == null ||
        updatedAt == null) {
      return null;
    }

    return TimerPreset(
      id: id,
      name: name,
      focusDuration: Duration(seconds: focusSeconds),
      shortBreakDuration: Duration(seconds: shortBreakSeconds),
      longBreakDuration: Duration(seconds: longBreakSeconds),
      sessionsBeforeLongBreak: sessionsBeforeLongBreak,
      iconKey: iconKey,
      cardColorKey: cardColorKey,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  } catch (_) {
    return null;
  }
}

T? enumByName<T extends Enum>(List<T> values, Object? name) {
  if (name is! String) {
    return null;
  }

  for (final value in values) {
    if (value.name == name) {
      return value;
    }
  }
  return null;
}

DateTime? parseDateTime(Object? value) {
  if (value is! String) {
    return null;
  }
  return DateTime.tryParse(value);
}

DateTime? parseNullableDateTime(Object? value) {
  if (value == null) {
    return null;
  }
  return parseDateTime(value);
}
