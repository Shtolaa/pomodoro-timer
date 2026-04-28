import 'package:shared_preferences/shared_preferences.dart';

import '../features/app_theme/data/pomodoro_theme_codec.dart';
import '../features/app_theme/domain/pomodoro_theme.dart';
import '../features/presets/data/timer_preset_codec.dart';
import '../features/presets/domain/timer_preset.dart';
import '../features/timer/data/timer_state_codec.dart';

class LocalPomodoroStorage {
  LocalPomodoroStorage(this.preferences);

  static const _selectedThemeKey = 'selected_theme';
  static const _presetsKey = 'timer_presets';
  static const _activePresetIdKey = 'active_preset_id';
  static const _timerStateKey = 'timer_state';
  static const _notificationsEnabledKey = 'notifications_enabled';

  final SharedPreferences preferences;

  static Future<LocalPomodoroStorage> load() async {
    return LocalPomodoroStorage(await SharedPreferences.getInstance());
  }

  PomodoroThemeOption? loadSelectedTheme() {
    return themeFromKey(preferences.getString(_selectedThemeKey));
  }

  Future<void> saveSelectedTheme(PomodoroThemeOption theme) async {
    await preferences.setString(_selectedThemeKey, themeKeyFor(theme));
  }

  List<TimerPreset>? loadPresets() {
    final value = preferences.getString(_presetsKey);
    if (value == null) {
      return null;
    }
    return decodeTimerPresets(value);
  }

  Future<void> savePresets(List<TimerPreset> presets) async {
    await preferences.setString(_presetsKey, encodeTimerPresets(presets));
  }

  int? loadActivePresetId() {
    return preferences.getInt(_activePresetIdKey);
  }

  Future<void> saveActivePresetId(int id) async {
    await preferences.setInt(_activePresetIdKey, id);
  }

  PersistedTimerState? loadTimerState() {
    final value = preferences.getString(_timerStateKey);
    if (value == null) {
      return null;
    }
    return decodeTimerState(value);
  }

  Future<void> saveTimerState(PersistedTimerState timerState) async {
    await preferences.setString(_timerStateKey, encodeTimerState(timerState));
  }

  bool loadNotificationsEnabled() {
    return preferences.getBool(_notificationsEnabledKey) ?? false;
  }

  Future<void> saveNotificationsEnabled(bool enabled) async {
    await preferences.setBool(_notificationsEnabledKey, enabled);
  }
}
