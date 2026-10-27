import 'package:scholar_calendar/controllers/database_controller.dart';
import 'package:scholar_calendar/enums/event_type.dart';
import 'package:scholar_calendar/models/event.dart';
import 'package:scholar_calendar/models/signature.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SignatureEventsDetailsPage extends StatelessWidget {
  final Signature signature;
  SignatureEventsDetailsPage({required this.signature, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          signature.name,
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showDialogHelp(context);
            },
            icon: Icon(
              Icons.help_outline_outlined,
            ),
          )
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: databaseController.getEventsOfSignatureById(signature.id!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Event>? list = snapshot.data;
            if (list!.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info,
                        size: 120,
                        color: Colors.grey,
                      ),
                      Text(
                        "No hay eventos asociados a la asignatura",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      )
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  Event? event = list[index];
                  Color borderEventColor = Colors.green;
                  if (event.startTime.isBefore(DateTime.now()) &&
                      event.endTime.isAfter(DateTime.now())) {
                    borderEventColor = Colors.red;
                  } else if (event.endTime.isBefore(DateTime.now())) {
                    borderEventColor = Colors.grey;
                  }
                  return Container(
                    margin: EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      border: Border.all(color: borderEventColor, width: 2),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.event_outlined,
                        color: event.color,
                        size: 64,
                      ),
                      title: Text(
                        event.name,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w900),
                      ),
                      isThreeLine: true,
                      subtitle: Text(
                        "Tipo: ${event.eventType.asString}\n"
                        "Fecha: ${DateFormat('EEEE, d', 'es_ES').format(event.startTime)} de ${DateFormat('MMMM', 'es_ES').format(event.startTime)} a las ${DateFormat('hh:mm a', 'es_ES').format(event.startTime)}\n"
                        "Duración: ${event.endTime.difference(event.startTime).inMinutes} minutos",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  );
                });
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  void _showDialogHelp(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actions: [
              ListTile(
                leading: Icon(Icons.help_outline_outlined),
                contentPadding: EdgeInsets.all(2),
                title: Text(
                  "Ayuda",
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "Los eventos con el borde gris significa que ya ocurrieron.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Los eventos con el borde rojo significa que estan ocurriendo en este instante.",
                      style: TextStyle(fontSize: 14, color: Colors.red),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Los eventos con el borde verde significa que estan por ocurrir.",
                      style: TextStyle(fontSize: 14, color: Colors.green),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cerrar",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          );
        });
  }
}
