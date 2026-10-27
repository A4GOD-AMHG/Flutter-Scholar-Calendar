import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:scholar_calendar/api/notification_api.dart';
import 'package:scholar_calendar/components/dialog_signature_widget.dart';
import 'package:scholar_calendar/controllers/database_controller.dart';
import 'package:scholar_calendar/models/event.dart';
import 'package:scholar_calendar/models/signature.dart';
import 'package:scholar_calendar/screens/home_page.dart';
import 'package:scholar_calendar/screens/signature_events_details_page.dart';
import 'package:scholar_calendar/utils/features_discoveries.dart';

class SignaturesDetailsPage extends StatefulWidget {
  SignaturesDetailsPage({Key? key}) : super(key: key);

  @override
  State<SignaturesDetailsPage> createState() => _SignaturesDetailsPageState();
}

class _SignaturesDetailsPageState extends State<SignaturesDetailsPage> {
  bool hasSignatures = true;
  late BuildContext cont;

  @override
  void initState() {
    if (getShowDiscovery(key_view_signatures) ?? true) {
      WidgetsBinding.instance.addPostFrameCallback((Duration duration) =>
          showDiscovery(cont,
              listId: [kFeatureId3Slidable], key: key_view_signatures));
    }
    super.initState();
    loadState();
  }

