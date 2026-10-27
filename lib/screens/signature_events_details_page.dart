import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scholar_calendar/components/empty_state.dart';
import 'package:scholar_calendar/controllers/database_controller.dart';
import 'package:scholar_calendar/enums/event_type.dart';
import 'package:scholar_calendar/models/event.dart';
import 'package:scholar_calendar/models/signature.dart';

///Estado temporal de un evento respecto al momento actual
enum _EventStatus {
  past(
    Colors.grey,
    "Los eventos con el borde gris significa que ya ocurrieron.",
  ),
  ongoing(
    Colors.red,
    "Los eventos con el borde rojo significa que estan ocurriendo en este instante.",
  ),
  upcoming(
    Colors.green,
    "Los eventos con el borde verde significa que estan por ocurrir.",
  );

  const _EventStatus(this.color, this.help);
  final Color color;
  final String help;

  static _EventStatus of(Event event) {
    final now = DateTime.now();
    if (event.endTime.isBefore(now)) return past;
    if (event.startTime.isBefore(now)) return ongoing;
    return upcoming;
  }
}

class SignatureEventsDetailsPage extends StatefulWidget {
  final Signature signature;
  const SignatureEventsDetailsPage({required this.signature, super.key});

  @override
  State<SignatureEventsDetailsPage> createState() =>
      _SignatureEventsDetailsPageState();
}

class _SignatureEventsDetailsPageState
    extends State<SignatureEventsDetailsPage> {
  // se crea una sola vez para no repetir la consulta en cada reconstrucción
  late final Future<List<Event>> _events = databaseController
      .getEventsOfSignatureById(widget.signature.id!);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.signature.name),
        actions: [
          IconButton(
            tooltip: "Ayuda",
            onPressed: () => _showDialogHelp(context),
            icon: const Icon(Icons.help_outline_outlined),
          ),
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: _events,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const EmptyState(
              icon: Icons.error_outline,
              message: "No se pudieron cargar los eventos",
            );
          }
          final list = snapshot.data;
          if (list == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.event_busy_outlined,
              message: "No hay eventos asociados a la asignatura",
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: list.length,
            itemBuilder: (context, index) => _buildEvent(context, list[index]),
          );
        },
      ),
    );
  }

  Widget _buildEvent(BuildContext context, Event event) {
    final status = _EventStatus.of(event);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: status.color, width: 2),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(Icons.event_outlined, color: event.color, size: 48),
        title: Text(
          event.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        isThreeLine: true,
        subtitle: Text(
          "Tipo: ${event.eventType.asString}\n"
          "Fecha: ${DateFormat('EEEE, d', 'es_ES').format(event.startTime)} de ${DateFormat('MMMM', 'es_ES').format(event.startTime)} a las ${DateFormat('hh:mm a', 'es_ES').format(event.startTime)}\n"
          "Duración: ${event.endTime.difference(event.startTime).inMinutes} minutos",
        ),
      ),
    );
  }

  void _showDialogHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.help_outline_outlined),
          title: const Text("Ayuda"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final status in _EventStatus.values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.circle, color: status.color, size: 16),
                  title: Text(
                    status.help,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }
}
