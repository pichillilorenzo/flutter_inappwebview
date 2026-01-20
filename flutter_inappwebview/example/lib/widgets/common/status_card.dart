import 'package:flutter/material.dart';

/// A card displaying the status of a component (e.g., browser, WebView, channel).
///
/// Used in screens like InAppBrowserScreen and ControllersScreen to show
/// whether a component is active/open or inactive/closed.
class StatusCard extends StatelessWidget {
  /// Whether the component is in an active/open state.
  final bool isActive;

  /// The icon to display when active.
  final IconData activeIcon;

  /// The icon to display when inactive.
  final IconData inactiveIcon;

  /// The title text to display when active.
  final String activeTitle;

  /// The title text to display when inactive.
  final String inactiveTitle;

  /// Optional subtitle text.
  final String? subtitle;

  /// Background color when active. Defaults to green shade.
  final Color? activeColor;

  /// Background color when inactive. Defaults to grey shade.
  final Color? inactiveColor;

  /// Optional trailing widget.
  final Widget? trailing;

  const StatusCard({
    super.key,
    required this.isActive,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.activeTitle,
    required this.inactiveTitle,
    this.subtitle,
    this.activeColor,
    this.inactiveColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isActive
        ? (activeColor ?? Colors.green.shade50)
        : (inactiveColor ?? Colors.grey.shade100);
    final iconColor = isActive ? Colors.green : Colors.grey;
    final textColor = isActive ? Colors.green : Colors.grey;

    return Card(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: iconColor,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isActive ? activeTitle : inactiveTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// A small status indicator badge with an icon and text.
///
/// Useful for showing inline status information like "WebView Ready" or "Loading...".
class StatusBadge extends StatelessWidget {
  /// Whether the status is positive/active.
  final bool isActive;

  /// The text to display.
  final String text;

  /// Optional icon to display. Defaults to check/cancel icons.
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.isActive,
    required this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon!, color: isActive ? Colors.green : Colors.white, size: 14)
          else
            Icon(
              isActive ? Icons.check : Icons.hourglass_empty,
              color: isActive ? Colors.green : Colors.white,
              size: 14,
            ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: isActive ? Colors.green : Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// A channel status indicator showing active/inactive state.
///
/// Used for WebMessageChannel and similar components.
class ChannelStatusIndicator extends StatelessWidget {
  /// Whether the channel is active.
  final bool isActive;

  /// Text to display when active.
  final String activeText;

  /// Text to display when inactive.
  final String inactiveText;

  const ChannelStatusIndicator({
    super.key,
    required this.isActive,
    this.activeText = 'Channel Active',
    this.inactiveText = 'No Channel',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            color: isActive ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isActive ? activeText : inactiveText,
            style: TextStyle(color: isActive ? Colors.green : Colors.grey),
          ),
        ],
      ),
    );
  }
}
