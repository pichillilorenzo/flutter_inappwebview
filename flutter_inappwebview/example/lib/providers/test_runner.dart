import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../models/test_configuration.dart';
import '../models/test_result.dart';
import '../models/test_runner_models.dart';
import '../utils/constants.dart';
import '../utils/controller_methods_registry.dart';
import '../utils/test_runner_catalog.dart';

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

  /// The current test configuration being used
  TestConfiguration? _currentConfiguration;

  /// The type of WebView being used
  TestWebViewType _webViewType = TestWebViewType.inAppWebView;

  /// Headless WebView instance (when using headless mode)
  HeadlessInAppWebView? _headlessWebView;

  /// Controller for WebView (both headless and visible)
  InAppWebViewController? _webViewController;

  /// Whether the WebView is ready
  bool _webViewReady = false;

  /// Key to force WebView recreation
  Key _webViewKey = UniqueKey();

  /// Initial URL for the WebView
  String _initialUrl = 'about:blank';

  // Event StreamControllers for listening to WebView events
  final _onLoadStopController = StreamController<WebUri?>.broadcast();
  final _onLoadStartController = StreamController<WebUri?>.broadcast();
  final _onProgressChangedController = StreamController<int>.broadcast();
  final _onPageCommitVisibleController = StreamController<WebUri?>.broadcast();
  final _onTitleChangedController = StreamController<String?>.broadcast();
  final _onUpdateVisitedHistoryController =
      StreamController<WebUri?>.broadcast();

  // Store target progress for onProgressChanged event filtering
  int _targetProgress = 100;
  String _progressComparison = 'greaterThanOrEquals';

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
  TestConfiguration? get currentConfiguration => _currentConfiguration;
  TestWebViewType get webViewType => _webViewType;
  bool get isUsingHeadless => _webViewType == TestWebViewType.headless;
  HeadlessInAppWebView? get headlessWebView => _headlessWebView;
  InAppWebViewController? get webViewController => _webViewController;
  bool get webViewReady => _webViewReady;
  Key get webViewKey => _webViewKey;

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

  /// Set the WebView type to use for testing
  void setWebViewType(TestWebViewType type) {
    if (_webViewType != type) {
      _webViewType = type;
      _webViewReady = false;
      _webViewController = null;
      _webViewKey = UniqueKey();
      notifyListeners();
    }
  }

  /// Set the test configuration to use
  void setConfiguration(TestConfiguration? config) {
    _currentConfiguration = config;
    if (config != null) {
      _webViewType = config.webViewType;
      _initialUrl = config.initialUrl ?? 'about:blank';
    }
    _webViewReady = false;
    _webViewController = null;
    _webViewKey = UniqueKey();
    notifyListeners();
  }

  /// Set the initial URL for the WebView
  void setInitialUrl(String url) {
    _initialUrl = url;
    notifyListeners();
  }

  /// Recreate the WebView (forces a new key)
  void recreateWebView() {
    _webViewReady = false;
    _webViewController = null;
    _webViewKey = UniqueKey();
    notifyListeners();
  }

  /// Build the InAppWebView widget for visible mode
  /// This should be used by the UI to display the WebView
  Widget buildInAppWebView({double? width, double? height}) {
    return InAppWebView(
      key: _webViewKey,
      initialUrlRequest: URLRequest(
        url: WebUri(_currentConfiguration?.initialUrl ?? _initialUrl),
      ),
      initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
      onWebViewCreated: (controller) {
        _webViewController = controller;
        notifyListeners();
      },
      onLoadStart: (controller, url) {
        _onLoadStartController.add(url);
      },
      onLoadStop: (controller, url) {
        _onLoadStopController.add(url);
        if (!_webViewReady) {
          _webViewReady = true;
          notifyListeners();
        }
      },
      onProgressChanged: (controller, progress) {
        _onProgressChangedController.add(progress);
      },
      onPageCommitVisible: (controller, url) {
        _onPageCommitVisibleController.add(url);
      },
      onTitleChanged: (controller, title) {
        _onTitleChangedController.add(title);
      },
      onUpdateVisitedHistory: (controller, url, isReload) {
        _onUpdateVisitedHistoryController.add(url);
      },
    );
  }

  /// Initialize headless WebView for testing
  Future<void> initializeHeadlessWebView({
    String? initialUrl,
    double? width,
    double? height,
  }) async {
    if (_headlessWebView != null) {
      await disposeHeadlessWebView();
    }

    final completer = Completer<void>();

    _headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(initialUrl ?? _initialUrl)),
      initialSize: Size(width ?? 1920, height ?? 1080),
      onWebViewCreated: (controller) {
        _webViewController = controller;
        notifyListeners();
      },
      onLoadStart: (controller, url) {
        _onLoadStartController.add(url);
      },
      onLoadStop: (controller, url) {
        _onLoadStopController.add(url);
        if (!completer.isCompleted) {
          completer.complete();
        }
        if (!_webViewReady) {
          _webViewReady = true;
          notifyListeners();
        }
      },
      onProgressChanged: (controller, progress) {
        _onProgressChangedController.add(progress);
      },
      onPageCommitVisible: (controller, url) {
        _onPageCommitVisibleController.add(url);
      },
      onTitleChanged: (controller, title) {
        _onTitleChangedController.add(title);
      },
      onUpdateVisitedHistory: (controller, url, isReload) {
        _onUpdateVisitedHistoryController.add(url);
      },
    );

    await _headlessWebView!.run();

    // Wait for initial load or timeout
    await completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {},
    );

    _webViewReady = true;
    notifyListeners();
  }

  /// Dispose headless WebView
  Future<void> disposeHeadlessWebView() async {
    if (_headlessWebView != null) {
      await _headlessWebView!.dispose();
      _headlessWebView = null;
      _webViewController = null;
      _webViewReady = false;
      notifyListeners();
    }
  }

  /// Run tests from a custom configuration
  Future<void> runConfiguration(TestConfiguration config) async {
    _currentConfiguration = config;
    _webViewType = config.webViewType;

    // Get appropriate controller based on WebView type
    if (config.webViewType == TestWebViewType.headless) {
      // Always recreate headless WebView to ensure fresh state and correct size
      await initializeHeadlessWebView(
        initialUrl: config.initialUrl,
        width: config.headlessWidth,
        height: config.headlessHeight,
      );
    }

    // Run custom steps if any
    if (config.customSteps.isNotEmpty) {
      await _runCustomSteps(config.customSteps, _webViewController);
    }
  }

  /// Run tests using the current WebView state
  /// Call this after ensuring the WebView is ready
  Future<void> runConfigurationWithCurrentWebView(
    TestConfiguration config,
  ) async {
    _currentConfiguration = config;

    // Run custom steps if any
    if (config.customSteps.isNotEmpty) {
      await _runCustomSteps(config.customSteps, _webViewController);
    }
  }

  /// Run custom test steps
  Future<void> _runCustomSteps(
    List<CustomTestStep> steps,
    InAppWebViewController? controller,
  ) async {
    if (_status == TestStatus.running) return;

    _status = TestStatus.running;
    _shouldStop = false;
    _results = [];
    _progress = 0;
    _total = steps.length;
    _startTime = DateTime.now();
    _endTime = null;
    notifyListeners();

    for (var i = 0; i < steps.length; i++) {
      if (_shouldStop) {
        _status = TestStatus.paused;
        notifyListeners();
        break;
      }

      final step = steps[i];
      if (!step.enabled) {
        _results = [
          ..._results,
          ExtendedTestResult(
            testId: step.id,
            testTitle: step.name,
            category: _categoryFromString(step.category),
            success: true,
            message: 'Skipped - disabled',
            duration: Duration.zero,
            timestamp: DateTime.now(),
            skipped: true,
            skipReason: 'Step is disabled',
          ),
        ];
        continue;
      }

      _currentTest = step.name;
      _progress = i;
      notifyListeners();

      final result = await _executeCustomStep(step, controller);
      _results = [..._results, result];
      notifyListeners();

      // Small delay between steps
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _status = _shouldStop ? TestStatus.paused : TestStatus.completed;
    _currentTest = null;
    _progress = steps.length;
    _endTime = DateTime.now();
    _shouldStop = false;
    notifyListeners();
  }

  /// Execute a single custom test step
  Future<ExtendedTestResult> _executeCustomStep(
    CustomTestStep step,
    InAppWebViewController? controller,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      dynamic result;

      switch (step.action.type) {
        case CustomTestActionType.controllerMethod:
          result = await _executeControllerMethod(step.action, controller);
          break;
        case CustomTestActionType.evaluateJavascript:
          if (controller == null) throw Exception('Controller not available');
          result = await controller.evaluateJavascript(
            source: step.action.script ?? '',
          );
          break;
        case CustomTestActionType.loadUrl:
          if (controller == null) throw Exception('Controller not available');
          await controller.loadUrl(
            urlRequest: URLRequest(url: WebUri(step.action.url ?? '')),
          );
          result = 'URL loaded';
          break;
        case CustomTestActionType.loadHtml:
          if (controller == null) throw Exception('Controller not available');
          await controller.loadData(data: step.action.html ?? '');
          result = 'HTML loaded';
          break;
        case CustomTestActionType.checkUrl:
          if (controller == null) throw Exception('Controller not available');
          final currentUrl = await controller.getUrl();
          final matches = currentUrl?.toString() == step.action.url;
          result = matches ? 'URL matches' : 'URL mismatch: $currentUrl';
          if (!matches) throw Exception(result);
          break;
        case CustomTestActionType.checkTitle:
          if (controller == null) throw Exception('Controller not available');
          final title = await controller.getTitle();
          final matches = title == step.action.text;
          result = matches ? 'Title matches' : 'Title mismatch: $title';
          if (!matches) throw Exception(result);
          break;
        case CustomTestActionType.checkElement:
          if (controller == null) throw Exception('Controller not available');
          final exists = await controller.evaluateJavascript(
            source:
                'document.querySelector("${step.action.selector}") !== null',
          );
          if (exists != true && exists != 'true') {
            throw Exception('Element not found: ${step.action.selector}');
          }
          result = 'Element found';
          break;
        case CustomTestActionType.waitForElement:
          if (controller == null) throw Exception('Controller not available');
          final timeout = step.action.delayMs ?? 5000;
          final startWait = DateTime.now();
          bool found = false;
          while (DateTime.now().difference(startWait).inMilliseconds <
              timeout) {
            final exists = await controller.evaluateJavascript(
              source:
                  'document.querySelector("${step.action.selector}") !== null',
            );
            if (exists == true || exists == 'true') {
              found = true;
              break;
            }
            await Future.delayed(const Duration(milliseconds: 100));
          }
          if (!found) {
            throw Exception(
              'Element not found within ${timeout}ms: ${step.action.selector}',
            );
          }
          result = 'Element found';
          break;
        case CustomTestActionType.clickElement:
          if (controller == null) throw Exception('Controller not available');
          await controller.evaluateJavascript(
            source:
                'document.querySelector("${step.action.selector}")?.click()',
          );
          result = 'Clicked element';
          break;
        case CustomTestActionType.typeText:
          if (controller == null) throw Exception('Controller not available');
          await controller.evaluateJavascript(
            source:
                '''
              var el = document.querySelector("${step.action.selector}");
              if (el) { el.value = "${step.action.text}"; }
            ''',
          );
          result = 'Typed text';
          break;
        case CustomTestActionType.scrollTo:
          if (controller == null) throw Exception('Controller not available');
          await controller.scrollTo(
            x: step.action.x ?? 0,
            y: step.action.y ?? 0,
          );
          result = 'Scrolled to (${step.action.x}, ${step.action.y})';
          break;
        case CustomTestActionType.takeScreenshot:
          if (controller == null) throw Exception('Controller not available');
          final screenshot = await controller.takeScreenshot();
          result = screenshot != null
              ? 'Screenshot taken: ${screenshot.length} bytes'
              : 'Screenshot failed';
          break;
        case CustomTestActionType.delay:
          await Future.delayed(
            Duration(milliseconds: step.action.delayMs ?? 1000),
          );
          result = 'Delayed ${step.action.delayMs}ms';
          break;
        case CustomTestActionType.waitForNavigationEvent:
          result = await _executeWaitForNavigationEvent(
            step.action,
            controller,
          );
          break;
        case CustomTestActionType.custom:
          // Custom code execution would require eval or predefined functions
          result = 'Custom action executed';
          break;
      }

      stopwatch.stop();

      // Check expected result if specified
      if (step.expectedResult != null) {
        final resultStr = result?.toString() ?? '';
        if (!resultStr.contains(step.expectedResult!)) {
          return ExtendedTestResult(
            testId: step.id,
            testTitle: step.name,
            category: _categoryFromString(step.category),
            success: false,
            message: 'Expected "${step.expectedResult}" but got "$resultStr"',
            duration: stopwatch.elapsed,
            timestamp: DateTime.now(),
            data: {'result': result},
          );
        }
      }

      return ExtendedTestResult(
        testId: step.id,
        testTitle: step.name,
        category: _categoryFromString(step.category),
        success: true,
        message: result?.toString() ?? 'Success',
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
        data: {'result': result},
      );
    } catch (e, stackTrace) {
      stopwatch.stop();
      debugPrint('Custom step ${step.id} failed: $e');
      debugPrint('Stack trace: $stackTrace');

      return ExtendedTestResult(
        testId: step.id,
        testTitle: step.name,
        category: _categoryFromString(step.category),
        success: false,
        message: 'Error: $e',
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
        data: {'error': e.toString(), 'stackTrace': stackTrace.toString()},
      );
    }
  }

  /// Execute a controller method action
  Future<dynamic> _executeControllerMethod(
    CustomTestAction action,
    InAppWebViewController? controller,
  ) async {
    if (controller == null) {
      throw Exception('Controller not available');
    }

    final methodId = action.methodId;
    if (methodId == null) {
      throw Exception('Method ID not specified');
    }

    final method = ControllerMethodsRegistry.instance.findMethodById(methodId);
    if (method == null) {
      throw Exception('Method not found: $methodId');
    }

    // Merge default parameters with custom parameters
    final params = <String, dynamic>{
      ...method.parameters,
      if (action.methodParameters != null) ...action.methodParameters!,
    };

    return await method.execute(controller, params);
  }

  /// Execute a wait for navigation event action
  Future<String> _executeWaitForNavigationEvent(
    CustomTestAction action,
    InAppWebViewController? controller,
  ) async {
    if (controller == null) {
      throw Exception('Controller not available');
    }

    final event = action.navigationEvent;
    if (event == null) {
      throw Exception('Navigation event type not specified');
    }

    // Use broadcast streams to listen for the next event
    // .first will return the next value published to the stream
    switch (event) {
      case NavigationEventType.onLoadStop:
        final url = await _onLoadStopController.stream.first;
        return 'onLoadStop triggered - loaded: $url';

      case NavigationEventType.onLoadStart:
        final url = await _onLoadStartController.stream.first;
        return 'onLoadStart triggered - navigation started to $url';

      case NavigationEventType.onProgressChanged:
        _targetProgress = action.targetProgress ?? 100;
        _progressComparison =
            action.progressComparison ?? 'greaterThanOrEquals';
        // Filter the stream to only get progress values that match the condition
        final progress = await _onProgressChangedController.stream.firstWhere((
          progress,
        ) {
          switch (_progressComparison) {
            case 'equals':
              return progress == _targetProgress;
            case 'greaterThan':
              return progress > _targetProgress;
            case 'greaterThanOrEquals':
            default:
              return progress >= _targetProgress;
          }
        });
        return 'onProgressChanged reached $progress (target: $_progressComparison $_targetProgress)';

      case NavigationEventType.onPageCommitVisible:
        final url = await _onPageCommitVisibleController.stream.first;
        return 'onPageCommitVisible triggered - page visible: $url';

      case NavigationEventType.onTitleChanged:
        final title = await _onTitleChangedController.stream.first;
        return 'onTitleChanged triggered - title changed to: $title';

      case NavigationEventType.onUpdateVisitedHistory:
        final url = await _onUpdateVisitedHistoryController.stream.first;
        return 'onUpdateVisitedHistory triggered - URL changed to: $url';
    }
  }

  TestCategory _categoryFromString(String category) {
    return TestCategory.values.firstWhere(
      (c) => c.name.toLowerCase() == category.toLowerCase(),
      orElse: () => TestCategory.advanced,
    );
  }

  /// Run all tests for a specific category
  Future<void> runCategoryTests(TestCategory category) async {
    final categoryGroup = getTestCategories().firstWhere(
      (g) => g.category == category,
      orElse: () => throw Exception('Category not found'),
    );

    await _runTests(categoryGroup.tests, _webViewController);
  }

  /// Run all tests across all categories
  Future<void> runAllTests() async {
    final allTests = <ExecutableTestCase>[];
    for (final category in getTestCategories()) {
      allTests.addAll(category.tests);
    }
    await _runTests(allTests, _webViewController);
  }

  /// Run selected tests
  Future<void> runSelectedTests(List<ExecutableTestCase> tests) async {
    await _runTests(tests, _webViewController);
  }

  /// Run tests from selected categories
  Future<void> runSelectedCategories(List<TestCategory> categories) async {
    final tests = <ExecutableTestCase>[];
    for (final category in getTestCategories()) {
      if (categories.contains(category.category)) {
        tests.addAll(category.tests);
      }
    }
    await _runTests(tests, _webViewController);
  }

  /// Run a single test
  Future<ExtendedTestResult> runSingleTest(ExecutableTestCase testCase) async {
    _status = TestStatus.running;
    _currentTest = testCase.title;
    _progress = 0;
    _total = 1;
    _startTime = DateTime.now();
    notifyListeners();

    final result = await _executeTest(testCase, _webViewController);
    _results = [result];

    _status = TestStatus.completed;
    _currentTest = null;
    _progress = 1;
    _endTime = DateTime.now();
    notifyListeners();

    return result;
  }

  /// Re-run failed tests
  Future<void> rerunFailedTests() async {
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

    await _runTests(failedTests, _webViewController, append: true);
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

  /// Get all available test categories with their tests
  static List<TestCategoryGroup> getTestCategories() {
    return TestRunnerCatalog.getTestCategories();
  }
}
