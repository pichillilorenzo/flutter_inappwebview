import 'package:flutter/material.dart';

/// An AppBar loading indicator for use in the actions section.
///
/// Shows a small circular progress indicator when loading is true,
/// otherwise shows nothing.
class AppBarLoadingIndicator extends StatelessWidget {
  /// Whether to show the loading indicator.
  final bool isLoading;

  const AppBarLoadingIndicator({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return const Padding(
      padding: EdgeInsets.all(16),
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      ),
    );
  }
}
