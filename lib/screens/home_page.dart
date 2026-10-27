import 'dart:async';

import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scholar_calendar/api/notification_api.dart';
import 'package:scholar_calendar/components/bottom_sheet_add_event_widget.dart';
import 'package:scholar_calendar/components/confirm_dialog.dart';
import 'package:scholar_calendar/components/drawer_app.dart';
import 'package:scholar_calendar/components/floating_action_button_speed_dial.dart';
import 'package:scholar_calendar/controllers/database_controller.dart';
import 'package:scholar_calendar/utils/features_discoveries.dart';
import 'package:scholar_calendar/utils/messages.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CalendarController _calendarController = CalendarController();
  final List<Appointment> _appointments = [];
  bool hasEvents = false;
  StreamSubscription<String?>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    if (getShowDiscovery(keyHome) ?? true) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => showDiscovery(
          context,
          listId: [kFeatureId1DeleteAllEvents],
          key: keyHome,
        ),
      );
    }
    loadState();
    listenNotifications();
  }

  void listenNotifications() => _notificationSubscription = NotificationApi
      .onNotifications
      .stream
      .listen(onClickedNotification);

  void onClickedNotification(String? payload) {}

  void loadState() async {
    final events = await databaseController.getEvents();
    final signatures = {
      for (final s in await databaseController.getSignatures()) s.id: s,
    };
    if (!mounted) return;

    setState(() {
      hasEvents = events.isNotEmpty;
      for (final event in events) {
        final signature = signatures[event.idSignature];
        if (signature == null) continue;
        _appointments.add(
          Appointment(
            id: event.id,
            startTime: event.startTime,
            endTime: event.endTime,
            color: event.color,
            subject: signature.symbology,
            notes: event.startTime.toString(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const iconDelete = Icon(Icons.delete_sweep_outlined);
    final textStyle = TextStyle(color: scheme.onSurface);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eventos Escolares"),
        actions: [
          buildWidget(
            context,
            child: IconButton(
              tooltip: "Eliminar todos los eventos",
              icon: iconDelete,
              onPressed: hasEvents ? _showDialogDeleteAllEvents : null,
            ),
            featureId: kFeatureId1DeleteAllEvents,
            tapTarget: iconDelete,
            contentLocation: ContentLocation.below,
            title: "Eliminar",
            description: "Pulse aquí si desea eliminar todos los eventos",
          ),
        ],
      ),
      drawer: const DrawerApp(),
      body: SfCalendar(
        monthViewSettings: MonthViewSettings(
          agendaStyle: AgendaStyle(
            backgroundColor: scheme.surfaceContainerLow,
            dateTextStyle: textStyle,
            dayTextStyle: textStyle,
          ),
          showAgenda: true,
          showTrailingAndLeadingDates: true,
          appointmentDisplayCount: 10,
          monthCellStyle: MonthCellStyle(
            leadingDatesTextStyle: TextStyle(color: scheme.outline),
            trailingDatesTextStyle: TextStyle(color: scheme.outline),
            textStyle: textStyle,
          ),
        ),
        scheduleViewSettings: ScheduleViewSettings(
          monthHeaderSettings: MonthHeaderSettings(monthTextStyle: textStyle),
          weekHeaderSettings: WeekHeaderSettings(
            backgroundColor: scheme.surfaceContainer,
            weekTextStyle: textStyle,
          ),
        ),
        allowDragAndDrop: true,
        onDragEnd: (details) => _moveEvent(
          details.appointment as Appointment,
          details.droppingTime,
        ),
        onAppointmentResizeEnd: (details) => _moveEvent(
          details.appointment as Appointment,
          details.startTime,
          details.endTime,
        ),
        viewHeaderStyle: ViewHeaderStyle(
          backgroundColor: scheme.surfaceContainerLow,
          dateTextStyle: textStyle,
          dayTextStyle: textStyle,
        ),
        todayHighlightColor: scheme.primary,
        todayTextStyle: TextStyle(color: scheme.onPrimary),
        cellBorderColor: scheme.outlineVariant,
        headerStyle: CalendarHeaderStyle(
          backgroundColor: scheme.surfaceContainerHigh,
          textStyle: TextStyle(
            color: scheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        weekNumberStyle: WeekNumberStyle(
          backgroundColor: scheme.surfaceContainerHigh,
          textStyle: textStyle,
        ),
        view: CalendarView.week,
        allowViewNavigation: true,
        allowedViews: const <CalendarView>[
          CalendarView.week,
          CalendarView.workWeek,
          CalendarView.month,
        ],
        showCurrentTimeIndicator: true,
        dataSource: MeetingDataSource(_appointments),
        appointmentBuilder: _appointmentBuilder,
        viewNavigationMode: ViewNavigationMode.snap,
        showWeekNumber: true,
        showDatePickerButton: true,
        controller: _calendarController,
        firstDayOfWeek: 1,
        allowAppointmentResize: true,
        backgroundColor: scheme.surface,
        timeSlotViewSettings: TimeSlotViewSettings(
          endHour: 24,
          timeIntervalHeight: 80,
          timeFormat: 'h:mm a',
          dateFormat: 'd',
          dayFormat: 'EEE',
          timeTextStyle: TextStyle(color: scheme.outline, fontSize: 12),
          timeRulerSize: 70,
        ),
      ),
      floatingActionButton: const FloatingActionButtonSpeedDial(),
    );
  }

  void _showDialogDeleteAllEvents() {
    showConfirmDialog(
      context,
      title: "¿Desea eliminar todos los eventos?",
      note: "Nota: Al eliminar todos los eventos todas las alarmas serán eliminadas",
      onConfirm: () async {
        await databaseController.deleteAllEvents();
        NotificationApi.cancelAll();
        showSuccess("Eventos eliminados satisfactoriamente");
        Get.offAll(() => const MyHomePage());
      },
    );
  }

  ///[_moveEvent] guarda en la base de datos un evento arrastrado o redimensionado
  ///y reprograma sus alarmas.
  Future<void> _moveEvent(
    Appointment appointment,
    DateTime? startTime, [
    DateTime? endTime,
  ]) async {
    if (startTime == null) return;
    final event = await databaseController.getEventById(appointment.id as int);
    if (event == null) return;
    final isUpdated = await databaseController.updateEventStartTimeById(
      event: event,
      startTime: startTime,
      endTime: endTime,
    );
    final alarm = await databaseController.getAlarmById(event.idAlarm!);
    final updated = await databaseController.getEventById(event.id!);
    if (updated != null && alarm != null) {
      await NotificationApi.scheduleEvent(updated, alarm);
    }
    if (isUpdated) showSuccess("Evento modificado satisfactoriamente");
  }

  Future<void> _openEvent(Appointment appointment) async {
    final event = await databaseController.getEventById(appointment.id as int);
    if (event == null) return;
    final signature = await databaseController.getSignatureById(
      event.idSignature!,
    );
    final alarm = await databaseController.getAlarmById(event.idAlarm!);
    if (!mounted) return;
    showEventSheet(
      context,
      event: event,
      alarm: alarm,
      signatureName: signature?.name,
    );
  }

  ///[_onColor] color de texto legible sobre el color del evento
  static Color _onColor(Color color) =>
      ThemeData.estimateBrightnessForColor(color) == Brightness.dark
      ? Colors.white
      : Colors.black87;

  Widget _appointmentBuilder(
    BuildContext context,
    CalendarAppointmentDetails calendarAppointmentDetails,
  ) {
    final bounds = calendarAppointmentDetails.bounds;
    if (calendarAppointmentDetails.isMoreAppointmentRegion) {
      final scheme = Theme.of(context).colorScheme;
      return Container(
        width: bounds.width,
        height: bounds.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '+ más',
          style: TextStyle(color: scheme.onSecondaryContainer, fontSize: 10),
        ),
      );
    }

    final Appointment appointment =
        calendarAppointmentDetails.appointments.first;
    final onColor = _onColor(appointment.color);
    final decoration = BoxDecoration(
      color: appointment.color,
      borderRadius: BorderRadius.circular(6),
    );

    if (_calendarController.view == CalendarView.month) {
      final style = TextStyle(color: onColor, fontSize: 10);
      return Container(
        decoration: decoration,
        alignment: Alignment.center,
        child: appointment.isAllDay
            ? Text(appointment.subject, style: style)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    appointment.subject,
                    style: style.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${DateFormat('hh:mm a').format(appointment.startTime)} - '
                    '${DateFormat('hh:mm a').format(appointment.endTime)}',
                    style: style,
                  ),
                ],
              ),
      );
    }

    return GestureDetector(
      onTap: () => _openEvent(appointment),
      child: Container(
        alignment: Alignment.center,
        decoration: decoration,
        width: bounds.width,
        height: bounds.height,
        child: Text(
          (appointment.notes != null) ? appointment.subject : " ",
          style: TextStyle(
            color: onColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
