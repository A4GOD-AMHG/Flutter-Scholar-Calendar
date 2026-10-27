import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:scholar_calendar/components/bottom_sheet_add_event_widget.dart';
import 'package:scholar_calendar/components/dialog_signature_widget.dart';
import 'package:scholar_calendar/controllers/database_controller.dart';
import 'package:scholar_calendar/screens/signatures_details_page.dart';

///[speedDialChild] opción del [SpeedDial] con el estilo de la app
SpeedDialChild speedDialChild(
  BuildContext context, {
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  final scheme = Theme.of(context).colorScheme;
  return SpeedDialChild(
    child: Icon(icon),
    label: label,
    backgroundColor: scheme.secondaryContainer,
    foregroundColor: scheme.onSecondaryContainer,
    labelBackgroundColor: scheme.surfaceContainerHighest,
    labelStyle: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w500),
    onTap: onTap,
  );
}

///[appSpeedDial] botón flotante desplegable con el estilo de la app
SpeedDial appSpeedDial(BuildContext context, List<SpeedDialChild> children) {
  final scheme = Theme.of(context).colorScheme;
  return SpeedDial(
    backgroundColor: scheme.primaryContainer,
    foregroundColor: scheme.onPrimaryContainer,
    activeBackgroundColor: scheme.error,
    activeForegroundColor: scheme.onError,
    overlayColor: Colors.black,
    overlayOpacity: 0.5,
    spacing: 5,
    spaceBetweenChildren: 12,
    animatedIcon: AnimatedIcons.menu_close,
    children: children,
  );
}

class FloatingActionButtonSpeedDial extends StatefulWidget {
  const FloatingActionButtonSpeedDial({super.key});

  @override
  State<FloatingActionButtonSpeedDial> createState() =>
      _FloatingActionButtonSpeedDialState();
}

class _FloatingActionButtonSpeedDialState
    extends State<FloatingActionButtonSpeedDial> {
  bool hasSignatures = true;

  @override
  void initState() {
    super.initState();
    loadState();
  }

  void loadState() async {
    final checkHasSignatures = await databaseController.hasSignatures();
    if (mounted) setState(() => hasSignatures = checkHasSignatures);
  }

  @override
  Widget build(BuildContext context) {
    return appSpeedDial(context, [
      if (hasSignatures)
        speedDialChild(
          context,
          icon: Icons.add_alarm_outlined,
          label: "Añadir Evento",
          onTap: () => showEventSheet(context),
        ),
      speedDialChild(
        context,
        icon: Icons.add,
        label: "Agregar Asignatura",
        onTap: () => showDialog(
          context: context,
          builder: (_) => const DialogSignatureWidget(returnToHome: true),
        ),
      ),
      speedDialChild(
        context,
        icon: Icons.class_outlined,
        label: "Ver Asignaturas",
        onTap: () => Get.offAll(() => const SignaturesDetailsPage()),
      ),
    ]);
  }
}
