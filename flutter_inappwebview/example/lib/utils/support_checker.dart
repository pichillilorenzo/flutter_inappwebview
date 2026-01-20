import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Represents a platform for API support checking.
enum SupportedPlatform {
  android,
  ios,
  macos,
  web,
  windows,
  linux;

  String get displayName {
    switch (this) {
      case SupportedPlatform.android:
        return 'Android';
      case SupportedPlatform.ios:
        return 'iOS';
      case SupportedPlatform.macos:
        return 'macOS';
      case SupportedPlatform.web:
        return 'Web';
      case SupportedPlatform.windows:
        return 'Windows';
      case SupportedPlatform.linux:
        return 'Linux';
    }
  }

  IconData get icon {
    switch (this) {
      case SupportedPlatform.android:
        return Icons.android;
      case SupportedPlatform.ios:
        return Icons.phone_iphone;
      case SupportedPlatform.macos:
        return Icons.laptop_mac;
      case SupportedPlatform.web:
        return Icons.language;
      case SupportedPlatform.windows:
        return Icons.desktop_windows;
      case SupportedPlatform.linux:
        return Icons.computer;
    }
  }

  Color get color {
    switch (this) {
      case SupportedPlatform.android:
        return Colors.green.shade600;
      case SupportedPlatform.ios:
        return Colors.grey.shade700;
      case SupportedPlatform.macos:
        return Colors.blueGrey.shade600;
      case SupportedPlatform.web:
        return Colors.blue.shade600;
      case SupportedPlatform.windows:
        return Colors.lightBlue.shade600;
      case SupportedPlatform.linux:
        return Colors.orange.shade700;
    }
  }

  TargetPlatform? get targetPlatform {
    switch (this) {
      case SupportedPlatform.android:
        return TargetPlatform.android;
      case SupportedPlatform.ios:
        return TargetPlatform.iOS;
      case SupportedPlatform.macos:
        return TargetPlatform.macOS;
      case SupportedPlatform.windows:
        return TargetPlatform.windows;
      case SupportedPlatform.linux:
        return TargetPlatform.linux;
      case SupportedPlatform.web:
        return null; // Web doesn't have a TargetPlatform
    }
  }
}

/// Helper utilities for support checks across platforms.
class SupportCheckHelper {
  /// Maps [SupportedPlatform] to a [TargetPlatform] when possible.
  static TargetPlatform? targetPlatformFor(SupportedPlatform platform) {
    return platform.targetPlatform;
  }

  /// Checks class support for a specific [SupportedPlatform].
  static bool isClassSupportedForPlatform({
    required SupportedPlatform platform,
    required bool Function({TargetPlatform? platform}) checker,
  }) {
    if (platform == SupportedPlatform.web) {
      return checker(platform: null);
    }
    return checker(platform: targetPlatformFor(platform));
  }

  /// Checks method support for a specific [SupportedPlatform].
  static bool isMethodSupportedForPlatform<T>({
    required SupportedPlatform platform,
    required T method,
    required bool Function(T method, {TargetPlatform? platform}) checker,
  }) {
    if (platform == SupportedPlatform.web) {
      return checker(method, platform: null);
    }
    return checker(method, platform: targetPlatformFor(platform));
  }

  /// Checks property support for a specific [SupportedPlatform].
  static bool isPropertySupportedForPlatform({
    required SupportedPlatform platform,
    required dynamic property,
    required bool Function(dynamic property, {TargetPlatform? platform})
    checker,
  }) {
    if (platform == SupportedPlatform.web) {
      return checker(property, platform: null);
    }
    return checker(property, platform: targetPlatformFor(platform));
  }

  /// Returns all supported platforms for a given class checker.
  static Set<SupportedPlatform> supportedPlatformsForClass({
    required bool Function({TargetPlatform? platform}) checker,
  }) {
    return SupportedPlatform.values
        .where(
          (platform) =>
              isClassSupportedForPlatform(platform: platform, checker: checker),
        )
        .toSet();
  }

  /// Returns all supported platforms for a given method checker.
  static Set<SupportedPlatform> supportedPlatformsForMethod<T>({
    required T method,
    required bool Function(T method, {TargetPlatform? platform}) checker,
  }) {
    return SupportedPlatform.values
        .where(
          (platform) => isMethodSupportedForPlatform(
            platform: platform,
            method: method,
            checker: checker,
          ),
        )
        .toSet();
  }

  /// Returns all supported platforms for a given property checker.
  static Set<SupportedPlatform> supportedPlatformsForProperty({
    required dynamic property,
    required bool Function(dynamic property, {TargetPlatform? platform})
    checker,
  }) {
    return SupportedPlatform.values
        .where(
          (platform) => isPropertySupportedForPlatform(
            platform: platform,
            property: property,
            checker: checker,
          ),
        )
        .toSet();
  }
}

/// Definition of an API method with platform support information.
class ApiMethodDefinition {
  final String name;
  final String signature;
  final String description;
  final String className;
  final bool isStatic;
  final bool isDeprecated;
  final String? category;

  const ApiMethodDefinition({
    required this.name,
    this.signature = '',
    this.description = '',
    required this.className,
    this.isStatic = false,
    this.isDeprecated = false,
    this.category,
  });

  /// Returns the supported platforms for this method using runtime checks.
  Set<SupportedPlatform> get supportedPlatforms =>
      SupportChecker.getSupportedPlatformsForMethod(className, name);

  bool isSupported(SupportedPlatform platform) =>
      supportedPlatforms.contains(platform);
}

/// Definition of an API event with platform support information.
class ApiEventDefinition {
  final String name;
  final String signature;
  final String description;
  final String className;
  final String? category;

  const ApiEventDefinition({
    required this.name,
    this.signature = '',
    this.description = '',
    required this.className,
    this.category,
  });

  /// Returns the supported platforms for this event using runtime checks.
  Set<SupportedPlatform> get supportedPlatforms =>
      SupportChecker.getSupportedPlatformsForEvent(className, name);

  bool isSupported(SupportedPlatform platform) =>
      supportedPlatforms.contains(platform);
}

/// Definition of an API class with its methods and events.
class ApiClassDefinition {
  final String className;
  final String description;
  final List<ApiMethodDefinition> methods;
  final List<ApiEventDefinition> events;
  final bool Function()? isClassSupported;

  const ApiClassDefinition({
    required this.className,
    this.description = '',
    this.methods = const [],
    this.events = const [],
    this.isClassSupported,
  });

  int get totalApis => methods.length + events.length;

  int methodCountForPlatform(SupportedPlatform platform) =>
      methods.where((m) => m.isSupported(platform)).length;

  int eventCountForPlatform(SupportedPlatform platform) =>
      events.where((e) => e.isSupported(platform)).length;
}

/// Summary of API support statistics.
class SupportSummary {
  final int totalMethods;
  final int totalEvents;
  final Map<SupportedPlatform, int> methodsPerPlatform;
  final Map<SupportedPlatform, int> eventsPerPlatform;

  const SupportSummary({
    required this.totalMethods,
    required this.totalEvents,
    required this.methodsPerPlatform,
    required this.eventsPerPlatform,
  });

  int get totalApis => totalMethods + totalEvents;

  int totalApisForPlatform(SupportedPlatform platform) =>
      (methodsPerPlatform[platform] ?? 0) + (eventsPerPlatform[platform] ?? 0);
}

typedef _MethodSupportResolver =
    bool Function(String methodName, SupportedPlatform platform);

typedef _PropertySupportResolver =
    bool Function(String propertyName, SupportedPlatform platform);

/// Utility class that provides comprehensive API support information.
class SupportChecker {
  // All supported platforms
  static const allPlatforms = {
    SupportedPlatform.android,
    SupportedPlatform.ios,
    SupportedPlatform.macos,
    SupportedPlatform.web,
    SupportedPlatform.windows,
    SupportedPlatform.linux,
  };

  // Mobile platforms
  static const mobilePlatforms = {
    SupportedPlatform.android,
    SupportedPlatform.ios,
  };

  // Native platforms (non-web)
  static const nativePlatforms = {
    SupportedPlatform.android,
    SupportedPlatform.ios,
    SupportedPlatform.macos,
    SupportedPlatform.windows,
    SupportedPlatform.linux,
  };

  // Desktop platforms
  static const desktopPlatforms = {
    SupportedPlatform.macos,
    SupportedPlatform.windows,
    SupportedPlatform.linux,
  };

  // Apple platforms
  static const applePlatforms = {
    SupportedPlatform.ios,
    SupportedPlatform.macos,
  };

  static String _enumName(Object? value) {
    if (value is Enum) return value.name;
    return value.toString().split('.').last;
  }

  static String classNameOf(Type type) => type.toString();

  static String eventClassNameOf(Type type) => '${classNameOf(type)} Events';

  static Set<String> get registeredClassNames => {
    ..._classSupportResolvers.keys,
    ..._methodSupportResolvers.keys,
    ..._eventSupportResolvers.keys,
  };

  static _MethodSupportResolver _buildMethodResolver<T>({
    required List<T> values,
    required bool Function(T method, {TargetPlatform? platform}) checker,
  }) {
    final methodByName = {for (final value in values) _enumName(value): value};
    return (String methodName, SupportedPlatform platform) {
      final resolved = methodByName[methodName];
      if (resolved == null) return false;
      return SupportCheckHelper.isMethodSupportedForPlatform(
        platform: platform,
        method: resolved,
        checker: checker,
      );
    };
  }

  static _PropertySupportResolver _buildPropertyResolver<T>({
    required List<T> values,
    required bool Function(dynamic property, {TargetPlatform? platform})
    checker,
    Map<String, String> nameOverrides = const {},
  }) {
    final propertyByName = {
      for (final value in values) _enumName(value): value,
    };
    return (String propertyName, SupportedPlatform platform) {
      final resolvedName = nameOverrides[propertyName] ?? propertyName;
      final resolved = propertyByName[resolvedName];
      if (resolved == null) return false;
      return SupportCheckHelper.isPropertySupportedForPlatform(
        platform: platform,
        property: resolved,
        checker: checker,
      );
    };
  }

