import 'dart:math' as math;

import 'package:animate_do/animate_do.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholar_calendar/api/notification_api.dart';
import 'package:scholar_calendar/components/confirm_dialog.dart';
import 'package:scholar_calendar/components/dialog_add_alert_widget.dart';
import 'package:scholar_calendar/components/dropdown_button_event_type.dart';
import 'package:scholar_calendar/components/dropdown_button_signature.dart';
import 'package:scholar_calendar/controllers/database_controller.dart';
import 'package:scholar_calendar/enums/event_type.dart';
import 'package:scholar_calendar/models/alarm.dart';
import 'package:scholar_calendar/models/event.dart';
import 'package:scholar_calendar/screens/home_page.dart';
import 'package:scholar_calendar/utils/features_discoveries.dart';
import 'package:scholar_calendar/utils/messages.dart';

///[showEventSheet] abre la hoja para añadir (o editar, si se pasa [event]) un evento
Future<void> showEventSheet(
  BuildContext context, {
  Event? event,
  Alarm? alarm,
  String? signatureName,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BottomSheetAddEventWidget(
      event: event,
      alarm: alarm,
      signatureName: signatureName,
    ),
  );
}

class BottomSheetAddEventWidget extends StatefulWidget {
  final Event? event;
  final Alarm? alarm;
  final String? signatureName;

  const BottomSheetAddEventWidget({
    this.event,
    this.alarm,
    this.signatureName,
    super.key,
  });

  @override
  State<BottomSheetAddEventWidget> createState() =>
      _BottomSheetAddEventWidgetState();
}

class _BottomSheetAddEventWidgetState extends State<BottomSheetAddEventWidget> {
  static const _errorStartTime =
      "La fecha seleccionada no puede ser menor que la fecha actual";
  static const _errorAlarmDate =
      "Seleccione una fecha correcta para poder añadir una alarma o alerta";

  late String _textEventName;
  String? _textAlarmDescription;
  late DateTime _dateTime;
  late Duration _duration;
  Duration _alert = Duration.zero;
  EventType? _eventType;
  String? _signatureName;
  bool _editing = false;
  bool _notificationIsEnabled = true;
  bool _switchIsEnabled = true;
  final _formKey = GlobalKey<FormState>();
  late Color _dialogSelectColor;

  String _errorMessageEventType = "",
      _errorMessageSignature = "",
      _errorMessageStartTime = "",
      _errorMessageDuration = "",
      _errorMessageAlert = "";

  @override
  void initState() {
    super.initState();
    _editing = widget.event != null;
    _showTutorial();
    final event = widget.event;
    if (event != null) {
      _dateTime = event.startTime;
      _duration = Duration(
        minutes: event.endTime.difference(event.startTime).inMinutes,
      );
      _textEventName = event.name;
      _textAlarmDescription = widget.alarm?.description;
      _dialogSelectColor = event.color;
      _eventType = event.eventType;
      _signatureName = widget.signatureName;
      final alarmTime = widget.alarm?.time;
      if (alarmTime != null && alarmTime.isBefore(event.startTime)) {
        _alert = event.startTime.difference(alarmTime);
      }
    } else {
      _dateTime = DateTime.now();
      _duration = const Duration(minutes: 15);
      _textEventName = "";
      _textAlarmDescription = "";
      _dialogSelectColor = Color(0xFF000000 | math.Random().nextInt(0x1000000));
    }
  }

