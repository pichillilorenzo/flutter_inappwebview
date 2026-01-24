import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/providers/settings_manager.dart';
import 'package:flutter_inappwebview_example/models/environment_setting_definition.dart';
import 'package:flutter_inappwebview_example/models/webview_environment_profile.dart';
import 'package:flutter_inappwebview_example/utils/platform_utils.dart';
import 'package:flutter_inappwebview_example/utils/responsive_utils.dart';
import 'package:flutter_inappwebview_example/widgets/common/app_drawer.dart';
import 'package:flutter_inappwebview_example/widgets/settings/responsive_setting_tile.dart';
import 'package:flutter_inappwebview_example/widgets/common/support_badge.dart';

import '../utils/support_checker.dart';

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
      drawer: AppDrawer(),
      body: Consumer<SettingsManager>(
        builder: (context, settingsManager, child) {
          if (settingsManager.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final definitions =
              SettingsManager.getEnvironmentSettingDefinitions();

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
    final header = Row(
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
    );
    final subtitle = Text(
      '${filteredSettings.length} setting${filteredSettings.length == 1 ? '' : 's'}',
      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
    );

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
        title: header,
        subtitle: subtitle,
        children: filteredSettings.map((setting) {
          return _buildSettingTile(setting, settingsManager);
        }).toList(),
      ),
    );
  }

  Widget _buildSettingTile(
    EnvironmentSettingDefinition setting,
    SettingsManager settingsManager,
  ) {
    final isModified = _modifiedKeys.contains(setting.key);
    final currentValue = _localSettings[setting.key] ?? setting.defaultValue;
    final hasPlatformLimitations = setting.supportedPlatforms.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isModified ? Colors.orange.shade50 : null,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: ResponsiveSettingTile(
        title: Row(
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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Modified',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        description: Text(
          setting.description,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        badges: hasPlatformLimitations
            ? SupportBadgesRow(
                supportedPlatforms: setting.supportedPlatforms,
                compact: true,
              )
            : null,
        trailing: isModified
            ? IconButton(
                icon: const Icon(Icons.restore, size: 20),
                tooltip: 'Reset to default',
                onPressed: () => _resetSetting(setting.key),
              )
            : null,
        control: _buildSettingControl(setting, currentValue),
        inlineControl: setting.type == EnvironmentSettingType.boolean,
      ),
    );
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
        if (setting.enumValues == null || setting.enumValues!.isEmpty) {
          return const SizedBox.shrink();
        }
        if (_isBitmaskEnumSetting(setting)) {
          return _buildBitmaskEnumControl(setting, currentValue);
        }
        final selectedValue = _resolveEnumSelection(setting, currentValue);
        return DropdownButton<dynamic>(
          value: selectedValue,
          isExpanded: true,
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('Not Set', style: TextStyle(fontSize: 14)),
            ),
            ...setting.enumValues!.map((enumValue) {
              return DropdownMenuItem(
                value: enumValue,
                child: Text(
                  EnvironmentSettingDefinition.enumDisplayName(enumValue),
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }),
          ],
          onChanged: (value) => _updateSetting(
            setting.key,
            EnvironmentSettingDefinition.enumValueToNative(value),
          ),
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
          onPressed: () => _showAddCustomSchemeDialog(setting.key, items),
        ),
      ],
    );
  }

  void _showAddCustomSchemeDialog(
    String settingKey,
    List<Map<String, dynamic>> currentItems,
  ) {
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
                  _updateSetting(settingKey, newItems);
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

  bool _isBitmaskEnumSetting(EnvironmentSettingDefinition setting) {
    return setting.property ==
        WebViewEnvironmentSettingsProperty.releaseChannels;
  }

  int _resolveBitmaskValue(dynamic currentValue) {
    if (currentValue == null) return 0;
    if (currentValue is int) return currentValue;
    final nativeValue = EnvironmentSettingDefinition.enumValueToNative(
      currentValue,
    );
    return nativeValue is int ? nativeValue : 0;
  }

  dynamic _resolveEnumSelection(
    EnvironmentSettingDefinition setting,
    dynamic currentValue,
  ) {
    if (currentValue == null) return null;
    final enumValues = setting.enumValues;
    if (enumValues == null || enumValues.isEmpty) return null;

    if (enumValues.contains(currentValue)) {
      return currentValue;
    }

    for (final enumValue in enumValues) {
      final nativeValue = EnvironmentSettingDefinition.enumValueToNative(
        enumValue,
      );
      if (nativeValue == currentValue) {
        return enumValue;
      }
    }

    return null;
  }

  Widget _buildBitmaskEnumControl(
    EnvironmentSettingDefinition setting,
    dynamic currentValue,
  ) {
    final enumValues = setting.enumValues ?? <dynamic>[];
    if (enumValues.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentMask = _resolveBitmaskValue(currentValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: enumValues.map((enumValue) {
            final nativeValue = EnvironmentSettingDefinition.enumValueToNative(
              enumValue,
            );
            final maskValue = nativeValue is int ? nativeValue : 0;
            final isSelected =
                maskValue != 0 && (currentMask & maskValue) == maskValue;

            return FilterChip(
              label: Text(
                EnvironmentSettingDefinition.enumDisplayName(enumValue),
                style: const TextStyle(fontSize: 12),
              ),
              selected: isSelected,
              onSelected: (selected) {
                final updatedMask = selected
                    ? (currentMask | maskValue)
                    : (currentMask & ~maskValue);
                _updateSetting(
                  setting.key,
                  updatedMask == 0 ? null : updatedMask,
                );
              },
            );
          }).toList(),
        ),
        if (currentMask == 0)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'No release channels selected',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
      ],
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
    final isMobile = context.isMobile;
    final resetButton = OutlinedButton.icon(
      icon: const Icon(Icons.restore),
      label: const Text('Reset All'),
      onPressed: () => _showResetConfirmDialog(settingsManager),
    );
    final recreateButton = OutlinedButton.icon(
      icon: const Icon(Icons.refresh),
      label: const Text('Recreate Env'),
      onPressed: () async {
        await settingsManager.recreateEnvironment();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$WebViewEnvironment recreated')),
          );
        }
      },
    );
    final applyButton = ElevatedButton.icon(
      icon: const Icon(Icons.check),
      label: const Text('Apply & Create'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      onPressed: () => _applySettings(settingsManager),
    );

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
      child: isMobile
          ? Wrap(
              key: const ValueKey('settings_bottom_bar_actions'),
              spacing: 12,
              runSpacing: 8,
              children: [
                resetButton,
                if (settingsManager.webViewEnvironment != null) recreateButton,
                applyButton,
              ],
            )
          : Row(
              key: const ValueKey('settings_bottom_bar_actions'),
              children: [
                resetButton,
                const SizedBox(width: 8),
                if (settingsManager.webViewEnvironment != null) recreateButton,
                const Spacer(),
                applyButton,
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
          _expandedCategories =
              SettingsManager.getEnvironmentSettingDefinitions().keys.toSet();
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
}
