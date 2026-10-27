# Flutter Scholar Calendar

**Eventos Escolares** es una aplicación móvil hecha con Flutter para organizar la vida académica: permite registrar asignaturas, planificar eventos (seminarios, conferencias, clases prácticas, pruebas, laboratorios…) en un calendario y recibir alarmas y recordatorios locales antes de cada uno. Desarrollada por **Alexis Manuel Hurtado Garcia** (junto a Leonardo Alain Moreira Rodríguez).

## Tech Stack

<div style="display: flex; align-items: center;">
  <img src="https://raw.githubusercontent.com/A4GOD-AMHG/Utils-for-repos/refs/heads/main/icons/dart/dart-original.svg" alt="dart" width="65" height="65" />
  <img src="https://raw.githubusercontent.com/A4GOD-AMHG/Utils-for-repos/refs/heads/main/icons/flutter/flutter-original.svg" alt="flutter" width="65" height="65" />
  <img src="https://raw.githubusercontent.com/A4GOD-AMHG/Utils-for-repos/refs/heads/main/icons/sqlite/sqlite-original.svg" alt="sqlite" width="65" height="65" />
</div>

## Características

- **Calendario interactivo**: vistas de semana, semana laboral y mes con agenda, número de semana y selector de fecha.
- **Arrastrar y redimensionar**: mueve o alarga un evento directamente en el calendario; los cambios se guardan y las alarmas se reprograman.
- **Asignaturas**: alta, edición y borrado con nombre y simbología únicos; al borrar una asignatura se eliminan sus eventos y alarmas.
- **Eventos**: nombre, descripción, tipo, asignatura, color personalizado, fecha y duración (mínimo 15 minutos).
- **Alarmas y recordatorios**: notificación local al inicio del evento y recordatorio opcional con la antelación que elijas.
- **Búsqueda**: busca eventos por nombre, agrupados por día ("Hoy", "Mañana"…).
- **Tutoriales guiados**: cada pantalla explica sus acciones la primera vez y pueden reiniciarse desde el menú.
- **Interfaz en español**: tema oscuro Material 3, estados de carga, vacío y error.
- **Datos locales**: todo se guarda en SQLite en el propio dispositivo, sin cuentas ni servidor.

## Dependencias

### Dependencias Principales

- `syncfusion_flutter_calendar`: calendario con vistas, arrastrar y soltar y redimensionado.
- `sqflite`: base de datos SQLite local.
- `path`: construcción de la ruta del fichero de base de datos.
- `shared_preferences`: recuerda qué tutoriales ya se mostraron.
- `flutter_local_notifications`: alarmas y recordatorios programados.
- `timezone`: fechas con zona horaria para programar notificaciones.
- `rxdart`: flujo de notificaciones pulsadas.
- `get`: navegación entre pantallas y utilidades de validación.
- `flutter_localizations` / `intl`: textos y formatos de fecha en español.
- `flutter_speed_dial`: botón flotante con acciones.
- `flutter_slidable`: acciones deslizables en la lista de asignaturas.
- `flex_color_picker`: selector de color del evento.
- `feature_discovery`: tutoriales sobre los elementos de la interfaz.
- `animate_do`: animaciones de entrada y de mensajes de error.
- `cupertino_icons`: iconos de estilo iOS.

### Dependencias de Desarrollo

- `flutter_test`: pruebas unitarias y de widgets.
- `flutter_lints`: reglas de análisis estático recomendadas.
- `flutter_native_splash`: genera la pantalla de carga nativa.
- `flutter_launcher_icons`: genera los iconos de la app.

## Cómo usar

1. Clona el repositorio:

   ```bash
   git clone https://github.com/A4GOD-AMHG/Flutter-Scholar-Calendar.git
   cd Flutter-Scholar-Calendar
   ```

2. El repositorio solo contiene el código Dart. Genera las carpetas de plataforma e instala las dependencias (requiere Flutter 3.38 o superior, Dart 3):

   ```bash
   flutter create . --org com.a4god --project-name scholar_calendar --platforms android,ios
   flutter pub get
   dart run flutter_launcher_icons
   dart run flutter_native_splash:create
   ```

3. En Android, añade en `android/app/src/main/AndroidManifest.xml` los permisos de notificaciones y alarmas exactas que usa `flutter_local_notifications`:

   ```xml
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
   <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
   <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
   ```

   y los receivers indicados en la [guía del plugin](https://pub.dev/packages/flutter_local_notifications#-android-setup) (incluido `coreLibraryDesugaringEnabled` en `android/app/build.gradle`).

4. Ejecuta la app:

   ```bash
   flutter run
   ```

5. Pruebas y build:

   ```bash
   flutter test
   flutter build apk --release
   ```

No necesita variables de entorno: todos los datos se guardan localmente.

## Estructura del Proyecto

```
lib/
├── main.dart                       # Punto de entrada (orientación vertical)
├── app.dart                        # MaterialApp, splash e inicialización de servicios
├── api/
│   └── notification_api.dart       # Programación y cancelación de alarmas/recordatorios
├── components/
│   ├── bottom_sheet_add_event_widget.dart     # Formulario de crear/editar evento
│   ├── confirm_dialog.dart                    # Diálogo de confirmación reutilizable
│   ├── dialog_add_alert_widget.dart           # Selector de antelación del recordatorio
│   ├── dialog_signature_widget.dart           # Formulario de asignatura
│   ├── drawer_app.dart                        # Menú lateral
│   ├── dropdown_button_event_type.dart        # Selector de tipo de evento
│   ├── dropdown_button_signature.dart         # Selector de asignatura
│   ├── empty_state.dart                       # Estado vacío / sin resultados
│   └── floating_action_button_speed_dial.dart # Botón flotante de acciones
├── controllers/
│   └── database_controller.dart    # Fachada de acceso a datos para la UI
├── database/
│   └── database_provider.dart      # Esquema y consultas SQLite
├── enums/
│   └── event_type.dart             # Tipos de evento y su texto
├── models/                         # Alarm, Event, Signature
├── screens/
│   ├── home_page.dart                     # Calendario principal
│   ├── search_events_page.dart            # Búsqueda de eventos
│   ├── signatures_details_page.dart       # Lista de asignaturas
│   └── signature_events_details_page.dart # Eventos de una asignatura
├── themes/
│   └── theme.dart                  # Tema oscuro Material 3
└── utils/
    ├── features_discoveries.dart   # Tutoriales y preferencias
    └── messages.dart               # Mensajes (SnackBar) de éxito y error
assets/images/                      # Icono, splash y cabecera del menú
test/widget_test.dart               # Pruebas de modelos
```

## Licencia

Este proyecto es de uso libre con fines educativos.

## Autor

**Alexis Manuel Hurtado Garcia** - [GitHub](https://github.com/A4GOD-AMHG)
