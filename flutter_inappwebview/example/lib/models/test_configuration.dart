import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview_example/widgets/common/parameter_dialog.dart';
import 'package:flutter_inappwebview_example/utils/constants.dart';

/// Specifies which type of WebView to use for test execution
enum TestWebViewType {
  /// Use a visible InAppWebView widget for real-time rendering
  inAppWebView,

  /// Use a headless WebView for background execution
  headless,
}

/// Specifies how to match the expected result
enum ExpectedResultType {
  /// Exact string match
  exact,

  /// Contains the expected value (case-sensitive)
  contains,

  /// Contains the expected value (case-insensitive)
  containsIgnoreCase,

  /// Matches a regular expression pattern
  regex,

  /// Result is not null
  notNull,

  /// Result is null
  isNull,

  /// Result is truthy (not null, not false, not empty)
  truthy,

  /// Result is falsy (null, false, or empty)
  falsy,

  /// Result type matches (e.g., 'String', 'int', 'Map', 'List')
  typeIs,

  /// Result is a non-empty string
  notEmpty,

  /// Result is a Map with specific key
  hasKey,

  /// Result is a List with specific length
  lengthEquals,

  /// Result is a number greater than expected
  greaterThan,

  /// Result is a number less than expected
  lessThan,

  /// Custom JavaScript expression to validate (receives 'result' variable)
  customExpression,

  /// Any result is acceptable (no validation)
  any,
}

/// Represents a custom test step that can be defined by the user
class CustomTestStep {
  final String id;
  final String name;
  final String description;
  final TestCategory category;
  final CustomTestAction action;
  final Map<String, dynamic> parameters;

  /// The expected result value (interpretation depends on expectedResultType)
  final String? expectedResult;

  /// How to match/validate the expected result
  final ExpectedResultType expectedResultType;

  final bool enabled;
  final int order;

  const CustomTestStep({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.action,
    this.parameters = const {},
    this.expectedResult,
    this.expectedResultType = ExpectedResultType.any,
    this.enabled = true,
    this.order = 0,
  });

  CustomTestStep copyWith({
    String? id,
    String? name,
    String? description,
    TestCategory? category,
    CustomTestAction? action,
    Map<String, dynamic>? parameters,
    String? expectedResult,
    ExpectedResultType? expectedResultType,
    bool? enabled,
    int? order,
  }) {
    return CustomTestStep(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      action: action ?? this.action,
      parameters: parameters ?? this.parameters,
      expectedResult: expectedResult ?? this.expectedResult,
      expectedResultType: expectedResultType ?? this.expectedResultType,
      enabled: enabled ?? this.enabled,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'action': action.toJson(),
      'parameters': parameters,
      'expectedResult': expectedResult,
      'expectedResultType': expectedResultType.name,
      'enabled': enabled,
      'order': order,
    };
  }

  factory CustomTestStep.fromJson(Map<String, dynamic> json) {
    return CustomTestStep(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: TestCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => TestCategory.advanced,
      ),
      action: CustomTestAction.fromJson(json['action'] as Map<String, dynamic>),
      parameters: (json['parameters'] as Map<String, dynamic>?) ?? {},
      expectedResult: json['expectedResult'] as String?,
      expectedResultType: ExpectedResultType.values.firstWhere(
        (e) => e.name == json['expectedResultType'],
        orElse: () => ExpectedResultType.any,
      ),
      enabled: json['enabled'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
    );
  }

  /// Validates a result against the expected result configuration
  bool validateResult(dynamic result) {
    switch (expectedResultType) {
      case ExpectedResultType.any:
        return true;
      case ExpectedResultType.exact:
        return result?.toString() == expectedResult;
      case ExpectedResultType.contains:
        return result?.toString().contains(expectedResult ?? '') ?? false;
      case ExpectedResultType.containsIgnoreCase:
        return result?.toString().toLowerCase().contains(
              (expectedResult ?? '').toLowerCase(),
            ) ??
            false;
      case ExpectedResultType.regex:
        if (expectedResult == null) return false;
        try {
          return RegExp(expectedResult!).hasMatch(result?.toString() ?? '');
        } catch (_) {
          return false;
        }
      case ExpectedResultType.notNull:
        return result != null;
      case ExpectedResultType.isNull:
        return result == null;
      case ExpectedResultType.truthy:
        if (result == null) return false;
        if (result is bool) return result;
        if (result is String) return result.isNotEmpty;
        if (result is num) return result != 0;
        if (result is List) return result.isNotEmpty;
        if (result is Map) return result.isNotEmpty;
        return true;
      case ExpectedResultType.falsy:
        if (result == null) return true;
        if (result is bool) return !result;
        if (result is String) return result.isEmpty;
        if (result is num) return result == 0;
        if (result is List) return result.isEmpty;
        if (result is Map) return result.isEmpty;
        return false;
      case ExpectedResultType.typeIs:
        if (expectedResult == null) return false;
        final typeName = result.runtimeType.toString();
        return typeName == expectedResult ||
            typeName.startsWith('${expectedResult}<') ||
            _matchesSimpleType(result, expectedResult!);
      case ExpectedResultType.notEmpty:
        if (result == null) return false;
        if (result is String) return result.isNotEmpty;
        if (result is List) return result.isNotEmpty;
        if (result is Map) return result.isNotEmpty;
        return true;
      case ExpectedResultType.hasKey:
        if (result is! Map || expectedResult == null) return false;
        return result.containsKey(expectedResult);
      case ExpectedResultType.lengthEquals:
        if (expectedResult == null) return false;
        final expectedLength = int.tryParse(expectedResult!);
        if (expectedLength == null) return false;
        if (result is List) return result.length == expectedLength;
        if (result is String) return result.length == expectedLength;
        if (result is Map) return result.length == expectedLength;
        return false;
      case ExpectedResultType.greaterThan:
        if (expectedResult == null) return false;
        final expectedNum = num.tryParse(expectedResult!);
        if (expectedNum == null || result is! num) return false;
        return result > expectedNum;
      case ExpectedResultType.lessThan:
        if (expectedResult == null) return false;
        final expectedNum = num.tryParse(expectedResult!);
        if (expectedNum == null || result is! num) return false;
        return result < expectedNum;
      case ExpectedResultType.customExpression:
        // Custom expressions should be handled by the test runner with JavaScript
        return true;
    }
  }

