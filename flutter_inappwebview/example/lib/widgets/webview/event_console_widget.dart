import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/models/event_log_entry.dart';
import 'package:flutter_inappwebview_example/providers/event_log_provider.dart';

/// Widget to display WebView event logs in a console-like interface
class EventConsoleWidget extends StatefulWidget {
  const EventConsoleWidget({super.key});

  @override
  State<EventConsoleWidget> createState() => _EventConsoleWidgetState();
}

class _EventConsoleWidgetState extends State<EventConsoleWidget> {
  EventType? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(child: _buildEventList()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          const Text(
            'Events',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 16),
          Expanded(child: _buildFilterDropdown()),
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear',
            onPressed: () {
              context.read<EventLogProvider>().clear();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return DropdownButton<EventType?>(
      value: _selectedFilter,
      isExpanded: true,
      hint: const Text('All Events'),
      items: [
        const DropdownMenuItem<EventType?>(
          value: null,
          child: Text('All Events'),
        ),
        ...EventType.values.map((type) {
          return DropdownMenuItem<EventType?>(
            value: type,
            child: Text(type.name),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedFilter = value;
        });
      },
    );
  }

  Widget _buildEventList() {
    return Consumer<EventLogProvider>(
      builder: (context, provider, child) {
        final events = _selectedFilter == null
            ? provider.events
            : provider.filterByType(_selectedFilter);

        if (events.isEmpty) {
          return const Center(
            child: Text(
              'No events logged yet',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: events.length,
          reverse: true, // Show latest at top
          itemBuilder: (context, index) {
            final event = events[events.length - 1 - index];
            return _buildEventItem(event);
          },
        );
      },
    );
  }

  Widget _buildEventItem(EventLogEntry event) {
    final timeFormat = DateFormat('HH:mm:ss.SSS');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getEventTypeColor(event.eventType),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            event.eventType.name,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(event.message, style: const TextStyle(fontSize: 14)),
        subtitle: Text(
          timeFormat.format(event.timestamp),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        children: event.data != null
            ? [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey.shade50,
                  width: double.infinity,
                  child: _buildEventData(event.data!),
                ),
              ]
            : [],
      ),
    );
  }

  Widget _buildEventData(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${entry.key}: ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Expanded(
                child: Text(
                  entry.value.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getEventTypeColor(EventType type) {
    switch (type) {
      case EventType.navigation:
        return Colors.blue.shade50;
      case EventType.javascript:
        return Colors.purple.shade50;
      case EventType.console:
        return Colors.orange.shade50;
      case EventType.network:
        return Colors.green.shade50;
      case EventType.error:
        return Colors.red.shade50;
      case EventType.performance:
        return Colors.teal.shade50;
      case EventType.storage:
        return Colors.amber.shade50;
      case EventType.cookies:
        return Colors.brown.shade50;
      case EventType.messaging:
        return Colors.indigo.shade50;
      case EventType.ui:
        return Colors.cyan.shade50;
    }
  }
}
