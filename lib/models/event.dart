import 'package:flutter/material.dart';
import 'package:scholar_calendar/enums/event_type.dart';

///[Event] clase para modelar los eventos
class Event {
  int? id;
  late String name;
  late EventType eventType;
  late DateTime startTime;
  late DateTime endTime;
  late Color color;
  late int? idSignature;
  late int? idAlarm;

  ///[id] para identificar cada evento
  ///
  ///[name] nombre del evento
  ///
  ///[eventType] tipo de evento
  ///
  ///[startTime] fecha a la que comienza el evento
  ///
  ///[endTime] fecha de fin del evento
  ///
  ///[color] color del evento
  ///
  ///[idSignature] id de la asignatura relacionada con el evento
  ///
  ///[idAlarm] id de la alarma relacionada con el evento
  Event({
    this.id,
    required this.name,
    required this.eventType,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.idSignature,
    this.idAlarm,
  });

  ///[toMap]  método para convertir el evento en un [Map]
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'eventType': eventType.asString,
      'startTime': startTime.toString(),
      'endTime': endTime.toString(),
      'color': color.toARGB32(),
      'idSignature': idSignature,
      'idAlarm': idAlarm,
    };
  }

  ///[Event.fromMap] constructor nombrado para crear un evento pasándole el parámetro [map]
  Event.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    eventType = EventTypeModel.fromString(map['eventType'])!;
    startTime = DateTime.parse(map['startTime']);
    endTime = DateTime.parse(map['endTime']);
    color = Color(map['color']);
    idSignature = map['idSignature'];
    idAlarm = map['idAlarm'];
  }

  ///[toString]  método para convertir el evento en un cadena de texto
  @override
  String toString() =>
      'Event(id: $id, name: $name, eventType: $eventType, startTime: $startTime, endTime: $endTime, color: $color, idSignature: $idSignature, idAlarm: $idAlarm)';
}
