import 'package:cozy_pomodoro/app/local_pomodoro_storage.dart';
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
}
