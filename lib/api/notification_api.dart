import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationApi {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'event_alarms',
      'Alarmas de eventos',
      channelDescription: 'Alarmas y recordatorios de los eventos escolares',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
    ),
    iOS: DarwinNotificationDetails(),
  );

  static Future init() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(),
    );

    final details = await _notifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      onNotifications.add(details.notificationResponse?.payload);
    }

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) =>
          onNotifications.add(response.payload),
    );

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }

  static Future showScheduledNotification({
    required int id,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
  }) async {
    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      // tz.local is never initialised; UTC keeps the same absolute instant.
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.UTC),
      notificationDetails: _details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static void cancel(int id) => _notifications.cancel(id: id);
  static void cancelAll() => _notifications.cancelAll();
}
