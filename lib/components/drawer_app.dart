import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholar_calendar/app.dart';
import 'package:scholar_calendar/screens/home_page.dart';
import 'package:scholar_calendar/screens/search_events_page.dart';
import 'package:scholar_calendar/screens/signatures_details_page.dart';
import 'package:scholar_calendar/utils/features_discoveries.dart';

class DrawerApp extends StatelessWidget {
  const DrawerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/drawer_header.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                appName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: const [Shadow(blurRadius: 8)],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.class_outlined),
            title: const Text("Ver Asignaturas"),
            onTap: () => Get.offAll(() => const SignaturesDetailsPage()),
          ),
          ListTile(
            leading: const Icon(Icons.search_outlined),
            title: const Text("Buscar Eventos"),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const SearchEventsPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline_outlined),
            title: const Text("Reiniciar tutoriales"),
            onTap: () {
              //Reinicia el tutorial de cada pantalla
              for (final key in [
                keyHome,
                keyAddEvent,
                keyViewSignatures,
                keyDeleteEvent,
                keySearchEvents,
              ]) {
                setShowDiscovery(true, key);
              }
              Get.offAll(() => const MyHomePage());
            },
          ),
          const Divider(indent: 16, endIndent: 16),
          AboutListTile(
            icon: const Icon(Icons.info_outline),
            applicationName: appName,
            applicationVersion: appVersion,
            applicationIcon: Image.asset("assets/images/icon.png", width: 48),
            aboutBoxChildren: [
              const SizedBox(height: 8),
              Text("Autores:", style: theme.textTheme.titleMedium),
              const Text(
                "Leonardo Alain Moreira Rodríguez\nAlexis Manuel Hurtado García",
              ),
              const SizedBox(height: 12),
              Text("Tutor:", style: theme.textTheme.titleMedium),
              const Text("Ing. Alfredo Rafael Espinosa Palenque"),
            ],
            child: const Text("Sobre $appName"),
          ),
        ],
      ),
    );
  }
}
