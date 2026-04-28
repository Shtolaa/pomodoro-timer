import 'package:cozy_pomodoro/features/presets/domain/preset_color_key.dart';
import 'package:cozy_pomodoro/features/presets/domain/preset_icon_key.dart';
import 'package:cozy_pomodoro/features/presets/domain/timer_preset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final createdAt = DateTime(2026, 4, 28, 9);
  final updatedAt = DateTime(2026, 4, 28, 10);

  TimerPreset createPreset({
    int id = 1,
    String name = 'Study',
    Duration focusDuration = const Duration(minutes: 25),
    Duration shortBreakDuration = const Duration(minutes: 5),
    Duration longBreakDuration = const Duration(minutes: 15),
    int sessionsBeforeLongBreak = 4,
    PresetIconKey iconKey = PresetIconKey.book,
    PresetColorKey cardColorKey = PresetColorKey.lavender,
    DateTime? createdAtOverride,
    DateTime? updatedAtOverride,
    DateTime? deletedAt,
  }) {
    return TimerPreset(
      id: id,
      name: name,
      focusDuration: focusDuration,
      shortBreakDuration: shortBreakDuration,
      longBreakDuration: longBreakDuration,
      sessionsBeforeLongBreak: sessionsBeforeLongBreak,
      iconKey: iconKey,
      cardColorKey: cardColorKey,
      createdAt: createdAtOverride ?? createdAt,
      updatedAt: updatedAtOverride ?? updatedAt,
      deletedAt: deletedAt,
    );
  }

  test('creates a valid timer preset', () {
    final preset = createPreset();

    expect(preset.id, 1);
    expect(preset.name, 'Study');
    expect(preset.focusDuration, const Duration(minutes: 25));
    expect(preset.shortBreakDuration, const Duration(minutes: 5));
    expect(preset.longBreakDuration, const Duration(minutes: 15));
    expect(preset.sessionsBeforeLongBreak, 4);
    expect(preset.iconKey, PresetIconKey.book);
    expect(preset.cardColorKey, PresetColorKey.lavender);
    expect(preset.createdAt, createdAt);
    expect(preset.updatedAt, updatedAt);
    expect(preset.deletedAt, isNull);
  });

  test('rejects non-positive id', () {
    expect(() => createPreset(id: 0), throwsAssertionError);
    expect(() => createPreset(id: -1), throwsAssertionError);
  });

  test('rejects blank name', () {
    expect(() => createPreset(name: ''), throwsAssertionError);
    expect(() => createPreset(name: '   '), throwsAssertionError);
  });

  test('rejects non-positive focus duration', () {
    expect(
      () => createPreset(focusDuration: Duration.zero),
      throwsAssertionError,
    );
    expect(
      () => createPreset(focusDuration: const Duration(seconds: -1)),
      throwsAssertionError,
    );
  });

  test('rejects non-positive short break duration', () {
    expect(
      () => createPreset(shortBreakDuration: Duration.zero),
      throwsAssertionError,
    );
    expect(
      () => createPreset(shortBreakDuration: const Duration(seconds: -1)),
      throwsAssertionError,
    );
  });

  test('rejects non-positive long break duration', () {
    expect(
      () => createPreset(longBreakDuration: Duration.zero),
      throwsAssertionError,
    );
    expect(
      () => createPreset(longBreakDuration: const Duration(seconds: -1)),
      throwsAssertionError,
    );
  });

  test('rejects non-positive sessions before long break', () {
    expect(
        () => createPreset(sessionsBeforeLongBreak: 0), throwsAssertionError);
    expect(
      () => createPreset(sessionsBeforeLongBreak: -1),
      throwsAssertionError,
    );
  });

  test('rejects update timestamp before creation timestamp', () {
    expect(
      () => createPreset(
        updatedAtOverride: createdAt.subtract(const Duration(seconds: 1)),
      ),
      throwsAssertionError,
    );
  });

  test('supports soft-deleted presets', () {
    final deletedAt = DateTime(2026, 4, 29, 9);
    final preset = createPreset(deletedAt: deletedAt);

    expect(preset.deletedAt, deletedAt);
  });

  test('rejects deletion timestamp before creation timestamp', () {
    expect(
      () => createPreset(
        deletedAt: createdAt.subtract(const Duration(seconds: 1)),
      ),
      throwsAssertionError,
    );
  });

  test('converts to timer config', () {
    final config = createPreset(
      focusDuration: const Duration(minutes: 30),
      shortBreakDuration: const Duration(minutes: 7),
      longBreakDuration: const Duration(minutes: 20),
      sessionsBeforeLongBreak: 3,
    ).toTimerConfig();

    expect(config.focusDuration, const Duration(minutes: 30));
    expect(config.shortBreakDuration, const Duration(minutes: 7));
    expect(config.longBreakDuration, const Duration(minutes: 20));
    expect(config.focusSessionsBeforeLongBreak, 3);
  });

  test('copies and updates preset fields', () {
    final deletedAt = DateTime(2026, 4, 29, 9);
    final preset = createPreset().copyWith(
      name: 'Deep Work',
      iconKey: PresetIconKey.laptop,
      cardColorKey: PresetColorKey.powderBlue,
      deletedAt: deletedAt,
    );

    expect(preset.id, 1);
    expect(preset.name, 'Deep Work');
    expect(preset.iconKey, PresetIconKey.laptop);
    expect(preset.cardColorKey, PresetColorKey.powderBlue);
    expect(preset.deletedAt, deletedAt);
  });

  test('clears deleted timestamp when copied', () {
    final deleted = createPreset(deletedAt: DateTime(2026, 4, 29, 9));
    final restored = deleted.copyWith(clearDeletedAt: true);

    expect(restored.deletedAt, isNull);
  });

  test('returns 1 as the next preset id when there are no presets', () {
    expect(nextPresetId([]), 1);
  });

  test('returns max preset id plus one', () {
    expect(
      nextPresetId([
        createPreset(id: 1),
        createPreset(id: 4),
        createPreset(id: 2),
      ]),
      5,
    );
  });

  test('includes soft-deleted presets when calculating next id', () {
    expect(
      nextPresetId([
        createPreset(id: 1),
        createPreset(id: 7, deletedAt: DateTime(2026, 4, 29, 9)),
        createPreset(id: 3),
      ]),
      8,
    );
  });
}
