import 'package:cozy_pomodoro/app/local_pomodoro_storage.dart';
import 'package:cozy_pomodoro/features/presets/domain/preset_color_key.dart';
import 'package:cozy_pomodoro/features/presets/domain/preset_icon_key.dart';
import 'package:cozy_pomodoro/features/statistics/domain/focus_session_record.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('notifications are disabled by default', () async {
    final storage = await LocalPomodoroStorage.load();

    expect(storage.loadNotificationsEnabled(), isFalse);
  });

  test('saves enabled notification setting', () async {
    final storage = await LocalPomodoroStorage.load();

    await storage.saveNotificationsEnabled(true);

    expect(storage.loadNotificationsEnabled(), isTrue);
  });

  test('saves disabled notification setting', () async {
    final storage = await LocalPomodoroStorage.load();

    await storage.saveNotificationsEnabled(true);
    await storage.saveNotificationsEnabled(false);

    expect(storage.loadNotificationsEnabled(), isFalse);
  });

  test('focus session records are empty by default', () async {
    final storage = await LocalPomodoroStorage.load();

    expect(storage.loadFocusSessionRecords(), isEmpty);
  });

  test('saves focus session records', () async {
    final storage = await LocalPomodoroStorage.load();
    final startedAt = DateTime(2026, 4, 28, 9);
    final record = FocusSessionRecord(
      id: 1,
      presetId: 1,
      presetNameSnapshot: 'Standard Pomodoro',
      presetIconSnapshot: PresetIconKey.book,
      presetColorSnapshot: PresetColorKey.peach,
      durationSeconds: 1500,
      startedAt: startedAt,
      completedAt: startedAt.add(const Duration(minutes: 25)),
    );

    await storage.saveFocusSessionRecords([record]);

    final records = storage.loadFocusSessionRecords();
    expect(records, hasLength(1));
    expect(records.single.presetNameSnapshot, 'Standard Pomodoro');
  });

  test('corrupt focus session records fall back to empty list', () async {
    SharedPreferences.setMockInitialValues({
      'focus_session_records': 'not json',
    });
    final storage = await LocalPomodoroStorage.load();

    expect(storage.loadFocusSessionRecords(), isEmpty);
  });
}
