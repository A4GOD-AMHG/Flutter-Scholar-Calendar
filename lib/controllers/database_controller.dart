import 'package:scholar_calendar/database/database_provider.dart';
import 'package:scholar_calendar/models/alarm.dart';
import 'package:scholar_calendar/models/event.dart';
import 'package:scholar_calendar/models/signature.dart';

///[_DatabaseController] clase que controla la base de datos
class _DatabaseController {
  ///[init] método que abre (o crea) la base de datos
  Future<void> init() async {
    await DatabaseProvider.db.database;
  }

  ///[getSignatures] método que retorna una lista de las asignaturas
  Future<List<Signature>> getSignatures() async {
    return DatabaseProvider.db.getSignatures();
  }

  ///[getSignaturesNames] método que retorna una lista de todos los nombres de las asignaturas
  Future<List<String>> getSignaturesNames() async {
    return DatabaseProvider.db.getSignaturesNames();
  }

  ///[getEvents] método que retorna una lista de los eventos
  Future<List<Event>> getEvents() async {
    return DatabaseProvider.db.getEvents();
  }

  ///[getEventsNames] método que retorna una lista de nombres de los eventos
  Future<List<String>> getEventsNames() async {
    return DatabaseProvider.db.getEventsNames();
  }

  ///[getEventsOfSignatureById] método que retorna una lista de los eventos de una asignatura por id
  ///
  ///[id] id de la asignatura a la que se le buscan los eventos asociados
  Future<List<Event>> getEventsOfSignatureById(int id) async {
    return DatabaseProvider.db.getEventsOfSignatureById(id);
  }

  ///[countEventsByIdSignature] método que retorna la cantidad de eventos asociados a una asignatura por su id
  ///
  ///[id] id de la asignatura a la que se le va a buscar la cantidad de eventos
  Future<int> countEventsByIdSignature(int id) async {
    var events = await getEventsOfSignatureById(id);
    return events.length;
  }

  ///[getAlarms] método que retorna una lista de las alarmas
  Future<List<Alarm>> getAlarms() async {
    return DatabaseProvider.db.getAlarms();
  }

  ///[insertEvent] método para insertar un evento en la tabla Events
  ///
  ///[event] evento a insertar
  ///
  ///[idSignature] id de la asignatura relacionada con el evento
  ///
  ///[alarm] alarma del evento
  Future<Event> insertEvent({
    required Event event,
    required int idSignature,
    required Alarm alarm,
  }) async {
    return DatabaseProvider.db.insertEvent(
      event: event,
      idSignature: idSignature,
      alarm: alarm,
    );
  }

  ///[updateEvent] método para actualizar los datos de un evento
  ///
  ///[event] evento actualizado
  ///
  ///[idSignature] asignatura relacionada con el evento
  ///
  ///[alarm] alarma del evento (descripción y hora)
  ///
  ///retorna [true] si se actualiza con éxito, y [false] si no
  Future<bool> updateEvent({
    required Event event,
    required int idSignature,
    required Alarm alarm,
  }) async {
    return DatabaseProvider.db.updateEvent(
      event: event,
      idSignature: idSignature,
      alarm: alarm,
    );
  }

  ///[updateEventStartTimeById] método para actualizar la fecha de inicio de un evento
  ///
  ///[event] evento a cambiarle la fecha
  ///
  ///[startTime] fecha actualizada del evento
  ///
  ///retorna [true] si se actualiza con éxito, y [false] si no
  Future<bool> updateEventStartTimeById({
    required Event event,
    required DateTime startTime,
    DateTime? endTime,
  }) async {
    return DatabaseProvider.db.updateEventStartTimeById(
      event: event,
      startTime: startTime,
      endTime: endTime,
    );
  }

  ///[insertSignature] método para insertar una asignatura en la tabla Signature
  ///
  ///[signature] asignatura a insertar
  Future<Signature?> insertSignature(Signature signature) async {
    return DatabaseProvider.db.insertSignature(signature);
  }

