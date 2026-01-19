import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/providers/settings_manager.dart';
import 'package:flutter_inappwebview_example/models/settings_profile.dart';
import 'package:flutter_inappwebview_example/utils/platform_utils.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';
import 'package:flutter_inappwebview_example/main.dart';

/// Comprehensive settings editor for InAppWebViewSettings
class SettingsEditorScreen extends StatefulWidget {
  const SettingsEditorScreen({super.key});

  @override
  State<SettingsEditorScreen> createState() => _SettingsEditorScreenState();
}

class _SettingsEditorScreenState extends State<SettingsEditorScreen> {
  final TextEditingController _profileNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<String> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    // Initialize the settings manager if not already done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsManager = context.read<SettingsManager>();
      if (settingsManager.isLoading) {
        settingsManager.init();
      }
    });
  }

  @override
  void dispose() {
    _profileNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  SupportedPlatform? get _currentPlatform => PlatformUtils.getCurrentPlatform();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Profile',
            onPressed: _showSaveProfileDialog,
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Load Profile',
            onPressed: _showLoadProfileDialog,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: ListTile(
                  leading: Icon(Icons.restore),
                  title: Text('Reset to Defaults'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Export JSON'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: ListTile(
                  leading: Icon(Icons.upload),
                  title: Text('Import JSON'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'expand_all',
                child: ListTile(
                  leading: Icon(Icons.unfold_more),
                  title: Text('Expand All'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'collapse_all',
                child: ListTile(
                  leading: Icon(Icons.unfold_less),
                  title: Text('Collapse All'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: buildDrawer(context: context),
      body: Consumer<SettingsManager>(
        builder: (context, settingsManager, child) {
          if (settingsManager.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final definitions = SettingsManager.getSettingDefinitions();

          return Column(
            children: [
              _buildHeader(settingsManager),
              _buildSearchBar(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: definitions.entries.map((entry) {
                    return _buildCategorySection(
                      entry.key,
                      entry.value,
                      settingsManager,
                    );
                  }).toList(),
                ),
              ),
              _buildBottomBar(settingsManager),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(SettingsManager settingsManager) {
    final profile = settingsManager.currentProfile;
    final modifiedCount = settingsManager.modifiedSettings.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Icon(Icons.settings, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile != null
                      ? 'Profile: ${profile.name}'
                      : 'New Configuration',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  modifiedCount > 0
                      ? '$modifiedCount setting${modifiedCount == 1 ? '' : 's'} modified'
                      : 'Using default settings',
                  style: TextStyle(
                    fontSize: 12,
                    color: modifiedCount > 0
                        ? Colors.orange.shade700
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Chip(
            label: Text(
              _currentPlatform?.displayName.toUpperCase() ?? 'UNKNOWN',
            ),
            backgroundColor: Colors.blue.shade100,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search settings...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value.toLowerCase());
        },
      ),
    );
  }

  Widget _buildCategorySection(
    String category,
    List<SettingDefinition> settings,
    SettingsManager settingsManager,
  ) {
    // Filter settings based on search query
    final filteredSettings = settings.where((setting) {
      if (_searchQuery.isEmpty) return true;
      return setting.name.toLowerCase().contains(_searchQuery) ||
          setting.description.toLowerCase().contains(_searchQuery) ||
          setting.key.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredSettings.isEmpty) return const SizedBox.shrink();

    final isExpanded =
        _expandedCategories.contains(category) || _searchQuery.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        key: Key(category),
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            if (expanded) {
              _expandedCategories.add(category);
            } else {
              _expandedCategories.remove(category);
            }
          });
        },
        title: Row(
          children: [
            Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${filteredSettings.length}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${filteredSettings.length} setting${filteredSettings.length == 1 ? '' : 's'}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        children: filteredSettings.map((setting) {
          return _buildSettingTile(setting, settingsManager);
        }).toList(),
      ),
    );
  }

  Widget _buildSettingTile(
    SettingDefinition setting,
    SettingsManager settingsManager,
  ) {
    final isModified = settingsManager.isSettingModified(setting.key);
    final currentValue = settingsManager.getSetting(setting.key);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isModified ? Colors.orange.shade50 : null,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            setting.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (isModified) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Modified',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      setting.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isModified)
                IconButton(
                  icon: const Icon(Icons.restore, size: 20),
                  tooltip: 'Reset to default',
                  onPressed: () => settingsManager.resetSetting(setting.key),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildSettingControl(setting, currentValue, settingsManager),
        ],
      ),
    );
  }

  Widget _buildSettingControl(
    SettingDefinition setting,
    dynamic currentValue,
    SettingsManager settingsManager,
  ) {
    switch (setting.type) {
      case SettingType.boolean:
        return Switch(
          value: currentValue ?? setting.defaultValue ?? false,
          onChanged: (value) =>
              settingsManager.updateSetting(setting.key, value),
        );

      case SettingType.string:
        return SizedBox(
          width: 150,
          child: TextField(
            controller: TextEditingController(
              text: currentValue?.toString() ?? '',
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(fontSize: 14),
            onChanged: (value) =>
                settingsManager.updateSetting(setting.key, value),
          ),
        );

      case SettingType.integer:
        return SizedBox(
          width: 80,
          child: TextField(
            controller: TextEditingController(
              text: currentValue?.toString() ?? '',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(fontSize: 14),
            onChanged: (value) {
              final intValue = int.tryParse(value);
              if (intValue != null) {
                settingsManager.updateSetting(setting.key, intValue);
              }
            },
          ),
        );

      case SettingType.double:
        return SizedBox(
          width: 80,
          child: TextField(
            controller: TextEditingController(
              text: currentValue?.toString() ?? '',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(fontSize: 14),
            onChanged: (value) {
              final doubleValue = double.tryParse(value);
              if (doubleValue != null) {
                settingsManager.updateSetting(setting.key, doubleValue);
              }
            },
          ),
        );

      case SettingType.enumeration:
        if (setting.enumValues == null) {
          return const SizedBox.shrink();
        }
        return DropdownButton<dynamic>(
          value: currentValue ?? setting.defaultValue,
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('Not Set', style: TextStyle(fontSize: 14)),
            ),
            ...setting.enumValues!.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.value,
                child: Text(entry.key, style: const TextStyle(fontSize: 14)),
              );
            }),
          ],
          onChanged: (value) =>
              settingsManager.updateSetting(setting.key, value),
        );
    }
  }

  Widget _buildBottomBar(SettingsManager settingsManager) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.restore),
            label: const Text('Reset All'),
            onPressed: () => _showResetConfirmDialog(settingsManager),
          ),
          const Spacer(),
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Apply to WebView'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final settings = settingsManager.buildSettings();
              Navigator.pop(context, settings);
            },
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    final settingsManager = context.read<SettingsManager>();

    switch (action) {
      case 'reset':
        _showResetConfirmDialog(settingsManager);
        break;
      case 'export':
        _exportSettings(settingsManager);
        break;
      case 'import':
        _showImportDialog(settingsManager);
        break;
      case 'expand_all':
        setState(() {
          _expandedCategories = SettingsManager.getSettingDefinitions().keys
              .toSet();
        });
        break;
      case 'collapse_all':
        setState(() {
          _expandedCategories.clear();
        });
        break;
    }
  }

  void _showSaveProfileDialog() {
    final settingsManager = context.read<SettingsManager>();
    final currentProfile = settingsManager.currentProfile;
    _profileNameController.text = currentProfile?.name ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _profileNameController,
              decoration: const InputDecoration(
                labelText: 'Profile Name',
                hintText: 'Enter a name for this profile',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Text(
              'This will save ${settingsManager.modifiedSettings.length} modified settings.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _profileNameController.text.trim();
              if (name.isNotEmpty) {
                await settingsManager.saveCurrentSettings(name);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile "$name" saved')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLoadProfileDialog() {
    final settingsManager = context.read<SettingsManager>();

    if (settingsManager.profiles.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No saved profiles found')));
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final profiles = settingsManager.profiles;

          if (profiles.isEmpty) {
            // Close dialog if all profiles were deleted
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pop(dialogContext);
            });
            return const SizedBox.shrink();
          }

          return AlertDialog(
            title: const Text('Load Profile'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  final isCurrentProfile =
                      profile.id == settingsManager.currentProfileId;

                  return ListTile(
                    title: Text(profile.name),
                    subtitle: Text(
                      '${profile.settings.length} settings • Created ${_formatDate(profile.createdAt)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    leading: Icon(
                      isCurrentProfile ? Icons.check_circle : Icons.folder,
                      color: isCurrentProfile ? Colors.green : null,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDeleteProfile(
                        profile,
                        onDeleted: () => setDialogState(() {}),
                      ),
                    ),
                    onTap: () async {
                      await settingsManager.loadProfile(profile.id);
                      if (mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text('Loaded profile "${profile.name}"'),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteProfile(
    SettingsProfile profile, {
    VoidCallback? onDeleted,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text('Are you sure you want to delete "${profile.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<SettingsManager>().deleteProfile(profile.id);
              if (mounted) {
                Navigator.pop(dialogContext);
                onDeleted?.call();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted profile "${profile.name}"')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmDialog(SettingsManager settingsManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await settingsManager.resetToDefaults();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings reset to defaults')),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _exportSettings(SettingsManager settingsManager) {
    final json = settingsManager.exportSettingsAsJson();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Settings'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Copy the JSON below:',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      json,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: json));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            child: const Text('Copy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(SettingsManager settingsManager) {
    final importController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Settings'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Paste JSON settings:',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: importController,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    hintText: '{"settings": {...}}',
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
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
              final success = await settingsManager.importSettingsFromJson(
                importController.text,
              );
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Settings imported successfully'
                          : 'Failed to import settings - invalid JSON',
                    ),
                  ),
                );
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'today';
    } else if (diff.inDays == 1) {
      return 'yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
