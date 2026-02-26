import 'package:flutter/material.dart';

/// A widget displaying an empty state with an icon, title, and description.
///
/// Used across multiple screens (CookieManagerScreen, HttpAuthScreen,
/// WebStorageScreen, CategoryScreen) to provide consistent empty state UI.
class EmptyState extends StatelessWidget {
  /// The icon to display at the top of the empty state.
  final IconData icon;

  /// The main title text.
  final String title;

  /// An optional description providing additional context.
  final String? description;

  /// The size of the icon.
  final double iconSize;

  /// Optional action button to display below the description.
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.iconSize = 64,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

/// An empty state wrapped in a Card.
///
/// Useful when the empty state needs to be displayed within a card-based layout.
class EmptyStateCard extends StatelessWidget {
  /// The icon to display at the top of the empty state.
  final IconData icon;

  /// The main title text.
  final String title;

  /// An optional description providing additional context.
  final String? description;

  /// The size of the icon.
  final double iconSize;

  /// Optional action button to display below the description.
  final Widget? action;

  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.iconSize = 64,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: EmptyState(
        icon: icon,
        title: title,
        description: description,
        iconSize: iconSize,
        action: action,
      ),
    );
  }
}
