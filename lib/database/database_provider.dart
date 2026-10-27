import 'package:path/path.dart';
import 'package:scholar_calendar/enums/event_type.dart';
import 'package:scholar_calendar/models/alarm.dart';
import 'package:scholar_calendar/models/event.dart';
import 'package:scholar_calendar/models/signature.dart';
import 'package:sqflite/sqflite.dart';

///[DatabaseProvider]  clase que provee la base de datos
class DatabaseProvider {
  DatabaseProvider._();

  static final DatabaseProvider db = DatabaseProvider._();

  Database? _database;

  Future<Database>? _opening;

  ///[database] abre la base de datos una sola vez, aunque se pida en paralelo
  Future<Database> get database async =>
      _database ??= await (_opening ??= createDatabase());

  ///[createDatabase] método que crea la base de datos
  Future<Database> createDatabase() async {
    String dbPath = await getDatabasesPath();

    // contiene la consulta SQL para crear la tabla Signature
    String querySignature =
        "CREATE TABLE Signature("
        "id INTEGER PRIMARY KEY AUTOINCREMENT," // el id se autoincrementa
        "name TEXT NOT NULL UNIQUE," // el nombre de la asignatura es único y es obligatorio
        "symbology TEXT NOT NULL UNIQUE);"; // la sombología de la asignatura es única y es obligatoria

    // contiene la consulta SQL para crear la tabla Alarm
    String queryAlarm =
        "CREATE TABLE Alarm("
        "id INTEGER PRIMARY KEY AUTOINCREMENT," // el id se autoincrementa
        "description TEXT," //descripción opcional de la alarma
        "time TEXT NOT NULL);"; //fecha de la alarma convertida en [String]

    /// contiene la consulta SQL para crear la tabla Event
    String queryEvent =
        "CREATE TABLE Event("
        "id INTEGER PRIMARY KEY AUTOINCREMENT," // el id se autoincrementa
        "name TEXT NOT NULL," //nombre del evento, es obligatorio
        "eventType TEXT NOT NULL," //tipo de evento, es obligatorio
        "startTime TEXT NOT NULL," //fecha de inicio del evento convertida en [String], es obligatorio
        "endTime TEXT NOT NULL," //fecha de fin del evento convertida en [String], es obligatorio
        "color INTEGER NOT NULL," //color del evento, convertido en [int]
        "idSignature INTEGER NOT NULL," //id de la asignatura relacionda con el evento
        "idAlarm INTEGER NOT NULL," //id de la alarma del evento
        "FOREIGN KEY(idSignature) REFERENCES Signature(id) ON DELETE CASCADE," //llave foránea de asignatura, permite la eliminación en cascada
        "FOREIGN KEY(idAlarm) REFERENCES Alarm(id));"; //llave foránea de alarma

    //variable que contiene todas las consultas
    List<String> queries = [querySignature, queryAlarm, queryEvent];
    return await openDatabase(
      join(dbPath, 'eventDB.db'), //archivo que contiene la base de datos
      version: 1, //versión de la base de datos
      onConfigure: onConfigure,
      onCreate: (Database database, int version) async {
        for (String currentQuery in queries) {
          //ejecuta las consultas de una en una
          await database.execute(currentQuery);
        }
      },
    );
  }

  ///[onConfigure] método que contiene las configuraciones de la base de datos
  Future onConfigure(Database db) async {
    await db.execute(
      "PRAGMA foreign_keys = ON",
    ); //permite la eliminación en cascada
  }

  ///[getSignatures] método que retorna una lista de las asignaturas
  Future<List<Signature>> getSignatures() async {
    final db = await database;

    var signatures = await db.query(
      'Signature',
      columns: ['id', 'name', 'symbology'],
      orderBy: "name ASC",
    );

    return signatures.map(Signature.fromMap).toList();
  }

  ///[getSignaturesNames] método que retorna una lista de todos los nombres de las asignaturas
  Future<List<String>> getSignaturesNames() async {
    List<Signature> signatures = await getSignatures();
    return signatures.map((e) => e.name).toList();
  }

  ///[getEvents] método que retorna una lista de los eventos
  Future<List<Event>> getEvents() async {
    final db = await database;

    var events = await db.query(
      'Event',
      columns: [
        'id',
        'name',
        'eventType',
        'startTime',
        'endTime',
        'color',
        'idSignature',
        'idAlarm',
      ],
      orderBy: "startTime ASC",
    );

    return events.map(Event.fromMap).toList();
  }

  ///[getEventsNames] método que retorna una lista de nombres de los eventos
  Future<List<String>> getEventsNames() async {
    List<Event> events = await getEvents();
    return events.map((e) => e.name).toList();
  }

  ///[getEventsOfSignatureById] método que retorna una lista de los eventos de una asignatura por id
  ///
  ///[id] id de la asignatura a la que se le buscan los eventos asociados
  Future<List<Event>> getEventsOfSignatureById(int id) async {
    final db = await database;

    var events = await db.query(
      'Event',
      columns: [
        'id',
        'name',
        'eventType',
        'startTime',
        'endTime',
        'color',
        'idSignature',
        'idAlarm',
      ],
      where: "idSignature = ?",
      whereArgs: [id],
      orderBy: "startTime ASC",
    );

    return events.map(Event.fromMap).toList();
  }