  static final Map<String, bool Function({TargetPlatform? platform})>
  _classSupportResolvers = {
    classNameOf(InAppWebViewController):
        InAppWebViewController.isClassSupported,
    eventClassNameOf(InAppWebView): InAppWebView.isClassSupported,
    classNameOf(HeadlessInAppWebView): HeadlessInAppWebView.isClassSupported,
    classNameOf(InAppBrowser): InAppBrowser.isClassSupported,
    classNameOf(ChromeSafariBrowser): ChromeSafariBrowser.isClassSupported,
    classNameOf(CookieManager): CookieManager.isClassSupported,
    classNameOf(WebStorage): WebStorage.isClassSupported,
    classNameOf(FindInteractionController):
        FindInteractionController.isClassSupported,
    classNameOf(PullToRefreshController):
        PullToRefreshController.isClassSupported,
    classNameOf(PrintJobController): PrintJobController.isClassSupported,
    classNameOf(WebAuthenticationSession):
        WebAuthenticationSession.isClassSupported,
    classNameOf(ServiceWorkerController):
        ServiceWorkerController.isClassSupported,
    classNameOf(ProxyController): ProxyController.isClassSupported,
    classNameOf(TracingController): TracingController.isClassSupported,
    classNameOf(HttpAuthCredentialDatabase):
        HttpAuthCredentialDatabase.isClassSupported,
    classNameOf(WebViewEnvironment): WebViewEnvironment.isClassSupported,
    classNameOf(ProcessGlobalConfig): ProcessGlobalConfig.isClassSupported,
    classNameOf(WebMessageChannel): WebMessageChannel.isClassSupported,
  };

  static final Map<String, _MethodSupportResolver> _methodSupportResolvers = {
    classNameOf(InAppWebViewController): _buildMethodResolver(
      values: PlatformInAppWebViewControllerMethod.values,
      checker: InAppWebViewController.isMethodSupported,
    ),
    classNameOf(HeadlessInAppWebView): _buildMethodResolver(
      values: PlatformHeadlessInAppWebViewMethod.values,
      checker: HeadlessInAppWebView.isMethodSupported,
    ),
    classNameOf(InAppBrowser): _buildMethodResolver(
      values: PlatformInAppBrowserMethod.values,
      checker: InAppBrowser.isMethodSupported,
    ),
    classNameOf(ChromeSafariBrowser): _buildMethodResolver(
      values: PlatformChromeSafariBrowserMethod.values,
      checker: ChromeSafariBrowser.isMethodSupported,
    ),
    classNameOf(CookieManager): _buildMethodResolver(
      values: PlatformCookieManagerMethod.values,
      checker: CookieManager.isMethodSupported,
    ),
    classNameOf(WebStorage): _buildMethodResolver(
      values: PlatformLocalStorageMethod.values,
      checker: LocalStorage.isMethodSupported,
    ),
    classNameOf(FindInteractionController): _buildMethodResolver(
      values: PlatformFindInteractionControllerMethod.values,
      checker: FindInteractionController.isMethodSupported,
    ),
    classNameOf(PullToRefreshController): _buildMethodResolver(
      values: PlatformPullToRefreshControllerMethod.values,
      checker: PullToRefreshController.isMethodSupported,
    ),
    classNameOf(PrintJobController): _buildMethodResolver(
      values: PlatformPrintJobControllerMethod.values,
      checker: PrintJobController.isMethodSupported,
    ),
    classNameOf(WebAuthenticationSession): _buildMethodResolver(
      values: PlatformWebAuthenticationSessionMethod.values,
      checker: WebAuthenticationSession.isMethodSupported,
    ),
    classNameOf(ServiceWorkerController): _buildMethodResolver(
      values: PlatformServiceWorkerControllerMethod.values,
      checker: ServiceWorkerController.isMethodSupported,
    ),
    classNameOf(ProxyController): _buildMethodResolver(
      values: PlatformProxyControllerMethod.values,
      checker: ProxyController.isMethodSupported,
    ),
    classNameOf(TracingController): _buildMethodResolver(
      values: PlatformTracingControllerMethod.values,
      checker: TracingController.isMethodSupported,
    ),
    classNameOf(HttpAuthCredentialDatabase): _buildMethodResolver(
      values: PlatformHttpAuthCredentialDatabaseMethod.values,
      checker: HttpAuthCredentialDatabase.isMethodSupported,
    ),
    classNameOf(WebViewEnvironment): _buildMethodResolver(
      values: PlatformWebViewEnvironmentMethod.values,
      checker: WebViewEnvironment.isMethodSupported,
    ),
    classNameOf(ProcessGlobalConfig): _buildMethodResolver(
      values: PlatformProcessGlobalConfigMethod.values,
      checker: ProcessGlobalConfig.isMethodSupported,
    ),
    classNameOf(WebMessageChannel): _buildMethodResolver(
      values: PlatformWebMessageChannelMethod.values,
      checker: WebMessageChannel.isMethodSupported,
    ),
  };

  static final Map<String, _PropertySupportResolver> _eventSupportResolvers = {
    eventClassNameOf(InAppWebView): _buildPropertyResolver(
      values: PlatformWebViewCreationParamsProperty.values,
      checker: InAppWebView.isPropertySupported,
    ),
    classNameOf(FindInteractionController): _buildPropertyResolver(
      values: PlatformFindInteractionControllerCreationParamsProperty.values,
      checker: (property, {platform}) =>
          FindInteractionController.isPropertySupported(
            property as PlatformFindInteractionControllerCreationParamsProperty,
            platform: platform,
          ),
    ),
  };

  /// Get all API definitions organized by class.
  static List<ApiClassDefinition> getAllApiDefinitions() {
    return [
      _getInAppWebViewControllerDefinition(),
      _getInAppWebViewEventsDefinition(),
      _getHeadlessInAppWebViewDefinition(),
      _getInAppBrowserDefinition(),
      _getChromeSafariBrowserDefinition(),
      _getCookieManagerDefinition(),
      _getWebStorageDefinition(),
      _getFindInteractionControllerDefinition(),
      _getPullToRefreshControllerDefinition(),
      _getPrintJobControllerDefinition(),
      _getWebAuthenticationSessionDefinition(),
      _getServiceWorkerControllerDefinition(),
      _getProxyControllerDefinition(),
      _getTracingControllerDefinition(),
      _getHttpAuthCredentialDatabaseDefinition(),
      _getWebViewEnvironmentDefinition(),
      _getProcessGlobalConfigDefinition(),
      _getWebMessageChannelDefinition(),
    ];
  }

  /// Check if a specific method is supported on current platform.
  static bool isMethodSupported(String className, String methodName) {
    final currentPlatform = _getCurrentPlatform();
    if (currentPlatform == null) return false;
    return isMethodSupportedForPlatform(className, methodName, currentPlatform);
  }

  /// Check if a specific method is supported on a target platform.
  static bool isMethodSupportedForPlatform(
    String className,
    String methodName,
    SupportedPlatform platform,
  ) {
    final resolver = _methodSupportResolvers[className];
    if (resolver != null) {
      return resolver(methodName, platform);
    }

    final definitions = getAllApiDefinitions();
    final classDef = definitions.cast<ApiClassDefinition?>().firstWhere(
      (c) => c?.className == className,
      orElse: () => null,
    );
    if (classDef == null) return false;

    final method = classDef.methods.cast<ApiMethodDefinition?>().firstWhere(
      (m) => m?.name == methodName,
      orElse: () => null,
    );
    if (method == null) return false;

    return method.isSupported(platform);
  }

  /// Check if a specific event is supported on current platform.
  static bool isEventSupported(String className, String eventName) {
    final currentPlatform = _getCurrentPlatform();
    if (currentPlatform == null) return false;
    return isEventSupportedForPlatform(className, eventName, currentPlatform);
  }

  /// Check if a specific event is supported on a target platform.
  static bool isEventSupportedForPlatform(
    String className,
    String eventName,
    SupportedPlatform platform,
  ) {
    final resolver = _eventSupportResolvers[className];
    if (resolver != null) {
      return resolver(eventName, platform);
    }

    final definitions = getAllApiDefinitions();
    final classDef = definitions.cast<ApiClassDefinition?>().firstWhere(
      (c) => c?.className == className,
      orElse: () => null,
    );
    if (classDef == null) return false;

    final event = classDef.events.cast<ApiEventDefinition?>().firstWhere(
      (e) => e?.name == eventName,
      orElse: () => null,
    );
    if (event == null) return false;

    return event.isSupported(platform);
  }

  /// Returns supported platforms for a given class.
  static Set<SupportedPlatform> getSupportedPlatformsForClass(
    String className,
  ) {
    final resolver = _classSupportResolvers[className];
    if (resolver != null) {
      return SupportCheckHelper.supportedPlatformsForClass(checker: resolver);
    }

    final definitions = getAllApiDefinitions();
    final classDef = definitions.cast<ApiClassDefinition?>().firstWhere(
      (c) => c?.className == className,
      orElse: () => null,
    );
    if (classDef == null) return {};

    final supported = <SupportedPlatform>{};
    if (classDef.isClassSupported != null) {
      final currentPlatform = _getCurrentPlatform();
      if (currentPlatform != null && classDef.isClassSupported!()) {
        supported.add(currentPlatform);
      }
    }

    for (final platform in SupportedPlatform.values) {
      if (classDef.methods.any((m) => m.isSupported(platform)) ||
          classDef.events.any((e) => e.isSupported(platform))) {
        supported.add(platform);
      }
    }
    return supported;
  }

  /// Returns supported platforms for a specific method.
  static Set<SupportedPlatform> getSupportedPlatformsForMethod(
    String className,
    String methodName,
  ) {
    final resolver = _methodSupportResolvers[className];
    if (resolver != null) {
      return SupportedPlatform.values
          .where((p) => resolver(methodName, p))
          .toSet();
    }
    // No resolver registered for this class
    return <SupportedPlatform>{};
  }

  /// Returns supported platforms for a specific event.
  static Set<SupportedPlatform> getSupportedPlatformsForEvent(
    String className,
    String eventName,
  ) {
    final resolver = _eventSupportResolvers[className];
    if (resolver != null) {
      return SupportedPlatform.values
          .where((p) => resolver(eventName, p))
          .toSet();
    }
    // No resolver registered for this class
    return <SupportedPlatform>{};
  }

