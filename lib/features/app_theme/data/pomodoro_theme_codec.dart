import '../domain/pomodoro_theme.dart';

String themeKeyFor(PomodoroThemeOption theme) => theme.name;

PomodoroThemeOption? themeFromKey(String? key) {
  if (key == null) {
    return null;
  }

  for (final theme in PomodoroThemeOption.themes) {
    if (theme.name == key) {
      return theme;
    }
  }
  return null;
}
