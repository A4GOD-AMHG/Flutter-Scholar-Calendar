import 'package:flutter/material.dart';

///[showConfirmDialog] diálogo de confirmación para acciones destructivas
///
///[note] advertencia opcional que se muestra bajo el título
Future<void> showConfirmDialog(
  BuildContext context, {
  required String title,
  String? note,
  required Future<void> Function() onConfirm,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: scheme.error, size: 36),
        title: Text(title, textAlign: TextAlign.center),
        content: note == null ? null : Text(note, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            onPressed: onConfirm,
            child: const Text("Aceptar"),
          ),
        ],
      );
    },
  );
}