  /// Get support summary statistics.
  static SupportSummary getSupportSummary() {
    final definitions = getAllApiDefinitions();

    int totalMethods = 0;
    int totalEvents = 0;
    final methodsPerPlatform = <SupportedPlatform, int>{};
    final eventsPerPlatform = <SupportedPlatform, int>{};

    for (final platform in SupportedPlatform.values) {
      methodsPerPlatform[platform] = 0;
      eventsPerPlatform[platform] = 0;
    }

    for (final classDef in definitions) {
      totalMethods += classDef.methods.length;
      totalEvents += classDef.events.length;

      for (final method in classDef.methods) {
        final supported = getSupportedPlatformsForMethod(
          classDef.className,
          method.name,
        );
        for (final platform in supported) {
          methodsPerPlatform[platform] = methodsPerPlatform[platform]! + 1;
        }
      }

      for (final event in classDef.events) {
        final supported = getSupportedPlatformsForEvent(
          classDef.className,
          event.name,
        );
        for (final platform in supported) {
          eventsPerPlatform[platform] = eventsPerPlatform[platform]! + 1;
        }
      }
    }

    return SupportSummary(
      totalMethods: totalMethods,
      totalEvents: totalEvents,
      methodsPerPlatform: methodsPerPlatform,
      eventsPerPlatform: eventsPerPlatform,
    );
  }