  /// Helper to match simple type names
  static bool _matchesSimpleType(dynamic value, String typeName) {
    switch (typeName.toLowerCase()) {
      case 'string':
        return value is String;
      case 'int':
      case 'integer':
        return value is int;
      case 'double':
      case 'float':
        return value is double;
      case 'num':
      case 'number':
        return value is num;
      case 'bool':
      case 'boolean':
        return value is bool;
      case 'list':
      case 'array':
        return value is List;
      case 'map':
      case 'object':
        return value is Map;
      default:
        return false;
    }
  }
}

/// Types of actions that can be performed in a custom test
enum CustomTestActionType {
  evaluateJavascript,
  loadUrl,
  loadHtml,
  checkUrl,
  checkTitle,
  checkElement,
  waitForElement,
  clickElement,
  typeText,
  scrollTo,
  takeScreenshot,
  delay,

  /// Wait for a specific navigation event (onLoadStop, onProgressChanged, etc.)
  waitForNavigationEvent,

  /// Execute an InAppWebViewController method
  controllerMethod,
  custom,
}

/// Navigation events that can be waited for
enum NavigationEventType {
  /// Wait for onLoadStop to fire
  onLoadStop,

  /// Wait for onLoadStart to fire
  onLoadStart,

  /// Wait for onProgressChanged to reach a specific value
  onProgressChanged,

  /// Wait for onPageCommitVisible to fire
  onPageCommitVisible,

  /// Wait for onTitleChanged to fire
  onTitleChanged,

  /// Wait for onUpdateVisitedHistory to fire
  onUpdateVisitedHistory,
}

/// Represents an action to perform in a custom test
class CustomTestAction {
  final CustomTestActionType type;
  final String? script;
  final String? url;
  final String? html;
  final String? selector;
  final String? text;
  final int? x;
  final int? y;
  final int? delayMs;
  final String? customCode;

  /// For controllerMethod action type - the method ID from ControllerMethodsRegistry
  final String? methodId;

  /// For controllerMethod action type - the method parameters
  final Map<String, dynamic>? methodParameters;

  /// For waitForNavigationEvent action type - the navigation event to wait for
  final NavigationEventType? navigationEvent;

  /// For waitForNavigationEvent with onProgressChanged - the target progress value (0-100)
  final int? targetProgress;

  /// For waitForNavigationEvent - comparison operator for progress ('equals', 'greaterThan', 'greaterThanOrEquals')
  final String? progressComparison;

  /// For waitForNavigationEvent - optional URL pattern to match (regex or contains)
  final String? urlPattern;

  const CustomTestAction({
    required this.type,
    this.script,
    this.url,
    this.html,
    this.selector,
    this.text,
    this.x,
    this.y,
    this.delayMs,
    this.customCode,
    this.methodId,
    this.methodParameters,
    this.navigationEvent,
    this.targetProgress,
    this.progressComparison,
    this.urlPattern,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'script': script,
      'url': url,
      'html': html,
      'selector': selector,
      'text': text,
      'x': x,
      'y': y,
      'delayMs': delayMs,
      'customCode': customCode,
      'methodId': methodId,
      'methodParameters': _sanitizeParameters(methodParameters),
      'navigationEvent': navigationEvent?.name,
      'targetProgress': targetProgress,
      'progressComparison': progressComparison,
      'urlPattern': urlPattern,
    };
  }

  /// Sanitizes parameters for JSON serialization by converting non-JSON-serializable
  /// objects to their string representation or null
  static Map<String, dynamic>? _sanitizeParameters(
    Map<String, dynamic>? params,
  ) {
    if (params == null) return null;
    final sanitized = <String, dynamic>{};
    for (final entry in params.entries) {
      sanitized[entry.key] = _sanitizeValue(entry.value);
    }
    return sanitized;
  }

