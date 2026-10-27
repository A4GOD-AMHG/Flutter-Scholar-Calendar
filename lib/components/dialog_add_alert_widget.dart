import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// ignore: must_be_immutable
class DialogAddAlertWidget extends StatefulWidget {
  DateTime dateTime;
  static Duration alert = Duration();
  String errorMessageAlert;
  VoidCallback? onChange;
  DialogAddAlertWidget(
      {required this.dateTime,
      required this.errorMessageAlert,
      required this.onChange,
      Key? key})
      : super(key: key);

  @override
  State<DialogAddAlertWidget> createState() => _DialogAddAlertWidgetState();
}

class _DialogAddAlertWidgetState extends State<DialogAddAlertWidget> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Añadir Alerta",
                style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text(
                "Seleccione el tiempo antes que desea recibir un recordatorio",
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            Localizations(
              delegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                DefaultWidgetsLocalizations.delegate,
              ],
              locale: const Locale('es'),
              child: SizedBox(
                height: 100,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                          pickerTextStyle: TextStyle(
                              fontSize: 18,
                              color:
                                  Theme.of(context).colorScheme.onSurface),
                          dateTimePickerTextStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface)),
                      brightness: Theme.of(context).brightness),
                  child: CupertinoTimerPicker(
                    initialTimerDuration: Duration(),
                    mode: CupertinoTimerPickerMode.hm,
                    onTimerDurationChanged: (Duration duration) {
                      setState(() {
                        DialogAddAlertWidget.alert = duration;
                        if (widget.dateTime
                                .subtract(DialogAddAlertWidget.alert)
                                .compareTo(DateTime.now()) <
                            0) {
                          widget.errorMessageAlert =
                              "La alerta no puede ser menor que la hora actual";
                        } else if (DialogAddAlertWidget.alert
                                .compareTo(Duration()) ==
                            0) {
                          widget.errorMessageAlert = "";
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
            if (widget.errorMessageAlert.isNotEmpty)
              ElasticIn(
                child: Text(
                  widget.errorMessageAlert,
                  style: TextStyle(color: Colors.red[700], fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () async {
                      if (widget.dateTime
                          .isBefore(DateTime.now().add(Duration(minutes: 1)))) {
                        setState(() {
                          widget.errorMessageAlert =
                              "Seleccione una fecha correcta para poder añadir una alarma o alerta";
                        });
                        widget.onChange!();
                      } else if (widget.dateTime
                              .subtract(DialogAddAlertWidget.alert)
                              .compareTo(DateTime.now()) <
                          0) {
                        setState(() {
                          widget.errorMessageAlert =
                              "La alerta no puede ser menor que la hora actual";
                        });
                      } else {
                        setState(() {
                          widget.errorMessageAlert = "";
                        });
                        widget.onChange!();

                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text(
                      "Guardar",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        DialogAddAlertWidget.alert = Duration();
                      });
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
