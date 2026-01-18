import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

import '../../providers/test_runner.dart';
import '../../utils/constants.dart';
import '../../main.dart';

/// Automated test runner screen
class TestRunnerScreen extends StatefulWidget {
  const TestRunnerScreen({super.key});

  @override
  State<TestRunnerScreen> createState() => _TestRunnerScreenState();
}

class _TestRunnerScreenState extends State<TestRunnerScreen> {
  InAppWebViewController? _webViewController;
  final Set<TestCategory> _selectedCategories = {};
  ResultFilter _resultFilter = ResultFilter.all;
  bool _webViewReady = false;

  @override
  void initState() {
    super.initState();
    // Select all categories by default
    _selectedCategories.addAll(TestCategory.values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Runner'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
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
              const PopupMenuItem(
                value: 'export_csv',
                child: ListTile(
                  leading: Icon(Icons.table_chart),
                  title: Text('Export as CSV'),
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
      drawer: buildDrawer(context: context),
      body: Column(
        children: [
          _buildCategorySelector(),
          _buildControlBar(),
          _buildProgressSection(),
          _buildFilterBar(),
          Expanded(
            child: Row(
              children: [
                // Hidden WebView for testing
                SizedBox(width: 1, height: 1, child: _buildHiddenWebView()),
                // Results list
                Expanded(child: _buildResultsList()),
              ],
            ),
          ),
          _buildSummaryBar(),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = TestRunner.getTestCategories();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Test Categories',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.select_all, size: 18),
                    label: const Text('All'),
                    onPressed: () {
                      setState(() {
                        _selectedCategories.clear();
                        _selectedCategories.addAll(TestCategory.values);
                      });
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.deselect, size: 18),
                    label: const Text('None'),
                    onPressed: () {
                      setState(() {
                        _selectedCategories.clear();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              final isSelected = _selectedCategories.contains(
                category.category,
              );
              return FilterChip(
                label: Text('${category.name} (${category.tests.length})'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCategories.add(category.category);
                    } else {
                      _selectedCategories.remove(category.category);
                    }
                  });
                },
                avatar: Icon(
                  _getCategoryIcon(category.category),
                  size: 18,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
                selectedColor: _getCategoryColor(category.category),
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    return Consumer<TestRunner>(
      builder: (context, runner, child) {
        final isRunning = runner.status == TestStatus.running;
        final hasFailed = runner.failed > 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              ElevatedButton.icon(
                icon: Icon(isRunning ? Icons.stop : Icons.play_arrow),
                label: Text(isRunning ? 'Stop' : 'Run Selected'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRunning ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: _selectedCategories.isEmpty && !isRunning
                    ? null
                    : () {
                        if (isRunning) {
                          runner.stopTests();
                        } else {
                          _runSelectedTests();
                        }
                      },
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Run All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: isRunning ? null : _runAllTests,
              ),
              const SizedBox(width: 8),
              if (hasFailed && !isRunning)
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Re-run Failed'),
                  onPressed: _rerunFailedTests,
                ),
              const Spacer(),
              if (!_webViewReady)
                const Chip(
                  avatar: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  label: Text('WebView loading...'),
                ),
              if (_webViewReady)
                const Chip(
                  avatar: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 18,
                  ),
                  label: Text('WebView ready'),
                ),
            ],
          ),
        );
      },
    );
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

  Widget _buildFilterBar() {
    return Consumer<TestRunner>(
      builder: (context, runner, child) {
        if (runner.results.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              const Text('Filter: '),
              const SizedBox(width: 8),
              SegmentedButton<ResultFilter>(
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
              ),
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

  Widget _buildHiddenWebView() {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri('https://flutter.dev')),
      initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
      onWebViewCreated: (controller) {
        _webViewController = controller;
      },
      onLoadStop: (controller, url) {
        if (!_webViewReady) {
          setState(() {
            _webViewReady = true;
          });
        }
      },
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

  void _runSelectedTests() {
    if (!_webViewReady) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('WebView is not ready yet')));
      return;
    }

    final runner = context.read<TestRunner>();
    runner.runSelectedCategories(
      _selectedCategories.toList(),
      _webViewController,
    );
  }

  void _runAllTests() {
    if (!_webViewReady) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('WebView is not ready yet')));
      return;
    }

    final runner = context.read<TestRunner>();
    runner.runAllTests(_webViewController);
  }

  void _rerunFailedTests() {
    if (!_webViewReady) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('WebView is not ready yet')));
      return;
    }

    final runner = context.read<TestRunner>();
    runner.rerunFailedTests(_webViewController);
  }

  void _handleMenuAction(String action) {
    final runner = context.read<TestRunner>();

    switch (action) {
      case 'export_json':
        _exportResults(runner.exportResultsAsJson(), 'test_results.json');
        break;
      case 'export_csv':
        _exportResults(runner.exportResultsAsCsv(), 'test_results.csv');
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

  IconData _getCategoryIcon(TestCategory category) {
    switch (category) {
      case TestCategory.navigation:
        return Icons.navigation;
      case TestCategory.javascript:
        return Icons.code;
      case TestCategory.content:
        return Icons.article;
      case TestCategory.storage:
        return Icons.storage;
      case TestCategory.advanced:
        return Icons.settings;
      case TestCategory.browsers:
        return Icons.web;
    }
  }

  Color _getCategoryColor(TestCategory category) {
    switch (category) {
      case TestCategory.navigation:
        return Colors.blue;
      case TestCategory.javascript:
        return Colors.amber.shade700;
      case TestCategory.content:
        return Colors.green;
      case TestCategory.storage:
        return Colors.purple;
      case TestCategory.advanced:
        return Colors.orange;
      case TestCategory.browsers:
        return Colors.teal;
    }
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
