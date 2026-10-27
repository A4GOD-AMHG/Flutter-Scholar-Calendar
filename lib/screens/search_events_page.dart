import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scholar_calendar/components/bottom_sheet_add_event_widget.dart';
import 'package:scholar_calendar/components/empty_state.dart';
import 'package:scholar_calendar/controllers/database_controller.dart';
import 'package:scholar_calendar/models/event.dart';
import 'package:scholar_calendar/models/signature.dart';
import 'package:scholar_calendar/utils/features_discoveries.dart';

class SearchEventsPage extends StatefulWidget {
  const SearchEventsPage({super.key});

  @override
  State<SearchEventsPage> createState() => _SearchEventsPageState();
}

class _SearchEventsPageState extends State<SearchEventsPage> {
  @override
  void initState() {
    super.initState();
    if (getShowDiscovery(keySearchEvents) ?? true) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => showDiscovery(
          context,
          listId: [kFeatureId8SearchEvents],
          key: keySearchEvents,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buscar Eventos"),
        actions: [
          buildWidget(
            context,
            featureId: kFeatureId8SearchEvents,
            tapTarget: const Icon(Icons.search),
            child: IconButton(
              tooltip: "Buscar",
              onPressed: _showSearch,
              icon: const Icon(Icons.search),
            ),
            contentLocation: ContentLocation.trivial,
            title: "Buscar Eventos",
            description: "Pulse aquí para buscar un evento por nombre",
          ),
        ],
      ),
      body: EmptyState(
        icon: Icons.manage_search_outlined,
        message: "Busque cualquier evento por su nombre",
        action: FilledButton.icon(
          onPressed: _showSearch,
          icon: const Icon(Icons.search),
          label: const Text("Buscar"),
        ),
      ),
    );
  }

  Future<void> _showSearch() async {
    final events = await databaseController.getEvents();
    final signatures = await databaseController.getSignatures();
    if (!mounted) return;
    showSearch(
      context: context,
      delegate: CustomSearchDelegate(
        events: events,
        signatures: {for (final s in signatures) s.id!: s},
      ),
    );
  }
}

///[CustomSearchDelegate] clase para definir las búsquedas, su contenido y funcionamiento
///
///[events] lista de todos los eventos
///
///[signatures] asignaturas indexadas por id
class CustomSearchDelegate extends SearchDelegate {
  final List<Event> events;
  final Map<int, Signature> signatures;

  CustomSearchDelegate({required this.events, required this.signatures})
    : super(searchFieldLabel: "Nombre del evento");

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: theme.colorScheme.surfaceContainerHigh,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          tooltip: "Limpiar",
          onPressed: () => query = '',
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  TextInputAction get textInputAction => TextInputAction.search;

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  ///[_dayLabel] "Hoy", "Ayer", "Mañana" o la fecha completa en español
  static String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (day.difference(today).inDays) {
      case -1:
        return "Ayer";
      case 0:
        return "Hoy";
      case 1:
        return "Mañana";
    }
    return "${DateFormat('EEEE, d', 'es_ES').format(day)} de "
        "${DateFormat('MMMM', 'es_ES').format(day)} del "
        "${DateFormat('y', 'es_ES').format(day)}";
  }

  Widget _buildList(BuildContext context) {
    final lowerQuery = query.toLowerCase();
    // solo eventos cuya asignatura existe, para no romper la lista
    final results = events
        .where(
          (event) =>
              signatures.containsKey(event.idSignature) &&
              event.name.toLowerCase().contains(lowerQuery),
        )
        .toList();
    if (results.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_outlined,
        message: "No se han encontrado resultados.",
      );
    }
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final event = results[index];
        final signature = signatures[event.idSignature]!;
        final day = DateUtils.dateOnly(event.startTime);
        final isNewDay =
            index == 0 ||
            !DateUtils.isSameDay(results[index - 1].startTime, day);
        final tile = _buildListTile(context, signature, event);
        if (!isNewDay) return tile;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Text(
                _dayLabel(day),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            tile,
          ],
        );
      },
    );
  }

  Widget _buildListTile(
    BuildContext context,
    Signature signature,
    Event event,
  ) {
    final time = DateFormat('hh:mm a', 'es_ES');
    return Card(
      child: ListTile(
        onTap: () => _showEvent(context, event, signature),
        leading: CircleAvatar(
          backgroundColor: event.color,
          foregroundColor:
              ThemeData.estimateBrightnessForColor(event.color) ==
                  Brightness.dark
              ? Colors.white
              : Colors.black87,
          child: Text(
            signature.symbology,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(event.name),
        subtitle: Text(
          "${signature.name}\n${time.format(event.startTime)} - ${time.format(event.endTime)}",
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  void _showEvent(
    BuildContext context,
    Event event,
    Signature signature,
  ) async {
    final alarm = await databaseController.getAlarmById(event.idAlarm!);
    if (!context.mounted) return;
    showEventSheet(
      context,
      event: event,
      alarm: alarm,
      signatureName: signature.name,
    );
  }
}
