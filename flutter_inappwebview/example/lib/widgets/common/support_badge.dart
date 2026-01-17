import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_example/utils/constants.dart';

/// Widget displaying platform support badges with colored icons
class SupportBadge extends StatelessWidget {
  final List<String> supportedPlatforms;
  final String currentPlatform;

  const SupportBadge({
    super.key,
    required this.supportedPlatforms,
    required this.currentPlatform,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: allPlatforms.map((platform) {
        final isSupported = supportedPlatforms.contains(platform);
        final isCurrent = platform == currentPlatform;

        return Tooltip(
          message:
              '${platformNames[platform]} - ${isSupported ? 'Supported' : 'Not Supported'}',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSupported
                  ? SupportBadgeColors.supported.withOpacity(0.1)
                  : SupportBadgeColors.unsupported.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: isCurrent
                  ? Border.all(
                      color: isSupported
                          ? SupportBadgeColors.supported
                          : SupportBadgeColors.unsupported,
                      width: 2,
                    )
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSupported ? Icons.check : Icons.close,
                  size: 14,
                  color: isSupported
                      ? SupportBadgeColors.supported
                      : SupportBadgeColors.unsupported,
                ),
                const SizedBox(width: 2),
                Text(
                  platformNames[platform]!,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSupported
                        ? SupportBadgeColors.supported
                        : SupportBadgeColors.unsupported,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
