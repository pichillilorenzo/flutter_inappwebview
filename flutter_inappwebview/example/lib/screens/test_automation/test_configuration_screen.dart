import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../models/test_configuration.dart';
import '../../utils/constants.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/test_automation/custom_test_step_dialog.dart';

/// Screen for managing test configurations, custom steps, and test ordering
class TestConfigurationScreen extends StatefulWidget {
  const TestConfigurationScreen({super.key});

  @override
  State<TestConfigurationScreen> createState() =>
      _TestConfigurationScreenState();
}

class _TestConfigurationScreenState extends State<TestConfigurationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _importController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _importController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        return Consumer<TestConfigurationManager>(
          builder: (context, manager, child) => Scaffold(
            appBar: AppBar(
              title: const Text('Test Configuration'),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                isScrollable: isNarrow,
                tabs: const [
                  Tab(icon: Icon(Icons.edit_note), text: 'Custom Steps'),
                  Tab(icon: Icon(Icons.settings), text: 'Settings'),
                  Tab(icon: Icon(Icons.import_export), text: 'Import/Export'),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  tooltip: 'Save Configuration',
                  onPressed: () => _saveConfiguration(context, manager),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (action) =>
                      _handleMenuAction(context, action, manager),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'new',
                      child: ListTile(
                        leading: Icon(Icons.add),
                        title: Text('New Configuration'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'load',
                      child: ListTile(
                        leading: Icon(Icons.folder_open),
                        title: Text('Load Configuration'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'reset',
                      child: ListTile(
                        leading: Icon(Icons.restart_alt, color: Colors.orange),
                        title: Text('Reset to Default'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            drawer: AppDrawer(),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildCustomStepsTab(manager),
                _buildSettingsTab(manager),
                _buildImportExportTab(manager),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomStepsTab(TestConfigurationManager manager) {
    final allSteps = manager.currentConfig.customSteps;
    final filteredSteps = _searchQuery.isEmpty
        ? allSteps
        : allSteps
              .where(
                (step) =>
                    step.name.toLowerCase().contains(_searchQuery) ||
                    step.description.toLowerCase().contains(_searchQuery),
              )
              .toList();

    return Column(
      children: [
        _buildConfigHeader(manager),
        _buildSearchBar(allSteps.length, filteredSteps.length),
        Expanded(
          child: filteredSteps.isEmpty
              ? _buildEmptyStepsMessage(
                  isFiltered: _searchQuery.isNotEmpty && allSteps.isNotEmpty,
                )
              : _buildStepsList(manager, filteredSteps, allSteps),
        ),
      ],
    );
  }

  Widget _buildSearchBar(int totalCount, int filteredCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search custom steps...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(width: 12),
            Text(
              '$filteredCount of $totalCount',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfigHeader(TestConfigurationManager manager) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(bottom: BorderSide(color: Colors.blue.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  manager.currentConfig.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (manager.currentConfig.description.isNotEmpty)
                  Text(
                    manager.currentConfig.description,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                Text(
                  '${manager.currentConfig.customSteps.length} custom step(s)',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Step'),
            onPressed: () => _showAddStepDialog(context, manager),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStepsMessage({bool isFiltered = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltered ? Icons.search_off : Icons.playlist_add,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? 'No Matching Steps' : 'No Custom Test Steps',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered
                ? 'Try a different search term'
                : 'Click "Add Step" to create your first custom test',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsList(
    TestConfigurationManager manager,
    List<CustomTestStep> filteredSteps,
    List<CustomTestStep> allSteps,
  ) {
    // When filtering, disable reordering to avoid index confusion
    final isFiltering = _searchQuery.isNotEmpty;

    if (isFiltering) {
      // Use regular ListView when filtering (no reordering)
      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: filteredSteps.length,
        itemBuilder: (context, index) {
          final step = filteredSteps[index];
          return _buildStepCard(
            context,
            manager,
            step,
            index,
            canReorder: false,
          );
        },
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(8),
      buildDefaultDragHandles: false,
      itemCount: filteredSteps.length,
      onReorder: (oldIndex, newIndex) {
        manager.reorderCustomSteps(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final step = filteredSteps[index];
        return _buildStepCard(context, manager, step, index, canReorder: true);
      },
    );
  }

  Widget _buildSettingsTab(TestConfigurationManager manager) {
    final config = manager.currentConfig;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // WebView Type Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.web, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'WebView Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how the WebView should be rendered during tests',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<TestWebViewType>(
                    title: Text('${InAppWebView} (Visible)'),
                    subtitle: const Text(
                      'Display WebView in real-time during test execution',
                    ),
                    value: TestWebViewType.inAppWebView,
                    groupValue: config.webViewType,
                    onChanged: (value) {
                      if (value != null) {
                        manager.setWebViewType(value);
                      }
                    },
                  ),
                  RadioListTile<TestWebViewType>(
                    title: const Text('Headless WebView'),
                    subtitle: const Text(
                      'Run tests in background without visible rendering',
                    ),
                    value: TestWebViewType.headless,
                    groupValue: config.webViewType,
                    onChanged: (value) {
                      if (value != null) {
                        manager.setWebViewType(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Initial URL
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.link, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Initial URL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'URL to load before running tests (optional)',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: TextEditingController(
                      text: config.initialUrl ?? '',
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Initial URL',
                      hintText: 'https://example.com',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      manager.setInitialUrl(value.isEmpty ? null : value);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Headless WebView Size (only shown when headless is selected)
          if (config.webViewType == TestWebViewType.headless)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.aspect_ratio, color: Colors.purple.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Headless WebView Size',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set the virtual viewport size for the headless WebView',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(
                              text: config.headlessWidth.toInt().toString(),
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Width (px)',
                              hintText: '1920',
                              border: OutlineInputBorder(),
                              suffixText: 'px',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final width = double.tryParse(value);
                              if (width != null && width > 0) {
                                manager.setHeadlessSize(
                                  width,
                                  config.headlessHeight,
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(
                              text: config.headlessHeight.toInt().toString(),
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Height (px)',
                              hintText: '1080',
                              border: OutlineInputBorder(),
                              suffixText: 'px',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final height = double.tryParse(value);
                              if (height != null && height > 0) {
                                manager.setHeadlessSize(
                                  config.headlessWidth,
                                  height,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Quick preset sizes
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSizePresetChip(
                          manager,
                          config,
                          'Mobile',
                          375,
                          667,
                        ),
                        _buildSizePresetChip(
                          manager,
                          config,
                          'Tablet',
                          768,
                          1024,
                        ),
                        _buildSizePresetChip(
                          manager,
                          config,
                          'Desktop',
                          1920,
                          1080,
                        ),
                        _buildSizePresetChip(manager, config, '4K', 3840, 2160),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (config.webViewType == TestWebViewType.headless)
            const SizedBox(height: 16),

          // Default Configuration
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.playlist_add_check,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Default Configuration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Load a pre-built configuration with common test scenarios including navigation, JavaScript execution, security checks, and more.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Load Default Configuration'),
                    onPressed: () => _loadDefaultConfig(manager),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizePresetChip(
    TestConfigurationManager manager,
    TestConfiguration config,
    String label,
    double width,
    double height,
  ) {
    final isSelected =
        config.headlessWidth == width && config.headlessHeight == height;
    return FilterChip(
      label: Text('$label (${width.toInt()}×${height.toInt()})'),
      selected: isSelected,
      onSelected: (_) {
        manager.setHeadlessSize(width, height);
      },
    );
  }

  void _loadDefaultConfig(TestConfigurationManager manager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Default Configuration?'),
        content: const Text(
          'This will replace your current configuration with the default test suite. '
          'Any unsaved changes will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final defaultConfig = TestConfiguration.defaultConfig();
              manager.importConfig(defaultConfig.toJsonString());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Default configuration loaded')),
              );
              _tabController.animateTo(0);
            },
            child: const Text('Load Default'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context,
    TestConfigurationManager manager,
    CustomTestStep step,
    int index, {
    bool canReorder = true,
  }) {
    return Card(
      key: ValueKey(step.id),
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            // Drag handle (only when reordering is enabled)
            if (canReorder)
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: Icon(
                      Icons.drag_handle,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.label, color: Colors.grey.shade400, size: 20),
              ),
            // Step content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      decoration: step.enabled
                          ? null
                          : TextDecoration.lineThrough,
                      color: step.enabled ? null : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.description.isNotEmpty
                        ? step.description
                        : 'No description',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildChip(step.category.name, Colors.blue),
                      _buildChip(
                        _getActionTypeName(step.action.type),
                        Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: step.enabled,
                    onChanged: (value) {
                      manager.updateCustomStep(
                        step.id,
                        step.copyWith(enabled: value),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  tooltip: 'Edit',
                  onPressed: () => _showEditStepDialog(context, manager, step),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.red.shade400,
                  ),
                  tooltip: 'Delete',
                  onPressed: () => _confirmDeleteStep(context, manager, step),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: color)),
    );
  }

  Widget _buildImportExportTab(TestConfigurationManager manager) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Export section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.upload, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Export Configuration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Export your current test configuration as JSON',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy to Clipboard'),
                        onPressed: () => _exportToClipboard(context, manager),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.visibility),
                        label: const Text('Preview JSON'),
                        onPressed: () => _showJsonPreview(context, manager),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Import section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.download, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Import Configuration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Paste JSON configuration to import',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _importController,
                    decoration: const InputDecoration(
                      labelText: 'Paste JSON here',
                      border: OutlineInputBorder(),
                      hintText: '{"id": "...", "name": "...", ...}',
                    ),
                    maxLines: 8,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.file_download),
                        label: const Text('Import'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _importConfig(context, manager),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.paste),
                        label: const Text('Paste from Clipboard'),
                        onPressed: () => _pasteFromClipboard(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sample configuration
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Sample Configuration',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click below to load a sample configuration with example custom tests.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => _loadSampleConfig(manager),
                    child: const Text('Load Sample'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStepDialog(
    BuildContext context,
    TestConfigurationManager manager,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          CustomTestStepDialog(onSave: (step) => manager.addCustomStep(step)),
    );
  }

  void _showEditStepDialog(
    BuildContext context,
    TestConfigurationManager manager,
    CustomTestStep step,
  ) {
    showDialog(
      context: context,
      builder: (context) => CustomTestStepDialog(
        existingStep: step,
        onSave: (updatedStep) => manager.updateCustomStep(step.id, updatedStep),
      ),
    );
  }

  void _confirmDeleteStep(
    BuildContext context,
    TestConfigurationManager manager,
    CustomTestStep step,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Test Step?'),
        content: Text('Are you sure you want to delete "${step.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              manager.removeCustomStep(step.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _saveConfiguration(
    BuildContext context,
    TestConfigurationManager manager,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final nameController = TextEditingController(
          text: manager.currentConfig.name,
        );
        return AlertDialog(
          title: const Text('Save Configuration'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Configuration Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                manager.saveCurrentConfig(name: nameController.text);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configuration saved')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String action,
    TestConfigurationManager manager,
  ) {
    switch (action) {
      case 'new':
        manager.resetConfig();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New configuration created')),
        );
        break;
      case 'load':
        _showLoadDialog(context, manager);
        break;
      case 'reset':
        _confirmReset(context, manager);
        break;
    }
  }

  void _showLoadDialog(BuildContext context, TestConfigurationManager manager) {
    if (manager.savedConfigs.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No saved configurations')));
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final configs = manager.savedConfigs;
          if (configs.isEmpty) {
            Navigator.pop(dialogContext);
            return const SizedBox.shrink();
          }
          return AlertDialog(
            title: const Text('Load Configuration'),
            content: SizedBox(
              width: 400,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: configs.length,
                itemBuilder: (context, index) {
                  final config = configs[index];
                  return ListTile(
                    title: Text(config.name),
                    subtitle: Text(
                      '${config.customSteps.length} steps • Modified: ${_formatDate(config.modifiedAt)}',
                    ),
                    onTap: () {
                      manager.loadConfig(config.id);
                      Navigator.pop(dialogContext);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () {
                        manager.deleteConfig(config.id);
                        setDialogState(
                          () {},
                        ); // Rebuild dialog to reflect deletion
                        if (manager.savedConfigs.isEmpty) {
                          Navigator.pop(dialogContext);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmReset(BuildContext context, TestConfigurationManager manager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Configuration?'),
        content: const Text(
          'This will clear all custom steps and reset to default settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              manager.resetConfig();
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _exportToClipboard(
    BuildContext context,
    TestConfigurationManager manager,
  ) {
    final json = manager.exportConfig();
    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration copied to clipboard')),
    );
  }

  void _showJsonPreview(
    BuildContext context,
    TestConfigurationManager manager,
  ) {
    final json = manager.exportConfig();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('JSON Preview'),
        content: SizedBox(
          width: 500,
          height: 400,
          child: SingleChildScrollView(
            child: SelectableText(
              json,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: json));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _importConfig(BuildContext context, TestConfigurationManager manager) {
    final json = _importController.text.trim();
    if (json.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste JSON configuration first')),
      );
      return;
    }

    try {
      manager.importConfig(json);
      _importController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuration imported successfully')),
      );
      _tabController.animateTo(0); // Switch to custom steps tab
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _importController.text = data!.text!;
    }
  }

  void _loadSampleConfig(TestConfigurationManager manager) {
    final sample = TestConfiguration(
      id: 'sample_config',
      name: 'Sample Test Configuration',
      description: 'A sample configuration with example custom tests',
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      customSteps: [
        CustomTestStep(
          id: 'sample_step_1',
          name: 'Check Page Title',
          description: 'Verify the page title contains expected text',
          category: TestCategory.content,
          action: CustomTestAction.evaluateJs('document.title'),
          expectedResult: 'Flutter',
          order: 0,
        ),
        CustomTestStep(
          id: 'sample_step_2',
          name: 'Wait for Element',
          description: 'Wait for the main content to load',
          category: TestCategory.content,
          action: CustomTestAction.waitForElement('body', timeoutMs: 5000),
          order: 1,
        ),
        CustomTestStep(
          id: 'sample_step_3',
          name: 'Check Element Exists',
          description: 'Verify a specific element is present',
          category: TestCategory.content,
          action: CustomTestAction.checkElement('a[href]'),
          order: 2,
        ),
        CustomTestStep(
          id: 'sample_step_4',
          name: 'Execute Custom JS',
          description: 'Run custom JavaScript and return result',
          category: TestCategory.javascript,
          action: CustomTestAction.evaluateJs(
            'document.querySelectorAll("a").length',
          ),
          order: 3,
        ),
      ],
    );

    manager.importConfig(sample.toJsonString());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sample configuration loaded')),
    );
    _tabController.animateTo(0);
  }

  String _getActionTypeName(CustomTestActionType type) {
    return type.name
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}')
        .trim();
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