  ///[getAlarms] método que retorna una lista de las alarmas
  Future<List<Alarm>> getAlarms() async {
    final db = await database;

    var alarms = await db.query(
      'Alarm',
      columns: ['id', 'description', 'time'],
    );

    return alarms.map(Alarm.fromMap).toList();
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
    final db = await database;
    Alarm nalarm = await _insertAlarm(alarm);
    int idAlarm = nalarm.id!;
    event.id = await db.insert('Event', <String, Object?>{
      'name': event.name,
      'eventType': event.eventType.asString,
      'startTime': event.startTime.toString(),
      'endTime': event.endTime.toString(),
      'color': event.color.toARGB32(),
      'idSignature': idSignature,
      'idAlarm': idAlarm,
    });
    event.idSignature = idSignature;
    event.idAlarm = idAlarm;
    return event;
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
    final db = await database;

    var updateCountAlarm = await db.rawUpdate(
      '''UPDATE Alarm 
           SET description = ?, 
           time = ?
           WHERE id = ?
        ''',
      [alarm.description, alarm.time.toString(), event.idAlarm],
    );

    var updateCountEvent = await db.rawUpdate(
      '''UPDATE Event 
           SET name = ?, 
           eventType = ?,
           startTime = ?,
           endTime = ?,
           color = ?,
           idSignature = ?
           WHERE id = ?
        ''',
      [
        event.name,
        event.eventType.asString,
        event.startTime.toString(),
        event.endTime.toString(),
        event.color.toARGB32(),
        idSignature,
        event.id,
      ],
    );
    return updateCountAlarm != 0 && updateCountEvent != 0;
  }

  ///[updateEventStartTimeById] método para actualizar la fecha de inicio de un evento
  ///
  ///[event] evento a cambiarle la fecha
  ///
  ///[startTime] fecha actualizada del evento
  ///
  ///[endTime] nueva fecha de fin; si es nula se conserva la duración
  ///
  ///retorna [true] si se actualiza con éxito, y [false] si no
  Future<bool> updateEventStartTimeById({
    required Event event,
    required DateTime startTime,
    DateTime? endTime,
  }) async {
    final db = await database;
    // conserva la antelación del recordatorio respecto al inicio
    final alarm = await getAlarmById(event.idAlarm!);
    final reminderOffset = alarm == null
        ? Duration.zero
        : event.startTime.difference(alarm.time);
    var updateCountAlarm = await db.rawUpdate(
      '''UPDATE Alarm 
           SET time = ?
           WHERE id = ?
        ''',
      [startTime.subtract(reminderOffset).toString(), event.idAlarm],
    );
    endTime ??= startTime.add(event.endTime.difference(event.startTime));
    var updateCountEvent = await db.rawUpdate(
      '''UPDATE Event 
           SET startTime = ?,
           endTime = ?
           WHERE id = ?
        ''',
      [startTime.toString(), endTime.toString(), event.id],
    );
    return updateCountAlarm != 0 && updateCountEvent != 0;
  }

  ///[insertSignature] método para insertar una asignatura en la tabla Signature
  ///
  ///[signature] asignatura a insertar
  Future<Signature?> insertSignature(Signature signature) async {
    final db = await database;
    signature.id = await db.insert('Signature', signature.toMap());
    return signature;
  }

  ///[updateSignature] método para actualizar los datos de una asignatura
  ///
  ///[signature] asignatura a actualizar
  ///
  ///retorna [true] si se actualiza con éxito, y [false] si no
  Future<bool> updateSignature(Signature signature) async {
    final db = await database;

    var updateCountSignature = await db.rawUpdate(
      '''UPDATE Signature 
           SET name = ?, 
           symbology = ?
           WHERE id = ?
        ''',
      [signature.name, signature.symbology, signature.id],
    );
    return updateCountSignature != 0;
  }

  ///[insertAlarm] método para insertar una alarma en la tabla Alarms
  ///
  ///[alarm] alarma a insertar
  Future<Alarm> _insertAlarm(Alarm alarm) async {
    final db = await database;
    alarm.id = await db.insert('Alarm', alarm.toMap());
    return alarm;
  }

  ///[_deleteAlarm] método para eliminar una alarma
  ///
  ///[id] id de la alarma a eliminar
  ///
  ///retorna [true] si la borra, y [false] si no
  Future<bool> _deleteAlarm(int id) async {
    final db = await database;
    var deleteCount = await db.rawDelete(
      '''
        DELETE FROM Alarm 
        WHERE id = ?''',
      [id],
    );
    return deleteCount != 0;
  }

