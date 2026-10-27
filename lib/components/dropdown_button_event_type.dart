import 'package:flutter/material.dart';
import 'package:scholar_calendar/enums/event_type.dart';

class DropdownButtonEventTypeWidget extends StatefulWidget {
  static String? value;

  DropdownButtonEventTypeWidget({Key? key}) : super(key: key);

  @override
  State<DropdownButtonEventTypeWidget> createState() =>
      _DropdownButtonEventTypeWidgetState();
}

class _DropdownButtonEventTypeWidgetState
    extends State<DropdownButtonEventTypeWidget> {
  EventType? _eventType;
  @override
  void initState() {
    super.initState();
    if (_eventType != null) {
      DropdownButtonEventTypeWidget.value = _eventType!.asString;
    }
  }

  @override
  void dispose() {
    super.dispose();
    DropdownButtonEventTypeWidget.value = null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: DropdownButton<EventType>(
        dropdownColor: Theme.of(context).colorScheme.surface,
        style: TextStyle(
          fontSize: 18,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        value: EventTypeModel.fromString(DropdownButtonEventTypeWidget.value),
        hint: Text(
          "Tipo de evento",
          style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface),
        ),
        onChanged: (EventType? value) {
          setState(() {
            _eventType = value!;
            DropdownButtonEventTypeWidget.value = value.asString;
          });
        },
        items: EventType.values.map((EventType eventType) {
          return DropdownMenuItem<EventType>(
              value: eventType, child: Text(eventType.asString));
        }).toList(),
      ),
    );
  }
}
