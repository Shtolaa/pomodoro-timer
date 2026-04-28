import 'package:cozy_pomodoro/features/presets/domain/preset_color_key.dart';
import 'package:cozy_pomodoro/features/presets/domain/preset_icon_key.dart';
import 'package:cozy_pomodoro/features/statistics/data/focus_session_record_codec.dart';
import 'package:cozy_pomodoro/features/statistics/domain/focus_session_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes and deserializes focus session records', () {
    final startedAt = DateTime(2026, 4, 28, 9);
    final completedAt = DateTime(2026, 4, 28, 9, 25);
    final record = FocusSessionRecord(
      id: 9,
      presetId: 2,
      presetNameSnapshot: 'Reading',
      presetIconSnapshot: PresetIconKey.book,
      presetColorSnapshot: PresetColorKey.honey,
      durationSeconds: 1500,
      startedAt: startedAt,
      completedAt: completedAt,
    );

    final decoded = decodeFocusSessionRecords(
      encodeFocusSessionRecords([record]),
    );

    expect(decoded, hasLength(1));
    expect(decoded!.single.id, 9);
    expect(decoded.single.presetId, 2);
    expect(decoded.single.presetNameSnapshot, 'Reading');
    expect(decoded.single.presetIconSnapshot, PresetIconKey.book);
    expect(decoded.single.presetColorSnapshot, PresetColorKey.honey);
    expect(decoded.single.durationSeconds, 1500);
    expect(decoded.single.startedAt, startedAt);
    expect(decoded.single.completedAt, completedAt);
  });

  test('returns null for invalid focus session data', () {
    expect(decodeFocusSessionRecords('not json'), isNull);
    expect(
      focusSessionRecordFromJson({
        'id': 0,
        'presetId': 1,
        'presetNameSnapshot': 'Broken',
        'presetIconSnapshot': PresetIconKey.book.name,
        'presetColorSnapshot': PresetColorKey.peach.name,
        'durationSeconds': 0,
        'startedAt': DateTime(2026, 4, 28, 9).toIso8601String(),
        'completedAt': DateTime(2026, 4, 28, 9, 25).toIso8601String(),
      }),
      isNull,
    );
  });
}
