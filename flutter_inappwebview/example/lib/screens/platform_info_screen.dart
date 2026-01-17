import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../utils/platform_utils.dart';

/// Screen displaying detailed platform information and capabilities.
class PlatformInfoScreen extends StatelessWidget {
  const PlatformInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Platform Information')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            context,
            title: 'Platform Details',
            icon: PlatformUtils.getPlatformIcon(),
            children: [
              _buildInfoTile(
                'Platform',
                PlatformUtils.getPlatformName(),
                Icons.devices,
              ),
              _buildInfoTile(
                'Flutter Version',
                PlatformUtils.getFlutterVersion(),
                Icons.flutter_dash,
              ),
              _buildInfoTile(
                'Dart Version',
                PlatformUtils.getDartVersion(),
                Icons.code,
              ),
              _buildInfoTile(
                'Platform Type',
                _getPlatformType(),
                Icons.category,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Supported Features',
            icon: Icons.check_circle_outline,
            children: [_buildFeaturesList(context)],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = _getSupportedFeatures();

    return Column(
      children: features.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Icon(
                entry.value ? Icons.check_circle : Icons.cancel,
                color: entry.value ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(entry.key, style: const TextStyle(fontSize: 14)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getPlatformType() {
    if (PlatformUtils.isWebPlatform()) {
      return 'Web';
    } else if (PlatformUtils.isMobilePlatform()) {
      return 'Mobile';
    } else if (PlatformUtils.isDesktopPlatform()) {
      return 'Desktop';
    }
    return 'Unknown';
  }

  Map<String, bool> _getSupportedFeatures() {
    // Check various platform class support
    try {
      return {
        'InAppWebView': InAppWebViewController.isClassSupported(),
        'CookieManager': CookieManager.isClassSupported(),
        'InAppBrowser': InAppBrowser.isClassSupported(),
        'ChromeSafariBrowser': ChromeSafariBrowser.isClassSupported(),
        'WebStorage': WebStorage.isClassSupported(),
        'HttpAuthCredentialDatabase':
            HttpAuthCredentialDatabase.isClassSupported(),
        'ServiceWorkerController': ServiceWorkerController.isClassSupported(),
        'WebViewEnvironment': WebViewEnvironment.isClassSupported(),
        'PullToRefreshController': PullToRefreshController.isClassSupported(),
        'FindInteractionController':
            FindInteractionController.isClassSupported(),
      };
    } catch (e) {
      // If platform is not initialized (e.g., in tests), return empty map
      return {};
    }
  }
}
