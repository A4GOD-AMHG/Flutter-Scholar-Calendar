import 'package:animate_do/animate_do.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:scholar_calendar/api/notification_api.dart';
import 'package:scholar_calendar/controllers/database_controller.dart';
import 'package:scholar_calendar/screens/home_page.dart';
import 'package:scholar_calendar/themes/theme.dart';
import 'package:scholar_calendar/utils/features_discoveries.dart';

const appName = "Eventos Escolares";
const appVersion = "1.1.0";

///[MyApp] clase que contiene a la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Este widget es la raíz de la aplicación.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Init.instance.ready,
      builder: (context, AsyncSnapshot snapshot) {
        // Muestra una pantalla de carga mientras espera que carguen los recursos de la app:
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            theme: dark,
            debugShowCheckedModeBanner: false,
            home: const Splash(),
          );
        }
        // Cuando termina de cargar, retorna la app:
        return FeatureDiscovery(
          child: GetMaterialApp(
            title: appName,
            theme: dark,
            debugShowCheckedModeBanner: false,
            // Idioma de la app configurado al Español
            locale: const Locale('es', 'ES'),
            supportedLocales: const [Locale('es', 'ES')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const MyHomePage(), // pantalla principal de la aplicación
          ),
        );
      },
    );
  }
}

///[Splash] pantalla de carga de la app
class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: splashColor,
      body: Center(
        child: FadeInUp(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/icon256x256.png', width: 160),
              const SizedBox(height: 24),
              const Text(
                appName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Versión $appVersion",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Init {
  Init._();
  static final instance = Init._();

  ///[ready] se resuelve una sola vez, aunque [MyApp] se reconstruya.
  late final Future<void> ready = _initialize();

  ///[_initialize]
  ///Aquí es donde se inician los recursos necesarios de la app mientras la pantalla [Splash] está desplegada.
  Future<void> _initialize() async {
    await Future.wait([
      initPreferences(), // preferencias compartidas (tutoriales)
      databaseController.init(), // base de datos
      NotificationApi.init(), // notificaciones locales
      Future.delayed(const Duration(seconds: 2)),
    ]);
  }
}
