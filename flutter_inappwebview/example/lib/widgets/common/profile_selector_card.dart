import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/providers/settings_manager.dart';
import 'package:flutter_inappwebview_example/models/settings_profile.dart';
import 'package:flutter_inappwebview_example/models/webview_environment_profile.dart';

class ProfileSelectorCard extends StatelessWidget {
  const ProfileSelectorCard({
    super.key,
    required this.onEditSettingsProfile,
    this.onEditEnvironmentProfile,
    this.compact = false,
  });

  final VoidCallback onEditSettingsProfile;
  final VoidCallback? onEditEnvironmentProfile;

  /// When true, displays a more compact layout suitable for embedding
  /// in constrained spaces (e.g., below WebView)
  final bool compact;

  static const double _desktopBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsManager>(
      builder: (context, settingsManager, _) {
        if (settingsManager.isLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return Card(
          margin: compact
              ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
              : null,
          child: Padding(
            padding: compact
                ? const EdgeInsets.all(8)
                : const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= _desktopBreakpoint;

                if (isWide) {
                  // Desktop: Two columns side by side
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildSettingsProfileRow(
                          context,
                          settingsManager,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildEnvironmentProfileRow(
                          context,
                          settingsManager,
                        ),
                      ),
                    ],
                  );
                } else {
                  // Mobile: One column stacked
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSettingsProfileRow(context, settingsManager),
                      SizedBox(height: compact ? 8 : 16),
                      _buildEnvironmentProfileRow(context, settingsManager),
                    ],
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsProfileRow(
    BuildContext context,
    SettingsManager settingsManager,
  ) {
    final current = settingsManager.currentProfile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${InAppWebView} Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: compact ? 12 : 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String?>(
                value: settingsManager.currentProfileId,
                decoration: InputDecoration(
                  labelText: 'Settings Profile',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  contentPadding: compact
                      ? const EdgeInsets.symmetric(horizontal: 8, vertical: 8)
                      : null,
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Default Settings'),
                  ),
                  ...settingsManager.profiles.map(
                    (profile) => DropdownMenuItem(
                      value: profile.id,
                      child: Text(profile.name),
                    ),
                  ),
                ],
                onChanged: (value) async {
                  if (value == null) {
                    await settingsManager.resetToDefaults();
                  } else {
                    await settingsManager.loadProfile(value);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit settings profile',
              constraints: compact
                  ? const BoxConstraints(minWidth: 32, minHeight: 32)
                  : null,
              iconSize: compact ? 18 : 24,
              onPressed: onEditSettingsProfile,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete selected profile',
              constraints: compact
                  ? const BoxConstraints(minWidth: 32, minHeight: 32)
                  : null,
              iconSize: compact ? 18 : 24,
              onPressed: current == null
                  ? null
                  : () => _confirmDeleteSettingsProfile(context, current),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnvironmentProfileRow(
    BuildContext context,
    SettingsManager settingsManager,
  ) {
    final current = settingsManager.currentEnvironmentProfile;
    final supported = settingsManager.isEnvironmentSupported;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$WebViewEnvironment',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 12 : 14,
                ),
              ),
            ),
            if (!supported)
              Text(
                'Not supported',
                style: TextStyle(
                  fontSize: compact ? 10 : 12,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String?>(
                value: settingsManager.currentEnvironmentProfileId,
                decoration: InputDecoration(
                  labelText: 'Environment Profile',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  contentPadding: compact
                      ? const EdgeInsets.symmetric(horizontal: 8, vertical: 8)
                      : null,
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('No Environment (Default)'),
                  ),
                  ...settingsManager.environmentProfiles.map(
                    (profile) => DropdownMenuItem(
                      value: profile.id,
                      child: Text(profile.name),
                    ),
                  ),
                ],
                onChanged: (value) async {
                  if (value == null) {
                    await settingsManager.clearEnvironmentSelection();
                  } else {
                    await settingsManager.loadEnvironmentProfile(value);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit environment profile',
              constraints: compact
                  ? const BoxConstraints(minWidth: 32, minHeight: 32)
                  : null,
              iconSize: compact ? 18 : 24,
              onPressed: onEditEnvironmentProfile,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete environment profile',
              constraints: compact
                  ? const BoxConstraints(minWidth: 32, minHeight: 32)
                  : null,
              iconSize: compact ? 18 : 24,
              onPressed: current == null
                  ? null
                  : () => _confirmDeleteEnvironmentProfile(context, current),
            ),
          ],
        ),
        if (settingsManager.isEnvironmentLoading)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  Future<void> _confirmDeleteSettingsProfile(
    BuildContext context,
    SettingsProfile profile,
  ) async {
    final shouldDelete = await _confirmDialog(
      context,
      title: 'Delete Settings Profile',
      message: 'Delete "${profile.name}"?',
    );
    if (shouldDelete) {
      await context.read<SettingsManager>().deleteProfile(profile.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted profile "${profile.name}"')),
        );
      }
    }
  }

  Future<void> _confirmDeleteEnvironmentProfile(
    BuildContext context,
    WebViewEnvironmentProfile profile,
  ) async {
    final shouldDelete = await _confirmDialog(
      context,
      title: 'Delete Environment Profile',
      message: 'Delete "${profile.name}"?',
    );
    if (shouldDelete) {
      await context.read<SettingsManager>().deleteEnvironmentProfile(
        profile.id,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted environment "${profile.name}"')),
        );
      }
    }
  }

  Future<bool> _confirmDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    return (await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        )) ??
        false;
  }
}
