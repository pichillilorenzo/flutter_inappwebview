import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/providers/settings_manager.dart';
import 'package:flutter_inappwebview_example/models/webview_environment_profile.dart';
import 'package:flutter_inappwebview_example/utils/platform_utils.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';
import 'package:flutter_inappwebview_example/main.dart';

/// Comprehensive settings editor for WebViewEnvironmentSettings
/// Used to configure WebView2 (Windows) and WPE WebKit (Linux) environments
class WebViewEnvironmentSettingsEditorScreen extends StatefulWidget {
  const WebViewEnvironmentSettingsEditorScreen({super.key});

  @override
  State<WebViewEnvironmentSettingsEditorScreen> createState() =>
      _WebViewEnvironmentSettingsEditorScreenState();
}

class _WebViewEnvironmentSettingsEditorScreenState
    extends State<WebViewEnvironmentSettingsEditorScreen> {
  final TextEditingController _profileNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<String> _expandedCategories = {};
  Map<String, dynamic> _localSettings = {};
  Set<String> _modifiedKeys = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsManager = context.read<SettingsManager>();
      if (settingsManager.isLoading) {
        settingsManager.init();
      }
      _loadCurrentSettings();
    });
  }

  void _loadCurrentSettings() {
    final settingsManager = context.read<SettingsManager>();
    setState(() {
      _localSettings = Map<String, dynamic>.from(
        settingsManager.currentEnvironmentSettings,
      );
      _modifiedKeys.clear();
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
        title: const Text('Environment Settings'),
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
                value: 'clear_selection',
                child: ListTile(
                  leading: Icon(Icons.clear),
                  title: Text('Clear Environment'),
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

          final definitions = getEnvironmentSettingDefinitions();

          return Column(
            children: [
              _buildHeader(settingsManager),
              if (!settingsManager.isEnvironmentSupported)
                _buildUnsupportedPlatformBanner(),
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

  Widget _buildUnsupportedPlatformBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Limited Platform Support',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${WebViewEnvironment} is only functional on Windows and Linux. '
                  'Settings below show what\'s available on those platforms.',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(SettingsManager settingsManager) {
    final profile = settingsManager.currentEnvironmentProfile;
    final modifiedCount = _modifiedKeys.length;
    final envStatus = settingsManager.webViewEnvironment != null
        ? 'Active'
        : profile != null
        ? 'Pending'
        : 'None';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Icon(Icons.memory, color: Colors.purple.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile != null
                      ? 'Profile: ${profile.name}'
                      : 'New Environment Configuration',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
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
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: envStatus == 'Active'
                            ? Colors.green.shade100
                            : envStatus == 'Pending'
                            ? Colors.orange.shade100
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Env: $envStatus',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: envStatus == 'Active'
                              ? Colors.green.shade800
                              : envStatus == 'Pending'
                              ? Colors.orange.shade800
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Chip(
            label: Text(
              _currentPlatform?.displayName.toUpperCase() ?? 'UNKNOWN',
            ),
            backgroundColor: Colors.purple.shade100,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade800,
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
          hintText: 'Search environment settings...',
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
    List<EnvironmentSettingDefinition> settings,
    SettingsManager settingsManager,
  ) {
    // Filter settings based on search query only (show all platforms)
    final filteredSettings = settings.where((setting) {
      // Filter by search query
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
        key: ValueKey('$category-$isExpanded'),
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

  bool _isSettingSupportedOnCurrentPlatform(
    EnvironmentSettingDefinition setting,
  ) {
    final platform = _currentPlatform;
    if (platform == null) return false;

    if (setting.supportedPlatforms.isEmpty) return true;
    return setting.supportedPlatforms.contains(platform);
  }

  Widget _buildSettingTile(
    EnvironmentSettingDefinition setting,
    SettingsManager settingsManager,
  ) {
    final isModified = _modifiedKeys.contains(setting.key);
    final currentValue = _localSettings[setting.key] ?? setting.defaultValue;
    final isCurrentPlatformSupported = _isSettingSupportedOnCurrentPlatform(
      setting,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isModified
            ? Colors.orange.shade50
            : (!isCurrentPlatformSupported ? Colors.grey.shade50 : null),
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
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isCurrentPlatformSupported
                                  ? Colors.black87
                                  : Colors.grey.shade500,
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
                        if (setting.supportedPlatforms.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          ...setting.supportedPlatforms.map((p) {
                            final isSupported = _currentPlatform == p;
                            return Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: _getPlatformColor(
                                  p,
                                ).withOpacity(isSupported ? 0.3 : 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: _getPlatformColor(
                                    p,
                                  ).withOpacity(isSupported ? 0.6 : 0.2),
                                ),
                              ),
                              child: Text(
                                p.displayName,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: isSupported
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _getPlatformColor(
                                    p,
                                  ).withOpacity(isSupported ? 1.0 : 0.5),
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      setting.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isCurrentPlatformSupported
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              if (isModified)
                IconButton(
                  icon: const Icon(Icons.restore, size: 20),
                  tooltip: 'Reset to default',
                  onPressed: () => _resetSetting(setting.key),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Opacity(
            opacity: isCurrentPlatformSupported ? 1.0 : 0.5,
            child: IgnorePointer(
              ignoring: !isCurrentPlatformSupported,
              child: _buildSettingControl(setting, currentValue),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPlatformColor(SupportedPlatform platform) {
    switch (platform) {
      case SupportedPlatform.windows:
        return Colors.blue;
      case SupportedPlatform.linux:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSettingControl(
    EnvironmentSettingDefinition setting,
    dynamic currentValue,
  ) {
    switch (setting.type) {
      case EnvironmentSettingType.boolean:
        return Switch(
          value: currentValue ?? setting.defaultValue ?? false,
          onChanged: (value) => _updateSetting(setting.key, value),
        );

      case EnvironmentSettingType.string:
        return SizedBox(
          width: double.infinity,
          child: TextField(
            controller: TextEditingController(
              text: currentValue?.toString() ?? '',
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              border: const OutlineInputBorder(),
              hintText: setting.hint ?? 'Enter value...',
            ),
            style: const TextStyle(fontSize: 14),
            onChanged: (value) =>
                _updateSetting(setting.key, value.isEmpty ? null : value),
          ),
        );

      case EnvironmentSettingType.stringList:
        return _buildStringListControl(setting, currentValue);

      case EnvironmentSettingType.enumeration:
        if (setting.enumValues == null) {
          return const SizedBox.shrink();
        }
        return DropdownButton<dynamic>(
          value: currentValue,
          isExpanded: true,
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
          onChanged: (value) => _updateSetting(setting.key, value),
        );

      case EnvironmentSettingType.customSchemeRegistrations:
        return _buildCustomSchemeRegistrationsControl(setting, currentValue);
    }
  }

  Widget _buildStringListControl(
    EnvironmentSettingDefinition setting,
    dynamic currentValue,
  ) {
    final List<String> items = currentValue != null
        ? List<String>.from(currentValue as List)
        : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ...items.map((item) {
              return Chip(
                label: Text(item, style: const TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  final newItems = List<String>.from(items)..remove(item);
                  _updateSetting(
                    setting.key,
                    newItems.isEmpty ? null : newItems,
                  );
                },
              );
            }),
            ActionChip(
              avatar: const Icon(Icons.add, size: 16),
              label: const Text('Add', style: TextStyle(fontSize: 12)),
              onPressed: () => _showAddStringItemDialog(setting, items),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddStringItemDialog(
    EnvironmentSettingDefinition setting,
    List<String> currentItems,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${setting.name}'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Value',
            hintText: setting.hint ?? 'Enter value...',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                final newItems = List<String>.from(currentItems)..add(value);
                _updateSetting(setting.key, newItems);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomSchemeRegistrationsControl(
    EnvironmentSettingDefinition setting,
    dynamic currentValue,
  ) {
    // For now, show as JSON editable text
    final List<Map<String, dynamic>> items = currentValue != null
        ? List<Map<String, dynamic>>.from(
            (currentValue as List).map((e) => Map<String, dynamic>.from(e)),
          )
        : <Map<String, dynamic>>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isEmpty)
          Text(
            'No custom schemes registered',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          )
        else
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final scheme = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                dense: true,
                title: Text(
                  scheme['scheme']?.toString() ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Fetch: ${scheme['treatAsSecure'] ?? false}',
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () {
                    final newItems = List<Map<String, dynamic>>.from(items)
                      ..removeAt(index);
                    _updateSetting(
                      setting.key,
                      newItems.isEmpty ? null : newItems,
                    );
                  },
                ),
              ),
            );
          }),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Custom Scheme'),
          onPressed: () => _showAddCustomSchemeDialog(items),
        ),
      ],
    );
  }

  void _showAddCustomSchemeDialog(List<Map<String, dynamic>> currentItems) {
    final schemeController = TextEditingController();
    bool treatAsSecure = false;
    bool hasAccess = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Custom Scheme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: schemeController,
                decoration: const InputDecoration(
                  labelText: 'Scheme Name',
                  hintText: 'e.g., myapp',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Treat as Secure'),
                subtitle: const Text('Allow secure context features'),
                value: treatAsSecure,
                onChanged: (value) =>
                    setDialogState(() => treatAsSecure = value),
              ),
              SwitchListTile(
                title: const Text('Has Access'),
                subtitle: const Text('Allow access to other schemes'),
                value: hasAccess,
                onChanged: (value) => setDialogState(() => hasAccess = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final scheme = schemeController.text.trim();
                if (scheme.isNotEmpty) {
                  final newItems = List<Map<String, dynamic>>.from(currentItems)
                    ..add({
                      'scheme': scheme,
                      'treatAsSecure': treatAsSecure,
                      'hasAccess': hasAccess,
                    });
                  _updateSetting('customSchemeRegistrations', newItems);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateSetting(String key, dynamic value) {
    setState(() {
      if (value == null) {
        _localSettings.remove(key);
      } else {
        _localSettings[key] = value;
      }
      _modifiedKeys.add(key);
    });
  }

  void _resetSetting(String key) {
    setState(() {
      _localSettings.remove(key);
      _modifiedKeys.remove(key);
    });
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
          const SizedBox(width: 8),
          if (settingsManager.webViewEnvironment != null)
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Recreate Env'),
              onPressed: () async {
                await settingsManager.recreateEnvironment();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$WebViewEnvironment recreated'),
                    ),
                  );
                }
              },
            ),
          const Spacer(),
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Apply & Create'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _applySettings(settingsManager),
          ),
        ],
      ),
    );
  }

  Future<void> _applySettings(SettingsManager settingsManager) async {
    // Save to current environment profile or create new
    if (settingsManager.currentEnvironmentProfile != null) {
      await settingsManager.updateEnvironmentProfile(
        settingsManager.currentEnvironmentProfileId!,
        settings: Map<String, dynamic>.from(_localSettings),
      );
    } else {
      // Just update internal state and recreate
      for (final entry in _localSettings.entries) {
        settingsManager.currentEnvironmentSettings[entry.key] = entry.value;
      }
      await settingsManager.recreateEnvironment();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Environment settings applied')),
      );
    }
  }

  void _handleMenuAction(String action) {
    final settingsManager = context.read<SettingsManager>();

    switch (action) {
      case 'reset':
        _showResetConfirmDialog(settingsManager);
        break;
      case 'clear_selection':
        _clearEnvironmentSelection(settingsManager);
        break;
      case 'expand_all':
        setState(() {
          _expandedCategories = getEnvironmentSettingDefinitions().keys.toSet();
        });
        break;
      case 'collapse_all':
        setState(() {
          _expandedCategories.clear();
        });
        break;
    }
  }

  Future<void> _clearEnvironmentSelection(
    SettingsManager settingsManager,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Environment'),
        content: Text(
          'This will dispose the current $WebViewEnvironment and clear the selection. '
          'Any WebViews using this environment will need to be recreated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await settingsManager.clearEnvironmentSelection();
      _loadCurrentSettings();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Environment cleared')));
      }
    }
  }

  void _showSaveProfileDialog() {
    final settingsManager = context.read<SettingsManager>();
    final currentProfile = settingsManager.currentEnvironmentProfile;
    _profileNameController.text = currentProfile?.name ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Environment Profile'),
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
              'This will save ${_modifiedKeys.length} modified settings.',
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
                // Update internal settings first
                for (final entry in _localSettings.entries) {
                  settingsManager.currentEnvironmentSettings[entry.key] =
                      entry.value;
                }
                await settingsManager.saveCurrentEnvironmentSettings(name);
                _modifiedKeys.clear();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(this.context).showSnackBar(
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

    if (settingsManager.environmentProfiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved environment profiles found')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final profiles = settingsManager.environmentProfiles;

          if (profiles.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pop(dialogContext);
            });
            return const SizedBox.shrink();
          }

          return AlertDialog(
            title: const Text('Load Environment Profile'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  final isCurrentProfile =
                      profile.id == settingsManager.currentEnvironmentProfileId;

                  return ListTile(
                    title: Text(profile.name),
                    subtitle: Text(
                      '${profile.settings.length} settings • Created ${_formatDate(profile.createdAt)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    leading: Icon(
                      isCurrentProfile ? Icons.check_circle : Icons.memory,
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
                      await settingsManager.loadEnvironmentProfile(profile.id);
                      _loadCurrentSettings();
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
    WebViewEnvironmentProfile profile, {
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
              await context.read<SettingsManager>().deleteEnvironmentProfile(
                profile.id,
              );
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
          'Are you sure you want to reset all environment settings to their default values?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _loadCurrentSettings();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: const Text('Reset'),
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

  /// Get all environment setting definitions organized by category
  static Map<String, List<EnvironmentSettingDefinition>>
  getEnvironmentSettingDefinitions() {
    return {
      'General': [
        EnvironmentSettingDefinition(
          key: 'browserExecutableFolder',
          name: 'Browser Executable Folder',
          description:
              'Path to the folder containing the WebView2 browser executable',
          type: EnvironmentSettingType.string,
          hint: 'C:\\Program Files (x86)\\Microsoft\\Edge WebView2\\...',
          supportedPlatforms: [SupportedPlatform.windows],
        ),
        EnvironmentSettingDefinition(
          key: 'userDataFolder',
          name: 'User Data Folder',
          description: 'Path to the user data folder for WebView2 profile',
          type: EnvironmentSettingType.string,
          hint: 'C:\\Users\\...\\AppData\\Local\\...',
          supportedPlatforms: [SupportedPlatform.windows],
        ),
        EnvironmentSettingDefinition(
          key: 'additionalBrowserArguments',
          name: 'Additional Browser Arguments',
          description: 'Additional command line arguments for the browser',
          type: EnvironmentSettingType.string,
          hint: '--disable-gpu --enable-logging',
          supportedPlatforms: [SupportedPlatform.windows],
        ),
        EnvironmentSettingDefinition(
          key: 'targetCompatibleBrowserVersion',
          name: 'Target Compatible Browser Version',
          description: 'Minimum WebView2 version required',
          type: EnvironmentSettingType.string,
          hint: '100.0.0.0',
          supportedPlatforms: [SupportedPlatform.windows],
        ),
      ],
      'Release Channel': [
        EnvironmentSettingDefinition(
          key: 'channelSearchKind',
          name: 'Channel Search Kind',
          description: 'How to search for WebView2 runtime',
          type: EnvironmentSettingType.enumeration,
          // Use hardcoded values to avoid accessing platform-specific enum values at build time
          // EnvironmentChannelSearchKind: MOST_STABLE = 0, LEAST_STABLE = 1
          enumValues: const {'Most Stable': 0, 'Least Stable': 1},
          supportedPlatforms: [SupportedPlatform.windows],
        ),
        EnvironmentSettingDefinition(
          key: 'releaseChannels',
          name: 'Release Channels',
          description: 'Which release channels to consider',
          type: EnvironmentSettingType.enumeration,
          // Use hardcoded values to avoid accessing platform-specific enum values at build time
          // EnvironmentReleaseChannels: STABLE = 1, BETA = 2, DEV = 4, CANARY = 8
          enumValues: const {'Stable': 1, 'Beta': 2, 'Dev': 4, 'Canary': 8},
          supportedPlatforms: [SupportedPlatform.windows],
        ),
      ],
      'Localization': [
        EnvironmentSettingDefinition(
          key: 'language',
          name: 'Language',
          description: 'Default language for the WebView',
          type: EnvironmentSettingType.string,
          hint: 'en-US',
          supportedPlatforms: [SupportedPlatform.windows],
        ),
        EnvironmentSettingDefinition(
          key: 'preferredLanguages',
          name: 'Preferred Languages',
          description: 'List of preferred languages',
          type: EnvironmentSettingType.stringList,
          hint: 'en-US, fr-FR, de-DE',
          supportedPlatforms: [SupportedPlatform.linux],
        ),
        EnvironmentSettingDefinition(
          key: 'timeZoneOverride',
          name: 'Time Zone Override',
          description: 'Override the default time zone',
          type: EnvironmentSettingType.string,
          hint: 'America/New_York',
          supportedPlatforms: [SupportedPlatform.windows],
        ),
      ],
      'Spellcheck': [
        EnvironmentSettingDefinition(
          key: 'spellCheckingEnabled',
          name: 'Spell Checking Enabled',
          description: 'Enable spell checking',
          type: EnvironmentSettingType.boolean,
          defaultValue: false,
          supportedPlatforms: [SupportedPlatform.linux],
        ),
        EnvironmentSettingDefinition(
          key: 'spellCheckingLanguages',
          name: 'Spell Checking Languages',
          description: 'Languages for spell checking',
          type: EnvironmentSettingType.stringList,
          hint: 'en_US, fr_FR',
          supportedPlatforms: [SupportedPlatform.linux],
        ),
      ],
      'Extensions': [
        EnvironmentSettingDefinition(
          key: 'areBrowserExtensionsEnabled',
          name: 'Browser Extensions Enabled',
          description: 'Enable browser extensions support',
          type: EnvironmentSettingType.boolean,
          defaultValue: false,
          supportedPlatforms: [SupportedPlatform.windows],
        ),
        EnvironmentSettingDefinition(
          key: 'webProcessExtensionsDirectory',
          name: 'Web Process Extensions Directory',
          description: 'Path to web process extensions',
          type: EnvironmentSettingType.string,
          hint: '/path/to/extensions',
          supportedPlatforms: [SupportedPlatform.linux],
        ),
      ],
      'Security & Privacy': [
        EnvironmentSettingDefinition(
          key: 'allowSingleSignOnUsingOSPrimaryAccount',
          name: 'Allow SSO with OS Account',
          description:
              'Allow single sign-on using the OS primary account (AAD)',
          type: EnvironmentSettingType.boolean,
          defaultValue: false,
          supportedPlatforms: [SupportedPlatform.windows],
        ),
        EnvironmentSettingDefinition(
          key: 'enableTrackingPrevention',
          name: 'Enable Tracking Prevention',
          description: 'Enable tracking prevention features',
          type: EnvironmentSettingType.boolean,
          defaultValue: true,
          supportedPlatforms: [SupportedPlatform.windows],
        ),
        EnvironmentSettingDefinition(
          key: 'exclusiveUserDataFolderAccess',
          name: 'Exclusive User Data Folder Access',
          description: 'Ensure exclusive access to the user data folder',
          type: EnvironmentSettingType.boolean,
          defaultValue: false,
          supportedPlatforms: [SupportedPlatform.windows],
        ),
        EnvironmentSettingDefinition(
          key: 'sandboxPaths',
          name: 'Sandbox Paths',
          description: 'Paths for sandbox isolation',
          type: EnvironmentSettingType.stringList,
          hint: '/path/to/sandbox',
          supportedPlatforms: [SupportedPlatform.linux],
        ),
      ],
      'Automation & Debugging': [
        EnvironmentSettingDefinition(
          key: 'automationAllowed',
          name: 'Automation Allowed',
          description: 'Allow WebDriver automation',
          type: EnvironmentSettingType.boolean,
          defaultValue: false,
          supportedPlatforms: [SupportedPlatform.linux],
        ),
        EnvironmentSettingDefinition(
          key: 'isCustomCrashReportingEnabled',
          name: 'Custom Crash Reporting',
          description: 'Enable custom crash reporting',
          type: EnvironmentSettingType.boolean,
          defaultValue: false,
          supportedPlatforms: [SupportedPlatform.windows],
        ),
      ],
      'Appearance': [
        EnvironmentSettingDefinition(
          key: 'scrollbarStyle',
          name: 'Scrollbar Style',
          description: 'Style of scrollbars in the WebView',
          type: EnvironmentSettingType.enumeration,
          // Use hardcoded values to avoid accessing platform-specific enum values at build time
          // EnvironmentScrollbarStyle: DEFAULT = 0, FLUENT_OVERLAY = 1
          enumValues: const {'Default': 0, 'Fluent Overlay': 1},
          supportedPlatforms: [SupportedPlatform.windows],
        ),
      ],
      'Cache': [
        EnvironmentSettingDefinition(
          key: 'cacheModel',
          name: 'Cache Model',
          description: 'Caching strategy for the WebView',
          type: EnvironmentSettingType.enumeration,
          // Use hardcoded values to avoid accessing platform-specific enum values at build time
          // CacheModel: DOCUMENT_VIEWER = 0, DOCUMENT_BROWSER = 1, WEB_BROWSER = 2
          enumValues: const {
            'Document Viewer': 0,
            'Document Browser': 1,
            'Web Browser': 2,
          },
          supportedPlatforms: [SupportedPlatform.linux],
        ),
      ],
      'Custom Schemes': [
        EnvironmentSettingDefinition(
          key: 'customSchemeRegistrations',
          name: 'Custom Scheme Registrations',
          description: 'Register custom URL schemes',
          type: EnvironmentSettingType.customSchemeRegistrations,
          supportedPlatforms: [SupportedPlatform.windows],
        ),
      ],
    };
  }
}

/// Enum representing the type of an environment setting
enum EnvironmentSettingType {
  boolean,
  string,
  stringList,
  enumeration,
  customSchemeRegistrations,
}

/// Definition of a single environment setting
class EnvironmentSettingDefinition {
  final String key;
  final String name;
  final String description;
  final EnvironmentSettingType type;
  final dynamic defaultValue;
  final Map<String, dynamic>? enumValues;
  final String? hint;
  final List<SupportedPlatform> supportedPlatforms;

  const EnvironmentSettingDefinition({
    required this.key,
    required this.name,
    required this.description,
    required this.type,
    this.defaultValue,
    this.enumValues,
    this.hint,
    this.supportedPlatforms = const [],
  });
}
