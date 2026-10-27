import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scholar_calendar/models/alarm.dart';
import 'package:scholar_calendar/models/event.dart';
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

    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
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

  ///[reminderId] id de la notificación de recordatorio de una alarma
  static int reminderId(int idAlarm) => -idAlarm - 1;

  ///[cancelEvent] cancela la alarma y el recordatorio de un evento
  static void cancelEvent(int idAlarm) {
    cancel(idAlarm);
    cancel(reminderId(idAlarm));
  }

  ///[scheduleEvent] (re)programa la alarma del [event] y, si [alarm] es
  ///anterior al inicio del evento, también su recordatorio.
  static Future<void> scheduleEvent(Event event, Alarm alarm) async {
    final idAlarm = event.idAlarm!;
    cancelEvent(idAlarm);
    final now = DateTime.now();
    final before = event.startTime.difference(alarm.time);
    if (before > Duration.zero && alarm.time.isAfter(now)) {
      final minutes = before.inMinutes;
      await showScheduledNotification(
        id: reminderId(idAlarm),
        title: "Recordatorio del evento ${event.name}",
        body:
            "Este evento será dentro de $minutes ${minutes == 1 ? "minuto" : "minutos"}",
        scheduledDate: alarm.time,
      );
    }
    if (event.startTime.isAfter(now)) {
      await showScheduledNotification(
        id: idAlarm,
        title: event.name,
        body: alarm.description,
        payload: event.name,
        scheduledDate: event.startTime,
      );
    }
  }

  static void cancel(int id) => _notifications.cancel(id: id);
  static void cancelAll() => _notifications.cancelAll();
}
