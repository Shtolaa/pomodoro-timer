import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import '../domain/timer_engine.dart';
import 'timer_notification_message.dart';

class TimerNotificationService {
  TimerNotificationService({FlutterLocalNotificationsPlugin? notifications})
      : _notifications = notifications ?? FlutterLocalNotificationsPlugin();

  static const int _timerNotificationId = 1;
  static const int _transitionNotificationId = 2;
  static const String _channelId = 'timer_session_transitions';
  static const String _channelName = 'Timer session transitions';
  static const String _channelDescription =
      'Notifications for Pomodoro focus and break transitions.';

  final FlutterLocalNotificationsPlugin _notifications;
  bool _initialized = false;

  Future<bool> initialize() async {
    if (_initialized || kIsWeb) {
      return _initialized;
    }

    try {
      timezone_data.initializeTimeZones();
      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
      );
      _initialized =
          await _notifications.initialize(initializationSettings) ?? false;
    } catch (_) {
      _initialized = false;
    }

    return _initialized;
  }

  Future<void> showSessionTransition({
    required PomodoroTimerState completedState,
    required PomodoroTimerConfig config,
    required bool notificationsEnabled,
  }) async {
    if (!notificationsEnabled || !await initialize()) {
      return;
    }

    final message =
        sessionTransitionNotificationMessage(completedState, config);
    try {
      await _notifications.show(
        _transitionNotificationId,
        message.title,
        message.body,
        const NotificationDetails(android: _androidDetails),
        payload: 'timer-session-transition',
      );
    } catch (_) {}
  }

  Future<bool> requestPermission() async {
    if (!await initialize()) {
      return false;
    }

    try {
      final androidNotifications =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidNotifications?.requestNotificationsPermission() ??
          true;
    } catch (_) {
      return false;
    }
  }

  Future<void> scheduleSessionCompletion({
    required PomodoroTimerState state,
    required PomodoroTimerConfig config,
    required bool notificationsEnabled,
  }) async {
    if (!notificationsEnabled ||
        state.status != PomodoroTimerStatus.running ||
        state.endsAt == null ||
        !state.endsAt!.isAfter(DateTime.now()) ||
        !await initialize()) {
      return;
    }

    final message = sessionTransitionNotificationMessage(state, config);
    try {
      await _notifications.cancel(_timerNotificationId);
      await _notifications.zonedSchedule(
        _timerNotificationId,
        message.title,
        message.body,
        timezone.TZDateTime.from(state.endsAt!, timezone.local),
        const NotificationDetails(android: _androidDetails),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'timer-session-transition',
      );
    } catch (_) {}
  }

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    _channelId,
    _channelName,
    channelDescription: _channelDescription,
    importance: Importance.high,
    priority: Priority.high,
    category: AndroidNotificationCategory.reminder,
  );

  Future<void> cancelTimerNotification() async {
    if (!await initialize()) {
      return;
    }

    try {
      await _notifications.cancel(_timerNotificationId);
    } catch (_) {}
  }
}
