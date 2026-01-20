import 'package:flutter/material.dart';

/// A card containing grouped methods under a section title.
///
/// Used in screens like InAppBrowserScreen to group related methods
/// (e.g., "Open Methods", "Control Methods", "Settings Methods").
class MethodSectionCard extends StatelessWidget {
  /// The title of the section.
  final String title;

  /// The child widgets (typically method tiles or buttons).
  final List<Widget> children;

  /// Optional icon to display next to the title.
  final IconData? icon;

  const MethodSectionCard({
    super.key,
    required this.title,
    required this.children,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// A card with a header row containing a title and refresh button.
///
/// Used for data lists like cookies, credentials, origins, etc.
class DataListCard extends StatelessWidget {
  /// The title to display in the header.
  final String title;

  /// The count to display next to the title.
  final int? count;

  /// Optional secondary count (e.g., "5 of 10" when filtered).
  final int? totalCount;

  /// Called when the refresh button is pressed. If null, button is hidden.
  final VoidCallback? onRefresh;

  /// Whether refresh is disabled.
  final bool refreshDisabled;

  /// The child widget (typically a list or table).
  final Widget child;

  const DataListCard({
    super.key,
    required this.title,
    this.count,
    this.totalCount,
    this.onRefresh,
    this.refreshDisabled = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  _buildTitleText(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (onRefresh != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: refreshDisabled ? null : onRefresh,
                    tooltip: 'Refresh',
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }

  String _buildTitleText() {
    if (count == null) return title;
    if (totalCount != null && totalCount != count) {
      return '$title ($count of $totalCount)';
    }
    return '$title ($count)';
  }
}

/// A grouped section within a card containing related information.
///
/// Used for displaying categorized features in PlatformInfoScreen.
class InfoSection extends StatelessWidget {
  /// The title of the section.
  final String title;

  /// Icon to display next to the title.
  final IconData icon;

  /// The child widgets.
  final List<Widget> children;

  const InfoSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}