  void loadState() async {
    var checkHasSignatures = await databaseController.hasSignatures();
    setState(() {
      hasSignatures = checkHasSignatures;
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      cont = context;
    });
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Get.offAll(() => const MyHomePage());
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(
            "Asignaturas",
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            IconButton(
                onPressed: () => Get.offAll(() => MyHomePage()),
                icon: Icon(Icons.close))
          ],
        ),
        body: FutureBuilder<List<List<dynamic>>>(
          future: getSignaturesWithNumberOfEvents(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Signature?>? list =
                  new List.filled(snapshot.data!.length, null);
              for (int i = 0; i < snapshot.data!.length; i++) {
                list[i] = snapshot.data![i][0];
              }

              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info,
                          size: 120,
                          color: Colors.grey,
                        ),
                        Text(
                          "No se han agregado asignaturas aún",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
              return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    Signature? signature = list[index];
                    return (index == 0)
                        ? buildWidget(context,
                            featureId: kFeatureId3Slidable,
                            tapTarget: Icon(Icons.class_outlined),
                            child: _buildSlidable(
                                context, index, snapshot, signature),
                            contentLocation: ContentLocation.below,
                            title: "Asignatura",
                            description:
                                "Deslizar hacia:\nDerecha para ver opciones de eliminar y editar\nIzquierda para ver más")
                        : _buildSlidable(context, index, snapshot, signature);
                  });
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        floatingActionButton: SpeedDial(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          activeBackgroundColor: Colors.red,
          overlayColor: Theme.of(context).colorScheme.surface,
          overlayOpacity: 0.5,
          spacing: 5,
          spaceBetweenChildren: 15,
          animatedIcon: AnimatedIcons.menu_close,
          children: [
            SpeedDialChild(
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              child: Icon(
                Icons.add,
              ),
              label: "Agregar Asignatura",
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.surface,
              ),
              labelBackgroundColor:
                  Theme.of(context).colorScheme.onSurface,
              foregroundColor: Theme.of(context).colorScheme.surface,
              onTap: () async {
                await _showDialogSignature(
                  context,
                  DialogSignatureWidget(
                    page: SignaturesDetailsPage(),
                  ),
                );
              },
            ),
            if (hasSignatures)
              SpeedDialChild(
                backgroundColor: Theme.of(context).colorScheme.onSurface,
                child: Icon(
                  Icons.delete,
                ),
                label: "Eliminar todas las asignaturas",
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                ),
                labelBackgroundColor:
                    Theme.of(context).colorScheme.onSurface,
                foregroundColor: Theme.of(context).colorScheme.surface,
                onTap: () async {
                  _showDialogDeleteAllSignatures(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Slidable _buildSlidable(
    BuildContext context,
    int index,
    AsyncSnapshot<List<List<dynamic>>> snapshot,
    Signature? signature,
  ) {
    return Slidable(
      key: ValueKey(signature!.id),
      child: ListTile(
        leading: Icon(
          Icons.class_outlined,
          color: Theme.of(context).colorScheme.onSurface,
          size: 50,
        ),
        title: Text(
          signature.name,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w900),
        ),
        isThreeLine: true,
        subtitle: Text(
          "${signature.symbology}\n${snapshot.data![index][1]} ${(snapshot.data![index][1] == 1) ? "evento" : "eventos"}",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      startActionPane: ActionPane(
        motion: DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (BuildContext context) async {
              _showDialogDeleteSignature(context, signature);
            },
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Eliminar',
          ),
          SlidableAction(
            onPressed: (BuildContext context) {
              _showDialogSignature(
                  context,
                  DialogSignatureWidget(
                    signature: signature,
                    page: SignaturesDetailsPage(),
                  ));
            },
            backgroundColor: Color(0xFF21B7CA),
            foregroundColor: Colors.white,
            icon: Icons.edit_outlined,
            label: 'Editar',
          )
        ],
      ),
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (BuildContext context) {
              Get.to(() => SignatureEventsDetailsPage(signature: signature));
            },
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            icon: Icons.more_horiz_outlined,
            label: 'Más',
          ),
        ],
      ),
    );
  }

  void _showDialogDeleteAllSignatures(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Text(
                              "¿Desea eliminar todas las asignaturas?",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).colorScheme.onSurface),
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.warning_amber_outlined,
                              ),
                              title: Text(
                                "Nota: Al eliminar todas las asignaturas todos los eventos y alarmas serán eliminados",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface),
                              ),
                            )
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                              onPressed: () async {
                                await databaseController.deleteAllSignatures();
                                NotificationApi.cancelAll();
                                Get.offAll(() => SignaturesDetailsPage());
                              },
                              child: const Text(
                                "Aceptar",
                                style: TextStyle(fontSize: 18),
                              )),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Cancelar",
                                style: TextStyle(fontSize: 18),
                              ))
                        ],
                        mainAxisSize: MainAxisSize.min,
                      )
                    ],
                  )
                ],
              ),
            ));
  }

  void _showDialogDeleteSignature(
      BuildContext context, Signature signature) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          "¿Desea eliminar la asignatura ${signature.name}?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              color:
                                  Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.warning_amber_outlined,
                        ),
                        title: Text(
                          "Nota: Al eliminar esta asignatura todos los eventos y alarmas asociados a ella serán eliminados",
                          style: TextStyle(
                              fontSize: 14,
                              color:
                                  Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                              onPressed: () async {
                                List<Event> events = await databaseController
                                    .getEventsOfSignatureById(signature.id!);

                                bool isDeleted = await databaseController
                                    .deleteSignature(signature.id!);
                                if (isDeleted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Colors.green,
                                      content: Text(
                                          "Asignatura eliminada satisfactoriamente"),
                                    ),
                                  );
                                }
                                events.forEach((currentEvent) {
                                  if (currentEvent.startTime
                                      .isAfter(DateTime.now())) {
                                    var id = (currentEvent.idAlarm! * -1) - 1;
                                    NotificationApi.cancel(
                                        currentEvent.idAlarm!);
                                    NotificationApi.cancel(id);
                                  }
                                });

                                Get.offAll(() => SignaturesDetailsPage());
                              },
                              child: const Text(
                                "Aceptar",
                                style: TextStyle(fontSize: 18),
                              )),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Cancelar",
                                style: TextStyle(fontSize: 18),
                              ))
                        ],
                        mainAxisSize: MainAxisSize.min,
                      )
                    ],
                  )
                ],
              ),
            ));
  }

  Future<void> _showDialogSignature(
      BuildContext context, DialogSignatureWidget dialog) async {
    await showDialog(
        context: context, builder: (BuildContext context) => dialog);
  }

  Future<void> asyncFor(
      int index, int max, Future<void> Function(int) forBody) {
    if (index >= max) {
      return Future.value();
    }
    return forBody(index).then((_) => asyncFor(index + 1, max, forBody));
  }

  Future<List<List<dynamic>>> getSignaturesWithNumberOfEvents() async {
    List<Signature> signatures = await databaseController.getSignatures();
    List<List<dynamic>> signaturesWithNumberOfEvents =
        new List<List<dynamic>>.filled(
            signatures.length, new List<dynamic>.filled(2, null));
    List<int> count = List.filled(signatures.length, 0);

    await asyncFor(0, signatures.length, (i) {
      int id = signatures[i].id!;

      return databaseController.countEventsByIdSignature(id).then((value) {
        count[i] = value;
      });
    });

    for (int i = 0; i < signatures.length; i++) {
      signaturesWithNumberOfEvents[i] = [signatures[i], count[i]];
    }
    return signaturesWithNumberOfEvents;
  }
}
