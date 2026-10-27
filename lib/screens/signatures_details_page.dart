import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:scholar_calendar/api/notification_api.dart';
import 'package:scholar_calendar/components/confirm_dialog.dart';
import 'package:scholar_calendar/components/dialog_signature_widget.dart';
import 'package:scholar_calendar/components/empty_state.dart';
import 'package:scholar_calendar/components/floating_action_button_speed_dial.dart';
import 'package:scholar_calendar/controllers/database_controller.dart';
import 'package:scholar_calendar/models/signature.dart';
import 'package:scholar_calendar/screens/home_page.dart';
import 'package:scholar_calendar/screens/signature_events_details_page.dart';
import 'package:scholar_calendar/utils/features_discoveries.dart';
import 'package:scholar_calendar/utils/messages.dart';

class SignaturesDetailsPage extends StatefulWidget {
  const SignaturesDetailsPage({super.key});

  @override
  State<SignaturesDetailsPage> createState() => _SignaturesDetailsPageState();
}

class _SignaturesDetailsPageState extends State<SignaturesDetailsPage> {
  late final Future<List<(Signature, int)>> _signatures =
      getSignaturesWithNumberOfEvents();

  @override
  void initState() {
    super.initState();
    if (getShowDiscovery(key_view_signatures) ?? true) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => showDiscovery(
          context,
          listId: [kFeatureId3Slidable],
          key: key_view_signatures,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Get.offAll(() => const MyHomePage());
      },
      child: FutureBuilder<List<(Signature, int)>>(
        future: _signatures,
        builder: (context, snapshot) {
          final list = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              title: const Text("Asignaturas"),
              actions: [
                IconButton(
                  tooltip: "Volver al calendario",
                  onPressed: () => Get.offAll(() => const MyHomePage()),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            body: _buildBody(context, snapshot),
            floatingActionButton: appSpeedDial(context, [
              speedDialChild(
                context,
                icon: Icons.add,
                label: "Agregar Asignatura",
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => const DialogSignatureWidget(),
                ),
              ),
              if (list != null && list.isNotEmpty)
                speedDialChild(
                  context,
                  icon: Icons.delete_sweep_outlined,
                  label: "Eliminar todas las asignaturas",
                  onTap: _showDialogDeleteAllSignatures,
                ),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<List<(Signature, int)>> snapshot,
  ) {
    if (snapshot.hasError) {
      return const EmptyState(
        icon: Icons.error_outline,
        message: "No se pudieron cargar las asignaturas",
      );
    }
    final list = snapshot.data;
    if (list == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (list.isEmpty) {
      return const EmptyState(
        icon: Icons.class_outlined,
        message: "No se han agregado asignaturas aún\nPulse + para agregar la primera",
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 96),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final (signature, eventCount) = list[index];
        final slidable = _buildSlidable(context, signature, eventCount);
        return (index == 0)
            ? buildWidget(
                context,
                featureId: kFeatureId3Slidable,
                tapTarget: const Icon(Icons.class_outlined),
                child: slidable,
                contentLocation: ContentLocation.below,
                title: "Asignatura",
                description: "Deslizar hacia:\nDerecha para ver opciones de eliminar y editar\nIzquierda para ver más",
              )
            : slidable;
      },
    );
  }

  Widget _buildSlidable(
    BuildContext context,
    Signature signature,
    int eventCount,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Slidable(
        key: ValueKey(signature.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _showDialogDeleteSignature(signature),
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
              icon: Icons.delete_outline,
              label: 'Eliminar',
            ),
            SlidableAction(
              onPressed: (_) => showDialog(
                context: context,
                builder: (_) => DialogSignatureWidget(signature: signature),
              ),
              backgroundColor: scheme.tertiary,
              foregroundColor: scheme.onTertiary,
              icon: Icons.edit_outlined,
              label: 'Editar',
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => Get.to(
                () => SignatureEventsDetailsPage(signature: signature),
              ),
              backgroundColor: scheme.secondaryContainer,
              foregroundColor: scheme.onSecondaryContainer,
              icon: Icons.more_horiz_outlined,
              label: 'Más',
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
            child: Text(
              signature.symbology.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            signature.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            "$eventCount ${eventCount == 1 ? "evento" : "eventos"}",
          ),
          trailing: const Icon(Icons.swipe_outlined),
          onTap: () =>
              Get.to(() => SignatureEventsDetailsPage(signature: signature)),
        ),
      ),
    );
  }

  void _showDialogDeleteAllSignatures() {
    showConfirmDialog(
      context,
      title: "¿Desea eliminar todas las asignaturas?",
      note: "Nota: Al eliminar todas las asignaturas todos los eventos y alarmas serán eliminados",
      onConfirm: () async {
        await databaseController.deleteAllSignatures();
        NotificationApi.cancelAll();
        showSuccess("Asignaturas eliminadas satisfactoriamente");
        Get.offAll(() => const SignaturesDetailsPage());
      },
    );
  }

  void _showDialogDeleteSignature(Signature signature) {
    showConfirmDialog(
      context,
      title: "¿Desea eliminar la asignatura ${signature.name}?",
      note: "Nota: Al eliminar esta asignatura todos los eventos y alarmas asociados a ella serán eliminados",
      onConfirm: () async {
        final events = await databaseController.getEventsOfSignatureById(
          signature.id!,
        );
        final isDeleted = await databaseController.deleteSignature(
          signature.id!,
        );
        for (final event in events) {
          NotificationApi.cancelEvent(event.idAlarm!);
        }
        if (isDeleted) showSuccess("Asignatura eliminada satisfactoriamente");
        Get.offAll(() => const SignaturesDetailsPage());
      },
    );
  }

  Future<List<(Signature, int)>> getSignaturesWithNumberOfEvents() async {
    final signatures = await databaseController.getSignatures();
    return [
      for (final signature in signatures)
        (
          signature,
          await databaseController.countEventsByIdSignature(signature.id!),
        ),
    ];
  }
}
