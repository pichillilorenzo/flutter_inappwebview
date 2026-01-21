import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MethodResultEntry {
  final String message;
  final bool isError;
  final DateTime timestamp;
  final dynamic value;

  const MethodResultEntry({
    required this.message,
    required this.isError,
    required this.timestamp,
    this.value,
  });

  /// Returns the copyable string representation of the result value.
  /// Attempts toMap()/toJson() conversion first, then JSON encoding, falls back to toString().
  String get copyableValue {
    if (value == null) return message;

    // Try to convert to serializable form first
    final serializable = _toSerializable(value);

    try {
      return const JsonEncoder.withIndent('  ').convert(serializable);
    } catch (_) {
      return serializable.toString();
    }
  }

  /// Converts a value to a JSON-serializable form.
  /// Handles objects with toMap() or toJson() methods, Lists, Maps, and primitives.
  static dynamic _toSerializable(dynamic value) {
    if (value == null) return null;
    if (value is String || value is num || value is bool) return value;

    // Handle List recursively
    if (value is List) {
      return value.map(_toSerializable).toList();
    }

    // Handle Map recursively
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _toSerializable(v)));
    }

    // Try toMap() - common in flutter_inappwebview objects
    try {
      final result = (value as dynamic).toMap?.call();
      if (result is Map) {
        return _toSerializable(result);
      }
    } catch (_) {}

    // Try toJson() - common in many Flutter/Dart packages
    try {
      final result = (value as dynamic).toJson?.call();
      if (result is Map) {
        return _toSerializable(result);
      }
    } catch (_) {}

    // Fallback to toString()
    return value.toString();
  }
}

class MethodResultHistory extends StatefulWidget {
  const MethodResultHistory({
    super.key,
    required this.entries,
    this.selectedIndex,
    this.onSelected,
    this.maxEntries = 3,
    this.title,
    this.copyTooltip = 'Copy result',
    this.emptyLabel,
    this.initiallyExpanded = false,
  });

  final List<MethodResultEntry> entries;
  final int? selectedIndex;
  final ValueChanged<int>? onSelected;
  final int maxEntries;
  final String? title;
  final String copyTooltip;
  final String? emptyLabel;
  final bool initiallyExpanded;

  @override
  State<MethodResultHistory> createState() => _MethodResultHistoryState();
}

class _MethodResultHistoryState extends State<MethodResultHistory> {
  late bool _isExpanded;
  late int _localSelectedIndex;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _localSelectedIndex = widget.selectedIndex ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.entries.isEmpty) {
      if (widget.emptyLabel == null) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          widget.emptyLabel!,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      );
    }

    final visibleEntries = widget.entries.take(widget.maxEntries).toList();
    final effectiveSelectedIndex =
        widget.selectedIndex != null &&
            widget.selectedIndex! < visibleEntries.length
        ? widget.selectedIndex!
        : (_localSelectedIndex < visibleEntries.length
              ? _localSelectedIndex
              : 0);
    final selectedEntry = visibleEntries[effectiveSelectedIndex];
    final latestEntry = visibleEntries.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.title ?? 'History',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                // Show latest result status icon when collapsed
                if (!_isExpanded) ...[
                  Icon(
                    latestEntry.isError
                        ? Icons.error_outline
                        : Icons.check_circle,
                    size: 14,
                    color: latestEntry.isError ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      latestEntry.message,
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: latestEntry.isError
                            ? Colors.red.shade800
                            : Colors.green.shade800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else ...[
                  const Spacer(),
                ],
                IconButton(
                  key: const Key('method-history-copy'),
                  icon: const Icon(Icons.content_copy, size: 16),
                  tooltip: widget.copyTooltip,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: selectedEntry.copyableValue),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Result copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 4),
          for (var index = 0; index < visibleEntries.length; index++)
            _HistoryEntryTile(
              key: Key('method-history-entry-$index'),
              entry: visibleEntries[index],
              isSelected: index == effectiveSelectedIndex,
              onTap: widget.onSelected == null
                  ? () => setState(() => _localSelectedIndex = index)
                  : () => widget.onSelected!(index),
            ),
        ],
      ],
    );
  }
}

class _HistoryEntryTile extends StatelessWidget {
  const _HistoryEntryTile({
    super.key,
    required this.entry,
    required this.isSelected,
    this.onTap,
  });

  final MethodResultEntry entry;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final baseColor = entry.isError ? Colors.red : Colors.green;
    final borderColor = isSelected ? baseColor : Colors.grey.shade300;
    final backgroundColor = isSelected
        ? baseColor.withOpacity(0.1)
        : Colors.grey.shade100;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              entry.isError ? Icons.error_outline : Icons.check_circle,
              size: 14,
              color: baseColor,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                entry.message,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: baseColor.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
