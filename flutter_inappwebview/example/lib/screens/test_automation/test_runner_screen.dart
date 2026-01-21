import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/test_configuration.dart';
import '../../models/test_runner_models.dart';
import '../../providers/test_runner.dart';
import '../../widgets/common/app_drawer.dart';

/// Automated test runner screen
class TestRunnerScreen extends StatefulWidget {
  const TestRunnerScreen({super.key});

  @override
  State<TestRunnerScreen> createState() => _TestRunnerScreenState();
}

class _TestRunnerScreenState extends State<TestRunnerScreen> {
  static const String _lastConfigKey = 'test_runner_last_config';
  static const String _lastWebViewTypeKey = 'test_runner_last_webview_type';
  static const ValueKey<String> _panelLayoutKey = ValueKey('testRunnerPanels');
  static const ValueKey<String> _controlBarWrapKey = ValueKey(
    'testRunnerControlBarWrap',
  );

  ResultFilter _resultFilter = ResultFilter.all;

  // Custom configuration support
  TestConfiguration? _currentConfiguration;
  bool _configManagerInitialized = false;

  // Flag to prevent loading config multiple times
  bool _configLoaded = false;

  @override
  void initState() {
    super.initState();
    // Defer loading last configuration until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLastConfiguration();
    });
  }

  Future<void> _loadLastConfiguration() async {
    if (_configLoaded) return;
    _configLoaded = true;

    final prefs = await SharedPreferences.getInstance();
    final configManager = context.read<TestConfigurationManager>();
    if (!_configManagerInitialized) {
      await configManager.init();
      _configManagerInitialized = true;
    }
    final lastConfigJson = prefs.getString(_lastConfigKey);
    final lastWebViewType = prefs.getString(_lastWebViewTypeKey);

    final runner = context.read<TestRunner>();

    if (lastWebViewType != null) {
      final webViewType = TestWebViewType.values.firstWhere(
        (e) => e.name == lastWebViewType,
        orElse: () => TestWebViewType.inAppWebView,
      );
      runner.setWebViewType(webViewType);
    }

    TestConfiguration? configToLoad;

    // First choice: the last used configuration snapshot (represents what the user ran last)
    if (lastConfigJson != null && lastConfigJson.isNotEmpty) {
      try {
        final parsedConfig = TestConfiguration.fromJsonString(lastConfigJson);
        if (parsedConfig.id == 'default_config') {
          // Always rebuild the pre-built configuration from code
          configToLoad = TestConfiguration.defaultConfig();
        } else {
          configToLoad = parsedConfig;

          // Use a fresher saved version if it exists
          try {
            final freshConfig = configManager.savedConfigs.firstWhere(
              (c) => c.id == configToLoad!.id,
            );
            configToLoad = freshConfig;
          } catch (_) {
            // Not found in saved configs
          }
        }
      } catch (e) {
        debugPrint('Failed to parse last configuration: $e');
      }
    }

    // Always fall back to the pre-built default when no last snapshot is available
    configToLoad ??= TestConfiguration.defaultConfig();

    if (mounted) {
      setState(() {
        _currentConfiguration = configToLoad;
      });
      runner.setConfiguration(configToLoad);
      await _saveLastConfiguration();
    }
  }

  Future<void> _saveLastConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    final runner = context.read<TestRunner>();
    final config = _currentConfiguration;
    if (config == null || config.id == 'default_config') {
      await prefs.remove(_lastConfigKey);
    } else {
      await prefs.setString(_lastConfigKey, config.toJsonString());
    }
    await prefs.setString(_lastWebViewTypeKey, runner.webViewType.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Runner'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Load Configuration',
            onPressed: _showConfigurationDialog,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_json',
                child: ListTile(
                  leading: Icon(Icons.code),
                  title: Text('Export as JSON'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  leading: Icon(Icons.clear_all),
                  title: Text('Clear Results'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 600;
          return Consumer<TestRunner>(
            builder: (context, runner, child) {
              final panelChildren = <Widget>[
                if (runner.webViewType == TestWebViewType.inAppWebView)
                  Flexible(
                    key: const ValueKey('testRunnerWebViewPanel'),
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildVisibleWebView(runner),
                      ),
                    ),
                  ),
                Flexible(
                  key: const ValueKey('testRunnerResultsPanel'),
                  flex: runner.webViewType == TestWebViewType.inAppWebView
                      ? 1
                      : 2,
                  child: _buildResultsList(),
                ),
              ];

              return Column(
                children: [
                  _buildConfigurationBanner(),
                  _buildWebViewTypeSelector(isNarrow: isNarrow),
                  _buildControlBar(isNarrow: isNarrow),
                  _buildProgressSection(),
                  _buildFilterBar(isNarrow: isNarrow),
                  Expanded(
                    child: Flex(
                      key: _panelLayoutKey,
                      direction: isNarrow ? Axis.vertical : Axis.horizontal,
                      children: panelChildren,
                    ),
                  ),
                  _buildSummaryBar(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildConfigurationBanner() {
    final runner = context.read<TestRunner>();
    final config = _currentConfiguration ?? TestConfiguration.defaultConfig();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(bottom: BorderSide(color: Colors.blue.shade200)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuration: ${config.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${config.customSteps.length} test steps • '
                  '${config.webViewType == TestWebViewType.headless ? "Headless" : "Visible"} WebView',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reset'),
            onPressed: () {
              setState(() {
                _currentConfiguration = TestConfiguration.defaultConfig();
              });
              runner.setConfiguration(_currentConfiguration);
              runner.setInitialUrl(
                _currentConfiguration?.initialUrl ?? 'https://flutter.dev',
              );
              // Clear saved configuration
              _saveLastConfiguration();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWebViewTypeSelector({required bool isNarrow}) {
    return Consumer<TestRunner>(
      builder: (context, runner, child) {
        final selector = SegmentedButton<TestWebViewType>(
          segments: const [
            ButtonSegment(
              value: TestWebViewType.inAppWebView,
              label: Text('Visible'),
              icon: Icon(Icons.visibility, size: 18),
            ),
            ButtonSegment(
              value: TestWebViewType.headless,
              label: Text('Headless'),
              icon: Icon(Icons.visibility_off, size: 18),
            ),
          ],
          selected: {runner.webViewType},
          onSelectionChanged: (selection) {
            runner.setWebViewType(selection.first);
            _saveLastConfiguration();
          },
        );

        final helperText = runner.webViewType == TestWebViewType.inAppWebView
            ? Text(
                'Real-time rendering enabled',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade700,
                  fontStyle: FontStyle.italic,
                ),
              )
            : null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('WebView Mode: '),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: selector,
                          ),
                        ),
                      ],
                    ),
                    if (helperText != null) ...[
                      const SizedBox(height: 6),
                      helperText,
                    ],
                  ],
                )
              : Row(
                  children: [
                    const Text('WebView Mode: '),
                    const SizedBox(width: 8),
                    selector,
                    const Spacer(),
                    if (helperText != null) helperText,
                  ],
                ),
        );
      },
    );
  }

  Widget _buildVisibleWebView(TestRunner runner) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: Colors.grey.shade200,
          child: Row(
            children: [
              const Icon(Icons.web, size: 16),
              const SizedBox(width: 4),
              const Text('WebView Preview', style: TextStyle(fontSize: 12)),
              const Spacer(),
              if (runner.webViewReady)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Ready',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                )
              else
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
        Expanded(child: runner.buildInAppWebView()),
      ],
    );
  }

  void _showConfigurationDialog() {
    final configManager = context.read<TestConfigurationManager>();
    final savedConfigs = configManager.savedConfigs;
    final runner = context.read<TestRunner>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Load Test Configuration'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.playlist_add_check,
                    color: Colors.blue,
                  ),
                  title: const Text('Load Default Configuration'),
                  subtitle: const Text('Pre-built tests for common scenarios'),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _loadConfiguration(TestConfiguration.defaultConfig());
                  },
                ),
                const Divider(),
                // Show saved configurations if available
                if (savedConfigs.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Colors.orange.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Saved Configurations (${savedConfigs.length})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...savedConfigs.map(
                    (config) => ListTile(
                      leading: const Icon(
                        Icons.description,
                        color: Colors.orange,
                      ),
                      title: Text(config.name),
                      subtitle: Text(
                        '${config.customSteps.length} steps • ${config.webViewType == TestWebViewType.headless ? "Headless" : "Visible"} WebView',
                      ),
                      onTap: () {
                        Navigator.pop(dialogContext);
                        _loadConfiguration(config);
                      },
                    ),
                  ),
                  const Divider(),
                ],
                ListTile(
                  leading: const Icon(Icons.paste, color: Colors.green),
                  title: const Text('Import from Clipboard'),
                  subtitle: const Text('Paste JSON configuration'),
                  onTap: () async {
                    Navigator.pop(dialogContext);
                    await _importFromClipboard();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.restore, color: Colors.grey),
                  title: const Text('Reset to Default'),
                  subtitle: const Text('Load default test configuration'),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    setState(() {
                      _currentConfiguration = TestConfiguration.defaultConfig();
                    });
                    runner.setConfiguration(_currentConfiguration);
                    runner.setInitialUrl(
                      _currentConfiguration?.initialUrl ??
                          'https://flutter.dev',
                    );
                    // Save configuration
                    _saveLastConfiguration();
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _loadConfiguration(TestConfiguration config) {
    final runner = context.read<TestRunner>();
    final effectiveConfig = config.id == 'default_config'
        ? TestConfiguration.defaultConfig()
        : config;
    setState(() {
      _currentConfiguration = effectiveConfig;
    });
    runner.setConfiguration(effectiveConfig);
    // Save as last configuration
    _saveLastConfiguration();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Configuration loaded: ${effectiveConfig.name} (${effectiveConfig.customSteps.length} test steps)',
        ),
      ),
    );
  }

  Future<void> _importFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text;
      if (text != null && text.isNotEmpty) {
        final config = TestConfiguration.fromJsonString(text);
        _loadConfiguration(config);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Clipboard is empty')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildControlBar({required bool isNarrow}) {
    return Consumer<TestRunner>(
      builder: (context, runner, child) {
        final isRunning = runner.status == TestStatus.running;
        final hasFailed = runner.failed > 0;
        final config =
            _currentConfiguration ?? TestConfiguration.defaultConfig();
        final statusChip = _buildWebViewStatusChip(runner);

        final actions = Wrap(
          key: _controlBarWrapKey,
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(isRunning ? Icons.stop : Icons.play_arrow),
              label: Text(
                isRunning ? 'Stop' : 'Run Tests (${config.customSteps.length})',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isRunning ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: isRunning
                  ? () => runner.stopTests()
                  : () => _runSelectedTests(),
            ),
            if (hasFailed && !isRunning)
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Re-run Failed'),
                onPressed: _rerunFailedTests,
              ),
          ],
        );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Expanded(child: actions),
              if (statusChip != null) ...[
                const SizedBox(width: 12),
                statusChip,
              ],
            ],
          ),
        );
      },
    );
  }

  Widget? _buildWebViewStatusChip(TestRunner runner) {
    if (!runner.webViewReady &&
        runner.webViewType == TestWebViewType.inAppWebView) {
      return const Chip(
        avatar: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: Text('WebView loading...'),
      );
    }

    if (runner.webViewReady || runner.webViewType == TestWebViewType.headless) {
      return Chip(
        avatar: Icon(
          runner.webViewType == TestWebViewType.headless
              ? Icons.visibility_off
              : Icons.check_circle,
          color: Colors.green,
          size: 18,
        ),
        label: Text(
          runner.webViewType == TestWebViewType.headless
              ? 'Headless mode'
              : 'WebView ready',
        ),
      );
    }

    return null;
  }

  Widget _buildProgressSection() {
    return Consumer<TestRunner>(
      builder: (context, runner, child) {
        if (runner.status != TestStatus.running) {
          return const SizedBox.shrink();
        }

        final progress = runner.total > 0
            ? runner.progress / runner.total
            : 0.0;

        return Container(
          padding: const EdgeInsets.all(12),
          color: Colors.blue.shade50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Running: ${runner.currentTest ?? "..."}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${runner.progress}/${runner.total}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.blue.shade100,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterBar({required bool isNarrow}) {
    return Consumer<TestRunner>(
      builder: (context, runner, child) {
        if (runner.results.isEmpty) {
          return const SizedBox.shrink();
        }

        final filterButtons = SegmentedButton<ResultFilter>(
          segments: [
            ButtonSegment(
              value: ResultFilter.all,
              label: Text('All (${runner.results.length})'),
            ),
            ButtonSegment(
              value: ResultFilter.passed,
              label: Text('Passed (${runner.passed})'),
              icon: const Icon(Icons.check_circle, size: 16),
            ),
            ButtonSegment(
              value: ResultFilter.failed,
              label: Text('Failed (${runner.failed})'),
              icon: const Icon(Icons.cancel, size: 16),
            ),
            ButtonSegment(
              value: ResultFilter.skipped,
              label: Text('Skipped (${runner.skipped})'),
              icon: const Icon(Icons.skip_next, size: 16),
            ),
          ],
          selected: {_resultFilter},
          onSelectionChanged: (selection) {
            setState(() {
              _resultFilter = selection.first;
            });
          },
        );

        final filterContent = isNarrow
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: filterButtons,
              )
            : filterButtons;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [Text('Filter: '), SizedBox(width: 8)]),
                    const SizedBox(height: 8),
                    filterContent,
                  ],
                )
              : Row(
                  children: [
                    const Text('Filter: '),
                    const SizedBox(width: 8),
                    Flexible(child: filterContent),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildResultsList() {
    return Consumer<TestRunner>(
      builder: (context, runner, child) {
        if (runner.results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.science_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No test results yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select categories and click Run to start testing',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        final filteredResults = _filterResults(runner.results);

        return ListView.builder(
          itemCount: filteredResults.length,
          itemBuilder: (context, index) {
            final result = filteredResults[index];
            return _buildResultTile(result);
          },
        );
      },
    );
  }

  Widget _buildResultTile(ExtendedTestResult result) {
    final icon = result.skipped
        ? Icons.skip_next
        : result.success
        ? Icons.check_circle
        : Icons.cancel;
    final color = result.skipped
        ? Colors.grey
        : result.success
        ? Colors.green
        : Colors.red;

    return ExpansionTile(
      leading: Icon(icon, color: color),
      title: Text(
        result.testTitle,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: result.skipped ? Colors.grey : null,
        ),
      ),
      subtitle: Text(
        '${result.category.name} • ${result.duration.inMilliseconds}ms',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          result.skipped
              ? 'SKIPPED'
              : result.success
              ? 'PASSED'
              : 'FAILED',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Test ID: ${result.testId}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                'Message: ${result.message}',
                style: const TextStyle(fontSize: 14),
              ),
              if (result.skipReason != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Skip Reason: ${result.skipReason}',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                ),
              ],
              if (result.data != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Data: ${result.data}',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                'Timestamp: ${result.timestamp.toIso8601String()}',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryBar() {
    return Consumer<TestRunner>(
      builder: (context, runner, child) {
        if (runner.results.isEmpty && runner.status == TestStatus.idle) {
          return const SizedBox.shrink();
        }

        final statusColor = runner.status == TestStatus.completed
            ? (runner.failed == 0 ? Colors.green : Colors.orange)
            : runner.status == TestStatus.running
            ? Colors.blue
            : Colors.grey;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            border: Border(
              top: BorderSide(color: statusColor.withOpacity(0.3)),
            ),
          ),
          child: Row(
            children: [
              Icon(
                runner.status == TestStatus.completed
                    ? (runner.failed == 0 ? Icons.check_circle : Icons.warning)
                    : runner.status == TestStatus.running
                    ? Icons.hourglass_empty
                    : Icons.info,
                color: statusColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusText(runner),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    if (runner.results.isNotEmpty)
                      Text(
                        'Success Rate: ${runner.successRate.toStringAsFixed(1)}% • '
                        'Elapsed: ${_formatDuration(runner.elapsedTime)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              _buildStatChip('Passed', runner.passed, Colors.green),
              const SizedBox(width: 8),
              _buildStatChip('Failed', runner.failed, Colors.red),
              const SizedBox(width: 8),
              _buildStatChip('Skipped', runner.skipped, Colors.grey),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  List<ExtendedTestResult> _filterResults(List<ExtendedTestResult> results) {
    switch (_resultFilter) {
      case ResultFilter.passed:
        return results.where((r) => r.success && !r.skipped).toList();
      case ResultFilter.failed:
        return results.where((r) => !r.success && !r.skipped).toList();
      case ResultFilter.skipped:
        return results.where((r) => r.skipped).toList();
      case ResultFilter.all:
        return results;
    }
  }

  /// Waits for the WebView to be ready (for visible mode) or initializes headless WebView
  Future<void> _ensureWebViewReady() async {
    final runner = context.read<TestRunner>();
    final config = _currentConfiguration ?? TestConfiguration.defaultConfig();

    if (runner.webViewType == TestWebViewType.headless) {
      // For headless mode, initialize the headless WebView
      await runner.initializeHeadlessWebView(
        initialUrl: config.initialUrl ?? 'https://flutter.dev',
        width: config.headlessWidth,
        height: config.headlessHeight,
      );
    } else {
      // For visible mode, recreate the WebView and wait for it to be ready
      runner.recreateWebView();

      // Wait for the WebView to be ready
      int attempts = 0;
      while (!runner.webViewReady && attempts < 100) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      if (!runner.webViewReady) {
        throw Exception('WebView failed to initialize within timeout');
      }
    }
  }

  void _runSelectedTests() async {
    final runner = context.read<TestRunner>();
    final config = _currentConfiguration ?? TestConfiguration.defaultConfig();

    try {
      await _ensureWebViewReady();
      await runner.runConfigurationWithCurrentWebView(config);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to run tests: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _rerunFailedTests() async {
    final runner = context.read<TestRunner>();

    try {
      await _ensureWebViewReady();
      await runner.rerunFailedTests();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to re-run tests: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleMenuAction(String action) {
    final runner = context.read<TestRunner>();

    switch (action) {
      case 'export_json':
        _exportResults(runner.exportResultsAsJson(), 'test_results.json');
        break;
      case 'clear':
        runner.clearResults();
        break;
    }
  }

  void _exportResults(String content, String filename) {
    // Copy to clipboard for now
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Results copied to clipboard ($filename)'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  String _getStatusText(TestRunner runner) {
    switch (runner.status) {
      case TestStatus.idle:
        return 'Ready to run tests';
      case TestStatus.running:
        return 'Running tests...';
      case TestStatus.paused:
        return 'Tests paused';
      case TestStatus.completed:
        return runner.failed == 0
            ? 'All tests passed!'
            : '${runner.failed} test(s) failed';
      case TestStatus.error:
        return 'Error occurred';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else if (duration.inMinutes < 60) {
      final secs = duration.inSeconds % 60;
      return '${duration.inMinutes}m ${secs}s';
    } else {
      final mins = duration.inMinutes % 60;
      return '${duration.inHours}h ${mins}m';
    }
  }
}

enum ResultFilter { all, passed, failed, skipped }
