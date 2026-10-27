import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholar_calendar/screens/home_page.dart';
import 'package:scholar_calendar/screens/search_events_page.dart';
import 'package:scholar_calendar/screens/signatures_details_page.dart';
import 'package:scholar_calendar/utils/features_discoveries.dart';

class DrawerApp extends StatelessWidget {
  const DrawerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: ListTile(
              title: Text(""),
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/drawer_header.jpg'),
                  fit: BoxFit.cover),
            ),
          ),
          ListTile(
            title: const Text(
              "Ver Asignaturas",
              style: TextStyle(fontSize: 18),
            ),
            leading: const Icon(
              Icons.class_outlined,
            ),
            onTap: () {
              Get.offAll(() => SignaturesDetailsPage());
            },
          ),
          ListTile(
            title: const Text(
              "Buscar Eventos",
              style: TextStyle(fontSize: 18),
            ),
            leading: const Icon(Icons.search_outlined),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => SearchEventsPage());
            },
          ),
          ListTile(
            title: const Text(
              "Reiniciar tutoriales",
              style: TextStyle(fontSize: 18),
            ),
            leading: const Icon(
              Icons.help_outline_outlined,
            ),
            onTap: () {
              //Reinicia el tutorial de cada pantalla
              setShowDiscovery(true, key_home);
              setShowDiscovery(true, key_add_event);
              setShowDiscovery(true, key_view_signatures);
              setShowDiscovery(true, key_delete_event);
              setShowDiscovery(true, key_search_events);
              Get.offAll(() => MyHomePage());
            },
          ),
          AboutListTile(
            applicationName: "Eventos Escolares",
            applicationVersion: "1.0.0",
            applicationIcon: Image.asset(
              "assets/images/icon.png",
              scale: 2,
            ),
            aboutBoxChildren: [
              Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                        child: Text(
                      "Autores:",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                    )),
                    WidgetSpan(
                      child: Text(
                        "Leonardo Alain Moreira Rodríguez\nAlexis Manuel Hurtado García",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 15,
              ),
              Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                        child: Text(
                      "Tutor:",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                    )),
                    WidgetSpan(
                      child: Text(
                        "Ing. Alfredo Rafael Espinosa Palenque",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            icon: const Icon(
              Icons.info_outline,
            ),
            child: const Text(
              "Sobre Eventos Escolares",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
