import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholar_calendar/controllers/database_controller.dart';
import 'package:scholar_calendar/models/signature.dart';
import 'package:scholar_calendar/screens/home_page.dart';
import 'package:scholar_calendar/screens/signatures_details_page.dart';
import 'package:scholar_calendar/utils/messages.dart';
import 'package:sqflite/sqflite.dart';

///[DialogSignatureWidget] diálogo para agregar o, si se pasa [signature], editar una asignatura
///
///[returnToHome] indica si tras guardar se vuelve al calendario o a la lista de asignaturas
class DialogSignatureWidget extends StatefulWidget {
  final Signature? signature;
  final bool returnToHome;

  const DialogSignatureWidget({
    this.signature,
    this.returnToHome = false,
    super.key,
  });

  @override
  State<DialogSignatureWidget> createState() => _DialogSignatureWidgetState();
}

class _DialogSignatureWidgetState extends State<DialogSignatureWidget> {
  final _formKey = GlobalKey<FormState>();
  late String _name = widget.signature?.name ?? "";
  late String _symbology = widget.signature?.symbology ?? "";
  bool _existSignatureName = false;
  bool _existSignatureSymbology = false;
  bool _saving = false;

  bool get _editing => widget.signature != null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(_editing ? Icons.edit_outlined : Icons.class_outlined),
      title: Text("${_editing ? "Editar" : "Agregar"} Asignatura"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _name,
              autofocus: !_editing,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: "Nombre",
                prefixIcon: Icon(Icons.title),
              ),
              onSaved: (newValue) => _name = newValue!.trim(),
              onChanged: containSignatureName,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Llene este campo";
                }
                if (_existSignatureName &&
                    value.trim() != widget.signature?.name) {
                  return "Esta asignatura ya existe";
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _symbology,
              maxLength: 3,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: "Simbología",
                prefixIcon: Icon(Icons.short_text),
              ),
              onSaved: (newValue) => _symbology = newValue!,
              onChanged: containSignatureSymbology,
              validator: (value) {
                if (value == null || value.isEmpty || !value.isAlphabetOnly) {
                  return "Solo letras, sin espacios (máx. 3)";
                }
                if (_existSignatureSymbology &&
                    value != widget.signature?.symbology) {
                  return "Esta simbología ya existe";
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text("Guardar"),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _saving = true);
    try {
      if (_editing) {
        await databaseController.updateSignature(
          Signature(
            id: widget.signature!.id,
            name: _name,
            symbology: _symbology,
          ),
        );
      } else {
        await databaseController.insertSignature(
          Signature(name: _name, symbology: _symbology),
        );
      }
    } on DatabaseException catch (e) {
      // nombre o simbología duplicados (restricción UNIQUE)
      if (mounted) setState(() => _saving = false);
      showError(
        e.isUniqueConstraintError()
            ? "Ya existe una asignatura con ese nombre o simbología"
            : "No se pudo guardar la asignatura",
      );
      return;
    }
    showSuccess(
      "Asignatura ${_editing ? "modificada" : "añadida"} satisfactoriamente",
    );
    Get.offAll(
      () => widget.returnToHome
          ? const MyHomePage()
          : const SignaturesDetailsPage(),
    );
  }

  void containSignatureName(String signatureName) async {
    _existSignatureName = await databaseController.containSignatureName(
      signatureName.trim(),
    );
  }

  void containSignatureSymbology(String signatureSymbology) async {
    _existSignatureSymbology = await databaseController
        .containSignatureSymbology(signatureSymbology);
  }
}
