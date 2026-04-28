import 'package:cozy_pomodoro/features/presets/data/timer_preset_codec.dart';
import 'package:cozy_pomodoro/features/presets/domain/preset_color_key.dart';
import 'package:cozy_pomodoro/features/presets/domain/preset_icon_key.dart';
import 'package:cozy_pomodoro/features/presets/domain/timer_preset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes and deserializes presets with enum keys and deletedAt', () {
    final deletedAt = DateTime(2026, 4, 28, 12);
    final preset = TimerPreset(
      id: 7,
      name: 'Deep Work',
      focusDuration: const Duration(minutes: 45),
      shortBreakDuration: const Duration(minutes: 10),
      longBreakDuration: const Duration(minutes: 25),
      sessionsBeforeLongBreak: 3,
      iconKey: PresetIconKey.laptop,
      cardColorKey: PresetColorKey.powderBlue,
      createdAt: DateTime(2026, 4, 28, 9),
      updatedAt: deletedAt,
      deletedAt: deletedAt,
    );

    final decoded = decodeTimerPresets(encodeTimerPresets([preset]));

    expect(decoded, hasLength(1));
    expect(decoded!.single.id, 7);
    expect(decoded.single.name, 'Deep Work');
    expect(decoded.single.focusDuration, const Duration(minutes: 45));
    expect(decoded.single.shortBreakDuration, const Duration(minutes: 10));
    expect(decoded.single.longBreakDuration, const Duration(minutes: 25));
    expect(decoded.single.sessionsBeforeLongBreak, 3);
    expect(decoded.single.iconKey, PresetIconKey.laptop);
    expect(decoded.single.cardColorKey, PresetColorKey.powderBlue);
    expect(decoded.single.deletedAt, deletedAt);
  });

  test('returns null for invalid preset data', () {
    expect(decodeTimerPresets('not json'), isNull);
    expect(
      timerPresetFromJson({
        'id': 0,
        'name': 'Broken',
        'focusSeconds': 0,
        'shortBreakSeconds': 300,
        'longBreakSeconds': 1800,
        'sessionsBeforeLongBreak': 4,
        'iconKey': PresetIconKey.book.name,
        'cardColorKey': PresetColorKey.peach.name,
        'createdAt': DateTime(2026, 4, 28).toIso8601String(),
        'updatedAt': DateTime(2026, 4, 28).toIso8601String(),
      }),
      isNull,
    );
  });
}
