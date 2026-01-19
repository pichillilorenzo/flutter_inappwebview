import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/providers/settings_manager.dart';
import 'package:flutter_inappwebview_example/models/settings_profile.dart';
import 'package:flutter_inappwebview_example/models/webview_environment_profile.dart';

class ProfileSelectorCard extends StatelessWidget {
  const ProfileSelectorCard({super.key, required this.onEditSettingsProfile});

  final VoidCallback onEditSettingsProfile;

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
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                      const SizedBox(height: 16),
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
        const Text(
          'InAppWebView Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String?>(
                value: settingsManager.currentProfileId,
                decoration: const InputDecoration(
                  labelText: 'Settings Profile',
                  border: OutlineInputBorder(),
                  isDense: true,
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
              onPressed: onEditSettingsProfile,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete selected profile',
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
            const Expanded(
              child: Text(
                'WebView Environment',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (!supported)
              const Text(
                'Not supported',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String?>(
                value: settingsManager.currentEnvironmentProfileId,
                decoration: const InputDecoration(
                  labelText: 'Environment Profile',
                  border: OutlineInputBorder(),
                  isDense: true,
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
              icon: const Icon(Icons.add),
              tooltip: 'Create environment profile',
              onPressed: () => _showEnvironmentEditor(
                context,
                settingsManager,
                profile: null,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit environment profile',
              onPressed: current == null
                  ? null
                  : () => _showEnvironmentEditor(
                      context,
                      settingsManager,
                      profile: current,
                    ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete environment profile',
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

  Future<void> _showEnvironmentEditor(
    BuildContext context,
    SettingsManager settingsManager, {
    required WebViewEnvironmentProfile? profile,
  }) async {
    final nameController = TextEditingController(text: profile?.name ?? '');
    final jsonController = TextEditingController(
      text: const JsonEncoder.withIndent('  ').convert(
        profile?.settings ?? settingsManager.currentEnvironmentSettings,
      ),
    );

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          profile == null ? 'Create Environment' : 'Edit Environment',
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Profile Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: jsonController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Environment Settings (JSON)',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tip: Use WebViewEnvironmentSettings JSON map values.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name is required')),
                );
                return;
              }

              try {
                final decoded = jsonDecode(jsonController.text);
                if (decoded is! Map<String, dynamic>) {
                  throw const FormatException('Invalid JSON map');
                }
                final settings =
                    WebViewEnvironmentSettings.fromMap(decoded) ??
                    WebViewEnvironmentSettings();
                final settingsMap = settings.toMap();

                if (profile == null) {
                  await settingsManager.createEnvironmentProfile(
                    name,
                    settings: settingsMap,
                  );
                } else {
                  await settingsManager.updateEnvironmentProfile(
                    profile.id,
                    name: name,
                    settings: settingsMap,
                  );
                }

                if (context.mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Invalid JSON: $e')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
