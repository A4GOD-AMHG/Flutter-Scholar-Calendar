import 'package:flutter/material.dart';
import 'package:scholar_calendar/controllers/database_controller.dart';

///[DropdownButtonSignatureWidget] selector controlado de asignatura; carga los
///nombres desde la base de datos
class DropdownButtonSignatureWidget extends StatefulWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const DropdownButtonSignatureWidget({
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  State<DropdownButtonSignatureWidget> createState() =>
      _DropdownButtonSignatureWidgetState();
}

class _DropdownButtonSignatureWidgetState
    extends State<DropdownButtonSignatureWidget> {
  List<String> _names = [];

  @override
  void initState() {
    super.initState();
    loadState();
  }

  void loadState() async {
    final names = await databaseController.getSignaturesNames();
    if (mounted) setState(() => _names = names);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      // evita el assert de DropdownButton mientras se cargan los nombres
      value: _names.contains(widget.value) ? widget.value : null,
      hint: const Text("Asignatura"),
      icon: const Icon(Icons.class_outlined),
      borderRadius: BorderRadius.circular(12),
      onChanged: widget.onChanged,
      items: _names
          .map(
            (name) => DropdownMenuItem<String>(value: name, child: Text(name)),
          )
          .toList(),
    );
  }
}