  ///[updateSignature] método para actualizar los datos de una asignatura
  ///
  ///[signature] asignatura a actualizar
  ///
  ///retorna [true] si se actualiza con éxito, y [false] si no
  Future<bool> updateSignature(Signature signature) async {
    return DatabaseProvider.db.updateSignature(signature);
  }

  ///[deleteSignature] método para eliminar una asignatura
  ///
  ///[id] id de la asignatura a eliminar
  ///
  ///retorna [true] si los borra, y [false] si no
  Future<bool> deleteSignature(int id) async {
    return DatabaseProvider.db.deleteSignature(id);
  }

  ///[deleteAllSignatures] método para eliminar todas las alarmas
  ///
  ///retorna [true] si las borra, y [false] si no
  Future<bool> deleteAllSignatures() async {
    return DatabaseProvider.db.deleteAllSignatures();
  }

  ///[deleteEvent] método para eliminar un evento
  ///
  ///[id] id del evento a eliminar
  ///
  ///retorna [true] si lo borra, y [false] si no
  Future<bool> deleteEvent(Event event) async {
    return DatabaseProvider.db.deleteEvent(event);
  }

  ///[deleteAllEvents] método para eliminar todos los eventos
  ///
  ///retorna [true] si los borra, y [false] si no
  Future<bool> deleteAllEvents() async {
    return DatabaseProvider.db.deleteAllEvents();
  }

  ///[getAlarmById] método que retorna una alarma dado su id
  ///
  ///[id] id de la alarma a buscar
  Future<Alarm?> getAlarmById(int id) async {
    return DatabaseProvider.db.getAlarmById(id);
  }

  ///[getSignatureById] método que retorna una asignatura dado su id
  ///
  ///[id] id de la asignatura a buscar
  Future<Signature?> getSignatureById(int id) async {
    return DatabaseProvider.db.getSignatureById(id);
  }

  ///[getSignatureByName] método que retorna una asignatura dado su nombre
  ///
  ///[name] nombre de la asignatura a buscar
  Future<Signature?> getSignatureByName(String name) async {
    return DatabaseProvider.db.getSignatureByName(name);
  }

  ///[getSignatureBySymbology] método que retorna una asignatura dado su simbología
  ///
  ///[symbology] simbología de la asignatura a buscar
  Future<Signature?> getSignatureBySymbology(String symbology) async {
    return DatabaseProvider.db.getSignatureBySymbology(symbology);
  }

  ///[getEventById] método que retorna un evento dado su id
  ///
  ///[id] id del evento a buscar
  Future<Event?> getEventById(int id) async {
    return DatabaseProvider.db.getEventById(id);
  }

  ///[containSignatureName] método para saber si existe este nombre de asignatura en la base de datos
  ///
  ///[name] nombre a verificar
  ///
  ///retorna [true] cuando existe, y [false] si no
  Future<bool> containSignatureName(String name) async {
    return DatabaseProvider.db.containSignatureName(name);
  }

  ///[containSignatureSymbology] método para saber si existe esta simbología de asignatura en la base de datos
  ///
  ///[symbology] simbología a verificar
  ///
  ///retorna [true] cuando existe, y [false] si no
  Future<bool> containSignatureSymbology(String symbology) async {
    return DatabaseProvider.db.containSignatureSymbology(symbology);
  }

  ///[hasSignatures] método que retorna [true] si hay asignaturas en la base de datos y [false] si no
  Future<bool> hasSignatures() async {
    var signatures = await getSignatures();
    return signatures.isNotEmpty;
  }

  ///[hasEvents] método que retorna [true] si hay eventos en la base de datos y [false] si no
  Future<bool> hasEvents() async {
    var events = await getEvents();
    return events.isNotEmpty;
  }
}

///[databaseController] instancia de [_DatabaseController] utilizada para acceder a la base de datos
final databaseController = _DatabaseController();
