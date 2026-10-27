import 'package:flutter/material.dart';
import 'package:scholar_calendar/controllers/database_controller.dart';

class DropdownButtonSignatureWidget extends StatefulWidget {
  static String? value;

  DropdownButtonSignatureWidget({Key? key}) : super(key: key);

  @override
  State<DropdownButtonSignatureWidget> createState() =>
      _DropdownButtonSignatureWidgetState();
}

class _DropdownButtonSignatureWidgetState
    extends State<DropdownButtonSignatureWidget> {
  late List<String> menuItems;
  String? _selectedValue;

  List<DropdownMenuItem<String>>? _dropDownMenuItems;

  @override
  void initState() {
    super.initState();
    if (_selectedValue != null) {
      DropdownButtonSignatureWidget.value = _selectedValue;
    }

    loadState();
  }

  @override
  void dispose() {
    super.dispose();
    DropdownButtonSignatureWidget.value = null;
  }

  void loadState() async {
    menuItems = await databaseController.getSignaturesNames();
    setState(() {
      _dropDownMenuItems = menuItems
          .map((String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: DropdownButton(
        dropdownColor: Theme.of(context).colorScheme.surface,
        style: TextStyle(
          fontSize: 18,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        value: DropdownButtonSignatureWidget.value,
        hint: Text(
          "Asignatura",
          style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface),
        ),
        onChanged: (String? newValue) async {
          if (newValue != null) {
            setState(() {
              _selectedValue = newValue;
              DropdownButtonSignatureWidget.value = newValue;
            });
          }
        },
        items: _dropDownMenuItems,
      ),
    );
  }
}
