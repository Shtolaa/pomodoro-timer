import 'package:cozy_pomodoro/features/app_theme/data/pomodoro_theme_codec.dart';
import 'package:cozy_pomodoro/features/app_theme/domain/pomodoro_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolves saved theme keys', () {
    final peachCafe = PomodoroThemeOption.themes[2];

    expect(themeKeyFor(peachCafe), 'Peach Cafe');
    expect(themeFromKey('Peach Cafe'), peachCafe);
    expect(themeFromKey('Missing Theme'), isNull);
  });
}
