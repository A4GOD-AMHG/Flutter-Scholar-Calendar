///[Signature] clase para modelar las asignaturas
class Signature {
  int? id;
  late String name;
  late String symbology;

  ///[id] para identificar cada asignatura
  ///
  ///[name] nombre de la asignatura
  ///
  ///[symbology] simbologia de la asignatura
  Signature({this.id, required this.name, required this.symbology});

  ///[toMap]  método para convertir la asignatura en un [Map]
  Map<String, dynamic> toMap() {
    return {'name': name, 'symbology': symbology};
  }

  ///[Signature.fromMap] constructor nombrado para crear una asignatura pasándole el parámetro [map]
  Signature.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    symbology = map['symbology'];
  }

  ///[toString]  método para convertir la asignatura en un cadena de texto
  @override
  String toString() => 'Signature(id: $id, name: $name, symbology: $symbology)';
}
