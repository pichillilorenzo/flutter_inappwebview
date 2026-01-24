import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';
import 'package:flutter_inappwebview_example/utils/responsive_utils.dart';
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
  /// If null or empty, no support badges are shown.
  final Set<SupportedPlatform>? supportedPlatforms;

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

  /// Optional leading widget (e.g., check icon for selected state).
  final Widget? leading;

  /// Optional background color for the card.
  final Color? backgroundColor;

  /// Optional extra content to display below the main content.
  /// Useful for parameter configuration sections.
  final Widget? extraContent;

  /// Whether to hide the trailing widget entirely.
  final bool hideTrailing;

  const MethodCard({
    super.key,
    required this.methodName,
    required this.description,
    this.supportedPlatforms,
    this.historyEntries,
    this.selectedHistoryIndex,
    this.onHistorySelected,
    this.onRun,
    this.isLoading = false,
    this.trailing,
    this.historyTitle,
    this.leading,
    this.backgroundColor,
    this.extraContent,
    this.hideTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final entries = historyEntries ?? const [];
    final platforms = supportedPlatforms ?? const {};
    final buttonStyle = isMobile
        ? ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: const Size(0, 40),
            textStyle: const TextStyle(
              inherit: false,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          )
        : null;

    Widget? trailingWidget;
    if (!hideTrailing) {
      trailingWidget =
          trailing ??
          ElevatedButton(
            key: const Key('method-card-run-button'),
            style: buttonStyle,
            onPressed: !isLoading ? onRun : null,
            child: const Text('Run'),
          );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: backgroundColor,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 6 : 8,
        ),
        leading: leading,
        title: Text(
          methodName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 13 : 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: Colors.grey.shade600,
              ),
            ),
            if (platforms.isNotEmpty) ...[
              const SizedBox(height: 6),
              SupportBadgesRow(supportedPlatforms: platforms, compact: true),
            ],
            if (entries.isNotEmpty) ...[
              const SizedBox(height: 6),
              MethodResultHistory(
                entries: entries,
                selectedIndex: selectedHistoryIndex,
                title: historyTitle ?? methodName,
                onSelected: onHistorySelected,
              ),
            ],
            if (extraContent != null) ...[const Divider(), extraContent!],
          ],
        ),
        trailing: trailingWidget,
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
    final isMobile = context.isMobile;
    final entries = historyEntries ?? const [];
    final buttonStyle = isMobile
        ? ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: const Size(0, 40),
            textStyle: const TextStyle(
              inherit: false,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          )
        : null;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 6 : 8,
        ),
        title: Text(
          methodName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 13 : 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: Colors.grey.shade600,
              ),
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
          style: buttonStyle,
          onPressed: !isLoading ? onRun : null,
          child: const Text('Run'),
        ),
      ),
    );
  }
}