  void _showTutorial() {
    final showAdd = getShowDiscovery(key_add_event) ?? true;
    final showDelete = getShowDiscovery(key_delete_event) ?? true;
    if (!showAdd && !showDelete) return;

    List<String> listId;
    if (_editing && !showAdd && showDelete) {
      listId = [kFeatureId4DeleteEvent];
      setShowDiscovery(false, key_delete_event);
    } else if (!_editing && showAdd) {
      listId = [kFeatureId5Color, kFeatureId6Alert, kFeatureId7Switch];
    } else {
      listId = [
        kFeatureId4DeleteEvent,
        kFeatureId5Color,
        kFeatureId6Alert,
        kFeatureId7Switch,
      ];
      setShowDiscovery(false, key_delete_event);
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => showDiscovery(context, listId: listId, key: key_add_event),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const iconDeleteEvent = Icon(Icons.delete_outline);
    final iconColor = Icon(Icons.circle, color: _dialogSelectColor);
    final iconAlert = Icon(
      _notificationIsEnabled
          ? Icons.notifications_active_outlined
          : Icons.notifications_off_outlined,
      color: _notificationIsEnabled ? null : scheme.outline,
    );
    final pickerHeight = MediaQuery.sizeOf(context).height / 8;

    return Padding(
      // mantiene el formulario visible sobre el teclado
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _editing ? "Editar Evento" : "Añadir Evento",
                  style: theme.textTheme.titleLarge,
                ),
              ),
              if (_editing)
                buildWidget(
                  context,
                  featureId: kFeatureId4DeleteEvent,
                  tapTarget: iconDeleteEvent,
                  child: IconButton(
                    tooltip: "Eliminar evento",
                    color: scheme.error,
                    onPressed: _showDialogDeleteEvent,
                    icon: iconDeleteEvent,
                  ),
                  contentLocation: ContentLocation.below,
                  title: "Eliminar",
                  description: "Pulse aquí para eliminar este evento",
                ),
              buildWidget(
                context,
                featureId: kFeatureId5Color,
                tapTarget: iconColor,
                child: IconButton.filledTonal(
                  tooltip: "Color del evento",
                  iconSize: 28,
                  onPressed: _pickColor,
                  icon: iconColor,
                ),
                contentLocation: ContentLocation.below,
                title: "Color",
                description: "Toque aquí para seleccionar el color del evento",
              ),
            ],
          ),
          const SizedBox(height: 8),
          _section(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: _textEventName,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: "Nombre",
                      prefixIcon: Icon(Icons.title),
                    ),
                    onSaved: (newValue) => _textEventName = newValue!.trim(),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? "Llene este campo"
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    maxLength: 150,
                    minLines: 1,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    initialValue: _textAlarmDescription,
                    decoration: const InputDecoration(
                      labelText: "Descripción",
                      prefixIcon: Icon(Icons.event_note_outlined),
                      helperText: "Opcional",
                    ),
                    onSaved: (newValue) => _textAlarmDescription = newValue,
                  ),
                ],
              ),
            ),
          ),
          _section(
            child: Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                _withError(
                  DropdownButtonEventTypeWidget(
                    value: _eventType,
                    onChanged: (value) => setState(() => _eventType = value),
                  ),
                  _errorMessageEventType,
                ),
                _withError(
                  DropdownButtonSignatureWidget(
                    value: _signatureName,
                    onChanged: (value) =>
                        setState(() => _signatureName = value),
                  ),
                  _errorMessageSignature,
                ),
              ],
            ),
          ),
          _section(
            label: "Fecha y hora",
            child: _withError(
              _cupertino(
                SizedBox(
                  height: pickerHeight,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.dateAndTime,
                    use24hFormat: false,
                    initialDateTime: (_editing && validateStartTime())
                        ? _dateTime
                        : DateTime.now().add(const Duration(minutes: 1)),
                    minimumDate: DateTime.now(),
                    onDateTimeChanged: (DateTime dateTime) {
                      setState(() {
                        _dateTime = dateTime;
                        _checkStartTime();
                      });
                    },
                  ),
                ),
              ),
              _errorMessageStartTime,
              center: true,
            ),
          ),
          _section(
            label: "Duración",
            child: _withError(
              _cupertino(
                SizedBox(
                  height: pickerHeight,
                  child: CupertinoTimerPicker(
                    initialTimerDuration: _duration,
                    mode: CupertinoTimerPickerMode.hm,
                    onTimerDurationChanged: (Duration duration) {
                      setState(() {
                        _duration = duration;
                        _errorMessageDuration = validateDuration()
                            ? ""
                            : "La duración no puede ser menos de 15 minutos";
                      });
                    },
                  ),
                ),
              ),
              _errorMessageDuration,
              center: true,
            ),
          ),
          _section(
            child: _withError(
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _alert == Duration.zero
                          ? "Alarma"
                          : "Alarma · aviso ${_alert.inMinutes} min antes",
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  buildWidget(
                    context,
                    featureId: kFeatureId6Alert,
                    tapTarget: iconAlert,
                    child: IconButton(
                      tooltip: "Recordatorio",
                      onPressed: _notificationIsEnabled
                          ? _showDialogAddAlert
                          : null,
                      icon: iconAlert,
                    ),
                    contentLocation: ContentLocation.above,
                    title: "Recordatorio",
                    description: "Cuando la alarma esté activa pulse aquí\npara especificar un recordatorio del evento",
                  ),
                  buildWidget(
                    context,
                    featureId: kFeatureId7Switch,
                    tapTarget: Switch(
                      value: _notificationIsEnabled,
                      activeTrackColor: _dialogSelectColor,
                      onChanged: (value) {},
                    ),
                    child: Switch(
                      activeTrackColor: _dialogSelectColor,
                      value: _notificationIsEnabled,
                      onChanged: _switchIsEnabled
                          ? (isActivated) => setState(
                              () => _notificationIsEnabled = isActivated,
                            )
                          : null,
                    ),
                    contentLocation: ContentLocation.above,
                    title: "Alarma",
                    description: "Pulse aquí para activar o desactivar la alarma del evento",
                  ),
                ],
              ),
              (_errorMessageAlert.isNotEmpty && _notificationIsEnabled) ||
                      !_switchIsEnabled
                  ? _errorMessageAlert
                  : "",
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                  label: const Text("Guardar"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section({required Widget child, String? label}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: label == null
          ? child
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                child,
              ],
            ),
    );
  }

  ///[_withError] muestra [child] con su mensaje de error animado debajo
  Widget _withError(Widget child, String error, {bool center = false}) {
    return Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        if (error.isNotEmpty)
          ElasticIn(
            child: Text(
              error,
              textAlign: center ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _cupertino(Widget child) {
    final theme = Theme.of(context);
    final style = TextStyle(fontSize: 18, color: theme.colorScheme.onSurface);
    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: theme.brightness,
        textTheme: CupertinoTextThemeData(
          pickerTextStyle: style,
          dateTimePickerTextStyle: style,
        ),
      ),
      child: child,
    );
  }

  Future<void> _pickColor() async {
    final scheme = Theme.of(context).colorScheme;
    final Color newColor = await showColorPickerDialog(
      context,
      _dialogSelectColor,
      backgroundColor: scheme.surfaceContainerHigh,
      selectedPickerTypeColor: scheme.primary,
      title: const Text("Seleccione el color"),
      pickerTypeLabels: const <ColorPickerType, String>{
        ColorPickerType.primary: "Primarios",
        ColorPickerType.accent: "Acentuados",
      },
      actionButtons: const ColorPickerActionButtons(
        closeButton: true,
        dialogActionIcons: true,
      ),
    );
    if (mounted) setState(() => _dialogSelectColor = newColor);
  }

  ///[_checkStartTime] actualiza los errores y el estado de la alarma según la fecha
  void _checkStartTime() {
    if (!validateStartTime()) {
      _errorMessageStartTime = _errorStartTime;
      _errorMessageAlert = _errorAlarmDate;
      _notificationIsEnabled = false;
      _switchIsEnabled = false;
    } else {
      _errorMessageStartTime = "";
      _errorMessageAlert = "";
      _switchIsEnabled = true;
    }
  }

  void _save() async {
    setState(() {
      _errorMessageEventType = validateEventType()
          ? ""
          : "Seleccione el tipo de evento";
      _errorMessageSignature = validateSignature()
          ? ""
          : "Seleccione la asignatura";
      _checkStartTime();
      _errorMessageDuration = validateDuration()
          ? ""
          : "La duración no puede ser menos de 15 minutos";
    });
    final formIsValid = _formKey.currentState!.validate();
    if (!(formIsValid &&
        validateEventType() &&
        validateSignature() &&
        validateStartTime() &&
        validateDuration())) {
      return;
    }
    _formKey.currentState!.save();

    final startTime = DateTime(
      _dateTime.year,
      _dateTime.month,
      _dateTime.day,
      _dateTime.hour,
      _dateTime.minute,
    );
    final endTime = startTime.add(_duration);
    final signature = await databaseController.getSignatureByName(
      _signatureName!,
    );
    if (signature == null) {
      setState(() => _errorMessageSignature = "La asignatura ya no existe");
      return;
    }
    final alarm = Alarm(
      id: widget.event?.idAlarm,
      description: _textAlarmDescription,
      time: startTime.subtract(_alert),
    );
    Event event;
    if (_editing) {
      event = Event(
        id: widget.event!.id,
        name: _textEventName,
        eventType: _eventType!,
        startTime: startTime,
        endTime: endTime,
        color: _dialogSelectColor,
        idAlarm: widget.event!.idAlarm,
        idSignature: signature.id,
      );
      await databaseController.updateEvent(
        event: event,
        idSignature: signature.id!,
        alarm: alarm,
      );
    } else {
      event = await databaseController.insertEvent(
        event: Event(
          name: _textEventName,
          eventType: _eventType!,
          startTime: startTime,
          endTime: endTime,
          color: _dialogSelectColor,
        ),
        idSignature: signature.id!,
        alarm: alarm,
      );
    }
    if (_notificationIsEnabled) {
      await NotificationApi.scheduleEvent(event, alarm);
    } else {
      NotificationApi.cancelEvent(event.idAlarm!);
    }

    showSuccess(
      "Evento ${_editing ? "modificado" : "añadido"} satisfactoriamente",
    );
    Get.offAll(() => const MyHomePage());
  }

  bool validateEventType() => _eventType != null;
  bool validateSignature() => _signatureName != null;
  bool validateStartTime() =>
      _dateTime.isAfter(DateTime.now().add(const Duration(minutes: 1)));
  bool validateDuration() => _duration >= const Duration(minutes: 15);

  void _showDialogDeleteEvent() {
    showConfirmDialog(
      context,
      title: "¿Desea eliminar el evento?",
      onConfirm: () async {
        final isDeleted = await databaseController.deleteEvent(widget.event!);
        NotificationApi.cancelEvent(widget.event!.idAlarm!);
        if (isDeleted) showSuccess("Evento eliminado satisfactoriamente");
        Get.offAll(() => const MyHomePage());
      },
    );
  }

  Future<void> _showDialogAddAlert() async {
    if (!validateStartTime()) {
      setState(_checkStartTime);
      return;
    }
    final alert = await showDialog<Duration>(
      barrierDismissible: false,
      context: context,
      builder: (_) =>
          DialogAddAlertWidget(dateTime: _dateTime, initialAlert: _alert),
    );
    if (alert != null && mounted) {
      setState(() {
        _alert = alert;
        _errorMessageAlert = "";
      });
    }
  }
}
