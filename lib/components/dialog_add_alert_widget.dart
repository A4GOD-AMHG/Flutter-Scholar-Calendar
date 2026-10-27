import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///[DialogAddAlertWidget] diálogo para elegir con cuánta antelación avisar del evento.
///
///Devuelve la [Duration] elegida con [Navigator.pop], o `null` si se cancela.
class DialogAddAlertWidget extends StatefulWidget {
  final DateTime dateTime;
  final Duration initialAlert;

  const DialogAddAlertWidget({
    required this.dateTime,
    this.initialAlert = Duration.zero,
    super.key,
  });

  @override
  State<DialogAddAlertWidget> createState() => _DialogAddAlertWidgetState();
}

class _DialogAddAlertWidgetState extends State<DialogAddAlertWidget> {
  late Duration _alert = widget.initialAlert;
  String _error = "";

  String _validate() {
    if (widget.dateTime.isBefore(
      DateTime.now().add(const Duration(minutes: 1)),
    )) {
      return "Seleccione una fecha correcta para poder añadir una alarma o alerta";
    }
    if (widget.dateTime.subtract(_alert).isBefore(DateTime.now())) {
      return "La alerta no puede ser menor que la hora actual";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = TextStyle(fontSize: 18, color: theme.colorScheme.onSurface);
    return PopScope(
      canPop: false,
      child: AlertDialog(
        icon: const Icon(Icons.alarm_add_outlined),
        title: const Text("Añadir Alerta"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Seleccione el tiempo antes que desea recibir un recordatorio",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: theme.brightness,
                  textTheme: CupertinoTextThemeData(
                    pickerTextStyle: style,
                    dateTimePickerTextStyle: style,
                  ),
                ),
                child: CupertinoTimerPicker(
                  initialTimerDuration: _alert,
                  mode: CupertinoTimerPickerMode.hm,
                  onTimerDurationChanged: (duration) => setState(() {
                    _alert = duration;
                    _error = _validate();
                  }),
                ),
              ),
            ),
            if (_error.isNotEmpty)
              ElasticIn(
                child: Text(
                  _error,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () {
              final error = _validate();
              if (error.isEmpty) {
                Navigator.pop(context, _alert);
              } else {
                setState(() => _error = error);
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }
}
