import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/benchmark_result.dart';
import '../../utils/platform_utils.dart';
import '../../main.dart';

/// Performance benchmarking screen
class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  InAppWebViewController? _webViewController;
  bool _webViewReady = false;
  bool _isRunning = false;
  String? _currentBenchmark;
  List<BenchmarkResult> _currentResults = [];
  List<BenchmarkSession> _historicalSessions = [];
  BenchmarkSession? _previousSession;

  static const String _storageKey = 'benchmark_sessions';
  static const int _iterations = 3; // Number of iterations for averaging

  @override
  void initState() {
    super.initState();
    _loadHistoricalSessions();
  }

  Future<void> _loadHistoricalSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList(_storageKey) ?? [];
      setState(() {
        _historicalSessions =
            sessionsJson.map((s) => BenchmarkSession.fromJsonString(s)).toList()
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        if (_historicalSessions.isNotEmpty) {
          _previousSession = _historicalSessions.first;
        }
      });
    } catch (e) {
      debugPrint('Failed to load historical sessions: $e');
    }
  }

  Future<void> _saveSession(BenchmarkSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _historicalSessions.insert(0, session);
      // Keep only last 10 sessions
      if (_historicalSessions.length > 10) {
        _historicalSessions = _historicalSessions.take(10).toList();
      }
      await prefs.setStringList(
        _storageKey,
        _historicalSessions.map((s) => s.toJsonString()).toList(),
      );
      _previousSession = session;
    } catch (e) {
      debugPrint('Failed to save session: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Benchmarks'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_historicalSessions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'History',
              onPressed: _showHistoryDialog,
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Export Results'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'clear_history',
                child: ListTile(
                  leading: Icon(Icons.delete_sweep),
                  title: Text('Clear History'),
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
          _buildInfoBar(),
          _buildControlBar(),
          if (_isRunning) _buildProgressSection(),
          Expanded(
            child: Row(
              children: [
                // Hidden WebView
                SizedBox(width: 1, height: 1, child: _buildHiddenWebView()),
                // Results
                Expanded(child: _buildResultsSection()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Benchmarks measure execution time of key WebView operations. '
              'Each test runs $_iterations times and results are averaged.',
              style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          ElevatedButton.icon(
            icon: Icon(_isRunning ? Icons.stop : Icons.speed),
            label: Text(_isRunning ? 'Stop' : 'Run Benchmarks'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isRunning ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: !_webViewReady
                ? null
                : _isRunning
                ? _stopBenchmarks
                : _runBenchmarks,
          ),
          const SizedBox(width: 12),
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
              avatar: Icon(Icons.check_circle, color: Colors.green, size: 18),
              label: Text('Ready'),
            ),
          const Spacer(),
          if (_previousSession != null)
            Chip(
              avatar: const Icon(Icons.history, size: 18),
              label: Text(
                'Previous: ${_formatDateTime(_previousSession!.timestamp)}',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.orange.shade50,
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Running: ${_currentBenchmark ?? "..."}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${_currentResults.length} of ${_getBenchmarkTests().length} completed',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_currentResults.isEmpty && !_isRunning) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currentResults.isNotEmpty) ...[
            _buildSummaryCard(),
            const SizedBox(height: 16),
            _buildResultsChart(),
            const SizedBox(height: 16),
            _buildResultsList(),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.speed, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No benchmark results yet',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Click "Run Benchmarks" to start performance testing',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final totalMs = _currentResults.fold<int>(
      0,
      (sum, r) => sum + r.duration.inMilliseconds,
    );
    final avgMs = _currentResults.isNotEmpty
        ? totalMs ~/ _currentResults.length
        : 0;
    final fastest = _currentResults.isNotEmpty
        ? _currentResults.reduce((a, b) => a.duration < b.duration ? a : b)
        : null;
    final slowest = _currentResults.isNotEmpty
        ? _currentResults.reduce((a, b) => a.duration > b.duration ? a : b)
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assessment, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Time',
                    '${totalMs}ms',
                    Icons.timer,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Average',
                    '${avgMs}ms',
                    Icons.trending_flat,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Fastest',
                    fastest != null
                        ? '${fastest.duration.inMilliseconds}ms'
                        : '-',
                    Icons.flash_on,
                    Colors.green,
                    subtitle: fastest?.testName,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Slowest',
                    slowest != null
                        ? '${slowest.duration.inMilliseconds}ms'
                        : '-',
                    Icons.hourglass_full,
                    Colors.red,
                    subtitle: slowest?.testName,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsChart() {
    if (_currentResults.isEmpty) return const SizedBox.shrink();

    final maxDuration = _currentResults
        .map((r) => r.duration.inMilliseconds)
        .reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Results Chart',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            ..._currentResults.map((result) {
              final percentage = maxDuration > 0
                  ? result.duration.inMilliseconds / maxDuration
                  : 0.0;
              final color = _getPerformanceColor(result.duration);
              final previousResult = _previousSession?.results
                  .where((r) => r.testName == result.testName)
                  .firstOrNull;
              final change = previousResult != null
                  ? ((result.duration.inMilliseconds -
                                previousResult.duration.inMilliseconds) /
                            previousResult.duration.inMilliseconds *
                            100)
                        .round()
                  : null;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            result.testName,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${result.duration.inMilliseconds}ms',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        if (change != null) ...[
                          const SizedBox(width: 8),
                          _buildChangeIndicator(change),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Stack(
                      children: [
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: percentage,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeIndicator(int change) {
    final isImproved = change < 0;
    final color = isImproved
        ? Colors.green
        : (change > 5 ? Colors.red : Colors.grey);
    final icon = isImproved
        ? Icons.arrow_downward
        : (change > 0 ? Icons.arrow_upward : Icons.remove);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          Text(
            '${change.abs()}%',
            style: TextStyle(fontSize: 10, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.list, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Detailed Results',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            ..._currentResults.map((result) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: _getPerformanceColor(result.duration),
                  radius: 16,
                  child: Icon(
                    _getBenchmarkIcon(result.testName),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                title: Text(result.testName),
                subtitle: result.metadata.isNotEmpty
                    ? Text(
                        result.metadata.entries
                            .map((e) => '${e.key}: ${e.value}')
                            .join(' • '),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      )
                    : null,
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      result.durationFormatted,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getPerformanceColor(result.duration),
                      ),
                    ),
                    Text(
                      _formatDateTime(result.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
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

  List<_BenchmarkTest> _getBenchmarkTests() {
    return [
      _BenchmarkTest(
        name: 'Page Load',
        description: 'Time to load a page',
        icon: Icons.web,
        execute: _benchmarkPageLoad,
      ),
      _BenchmarkTest(
        name: 'JS Execution (Simple)',
        description: 'Execute simple JavaScript',
        icon: Icons.code,
        execute: _benchmarkJsSimple,
      ),
      _BenchmarkTest(
        name: 'JS Execution (Complex)',
        description: 'Execute complex JavaScript',
        icon: Icons.code,
        execute: _benchmarkJsComplex,
      ),
      _BenchmarkTest(
        name: 'DOM Query',
        description: 'Query DOM elements',
        icon: Icons.search,
        execute: _benchmarkDomQuery,
      ),
      _BenchmarkTest(
        name: 'Screenshot',
        description: 'Capture screenshot',
        icon: Icons.camera_alt,
        execute: _benchmarkScreenshot,
      ),
      _BenchmarkTest(
        name: 'Get HTML',
        description: 'Get page HTML content',
        icon: Icons.article,
        execute: _benchmarkGetHtml,
      ),
      _BenchmarkTest(
        name: 'Cookie Operations',
        description: 'Set and get cookies',
        icon: Icons.cookie,
        execute: _benchmarkCookies,
      ),
    ];
  }

  Future<void> _runBenchmarks() async {
    if (_webViewController == null) return;

    setState(() {
      _isRunning = true;
      _currentResults = [];
    });

    final tests = _getBenchmarkTests();

    for (final test in tests) {
      if (!_isRunning) break;

      setState(() {
        _currentBenchmark = test.name;
      });

      try {
        final result = await _runBenchmarkWithIterations(test);
        setState(() {
          _currentResults = [..._currentResults, result];
        });
      } catch (e) {
        debugPrint('Benchmark ${test.name} failed: $e');
      }
    }

    // Save session
    if (_currentResults.isNotEmpty) {
      final session = BenchmarkSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        deviceInfo: PlatformUtils.getPlatformName(),
        platformName: PlatformUtils.getPlatformName(),
        results: _currentResults,
      );
      await _saveSession(session);
    }

    setState(() {
      _isRunning = false;
      _currentBenchmark = null;
    });
  }

  Future<BenchmarkResult> _runBenchmarkWithIterations(
    _BenchmarkTest test,
  ) async {
    final durations = <Duration>[];

    for (var i = 0; i < _iterations; i++) {
      final stopwatch = Stopwatch()..start();
      await test.execute(_webViewController!);
      stopwatch.stop();
      durations.add(stopwatch.elapsed);

      // Small delay between iterations
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Calculate average
    final avgMs =
        durations.fold<int>(0, (sum, d) => sum + d.inMilliseconds) ~/
        durations.length;

    return BenchmarkResult(
      id: '${test.name}_${DateTime.now().millisecondsSinceEpoch}',
      testName: test.name,
      timestamp: DateTime.now(),
      duration: Duration(milliseconds: avgMs),
      metadata: {
        'iterations': _iterations,
        'minMs': durations
            .map((d) => d.inMilliseconds)
            .reduce((a, b) => a < b ? a : b),
        'maxMs': durations
            .map((d) => d.inMilliseconds)
            .reduce((a, b) => a > b ? a : b),
      },
    );
  }

  Future<Map<String, dynamic>> _benchmarkPageLoad(
    InAppWebViewController controller,
  ) async {
    // Load a simple page
    await controller.loadUrl(
      urlRequest: URLRequest(url: WebUri('https://example.com')),
    );

    // Wait for load to complete (simplified - in production use onLoadStop)
    await Future.delayed(const Duration(seconds: 2));

    return {'url': 'https://example.com'};
  }

  Future<Map<String, dynamic>> _benchmarkJsSimple(
    InAppWebViewController controller,
  ) async {
    final result = await controller.evaluateJavascript(source: '1 + 1');
    return {'result': result};
  }

  Future<Map<String, dynamic>> _benchmarkJsComplex(
    InAppWebViewController controller,
  ) async {
    final result = await controller.evaluateJavascript(
      source: '''
        (function() {
          var result = [];
          for (var i = 0; i < 1000; i++) {
            result.push(Math.sqrt(i));
          }
          return result.length;
        })()
      ''',
    );
    return {'arrayLength': result};
  }

  Future<Map<String, dynamic>> _benchmarkDomQuery(
    InAppWebViewController controller,
  ) async {
    final result = await controller.evaluateJavascript(
      source: 'document.querySelectorAll("*").length',
    );
    return {'elementCount': result};
  }

  Future<Map<String, dynamic>> _benchmarkScreenshot(
    InAppWebViewController controller,
  ) async {
    final screenshot = await controller.takeScreenshot();
    return {'size': screenshot?.length ?? 0};
  }

  Future<Map<String, dynamic>> _benchmarkGetHtml(
    InAppWebViewController controller,
  ) async {
    final html = await controller.getHtml();
    return {'length': html?.length ?? 0};
  }

  Future<Map<String, dynamic>> _benchmarkCookies(
    InAppWebViewController controller,
  ) async {
    final cookieManager = CookieManager.instance();

    // Set cookie
    await cookieManager.setCookie(
      url: WebUri('https://example.com'),
      name: 'benchmark_cookie',
      value: 'test_value',
    );

    // Get cookies
    final cookies = await cookieManager.getCookies(
      url: WebUri('https://example.com'),
    );

    return {'cookieCount': cookies.length};
  }

  void _stopBenchmarks() {
    setState(() {
      _isRunning = false;
      _currentBenchmark = null;
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportResults();
        break;
      case 'clear_history':
        _clearHistory();
        break;
    }
  }

  void _exportResults() {
    if (_currentResults.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No results to export')));
      return;
    }

    final session = BenchmarkSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      deviceInfo: PlatformUtils.getPlatformName(),
      platformName: PlatformUtils.getPlatformName(),
      results: _currentResults,
    );

    final json = const JsonEncoder.withIndent('  ').convert(session.toJson());
    Clipboard.setData(ClipboardData(text: json));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Results copied to clipboard')),
    );
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all historical benchmark data?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      setState(() {
        _historicalSessions = [];
        _previousSession = null;
      });
    }
  }

  void _showHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Benchmark History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _historicalSessions.length,
            itemBuilder: (context, index) {
              final session = _historicalSessions[index];
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(_formatDateTime(session.timestamp)),
                subtitle: Text(
                  '${session.results.length} tests • '
                  'Avg: ${session.averageDuration.inMilliseconds}ms',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.restore),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentResults = List.from(session.results);
                    });
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getPerformanceColor(Duration duration) {
    final ms = duration.inMilliseconds;
    if (ms < 100) return Colors.green;
    if (ms < 500) return Colors.orange;
    return Colors.red;
  }

  IconData _getBenchmarkIcon(String testName) {
    if (testName.contains('Page')) return Icons.web;
    if (testName.contains('JS')) return Icons.code;
    if (testName.contains('DOM')) return Icons.search;
    if (testName.contains('Screenshot')) return Icons.camera_alt;
    if (testName.contains('HTML')) return Icons.article;
    if (testName.contains('Cookie')) return Icons.cookie;
    return Icons.speed;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _BenchmarkTest {
  final String name;
  final String description;
  final IconData icon;
  final Future<Map<String, dynamic>> Function(InAppWebViewController) execute;

  const _BenchmarkTest({
    required this.name,
    required this.description,
    required this.icon,
    required this.execute,
  });
}
