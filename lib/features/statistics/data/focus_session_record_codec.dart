import 'dart:convert';

import '../../presets/data/timer_preset_codec.dart';
import '../../presets/domain/preset_color_key.dart';
import '../../presets/domain/preset_icon_key.dart';
import '../domain/focus_session_record.dart';

String encodeFocusSessionRecords(List<FocusSessionRecord> records) {
  return jsonEncode(records.map(focusSessionRecordToJson).toList());
}

List<FocusSessionRecord>? decodeFocusSessionRecords(String value) {
  try {
    final decoded = jsonDecode(value);
    if (decoded is! List) {
      return null;
    }

    final records = <FocusSessionRecord>[];
    for (final item in decoded) {
      if (item is! Map<String, Object?>) {
        return null;
      }
      final record = focusSessionRecordFromJson(item);
      if (record == null) {
        return null;
      }
      records.add(record);
    }
    return records;
  } catch (_) {
    return null;
  }
}

Map<String, Object?> focusSessionRecordToJson(FocusSessionRecord record) {
  return {
    'id': record.id,
    'presetId': record.presetId,
    'presetNameSnapshot': record.presetNameSnapshot,
    'presetIconSnapshot': record.presetIconSnapshot.name,
    'presetColorSnapshot': record.presetColorSnapshot.name,
    'durationSeconds': record.durationSeconds,
    'startedAt': record.startedAt.toIso8601String(),
    'completedAt': record.completedAt.toIso8601String(),
  };
}

FocusSessionRecord? focusSessionRecordFromJson(Map<String, Object?> json) {
  try {
    final id = json['id'];
    final presetId = json['presetId'];
    final presetNameSnapshot = json['presetNameSnapshot'];
    final presetIconSnapshot =
        enumByName(PresetIconKey.values, json['presetIconSnapshot']);
    final presetColorSnapshot =
        enumByName(PresetColorKey.values, json['presetColorSnapshot']);
    final durationSeconds = json['durationSeconds'];
    final startedAt = parseDateTime(json['startedAt']);
    final completedAt = parseDateTime(json['completedAt']);

    if (id is! int ||
        (presetId != null && presetId is! int) ||
        presetNameSnapshot is! String ||
        presetIconSnapshot == null ||
        presetColorSnapshot == null ||
        durationSeconds is! int ||
        startedAt == null ||
        completedAt == null) {
      return null;
    }

    return FocusSessionRecord(
      id: id,
      presetId: presetId as int?,
      presetNameSnapshot: presetNameSnapshot,
      presetIconSnapshot: presetIconSnapshot,
      presetColorSnapshot: presetColorSnapshot,
      durationSeconds: durationSeconds,
      startedAt: startedAt,
      completedAt: completedAt,
    );
  } catch (_) {
    return null;
  }
}