  ///[_deleteAllAlarms] método para eliminar todas las alarmas
  ///
  ///retorna [true] si las borra, y [false] si no
  Future<bool> _deleteAllAlarms() async {
    final db = await database;
    var deleteCount = await db.rawDelete('''
        DELETE FROM Alarm 
        ''');
    return deleteCount != 0;
  }

  ///[_deleteOrphanAlarms] elimina las alarmas cuyos eventos se borraron en cascada
  Future<void> _deleteOrphanAlarms(Database db) => db.rawDelete(
    'DELETE FROM Alarm WHERE id NOT IN (SELECT idAlarm FROM Event)',
  );

  ///[deleteSignature] método para eliminar una asignatura
  ///
  ///[id] id de la asignatura a eliminar
  ///
  ///retorna [true] si los borra, y [false] si no
  Future<bool> deleteSignature(int id) async {
    final db = await database;
    var deleteCount = await db.rawDelete(
      '''
        DELETE FROM Signature 
        WHERE id = ?''',
      [id],
    );
    await _deleteOrphanAlarms(db);
    return deleteCount != 0;
  }

  ///[deleteAllSignatures] método para eliminar todas las alarmas
  ///
  ///retorna [true] si las borra, y [false] si no
  Future<bool> deleteAllSignatures() async {
    final db = await database;
    var deleteCount = await db.rawDelete('''
        DELETE FROM Signature 
        ''');
    await _deleteOrphanAlarms(db);
    return deleteCount != 0;
  }

  ///[deleteEvent] método para eliminar un evento
  ///
  ///[id] id del evento a eliminar
  ///
  ///retorna [true] si lo borra, y [false] si no
  Future<bool> deleteEvent(Event event) async {
    final db = await database;

    var deleteCount = await db.rawDelete(
      '''
        DELETE FROM Event 
        WHERE id = ?''',
      [event.id],
    );
    await _deleteAlarm(event.idAlarm!);
    return deleteCount != 0;
  }

  ///[deleteAllEvents] método para eliminar todos los eventos
  ///
  ///retorna [true] si los borra, y [false] si no
  Future<bool> deleteAllEvents() async {
    final db = await database;

    var deleteCount = await db.rawDelete('''
        DELETE FROM Event 
       ''');
    await _deleteAllAlarms();
    return deleteCount != 0;
  }

  ///[getAlarmById] método que retorna una alarma dado su id
  ///
  ///[id] id de la alarma a buscar
  Future<Alarm?> getAlarmById(int id) async {
    final db = await database;
    var alarms = await db.rawQuery(
      '''
    SELECT * FROM Alarm
    WHERE id = ?''',
      [id],
    );
    return alarms.isEmpty ? null : Alarm.fromMap(alarms.first);
  }

  ///[getSignatureById] método que retorna una asignatura dado su id
  ///
  ///[id] id de la asignatura a buscar
  Future<Signature?> getSignatureById(int id) async {
    final db = await database;
    var signatures = await db.rawQuery(
      '''
    SELECT * FROM Signature
    WHERE id = ?''',
      [id],
    );
    return signatures.isEmpty ? null : Signature.fromMap(signatures.first);
  }

  ///[getSignatureByName] método que retorna una asignatura dado su nombre
  ///
  ///[name] nombre de la asignatura a buscar
  Future<Signature?> getSignatureByName(String name) async {
    final db = await database;
    var signatures = await db.rawQuery(
      '''
    SELECT * FROM Signature
    WHERE name = ?''',
      [name],
    );
    return signatures.isEmpty ? null : Signature.fromMap(signatures.first);
  }

  ///[getSignatureBySymbology] método que retorna una asignatura dado su simbología
  ///
  ///[symbology] simbología de la asignatura a buscar
  Future<Signature?> getSignatureBySymbology(String symbology) async {
    final db = await database;
    var signatures = await db.rawQuery(
      '''
    SELECT * FROM Signature
    WHERE symbology = ?''',
      [symbology],
    );
    return signatures.isEmpty ? null : Signature.fromMap(signatures.first);
  }

  ///[getEventById] método que retorna un evento dado su id
  ///
  ///[id] id del evento a buscar
  Future<Event?> getEventById(int id) async {
    final db = await database;
    var events = await db.rawQuery(
      '''
    SELECT * FROM Event
    WHERE id = ?''',
      [id],
    );
    return events.isEmpty ? null : Event.fromMap(events.first);
  }

  ///[containSignatureName] método para saber si existe este nombre de asignatura en la base de datos
  ///
  ///[name] nombre a verificar
  ///
  ///retorna [true] cuando existe, y [false] si no
  Future<bool> containSignatureName(String name) async {
    Signature? signature = await getSignatureByName(name);
    return signature != null;
  }

  ///[containSignatureSymbology] método para saber si existe esta simbología de asignatura en la base de datos
  ///
  ///[symbology] simbología a verificar
  ///
  ///retorna [true] cuando existe, y [false] si no
  Future<bool> containSignatureSymbology(String symbology) async {
    Signature? signature = await getSignatureBySymbology(symbology);
    return signature != null;
  }
}
