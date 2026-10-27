import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

///[preferences] instancia de [SharedPreferences] que va a contener las preferencias compartidas
///
///Se utiliza para controlar si un tutorial fue mostrado y no volverlo a mostrar más
SharedPreferences? preferences;

///[key_home] constante que contiene la clave de la pantalla home
const String key_home = "home";

///[key_delete_event] constante que contiene la clave del boton eliminar asignatura
const String key_delete_event = "delete_event";

///[key_add_event] constante que contiene la clave de la pantalla añadir eventos
const String key_add_event = "add_event";

///[key_view_signatures] constante que contiene la clave de la pantalla ver asignaturas
const String key_view_signatures = "view_signatures";

///[key_search_events] constante que contiene la clave de la pantalla buscar eventos
const String key_search_events = "search_events";

///[initPreferences] función que inicia las preferencias compartidas
Future initPreferences() async {
  preferences = await SharedPreferences.getInstance();
}

///[setShowDiscovery] función para cambiar el valor de un dato en las preferencias compartidas dado su clave
///
///[value] valor a cambiar
///
///[key] clave del dato a cambiar
Future setShowDiscovery(bool value, String key) async {
  await preferences!.setBool(key, value);
}

///[getShowDiscovery] retorna el valor [true] o [false] de un dato dado su clave y retorna [null] en caso de no existir ese dato
bool? getShowDiscovery(String key) => preferences!.getBool(key);

///[kFeatureId1DeleteAllEvents] constante que contiene el id del botón eliminar todos los eventos
const kFeatureId1DeleteAllEvents = 'feature_1delete_all_events';

///[kFeatureId3Slidable] constante que contiene el id del [Slidable] de la asignatura
const kFeatureId3Slidable = 'feature_3Slidable';

///[kFeatureId4DeleteEvent] constante que contiene el id del botón eliminar evento
const kFeatureId4DeleteEvent = 'feature_4delete_event';

///[kFeatureId5Color] constante que contiene el id del botón de cambiar el color del evento
const kFeatureId5Color = 'feature_5Color';

///[kFeatureId6Alert] constante que contiene el id del botón de agregar la alarma al evento
const kFeatureId6Alert = 'feature_6Alert';

///[kFeatureId7Switch] constante que contiene el id del [Switch] que activa la alarma del evento
const kFeatureId7Switch = 'feature_7Switch';

///[kFeatureId8SearchEvents] constante que contiene el id del botón buscar eventos
const kFeatureId8SearchEvents = 'feature_8SearchEvents';

///[buildWidget] función para agregar un tutorial a un elemento de tipo [Widget] determinado de la aplicación
///
///[featureId] id del elemento que se le va a agregar el tutorial
///
///[tapTarget] elemento de tipo [Widget] que aparecerá marcado al salir el tutorial
///
///[child] elemento de tipo [Widget] que se le va a agregar el tutorial
///
///[title] título del tutorial(Opcional)
///
///[description] descripción del tutorial(Opcional)
///
///[contentLocation] localización del contenido del tutorial
DescribedFeatureOverlay buildWidget(BuildContext context,
    {required String featureId,
    required Widget tapTarget,
    required Widget child,
    String title = "",
    String description = "",
    required ContentLocation contentLocation}) {
  return DescribedFeatureOverlay(
    featureId: featureId,
    tapTarget: tapTarget,
    title: Text(title),
    description: Text(description),
    backgroundColor: Theme.of(context).primaryColor,
    targetColor: Theme.of(context).colorScheme.surface,
    textColor: Theme.of(context).colorScheme.onSurface,
    child: child,
    contentLocation: contentLocation,
    barrierDismissible: false,
  );
}

///[showDiscovery] función encargada de mostrar el tutorial
///
///[context] contexto en el que va a estar
///
///[listId] lista de todos los id de los elementos que se van a mostrar en el tutorial
///
///[key] clave de la pantalla en la que se va a mostrar el tutorial
Future<void> showDiscovery(BuildContext context,
    {required List<String> listId, required String key}) async {
  await FeatureDiscovery.clearPreferences(
    context,
    listId,
  );
  FeatureDiscovery.discoverFeatures(
    context,
    listId,
  );
  setShowDiscovery(false, key);
}
