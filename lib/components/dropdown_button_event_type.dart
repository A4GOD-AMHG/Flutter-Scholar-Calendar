import 'package:flutter/material.dart';
import 'package:scholar_calendar/enums/event_type.dart';

///[DropdownButtonEventTypeWidget] selector controlado del tipo de evento
class DropdownButtonEventTypeWidget extends StatelessWidget {
  final EventType? value;
  final ValueChanged<EventType?> onChanged;

  const DropdownButtonEventTypeWidget({
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<EventType>(
      value: value,
      hint: const Text("Tipo de evento"),
      icon: const Icon(Icons.category_outlined),
      borderRadius: BorderRadius.circular(12),
      onChanged: onChanged,
      items: EventType.values
          .map(
            (eventType) => DropdownMenuItem<EventType>(
              value: eventType,
              child: Text(eventType.asString),
            ),
          )
          .toList(),
    );
  }
}
