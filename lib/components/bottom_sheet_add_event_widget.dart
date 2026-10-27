import 'package:animate_do/animate_do.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:scholar_calendar/api/notification_api.dart';
import 'package:scholar_calendar/components/dialog_add_alert_widget.dart';
import 'package:scholar_calendar/components/dropdown_button_event_type.dart';
import 'package:scholar_calendar/components/dropdown_button_signature.dart';
import 'package:scholar_calendar/controllers/database_controller.dart';
import 'package:scholar_calendar/enums/event_type.dart';
import 'package:scholar_calendar/models/alarm.dart';
import 'package:scholar_calendar/models/event.dart';
import 'package:scholar_calendar/models/signature.dart';
import 'package:scholar_calendar/screens/home_page.dart';
import 'package:scholar_calendar/utils/features_discoveries.dart';

class BottomSheetAddEventWidget extends StatefulWidget {
  final Event? event;
  final String? textAlarmDescription;

  BottomSheetAddEventWidget({this.event, this.textAlarmDescription, Key? key})
      : super(key: key);

  @override
  State<BottomSheetAddEventWidget> createState() =>
      _BottomSheetAddEventWidgetState();
}

class _BottomSheetAddEventWidgetState extends State<BottomSheetAddEventWidget> {
  late String _textEventName;
  String? _textAlarmDescription;
  late DateTime _dateTime;
  late Duration _duration;
  late Duration _alert;
  bool _editing = false;
  bool _notificationIsEnabled = true;
  bool _switchIsEnabled = true;
  late BuildContext cont;
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
    if ((getShowDiscovery(key_add_event) ?? true) ||
        (getShowDiscovery(key_delete_event) ?? true)) {
      List<String> listId = [];
      if (_editing &&
          !(getShowDiscovery(key_add_event) ?? true) &&
          (getShowDiscovery(key_delete_event) ?? true)) {
        listId = [kFeatureId4DeleteEvent];
        setShowDiscovery(false, key_delete_event);
      } else if (!_editing && (getShowDiscovery(key_add_event) ?? true)) {
        listId = [kFeatureId5Color, kFeatureId6Alert, kFeatureId7Switch];
      } else {
        listId = [
          kFeatureId4DeleteEvent,
          kFeatureId5Color,
          kFeatureId6Alert,
          kFeatureId7Switch
        ];
        setShowDiscovery(false, key_delete_event);
      }

      WidgetsBinding.instance
          .addPostFrameCallback((Duration duration) async {
        showDiscovery(cont, listId: listId, key: key_add_event);
      });
    }
    _alert = Duration();
    if (_editing) {
      _dateTime = widget.event!.startTime;
      var difference =
          widget.event!.endTime.difference(widget.event!.startTime);

      _duration = Duration(minutes: difference.inMinutes);
      _textEventName = widget.event!.name;
      _textAlarmDescription = widget.textAlarmDescription;
      _dialogSelectColor = widget.event!.color;
    } else {
      _dateTime = DateTime.now();
      _duration = Duration(minutes: 15);
      _textEventName = "";
      _textAlarmDescription = "";

      _dialogSelectColor =
          Color(0xFF000000 | math.Random().nextInt(0x1000000));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Icon iconDeleteEvent = Icon(Icons.delete);
    Icon iconColor = Icon(
      Icons.circle,
      color: _dialogSelectColor,
    );
    Icon iconAlert = Icon(
      (_notificationIsEnabled) ? Icons.notifications : Icons.notifications_off,
      color: (_notificationIsEnabled) ? null : Colors.grey[400],
    );
    setState(() {
      cont = context;
    });
    var size = MediaQuery.of(context).size;
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.only(top: size.height * 1 / 25),
      child: ListView(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: Column(children: [
                  _buildContainer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          (_editing) ? "Editar Evento" : "Añadir Evento",
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.onSurface,
                              fontSize: 18),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              if (_editing)
                                buildWidget(context,
                                    featureId: kFeatureId4DeleteEvent,
                                    tapTarget: iconDeleteEvent,
                                    child: IconButton(
                                        onPressed: () async =>
                                            _showDialogDeleteEvent(context),
                                        icon: iconDeleteEvent),
                                    contentLocation: ContentLocation.below,
                                    title: "Eliminar",
                                    description:
                                        "Pulse aquí para eliminar este evento"),
                              buildWidget(context,
                                  featureId: kFeatureId5Color,
                                  tapTarget: iconColor,
                                  child: Container(
                                    height: 45,
                                    width: 45,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey,
                                    ),
                                    child: IconButton(
                                        iconSize: 30,
                                        onPressed: () async {
                                          final Color newColor =
                                              await showColorPickerDialog(
                                                  context,
                                                  _dialogSelectColor,
                                                  backgroundColor:
                                                      Theme.of(context).colorScheme.surface,
                                                  selectedPickerTypeColor:
                                                      Theme.of(context).colorScheme.surfaceContainerHigh,
                                                  borderColor:
                                                      Theme.of(context).colorScheme.onSurface,
                                                  title: Text(
                                                    "Seleccione el color",
                                                    style: TextStyle(
                                                      color: Theme.of(context).colorScheme.onSurface,
                                                    ),
                                                  ),
                                                  titleTextStyle: TextStyle(
                                                    color: Theme.of(context).colorScheme.onSurface,
                                                  ),
                                                  pickerTypeTextStyle:
                                                      TextStyle(
                                                    color: Theme.of(context).colorScheme.onSurface,
                                                  ),
                                                  pickerTypeLabels: <
                                                      ColorPickerType, String>{
                                                    ColorPickerType.primary:
                                                        "Primarios",
                                                    ColorPickerType.accent:
                                                        "Acentuados",
                                                  },
                                                  actionButtons:
                                                      const ColorPickerActionButtons(
                                                    closeButton: true,
                                                    dialogActionIcons: true,
                                                  ));
                                          setState(() {
                                            _dialogSelectColor = newColor;
                                          });
                                        },
                                        icon: iconColor),
                                  ),
                                  contentLocation: ContentLocation.below,
                                  title: "Color",
                                  description:
                                      "Toque aquí para seleccionar el color del evento"),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  _buildContainer(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            initialValue: _textEventName,
                            decoration: InputDecoration(
                              labelText: "Nombre",
                              labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface),
                            ),
                            style: TextStyle(
                              fontSize: 18,
                              color:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                            onSaved: (newValue) {
                              _textEventName = newValue!;
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Llene este campo";
                              }
                            },
                          ),
                          TextFormField(
                            maxLength: 150,
                            minLines: 1,
                            maxLines: 4,
                            keyboardType: TextInputType.multiline,
                            expands: false,
                            initialValue: _textAlarmDescription,
                            decoration: InputDecoration(
                              labelText: "Descripción",
                              labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface),
                              suffix: Icon(Icons.event_note_outlined),
                              helperText: "Opcional",
                              helperStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 18,
                              color:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                            onSaved: (newValue) {
                              _textAlarmDescription = newValue!;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildContainer(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonEventTypeWidget(),
                                if (_errorMessageEventType.isNotEmpty)
                                  ElasticIn(
                                    child: Text(
                                      _errorMessageEventType,
                                      style: TextStyle(
                                          color: Colors.red[700], fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonSignatureWidget(),
                                if (_errorMessageSignature.isNotEmpty)
                                  ElasticIn(
                                    child: Text(
                                      _errorMessageSignature,
                                      style: TextStyle(
                                          color: Colors.red[700], fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildContainer(
                    child: Column(children: [
                      Localizations(
                        delegates: const [
                          GlobalMaterialLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                          DefaultWidgetsLocalizations.delegate,
                        ],
                        locale: const Locale('es'),
                        child: SizedBox(
                          height: size.height * 1 / 10,
                          child: CupertinoTheme(
                            data: CupertinoThemeData(
                                textTheme: CupertinoTextThemeData(
                                    pickerTextStyle: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context).colorScheme.onSurface),
                                    dateTimePickerTextStyle: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface)),
                                brightness: Theme.of(context).brightness),
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.dateAndTime,
                              initialDateTime: (_editing &&
                                      _dateTime.compareTo(DateTime.now()
                                              .add(Duration(minutes: 1))) >
                                          0)
                                  ? _dateTime
                                  : DateTime.now().add(Duration(minutes: 1)),
                              minimumDate: DateTime.now(),
                              onDateTimeChanged: (DateTime dateTime) {
                                setState(() {
                                  _dateTime = dateTime;
                                  if (!validateStartTime()) {
                                    _errorMessageStartTime =
                                        "La fecha seleccionada no puede ser menor que la fecha actual";
                                    _errorMessageAlert =
                                        "Seleccione una fecha correcta para poder añadir una alarma o alerta";
                                    _notificationIsEnabled = false;
                                    _switchIsEnabled = false;
                                  } else {
                                    _errorMessageStartTime = "";
                                    _errorMessageAlert = "";
                                    _switchIsEnabled = true;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      if (_errorMessageStartTime.isNotEmpty)
                        ElasticIn(
                          child: Text(
                            _errorMessageStartTime,
                            style:
                                TextStyle(color: Colors.red[700], fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ]),
                  ),
                  _buildContainer(
                    child: Column(children: [
                      Localizations(
                        delegates: const [
                          GlobalMaterialLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                          DefaultWidgetsLocalizations.delegate,
                        ],
                        locale: const Locale('es'),
                        child: SizedBox(
                          height: size.height * 1 / 10,
                          child: CupertinoTheme(
                            data: CupertinoThemeData(
                                textTheme: CupertinoTextThemeData(
                                    pickerTextStyle: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context).colorScheme.onSurface),
                                    dateTimePickerTextStyle: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface)),
                                brightness: Theme.of(context).brightness),
                            child: CupertinoTimerPicker(
                              initialTimerDuration: _duration,
                              mode: CupertinoTimerPickerMode.hm,
                              onTimerDurationChanged: (Duration duration) {
                                setState(() {
                                  _duration = duration;
                                  if (!validateDuration()) {
                                    _errorMessageDuration =
                                        "La duración no puede ser menos de 15 minutos";
                                  } else {
                                    _errorMessageDuration = "";
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      if (_errorMessageDuration.isNotEmpty)
                        ElasticIn(
                          child: Text(
                            _errorMessageDuration,
                            style:
                                TextStyle(color: Colors.red[700], fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        )
                    ]),
                  ),
                  _buildContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Alarma",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 18),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                buildWidget(context,
                                    featureId: kFeatureId6Alert,
                                    tapTarget: iconAlert,
                                    child: IconButton(
                                      onPressed: !_notificationIsEnabled
                                          ? null
                                          : _showDialogAddAlert,
                                      icon: iconAlert,
                                    ),
                                    contentLocation: ContentLocation.above,
                                    title: "Recordatorio",
                                    description:
                                        "Cuando la alarma esté activa pulse aquí\npara especificar un recordatorio del evento"),
                                buildWidget(context,
                                    featureId: kFeatureId7Switch,
                                    tapTarget: Switch(
                                      value: _notificationIsEnabled,
                                      activeColor: _dialogSelectColor,
                                      onChanged: (value) {},
                                    ),
                                    child: Switch(
                                        activeColor: _dialogSelectColor,
                                        value: _notificationIsEnabled,
                                        onChanged: (_switchIsEnabled)
                                            ? (isActivated) {
                                                setState(() {
                                                  _notificationIsEnabled =
                                                      isActivated;
                                                });
                                              }
                                            : null),
                                    contentLocation: ContentLocation.above,
                                    title: "Alarma",
                                    description:
                                        "Pulse aquí para activar o desactivar la alarma del evento"),
                              ],
                            ),
                          ],
                        ),
                        if (_errorMessageAlert.isNotEmpty &&
                                _notificationIsEnabled ||
                            !_switchIsEnabled)
                          ElasticIn(
                            child: Text(
                              _errorMessageAlert,
                              style: TextStyle(
                                  color: Colors.red[700], fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                ]),
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: _save,
                    child: const Text(
                      "Guardar",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _textEventName = "";

                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
                mainAxisSize: MainAxisSize.max,
              )
            ],
          )
        ],
      ),
    );
  }

  Container _buildContainer({required Widget child, double? width}) {
    return Container(
      width: width,
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
            ),
          ],
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          border: Border.all(
            width: 0.1,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          borderRadius: BorderRadius.circular(20)),
      child: child,
    );
  }

  void _save() async {
    if (!validateEventType()) {
      setState(() => _errorMessageEventType = "Seleccione el tipo de evento");
    } else {
      setState(() => _errorMessageEventType = "");
    }
    if (!validateSignature()) {
      setState(() => _errorMessageSignature = "Seleccione la asignatura");
    } else {
      setState(() => _errorMessageSignature = "");
    }
    if (!validateStartTime()) {
      setState(() {
        _errorMessageStartTime =
            "La fecha seleccionada no puede ser menor que la fecha actual";
        _errorMessageAlert =
            "Seleccione una fecha correcta para poder añadir una alarma o alerta";

        _notificationIsEnabled = false;
        _switchIsEnabled = false;
      });
    } else {
      setState(() {
        _errorMessageStartTime = "";
        _errorMessageAlert = "";
        _switchIsEnabled = true;
      });
    }
    if (!validateDuration()) {
      setState(() => _errorMessageDuration =
          "La duración no puede ser menos de 15 minutos");
    } else {
      setState(() => _errorMessageDuration = "");
    }
    if (_formKey.currentState!.validate() &&
        validateEventType() &&
        validateSignature() &&
        validateStartTime() &&
        validateDuration()) {
      _formKey.currentState!.save();

      setState(() {
        _errorMessageEventType = "";
        _errorMessageSignature = "";
        _errorMessageStartTime = "";
        _errorMessageDuration = "";
        _errorMessageAlert = "";
      });

      var startTime = DateTime(_dateTime.year, _dateTime.month, _dateTime.day,
          _dateTime.hour, _dateTime.minute);
      var endTime = startTime.add(_duration);
      Signature? signature = await databaseController
          .getSignatureByName(DropdownButtonSignatureWidget.value!);
      Alarm alarm = Alarm(
        description: _textAlarmDescription,
        time: startTime.subtract(_alert),
      );
      Event? event;
      if (_editing) {
        event = Event(
            id: widget.event!.id,
            name: _textEventName,
            eventType:
                EventTypeModel.fromString(DropdownButtonEventTypeWidget.value)!,
            startTime: _dateTime,
            endTime: _dateTime.add(_duration),
            color: _dialogSelectColor,
            idAlarm: widget.event!.idAlarm,
            idSignature: widget.event!.idSignature);
        await databaseController.updateEvent(
            event: event,
            idSignature: signature!.id!,
            description: _textAlarmDescription);
      } else {
        event = await databaseController.insertEvent(
          event: Event(
              name: _textEventName,
              eventType: EventTypeModel.fromString(
                  DropdownButtonEventTypeWidget.value)!,
              startTime: startTime,
              endTime: endTime,
              color: _dialogSelectColor),
          idSignature: signature!.id!,
          alarm: alarm,
        );
      }
      if (_notificationIsEnabled) {
        if (_alert.compareTo(Duration()) != 0) {
          await NotificationApi.showScheduledNotification(
            id: (event.idAlarm! * -1) - 1,
            title: "Recordatorio del evento " + event.name,
            body:
                "Este evento será dentro de  ${_alert.inMinutes} ${(_alert.inMinutes == 1) ? "minuto" : "minutos"}",
            scheduledDate: startTime.subtract(_alert),
            
          );
        }
        await NotificationApi.showScheduledNotification(
          id: event.idAlarm!,
          title: event.name,
          body: alarm.description,
          scheduledDate: startTime,
          
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
              "Evento ${(_editing) ? "modificado" : "añadido"} satisfactoriamente"),
        ),
      );
      Get.offAll(() => MyHomePage());
    }
  }

  bool validateEventType() => DropdownButtonEventTypeWidget.value != null;
  bool validateSignature() => DropdownButtonSignatureWidget.value != null;
  bool validateStartTime() =>
      _dateTime.compareTo(DateTime.now().add(Duration(minutes: 1))) > 0;
  bool validateDuration() => _duration.compareTo(Duration(minutes: 15)) >= 0;
  bool validateAlert() =>
      _dateTime.subtract(_alert).compareTo(DateTime.now()) >= 0 &&
      _notificationIsEnabled;

  void _showDialogDeleteEvent(BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          "¿Desea eliminar el evento?",
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                              onPressed: () async {
                                bool isDeleted = await databaseController
                                    .deleteEvent(widget.event!);
                                if (isDeleted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Colors.green,
                                      content: Text(
                                          "Evento eliminado satisfactoriamente"),
                                    ),
                                  );
                                }
                                NotificationApi.cancel(widget.event!.idAlarm!);
                                Get.offAll(() => MyHomePage());
                              },
                              child: const Text(
                                "Aceptar",
                                style: TextStyle(fontSize: 18),
                              )),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Cancelar",
                                style: TextStyle(fontSize: 18),
                              ))
                        ],
                        mainAxisSize: MainAxisSize.min,
                      )
                    ],
                  )
                ],
              ),
            ));
  }

  void _showDialogAddAlert() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return DialogAddAlertWidget(
          dateTime: _dateTime,
          errorMessageAlert: _errorMessageAlert,
          onChange: () => setState(() {
            if (!validateStartTime()) {
              _errorMessageAlert =
                  "Seleccione una fecha correcta para poder añadir una alarma o alerta";
              _errorMessageStartTime =
                  "La fecha seleccionada no puede ser menor que la fecha actual";
              _notificationIsEnabled = false;
              _switchIsEnabled = false;
            } else if (_dateTime.subtract(_alert).compareTo(DateTime.now()) <
                0) {
              _errorMessageAlert =
                  "La alerta no puede ser menor que la hora actual";
            } else {
              _errorMessageAlert = "";
              setState(() {
                _alert = DialogAddAlertWidget.alert;
              });
            }
          }),
        );
      },
    );
  }
}
