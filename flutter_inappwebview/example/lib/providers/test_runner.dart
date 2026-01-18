import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../models/test_result.dart';
import '../utils/constants.dart';

/// Status of the test runner
enum TestStatus { idle, running, paused, completed, error }

/// Extended test result with additional metadata
class ExtendedTestResult {
  final String testId;
  final String testTitle;
  final TestCategory category;
  final bool success;
  final String message;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final bool skipped;
  final String? skipReason;

  const ExtendedTestResult({
    required this.testId,
    required this.testTitle,
    required this.category,
    required this.success,
    required this.message,
    required this.duration,
    required this.timestamp,
    this.data,
    this.skipped = false,
    this.skipReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'testTitle': testTitle,
      'category': category.name,
      'success': success,
      'message': message,
      'durationMs': duration.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
      'skipped': skipped,
      'skipReason': skipReason,
    };
  }

  factory ExtendedTestResult.fromJson(Map<String, dynamic> json) {
    return ExtendedTestResult(
      testId: json['testId'] as String,
      testTitle: json['testTitle'] as String,
      category: TestCategory.values.firstWhere(
        (c) => c.name == json['category'],
      ),
      success: json['success'] as bool,
      message: json['message'] as String,
      duration: Duration(milliseconds: json['durationMs'] as int),
      timestamp: DateTime.parse(json['timestamp'] as String),
      data: json['data'] as Map<String, dynamic>?,
      skipped: json['skipped'] as bool? ?? false,
      skipReason: json['skipReason'] as String?,
    );
  }
}

/// A single test case that can be executed
class ExecutableTestCase {
  final String id;
  final String title;
  final String description;
  final TestCategory category;
  final Future<TestResult> Function(InAppWebViewController? controller) execute;
  final List<String> supportedPlatforms;

  const ExecutableTestCase({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.execute,
    this.supportedPlatforms = const [
      'android',
      'ios',
      'macos',
      'windows',
      'linux',
      'web',
    ],
  });

  bool isSupportedOnCurrentPlatform() {
    final currentPlatform = _getCurrentPlatform();
    return supportedPlatforms.contains(currentPlatform);
  }

  static String _getCurrentPlatform() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      default:
        return 'unknown';
    }
  }
}

/// Category with its test cases
class TestCategoryGroup {
  final String name;
  final String description;
  final TestCategory category;
  final List<ExecutableTestCase> tests;

  const TestCategoryGroup({
    required this.name,
    required this.description,
    required this.category,
    required this.tests,
  });
}

/// Test runner for executing automated tests
class TestRunner extends ChangeNotifier {
  TestStatus _status = TestStatus.idle;
  List<ExtendedTestResult> _results = [];
  String? _currentTest;
  int _progress = 0;
  int _total = 0;
  bool _shouldStop = false;
  DateTime? _startTime;
  DateTime? _endTime;

  // Getters
  TestStatus get status => _status;
  List<ExtendedTestResult> get results => List.unmodifiable(_results);
  String? get currentTest => _currentTest;
  int get progress => _progress;
  int get total => _total;
  int get passed => _results.where((r) => r.success && !r.skipped).length;
  int get failed => _results.where((r) => !r.success && !r.skipped).length;
  int get skipped => _results.where((r) => r.skipped).length;
  DateTime? get startTime => _startTime;
  DateTime? get endTime => _endTime;

  Duration get elapsedTime {
    if (_startTime == null) return Duration.zero;
    final end = _endTime ?? DateTime.now();
    return end.difference(_startTime!);
  }

  double get successRate {
    final executed = _results.where((r) => !r.skipped).length;
    if (executed == 0) return 0;
    return (passed / executed) * 100;
  }

  /// Run all tests for a specific category
  Future<void> runCategoryTests(
    TestCategory category,
    InAppWebViewController? controller,
  ) async {
    final categoryGroup = getTestCategories().firstWhere(
      (g) => g.category == category,
      orElse: () => throw Exception('Category not found'),
    );

    await _runTests(categoryGroup.tests, controller);
  }

  /// Run all tests across all categories
  Future<void> runAllTests(InAppWebViewController? controller) async {
    final allTests = <ExecutableTestCase>[];
    for (final category in getTestCategories()) {
      allTests.addAll(category.tests);
    }
    await _runTests(allTests, controller);
  }