  /// Sanitizes a single value for JSON serialization
  static dynamic _sanitizeValue(dynamic value) {
    if (value == null) return null;
    if (value is String || value is num || value is bool) return value;
    if (value is Uint8List) {
      // Encode Uint8List as base64 with type marker
      return {'_type': 'bytes', 'value': base64.encode(value)};
    }
    if (value is ParameterValueHint) {
      // Extract the underlying value from ParameterValueHint
      // If the underlying value is null, just return null
      final innerValue = value.value;
      if (innerValue == null) return null;
      return _sanitizeValue(innerValue);
    }
    if (value is List) return value.map(_sanitizeValue).toList();
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _sanitizeValue(v)));
    }
    // For non-JSON-serializable objects, convert to string or return null
    try {
      // Check if the object has a toJson method
      if (value is Map<String, dynamic>) return value;
      return value.toString();
    } catch (_) {
      return null;
    }
  }

  /// Deserializes a parameter value, converting special markers back to their original types
  static dynamic _deserializeValue(dynamic value) {
    if (value == null) return null;
    if (value is String || value is num || value is bool) return value;
    if (value is List) return value.map(_deserializeValue).toList();
    if (value is Map) {
      // Check for special type markers
      if (value['_type'] == 'bytes' && value['value'] is String) {
        try {
          return base64.decode(value['value'] as String);
        } catch (_) {
          return null;
        }
      }
      // Regular map - recurse into values
      return value.map((k, v) => MapEntry(k.toString(), _deserializeValue(v)));
    }
    return value;
  }

  /// Deserializes method parameters from JSON
  static Map<String, dynamic>? _deserializeParameters(
    Map<String, dynamic>? params,
  ) {
    if (params == null) return null;
    final result = <String, dynamic>{};
    for (final entry in params.entries) {
      result[entry.key] = _deserializeValue(entry.value);
    }
    return result;
  }

  factory CustomTestAction.fromJson(Map<String, dynamic> json) {
    return CustomTestAction(
      type: CustomTestActionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CustomTestActionType.custom,
      ),
      script: json['script'] as String?,
      url: json['url'] as String?,
      html: json['html'] as String?,
      selector: json['selector'] as String?,
      text: json['text'] as String?,
      x: json['x'] as int?,
      y: json['y'] as int?,
      delayMs: json['delayMs'] as int?,
      customCode: json['customCode'] as String?,
      methodId: json['methodId'] as String?,
      methodParameters: _deserializeParameters(
        json['methodParameters'] as Map<String, dynamic>?,
      ),
      navigationEvent: json['navigationEvent'] != null
          ? NavigationEventType.values.firstWhere(
              (e) => e.name == json['navigationEvent'],
              orElse: () => NavigationEventType.onLoadStop,
            )
          : null,
      targetProgress: json['targetProgress'] as int?,
      progressComparison: json['progressComparison'] as String?,
      urlPattern: json['urlPattern'] as String?,
    );
  }

  /// Creates an evaluate JavaScript action
  factory CustomTestAction.evaluateJs(String script) {
    return CustomTestAction(
      type: CustomTestActionType.evaluateJavascript,
      script: script,
    );
  }

  /// Creates a load URL action
  factory CustomTestAction.loadUrl(String url) {
    return CustomTestAction(type: CustomTestActionType.loadUrl, url: url);
  }

  /// Creates a load HTML action
  factory CustomTestAction.loadHtml(String html) {
    return CustomTestAction(type: CustomTestActionType.loadHtml, html: html);
  }

  /// Creates a check URL action
  factory CustomTestAction.checkUrl(String expectedUrl) {
    return CustomTestAction(
      type: CustomTestActionType.checkUrl,
      url: expectedUrl,
    );
  }

  /// Creates a check title action
  factory CustomTestAction.checkTitle(String expectedTitle) {
    return CustomTestAction(
      type: CustomTestActionType.checkTitle,
      text: expectedTitle,
    );
  }

  /// Creates a check element action
  factory CustomTestAction.checkElement(String selector) {
    return CustomTestAction(
      type: CustomTestActionType.checkElement,
      selector: selector,
    );
  }

  /// Creates a wait for element action
  factory CustomTestAction.waitForElement(
    String selector, {
    int timeoutMs = 5000,
  }) {
    return CustomTestAction(
      type: CustomTestActionType.waitForElement,
      selector: selector,
      delayMs: timeoutMs,
    );
  }

  /// Creates a click element action
  factory CustomTestAction.clickElement(String selector) {
    return CustomTestAction(
      type: CustomTestActionType.clickElement,
      selector: selector,
    );
  }

  /// Creates a type text action
  factory CustomTestAction.typeText(String selector, String text) {
    return CustomTestAction(
      type: CustomTestActionType.typeText,
      selector: selector,
      text: text,
    );
  }

  /// Creates a scroll to action
  factory CustomTestAction.scrollTo(int x, int y) {
    return CustomTestAction(type: CustomTestActionType.scrollTo, x: x, y: y);
  }

  /// Creates a delay action
  factory CustomTestAction.delay(int milliseconds) {
    return CustomTestAction(
      type: CustomTestActionType.delay,
      delayMs: milliseconds,
    );
  }

  /// Creates a wait for navigation event action
  factory CustomTestAction.waitForNavigationEvent(
    NavigationEventType event, {
    int? targetProgress,
    String? progressComparison,
    String? urlPattern,
  }) {
    return CustomTestAction(
      type: CustomTestActionType.waitForNavigationEvent,
      navigationEvent: event,
      targetProgress: targetProgress,
      progressComparison: progressComparison,
      urlPattern: urlPattern,
    );
  }

  /// Creates a controller method action to execute an InAppWebViewController method
  factory CustomTestAction.controllerMethod(
    String methodId, {
    Map<String, dynamic>? parameters,
  }) {
    return CustomTestAction(
      type: CustomTestActionType.controllerMethod,
      methodId: methodId,
      methodParameters: parameters,
    );
  }
}

