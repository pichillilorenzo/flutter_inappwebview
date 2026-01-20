import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';
import 'package:flutter_inappwebview_example/widgets/common/support_badge.dart';
import 'package:flutter_inappwebview_example/widgets/common/method_result_history.dart';

/// A card displaying a method with its description, platform support badges,
/// result history, and a run button.
///
/// Used across multiple screens (CookieManagerScreen, HttpAuthScreen,
/// WebStorageScreen, InAppBrowserScreen, etc.) to provide a consistent
/// method testing UI.
class MethodCard extends StatelessWidget {
  /// The name of the method to display.
  final String methodName;

  /// A description of what the method does.
  final String description;

  /// The set of platforms that support this method.
  final Set<SupportedPlatform> supportedPlatforms;

  /// The result history entries to display.
  final List<MethodResultEntry>? historyEntries;

  /// The currently selected history index.
  final int? selectedHistoryIndex;

  /// Called when the user selects a history entry.
  final ValueChanged<int>? onHistorySelected;

  /// Called when the run button is pressed. If null, the button is disabled.
  final VoidCallback? onRun;

  /// Whether to show a loading state on the run button.
  final bool isLoading;

  /// Optional trailing widget to use instead of the default run button.
  final Widget? trailing;

  /// Optional title to use for the history section.
  final String? historyTitle;

  const MethodCard({
    super.key,
    required this.methodName,
    required this.description,
    required this.supportedPlatforms,
    this.historyEntries,
    this.selectedHistoryIndex,
    this.onHistorySelected,
    this.onRun,
    this.isLoading = false,
    this.trailing,
    this.historyTitle,
  });

  @override
  Widget build(BuildContext context) {
    final entries = historyEntries ?? const [];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          methodName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 6),
            SupportBadgesRow(
              supportedPlatforms: supportedPlatforms,
              compact: true,
            ),
            if (entries.isNotEmpty) ...[
              const SizedBox(height: 6),
              MethodResultHistory(
                entries: entries,
                selectedIndex: selectedHistoryIndex,
                title: historyTitle ?? methodName,
                onSelected: onHistorySelected,
              ),
            ],
          ],
        ),
        trailing:
            trailing ??
            ElevatedButton(
              onPressed: !isLoading ? onRun : null,
              child: const Text('Run'),
            ),
      ),
    );
  }
}

/// A denser method tile for use in grouped method sections.
///
/// Similar to [MethodCard] but with a denser layout suitable for
/// embedding in card sections like "Open Methods", "Control Methods", etc.
class MethodTile extends StatelessWidget {
  /// The name of the method to display.
  final String methodName;

  /// A description of what the method does.
  final String description;

  /// The set of platforms that support this method.
  final Set<SupportedPlatform> supportedPlatforms;

  /// The result history entries to display.
  final List<MethodResultEntry>? historyEntries;

  /// The currently selected history index.
  final int? selectedHistoryIndex;

  /// Called when the user selects a history entry.
  final ValueChanged<int>? onHistorySelected;

  /// Called when the run button is pressed. If null, the button is disabled.
  final VoidCallback? onRun;

  /// Whether to show a loading state on the run button.
  final bool isLoading;

  /// Optional title to use for the history section.
  final String? historyTitle;

  const MethodTile({
    super.key,
    required this.methodName,
    required this.description,
    required this.supportedPlatforms,
    this.historyEntries,
    this.selectedHistoryIndex,
    this.onHistorySelected,
    this.onRun,
    this.isLoading = false,
    this.historyTitle,
  });

  @override
  Widget build(BuildContext context) {
    final entries = historyEntries ?? const [];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          methodName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 6),
            SupportBadgesRow(
              supportedPlatforms: supportedPlatforms,
              compact: true,
            ),
            if (entries.isNotEmpty) ...[
              const SizedBox(height: 6),
              MethodResultHistory(
                entries: entries,
                selectedIndex: selectedHistoryIndex,
                title: historyTitle ?? methodName,
                onSelected: onHistorySelected,
              ),
            ],
          ],
        ),
        trailing: ElevatedButton(
          onPressed: !isLoading ? onRun : null,
          child: const Text('Run'),
        ),
      ),
    );
  }
}
