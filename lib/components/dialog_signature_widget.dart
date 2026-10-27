import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholar_calendar/controllers/database_controller.dart';
import 'package:scholar_calendar/models/signature.dart';
import 'package:scholar_calendar/screens/home_page.dart';
import 'package:scholar_calendar/screens/signatures_details_page.dart';

// ignore: must_be_immutable
class DialogSignatureWidget extends StatefulWidget {
  Signature? signature;
  Widget? page;

  DialogSignatureWidget({this.signature, this.page, Key? key})
      : super(key: key);

  @override
  State<DialogSignatureWidget> createState() => _DialogSignatureWidgetState();
}

class _DialogSignatureWidgetState extends State<DialogSignatureWidget> {
  final _formKey = GlobalKey<FormState>();
  String? _textAddSignatureName;
  String? _textAddSignatureNameSymbology;

  late bool _existSignatureName;
  late bool _existSignatureSymbology;

  bool _editing = false;
  @override
  void initState() {
    super.initState();

    if (widget.signature == null) {
      _textAddSignatureName = "";
      _textAddSignatureNameSymbology = "";
      _existSignatureName = false;
      _existSignatureSymbology = false;
    } else {
      _textAddSignatureName = widget.signature!.name;
      _textAddSignatureNameSymbology = widget.signature!.symbology;
      _existSignatureName = true;
      _existSignatureSymbology = true;
      _editing = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                "${(_editing) ? "Editar" : "Agregar"} Asignatura",
                style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
              Container(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _textAddSignatureName,
                        decoration: InputDecoration(
                          labelText: "Nombre",
                          labelStyle: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.onSurface),
                        ),
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onSaved: (newValue) {
                          _textAddSignatureName = newValue!;
                        },
                        onChanged: containSignatureName,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Llene este campo";
                          }

                          if (_existSignatureName && !_editing) {
                            return "Esta asignatura ya existe";
                          }
                        },
                      ),
                      TextFormField(
                        initialValue: _textAddSignatureNameSymbology,
                        maxLength: 3,
                        decoration: InputDecoration(
                          labelText: "Simbología",
                          labelStyle: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.onSurface),
                        ),
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onSaved: (newValue) {
                          _textAddSignatureNameSymbology = newValue!;
                        },
                        onChanged: containSignatureSymbology,
                        validator: (value) {
                          if (value!.isEmpty || !value.isAlphabetOnly) {
                            return "Este campo no puede contener espacios en\nblanco ni estar vacío, solamente 3 letras";
                          }
                          if (_existSignatureSymbology && !_editing) {
                            return "Esta simbología ya existe";
                          }
                        },
                      ),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
              ),
              Row(
                children: [
                  TextButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          bool isUpdated = false;
                          if (_editing) {
                            isUpdated = await databaseController
                                .updateSignature(Signature(
                                    id: widget.signature!.id,
                                    name: _textAddSignatureName!,
                                    symbology:
                                        _textAddSignatureNameSymbology!));
                          } else {
                            _addSignature(_textAddSignatureName!,
                                _textAddSignatureNameSymbology!);
                          }
                          _textAddSignatureName = "";
                          _textAddSignatureNameSymbology = "";
                          if (!_editing | isUpdated) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: Colors.green,
                                content: Text(
                                    "Asignatura ${(_editing) ? "modificada" : "añadida"} satisfactoriamente")));
                          }

                          Get.offAll(() => widget.page is MyHomePage
                              ? MyHomePage()
                              : SignaturesDetailsPage());
                        }
                      },
                      child: const Text(
                        "Guardar",
                        style: TextStyle(fontSize: 18),
                      )),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
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
    );
  }

  Future<Signature?> _addSignature(String name, String symbology) async {
    Signature signature = Signature(name: name, symbology: symbology);
    Signature? nsignature = await databaseController.insertSignature(signature);
    return nsignature;
  }

  void containSignatureName(String signatureName) async {
    _existSignatureName =
        await databaseController.containSignatureName(signatureName);
  }

  void containSignatureSymbology(String signatureSymbology) async {
    _existSignatureSymbology =
        await databaseController.containSignatureSymbology(signatureSymbology);
  }
}