/// Represents a complete test configuration that can be saved and loaded
class TestConfiguration {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final List<CustomTestStep> customSteps;
  final Map<String, List<String>> testOrdering; // category -> list of test IDs
  final Set<String> enabledBuiltInTests;
  final Map<String, dynamic> metadata;

  /// The type of WebView to use for test execution
  final TestWebViewType webViewType;

  /// Initial URL to load before running tests (optional)
  final String? initialUrl;

  /// Width of the headless WebView in pixels (default: 1920)
  final double headlessWidth;

  /// Height of the headless WebView in pixels (default: 1080)
  final double headlessHeight;

  const TestConfiguration({
    required this.id,
    required this.name,
    this.description = '',
    required this.createdAt,
    required this.modifiedAt,
    this.customSteps = const [],
    this.testOrdering = const {},
    this.enabledBuiltInTests = const {},
    this.metadata = const {},
    this.webViewType = TestWebViewType.inAppWebView,
    this.initialUrl,
    this.headlessWidth = 1920,
    this.headlessHeight = 1080,
  });

  TestConfiguration copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<CustomTestStep>? customSteps,
    Map<String, List<String>>? testOrdering,
    Set<String>? enabledBuiltInTests,
    Map<String, dynamic>? metadata,
    TestWebViewType? webViewType,
    String? initialUrl,
    double? headlessWidth,
    double? headlessHeight,
  }) {
    return TestConfiguration(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
      customSteps: customSteps ?? this.customSteps,
      testOrdering: testOrdering ?? this.testOrdering,
      enabledBuiltInTests: enabledBuiltInTests ?? this.enabledBuiltInTests,
      metadata: metadata ?? this.metadata,
      webViewType: webViewType ?? this.webViewType,
      initialUrl: initialUrl ?? this.initialUrl,
      headlessWidth: headlessWidth ?? this.headlessWidth,
      headlessHeight: headlessHeight ?? this.headlessHeight,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'customSteps': customSteps.map((s) => s.toJson()).toList(),
      'testOrdering': testOrdering,
      'enabledBuiltInTests': enabledBuiltInTests.toList(),
      'metadata': metadata,
      'webViewType': webViewType.name,
      'initialUrl': initialUrl,
      'headlessWidth': headlessWidth,
      'headlessHeight': headlessHeight,
    };
  }

  factory TestConfiguration.fromJson(Map<String, dynamic> json) {
    return TestConfiguration(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      customSteps:
          (json['customSteps'] as List<dynamic>?)
              ?.map((s) => CustomTestStep.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      testOrdering:
          (json['testOrdering'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as List<dynamic>).cast<String>()),
          ) ??
          {},
      enabledBuiltInTests:
          (json['enabledBuiltInTests'] as List<dynamic>?)
              ?.cast<String>()
              .toSet() ??
          {},
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
      webViewType: TestWebViewType.values.firstWhere(
        (e) => e.name == json['webViewType'],
        orElse: () => TestWebViewType.inAppWebView,
      ),
      initialUrl: json['initialUrl'] as String?,
      headlessWidth: (json['headlessWidth'] as num?)?.toDouble() ?? 1920,
      headlessHeight: (json['headlessHeight'] as num?)?.toDouble() ?? 1080,
    );
  }

  /// Creates an empty default configuration
  factory TestConfiguration.empty({String? name}) {
    final now = DateTime.now();
    return TestConfiguration(
      id: 'config_${now.millisecondsSinceEpoch}',
      name: name ?? 'Default Configuration',
      createdAt: now,
      modifiedAt: now,
    );
  }

  /// Creates a default configuration with common test steps
  factory TestConfiguration.defaultConfig() {
    final now = DateTime.now();
    return TestConfiguration(
      id: 'default_config',
      name: 'Default Test Configuration',
      description: 'Default configuration with common test scenarios',
      createdAt: now,
      modifiedAt: now,
      customSteps: _buildDefaultTestSteps(),
      webViewType: TestWebViewType.inAppWebView,
      initialUrl: 'https://example.com',
    );
  }

  /// Build default test steps covering common scenarios
  static List<CustomTestStep> _buildDefaultTestSteps() {
    int order = 0;
    return [
      // ============================================================
      // NAVIGATION TESTS
      // ============================================================
      CustomTestStep(
        id: 'nav_load_url',
        name: 'Load URL',
        description: 'Load a test URL and verify navigation',
        category: TestCategory.navigation,
        action: CustomTestAction.controllerMethod(
          'loadUrl',
          parameters: {'url': 'https://example.com'},
        ),
        order: order++,
      ),
      CustomTestStep(
        id: 'nav_get_url',
        name: 'Get Current URL',
        description: 'Retrieve and verify the current URL',
        category: TestCategory.navigation,
        action: CustomTestAction.controllerMethod('getUrl'),
        expectedResultType: ExpectedResultType.notNull,
        order: order++,
      ),
      CustomTestStep(
        id: 'nav_load_data',
        name: 'Load HTML Data',
        description: 'Load HTML content directly into WebView',
        category: TestCategory.navigation,
        action: CustomTestAction.controllerMethod(
          'loadData',
          parameters: {
            'data': '<html><body><h1 id="test">Test Page</h1></body></html>',
            'mimeType': 'text/html',
            'encoding': 'utf-8',
            'baseUrl': 'https://example.com',
          },
        ),
        order: order++,
      ),
      CustomTestStep(
        id: 'nav_reload',
        name: 'Reload Page',
        description: 'Reload the current page',
        category: TestCategory.navigation,
        action: CustomTestAction.controllerMethod('reload'),
        order: order++,
      ),
      CustomTestStep(
        id: 'nav_can_go_back',
        name: 'Can Go Back',
        description: 'Check if navigation history allows going back',
        category: TestCategory.navigation,
        action: CustomTestAction.controllerMethod('canGoBack'),
        expectedResultType: ExpectedResultType.notNull,
        order: order++,
      ),
      CustomTestStep(
        id: 'nav_can_go_forward',
        name: 'Can Go Forward',
        description: 'Check if navigation history allows going forward',
        category: TestCategory.navigation,
        action: CustomTestAction.controllerMethod('canGoForward'),
        expectedResultType: ExpectedResultType.notNull,
        order: order++,
      ),
      CustomTestStep(
        id: 'nav_go_back',
        name: 'Go Back',
        description: 'Navigate back in history',
        category: TestCategory.navigation,
        action: CustomTestAction.controllerMethod('goBack'),
        order: order++,
      ),
      CustomTestStep(
        id: 'nav_go_forward',
        name: 'Go Forward',
        description: 'Navigate forward in history',
        category: TestCategory.navigation,
        action: CustomTestAction.controllerMethod('goForward'),
        order: order++,
      ),
      CustomTestStep(
        id: 'nav_stop_loading',
        name: 'Stop Loading',
        description: 'Stop the current page loading',
        category: TestCategory.navigation,
        action: CustomTestAction.controllerMethod('stopLoading'),
        order: order++,
      ),

      // ============================================================
      // CONTENT/PAGE INFO TESTS
      // ============================================================
      CustomTestStep(
        id: 'content_get_title',
        name: 'Get Page Title',
        description: 'Retrieve the current page title',
        category: TestCategory.content,
        action: CustomTestAction.controllerMethod('getTitle'),
        order: order++,
      ),
      CustomTestStep(
        id: 'content_get_html',
        name: 'Get HTML Source',
        description: 'Retrieve the page HTML source',
        category: TestCategory.content,
        action: CustomTestAction.controllerMethod('getHtml'),
        expectedResultType: ExpectedResultType.notEmpty,
        order: order++,
      ),
      CustomTestStep(
        id: 'content_get_progress',
        name: 'Get Loading Progress',
        description: 'Get the current page loading progress',
        category: TestCategory.content,
        action: CustomTestAction.controllerMethod('getProgress'),
        expectedResultType: ExpectedResultType.notNull,
        order: order++,
      ),
      CustomTestStep(
        id: 'content_get_favicons',
        name: 'Get Favicons',
        description: 'Get page favicon URLs',
        category: TestCategory.content,
        action: CustomTestAction.controllerMethod('getFavicons'),
        order: order++,
      ),
      CustomTestStep(
        id: 'content_get_original_url',
        name: 'Get Original URL',
        description: 'Get the original URL before any redirects',
        category: TestCategory.content,
        action: CustomTestAction.controllerMethod('getOriginalUrl'),
        order: order++,
      ),

      // ============================================================
      // JAVASCRIPT TESTS
      // ============================================================
      CustomTestStep(
        id: 'js_evaluate_simple',
        name: 'Evaluate Simple JS',
        description: 'Execute simple JavaScript expression',
        category: TestCategory.javascript,
        action: CustomTestAction.controllerMethod(
          'evaluateJavascript',
          parameters: {'source': '1 + 1'},
        ),
        expectedResult: '2',
        expectedResultType: ExpectedResultType.contains,
        order: order++,
      ),
      CustomTestStep(
        id: 'js_evaluate_string',
        name: 'Evaluate JS String',
        description: 'Execute JavaScript returning a string',
        category: TestCategory.javascript,
        action: CustomTestAction.controllerMethod(
          'evaluateJavascript',
          parameters: {'source': '"Hello" + " " + "World"'},
        ),
        expectedResult: 'Hello World',
        expectedResultType: ExpectedResultType.exact,
        order: order++,
      ),
      CustomTestStep(
        id: 'js_evaluate_document_title',
        name: 'Get Document Title via JS',
        description: 'Execute JavaScript to get document title',
        category: TestCategory.javascript,
        action: CustomTestAction.controllerMethod(
          'evaluateJavascript',
          parameters: {'source': 'document.title'},
        ),
        order: order++,
      ),
      CustomTestStep(
        id: 'js_evaluate_object',
        name: 'Evaluate JS Object',
        description: 'Execute JavaScript returning an object',
        category: TestCategory.javascript,
        action: CustomTestAction.controllerMethod(
          'evaluateJavascript',
          parameters: {'source': 'JSON.stringify({name: "test", value: 42})'},
        ),
        expectedResultType: ExpectedResultType.notEmpty,
        order: order++,
      ),
      CustomTestStep(
        id: 'js_call_async',
        name: 'Call Async JavaScript',
        description: 'Execute async JavaScript with await',
        category: TestCategory.javascript,
        action: CustomTestAction.controllerMethod(
          'callAsyncJavaScript',
          parameters: {
            'functionBody': '''
              await new Promise(resolve => setTimeout(resolve, 100));
              return "async result";
            ''',
          },
        ),
        order: order++,
      ),
      CustomTestStep(
        id: 'js_inject_css',
        name: 'Inject CSS Code',
        description: 'Inject CSS styles into the page',
        category: TestCategory.javascript,
        action: CustomTestAction.controllerMethod(
          'injectCSSCode',
          parameters: {
            'source': 'body { background-color: #f0f0f0 !important; }',
          },
        ),
        order: order++,
      ),

      // ============================================================
      // SCROLL TESTS
      // ============================================================
      CustomTestStep(
        id: 'scroll_to',
        name: 'Scroll To Position',
        description: 'Scroll to a specific position',
        category: TestCategory.advanced,
        action: CustomTestAction.controllerMethod(
          'scrollTo',
          parameters: {'x': 0, 'y': 100},
        ),
        order: order++,
      ),
      CustomTestStep(
        id: 'scroll_by',
        name: 'Scroll By Offset',
        description: 'Scroll by a relative offset',
        category: TestCategory.advanced,
        action: CustomTestAction.controllerMethod(
          'scrollBy',
          parameters: {'x': 0, 'y': 50},
        ),
        order: order++,
      ),
      CustomTestStep(
        id: 'scroll_get_x',
        name: 'Get Scroll X',
        description: 'Get horizontal scroll position',
        category: TestCategory.advanced,
        action: CustomTestAction.controllerMethod('getScrollX'),
        expectedResultType: ExpectedResultType.notNull,
        order: order++,
      ),
      CustomTestStep(
        id: 'scroll_get_y',
        name: 'Get Scroll Y',
        description: 'Get vertical scroll position',
        category: TestCategory.advanced,
        action: CustomTestAction.controllerMethod('getScrollY'),
        expectedResultType: ExpectedResultType.notNull,
        order: order++,
      ),

      // ============================================================
      // SCREENSHOT & PRINT TESTS
      // ============================================================
      CustomTestStep(
        id: 'screenshot_take',
        name: 'Take Screenshot',
        description: 'Capture a screenshot of the WebView',
        category: TestCategory.advanced,
        action: CustomTestAction.controllerMethod('takeScreenshot'),
        expectedResultType: ExpectedResultType.notNull,
        order: order++,
      ),

      // ============================================================
      // SECURITY TESTS
      // ============================================================
      CustomTestStep(
        id: 'security_is_secure_context',
        name: 'Check Secure Context',
        description: 'Verify if the page is in a secure context (HTTPS)',
        category: TestCategory.advanced,
        action: CustomTestAction.controllerMethod('isSecureContext'),
        expectedResultType: ExpectedResultType.notNull,
        order: order++,
      ),
      CustomTestStep(
        id: 'security_get_certificate',
        name: 'Get SSL Certificate',
        description: 'Retrieve SSL certificate information',
        category: TestCategory.advanced,
        action: CustomTestAction.controllerMethod('getCertificate'),
        order: order++,
      ),

      // ============================================================
      // STORAGE TESTS - COOKIES
      // ============================================================
      CustomTestStep(
        id: 'storage_set_cookie',
        name: 'Set Cookie',
        description: 'Set a test cookie',
        category: TestCategory.storage,
        action: CustomTestAction.evaluateJs('''
          document.cookie = "test_cookie=test_value; path=/";
          document.cookie;
        '''),
        expectedResultType: ExpectedResultType.contains,
        expectedResult: 'test_cookie',
        order: order++,
      ),
      CustomTestStep(
        id: 'storage_get_cookies',
        name: 'Get Cookies via JS',
        description: 'Retrieve cookies using JavaScript',
        category: TestCategory.storage,
        action: CustomTestAction.evaluateJs('document.cookie'),
        order: order++,
      ),

      // ============================================================
      // STORAGE TESTS - LOCAL STORAGE
      // ============================================================
      CustomTestStep(
        id: 'storage_local_set',
        name: 'LocalStorage Set Item',
        description: 'Set an item in localStorage',
        category: TestCategory.storage,
        action: CustomTestAction.evaluateJs('''
          localStorage.setItem("test_key", "test_value");
          localStorage.getItem("test_key");
        '''),
        expectedResult: 'test_value',
        expectedResultType: ExpectedResultType.exact,
        order: order++,
      ),
      CustomTestStep(
        id: 'storage_local_get',
        name: 'LocalStorage Get Item',
        description: 'Get an item from localStorage',
        category: TestCategory.storage,
        action: CustomTestAction.evaluateJs('localStorage.getItem("test_key")'),
        order: order++,
      ),
      CustomTestStep(
        id: 'storage_local_remove',
        name: 'LocalStorage Remove Item',
        description: 'Remove an item from localStorage',
        category: TestCategory.storage,
        action: CustomTestAction.evaluateJs('''
          localStorage.removeItem("test_key");
          localStorage.getItem("test_key");
        '''),
        expectedResultType: ExpectedResultType.isNull,
        order: order++,
      ),

      // ============================================================
      // STORAGE TESTS - SESSION STORAGE
      // ============================================================
      CustomTestStep(
        id: 'storage_session_set',
        name: 'SessionStorage Set Item',
        description: 'Set an item in sessionStorage',
        category: TestCategory.storage,
        action: CustomTestAction.evaluateJs('''
          sessionStorage.setItem("session_key", "session_value");
          sessionStorage.getItem("session_key");
        '''),
        expectedResult: 'session_value',
        expectedResultType: ExpectedResultType.exact,
        order: order++,
      ),
      CustomTestStep(
        id: 'storage_session_get',
        name: 'SessionStorage Get Item',
        description: 'Get an item from sessionStorage',
        category: TestCategory.storage,
        action: CustomTestAction.evaluateJs(
          'sessionStorage.getItem("session_key")',
        ),
        order: order++,
      ),

      // ============================================================
      // CONTENT SIZE & ZOOM TESTS
      // ============================================================
      CustomTestStep(
        id: 'content_height',
        name: 'Get Content Height',
        description: 'Get the content height of the page',
        category: TestCategory.content,
        action: CustomTestAction.controllerMethod('getContentHeight'),
        order: order++,
      ),
      CustomTestStep(
        id: 'content_width',
        name: 'Get Content Width',
        description: 'Get the content width of the page',
        category: TestCategory.content,
        action: CustomTestAction.controllerMethod('getContentWidth'),
        order: order++,
      ),
      CustomTestStep(
        id: 'zoom_get_scale',
        name: 'Get Zoom Scale',
        description: 'Get the current zoom scale',
        category: TestCategory.advanced,
        action: CustomTestAction.controllerMethod('getZoomScale'),
        order: order++,
      ),
      CustomTestStep(
        id: 'zoom_set_scale',
        name: 'Set Zoom Scale',
        description: 'Set the zoom scale to 1.0',
        category: TestCategory.advanced,
        action: CustomTestAction.controllerMethod(
          'zoomBy',
          parameters: {'zoomFactor': 1.0},
        ),
        order: order++,
      ),

      // ============================================================
      // DOM ELEMENT TESTS
      // ============================================================
      CustomTestStep(
        id: 'dom_check_element',
        name: 'Check Element Exists',
        description: 'Check if body element exists',
        category: TestCategory.content,
        action: CustomTestAction.checkElement('body'),
        order: order++,
      ),

      // ============================================================
      // FIND INTERACTION TESTS
      // ============================================================
    ];
  }

  /// Export configuration as formatted JSON string
  String toJsonString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  /// Import configuration from JSON string
  static TestConfiguration fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return TestConfiguration.fromJson(json);
  }
}