  /// Run selected tests
  Future<void> runSelectedTests(
    List<ExecutableTestCase> tests,
    InAppWebViewController? controller,
  ) async {
    await _runTests(tests, controller);
  }

  /// Run tests from selected categories
  Future<void> runSelectedCategories(
    List<TestCategory> categories,
    InAppWebViewController? controller,
  ) async {
    final tests = <ExecutableTestCase>[];
    for (final category in getTestCategories()) {
      if (categories.contains(category.category)) {
        tests.addAll(category.tests);
      }
    }
    await _runTests(tests, controller);
  }

  /// Run a single test
  Future<ExtendedTestResult> runSingleTest(
    ExecutableTestCase testCase,
    InAppWebViewController? controller,
  ) async {
    _status = TestStatus.running;
    _currentTest = testCase.title;
    _progress = 0;
    _total = 1;
    _startTime = DateTime.now();
    notifyListeners();

    final result = await _executeTest(testCase, controller);
    _results = [result];

    _status = TestStatus.completed;
    _currentTest = null;
    _progress = 1;
    _endTime = DateTime.now();
    notifyListeners();

    return result;
  }

  /// Re-run failed tests
  Future<void> rerunFailedTests(InAppWebViewController? controller) async {
    final failedTestIds = _results
        .where((r) => !r.success && !r.skipped)
        .map((r) => r.testId)
        .toSet();

    final allTests = <ExecutableTestCase>[];
    for (final category in getTestCategories()) {
      allTests.addAll(category.tests);
    }

    final failedTests = allTests
        .where((t) => failedTestIds.contains(t.id))
        .toList();

    // Remove old failed results
    _results = _results.where((r) => r.success || r.skipped).toList();

    await _runTests(failedTests, controller, append: true);
  }

