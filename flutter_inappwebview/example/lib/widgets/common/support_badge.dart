import 'package:flutter/material.dart';
import '../../utils/support_checker.dart';

class SupportBadge extends StatelessWidget {
  final SupportedPlatform platform;
  final bool isSupported;
  final bool showLabel;
  final bool compact;

  const SupportBadge({
    super.key,
    required this.platform,
    required this.isSupported,
    this.showLabel = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 14.0 : 16.0;
    final statusSize = compact ? 10.0 : 12.0;
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 3)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    final borderRadius = compact ? 10.0 : 12.0;

    final backgroundColor = isSupported
        ? platform.color.withOpacity(0.12)
        : Colors.grey.shade200;
    final borderColor = isSupported
        ? platform.color.withOpacity(0.4)
        : Colors.grey.shade300;
    final iconColor = isSupported ? platform.color : Colors.grey.shade500;

    return Tooltip(
      message:
          '${platform.displayName}: ${isSupported ? "Supported" : "Not supported"}',
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(platform.icon, size: iconSize, color: iconColor),
            if (showLabel) ...[
              const SizedBox(width: 4),
              Text(
                platform.displayName,
                style: TextStyle(
                  fontSize: compact ? 10 : 11,
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              isSupported ? Icons.check_circle : Icons.cancel,
              size: statusSize,
              color: isSupported ? Colors.green : Colors.red.shade300,
            ),
          ],
        ),
      ),
    );
  }
}

class SupportBadgesRow extends StatelessWidget {
  final Set<SupportedPlatform> supportedPlatforms;
  final List<SupportedPlatform> platforms;
  final bool showLabels;
  final bool compact;

  const SupportBadgesRow({
    super.key,
    required this.supportedPlatforms,
    this.platforms = SupportedPlatform.values,
    this.showLabels = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: compact ? 4 : 6,
      runSpacing: compact ? 4 : 6,
      children: platforms
          .map(
            (platform) => SupportBadge(
              platform: platform,
              isSupported: supportedPlatforms.contains(platform),
              showLabel: showLabels,
              compact: compact,
            ),
          )
          .toList(),
    );
  }
}