/// Provider for managing test configurations with persistence
class TestConfigurationManager extends ChangeNotifier {
  static const String _savedConfigsKey = 'test_saved_configs';
  static const String _currentConfigKey = 'test_current_config';

  SharedPreferences? _prefs;
  TestConfiguration _currentConfig = TestConfiguration.empty();
  List<TestConfiguration> _savedConfigs = [];
  bool _isLoading = true;

  TestConfiguration get currentConfig => _currentConfig;
  List<TestConfiguration> get savedConfigs => List.unmodifiable(_savedConfigs);
  bool get isLoading => _isLoading;

  /// Initialize the configuration manager and load persisted data
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSavedConfigs();
    await _loadCurrentConfig();
    _isLoading = false;
    notifyListeners();
  }

  /// Load saved configurations from SharedPreferences
  Future<void> _loadSavedConfigs() async {
    final configsJson = _prefs?.getStringList(_savedConfigsKey);
    if (configsJson != null) {
      _savedConfigs = configsJson
          .map((json) {
            try {
              return TestConfiguration.fromJsonString(json);
            } catch (e) {
              debugPrint('Failed to parse saved config: $e');
              return null;
            }
          })
          .whereType<TestConfiguration>()
          .toList();
    }
  }

  /// Load current configuration from SharedPreferences
  Future<void> _loadCurrentConfig() async {
    final configJson = _prefs?.getString(_currentConfigKey);
    if (configJson != null) {
      try {
        _currentConfig = TestConfiguration.fromJsonString(configJson);
      } catch (e) {
        debugPrint('Failed to parse current config: $e');
        _currentConfig = TestConfiguration.empty();
      }
    }
  }

  /// Save configurations to SharedPreferences
  Future<void> _saveConfigs() async {
    final configsJson = _savedConfigs.map((c) => c.toJsonString()).toList();
    await _prefs?.setStringList(_savedConfigsKey, configsJson);
    await _prefs?.setString(_currentConfigKey, _currentConfig.toJsonString());
  }

  /// Set the WebView type
  void setWebViewType(TestWebViewType type) {
    _currentConfig = _currentConfig.copyWith(webViewType: type);
    _saveConfigs();
    notifyListeners();
  }

  /// Set the initial URL
  void setInitialUrl(String? url) {
    _currentConfig = _currentConfig.copyWith(initialUrl: url);
    _saveConfigs();
    notifyListeners();
  }

  /// Set the headless WebView size
  void setHeadlessSize(double width, double height) {
    _currentConfig = _currentConfig.copyWith(
      headlessWidth: width,
      headlessHeight: height,
    );
    _saveConfigs();
    notifyListeners();
  }

  /// Add a custom test step
  void addCustomStep(CustomTestStep step) {
    final newSteps = [..._currentConfig.customSteps, step];
    _currentConfig = _currentConfig.copyWith(customSteps: newSteps);
    _saveConfigs();
    notifyListeners();
  }

  /// Update a custom test step
  void updateCustomStep(String stepId, CustomTestStep updatedStep) {
    final newSteps = _currentConfig.customSteps.map((s) {
      return s.id == stepId ? updatedStep : s;
    }).toList();
    _currentConfig = _currentConfig.copyWith(customSteps: newSteps);
    _saveConfigs();
    notifyListeners();
  }

  /// Remove a custom test step
  void removeCustomStep(String stepId) {
    final newSteps = _currentConfig.customSteps
        .where((s) => s.id != stepId)
        .toList();
    _currentConfig = _currentConfig.copyWith(customSteps: newSteps);
    _saveConfigs();
    notifyListeners();
  }

  /// Reorder custom test steps
  void reorderCustomSteps(int oldIndex, int newIndex) {
    final steps = [..._currentConfig.customSteps];
    if (newIndex > oldIndex) newIndex--;
    final step = steps.removeAt(oldIndex);
    steps.insert(newIndex, step);

    // Update order values
    final updatedSteps = steps.asMap().entries.map((e) {
      return e.value.copyWith(order: e.key);
    }).toList();

    _currentConfig = _currentConfig.copyWith(customSteps: updatedSteps);
    _saveConfigs();
    notifyListeners();
  }

  /// Set test ordering for a category
  void setTestOrdering(String category, List<String> testIds) {
    final newOrdering = Map<String, List<String>>.from(
      _currentConfig.testOrdering,
    );
    newOrdering[category] = testIds;
    _currentConfig = _currentConfig.copyWith(testOrdering: newOrdering);
    _saveConfigs();
    notifyListeners();
  }

  /// Toggle a built-in test enabled state
  void toggleBuiltInTest(String testId, bool enabled) {
    final newEnabled = Set<String>.from(_currentConfig.enabledBuiltInTests);
    if (enabled) {
      newEnabled.add(testId);
    } else {
      newEnabled.remove(testId);
    }
    _currentConfig = _currentConfig.copyWith(enabledBuiltInTests: newEnabled);
    _saveConfigs();
    notifyListeners();
  }

  /// Save current configuration
  Future<void> saveCurrentConfig({String? name}) async {
    if (name != null) {
      _currentConfig = _currentConfig.copyWith(name: name);
    }

    // Check if config already exists
    final existingIndex = _savedConfigs.indexWhere(
      (c) => c.id == _currentConfig.id,
    );
    if (existingIndex >= 0) {
      _savedConfigs[existingIndex] = _currentConfig;
    } else {
      _savedConfigs.add(_currentConfig);
    }
    await _saveConfigs();
    notifyListeners();
  }

  /// Load a saved configuration
  Future<void> loadConfig(String configId) async {
    final config = _savedConfigs.firstWhere(
      (c) => c.id == configId,
      orElse: () => TestConfiguration.empty(),
    );
    _currentConfig = config;
    await _saveConfigs();
    notifyListeners();
  }

  /// Delete a saved configuration
  Future<void> deleteConfig(String configId) async {
    _savedConfigs.removeWhere((c) => c.id == configId);
    await _saveConfigs();
    notifyListeners();
  }

  /// Import configuration from JSON string
  Future<void> importConfig(String jsonString) async {
    try {
      final config = TestConfiguration.fromJsonString(jsonString);
      _currentConfig = config;
      await _saveConfigs();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to import configuration: $e');
      rethrow;
    }
  }

  /// Export current configuration as JSON string
  String exportConfig() {
    return _currentConfig.toJsonString();
  }

  /// Reset to empty configuration
  Future<void> resetConfig() async {
    _currentConfig = TestConfiguration.empty();
    await _saveConfigs();
    notifyListeners();
  }

  /// Clear all saved configurations
  Future<void> clearAllSavedConfigs() async {
    _savedConfigs.clear();
    await _saveConfigs();
    notifyListeners();
  }
}
