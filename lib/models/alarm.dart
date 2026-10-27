///[Alarm] clase para modelar las alarmas
class Alarm {
  int? id;
  String? description;
  late DateTime time;

  ///[id] para identificar cada alarma
  ///
  ///[description] descripción de la alarma
  ///
  ///[time] fecha de la alarma
  Alarm({this.id, this.description, required this.time});

  ///[toMap]  método para convertir la alarma en un [Map]
  Map<String, dynamic> toMap() {
    return {'description': description, 'time': time.toString()};
  }

  ///[Alarm.fromMap] constructor nombrado para crear una alarma pasándole el parámetro [map]
  Alarm.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    description = map['description'];
    time = DateTime.parse(map['time']);
  }

  ///[toString]  método para convertir la alarma en un cadena de texto
  @override
  String toString() => 'Alarm(id: $id, description: $description, time: $time)';
}
