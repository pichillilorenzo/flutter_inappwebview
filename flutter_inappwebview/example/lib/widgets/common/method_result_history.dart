import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MethodResultEntry {
  final String message;
  final bool isError;
  final DateTime timestamp;

  const MethodResultEntry({
    required this.message,
    required this.isError,
    required this.timestamp,
  });
}

class MethodResultHistory extends StatelessWidget {
  const MethodResultHistory({
    super.key,
    required this.entries,
    this.selectedIndex,
    this.onSelected,
    this.maxEntries = 3,
    this.title,
    this.copyTooltip = 'Copy result',
    this.emptyLabel,
  });

  final List<MethodResultEntry> entries;
  final int? selectedIndex;
  final ValueChanged<int>? onSelected;
  final int maxEntries;
  final String? title;
  final String copyTooltip;
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      if (emptyLabel == null) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          emptyLabel!,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      );
    }

    final visibleEntries = entries.take(maxEntries).toList();
    final effectiveSelectedIndex =
        selectedIndex != null && selectedIndex! < visibleEntries.length
        ? selectedIndex!
        : 0;
    final selectedEntry = visibleEntries[effectiveSelectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title ?? 'History',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            IconButton(
              key: const Key('method-history-copy'),
              icon: const Icon(Icons.content_copy, size: 16),
              tooltip: copyTooltip,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: selectedEntry.message));
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        for (var index = 0; index < visibleEntries.length; index++)
          _HistoryEntryTile(
            key: Key('method-history-entry-$index'),
            entry: visibleEntries[index],
            isSelected: index == effectiveSelectedIndex,
            onTap: onSelected == null ? null : () => onSelected!(index),
          ),
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
