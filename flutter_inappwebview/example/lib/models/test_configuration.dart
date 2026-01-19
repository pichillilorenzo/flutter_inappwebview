import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Specifies which type of WebView to use for test execution
enum TestWebViewType {
  /// Use a visible InAppWebView widget for real-time rendering
  inAppWebView,

  /// Use a headless WebView for background execution
  headless,
}

/// Represents a custom test step that can be defined by the user
class CustomTestStep {
  final String id;
  final String name;
  final String description;
  final String category;
  final CustomTestAction action;
  final Map<String, dynamic> parameters;
  final String? expectedResult;
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
    this.enabled = true,
    this.order = 0,
  });

  CustomTestStep copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    CustomTestAction? action,
    Map<String, dynamic>? parameters,
    String? expectedResult,
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
      enabled: enabled ?? this.enabled,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'action': action.toJson(),
      'parameters': parameters,
      'expectedResult': expectedResult,
      'enabled': enabled,
      'order': order,
    };
  }

  factory CustomTestStep.fromJson(Map<String, dynamic> json) {
    return CustomTestStep(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'custom',
      action: CustomTestAction.fromJson(json['action'] as Map<String, dynamic>),
      parameters: (json['parameters'] as Map<String, dynamic>?) ?? {},
      expectedResult: json['expectedResult'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
    );
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

  /// Execute an InAppWebViewController method
  controllerMethod,
  custom,
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
      'methodParameters': methodParameters,
    };
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
      methodParameters: json['methodParameters'] as Map<String, dynamic>?,
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
    return [
      // Navigation tests
      CustomTestStep(
        id: 'default_load_url',
        name: 'Load URL',
        description: 'Load a test URL and verify navigation',
        category: 'navigation',
        action: CustomTestAction.controllerMethod(
          'loadUrl',
          parameters: {'url': 'https://example.com'},
        ),
        order: 0,
      ),
      CustomTestStep(
        id: 'default_get_url',
        name: 'Get Current URL',
        description: 'Retrieve and verify the current URL',
        category: 'navigation',
        action: CustomTestAction.controllerMethod('getUrl'),
        order: 1,
      ),
      CustomTestStep(
        id: 'default_reload',
        name: 'Reload Page',
        description: 'Reload the current page',
        category: 'navigation',
        action: CustomTestAction.controllerMethod('reload'),
        order: 2,
      ),

      // Page info tests
      CustomTestStep(
        id: 'default_get_title',
        name: 'Get Page Title',
        description: 'Retrieve the page title',
        category: 'pageInfo',
        action: CustomTestAction.controllerMethod('getTitle'),
        order: 3,
      ),
      CustomTestStep(
        id: 'default_get_html',
        name: 'Get HTML Source',
        description: 'Retrieve the page HTML source',
        category: 'pageInfo',
        action: CustomTestAction.controllerMethod('getHtml'),
        order: 4,
      ),

      // JavaScript tests
      CustomTestStep(
        id: 'default_evaluate_js',
        name: 'Evaluate JavaScript',
        description: 'Execute JavaScript and get result',
        category: 'javascript',
        action: CustomTestAction.controllerMethod(
          'evaluateJavascript',
          parameters: {'source': 'document.title'},
        ),
        order: 5,
      ),

      // Screenshot test
      CustomTestStep(
        id: 'default_screenshot',
        name: 'Take Screenshot',
        description: 'Capture a screenshot of the WebView',
        category: 'screenshotPrint',
        action: CustomTestAction.controllerMethod('takeScreenshot'),
        order: 6,
      ),

      // Security test
      CustomTestStep(
        id: 'default_secure_context',
        name: 'Check Secure Context',
        description: 'Verify if the page is in a secure context',
        category: 'security',
        action: CustomTestAction.controllerMethod('isSecureContext'),
        order: 7,
      ),

      // Certificate test
      CustomTestStep(
        id: 'default_get_certificate',
        name: 'Get SSL Certificate',
        description: 'Retrieve SSL certificate information',
        category: 'security',
        action: CustomTestAction.controllerMethod('getCertificate'),
        order: 8,
      ),
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

/// Provider for managing test configurations
class TestConfigurationManager extends ChangeNotifier {
  TestConfiguration _currentConfig = TestConfiguration.empty();
  List<TestConfiguration> _savedConfigs = [];

  TestConfiguration get currentConfig => _currentConfig;
  List<TestConfiguration> get savedConfigs => List.unmodifiable(_savedConfigs);

  /// Set the WebView type
  void setWebViewType(TestWebViewType type) {
    _currentConfig = _currentConfig.copyWith(webViewType: type);
    notifyListeners();
  }

  /// Set the initial URL
  void setInitialUrl(String? url) {
    _currentConfig = _currentConfig.copyWith(initialUrl: url);
    notifyListeners();
  }

  /// Add a custom test step
  void addCustomStep(CustomTestStep step) {
    final newSteps = [..._currentConfig.customSteps, step];
    _currentConfig = _currentConfig.copyWith(customSteps: newSteps);
    notifyListeners();
  }

  /// Update a custom test step
  void updateCustomStep(String stepId, CustomTestStep updatedStep) {
    final newSteps = _currentConfig.customSteps.map((s) {
      return s.id == stepId ? updatedStep : s;
    }).toList();
    _currentConfig = _currentConfig.copyWith(customSteps: newSteps);
    notifyListeners();
  }

  /// Remove a custom test step
  void removeCustomStep(String stepId) {
    final newSteps = _currentConfig.customSteps
        .where((s) => s.id != stepId)
        .toList();
    _currentConfig = _currentConfig.copyWith(customSteps: newSteps);
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
    notifyListeners();
  }

  /// Set test ordering for a category
  void setTestOrdering(String category, List<String> testIds) {
    final newOrdering = Map<String, List<String>>.from(
      _currentConfig.testOrdering,
    );
    newOrdering[category] = testIds;
    _currentConfig = _currentConfig.copyWith(testOrdering: newOrdering);
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
    notifyListeners();
  }

  /// Save current configuration
  void saveCurrentConfig({String? name}) {
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
    notifyListeners();
  }

  /// Load a saved configuration
  void loadConfig(String configId) {
    final config = _savedConfigs.firstWhere(
      (c) => c.id == configId,
      orElse: () => TestConfiguration.empty(),
    );
    _currentConfig = config;
    notifyListeners();
  }

  /// Delete a saved configuration
  void deleteConfig(String configId) {
    _savedConfigs.removeWhere((c) => c.id == configId);
    notifyListeners();
  }

  /// Import configuration from JSON string
  void importConfig(String jsonString) {
    try {
      final config = TestConfiguration.fromJsonString(jsonString);
      _currentConfig = config;
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
  void resetConfig() {
    _currentConfig = TestConfiguration.empty();
    notifyListeners();
  }
}