  static SupportedPlatform? _getCurrentPlatform() {
    if (kIsWeb) return SupportedPlatform.web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return SupportedPlatform.android;
      case TargetPlatform.iOS:
        return SupportedPlatform.ios;
      case TargetPlatform.macOS:
        return SupportedPlatform.macos;
      case TargetPlatform.windows:
        return SupportedPlatform.windows;
      case TargetPlatform.linux:
        return SupportedPlatform.linux;
      default:
        return null;
    }
  }

  // ====================
  // API Class Definitions
  // ====================

  static ApiClassDefinition _getInAppWebViewControllerDefinition() {
    final className = classNameOf(InAppWebViewController);
    return ApiClassDefinition(
      className: className,
      description: 'Controls an ${InAppWebView} instance.',
      isClassSupported: () => InAppWebViewController.isClassSupported(),
      methods: [
        // Navigation methods
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.loadUrl.name,
          signature: 'Future<void> loadUrl({required URLRequest urlRequest})',
          description: 'Loads the given URL with optional headers.',
          className: className,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.postUrl.name,
          signature:
              'Future<void> postUrl({required WebUri url, required Uint8List postData})',
          description: 'Loads the URL with POST data.',
          className: className,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.loadData.name,
          signature: 'Future<void> loadData({required String data, ...})',
          description: 'Loads HTML data directly into the WebView.',
          className: className,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.loadFile.name,
          signature: 'Future<void> loadFile({required String assetFilePath})',
          description: 'Loads a file from the asset bundle.',
          className: className,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.reload.name,
          signature: 'Future<void> reload()',
          description: 'Reloads the current page.',
          className: className,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.reloadFromOrigin.name,
          signature: 'Future<void> reloadFromOrigin()',
          description:
              'Reloads the current page, performing end-to-end validation.',
          className: className,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.goBack.name,
          signature: 'Future<void> goBack()',
          description: 'Goes back in the history of the WebView.',
          className: className,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.goForward.name,
          signature: 'Future<void> goForward()',
          description: 'Goes forward in the history of the WebView.',
          className: className,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.goBackOrForward.name,
          signature: 'Future<void> goBackOrForward({required int steps})',
          description: 'Goes to the history item at the given offset.',
          className: className,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.goTo.name,
          signature: 'Future<void> goTo({required WebHistoryItem historyItem})',
          description: 'Goes to the specified history item.',
          className: className,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.canGoBack.name,
          signature: 'Future<bool> canGoBack()',
          description: 'Returns whether the WebView can go back in history.',
          className: className,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.canGoForward.name,
          signature: 'Future<bool> canGoForward()',
          description: 'Returns whether the WebView can go forward in history.',
          className: className,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.canGoBackOrForward.name,
          signature: 'Future<bool> canGoBackOrForward({required int steps})',
          description:
              'Returns whether the WebView can go to the specified offset.',
          className: className,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.isLoading.name,
          signature: 'Future<bool> isLoading()',
          description: 'Returns whether the WebView is currently loading.',
          className: className,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.stopLoading.name,
          signature: 'Future<void> stopLoading()',
          description: 'Stops the current page load.',
          className: className,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.loadSimulatedRequest.name,
          signature:
              'Future<void> loadSimulatedRequest({required URLRequest urlRequest, ...})',
          description:
              'Navigates to a requested URL with simulated response data.',
          className: className,
          category: 'Navigation',
        ),

        // Page Info methods
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.getUrl.name,
          signature: 'Future<WebUri?> getUrl()',
          description: 'Gets the current URL of the WebView.',
          className: className,
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.getTitle.name,
          signature: 'Future<String?> getTitle()',
          description: 'Gets the title of the current page.',
          className: className,
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.getProgress.name,
          signature: 'Future<int?> getProgress()',
          description: 'Gets the current loading progress.',
          className: className,
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.getHtml.name,
          signature: 'Future<String?> getHtml()',
          description: 'Gets the HTML content of the current page.',
          className: className,
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.getFavicons.name,
          signature: 'Future<List<Favicon>> getFavicons()',
          description: 'Gets the favicons of the current page.',
          className: className,
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.getOriginalUrl.name,
          signature: 'Future<WebUri?> getOriginalUrl()',
          description: 'Gets the original URL before redirects.',
          className: className,
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.getSelectedText.name,
          signature: 'Future<String?> getSelectedText()',
          description: 'Gets the currently selected text.',
          className: className,
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.getHitTestResult.name,
          signature:
              'Future<${InAppWebViewHitTestResult}?> ${PlatformInAppWebViewControllerMethod.getHitTestResult.name}()',
          description: 'Gets a hit test result for the last tap.',
          className: className,
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.getMetaTags.name,
          signature: 'Future<List<MetaTag>> getMetaTags()',
          description: 'Gets all meta tags of the current page.',
          className: className,
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.getMetaThemeColor.name,
          signature: 'Future<Color?> getMetaThemeColor()',
          description: 'Gets the meta theme color of the page.',
          className: className,
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.getCertificate.name,
          signature: 'Future<SslCertificate?> getCertificate()',
          description: 'Gets the SSL certificate for the main resource.',
          className: className,
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name:
              PlatformInAppWebViewControllerMethod.getCopyBackForwardList.name,
          signature: 'Future<WebHistory?> getCopyBackForwardList()',
          description: 'Gets a copy of the back/forward list.',
          className: className,
          category: 'Page Info',
        ),

        // JavaScript methods
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.evaluateJavascript.name,
          signature:
              'Future<dynamic> evaluateJavascript({required String source, ...})',
          description: 'Evaluates JavaScript code and returns the result.',
          className: className,
          category: 'JavaScript',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.callAsyncJavaScript.name,
          signature:
              'Future<CallAsyncJavaScriptResult?> callAsyncJavaScript({...})',
          description: 'Calls a JavaScript function asynchronously.',
          className: className,
          category: 'JavaScript',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod
              .injectJavascriptFileFromUrl
              .name,
          signature:
              'Future<void> injectJavascriptFileFromUrl({required WebUri urlFile, ...})',
          description: 'Injects a JavaScript file from a URL.',
          className: className,
          category: 'JavaScript',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod
              .injectJavascriptFileFromAsset
              .name,
          signature:
              'Future<dynamic> injectJavascriptFileFromAsset({required String assetFilePath})',
          description: 'Injects a JavaScript file from assets.',
          className: className,
          category: 'JavaScript',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.injectCSSCode.name,
          signature: 'Future<void> injectCSSCode({required String source})',
          description: 'Injects CSS code into the page.',
          className: className,
          category: 'JavaScript',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.injectCSSFileFromUrl.name,
          signature:
              'Future<void> injectCSSFileFromUrl({required WebUri urlFile, ...})',
          description: 'Injects a CSS file from a URL.',
          className: className,
          category: 'JavaScript',
        ),
        ApiMethodDefinition(
          name:
              PlatformInAppWebViewControllerMethod.injectCSSFileFromAsset.name,
          signature:
              'Future<void> injectCSSFileFromAsset({required String assetFilePath})',
          description: 'Injects a CSS file from assets.',
          className: className,
          category: 'JavaScript',
        ),

        // JavaScript Handler methods
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.addJavaScriptHandler.name,
          signature:
              'void addJavaScriptHandler({required String handlerName, ...})',
          description: 'Adds a handler for JavaScript to call.',
          className: className,
          category: 'Handlers',
        ),
        ApiMethodDefinition(
          name:
              PlatformInAppWebViewControllerMethod.removeJavaScriptHandler.name,
          signature:
              'JavaScriptHandlerCallback? removeJavaScriptHandler({required String handlerName})',
          description: 'Removes a JavaScript handler.',
          className: className,
          category: 'Handlers',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.hasJavaScriptHandler.name,
          signature: 'bool hasJavaScriptHandler({required String handlerName})',
          description: 'Checks if a JavaScript handler exists.',
          className: className,
          category: 'Handlers',
        ),

        // User Scripts methods
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.addUserScript.name,
          signature:
              'Future<void> addUserScript({required UserScript userScript})',
          description: 'Adds a user script to the WebView.',
          className: className,
          category: 'User Scripts',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.removeUserScript.name,
          signature:
              'Future<bool> removeUserScript({required UserScript userScript})',
          description: 'Removes a user script.',
          className: className,
          category: 'User Scripts',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod
              .removeUserScriptsByGroupName
              .name,
          signature:
              'Future<void> removeUserScriptsByGroupName({required String groupName})',
          description: 'Removes user scripts by group name.',
          className: className,
          category: 'User Scripts',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.removeAllUserScripts.name,
          signature: 'Future<void> removeAllUserScripts()',
          description: 'Removes all user scripts.',
          className: className,
          category: 'User Scripts',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.hasUserScript.name,
          signature: 'bool hasUserScript({required UserScript userScript})',
          description: 'Checks if a user script exists.',
          className: className,
          category: 'User Scripts',
        ),

        // Scrolling methods
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.scrollTo.name,
          signature:
              'Future<void> scrollTo({required int x, required int y, bool animated})',
          description: 'Scrolls the WebView to the specified position.',
          className: className,
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.scrollBy.name,
          signature:
              'Future<void> scrollBy({required int x, required int y, bool animated})',
          description: 'Scrolls the WebView by the specified amount.',
          className: className,
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.getScrollX.name,
          signature: 'Future<int?> getScrollX()',
          description: 'Gets the current horizontal scroll position.',
          className: className,
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.getScrollY.name,
          signature: 'Future<int?> getScrollY()',
          description: 'Gets the current vertical scroll position.',
          className: className,
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.getContentHeight.name,
          signature: 'Future<int?> getContentHeight()',
          description: 'Gets the height of the HTML content.',
          className: className,
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.getContentWidth.name,
          signature: 'Future<int?> getContentWidth()',
          description: 'Gets the width of the HTML content.',
          className: className,
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.canScrollVertically.name,
          signature: 'Future<bool> canScrollVertically()',
          description: 'Checks if the WebView can scroll vertically.',
          className: className,
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.canScrollHorizontally.name,
          signature: 'Future<bool> canScrollHorizontally()',
          description: 'Checks if the WebView can scroll horizontally.',
          className: className,
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.pageDown.name,
          signature: 'Future<bool> pageDown({required bool bottom})',
          description: 'Scrolls down by half or full page.',
          className: className,
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.pageUp.name,
          signature: 'Future<bool> pageUp({required bool top})',
          description: 'Scrolls up by half or full page.',
          className: className,
          category: 'Scrolling',
        ),

        // Zoom methods
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.zoomBy.name,
          signature: 'Future<void> zoomBy({required double zoomFactor, ...})',
          description: 'Zooms by the specified factor.',
          className: className,
          category: 'Zoom',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.zoomIn.name,
          signature: 'Future<bool> zoomIn()',
          description: 'Zooms in by a standard amount.',
          className: className,
          category: 'Zoom',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.zoomOut.name,
          signature: 'Future<bool> zoomOut()',
          description: 'Zooms out by a standard amount.',
          className: className,
          category: 'Zoom',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.getZoomScale.name,
          signature: 'Future<double?> getZoomScale()',
          description: 'Gets the current zoom scale.',
          className: className,
          category: 'Zoom',
        ),

        // Settings methods
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.setSettings.name,
          signature:
              'Future<void> ${PlatformInAppWebViewControllerMethod.setSettings.name}({required ${InAppWebViewSettings} settings})',
          description: 'Updates the WebView settings.',
          className: className,
          category: 'Settings',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.getSettings.name,
          signature:
              'Future<${InAppWebViewSettings}?> ${PlatformInAppWebViewControllerMethod.getSettings.name}()',
          description: 'Gets the current WebView settings.',
          className: className,
          category: 'Settings',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.setContextMenu.name,
          signature: 'Future<void> setContextMenu(ContextMenu? contextMenu)',
          description: 'Sets the context menu.',
          className: className,
          category: 'Settings',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.requestFocus.name,
          signature: 'Future<void> requestFocus()',
          description: 'Requests focus for the WebView.',
          className: className,
          category: 'Settings',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.clearFocus.name,
          signature: 'Future<void> clearFocus()',
          description: 'Clears focus from the WebView.',
          className: className,
          category: 'Settings',
        ),

        // Screenshot methods
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.takeScreenshot.name,
          signature:
              'Future<Uint8List?> takeScreenshot({ScreenshotConfiguration? screenshotConfiguration})',
          description: 'Takes a screenshot of the WebView.',
          className: className,
          category: 'Screenshot',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.printCurrentPage.name,
          signature:
              'Future<${PrintJobController}?> ${PlatformInAppWebViewControllerMethod.printCurrentPage.name}({${PrintJobSettings}? settings})',
          description: 'Prints the current page.',
          className: className,
          category: 'Screenshot',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.createPdf.name,
          signature:
              'Future<Uint8List?> createPdf({PdfConfiguration? pdfConfiguration})',
          description: 'Creates a PDF from the current page.',
          className: className,
          category: 'Screenshot',
        ),

        // Cache methods
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.clearHistory.name,
          signature: 'Future<void> clearHistory()',
          description: 'Clears the WebView history.',
          className: className,
          category: 'Cache',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.clearFormData.name,
          signature: 'Future<void> clearFormData()',
          description: 'Clears form data.',
          className: className,
          category: 'Cache',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.clearSslPreferences.name,
          signature: 'Future<void> clearSslPreferences()',
          description: 'Clears SSL preferences.',
          className: className,
          category: 'Cache',
        ),

        // Pause/Resume methods
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.pause.name,
          signature: 'Future<void> pause()',
          description: 'Pauses the WebView.',
          className: className,
          category: 'Pause/Resume',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.resume.name,
          signature: 'Future<void> resume()',
          description: 'Resumes the WebView.',
          className: className,
          category: 'Pause/Resume',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.pauseTimers.name,
          signature: 'Future<void> pauseTimers()',
          description: 'Pauses all layout, parsing, and JavaScript timers.',
          className: className,
          category: 'Pause/Resume',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.resumeTimers.name,
          signature: 'Future<void> resumeTimers()',
          description: 'Resumes all layout, parsing, and JavaScript timers.',
          className: className,
          category: 'Pause/Resume',
        ),

        // Web Messaging methods
        ApiMethodDefinition(
          name:
              PlatformInAppWebViewControllerMethod.createWebMessageChannel.name,
          signature:
              'Future<${WebMessageChannel}?> ${PlatformInAppWebViewControllerMethod.createWebMessageChannel.name}()',
          description: 'Creates a message channel for communication.',
          className: className,
          category: 'Web Messaging',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.postWebMessage.name,
          signature:
              'Future<void> ${PlatformInAppWebViewControllerMethod.postWebMessage.name}({required ${WebMessage} message, ...})',
          description: 'Posts a message to the WebView.',
          className: className,
          category: 'Web Messaging',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.addWebMessageListener.name,
          signature:
              'Future<void> ${PlatformInAppWebViewControllerMethod.addWebMessageListener.name}(${WebMessageListener} webMessageListener)',
          description: 'Adds a listener for web messages.',
          className: className,
          category: 'Web Messaging',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.hasWebMessageListener.name,
          signature:
              'bool hasWebMessageListener({required String jsObjectName})',
          description: 'Checks if a web message listener exists.',
          className: className,
          category: 'Web Messaging',
        ),

        // Media methods
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.isInFullscreen.name,
          signature: 'Future<bool?> isInFullscreen()',
          description: 'Returns whether the WebView is in fullscreen mode.',
          className: className,
          category: 'Media',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.pauseAllMediaPlayback.name,
          signature: 'Future<void> pauseAllMediaPlayback()',
          description: 'Pauses all media playback.',
          className: className,
          category: 'Media',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod
              .setAllMediaPlaybackSuspended
              .name,
          signature:
              'Future<void> setAllMediaPlaybackSuspended({required bool suspended})',
          description: 'Suspends or resumes all media playback.',
          className: className,
          category: 'Media',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod
              .closeAllMediaPresentations
              .name,
          signature: 'Future<void> closeAllMediaPresentations()',
          description: 'Closes all media presentations.',
          className: className,
          category: 'Media',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod
              .requestMediaPlaybackState
              .name,
          signature: 'Future<MediaPlaybackState?> requestMediaPlaybackState()',
          description: 'Gets the current media playback state.',
          className: className,
          category: 'Media',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.isPlayingAudio.name,
          signature: 'Future<bool?> isPlayingAudio()',
          description: 'Checks if audio is currently playing.',
          className: className,
          category: 'Media',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.isMuted.name,
          signature: 'Future<bool?> isMuted()',
          description: 'Checks if audio is muted.',
          className: className,
          category: 'Media',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.setMuted.name,
          signature: 'Future<void> setMuted({required bool muted})',
          description: 'Sets the muted state.',
          className: className,
          category: 'Media',
        ),

        // Camera/Mic methods
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.getCameraCaptureState.name,
          signature: 'Future<MediaCaptureState?> getCameraCaptureState()',
          description: 'Gets the camera capture state.',
          className: className,
          category: 'Camera/Mic',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.setCameraCaptureState.name,
          signature:
              'Future<void> setCameraCaptureState({required MediaCaptureState state})',
          description: 'Sets the camera capture state.',
          className: className,
          category: 'Camera/Mic',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod
              .getMicrophoneCaptureState
              .name,
          signature: 'Future<MediaCaptureState?> getMicrophoneCaptureState()',
          description: 'Gets the microphone capture state.',
          className: className,
          category: 'Camera/Mic',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod
              .setMicrophoneCaptureState
              .name,
          signature:
              'Future<void> setMicrophoneCaptureState({required MediaCaptureState state})',
          description: 'Sets the microphone capture state.',
          className: className,
          category: 'Camera/Mic',
        ),

        // Security methods
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.isSecureContext.name,
          signature: 'Future<bool> isSecureContext()',
          description: 'Checks if the current context is secure (HTTPS).',
          className: className,
          category: 'Security',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.hasOnlySecureContent.name,
          signature: 'Future<bool> hasOnlySecureContent()',
          description: 'Checks if the page has only secure content.',
          className: className,
          category: 'Security',
        ),

        // Android-specific methods
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.startSafeBrowsing.name,
          signature: 'Future<bool> startSafeBrowsing()',
          description: 'Starts the Safe Browsing initialization.',
          className: className,
          category: 'Android',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.saveWebArchive.name,
          signature:
              'Future<String?> saveWebArchive({required String basename, ...})',
          description: 'Saves the current page as a web archive.',
          className: className,
          category: 'Android',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.requestFocusNodeHref.name,
          signature:
              'Future<RequestFocusNodeHrefResult?> requestFocusNodeHref()',
          description: 'Requests the URL of the focused anchor.',
          className: className,
          category: 'Android',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.requestImageRef.name,
          signature: 'Future<RequestImageRefResult?> requestImageRef()',
          description: 'Requests the URL of the focused image.',
          className: className,
          category: 'Android',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.saveState.name,
          signature: 'Future<Uint8List?> saveState()',
          description: 'Saves the WebView state to a bundle.',
          className: className,
          category: 'Android',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.restoreState.name,
          signature: 'Future<void> restoreState({required Uint8List state})',
          description: 'Restores the WebView state from a bundle.',
          className: className,
          category: 'Android',
        ),

        // iOS/macOS-specific methods
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.createWebArchiveData.name,
          signature: 'Future<Uint8List?> createWebArchiveData()',
          description: 'Creates a web archive of the current page.',
          className: className,
          category: 'iOS/macOS',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.terminateWebProcess.name,
          signature: 'Future<void> terminateWebProcess()',
          description: 'Terminates the web content process.',
          className: className,
          category: 'iOS/macOS',
        ),

        // Windows-specific methods
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.openDevTools.name,
          signature: 'Future<void> openDevTools()',
          description: 'Opens the browser DevTools.',
          className: className,
          category: 'Windows',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod
              .callDevToolsProtocolMethod
              .name,
          signature:
              'Future<dynamic> callDevToolsProtocolMethod({required String methodName, ...})',
          description: 'Calls a DevTools Protocol method.',
          className: className,
          category: 'Windows',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod
              .addDevToolsProtocolEventListener
              .name,
          signature:
              'Future<void> addDevToolsProtocolEventListener({required String eventName, ...})',
          description: 'Adds a DevTools Protocol event listener.',
          className: className,
          category: 'Windows',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod
              .removeDevToolsProtocolEventListener
              .name,
          signature:
              'Future<void> removeDevToolsProtocolEventListener({required String eventName})',
          description: 'Removes a DevTools Protocol event listener.',
          className: className,
          category: 'Windows',
        ),

        // Web-specific methods
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.getIFrameId.name,
          signature: 'Future<String?> getIFrameId()',
          description: 'Gets the iframe ID on web platform.',
          className: className,
          category: 'Web',
        ),

        // Other methods
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.getViewId.name,
          signature: 'int getViewId()',
          description: 'Gets the view ID of the WebView.',
          className: className,
          category: 'Other',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.dispose.name,
          signature: 'void dispose()',
          description: 'Disposes the controller and releases resources.',
          className: className,
          category: 'Other',
        ),

        // Static methods
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.getDefaultUserAgent.name,
          signature: 'static Future<String> getDefaultUserAgent()',
          description: 'Gets the default User-Agent string.',
          className: className,
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod
              .clearClientCertPreferences
              .name,
          signature: 'static Future<void> clearClientCertPreferences()',
          description: 'Clears the client certificate preferences.',
          className: className,
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod
              .getSafeBrowsingPrivacyPolicyUrl
              .name,
          signature: 'static Future<WebUri?> getSafeBrowsingPrivacyPolicyUrl()',
          description: 'Gets the Safe Browsing privacy policy URL.',
          className: className,
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod
              .setSafeBrowsingAllowlist
              .name,
          signature:
              'static Future<bool> setSafeBrowsingAllowlist({required List<String> hosts})',
          description: 'Sets the Safe Browsing allowlist.',
          className: className,
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod
              .getCurrentWebViewPackage
              .name,
          signature:
              'static Future<WebViewPackageInfo?> getCurrentWebViewPackage()',
          description: 'Gets the current WebView package info.',
          className: className,
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod
              .setWebContentsDebuggingEnabled
              .name,
          signature:
              'static Future<void> setWebContentsDebuggingEnabled(bool debuggingEnabled)',
          description: 'Enables or disables debugging.',
          className: className,
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.getVariationsHeader.name,
          signature: 'static Future<String?> getVariationsHeader()',
          description: 'Gets the variations header.',
          className: className,
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.isMultiProcessEnabled.name,
          signature: 'static Future<bool> isMultiProcessEnabled()',
          description: 'Checks if multi-process is enabled.',
          className: className,
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.disableWebView.name,
          signature: 'static Future<void> disableWebView()',
          description: 'Disables the WebView.',
          className: className,
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.handlesURLScheme.name,
          signature: 'static Future<bool> handlesURLScheme(String urlScheme)',
          description: 'Checks if the WebView handles a URL scheme.',
          className: className,
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.disposeKeepAlive.name,
          signature:
              'static Future<void> disposeKeepAlive(${InAppWebViewKeepAlive} keepAlive)',
          description: 'Disposes a keep-alive instance.',
          className: className,
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod.clearAllCache.name,
          signature:
              'static Future<void> clearAllCache({bool includeDiskFiles = true})',
          description: 'Clears all WebView caches.',
          className: className,
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: PlatformInAppWebViewControllerMethod
              .enableSlowWholeDocumentDraw
              .name,
          signature: 'static Future<void> enableSlowWholeDocumentDraw()',
          description: 'Enables slow whole document draw.',
          className: className,
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name:
              PlatformInAppWebViewControllerMethod.setJavaScriptBridgeName.name,
          signature:
              'static Future<void> setJavaScriptBridgeName(String bridgeName)',
          description: 'Sets the JavaScript bridge name.',
          className: className,
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name:
              PlatformInAppWebViewControllerMethod.getJavaScriptBridgeName.name,
          signature: 'static Future<String> getJavaScriptBridgeName()',
          description: 'Gets the JavaScript bridge name.',
          className: className,
          isStatic: true,
          category: 'Static',
        ),
      ],
    );
  }

  static ApiClassDefinition _getInAppWebViewEventsDefinition() {
    final className = eventClassNameOf(InAppWebView);
    return ApiClassDefinition(
      className: className,
      description: 'Events fired by ${InAppWebView}.',
      events: [
        // Core events
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onWebViewCreated.name,
          description: 'Called when the WebView is created.',
          className: className,
          category: 'Core',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onLoadStart.name,
          description: 'Called when a page starts loading.',
          className: className,
          category: 'Core',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onLoadStop.name,
          description: 'Called when a page finishes loading.',
          className: className,
          category: 'Core',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onLoadError.name,
          description: 'Called when a page fails to load.',
          className: className,
          category: 'Core',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onLoadHttpError.name,
          description: 'Called when an HTTP error is received.',
          className: className,
          category: 'Core',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onProgressChanged.name,
          description: 'Called when the loading progress changes.',
          className: className,
          category: 'Core',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onConsoleMessage.name,
          description: 'Called when a console message is received.',
          className: className,
          category: 'Core',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onTitleChanged.name,
          description: 'Called when the page title changes.',
          className: className,
          category: 'Core',
        ),
        ApiEventDefinition(
          name:
              PlatformWebViewCreationParamsProperty.onUpdateVisitedHistory.name,
          description: 'Called when the visited history is updated.',
          className: className,
          category: 'Core',
        ),

        // Navigation events
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty
              .shouldOverrideUrlLoading
              .name,
          description: 'Called to handle URL navigation requests.',
          className: className,
          category: 'Navigation',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onNavigationResponse.name,
          description: 'Called when receiving a navigation response.',
          className: className,
          category: 'Navigation',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty
              .shouldAllowDeprecatedTLS
              .name,
          description: 'Called to check if deprecated TLS should be allowed.',
          className: className,
          category: 'Navigation',
        ),

        // Window events
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onCreateWindow.name,
          description: 'Called when a new window is requested.',
          className: className,
          category: 'Window',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onCloseWindow.name,
          description: 'Called when a window should be closed.',
          className: className,
          category: 'Window',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onWindowFocus.name,
          description: 'Called when the window receives focus.',
          className: className,
          category: 'Window',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onWindowBlur.name,
          description: 'Called when the window loses focus.',
          className: className,
          category: 'Window',
        ),

        // JS Dialog events
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onJsAlert.name,
          description: 'Called when a JavaScript alert is shown.',
          className: className,
          category: 'JS Dialogs',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onJsConfirm.name,
          description: 'Called when a JavaScript confirm is shown.',
          className: className,
          category: 'JS Dialogs',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onJsPrompt.name,
          description: 'Called when a JavaScript prompt is shown.',
          className: className,
          category: 'JS Dialogs',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onJsBeforeUnload.name,
          description: 'Called before the page is unloaded.',
          className: className,
          category: 'JS Dialogs',
        ),

        // Authentication events
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty
              .onReceivedHttpAuthRequest
              .name,
          description: 'Called for HTTP authentication requests.',
          className: className,
          category: 'Authentication',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty
              .onReceivedServerTrustAuthRequest
              .name,
          description: 'Called for server trust authentication.',
          className: className,
          category: 'Authentication',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty
              .onReceivedClientCertRequest
              .name,
          description: 'Called when a client certificate is requested.',
          className: className,
          category: 'Authentication',
        ),

        // Network events
        ApiEventDefinition(
          name:
              PlatformWebViewCreationParamsProperty.shouldInterceptRequest.name,
          description: 'Called to intercept resource requests.',
          className: className,
          category: 'Network',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onLoadResource.name,
          description: 'Called when a resource is loaded.',
          className: className,
          category: 'Network',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty
              .onLoadResourceWithCustomScheme
              .name,
          description: 'Called when loading a custom scheme resource.',
          className: className,
          category: 'Network',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onReceivedError.name,
          description: 'Called when a resource load error occurs.',
          className: className,
          category: 'Network',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onReceivedHttpError.name,
          description: 'Called when an HTTP error occurs.',
          className: className,
          category: 'Network',
        ),

        // Download events
        ApiEventDefinition(
          name:
              PlatformWebViewCreationParamsProperty.onDownloadStartRequest.name,
          description: 'Called when a download is requested.',
          className: className,
          category: 'Download',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onDownloadStarting.name,
          description: 'Called when a download is starting.',
          className: className,
          category: 'Download',
        ),

        // Scroll events
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onScrollChanged.name,
          description: 'Called when the scroll position changes.',
          className: className,
          category: 'Scroll',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onOverScrolled.name,
          description: 'Called when the WebView is over-scrolled.',
          className: className,
          category: 'Scroll',
        ),

        // Zoom events
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onZoomScaleChanged.name,
          description: 'Called when the zoom scale changes.',
          className: className,
          category: 'Zoom',
        ),

        // Print events
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onPrintRequest.name,
          description: 'Called when a print request is made.',
          className: className,
          category: 'Print',
        ),

        // Fullscreen events
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onEnterFullscreen.name,
          description: 'Called when entering fullscreen mode.',
          className: className,
          category: 'Fullscreen',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onExitFullscreen.name,
          description: 'Called when exiting fullscreen mode.',
          className: className,
          category: 'Fullscreen',
        ),

        // Permission events
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onPermissionRequest.name,
          description: 'Called when a permission is requested.',
          className: className,
          category: 'Permission',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty
              .onPermissionRequestCanceled
              .name,
          description: 'Called when a permission request is canceled.',
          className: className,
          category: 'Permission',
        ),

        // Touch/Gesture events
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty
              .onLongPressHitTestResult
              .name,
          description: 'Called on a long press.',
          className: className,
          category: 'Touch',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty
              .onGeolocationPermissionsShowPrompt
              .name,
          description: 'Called when requesting geolocation permission.',
          className: className,
          category: 'Permission',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty
              .onGeolocationPermissionsHidePrompt
              .name,
          description: 'Called when hiding geolocation permission prompt.',
          className: className,
          category: 'Permission',
        ),

        // Render Process events
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onRenderProcessGone.name,
          description: 'Called when the render process terminates.',
          className: className,
          category: 'Render Process',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty
              .onRenderProcessResponsive
              .name,
          description: 'Called when the render process becomes responsive.',
          className: className,
          category: 'Render Process',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty
              .onRenderProcessUnresponsive
              .name,
          description: 'Called when the render process becomes unresponsive.',
          className: className,
          category: 'Render Process',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty
              .onWebContentProcessDidTerminate
              .name,
          description: 'Called when the web content process terminates.',
          className: className,
          category: 'Render Process',
        ),

        // Form events
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onFormResubmission.name,
          description: 'Called when a form is resubmitted.',
          className: className,
          category: 'Form',
        ),

        // Icon events
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onReceivedIcon.name,
          description: 'Called when a favicon is received.',
          className: className,
          category: 'Icon',
        ),
        ApiEventDefinition(
          name:
              PlatformWebViewCreationParamsProperty.onReceivedTouchIconUrl.name,
          description: 'Called when a touch icon URL is received.',
          className: className,
          category: 'Icon',
        ),

        // Safe Browsing events
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onSafeBrowsingHit.name,
          description: 'Called when Safe Browsing detects a threat.',
          className: className,
          category: 'Safe Browsing',
        ),

        // iOS/macOS events
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty
              .onDidReceiveServerRedirectForProvisionalNavigation
              .name,
          description: 'Called when a server redirect is received.',
          className: className,
          category: 'iOS/macOS',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty
              .onCameraCaptureStateChanged
              .name,
          description: 'Called when camera capture state changes.',
          className: className,
          category: 'iOS/macOS',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty
              .onMicrophoneCaptureStateChanged
              .name,
          description: 'Called when microphone capture state changes.',
          className: className,
          category: 'iOS/macOS',
        ),

        // Windows events
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onProcessFailed.name,
          description: 'Called when a process failure occurs.',
          className: className,
          category: 'Windows',
        ),

        // Other events
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onPageCommitVisible.name,
          description: 'Called when the page becomes visible.',
          className: className,
          category: 'Other',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onContentSizeChanged.name,
          description: 'Called when the content size changes.',
          className: className,
          category: 'Other',
        ),
        ApiEventDefinition(
          name:
              PlatformWebViewCreationParamsProperty.onAjaxReadyStateChange.name,
          description: 'Called when an AJAX ready state changes.',
          className: className,
          category: 'Other',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty.onAjaxProgress.name,
          description: 'Called for AJAX progress updates.',
          className: className,
          category: 'Other',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty
              .shouldInterceptAjaxRequest
              .name,
          description: 'Called to intercept AJAX requests.',
          className: className,
          category: 'Other',
        ),
        ApiEventDefinition(
          name: PlatformWebViewCreationParamsProperty
              .shouldInterceptFetchRequest
              .name,
          description: 'Called to intercept fetch requests.',
          className: className,
          category: 'Other',
        ),
      ],
    );
  }

  static ApiClassDefinition _getHeadlessInAppWebViewDefinition() {
    final className = classNameOf(HeadlessInAppWebView);
    return ApiClassDefinition(
      className: className,
      description: 'A WebView that runs without UI.',
      isClassSupported: () => HeadlessInAppWebView.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: PlatformHeadlessInAppWebViewMethod.run.name,
          signature: 'Future<void> run()',
          description: 'Runs the headless WebView.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformHeadlessInAppWebViewMethod.isRunning.name,
          signature: 'Future<bool> isRunning()',
          description: 'Checks if the WebView is running.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformHeadlessInAppWebViewMethod.setSize.name,
          signature: 'Future<void> setSize(Size size)',
          description: 'Sets the WebView size.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformHeadlessInAppWebViewMethod.getSize.name,
          signature: 'Future<Size?> getSize()',
          description: 'Gets the WebView size.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformHeadlessInAppWebViewMethod.dispose.name,
          signature: 'Future<void> dispose()',
          description: 'Disposes the headless WebView.',
          className: className,
        ),
      ],
    );
  }

  static ApiClassDefinition _getInAppBrowserDefinition() {
    final className = classNameOf(InAppBrowser);
    return ApiClassDefinition(
      className: className,
      description: 'A full-screen in-app browser.',
      isClassSupported: () => InAppBrowser.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: PlatformInAppBrowserMethod.openUrlRequest.name,
          signature:
              'Future<void> openUrlRequest({required URLRequest urlRequest, ...})',
          description: 'Opens a URL in the browser.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformInAppBrowserMethod.openFile.name,
          signature:
              'Future<void> openFile({required String assetFilePath, ...})',
          description: 'Opens a file from assets.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformInAppBrowserMethod.openData.name,
          signature: 'Future<void> openData({required String data, ...})',
          description: 'Opens HTML data.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformInAppBrowserMethod.openWithSystemBrowser.name,
          signature:
              'static Future<void> openWithSystemBrowser({required WebUri url})',
          description: 'Opens a URL in the system browser.',
          className: className,
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: PlatformInAppBrowserMethod.show.name,
          signature: 'Future<void> show()',
          description: 'Shows the browser.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformInAppBrowserMethod.hide.name,
          signature: 'Future<void> hide()',
          description: 'Hides the browser.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformInAppBrowserMethod.close.name,
          signature: 'Future<void> close()',
          description: 'Closes the browser.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformInAppBrowserMethod.isHidden.name,
          signature: 'Future<bool> isHidden()',
          description: 'Checks if the browser is hidden.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformInAppBrowserMethod.setSettings.name,
          signature:
              'Future<void> ${PlatformInAppBrowserMethod.setSettings.name}({required ${InAppBrowserClassSettings} settings})',
          description: 'Sets the browser settings.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformInAppBrowserMethod.getSettings.name,
          signature:
              'Future<${InAppBrowserClassSettings}?> ${PlatformInAppBrowserMethod.getSettings.name}()',
          description: 'Gets the browser settings.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformInAppBrowserMethod.isOpened.name,
          signature: 'bool isOpened()',
          description: 'Checks if the browser is opened.',
          className: className,
        ),
      ],
      events: [
        ApiEventDefinition(
          name: PlatformInAppBrowserEventsMethod.onBrowserCreated.name,
          description: 'Called when the browser is created.',
          className: className,
        ),
        ApiEventDefinition(
          name: PlatformInAppBrowserEventsMethod.onExit.name,
          description: 'Called when the browser exits.',
          className: className,
        ),
        ApiEventDefinition(
          name: PlatformInAppBrowserEventsMethod.onMainWindowWillClose.name,
          description: 'Called when the main window will close.',
          className: className,
        ),
      ],
    );
  }

  static ApiClassDefinition _getChromeSafariBrowserDefinition() {
    final className = classNameOf(ChromeSafariBrowser);
    return ApiClassDefinition(
      className: className,
      description:
          'A browser using Chrome Custom Tabs or SFSafariViewController.',
      isClassSupported: () => ChromeSafariBrowser.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: PlatformChromeSafariBrowserMethod.open.name,
          signature: 'Future<void> open({WebUri? url, ...})',
          description: 'Opens a URL in the browser.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformChromeSafariBrowserMethod.launchUrl.name,
          signature: 'Future<void> launchUrl({required WebUri url, ...})',
          description: 'Launches a URL.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformChromeSafariBrowserMethod.mayLaunchUrl.name,
          signature: 'Future<bool> mayLaunchUrl({WebUri? url, ...})',
          description: 'Hints to the browser to start loading a URL.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformChromeSafariBrowserMethod.validateRelationship.name,
          signature:
              'Future<bool> validateRelationship({required CustomTabsRelationType relation, ...})',
          description: 'Validates a relationship.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformChromeSafariBrowserMethod.close.name,
          signature: 'Future<void> close()',
          description: 'Closes the browser.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformChromeSafariBrowserMethod.isOpened.name,
          signature: 'bool isOpened()',
          description: 'Checks if the browser is opened.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformChromeSafariBrowserMethod.isAvailable.name,
          signature: 'static Future<bool> isAvailable()',
          description: 'Checks if the browser is available.',
          className: className,
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: PlatformChromeSafariBrowserMethod.getMaxToolbarItems.name,
          signature: 'static Future<int> getMaxToolbarItems()',
          description: 'Gets the maximum toolbar items.',
          className: className,
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: PlatformChromeSafariBrowserMethod.getPackageName.name,
          signature:
              'static Future<String?> getPackageName({List<String>? packages, ...})',
          description: 'Gets the package name for Custom Tabs.',
          className: className,
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: PlatformChromeSafariBrowserMethod.clearWebsiteData.name,
          signature: 'static Future<void> clearWebsiteData()',
          description: 'Clears website data.',
          className: className,
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: PlatformChromeSafariBrowserMethod.prewarmConnections.name,
          signature:
              'static Future<PrewarmingToken?> prewarmConnections({required List<WebUri> urls})',
          description: 'Prewarms connections.',
          className: className,
          isStatic: true,
        ),
        ApiMethodDefinition(
          name:
              PlatformChromeSafariBrowserMethod.invalidatePrewarmingToken.name,
          signature:
              'static Future<void> invalidatePrewarmingToken({required PrewarmingToken prewarmingToken})',
          description: 'Invalidates a prewarming token.',
          className: className,
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: PlatformChromeSafariBrowserMethod.setActionButton.name,
          signature:
              'Future<void> ${PlatformChromeSafariBrowserMethod.setActionButton.name}(${ChromeSafariBrowserActionButton} actionButton)',
          description: 'Sets an action button.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformChromeSafariBrowserMethod.updateActionButton.name,
          signature:
              'Future<void> updateActionButton({required Uint8List icon, required String description})',
          description: 'Updates the action button.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformChromeSafariBrowserMethod.setSecondaryToolbar.name,
          signature:
              'Future<void> ${PlatformChromeSafariBrowserMethod.setSecondaryToolbar.name}(${ChromeSafariBrowserSecondaryToolbar} secondaryToolbar)',
          description: 'Sets a secondary toolbar.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformChromeSafariBrowserMethod.updateSecondaryToolbar.name,
          signature:
              'Future<void> ${PlatformChromeSafariBrowserMethod.updateSecondaryToolbar.name}(${ChromeSafariBrowserSecondaryToolbar} secondaryToolbar)',
          description: 'Updates the secondary toolbar.',
          className: className,
        ),
        ApiMethodDefinition(
          name:
              PlatformChromeSafariBrowserMethod.requestPostMessageChannel.name,
          signature:
              'Future<bool> requestPostMessageChannel({required WebUri sourceOrigin, ...})',
          description: 'Requests a post message channel.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformChromeSafariBrowserMethod.postMessage.name,
          signature:
              'Future<CustomTabsPostMessageResultType> postMessage({required String message})',
          description: 'Posts a message.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformChromeSafariBrowserMethod
              .isEngagementSignalsApiAvailable
              .name,
          signature: 'Future<bool> isEngagementSignalsApiAvailable()',
          description: 'Checks if engagement signals API is available.',
          className: className,
        ),
      ],
      events: [
        ApiEventDefinition(
          name: PlatformChromeSafariBrowserEventsMethod.onOpened.name,
          description: 'Called when the browser is opened.',
          className: className,
        ),
        ApiEventDefinition(
          name: PlatformChromeSafariBrowserEventsMethod.onClosed.name,
          description: 'Called when the browser is closed.',
          className: className,
        ),
        ApiEventDefinition(
          name: PlatformChromeSafariBrowserEventsMethod
              .onCompletedInitialLoad
              .name,
          description: 'Called when the initial load completes.',
          className: className,
        ),
        ApiEventDefinition(
          name: PlatformChromeSafariBrowserEventsMethod
              .onInitialLoadDidRedirect
              .name,
          description: 'Called when the initial load redirects.',
          className: className,
        ),
        ApiEventDefinition(
          name:
              PlatformChromeSafariBrowserEventsMethod.onWillOpenInBrowser.name,
          description: 'Called when opening in the browser.',
          className: className,
        ),
        ApiEventDefinition(
          name: PlatformChromeSafariBrowserEventsMethod.onNavigationEvent.name,
          description: 'Called on navigation events.',
          className: className,
        ),
        ApiEventDefinition(
          name: PlatformChromeSafariBrowserEventsMethod.onServiceConnected.name,
          description: 'Called when the service connects.',
          className: className,
        ),
        ApiEventDefinition(
          name: PlatformChromeSafariBrowserEventsMethod
              .onRelationshipValidationResult
              .name,
          description: 'Called with relationship validation results.',
          className: className,
        ),
        ApiEventDefinition(
          name: PlatformChromeSafariBrowserEventsMethod
              .onMessageChannelReady
              .name,
          description: 'Called when the message channel is ready.',
          className: className,
        ),
        ApiEventDefinition(
          name: PlatformChromeSafariBrowserEventsMethod.onPostMessage.name,
          description: 'Called when a post message is received.',
          className: className,
        ),
        ApiEventDefinition(
          name: PlatformChromeSafariBrowserEventsMethod
              .onVerticalScrollEvent
              .name,
          description: 'Called on vertical scroll events.',
          className: className,
        ),
        ApiEventDefinition(
          name: PlatformChromeSafariBrowserEventsMethod
              .onGreatestScrollPercentageIncreased
              .name,
          description: 'Called when the greatest scroll percentage increases.',
          className: className,
        ),
        ApiEventDefinition(
          name: PlatformChromeSafariBrowserEventsMethod.onSessionEnded.name,
          description: 'Called when the session ends.',
          className: className,
        ),
      ],
    );
  }

  static ApiClassDefinition _getCookieManagerDefinition() {
    final className = classNameOf(CookieManager);
    return ApiClassDefinition(
      className: className,
      description: 'Manages cookies for WebViews.',
      isClassSupported: () => CookieManager.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: PlatformCookieManagerMethod.setCookie.name,
          signature:
              'Future<bool> setCookie({required WebUri url, required String name, required String value, ...})',
          description: 'Sets a cookie.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformCookieManagerMethod.getCookies.name,
          signature: 'Future<List<Cookie>> getCookies({required WebUri url})',
          description: 'Gets all cookies for a URL.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformCookieManagerMethod.getCookie.name,
          signature:
              'Future<Cookie?> getCookie({required WebUri url, required String name})',
          description: 'Gets a specific cookie.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformCookieManagerMethod.deleteCookie.name,
          signature:
              'Future<void> deleteCookie({required WebUri url, required String name, ...})',
          description: 'Deletes a cookie.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformCookieManagerMethod.deleteCookies.name,
          signature:
              'Future<void> deleteCookies({required WebUri url, String? domain, String? path})',
          description: 'Deletes cookies for a URL.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformCookieManagerMethod.deleteAllCookies.name,
          signature: 'Future<void> deleteAllCookies()',
          description: 'Deletes all cookies.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformCookieManagerMethod.removeSessionCookies.name,
          signature: 'Future<bool> removeSessionCookies()',
          description: 'Removes all session cookies.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformCookieManagerMethod.flush.name,
          signature: 'Future<void> flush()',
          description: 'Flushes cookies to persistent storage.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformCookieManagerMethod.getAllCookies.name,
          signature: 'Future<List<Cookie>> getAllCookies()',
          description: 'Gets all cookies.',
          className: className,
        ),
      ],
    );
  }

  static ApiClassDefinition _getWebStorageDefinition() {
    final className = classNameOf(WebStorage);
    return ApiClassDefinition(
      className: className,
      description: 'Manages ${LocalStorage} and ${SessionStorage}.',
      isClassSupported: () => WebStorage.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: PlatformLocalStorageMethod.length.name,
          signature: 'Future<int?> length()',
          description: 'Gets the number of items.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformLocalStorageMethod.setItem.name,
          signature:
              'Future<void> setItem({required String key, required dynamic value})',
          description: 'Sets an item.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformLocalStorageMethod.getItem.name,
          signature: 'Future<dynamic> getItem({required String key})',
          description: 'Gets an item.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformLocalStorageMethod.removeItem.name,
          signature: 'Future<void> removeItem({required String key})',
          description: 'Removes an item.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformLocalStorageMethod.getItems.name,
          signature:
              'Future<List<${WebStorageItem}>> ${PlatformLocalStorageMethod.getItems.name}()',
          description: 'Gets all items.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformLocalStorageMethod.clear.name,
          signature: 'Future<void> clear()',
          description: 'Clears all items.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformLocalStorageMethod.key.name,
          signature: 'Future<String> key({required int index})',
          description: 'Gets the key at an index.',
          className: className,
        ),
      ],
    );
  }

  static ApiClassDefinition _getFindInteractionControllerDefinition() {
    final className = classNameOf(FindInteractionController);
    return ApiClassDefinition(
      className: className,
      description: 'Controls find-in-page functionality.',
      isClassSupported: () => FindInteractionController.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: PlatformFindInteractionControllerMethod.findAll.name,
          signature: 'Future<void> findAll({String? find})',
          description: 'Finds all occurrences.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformFindInteractionControllerMethod.findNext.name,
          signature: 'Future<void> findNext({bool forward = true})',
          description: 'Finds the next occurrence.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformFindInteractionControllerMethod.clearMatches.name,
          signature: 'Future<void> clearMatches()',
          description: 'Clears all matches.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformFindInteractionControllerMethod.setSearchText.name,
          signature: 'Future<void> setSearchText(String? searchText)',
          description: 'Sets the search text.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformFindInteractionControllerMethod.getSearchText.name,
          signature: 'Future<String?> getSearchText()',
          description: 'Gets the search text.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformFindInteractionControllerMethod
              .isFindNavigatorVisible
              .name,
          signature: 'Future<bool?> isFindNavigatorVisible()',
          description: 'Checks if the find navigator is visible.',
          className: className,
        ),
        ApiMethodDefinition(
          name:
              PlatformFindInteractionControllerMethod.presentFindNavigator.name,
          signature: 'Future<void> presentFindNavigator()',
          description: 'Presents the find navigator.',
          className: className,
        ),
        ApiMethodDefinition(
          name:
              PlatformFindInteractionControllerMethod.dismissFindNavigator.name,
          signature: 'Future<void> dismissFindNavigator()',
          description: 'Dismisses the find navigator.',
          className: className,
        ),
        ApiMethodDefinition(
          name:
              PlatformFindInteractionControllerMethod.getActiveFindSession.name,
          signature: 'Future<FindSession?> getActiveFindSession()',
          description: 'Gets the active find session.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformFindInteractionControllerMethod.dispose.name,
          signature: 'void dispose()',
          description: 'Disposes the controller.',
          className: className,
        ),
      ],
      events: [
        ApiEventDefinition(
          name: PlatformFindInteractionControllerCreationParamsProperty
              .onFindResultReceived
              .name,
          description: 'Called when find results are received.',
          className: className,
        ),
      ],
    );
  }

  static ApiClassDefinition _getPullToRefreshControllerDefinition() {
    final className = classNameOf(PullToRefreshController);
    return ApiClassDefinition(
      className: className,
      description: 'Controls pull-to-refresh functionality.',
      isClassSupported: () => PullToRefreshController.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: PlatformPullToRefreshControllerMethod.setEnabled.name,
          signature: 'Future<void> setEnabled(bool enabled)',
          description: 'Enables or disables pull-to-refresh.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformPullToRefreshControllerMethod.isEnabled.name,
          signature: 'Future<bool> isEnabled()',
          description: 'Checks if pull-to-refresh is enabled.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformPullToRefreshControllerMethod.beginRefreshing.name,
          signature: 'Future<void> beginRefreshing()',
          description: 'Starts the refresh animation.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformPullToRefreshControllerMethod.endRefreshing.name,
          signature: 'Future<void> endRefreshing()',
          description: 'Stops the refresh animation.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformPullToRefreshControllerMethod.isRefreshing.name,
          signature: 'Future<bool> isRefreshing()',
          description: 'Checks if currently refreshing.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformPullToRefreshControllerMethod.setColor.name,
          signature: 'Future<void> setColor(Color color)',
          description: 'Sets the indicator color.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformPullToRefreshControllerMethod.setBackgroundColor.name,
          signature: 'Future<void> setBackgroundColor(Color color)',
          description: 'Sets the background color.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformPullToRefreshControllerMethod
              .setDistanceToTriggerSync
              .name,
          signature:
              'Future<void> setDistanceToTriggerSync(double distanceToTrigger)',
          description: 'Sets the distance to trigger refresh.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformPullToRefreshControllerMethod.setSlingshotDistance.name,
          signature:
              'Future<void> setSlingshotDistance(double slingshotDistance)',
          description: 'Sets the slingshot distance.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformPullToRefreshControllerMethod
              .getDefaultSlingshotDistance
              .name,
          signature: 'Future<double> getDefaultSlingshotDistance()',
          description: 'Gets the default slingshot distance.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformPullToRefreshControllerMethod.setIndicatorSize.name,
          signature: 'Future<void> setIndicatorSize(PullToRefreshSize size)',
          description: 'Sets the indicator size.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformPullToRefreshControllerMethod.dispose.name,
          signature: 'void dispose()',
          description: 'Disposes the controller.',
          className: className,
        ),
      ],
      events: [
        ApiEventDefinition(
          name: PlatformPullToRefreshControllerCreationParamsProperty
              .onRefresh
              .name,
          description: 'Called when a refresh is triggered.',
          className: className,
        ),
      ],
    );
  }

  static ApiClassDefinition _getPrintJobControllerDefinition() {
    final className = classNameOf(PrintJobController);
    return ApiClassDefinition(
      className: className,
      description: 'Controls print jobs.',
      isClassSupported: () => PrintJobController.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: PlatformPrintJobControllerMethod.cancel.name,
          signature: 'Future<void> cancel()',
          description: 'Cancels the print job.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformPrintJobControllerMethod.restart.name,
          signature: 'Future<void> restart()',
          description: 'Restarts the print job.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformPrintJobControllerMethod.dismiss.name,
          signature: 'Future<void> dismiss({bool animated = true})',
          description: 'Dismisses the print interface.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformPrintJobControllerMethod.getInfo.name,
          signature: 'Future<PrintJobInfo?> getInfo()',
          description: 'Gets the print job info.',
          className: className,
        ),
      ],
      events: [
        ApiEventDefinition(
          name: PlatformPrintJobControllerProperty.onComplete.name,
          description: 'Called when the print job completes.',
          className: className,
        ),
      ],
    );
  }

  static ApiClassDefinition _getWebAuthenticationSessionDefinition() {
    final className = classNameOf(WebAuthenticationSession);
    return ApiClassDefinition(
      className: className,
      description: 'Handles web authentication sessions.',
      isClassSupported: () => WebAuthenticationSession.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: PlatformWebAuthenticationSessionMethod.create.name,
          signature:
              'static Future<${WebAuthenticationSession}> ${PlatformWebAuthenticationSessionMethod.create.name}({...})',
          description: 'Creates a new authentication session.',
          className: className,
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: PlatformWebAuthenticationSessionMethod.canStart.name,
          signature: 'Future<bool> canStart()',
          description: 'Checks if the session can start.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformWebAuthenticationSessionMethod.start.name,
          signature: 'Future<void> start()',
          description: 'Starts the authentication session.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformWebAuthenticationSessionMethod.cancel.name,
          signature: 'Future<void> cancel()',
          description: 'Cancels the session.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformWebAuthenticationSessionMethod.dispose.name,
          signature: 'Future<void> dispose()',
          description: 'Disposes the session.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformWebAuthenticationSessionMethod.isAvailable.name,
          signature: 'static Future<bool> isAvailable()',
          description: 'Checks if web authentication is available.',
          className: className,
          isStatic: true,
        ),
      ],
      events: [
        ApiEventDefinition(
          name: PlatformWebAuthenticationSessionProperty.onComplete.name,
          description: 'Called when authentication completes.',
          className: className,
        ),
      ],
    );
  }

  static ApiClassDefinition _getServiceWorkerControllerDefinition() {
    final className = classNameOf(ServiceWorkerController);
    return ApiClassDefinition(
      className: className,
      description: 'Controls service workers.',
      isClassSupported: () => ServiceWorkerController.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name:
              PlatformServiceWorkerControllerMethod.setServiceWorkerClient.name,
          signature:
              'Future<void> setServiceWorkerClient(ServiceWorkerClient? value)',
          description: 'Sets the service worker client.',
          className: className,
        ),
        ApiMethodDefinition(
          name:
              PlatformServiceWorkerControllerMethod.getAllowContentAccess.name,
          signature: 'Future<bool> getAllowContentAccess()',
          description: 'Gets allow content access setting.',
          className: className,
        ),
        ApiMethodDefinition(
          name:
              PlatformServiceWorkerControllerMethod.setAllowContentAccess.name,
          signature: 'Future<void> setAllowContentAccess(bool allow)',
          description: 'Sets allow content access setting.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformServiceWorkerControllerMethod.getAllowFileAccess.name,
          signature: 'Future<bool> getAllowFileAccess()',
          description: 'Gets allow file access setting.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformServiceWorkerControllerMethod.setAllowFileAccess.name,
          signature: 'Future<void> setAllowFileAccess(bool allow)',
          description: 'Sets allow file access setting.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformServiceWorkerControllerMethod.getBlockNetworkLoads.name,
          signature: 'Future<bool> getBlockNetworkLoads()',
          description: 'Gets block network loads setting.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformServiceWorkerControllerMethod.setBlockNetworkLoads.name,
          signature: 'Future<void> setBlockNetworkLoads(bool block)',
          description: 'Sets block network loads setting.',
          className: className,
        ),
      ],
      events: [
        ApiEventDefinition(
          name: ServiceWorkerClientProperty.shouldInterceptRequest.name,
          description: 'Called to intercept service worker requests.',
          className: className,
        ),
      ],
    );
  }

  static ApiClassDefinition _getProxyControllerDefinition() {
    final className = classNameOf(ProxyController);
    return ApiClassDefinition(
      className: className,
      description: 'Controls proxy settings.',
      isClassSupported: () => ProxyController.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: PlatformProxyControllerMethod.setProxyOverride.name,
          signature:
              'Future<void> setProxyOverride({required ProxySettings settings})',
          description: 'Sets the proxy override.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformProxyControllerMethod.clearProxyOverride.name,
          signature: 'Future<void> clearProxyOverride()',
          description: 'Clears the proxy override.',
          className: className,
        ),
      ],
    );
  }

  static ApiClassDefinition _getTracingControllerDefinition() {
    final className = classNameOf(TracingController);
    return ApiClassDefinition(
      className: className,
      description: 'Controls tracing.',
      isClassSupported: () => TracingController.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: PlatformTracingControllerMethod.start.name,
          signature: 'Future<void> start({required TracingSettings settings})',
          description: 'Starts tracing.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformTracingControllerMethod.stop.name,
          signature: 'Future<bool> stop({String? filePath})',
          description: 'Stops tracing.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformTracingControllerMethod.isTracing.name,
          signature: 'Future<bool> isTracing()',
          description: 'Checks if tracing is active.',
          className: className,
        ),
      ],
    );
  }

  static ApiClassDefinition _getHttpAuthCredentialDatabaseDefinition() {
    final className = classNameOf(HttpAuthCredentialDatabase);
    return ApiClassDefinition(
      className: className,
      description: 'Manages HTTP authentication credentials.',
      isClassSupported: () => HttpAuthCredentialDatabase.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: PlatformHttpAuthCredentialDatabaseMethod
              .getAllAuthCredentials
              .name,
          signature:
              'Future<List<URLProtectionSpaceHttpAuthCredentials>> getAllAuthCredentials()',
          description: 'Gets all stored credentials.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformHttpAuthCredentialDatabaseMethod
              .getHttpAuthCredentials
              .name,
          signature:
              'Future<List<URLCredential>> getHttpAuthCredentials({...})',
          description: 'Gets credentials for a protection space.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformHttpAuthCredentialDatabaseMethod
              .setHttpAuthCredential
              .name,
          signature: 'Future<void> setHttpAuthCredential({...})',
          description: 'Sets a credential.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformHttpAuthCredentialDatabaseMethod
              .removeHttpAuthCredential
              .name,
          signature: 'Future<void> removeHttpAuthCredential({...})',
          description: 'Removes a credential.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformHttpAuthCredentialDatabaseMethod
              .removeHttpAuthCredentials
              .name,
          signature: 'Future<void> removeHttpAuthCredentials({...})',
          description: 'Removes all credentials for a protection space.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformHttpAuthCredentialDatabaseMethod
              .clearAllAuthCredentials
              .name,
          signature: 'Future<void> clearAllAuthCredentials()',
          description: 'Clears all credentials.',
          className: className,
        ),
      ],
    );
  }

  static ApiClassDefinition _getWebViewEnvironmentDefinition() {
    final className = classNameOf(WebViewEnvironment);
    return ApiClassDefinition(
      className: className,
      description: 'WebView2 environment for Windows.',
      isClassSupported: () => WebViewEnvironment.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: PlatformWebViewEnvironmentMethod.create.name,
          signature:
              'static Future<${WebViewEnvironment}> ${PlatformWebViewEnvironmentMethod.create.name}({...})',
          description: 'Creates a WebView environment.',
          className: className,
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: PlatformWebViewEnvironmentMethod.getAvailableVersion.name,
          signature:
              'static Future<String?> getAvailableVersion({String? browserExecutableFolder})',
          description: 'Gets the available WebView2 version.',
          className: className,
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: PlatformWebViewEnvironmentMethod.getProcessInfos.name,
          signature: 'Future<List<BrowserProcessInfo>> getProcessInfos()',
          description: 'Gets running process information.',
          className: className,
        ),
        ApiMethodDefinition(
          name: PlatformWebViewEnvironmentMethod.compareBrowserVersions.name,
          signature: 'static Future<int> compareBrowserVersions({...})',
          description: 'Compares browser versions.',
          className: className,
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: PlatformWebViewEnvironmentMethod.dispose.name,
          signature: 'Future<void> dispose()',
          description: 'Disposes the environment.',
          className: className,
        ),
      ],
      events: [
        ApiEventDefinition(
          name: PlatformWebViewEnvironmentProperty.onBrowserProcessExited.name,
          description: 'Called when the browser process exits.',
          className: className,
        ),
        ApiEventDefinition(
          name: PlatformWebViewEnvironmentProperty.onProcessInfosChanged.name,
          description: 'Called when process info changes.',
          className: className,
        ),
        ApiEventDefinition(
          name: PlatformWebViewEnvironmentProperty
              .onNewBrowserVersionAvailable
              .name,
          description: 'Called when a new browser version is available.',
          className: className,
        ),
      ],
    );
  }

  static ApiClassDefinition _getProcessGlobalConfigDefinition() {
    final className = classNameOf(ProcessGlobalConfig);
    return ApiClassDefinition(
      className: className,
      description: 'Global process configuration for Android.',
      isClassSupported: () => ProcessGlobalConfig.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: PlatformProcessGlobalConfigMethod.apply.name,
          signature:
              'Future<void> ${PlatformProcessGlobalConfigMethod.apply.name}({required ${ProcessGlobalConfigSettings} settings})',
          description: 'Applies global configuration settings.',
          className: className,
        ),
      ],
    );
  }

  static ApiClassDefinition _getWebMessageChannelDefinition() {
    final className = classNameOf(WebMessageChannel);
    return ApiClassDefinition(
      className: className,
      description: 'HTML5 message channel for two-way communication.',
      isClassSupported: () => WebMessageChannel.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: PlatformWebMessageChannelMethod.dispose.name,
          signature: 'void dispose()',
          description: 'Disposes the channel.',
          className: className,
        ),
      ],
    );
  }
}
