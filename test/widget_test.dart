import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholar_calendar/enums/event_type.dart';
import 'package:scholar_calendar/models/alarm.dart';
import 'package:scholar_calendar/models/event.dart';

void main() {
  test('EventType se convierte a texto y de vuelta', () {
    for (final type in EventType.values) {
      expect(EventTypeModel.fromString(type.asString), type);
    }
    expect(EventTypeModel.fromString('desconocido'), isNull);
  });

  test('Event sobrevive a toMap/fromMap (formato de la base de datos)', () {
    final event = Event(
      name: 'Parcial',
      eventType: EventType.exam,
      startTime: DateTime(2026, 3, 10, 9),
      endTime: DateTime(2026, 3, 10, 11),
      color: const Color(0xFF094C90),
      idSignature: 1,
      idAlarm: 2,
    );
    final copy = Event.fromMap({...event.toMap(), 'id': 7});

    expect(copy.id, 7);
    expect(copy.name, event.name);
    expect(copy.eventType, event.eventType);
    expect(copy.startTime, event.startTime);
    expect(copy.endTime, event.endTime);
    expect(copy.color, event.color);
    expect(copy.idSignature, 1);
    expect(copy.idAlarm, 2);
  });

  test('Alarm sobrevive a toMap/fromMap', () {
    final alarm = Alarm(description: null, time: DateTime(2026, 3, 10, 8, 45));
    final copy = Alarm.fromMap({...alarm.toMap(), 'id': 3});
    expect(copy.id, 3);
    expect(copy.description, isNull);
    expect(copy.time, alarm.time);
  });
}