  Future<void> _runTests(
    List<ExecutableTestCase> tests,
    InAppWebViewController? controller, {
    bool append = false,
  }) async {
    if (_status == TestStatus.running) return;

    _status = TestStatus.running;
    _shouldStop = false;
    if (!append) {
      _results = [];
    }
    _progress = 0;
    _total = tests.length;
    _startTime = DateTime.now();
    _endTime = null;
    notifyListeners();

    for (var i = 0; i < tests.length; i++) {
      if (_shouldStop) {
        _status = TestStatus.paused;
        notifyListeners();
        break;
      }

      final test = tests[i];
      _currentTest = test.title;
      _progress = i;
      notifyListeners();

      final result = await _executeTest(test, controller);
      _results = [..._results, result];
      notifyListeners();

      // Small delay between tests to avoid overwhelming the system
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _status = _shouldStop ? TestStatus.paused : TestStatus.completed;
    _currentTest = null;
    _progress = tests.length;
    _endTime = DateTime.now();
    _shouldStop = false;
    notifyListeners();
  }

  Future<ExtendedTestResult> _executeTest(
    ExecutableTestCase testCase,
    InAppWebViewController? controller,
  ) async {
    // Check platform support
    if (!testCase.isSupportedOnCurrentPlatform()) {
      return ExtendedTestResult(
        testId: testCase.id,
        testTitle: testCase.title,
        category: testCase.category,
        success: true,
        message: 'Skipped - not supported on current platform',
        duration: Duration.zero,
        timestamp: DateTime.now(),
        skipped: true,
        skipReason: 'Platform not supported',
      );
    }

    // Check if controller is required but not provided
    if (controller == null && _requiresController(testCase.id)) {
      return ExtendedTestResult(
        testId: testCase.id,
        testTitle: testCase.title,
        category: testCase.category,
        success: false,
        message: 'WebView controller not available',
        duration: Duration.zero,
        timestamp: DateTime.now(),
      );
    }

    final stopwatch = Stopwatch()..start();
    try {
      final result = await testCase.execute(controller);
      stopwatch.stop();

      return ExtendedTestResult(
        testId: testCase.id,
        testTitle: testCase.title,
        category: testCase.category,
        success: result.passed,
        message: result.message,
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
        data: result.data,
      );
    } catch (e, stackTrace) {
      stopwatch.stop();
      debugPrint('Test ${testCase.id} failed with error: $e');
      debugPrint('Stack trace: $stackTrace');

      return ExtendedTestResult(
        testId: testCase.id,
        testTitle: testCase.title,
        category: testCase.category,
        success: false,
        message: 'Error: ${e.toString()}',
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
        data: {'error': e.toString(), 'stackTrace': stackTrace.toString()},
      );
    }
  }

  bool _requiresController(String testId) {
    // Most tests require a controller except for cookie/storage tests
    // that use static managers
    return !testId.startsWith('cookie_') &&
        !testId.startsWith('storage_class_');
  }

  /// Stop running tests
  void stopTests() {
    _shouldStop = true;
    notifyListeners();
  }

  /// Clear results
  void clearResults() {
    _results = [];
    _status = TestStatus.idle;
    _currentTest = null;
    _progress = 0;
    _total = 0;
    _startTime = null;
    _endTime = null;
    notifyListeners();
  }

  /// Export results as JSON
  String exportResultsAsJson() {
    final export = {
      'exportedAt': DateTime.now().toIso8601String(),
      'status': _status.name,
      'startTime': _startTime?.toIso8601String(),
      'endTime': _endTime?.toIso8601String(),
      'totalTests': _total,
      'passed': passed,
      'failed': failed,
      'skipped': skipped,
      'successRate': successRate,
      'results': _results.map((r) => r.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(export);
  }

  /// Export results as CSV
  String exportResultsAsCsv() {
    final buffer = StringBuffer();
    buffer.writeln(
      'Test ID,Test Title,Category,Success,Skipped,Duration (ms),Message,Timestamp',
    );
    for (final result in _results) {
      final message = result.message.replaceAll('"', '""');
      buffer.writeln(
        '"${result.testId}","${result.testTitle}","${result.category.name}",${result.success},${result.skipped},${result.duration.inMilliseconds},"$message","${result.timestamp.toIso8601String()}"',
      );
    }
    return buffer.toString();
  }

  /// Get all available test categories with their tests
  static List<TestCategoryGroup> getTestCategories() {
    return [
      _buildNavigationTests(),
      _buildJavaScriptTests(),
      _buildPageInfoTests(),
      _buildScrollTests(),
      _buildCookieTests(),
      _buildStorageTests(),
    ];
  }

  // ============================================================
  // NAVIGATION TESTS
  // ============================================================
  static TestCategoryGroup _buildNavigationTests() {
    return TestCategoryGroup(
      name: 'Navigation',
      description: 'Tests for navigation-related methods',
      category: TestCategory.navigation,
      tests: [
        ExecutableTestCase(
          id: 'nav_loadUrl',
          title: 'Load URL',
          description: 'Load a URL and verify it loaded',
          category: TestCategory.navigation,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            final completer = Completer<bool>();
            final targetUrl = WebUri('https://flutter.dev');

            // Set up listener for load completion
            Timer? timeout;
            timeout = Timer(const Duration(seconds: 10), () {
              if (!completer.isCompleted) {
                completer.complete(false);
              }
            });

            await controller.loadUrl(urlRequest: URLRequest(url: targetUrl));

            // Wait a bit for the page to start loading
            await Future.delayed(const Duration(milliseconds: 500));

            final currentUrl = await controller.getUrl();
            timeout.cancel();

            final success =
                currentUrl?.toString().contains('flutter.dev') ?? false;

            return TestResult(
              passed: success,
              message: success
                  ? 'URL loaded successfully: $currentUrl'
                  : 'Failed to load URL. Current: $currentUrl',
              duration: Duration.zero,
              data: {'url': currentUrl?.toString()},
            );
          },
        ),
        ExecutableTestCase(
          id: 'nav_loadData',
          title: 'Load HTML Data',
          description: 'Load HTML data directly',
          category: TestCategory.navigation,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            const htmlData =
                '<html><body><h1 id="test">Test Page</h1></body></html>';
            await controller.loadData(
              data: htmlData,
              mimeType: 'text/html',
              encoding: 'utf-8',
            );

            await Future.delayed(const Duration(milliseconds: 500));

            final result = await controller.evaluateJavascript(
              source: 'document.getElementById("test")?.innerText',
            );

            final success = result == 'Test Page';

            return TestResult(
              passed: success,
              message: success
                  ? 'HTML data loaded successfully'
                  : 'Failed to load HTML data. Result: $result',
              duration: Duration.zero,
            );
          },
        ),
        ExecutableTestCase(
          id: 'nav_reload',
          title: 'Reload Page',
          description: 'Reload the current page',
          category: TestCategory.navigation,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              await controller.reload();
              await Future.delayed(const Duration(milliseconds: 300));
              return TestResult(
                passed: true,
                message: 'Page reloaded successfully',
                duration: Duration.zero,
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to reload: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'nav_stopLoading',
          title: 'Stop Loading',
          description: 'Stop a loading page',
          category: TestCategory.navigation,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              // Start loading a slow page
              controller.loadUrl(
                urlRequest: URLRequest(
                  url: WebUri('https://www.google.com/search?q=flutter'),
                ),
              );

              // Immediately stop
              await Future.delayed(const Duration(milliseconds: 100));
              await controller.stopLoading();

              return TestResult(
                passed: true,
                message: 'Stop loading executed successfully',
                duration: Duration.zero,
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to stop loading: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'nav_canGoBack',
          title: 'Can Go Back',
          description: 'Check navigation history (back)',
          category: TestCategory.navigation,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              final canGoBack = await controller.canGoBack();
              return TestResult(
                passed: true,
                message: 'canGoBack returned: $canGoBack',
                duration: Duration.zero,
                data: {'canGoBack': canGoBack},
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to check canGoBack: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'nav_canGoForward',
          title: 'Can Go Forward',
          description: 'Check navigation history (forward)',
          category: TestCategory.navigation,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              final canGoForward = await controller.canGoForward();
              return TestResult(
                passed: true,
                message: 'canGoForward returned: $canGoForward',
                duration: Duration.zero,
                data: {'canGoForward': canGoForward},
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to check canGoForward: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'nav_goBack',
          title: 'Go Back',
          description: 'Navigate back in history',
          category: TestCategory.navigation,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              await controller.goBack();
              return TestResult(
                passed: true,
                message: 'goBack executed successfully',
                duration: Duration.zero,
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to go back: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'nav_goForward',
          title: 'Go Forward',
          description: 'Navigate forward in history',
          category: TestCategory.navigation,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              await controller.goForward();
              return TestResult(
                passed: true,
                message: 'goForward executed successfully',
                duration: Duration.zero,
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to go forward: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
      ],
    );
  }

  // ============================================================
  // JAVASCRIPT TESTS
  // ============================================================
  static TestCategoryGroup _buildJavaScriptTests() {
    return TestCategoryGroup(
      name: 'JavaScript',
      description: 'Tests for JavaScript execution methods',
      category: TestCategory.javascript,
      tests: [
        ExecutableTestCase(
          id: 'js_evaluateSimple',
          title: 'Evaluate JavaScript (Simple)',
          description: 'Execute simple JS and get result',
          category: TestCategory.javascript,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              final result = await controller.evaluateJavascript(
                source: '1 + 1',
              );

              final success = result == 2 || result == '2';
              return TestResult(
                passed: success,
                message: success
                    ? 'JavaScript evaluated: 1 + 1 = $result'
                    : 'Unexpected result: $result',
                duration: Duration.zero,
                data: {'result': result},
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to evaluate JS: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'js_evaluateString',
          title: 'Evaluate JavaScript (String)',
          description: 'Execute JS returning a string',
          category: TestCategory.javascript,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              final result = await controller.evaluateJavascript(
                source: '"Hello" + " " + "World"',
              );

              final success = result == 'Hello World';
              return TestResult(
                passed: success,
                message: success
                    ? 'String concatenation: $result'
                    : 'Unexpected result: $result',
                duration: Duration.zero,
                data: {'result': result},
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to evaluate JS: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'js_evaluateObject',
          title: 'Evaluate JavaScript (Object)',
          description: 'Execute JS returning an object',
          category: TestCategory.javascript,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              final result = await controller.evaluateJavascript(
                source: 'JSON.stringify({name: "test", value: 42})',
              );

              final decoded = jsonDecode(result.toString());
              final success =
                  decoded['name'] == 'test' && decoded['value'] == 42;

              return TestResult(
                passed: success,
                message: success
                    ? 'Object returned correctly: $result'
                    : 'Unexpected result: $result',
                duration: Duration.zero,
                data: {'result': decoded},
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to evaluate JS: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'js_callAsync',
          title: 'Call Async JavaScript',
          description: 'Execute async JS with await',
          category: TestCategory.javascript,
          supportedPlatforms: const ['android', 'ios', 'macos'],
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              final result = await controller.callAsyncJavaScript(
                functionBody: '''
                  await new Promise(resolve => setTimeout(resolve, 100));
                  return "async result";
                ''',
              );

              final success = result?.value == 'async result';
              return TestResult(
                passed: success,
                message: success
                    ? 'Async JS executed: ${result?.value}'
                    : 'Unexpected result: ${result?.value}',
                duration: Duration.zero,
                data: {'result': result?.value},
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to call async JS: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'js_injectCSS',
          title: 'Inject CSS Code',
          description: 'Inject CSS into the page',
          category: TestCategory.javascript,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              await controller.injectCSSCode(
                source: 'body { background-color: red !important; }',
              );

              return TestResult(
                passed: true,
                message: 'CSS injected successfully',
                duration: Duration.zero,
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to inject CSS: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'js_injectJSFile',
          title: 'Inject JavaScript File',
          description: 'Inject external JS file',
          category: TestCategory.javascript,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              await controller.injectJavascriptFileFromUrl(
                urlFile: WebUri(
                  'https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.17.21/lodash.min.js',
                ),
              );

              await Future.delayed(const Duration(milliseconds: 500));

              final result = await controller.evaluateJavascript(
                source: 'typeof _ !== "undefined"',
              );

              final success = result == true || result == 'true';
              return TestResult(
                passed: success,
                message: success
                    ? 'External JS file injected successfully'
                    : 'JS file injection may have failed',
                duration: Duration.zero,
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to inject JS file: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
      ],
    );
  }

  // ============================================================
  // PAGE INFO TESTS
  // ============================================================
  static TestCategoryGroup _buildPageInfoTests() {
    return TestCategoryGroup(
      name: 'Page Info',
      description: 'Tests for retrieving page information',
      category: TestCategory.content,
      tests: [
        ExecutableTestCase(
          id: 'page_getUrl',
          title: 'Get URL',
          description: 'Get current page URL',
          category: TestCategory.content,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              final url = await controller.getUrl();
              return TestResult(
                passed: url != null,
                message: url != null ? 'Current URL: $url' : 'URL is null',
                duration: Duration.zero,
                data: {'url': url?.toString()},
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to get URL: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'page_getTitle',
          title: 'Get Title',
          description: 'Get current page title',
          category: TestCategory.content,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              final title = await controller.getTitle();
              return TestResult(
                passed: true,
                message: 'Page title: ${title ?? "(empty)"}',
                duration: Duration.zero,
                data: {'title': title},
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to get title: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'page_getHtml',
          title: 'Get HTML',
          description: 'Get page HTML content',
          category: TestCategory.content,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              final html = await controller.getHtml();
              final success = html != null && html.isNotEmpty;
              return TestResult(
                passed: success,
                message: success
                    ? 'HTML retrieved (${html.length} chars)'
                    : 'HTML is empty or null',
                duration: Duration.zero,
                data: {'htmlLength': html?.length},
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to get HTML: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'page_getProgress',
          title: 'Get Progress',
          description: 'Get page loading progress',
          category: TestCategory.content,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              final progress = await controller.getProgress();
              final success =
                  progress != null && progress >= 0 && progress <= 100;
              return TestResult(
                passed: success,
                message: 'Loading progress: $progress%',
                duration: Duration.zero,
                data: {'progress': progress},
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to get progress: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'page_getFavicons',
          title: 'Get Favicons',
          description: 'Get page favicon URLs',
          category: TestCategory.content,
          supportedPlatforms: const ['android', 'ios', 'macos'],
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              final favicons = await controller.getFavicons();
              return TestResult(
                passed: true,
                message: 'Found ${favicons.length} favicon(s)',
                duration: Duration.zero,
                data: {'count': favicons.length},
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to get favicons: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'page_getOriginalUrl',
          title: 'Get Original URL',
          description: 'Get original URL before redirects',
          category: TestCategory.content,
          supportedPlatforms: const ['android'],
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              final url = await controller.getOriginalUrl();
              return TestResult(
                passed: true,
                message: 'Original URL: ${url ?? "(none)"}',
                duration: Duration.zero,
                data: {'url': url?.toString()},
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to get original URL: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
      ],
    );
  }

  // ============================================================
  // SCROLL TESTS
  // ============================================================
  static TestCategoryGroup _buildScrollTests() {
    return TestCategoryGroup(
      name: 'Scroll',
      description: 'Tests for scroll-related methods',
      category: TestCategory.advanced,
      tests: [
        ExecutableTestCase(
          id: 'scroll_scrollTo',
          title: 'Scroll To',
          description: 'Scroll to specific position',
          category: TestCategory.advanced,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              await controller.scrollTo(x: 0, y: 100);
              await Future.delayed(const Duration(milliseconds: 200));

              final y = await controller.getScrollY();
              final success = y != null && y >= 0;

              return TestResult(
                passed: success,
                message: 'Scrolled to y=$y',
                duration: Duration.zero,
                data: {'y': y},
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to scroll: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'scroll_scrollBy',
          title: 'Scroll By',
          description: 'Scroll by offset',
          category: TestCategory.advanced,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              final initialY = await controller.getScrollY() ?? 0;
              await controller.scrollBy(x: 0, y: 50);
              await Future.delayed(const Duration(milliseconds: 200));

              final newY = await controller.getScrollY() ?? 0;

              return TestResult(
                passed: true,
                message: 'Scrolled from $initialY to $newY',
                duration: Duration.zero,
                data: {'initialY': initialY, 'newY': newY},
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to scroll by: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'scroll_getScrollX',
          title: 'Get Scroll X',
          description: 'Get horizontal scroll position',
          category: TestCategory.advanced,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              final x = await controller.getScrollX();
              return TestResult(
                passed: x != null,
                message: 'Scroll X: ${x ?? "null"}',
                duration: Duration.zero,
                data: {'x': x},
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to get scroll X: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'scroll_getScrollY',
          title: 'Get Scroll Y',
          description: 'Get vertical scroll position',
          category: TestCategory.advanced,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              final y = await controller.getScrollY();
              return TestResult(
                passed: y != null,
                message: 'Scroll Y: ${y ?? "null"}',
                duration: Duration.zero,
                data: {'y': y},
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to get scroll Y: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
      ],
    );
  }

  // ============================================================
  // COOKIE TESTS
  // ============================================================
  static TestCategoryGroup _buildCookieTests() {
    return TestCategoryGroup(
      name: 'Cookies',
      description: 'Tests for cookie management',
      category: TestCategory.storage,
      tests: [
        ExecutableTestCase(
          id: 'cookie_setCookie',
          title: 'Set Cookie',
          description: 'Set a cookie for a URL',
          category: TestCategory.storage,
          execute: (controller) async {
            try {
              await CookieManager.instance().setCookie(
                url: WebUri('https://flutter.dev'),
                name: 'test_cookie_${DateTime.now().millisecondsSinceEpoch}',
                value: 'test_value',
              );

              return TestResult(
                passed: true,
                message: 'Cookie set successfully',
                duration: Duration.zero,
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to set cookie: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'cookie_getCookies',
          title: 'Get Cookies',
          description: 'Get cookies for a URL',
          category: TestCategory.storage,
          execute: (controller) async {
            try {
              final cookies = await CookieManager.instance().getCookies(
                url: WebUri('https://flutter.dev'),
              );

              return TestResult(
                passed: true,
                message: 'Retrieved ${cookies.length} cookie(s)',
                duration: Duration.zero,
                data: {'count': cookies.length},
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to get cookies: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'cookie_deleteCookie',
          title: 'Delete Cookie',
          description: 'Delete a specific cookie',
          category: TestCategory.storage,
          execute: (controller) async {
            try {
              // First set a cookie to delete
              final cookieName =
                  'delete_test_${DateTime.now().millisecondsSinceEpoch}';
              await CookieManager.instance().setCookie(
                url: WebUri('https://flutter.dev'),
                name: cookieName,
                value: 'to_delete',
              );

              // Then delete it
              await CookieManager.instance().deleteCookie(
                url: WebUri('https://flutter.dev'),
                name: cookieName,
              );

              return TestResult(
                passed: true,
                message: 'Cookie deleted successfully',
                duration: Duration.zero,
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to delete cookie: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'cookie_deleteAllCookies',
          title: 'Delete All Cookies',
          description: 'Delete all cookies',
          category: TestCategory.storage,
          execute: (controller) async {
            try {
              await CookieManager.instance().deleteAllCookies();

              return TestResult(
                passed: true,
                message: 'All cookies deleted',
                duration: Duration.zero,
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to delete all cookies: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
      ],
    );
  }

  // ============================================================
  // STORAGE TESTS
  // ============================================================
  static TestCategoryGroup _buildStorageTests() {
    return TestCategoryGroup(
      name: 'Web Storage',
      description: 'Tests for localStorage and sessionStorage',
      category: TestCategory.storage,
      tests: [
        ExecutableTestCase(
          id: 'storage_localStorage_setItem',
          title: 'LocalStorage Set Item',
          description: 'Set an item in localStorage',
          category: TestCategory.storage,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              final key = 'test_key_${DateTime.now().millisecondsSinceEpoch}';
              await controller.webStorage.localStorage.setItem(
                key: key,
                value: 'test_value',
              );

              return TestResult(
                passed: true,
                message: 'LocalStorage item set: $key',
                duration: Duration.zero,
                data: {'key': key},
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to set localStorage item: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'storage_localStorage_getItem',
          title: 'LocalStorage Get Item',
          description: 'Get an item from localStorage',
          category: TestCategory.storage,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              // First set an item
              final key = 'get_test_${DateTime.now().millisecondsSinceEpoch}';
              final value = 'test_value_123';
              await controller.webStorage.localStorage.setItem(
                key: key,
                value: value,
              );

              // Then get it
              final retrieved = await controller.webStorage.localStorage
                  .getItem(key: key);

              final success = retrieved == value;
              return TestResult(
                passed: success,
                message: success
                    ? 'LocalStorage item retrieved: $retrieved'
                    : 'Value mismatch: expected $value, got $retrieved',
                duration: Duration.zero,
                data: {'key': key, 'value': retrieved},
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to get localStorage item: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'storage_localStorage_removeItem',
          title: 'LocalStorage Remove Item',
          description: 'Remove an item from localStorage',
          category: TestCategory.storage,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              final key =
                  'remove_test_${DateTime.now().millisecondsSinceEpoch}';
              await controller.webStorage.localStorage.setItem(
                key: key,
                value: 'to_remove',
              );

              await controller.webStorage.localStorage.removeItem(key: key);

              return TestResult(
                passed: true,
                message: 'LocalStorage item removed',
                duration: Duration.zero,
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to remove localStorage item: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'storage_sessionStorage_setItem',
          title: 'SessionStorage Set Item',
          description: 'Set an item in sessionStorage',
          category: TestCategory.storage,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              final key =
                  'session_test_${DateTime.now().millisecondsSinceEpoch}';
              await controller.webStorage.sessionStorage.setItem(
                key: key,
                value: 'session_value',
              );

              return TestResult(
                passed: true,
                message: 'SessionStorage item set: $key',
                duration: Duration.zero,
                data: {'key': key},
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to set sessionStorage item: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
        ExecutableTestCase(
          id: 'storage_sessionStorage_getItem',
          title: 'SessionStorage Get Item',
          description: 'Get an item from sessionStorage',
          category: TestCategory.storage,
          execute: (controller) async {
            if (controller == null) {
              return TestResult(
                passed: false,
                message: 'Controller not available',
                duration: Duration.zero,
              );
            }

            try {
              final key =
                  'session_get_${DateTime.now().millisecondsSinceEpoch}';
              final value = 'session_value_123';
              await controller.webStorage.sessionStorage.setItem(
                key: key,
                value: value,
              );

              final retrieved = await controller.webStorage.sessionStorage
                  .getItem(key: key);

              final success = retrieved == value;
              return TestResult(
                passed: success,
                message: success
                    ? 'SessionStorage item retrieved: $retrieved'
                    : 'Value mismatch: expected $value, got $retrieved',
                duration: Duration.zero,
                data: {'key': key, 'value': retrieved},
              );
            } catch (e) {
              return TestResult(
                passed: false,
                message: 'Failed to get sessionStorage item: $e',
                duration: Duration.zero,
              );
            }
          },
        ),
      ],
    );
  }
}
