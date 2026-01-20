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
    return ApiClassDefinition(
      className: 'InAppWebViewController',
      description: 'Controls an InAppWebView instance.',
      isClassSupported: () => InAppWebViewController.isClassSupported(),
      methods: [
        // Navigation methods
        ApiMethodDefinition(
          name: 'loadUrl',
          signature: 'Future<void> loadUrl({required URLRequest urlRequest})',
          description: 'Loads the given URL with optional headers.',
          className: 'InAppWebViewController',
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'postUrl',
          signature:
              'Future<void> postUrl({required WebUri url, required Uint8List postData})',
          description: 'Loads the URL with POST data.',
          className: 'InAppWebViewController',
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'loadData',
          signature: 'Future<void> loadData({required String data, ...})',
          description: 'Loads HTML data directly into the WebView.',
          className: 'InAppWebViewController',
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'loadFile',
          signature: 'Future<void> loadFile({required String assetFilePath})',
          description: 'Loads a file from the asset bundle.',
          className: 'InAppWebViewController',
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'reload',
          signature: 'Future<void> reload()',
          description: 'Reloads the current page.',
          className: 'InAppWebViewController',
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'reloadFromOrigin',
          signature: 'Future<void> reloadFromOrigin()',
          description:
              'Reloads the current page, performing end-to-end validation.',
          className: 'InAppWebViewController',
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'goBack',
          signature: 'Future<void> goBack()',
          description: 'Goes back in the history of the WebView.',
          className: 'InAppWebViewController',
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'goForward',
          signature: 'Future<void> goForward()',
          description: 'Goes forward in the history of the WebView.',
          className: 'InAppWebViewController',
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'goBackOrForward',
          signature: 'Future<void> goBackOrForward({required int steps})',
          description: 'Goes to the history item at the given offset.',
          className: 'InAppWebViewController',
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'goTo',
          signature: 'Future<void> goTo({required WebHistoryItem historyItem})',
          description: 'Goes to the specified history item.',
          className: 'InAppWebViewController',
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'canGoBack',
          signature: 'Future<bool> canGoBack()',
          description: 'Returns whether the WebView can go back in history.',
          className: 'InAppWebViewController',
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'canGoForward',
          signature: 'Future<bool> canGoForward()',
          description: 'Returns whether the WebView can go forward in history.',
          className: 'InAppWebViewController',
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'canGoBackOrForward',
          signature: 'Future<bool> canGoBackOrForward({required int steps})',
          description:
              'Returns whether the WebView can go to the specified offset.',
          className: 'InAppWebViewController',
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'isLoading',
          signature: 'Future<bool> isLoading()',
          description: 'Returns whether the WebView is currently loading.',
          className: 'InAppWebViewController',
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'stopLoading',
          signature: 'Future<void> stopLoading()',
          description: 'Stops the current page load.',
          className: 'InAppWebViewController',
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'loadSimulatedRequest',
          signature:
              'Future<void> loadSimulatedRequest({required URLRequest urlRequest, ...})',
          description:
              'Navigates to a requested URL with simulated response data.',
          className: 'InAppWebViewController',
          category: 'Navigation',
        ),

        // Page Info methods
        ApiMethodDefinition(
          name: 'getUrl',
          signature: 'Future<WebUri?> getUrl()',
          description: 'Gets the current URL of the WebView.',
          className: 'InAppWebViewController',
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: 'getTitle',
          signature: 'Future<String?> getTitle()',
          description: 'Gets the title of the current page.',
          className: 'InAppWebViewController',
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: 'getProgress',
          signature: 'Future<int?> getProgress()',
          description: 'Gets the current loading progress.',
          className: 'InAppWebViewController',
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: 'getHtml',
          signature: 'Future<String?> getHtml()',
          description: 'Gets the HTML content of the current page.',
          className: 'InAppWebViewController',
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: 'getFavicons',
          signature: 'Future<List<Favicon>> getFavicons()',
          description: 'Gets the favicons of the current page.',
          className: 'InAppWebViewController',
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: 'getOriginalUrl',
          signature: 'Future<WebUri?> getOriginalUrl()',
          description: 'Gets the original URL before redirects.',
          className: 'InAppWebViewController',
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: 'getSelectedText',
          signature: 'Future<String?> getSelectedText()',
          description: 'Gets the currently selected text.',
          className: 'InAppWebViewController',
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: 'getHitTestResult',
          signature: 'Future<InAppWebViewHitTestResult?> getHitTestResult()',
          description: 'Gets a hit test result for the last tap.',
          className: 'InAppWebViewController',
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: 'getMetaTags',
          signature: 'Future<List<MetaTag>> getMetaTags()',
          description: 'Gets all meta tags of the current page.',
          className: 'InAppWebViewController',
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: 'getMetaThemeColor',
          signature: 'Future<Color?> getMetaThemeColor()',
          description: 'Gets the meta theme color of the page.',
          className: 'InAppWebViewController',
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: 'getCertificate',
          signature: 'Future<SslCertificate?> getCertificate()',
          description: 'Gets the SSL certificate for the main resource.',
          className: 'InAppWebViewController',
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: 'getCopyBackForwardList',
          signature: 'Future<WebHistory?> getCopyBackForwardList()',
          description: 'Gets a copy of the back/forward list.',
          className: 'InAppWebViewController',
          category: 'Page Info',
        ),

        // JavaScript methods
        ApiMethodDefinition(
          name: 'evaluateJavascript',
          signature:
              'Future<dynamic> evaluateJavascript({required String source, ...})',
          description: 'Evaluates JavaScript code and returns the result.',
          className: 'InAppWebViewController',
          category: 'JavaScript',
        ),
        ApiMethodDefinition(
          name: 'callAsyncJavaScript',
          signature:
              'Future<CallAsyncJavaScriptResult?> callAsyncJavaScript({...})',
          description: 'Calls a JavaScript function asynchronously.',
          className: 'InAppWebViewController',
          category: 'JavaScript',
        ),
        ApiMethodDefinition(
          name: 'injectJavascriptFileFromUrl',
          signature:
              'Future<void> injectJavascriptFileFromUrl({required WebUri urlFile, ...})',
          description: 'Injects a JavaScript file from a URL.',
          className: 'InAppWebViewController',
          category: 'JavaScript',
        ),
        ApiMethodDefinition(
          name: 'injectJavascriptFileFromAsset',
          signature:
              'Future<dynamic> injectJavascriptFileFromAsset({required String assetFilePath})',
          description: 'Injects a JavaScript file from assets.',
          className: 'InAppWebViewController',
          category: 'JavaScript',
        ),
        ApiMethodDefinition(
          name: 'injectCSSCode',
          signature: 'Future<void> injectCSSCode({required String source})',
          description: 'Injects CSS code into the page.',
          className: 'InAppWebViewController',
          category: 'JavaScript',
        ),
        ApiMethodDefinition(
          name: 'injectCSSFileFromUrl',
          signature:
              'Future<void> injectCSSFileFromUrl({required WebUri urlFile, ...})',
          description: 'Injects a CSS file from a URL.',
          className: 'InAppWebViewController',
          category: 'JavaScript',
        ),
        ApiMethodDefinition(
          name: 'injectCSSFileFromAsset',
          signature:
              'Future<void> injectCSSFileFromAsset({required String assetFilePath})',
          description: 'Injects a CSS file from assets.',
          className: 'InAppWebViewController',
          category: 'JavaScript',
        ),

        // JavaScript Handler methods
        ApiMethodDefinition(
          name: 'addJavaScriptHandler',
          signature:
              'void addJavaScriptHandler({required String handlerName, ...})',
          description: 'Adds a handler for JavaScript to call.',
          className: 'InAppWebViewController',
          category: 'Handlers',
        ),
        ApiMethodDefinition(
          name: 'removeJavaScriptHandler',
          signature:
              'JavaScriptHandlerCallback? removeJavaScriptHandler({required String handlerName})',
          description: 'Removes a JavaScript handler.',
          className: 'InAppWebViewController',
          category: 'Handlers',
        ),
        ApiMethodDefinition(
          name: 'hasJavaScriptHandler',
          signature: 'bool hasJavaScriptHandler({required String handlerName})',
          description: 'Checks if a JavaScript handler exists.',
          className: 'InAppWebViewController',
          category: 'Handlers',
        ),

        // User Scripts methods
        ApiMethodDefinition(
          name: 'addUserScript',
          signature:
              'Future<void> addUserScript({required UserScript userScript})',
          description: 'Adds a user script to the WebView.',
          className: 'InAppWebViewController',
          category: 'User Scripts',
        ),
        ApiMethodDefinition(
          name: 'removeUserScript',
          signature:
              'Future<bool> removeUserScript({required UserScript userScript})',
          description: 'Removes a user script.',
          className: 'InAppWebViewController',
          category: 'User Scripts',
        ),
        ApiMethodDefinition(
          name: 'removeUserScriptsByGroupName',
          signature:
              'Future<void> removeUserScriptsByGroupName({required String groupName})',
          description: 'Removes user scripts by group name.',
          className: 'InAppWebViewController',
          category: 'User Scripts',
        ),
        ApiMethodDefinition(
          name: 'removeAllUserScripts',
          signature: 'Future<void> removeAllUserScripts()',
          description: 'Removes all user scripts.',
          className: 'InAppWebViewController',
          category: 'User Scripts',
        ),
        ApiMethodDefinition(
          name: 'hasUserScript',
          signature: 'bool hasUserScript({required UserScript userScript})',
          description: 'Checks if a user script exists.',
          className: 'InAppWebViewController',
          category: 'User Scripts',
        ),

        // Scrolling methods
        ApiMethodDefinition(
          name: 'scrollTo',
          signature:
              'Future<void> scrollTo({required int x, required int y, bool animated})',
          description: 'Scrolls the WebView to the specified position.',
          className: 'InAppWebViewController',
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: 'scrollBy',
          signature:
              'Future<void> scrollBy({required int x, required int y, bool animated})',
          description: 'Scrolls the WebView by the specified amount.',
          className: 'InAppWebViewController',
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: 'getScrollX',
          signature: 'Future<int?> getScrollX()',
          description: 'Gets the current horizontal scroll position.',
          className: 'InAppWebViewController',
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: 'getScrollY',
          signature: 'Future<int?> getScrollY()',
          description: 'Gets the current vertical scroll position.',
          className: 'InAppWebViewController',
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: 'getContentHeight',
          signature: 'Future<int?> getContentHeight()',
          description: 'Gets the height of the HTML content.',
          className: 'InAppWebViewController',
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: 'getContentWidth',
          signature: 'Future<int?> getContentWidth()',
          description: 'Gets the width of the HTML content.',
          className: 'InAppWebViewController',
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: 'canScrollVertically',
          signature: 'Future<bool> canScrollVertically()',
          description: 'Checks if the WebView can scroll vertically.',
          className: 'InAppWebViewController',
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: 'canScrollHorizontally',
          signature: 'Future<bool> canScrollHorizontally()',
          description: 'Checks if the WebView can scroll horizontally.',
          className: 'InAppWebViewController',
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: 'pageDown',
          signature: 'Future<bool> pageDown({required bool bottom})',
          description: 'Scrolls down by half or full page.',
          className: 'InAppWebViewController',
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: 'pageUp',
          signature: 'Future<bool> pageUp({required bool top})',
          description: 'Scrolls up by half or full page.',
          className: 'InAppWebViewController',
          category: 'Scrolling',
        ),

        // Zoom methods
        ApiMethodDefinition(
          name: 'zoomBy',
          signature: 'Future<void> zoomBy({required double zoomFactor, ...})',
          description: 'Zooms by the specified factor.',
          className: 'InAppWebViewController',
          category: 'Zoom',
        ),
        ApiMethodDefinition(
          name: 'zoomIn',
          signature: 'Future<bool> zoomIn()',
          description: 'Zooms in by a standard amount.',
          className: 'InAppWebViewController',
          category: 'Zoom',
        ),
        ApiMethodDefinition(
          name: 'zoomOut',
          signature: 'Future<bool> zoomOut()',
          description: 'Zooms out by a standard amount.',
          className: 'InAppWebViewController',
          category: 'Zoom',
        ),
        ApiMethodDefinition(
          name: 'getZoomScale',
          signature: 'Future<double?> getZoomScale()',
          description: 'Gets the current zoom scale.',
          className: 'InAppWebViewController',
          category: 'Zoom',
        ),

        // Settings methods
        ApiMethodDefinition(
          name: 'setSettings',
          signature:
              'Future<void> setSettings({required InAppWebViewSettings settings})',
          description: 'Updates the WebView settings.',
          className: 'InAppWebViewController',
          category: 'Settings',
        ),
        ApiMethodDefinition(
          name: 'getSettings',
          signature: 'Future<InAppWebViewSettings?> getSettings()',
          description: 'Gets the current WebView settings.',
          className: 'InAppWebViewController',
          category: 'Settings',
        ),
        ApiMethodDefinition(
          name: 'setContextMenu',
          signature: 'Future<void> setContextMenu(ContextMenu? contextMenu)',
          description: 'Sets the context menu.',
          className: 'InAppWebViewController',
          category: 'Settings',
        ),
        ApiMethodDefinition(
          name: 'requestFocus',
          signature: 'Future<void> requestFocus()',
          description: 'Requests focus for the WebView.',
          className: 'InAppWebViewController',
          category: 'Settings',
        ),
        ApiMethodDefinition(
          name: 'clearFocus',
          signature: 'Future<void> clearFocus()',
          description: 'Clears focus from the WebView.',
          className: 'InAppWebViewController',
          category: 'Settings',
        ),

        // Screenshot methods
        ApiMethodDefinition(
          name: 'takeScreenshot',
          signature:
              'Future<Uint8List?> takeScreenshot({ScreenshotConfiguration? screenshotConfiguration})',
          description: 'Takes a screenshot of the WebView.',
          className: 'InAppWebViewController',
          category: 'Screenshot',
        ),
        ApiMethodDefinition(
          name: 'printCurrentPage',
          signature:
              'Future<PrintJobController?> printCurrentPage({PrintJobSettings? settings})',
          description: 'Prints the current page.',
          className: 'InAppWebViewController',
          category: 'Screenshot',
        ),
        ApiMethodDefinition(
          name: 'createPdf',
          signature:
              'Future<Uint8List?> createPdf({PdfConfiguration? pdfConfiguration})',
          description: 'Creates a PDF from the current page.',
          className: 'InAppWebViewController',
          category: 'Screenshot',
        ),

        // Cache methods
        ApiMethodDefinition(
          name: 'clearHistory',
          signature: 'Future<void> clearHistory()',
          description: 'Clears the WebView history.',
          className: 'InAppWebViewController',
          category: 'Cache',
        ),
        ApiMethodDefinition(
          name: 'clearFormData',
          signature: 'Future<void> clearFormData()',
          description: 'Clears form data.',
          className: 'InAppWebViewController',
          category: 'Cache',
        ),
        ApiMethodDefinition(
          name: 'clearSslPreferences',
          signature: 'Future<void> clearSslPreferences()',
          description: 'Clears SSL preferences.',
          className: 'InAppWebViewController',
          category: 'Cache',
        ),

        // Pause/Resume methods
        ApiMethodDefinition(
          name: 'pause',
          signature: 'Future<void> pause()',
          description: 'Pauses the WebView.',
          className: 'InAppWebViewController',
          category: 'Pause/Resume',
        ),
        ApiMethodDefinition(
          name: 'resume',
          signature: 'Future<void> resume()',
          description: 'Resumes the WebView.',
          className: 'InAppWebViewController',
          category: 'Pause/Resume',
        ),
        ApiMethodDefinition(
          name: 'pauseTimers',
          signature: 'Future<void> pauseTimers()',
          description: 'Pauses all layout, parsing, and JavaScript timers.',
          className: 'InAppWebViewController',
          category: 'Pause/Resume',
        ),
        ApiMethodDefinition(
          name: 'resumeTimers',
          signature: 'Future<void> resumeTimers()',
          description: 'Resumes all layout, parsing, and JavaScript timers.',
          className: 'InAppWebViewController',
          category: 'Pause/Resume',
        ),

        // Web Messaging methods
        ApiMethodDefinition(
          name: 'createWebMessageChannel',
          signature: 'Future<WebMessageChannel?> createWebMessageChannel()',
          description: 'Creates a message channel for communication.',
          className: 'InAppWebViewController',
          category: 'Web Messaging',
        ),
        ApiMethodDefinition(
          name: 'postWebMessage',
          signature:
              'Future<void> postWebMessage({required WebMessage message, ...})',
          description: 'Posts a message to the WebView.',
          className: 'InAppWebViewController',
          category: 'Web Messaging',
        ),
        ApiMethodDefinition(
          name: 'addWebMessageListener',
          signature:
              'Future<void> addWebMessageListener(WebMessageListener webMessageListener)',
          description: 'Adds a listener for web messages.',
          className: 'InAppWebViewController',
          category: 'Web Messaging',
        ),
        ApiMethodDefinition(
          name: 'hasWebMessageListener',
          signature:
              'bool hasWebMessageListener({required String jsObjectName})',
          description: 'Checks if a web message listener exists.',
          className: 'InAppWebViewController',
          category: 'Web Messaging',
        ),

        // Media methods
        ApiMethodDefinition(
          name: 'isInFullscreen',
          signature: 'Future<bool?> isInFullscreen()',
          description: 'Returns whether the WebView is in fullscreen mode.',
          className: 'InAppWebViewController',
          category: 'Media',
        ),
        ApiMethodDefinition(
          name: 'pauseAllMediaPlayback',
          signature: 'Future<void> pauseAllMediaPlayback()',
          description: 'Pauses all media playback.',
          className: 'InAppWebViewController',
          category: 'Media',
        ),
        ApiMethodDefinition(
          name: 'setAllMediaPlaybackSuspended',
          signature:
              'Future<void> setAllMediaPlaybackSuspended({required bool suspended})',
          description: 'Suspends or resumes all media playback.',
          className: 'InAppWebViewController',
          category: 'Media',
        ),
        ApiMethodDefinition(
          name: 'closeAllMediaPresentations',
          signature: 'Future<void> closeAllMediaPresentations()',
          description: 'Closes all media presentations.',
          className: 'InAppWebViewController',
          category: 'Media',
        ),
        ApiMethodDefinition(
          name: 'requestMediaPlaybackState',
          signature: 'Future<MediaPlaybackState?> requestMediaPlaybackState()',
          description: 'Gets the current media playback state.',
          className: 'InAppWebViewController',
          category: 'Media',
        ),
        ApiMethodDefinition(
          name: 'isPlayingAudio',
          signature: 'Future<bool?> isPlayingAudio()',
          description: 'Checks if audio is currently playing.',
          className: 'InAppWebViewController',
          category: 'Media',
        ),
        ApiMethodDefinition(
          name: 'isMuted',
          signature: 'Future<bool?> isMuted()',
          description: 'Checks if audio is muted.',
          className: 'InAppWebViewController',
          category: 'Media',
        ),
        ApiMethodDefinition(
          name: 'setMuted',
          signature: 'Future<void> setMuted({required bool muted})',
          description: 'Sets the muted state.',
          className: 'InAppWebViewController',
          category: 'Media',
        ),

        // Camera/Mic methods
        ApiMethodDefinition(
          name: 'getCameraCaptureState',
          signature: 'Future<MediaCaptureState?> getCameraCaptureState()',
          description: 'Gets the camera capture state.',
          className: 'InAppWebViewController',
          category: 'Camera/Mic',
        ),
        ApiMethodDefinition(
          name: 'setCameraCaptureState',
          signature:
              'Future<void> setCameraCaptureState({required MediaCaptureState state})',
          description: 'Sets the camera capture state.',
          className: 'InAppWebViewController',
          category: 'Camera/Mic',
        ),
        ApiMethodDefinition(
          name: 'getMicrophoneCaptureState',
          signature: 'Future<MediaCaptureState?> getMicrophoneCaptureState()',
          description: 'Gets the microphone capture state.',
          className: 'InAppWebViewController',
          category: 'Camera/Mic',
        ),
        ApiMethodDefinition(
          name: 'setMicrophoneCaptureState',
          signature:
              'Future<void> setMicrophoneCaptureState({required MediaCaptureState state})',
          description: 'Sets the microphone capture state.',
          className: 'InAppWebViewController',
          category: 'Camera/Mic',
        ),

        // Security methods
        ApiMethodDefinition(
          name: 'isSecureContext',
          signature: 'Future<bool> isSecureContext()',
          description: 'Checks if the current context is secure (HTTPS).',
          className: 'InAppWebViewController',
          category: 'Security',
        ),
        ApiMethodDefinition(
          name: 'hasOnlySecureContent',
          signature: 'Future<bool> hasOnlySecureContent()',
          description: 'Checks if the page has only secure content.',
          className: 'InAppWebViewController',
          category: 'Security',
        ),

        // Android-specific methods
        ApiMethodDefinition(
          name: 'startSafeBrowsing',
          signature: 'Future<bool> startSafeBrowsing()',
          description: 'Starts the Safe Browsing initialization.',
          className: 'InAppWebViewController',
          category: 'Android',
        ),
        ApiMethodDefinition(
          name: 'saveWebArchive',
          signature:
              'Future<String?> saveWebArchive({required String basename, ...})',
          description: 'Saves the current page as a web archive.',
          className: 'InAppWebViewController',
          category: 'Android',
        ),
        ApiMethodDefinition(
          name: 'requestFocusNodeHref',
          signature:
              'Future<RequestFocusNodeHrefResult?> requestFocusNodeHref()',
          description: 'Requests the URL of the focused anchor.',
          className: 'InAppWebViewController',
          category: 'Android',
        ),
        ApiMethodDefinition(
          name: 'requestImageRef',
          signature: 'Future<RequestImageRefResult?> requestImageRef()',
          description: 'Requests the URL of the focused image.',
          className: 'InAppWebViewController',
          category: 'Android',
        ),
        ApiMethodDefinition(
          name: 'saveState',
          signature: 'Future<Uint8List?> saveState()',
          description: 'Saves the WebView state to a bundle.',
          className: 'InAppWebViewController',
          category: 'Android',
        ),
        ApiMethodDefinition(
          name: 'restoreState',
          signature: 'Future<void> restoreState({required Uint8List state})',
          description: 'Restores the WebView state from a bundle.',
          className: 'InAppWebViewController',
          category: 'Android',
        ),

        // iOS/macOS-specific methods
        ApiMethodDefinition(
          name: 'createWebArchiveData',
          signature: 'Future<Uint8List?> createWebArchiveData()',
          description: 'Creates a web archive of the current page.',
          className: 'InAppWebViewController',
          category: 'iOS/macOS',
        ),
        ApiMethodDefinition(
          name: 'terminateWebProcess',
          signature: 'Future<void> terminateWebProcess()',
          description: 'Terminates the web content process.',
          className: 'InAppWebViewController',
          category: 'iOS/macOS',
        ),

        // Windows-specific methods
        ApiMethodDefinition(
          name: 'openDevTools',
          signature: 'Future<void> openDevTools()',
          description: 'Opens the browser DevTools.',
          className: 'InAppWebViewController',
          category: 'Windows',
        ),
        ApiMethodDefinition(
          name: 'callDevToolsProtocolMethod',
          signature:
              'Future<dynamic> callDevToolsProtocolMethod({required String methodName, ...})',
          description: 'Calls a DevTools Protocol method.',
          className: 'InAppWebViewController',
          category: 'Windows',
        ),
        ApiMethodDefinition(
          name: 'addDevToolsProtocolEventListener',
          signature:
              'Future<void> addDevToolsProtocolEventListener({required String eventName, ...})',
          description: 'Adds a DevTools Protocol event listener.',
          className: 'InAppWebViewController',
          category: 'Windows',
        ),
        ApiMethodDefinition(
          name: 'removeDevToolsProtocolEventListener',
          signature:
              'Future<void> removeDevToolsProtocolEventListener({required String eventName})',
          description: 'Removes a DevTools Protocol event listener.',
          className: 'InAppWebViewController',
          category: 'Windows',
        ),

        // Web-specific methods
        ApiMethodDefinition(
          name: 'getIFrameId',
          signature: 'Future<String?> getIFrameId()',
          description: 'Gets the iframe ID on web platform.',
          className: 'InAppWebViewController',
          category: 'Web',
        ),

        // Other methods
        ApiMethodDefinition(
          name: 'getViewId',
          signature: 'int getViewId()',
          description: 'Gets the view ID of the WebView.',
          className: 'InAppWebViewController',
          category: 'Other',
        ),
        ApiMethodDefinition(
          name: 'dispose',
          signature: 'void dispose()',
          description: 'Disposes the controller and releases resources.',
          className: 'InAppWebViewController',
          category: 'Other',
        ),

        // Static methods
        ApiMethodDefinition(
          name: 'getDefaultUserAgent',
          signature: 'static Future<String> getDefaultUserAgent()',
          description: 'Gets the default User-Agent string.',
          className: 'InAppWebViewController',
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'clearClientCertPreferences',
          signature: 'static Future<void> clearClientCertPreferences()',
          description: 'Clears the client certificate preferences.',
          className: 'InAppWebViewController',
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'getSafeBrowsingPrivacyPolicyUrl',
          signature: 'static Future<WebUri?> getSafeBrowsingPrivacyPolicyUrl()',
          description: 'Gets the Safe Browsing privacy policy URL.',
          className: 'InAppWebViewController',
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'setSafeBrowsingAllowlist',
          signature:
              'static Future<bool> setSafeBrowsingAllowlist({required List<String> hosts})',
          description: 'Sets the Safe Browsing allowlist.',
          className: 'InAppWebViewController',
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'getCurrentWebViewPackage',
          signature:
              'static Future<WebViewPackageInfo?> getCurrentWebViewPackage()',
          description: 'Gets the current WebView package info.',
          className: 'InAppWebViewController',
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'setWebContentsDebuggingEnabled',
          signature:
              'static Future<void> setWebContentsDebuggingEnabled(bool debuggingEnabled)',
          description: 'Enables or disables debugging.',
          className: 'InAppWebViewController',
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'getVariationsHeader',
          signature: 'static Future<String?> getVariationsHeader()',
          description: 'Gets the variations header.',
          className: 'InAppWebViewController',
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'isMultiProcessEnabled',
          signature: 'static Future<bool> isMultiProcessEnabled()',
          description: 'Checks if multi-process is enabled.',
          className: 'InAppWebViewController',
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'disableWebView',
          signature: 'static Future<void> disableWebView()',
          description: 'Disables the WebView.',
          className: 'InAppWebViewController',
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'handlesURLScheme',
          signature: 'static Future<bool> handlesURLScheme(String urlScheme)',
          description: 'Checks if the WebView handles a URL scheme.',
          className: 'InAppWebViewController',
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'disposeKeepAlive',
          signature:
              'static Future<void> disposeKeepAlive(InAppWebViewKeepAlive keepAlive)',
          description: 'Disposes a keep-alive instance.',
          className: 'InAppWebViewController',
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'clearAllCache',
          signature:
              'static Future<void> clearAllCache({bool includeDiskFiles = true})',
          description: 'Clears all WebView caches.',
          className: 'InAppWebViewController',
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'enableSlowWholeDocumentDraw',
          signature: 'static Future<void> enableSlowWholeDocumentDraw()',
          description: 'Enables slow whole document draw.',
          className: 'InAppWebViewController',
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'setJavaScriptBridgeName',
          signature:
              'static Future<void> setJavaScriptBridgeName(String bridgeName)',
          description: 'Sets the JavaScript bridge name.',
          className: 'InAppWebViewController',
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'getJavaScriptBridgeName',
          signature: 'static Future<String> getJavaScriptBridgeName()',
          description: 'Gets the JavaScript bridge name.',
          className: 'InAppWebViewController',
          isStatic: true,
          category: 'Static',
        ),
      ],
    );
  }

  static ApiClassDefinition _getInAppWebViewEventsDefinition() {
    return ApiClassDefinition(
      className: 'InAppWebView Events',
      description: 'Events fired by InAppWebView.',
      events: [
        // Core events
        ApiEventDefinition(
          name: 'onWebViewCreated',
          description: 'Called when the WebView is created.',
          className: 'InAppWebView Events',
          category: 'Core',
        ),
        ApiEventDefinition(
          name: 'onLoadStart',
          description: 'Called when a page starts loading.',
          className: 'InAppWebView Events',
          category: 'Core',
        ),
        ApiEventDefinition(
          name: 'onLoadStop',
          description: 'Called when a page finishes loading.',
          className: 'InAppWebView Events',
          category: 'Core',
        ),
        ApiEventDefinition(
          name: 'onLoadError',
          description: 'Called when a page fails to load.',
          className: 'InAppWebView Events',
          category: 'Core',
        ),
        ApiEventDefinition(
          name: 'onLoadHttpError',
          description: 'Called when an HTTP error is received.',
          className: 'InAppWebView Events',
          category: 'Core',
        ),
        ApiEventDefinition(
          name: 'onProgressChanged',
          description: 'Called when the loading progress changes.',
          className: 'InAppWebView Events',
          category: 'Core',
        ),
        ApiEventDefinition(
          name: 'onConsoleMessage',
          description: 'Called when a console message is received.',
          className: 'InAppWebView Events',
          category: 'Core',
        ),
        ApiEventDefinition(
          name: 'onTitleChanged',
          description: 'Called when the page title changes.',
          className: 'InAppWebView Events',
          category: 'Core',
        ),
        ApiEventDefinition(
          name: 'onUpdateVisitedHistory',
          description: 'Called when the visited history is updated.',
          className: 'InAppWebView Events',
          category: 'Core',
        ),

        // Navigation events
        ApiEventDefinition(
          name: 'shouldOverrideUrlLoading',
          description: 'Called to handle URL navigation requests.',
          className: 'InAppWebView Events',
          category: 'Navigation',
        ),
        ApiEventDefinition(
          name: 'onNavigationResponse',
          description: 'Called when receiving a navigation response.',
          className: 'InAppWebView Events',
          category: 'Navigation',
        ),
        ApiEventDefinition(
          name: 'shouldAllowDeprecatedTLS',
          description: 'Called to check if deprecated TLS should be allowed.',
          className: 'InAppWebView Events',
          category: 'Navigation',
        ),

        // Window events
        ApiEventDefinition(
          name: 'onCreateWindow',
          description: 'Called when a new window is requested.',
          className: 'InAppWebView Events',
          category: 'Window',
        ),
        ApiEventDefinition(
          name: 'onCloseWindow',
          description: 'Called when a window should be closed.',
          className: 'InAppWebView Events',
          category: 'Window',
        ),
        ApiEventDefinition(
          name: 'onWindowFocus',
          description: 'Called when the window receives focus.',
          className: 'InAppWebView Events',
          category: 'Window',
        ),
        ApiEventDefinition(
          name: 'onWindowBlur',
          description: 'Called when the window loses focus.',
          className: 'InAppWebView Events',
          category: 'Window',
        ),

        // JS Dialog events
        ApiEventDefinition(
          name: 'onJsAlert',
          description: 'Called when a JavaScript alert is shown.',
          className: 'InAppWebView Events',
          category: 'JS Dialogs',
        ),
        ApiEventDefinition(
          name: 'onJsConfirm',
          description: 'Called when a JavaScript confirm is shown.',
          className: 'InAppWebView Events',
          category: 'JS Dialogs',
        ),
        ApiEventDefinition(
          name: 'onJsPrompt',
          description: 'Called when a JavaScript prompt is shown.',
          className: 'InAppWebView Events',
          category: 'JS Dialogs',
        ),
        ApiEventDefinition(
          name: 'onJsBeforeUnload',
          description: 'Called before the page is unloaded.',
          className: 'InAppWebView Events',
          category: 'JS Dialogs',
        ),

        // Authentication events
        ApiEventDefinition(
          name: 'onReceivedHttpAuthRequest',
          description: 'Called for HTTP authentication requests.',
          className: 'InAppWebView Events',
          category: 'Authentication',
        ),
        ApiEventDefinition(
          name: 'onReceivedServerTrustAuthRequest',
          description: 'Called for server trust authentication.',
          className: 'InAppWebView Events',
          category: 'Authentication',
        ),
        ApiEventDefinition(
          name: 'onReceivedClientCertRequest',
          description: 'Called when a client certificate is requested.',
          className: 'InAppWebView Events',
          category: 'Authentication',
        ),

        // Network events
        ApiEventDefinition(
          name: 'shouldInterceptRequest',
          description: 'Called to intercept resource requests.',
          className: 'InAppWebView Events',
          category: 'Network',
        ),
        ApiEventDefinition(
          name: 'onLoadResource',
          description: 'Called when a resource is loaded.',
          className: 'InAppWebView Events',
          category: 'Network',
        ),
        ApiEventDefinition(
          name: 'onLoadResourceWithCustomScheme',
          description: 'Called when loading a custom scheme resource.',
          className: 'InAppWebView Events',
          category: 'Network',
        ),
        ApiEventDefinition(
          name: 'onReceivedError',
          description: 'Called when a resource load error occurs.',
          className: 'InAppWebView Events',
          category: 'Network',
        ),
        ApiEventDefinition(
          name: 'onReceivedHttpError',
          description: 'Called when an HTTP error occurs.',
          className: 'InAppWebView Events',
          category: 'Network',
        ),

        // Download events
        ApiEventDefinition(
          name: 'onDownloadStartRequest',
          description: 'Called when a download is requested.',
          className: 'InAppWebView Events',
          category: 'Download',
        ),
        ApiEventDefinition(
          name: 'onDownloadStarting',
          description: 'Called when a download is starting.',
          className: 'InAppWebView Events',
          category: 'Download',
        ),

        // Scroll events
        ApiEventDefinition(
          name: 'onScrollChanged',
          description: 'Called when the scroll position changes.',
          className: 'InAppWebView Events',
          category: 'Scroll',
        ),
        ApiEventDefinition(
          name: 'onOverScrolled',
          description: 'Called when the WebView is over-scrolled.',
          className: 'InAppWebView Events',
          category: 'Scroll',
        ),

        // Zoom events
        ApiEventDefinition(
          name: 'onZoomScaleChanged',
          description: 'Called when the zoom scale changes.',
          className: 'InAppWebView Events',
          category: 'Zoom',
        ),

        // Print events
        ApiEventDefinition(
          name: 'onPrintRequest',
          description: 'Called when a print request is made.',
          className: 'InAppWebView Events',
          category: 'Print',
        ),

        // Fullscreen events
        ApiEventDefinition(
          name: 'onEnterFullscreen',
          description: 'Called when entering fullscreen mode.',
          className: 'InAppWebView Events',
          category: 'Fullscreen',
        ),
        ApiEventDefinition(
          name: 'onExitFullscreen',
          description: 'Called when exiting fullscreen mode.',
          className: 'InAppWebView Events',
          category: 'Fullscreen',
        ),

        // Permission events
        ApiEventDefinition(
          name: 'onPermissionRequest',
          description: 'Called when a permission is requested.',
          className: 'InAppWebView Events',
          category: 'Permission',
        ),
        ApiEventDefinition(
          name: 'onPermissionRequestCanceled',
          description: 'Called when a permission request is canceled.',
          className: 'InAppWebView Events',
          category: 'Permission',
        ),

        // Touch/Gesture events
        ApiEventDefinition(
          name: 'onLongPressHitTestResult',
          description: 'Called on a long press.',
          className: 'InAppWebView Events',
          category: 'Touch',
        ),
        ApiEventDefinition(
          name: 'onGeolocationPermissionsShowPrompt',
          description: 'Called when requesting geolocation permission.',
          className: 'InAppWebView Events',
          category: 'Permission',
        ),
        ApiEventDefinition(
          name: 'onGeolocationPermissionsHidePrompt',
          description: 'Called when hiding geolocation permission prompt.',
          className: 'InAppWebView Events',
          category: 'Permission',
        ),

        // Render Process events
        ApiEventDefinition(
          name: 'onRenderProcessGone',
          description: 'Called when the render process terminates.',
          className: 'InAppWebView Events',
          category: 'Render Process',
        ),
        ApiEventDefinition(
          name: 'onRenderProcessResponsive',
          description: 'Called when the render process becomes responsive.',
          className: 'InAppWebView Events',
          category: 'Render Process',
        ),
        ApiEventDefinition(
          name: 'onRenderProcessUnresponsive',
          description: 'Called when the render process becomes unresponsive.',
          className: 'InAppWebView Events',
          category: 'Render Process',
        ),
        ApiEventDefinition(
          name: 'onWebContentProcessDidTerminate',
          description: 'Called when the web content process terminates.',
          className: 'InAppWebView Events',
          category: 'Render Process',
        ),

        // Form events
        ApiEventDefinition(
          name: 'onFormResubmission',
          description: 'Called when a form is resubmitted.',
          className: 'InAppWebView Events',
          category: 'Form',
        ),

        // Icon events
        ApiEventDefinition(
          name: 'onReceivedIcon',
          description: 'Called when a favicon is received.',
          className: 'InAppWebView Events',
          category: 'Icon',
        ),
        ApiEventDefinition(
          name: 'onReceivedTouchIconUrl',
          description: 'Called when a touch icon URL is received.',
          className: 'InAppWebView Events',
          category: 'Icon',
        ),

        // Safe Browsing events
        ApiEventDefinition(
          name: 'onSafeBrowsingHit',
          description: 'Called when Safe Browsing detects a threat.',
          className: 'InAppWebView Events',
          category: 'Safe Browsing',
        ),

        // iOS/macOS events
        ApiEventDefinition(
          name: 'onDidReceiveServerRedirectForProvisionalNavigation',
          description: 'Called when a server redirect is received.',
          className: 'InAppWebView Events',
          category: 'iOS/macOS',
        ),
        ApiEventDefinition(
          name: 'onCameraCaptureStateChanged',
          description: 'Called when camera capture state changes.',
          className: 'InAppWebView Events',
          category: 'iOS/macOS',
        ),
        ApiEventDefinition(
          name: 'onMicrophoneCaptureStateChanged',
          description: 'Called when microphone capture state changes.',
          className: 'InAppWebView Events',
          category: 'iOS/macOS',
        ),

        // Windows events
        ApiEventDefinition(
          name: 'onProcessFailed',
          description: 'Called when a process failure occurs.',
          className: 'InAppWebView Events',
          category: 'Windows',
        ),
        ApiEventDefinition(
          name: 'onNewWindowRequested',
          description: 'Called when a new window is requested.',
          className: 'InAppWebView Events',
          category: 'Windows',
        ),

        // Other events
        ApiEventDefinition(
          name: 'onPageCommitVisible',
          description: 'Called when the page becomes visible.',
          className: 'InAppWebView Events',
          category: 'Other',
        ),
        ApiEventDefinition(
          name: 'onContentSizeChanged',
          description: 'Called when the content size changes.',
          className: 'InAppWebView Events',
          category: 'Other',
        ),
        ApiEventDefinition(
          name: 'onAjaxReadyStateChange',
          description: 'Called when an AJAX ready state changes.',
          className: 'InAppWebView Events',
          category: 'Other',
        ),
        ApiEventDefinition(
          name: 'onAjaxProgress',
          description: 'Called for AJAX progress updates.',
          className: 'InAppWebView Events',
          category: 'Other',
        ),
        ApiEventDefinition(
          name: 'shouldInterceptAjaxRequest',
          description: 'Called to intercept AJAX requests.',
          className: 'InAppWebView Events',
          category: 'Other',
        ),
        ApiEventDefinition(
          name: 'onFetchPost',
          description: 'Called when a fetch POST request is made.',
          className: 'InAppWebView Events',
          category: 'Other',
        ),
        ApiEventDefinition(
          name: 'shouldInterceptFetchRequest',
          description: 'Called to intercept fetch requests.',
          className: 'InAppWebView Events',
          category: 'Other',
        ),
      ],
    );
  }

  static ApiClassDefinition _getHeadlessInAppWebViewDefinition() {
    return ApiClassDefinition(
      className: 'HeadlessInAppWebView',
      description: 'A WebView that runs without UI.',
      isClassSupported: () => HeadlessInAppWebView.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: 'run',
          signature: 'Future<void> run()',
          description: 'Runs the headless WebView.',
          className: 'HeadlessInAppWebView',
        ),
        ApiMethodDefinition(
          name: 'isRunning',
          signature: 'Future<bool> isRunning()',
          description: 'Checks if the WebView is running.',
          className: 'HeadlessInAppWebView',
        ),
        ApiMethodDefinition(
          name: 'setSize',
          signature: 'Future<void> setSize(Size size)',
          description: 'Sets the WebView size.',
          className: 'HeadlessInAppWebView',
        ),
        ApiMethodDefinition(
          name: 'getSize',
          signature: 'Future<Size?> getSize()',
          description: 'Gets the WebView size.',
          className: 'HeadlessInAppWebView',
        ),
        ApiMethodDefinition(
          name: 'dispose',
          signature: 'Future<void> dispose()',
          description: 'Disposes the headless WebView.',
          className: 'HeadlessInAppWebView',
        ),
      ],
    );
  }

  static ApiClassDefinition _getInAppBrowserDefinition() {
    return ApiClassDefinition(
      className: 'InAppBrowser',
      description: 'A full-screen in-app browser.',
      isClassSupported: () => InAppBrowser.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: 'openUrlRequest',
          signature:
              'Future<void> openUrlRequest({required URLRequest urlRequest, ...})',
          description: 'Opens a URL in the browser.',
          className: 'InAppBrowser',
        ),
        ApiMethodDefinition(
          name: 'openFile',
          signature:
              'Future<void> openFile({required String assetFilePath, ...})',
          description: 'Opens a file from assets.',
          className: 'InAppBrowser',
        ),
        ApiMethodDefinition(
          name: 'openData',
          signature: 'Future<void> openData({required String data, ...})',
          description: 'Opens HTML data.',
          className: 'InAppBrowser',
        ),
        ApiMethodDefinition(
          name: 'openWithSystemBrowser',
          signature:
              'static Future<void> openWithSystemBrowser({required WebUri url})',
          description: 'Opens a URL in the system browser.',
          className: 'InAppBrowser',
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'show',
          signature: 'Future<void> show()',
          description: 'Shows the browser.',
          className: 'InAppBrowser',
        ),
        ApiMethodDefinition(
          name: 'hide',
          signature: 'Future<void> hide()',
          description: 'Hides the browser.',
          className: 'InAppBrowser',
        ),
        ApiMethodDefinition(
          name: 'close',
          signature: 'Future<void> close()',
          description: 'Closes the browser.',
          className: 'InAppBrowser',
        ),
        ApiMethodDefinition(
          name: 'isHidden',
          signature: 'Future<bool> isHidden()',
          description: 'Checks if the browser is hidden.',
          className: 'InAppBrowser',
        ),
        ApiMethodDefinition(
          name: 'setSettings',
          signature:
              'Future<void> setSettings({required InAppBrowserClassSettings settings})',
          description: 'Sets the browser settings.',
          className: 'InAppBrowser',
        ),
        ApiMethodDefinition(
          name: 'getSettings',
          signature: 'Future<InAppBrowserClassSettings?> getSettings()',
          description: 'Gets the browser settings.',
          className: 'InAppBrowser',
        ),
        ApiMethodDefinition(
          name: 'isOpened',
          signature: 'bool isOpened()',
          description: 'Checks if the browser is opened.',
          className: 'InAppBrowser',
        ),
      ],
      events: [
        ApiEventDefinition(
          name: 'onBrowserCreated',
          description: 'Called when the browser is created.',
          className: 'InAppBrowser',
        ),
        ApiEventDefinition(
          name: 'onExit',
          description: 'Called when the browser exits.',
          className: 'InAppBrowser',
        ),
        ApiEventDefinition(
          name: 'onMainWindowCreated',
          description: 'Called when the main window is created.',
          className: 'InAppBrowser',
        ),
        ApiEventDefinition(
          name: 'onMainWindowWillClose',
          description: 'Called when the main window will close.',
          className: 'InAppBrowser',
        ),
      ],
    );
  }

  static ApiClassDefinition _getChromeSafariBrowserDefinition() {
    return ApiClassDefinition(
      className: 'ChromeSafariBrowser',
      description:
          'A browser using Chrome Custom Tabs or SFSafariViewController.',
      isClassSupported: () => ChromeSafariBrowser.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: 'open',
          signature: 'Future<void> open({WebUri? url, ...})',
          description: 'Opens a URL in the browser.',
          className: 'ChromeSafariBrowser',
        ),
        ApiMethodDefinition(
          name: 'launchUrl',
          signature: 'Future<void> launchUrl({required WebUri url, ...})',
          description: 'Launches a URL.',
          className: 'ChromeSafariBrowser',
        ),
        ApiMethodDefinition(
          name: 'mayLaunchUrl',
          signature: 'Future<bool> mayLaunchUrl({WebUri? url, ...})',
          description: 'Hints to the browser to start loading a URL.',
          className: 'ChromeSafariBrowser',
        ),
        ApiMethodDefinition(
          name: 'validateRelationship',
          signature:
              'Future<bool> validateRelationship({required CustomTabsRelationType relation, ...})',
          description: 'Validates a relationship.',
          className: 'ChromeSafariBrowser',
        ),
        ApiMethodDefinition(
          name: 'close',
          signature: 'Future<void> close()',
          description: 'Closes the browser.',
          className: 'ChromeSafariBrowser',
        ),
        ApiMethodDefinition(
          name: 'isOpened',
          signature: 'bool isOpened()',
          description: 'Checks if the browser is opened.',
          className: 'ChromeSafariBrowser',
        ),
        ApiMethodDefinition(
          name: 'isAvailable',
          signature: 'static Future<bool> isAvailable()',
          description: 'Checks if the browser is available.',
          className: 'ChromeSafariBrowser',
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'getMaxToolbarItems',
          signature: 'static Future<int> getMaxToolbarItems()',
          description: 'Gets the maximum toolbar items.',
          className: 'ChromeSafariBrowser',
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'getPackageName',
          signature:
              'static Future<String?> getPackageName({List<String>? packages, ...})',
          description: 'Gets the package name for Custom Tabs.',
          className: 'ChromeSafariBrowser',
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'clearWebsiteData',
          signature: 'static Future<void> clearWebsiteData()',
          description: 'Clears website data.',
          className: 'ChromeSafariBrowser',
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'prewarmConnections',
          signature:
              'static Future<PrewarmingToken?> prewarmConnections({required List<WebUri> urls})',
          description: 'Prewarms connections.',
          className: 'ChromeSafariBrowser',
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'invalidatePrewarmingToken',
          signature:
              'static Future<void> invalidatePrewarmingToken({required PrewarmingToken prewarmingToken})',
          description: 'Invalidates a prewarming token.',
          className: 'ChromeSafariBrowser',
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'setActionButton',
          signature:
              'Future<void> setActionButton(ChromeSafariBrowserActionButton actionButton)',
          description: 'Sets an action button.',
          className: 'ChromeSafariBrowser',
        ),
        ApiMethodDefinition(
          name: 'updateActionButton',
          signature:
              'Future<void> updateActionButton({required Uint8List icon, required String description})',
          description: 'Updates the action button.',
          className: 'ChromeSafariBrowser',
        ),
        ApiMethodDefinition(
          name: 'setSecondaryToolbar',
          signature:
              'Future<void> setSecondaryToolbar(ChromeSafariBrowserSecondaryToolbar secondaryToolbar)',
          description: 'Sets a secondary toolbar.',
          className: 'ChromeSafariBrowser',
        ),
        ApiMethodDefinition(
          name: 'updateSecondaryToolbar',
          signature:
              'Future<void> updateSecondaryToolbar(ChromeSafariBrowserSecondaryToolbar secondaryToolbar)',
          description: 'Updates the secondary toolbar.',
          className: 'ChromeSafariBrowser',
        ),
        ApiMethodDefinition(
          name: 'requestPostMessageChannel',
          signature:
              'Future<bool> requestPostMessageChannel({required WebUri sourceOrigin, ...})',
          description: 'Requests a post message channel.',
          className: 'ChromeSafariBrowser',
        ),
        ApiMethodDefinition(
          name: 'postMessage',
          signature:
              'Future<CustomTabsPostMessageResultType> postMessage({required String message})',
          description: 'Posts a message.',
          className: 'ChromeSafariBrowser',
        ),
        ApiMethodDefinition(
          name: 'isEngagementSignalsApiAvailable',
          signature: 'Future<bool> isEngagementSignalsApiAvailable()',
          description: 'Checks if engagement signals API is available.',
          className: 'ChromeSafariBrowser',
        ),
      ],
      events: [
        ApiEventDefinition(
          name: 'onOpened',
          description: 'Called when the browser is opened.',
          className: 'ChromeSafariBrowser',
        ),
        ApiEventDefinition(
          name: 'onClosed',
          description: 'Called when the browser is closed.',
          className: 'ChromeSafariBrowser',
        ),
        ApiEventDefinition(
          name: 'onCompletedInitialLoad',
          description: 'Called when the initial load completes.',
          className: 'ChromeSafariBrowser',
        ),
        ApiEventDefinition(
          name: 'onInitialLoadDidRedirect',
          description: 'Called when the initial load redirects.',
          className: 'ChromeSafariBrowser',
        ),
        ApiEventDefinition(
          name: 'onWillOpenInBrowser',
          description: 'Called when opening in the browser.',
          className: 'ChromeSafariBrowser',
        ),
        ApiEventDefinition(
          name: 'onNavigationEvent',
          description: 'Called on navigation events.',
          className: 'ChromeSafariBrowser',
        ),
        ApiEventDefinition(
          name: 'onServiceConnected',
          description: 'Called when the service connects.',
          className: 'ChromeSafariBrowser',
        ),
        ApiEventDefinition(
          name: 'onRelationshipValidationResult',
          description: 'Called with relationship validation results.',
          className: 'ChromeSafariBrowser',
        ),
        ApiEventDefinition(
          name: 'onMessageChannelReady',
          description: 'Called when the message channel is ready.',
          className: 'ChromeSafariBrowser',
        ),
        ApiEventDefinition(
          name: 'onPostMessage',
          description: 'Called when a post message is received.',
          className: 'ChromeSafariBrowser',
        ),
        ApiEventDefinition(
          name: 'onVerticalScrollEvent',
          description: 'Called on vertical scroll events.',
          className: 'ChromeSafariBrowser',
        ),
        ApiEventDefinition(
          name: 'onGreatestScrollPercentageIncreased',
          description: 'Called when the greatest scroll percentage increases.',
          className: 'ChromeSafariBrowser',
        ),
        ApiEventDefinition(
          name: 'onSessionEnded',
          description: 'Called when the session ends.',
          className: 'ChromeSafariBrowser',
        ),
      ],
    );
  }

  static ApiClassDefinition _getCookieManagerDefinition() {
    return ApiClassDefinition(
      className: 'CookieManager',
      description: 'Manages cookies for WebViews.',
      isClassSupported: () => CookieManager.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: 'setCookie',
          signature:
              'Future<bool> setCookie({required WebUri url, required String name, required String value, ...})',
          description: 'Sets a cookie.',
          className: 'CookieManager',
        ),
        ApiMethodDefinition(
          name: 'getCookies',
          signature: 'Future<List<Cookie>> getCookies({required WebUri url})',
          description: 'Gets all cookies for a URL.',
          className: 'CookieManager',
        ),
        ApiMethodDefinition(
          name: 'getCookie',
          signature:
              'Future<Cookie?> getCookie({required WebUri url, required String name})',
          description: 'Gets a specific cookie.',
          className: 'CookieManager',
        ),
        ApiMethodDefinition(
          name: 'deleteCookie',
          signature:
              'Future<void> deleteCookie({required WebUri url, required String name, ...})',
          description: 'Deletes a cookie.',
          className: 'CookieManager',
        ),
        ApiMethodDefinition(
          name: 'deleteCookies',
          signature:
              'Future<void> deleteCookies({required WebUri url, String? domain, String? path})',
          description: 'Deletes cookies for a URL.',
          className: 'CookieManager',
        ),
        ApiMethodDefinition(
          name: 'deleteAllCookies',
          signature: 'Future<void> deleteAllCookies()',
          description: 'Deletes all cookies.',
          className: 'CookieManager',
        ),
        ApiMethodDefinition(
          name: 'removeSessionCookies',
          signature: 'Future<bool> removeSessionCookies()',
          description: 'Removes all session cookies.',
          className: 'CookieManager',
        ),
        ApiMethodDefinition(
          name: 'flush',
          signature: 'Future<void> flush()',
          description: 'Flushes cookies to persistent storage.',
          className: 'CookieManager',
        ),
        ApiMethodDefinition(
          name: 'getAllCookies',
          signature: 'Future<List<Cookie>> getAllCookies()',
          description: 'Gets all cookies.',
          className: 'CookieManager',
        ),
      ],
    );
  }

  static ApiClassDefinition _getWebStorageDefinition() {
    return ApiClassDefinition(
      className: 'WebStorage',
      description: 'Manages localStorage and sessionStorage.',
      isClassSupported: () => WebStorage.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: 'length',
          signature: 'Future<int?> length()',
          description: 'Gets the number of items.',
          className: 'WebStorage',
        ),
        ApiMethodDefinition(
          name: 'setItem',
          signature:
              'Future<void> setItem({required String key, required dynamic value})',
          description: 'Sets an item.',
          className: 'WebStorage',
        ),
        ApiMethodDefinition(
          name: 'getItem',
          signature: 'Future<dynamic> getItem({required String key})',
          description: 'Gets an item.',
          className: 'WebStorage',
        ),
        ApiMethodDefinition(
          name: 'removeItem',
          signature: 'Future<void> removeItem({required String key})',
          description: 'Removes an item.',
          className: 'WebStorage',
        ),
        ApiMethodDefinition(
          name: 'getItems',
          signature: 'Future<List<WebStorageItem>> getItems()',
          description: 'Gets all items.',
          className: 'WebStorage',
        ),
        ApiMethodDefinition(
          name: 'clear',
          signature: 'Future<void> clear()',
          description: 'Clears all items.',
          className: 'WebStorage',
        ),
        ApiMethodDefinition(
          name: 'key',
          signature: 'Future<String> key({required int index})',
          description: 'Gets the key at an index.',
          className: 'WebStorage',
        ),
      ],
    );
  }

  static ApiClassDefinition _getFindInteractionControllerDefinition() {
    return ApiClassDefinition(
      className: 'FindInteractionController',
      description: 'Controls find-in-page functionality.',
      isClassSupported: () => FindInteractionController.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: 'findAll',
          signature: 'Future<void> findAll({String? find})',
          description: 'Finds all occurrences.',
          className: 'FindInteractionController',
        ),
        ApiMethodDefinition(
          name: 'findNext',
          signature: 'Future<void> findNext({bool forward = true})',
          description: 'Finds the next occurrence.',
          className: 'FindInteractionController',
        ),
        ApiMethodDefinition(
          name: 'clearMatches',
          signature: 'Future<void> clearMatches()',
          description: 'Clears all matches.',
          className: 'FindInteractionController',
        ),
        ApiMethodDefinition(
          name: 'setSearchText',
          signature: 'Future<void> setSearchText(String? searchText)',
          description: 'Sets the search text.',
          className: 'FindInteractionController',
        ),
        ApiMethodDefinition(
          name: 'getSearchText',
          signature: 'Future<String?> getSearchText()',
          description: 'Gets the search text.',
          className: 'FindInteractionController',
        ),
        ApiMethodDefinition(
          name: 'isFindNavigatorVisible',
          signature: 'Future<bool?> isFindNavigatorVisible()',
          description: 'Checks if the find navigator is visible.',
          className: 'FindInteractionController',
        ),
        ApiMethodDefinition(
          name: 'presentFindNavigator',
          signature: 'Future<void> presentFindNavigator()',
          description: 'Presents the find navigator.',
          className: 'FindInteractionController',
        ),
        ApiMethodDefinition(
          name: 'dismissFindNavigator',
          signature: 'Future<void> dismissFindNavigator()',
          description: 'Dismisses the find navigator.',
          className: 'FindInteractionController',
        ),
        ApiMethodDefinition(
          name: 'getActiveFindSession',
          signature: 'Future<FindSession?> getActiveFindSession()',
          description: 'Gets the active find session.',
          className: 'FindInteractionController',
        ),
        ApiMethodDefinition(
          name: 'dispose',
          signature: 'void dispose()',
          description: 'Disposes the controller.',
          className: 'FindInteractionController',
        ),
      ],
      events: [
        ApiEventDefinition(
          name: 'onFindResultReceived',
          description: 'Called when find results are received.',
          className: 'FindInteractionController',
        ),
      ],
    );
  }

  static ApiClassDefinition _getPullToRefreshControllerDefinition() {
    return ApiClassDefinition(
      className: 'PullToRefreshController',
      description: 'Controls pull-to-refresh functionality.',
      isClassSupported: () => PullToRefreshController.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: 'setEnabled',
          signature: 'Future<void> setEnabled(bool enabled)',
          description: 'Enables or disables pull-to-refresh.',
          className: 'PullToRefreshController',
        ),
        ApiMethodDefinition(
          name: 'isEnabled',
          signature: 'Future<bool> isEnabled()',
          description: 'Checks if pull-to-refresh is enabled.',
          className: 'PullToRefreshController',
        ),
        ApiMethodDefinition(
          name: 'beginRefreshing',
          signature: 'Future<void> beginRefreshing()',
          description: 'Starts the refresh animation.',
          className: 'PullToRefreshController',
        ),
        ApiMethodDefinition(
          name: 'endRefreshing',
          signature: 'Future<void> endRefreshing()',
          description: 'Stops the refresh animation.',
          className: 'PullToRefreshController',
        ),
        ApiMethodDefinition(
          name: 'isRefreshing',
          signature: 'Future<bool> isRefreshing()',
          description: 'Checks if currently refreshing.',
          className: 'PullToRefreshController',
        ),
        ApiMethodDefinition(
          name: 'setColor',
          signature: 'Future<void> setColor(Color color)',
          description: 'Sets the indicator color.',
          className: 'PullToRefreshController',
        ),
        ApiMethodDefinition(
          name: 'setBackgroundColor',
          signature: 'Future<void> setBackgroundColor(Color color)',
          description: 'Sets the background color.',
          className: 'PullToRefreshController',
        ),
        ApiMethodDefinition(
          name: 'setDistanceToTrigger',
          signature:
              'Future<void> setDistanceToTrigger(double distanceToTrigger)',
          description: 'Sets the distance to trigger refresh.',
          className: 'PullToRefreshController',
        ),
        ApiMethodDefinition(
          name: 'setSlingshotDistance',
          signature:
              'Future<void> setSlingshotDistance(double slingshotDistance)',
          description: 'Sets the slingshot distance.',
          className: 'PullToRefreshController',
        ),
        ApiMethodDefinition(
          name: 'getDefaultSlingshotDistance',
          signature: 'Future<double> getDefaultSlingshotDistance()',
          description: 'Gets the default slingshot distance.',
          className: 'PullToRefreshController',
        ),
        ApiMethodDefinition(
          name: 'setIndicatorSize',
          signature: 'Future<void> setIndicatorSize(PullToRefreshSize size)',
          description: 'Sets the indicator size.',
          className: 'PullToRefreshController',
        ),
        ApiMethodDefinition(
          name: 'dispose',
          signature: 'void dispose()',
          description: 'Disposes the controller.',
          className: 'PullToRefreshController',
        ),
      ],
      events: [
        ApiEventDefinition(
          name: 'onRefresh',
          description: 'Called when a refresh is triggered.',
          className: 'PullToRefreshController',
        ),
      ],
    );
  }

  static ApiClassDefinition _getPrintJobControllerDefinition() {
    return ApiClassDefinition(
      className: 'PrintJobController',
      description: 'Controls print jobs.',
      isClassSupported: () => PrintJobController.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: 'cancel',
          signature: 'Future<void> cancel()',
          description: 'Cancels the print job.',
          className: 'PrintJobController',
        ),
        ApiMethodDefinition(
          name: 'restart',
          signature: 'Future<void> restart()',
          description: 'Restarts the print job.',
          className: 'PrintJobController',
        ),
        ApiMethodDefinition(
          name: 'dismiss',
          signature: 'Future<void> dismiss({bool animated = true})',
          description: 'Dismisses the print interface.',
          className: 'PrintJobController',
        ),
        ApiMethodDefinition(
          name: 'getInfo',
          signature: 'Future<PrintJobInfo?> getInfo()',
          description: 'Gets the print job info.',
          className: 'PrintJobController',
        ),
      ],
      events: [
        ApiEventDefinition(
          name: 'onComplete',
          description: 'Called when the print job completes.',
          className: 'PrintJobController',
        ),
      ],
    );
  }

  static ApiClassDefinition _getWebAuthenticationSessionDefinition() {
    return ApiClassDefinition(
      className: 'WebAuthenticationSession',
      description: 'Handles web authentication sessions.',
      isClassSupported: () => WebAuthenticationSession.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: 'create',
          signature: 'static Future<WebAuthenticationSession> create({...})',
          description: 'Creates a new authentication session.',
          className: 'WebAuthenticationSession',
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'canStart',
          signature: 'Future<bool> canStart()',
          description: 'Checks if the session can start.',
          className: 'WebAuthenticationSession',
        ),
        ApiMethodDefinition(
          name: 'start',
          signature: 'Future<void> start()',
          description: 'Starts the authentication session.',
          className: 'WebAuthenticationSession',
        ),
        ApiMethodDefinition(
          name: 'cancel',
          signature: 'Future<void> cancel()',
          description: 'Cancels the session.',
          className: 'WebAuthenticationSession',
        ),
        ApiMethodDefinition(
          name: 'dispose',
          signature: 'Future<void> dispose()',
          description: 'Disposes the session.',
          className: 'WebAuthenticationSession',
        ),
        ApiMethodDefinition(
          name: 'isAvailable',
          signature: 'static Future<bool> isAvailable()',
          description: 'Checks if web authentication is available.',
          className: 'WebAuthenticationSession',
          isStatic: true,
        ),
      ],
      events: [
        ApiEventDefinition(
          name: 'onComplete',
          description: 'Called when authentication completes.',
          className: 'WebAuthenticationSession',
        ),
      ],
    );
  }

  static ApiClassDefinition _getServiceWorkerControllerDefinition() {
    return ApiClassDefinition(
      className: 'ServiceWorkerController',
      description: 'Controls service workers.',
      isClassSupported: () => ServiceWorkerController.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: 'instance',
          signature: 'static ServiceWorkerController instance()',
          description: 'Gets the singleton instance.',
          className: 'ServiceWorkerController',
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'setServiceWorkerClient',
          signature:
              'Future<void> setServiceWorkerClient(ServiceWorkerClient? value)',
          description: 'Sets the service worker client.',
          className: 'ServiceWorkerController',
        ),
        ApiMethodDefinition(
          name: 'getServiceWorkerClient',
          signature: 'Future<ServiceWorkerClient?> getServiceWorkerClient()',
          description: 'Gets the service worker client.',
          className: 'ServiceWorkerController',
        ),
        ApiMethodDefinition(
          name: 'getAllowContentAccess',
          signature: 'Future<bool> getAllowContentAccess()',
          description: 'Gets allow content access setting.',
          className: 'ServiceWorkerController',
        ),
        ApiMethodDefinition(
          name: 'setAllowContentAccess',
          signature: 'Future<void> setAllowContentAccess(bool allow)',
          description: 'Sets allow content access setting.',
          className: 'ServiceWorkerController',
        ),
        ApiMethodDefinition(
          name: 'getAllowFileAccess',
          signature: 'Future<bool> getAllowFileAccess()',
          description: 'Gets allow file access setting.',
          className: 'ServiceWorkerController',
        ),
        ApiMethodDefinition(
          name: 'setAllowFileAccess',
          signature: 'Future<void> setAllowFileAccess(bool allow)',
          description: 'Sets allow file access setting.',
          className: 'ServiceWorkerController',
        ),
        ApiMethodDefinition(
          name: 'getBlockNetworkLoads',
          signature: 'Future<bool> getBlockNetworkLoads()',
          description: 'Gets block network loads setting.',
          className: 'ServiceWorkerController',
        ),
        ApiMethodDefinition(
          name: 'setBlockNetworkLoads',
          signature: 'Future<void> setBlockNetworkLoads(bool block)',
          description: 'Sets block network loads setting.',
          className: 'ServiceWorkerController',
        ),
      ],
      events: [
        ApiEventDefinition(
          name: 'shouldInterceptRequest',
          description: 'Called to intercept service worker requests.',
          className: 'ServiceWorkerController',
        ),
      ],
    );
  }

  static ApiClassDefinition _getProxyControllerDefinition() {
    return ApiClassDefinition(
      className: 'ProxyController',
      description: 'Controls proxy settings.',
      isClassSupported: () => ProxyController.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: 'setProxyOverride',
          signature:
              'Future<void> setProxyOverride({required ProxySettings settings})',
          description: 'Sets the proxy override.',
          className: 'ProxyController',
        ),
        ApiMethodDefinition(
          name: 'clearProxyOverride',
          signature: 'Future<void> clearProxyOverride()',
          description: 'Clears the proxy override.',
          className: 'ProxyController',
        ),
      ],
    );
  }

  static ApiClassDefinition _getTracingControllerDefinition() {
    return ApiClassDefinition(
      className: 'TracingController',
      description: 'Controls tracing.',
      isClassSupported: () => TracingController.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: 'start',
          signature: 'Future<void> start({required TracingSettings settings})',
          description: 'Starts tracing.',
          className: 'TracingController',
        ),
        ApiMethodDefinition(
          name: 'stop',
          signature: 'Future<bool> stop({String? filePath})',
          description: 'Stops tracing.',
          className: 'TracingController',
        ),
        ApiMethodDefinition(
          name: 'isTracing',
          signature: 'Future<bool> isTracing()',
          description: 'Checks if tracing is active.',
          className: 'TracingController',
        ),
      ],
    );
  }

  static ApiClassDefinition _getHttpAuthCredentialDatabaseDefinition() {
    return ApiClassDefinition(
      className: 'HttpAuthCredentialDatabase',
      description: 'Manages HTTP authentication credentials.',
      isClassSupported: () => HttpAuthCredentialDatabase.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: 'getAllAuthCredentials',
          signature:
              'Future<List<URLProtectionSpaceHttpAuthCredentials>> getAllAuthCredentials()',
          description: 'Gets all stored credentials.',
          className: 'HttpAuthCredentialDatabase',
        ),
        ApiMethodDefinition(
          name: 'getHttpAuthCredentials',
          signature:
              'Future<List<URLCredential>> getHttpAuthCredentials({...})',
          description: 'Gets credentials for a protection space.',
          className: 'HttpAuthCredentialDatabase',
        ),
        ApiMethodDefinition(
          name: 'setHttpAuthCredential',
          signature: 'Future<void> setHttpAuthCredential({...})',
          description: 'Sets a credential.',
          className: 'HttpAuthCredentialDatabase',
        ),
        ApiMethodDefinition(
          name: 'removeHttpAuthCredential',
          signature: 'Future<void> removeHttpAuthCredential({...})',
          description: 'Removes a credential.',
          className: 'HttpAuthCredentialDatabase',
        ),
        ApiMethodDefinition(
          name: 'removeHttpAuthCredentials',
          signature: 'Future<void> removeHttpAuthCredentials({...})',
          description: 'Removes all credentials for a protection space.',
          className: 'HttpAuthCredentialDatabase',
        ),
        ApiMethodDefinition(
          name: 'clearAllAuthCredentials',
          signature: 'Future<void> clearAllAuthCredentials()',
          description: 'Clears all credentials.',
          className: 'HttpAuthCredentialDatabase',
        ),
      ],
    );
  }

  static ApiClassDefinition _getWebViewEnvironmentDefinition() {
    return ApiClassDefinition(
      className: 'WebViewEnvironment',
      description: 'WebView2 environment for Windows.',
      isClassSupported: () => WebViewEnvironment.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: 'create',
          signature: 'static Future<WebViewEnvironment> create({...})',
          description: 'Creates a WebView environment.',
          className: 'WebViewEnvironment',
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'getAvailableVersion',
          signature:
              'static Future<String?> getAvailableVersion({String? browserExecutableFolder})',
          description: 'Gets the available WebView2 version.',
          className: 'WebViewEnvironment',
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'getProcessInfos',
          signature: 'Future<List<BrowserProcessInfo>> getProcessInfos()',
          description: 'Gets running process information.',
          className: 'WebViewEnvironment',
        ),
        ApiMethodDefinition(
          name: 'compareBrowserVersions',
          signature: 'static Future<int> compareBrowserVersions({...})',
          description: 'Compares browser versions.',
          className: 'WebViewEnvironment',
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'dispose',
          signature: 'Future<void> dispose()',
          description: 'Disposes the environment.',
          className: 'WebViewEnvironment',
        ),
      ],
      events: [
        ApiEventDefinition(
          name: 'onBrowserProcessExited',
          description: 'Called when the browser process exits.',
          className: 'WebViewEnvironment',
        ),
        ApiEventDefinition(
          name: 'onProcessInfosChanged',
          description: 'Called when process info changes.',
          className: 'WebViewEnvironment',
        ),
        ApiEventDefinition(
          name: 'onNewBrowserVersionAvailable',
          description: 'Called when a new browser version is available.',
          className: 'WebViewEnvironment',
        ),
      ],
    );
  }

  static ApiClassDefinition _getProcessGlobalConfigDefinition() {
    return ApiClassDefinition(
      className: 'ProcessGlobalConfig',
      description: 'Global process configuration for Android.',
      isClassSupported: () => ProcessGlobalConfig.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: 'apply',
          signature:
              'Future<void> apply({required ProcessGlobalConfigSettings settings})',
          description: 'Applies global configuration settings.',
          className: 'ProcessGlobalConfig',
        ),
      ],
    );
  }

  static ApiClassDefinition _getWebMessageChannelDefinition() {
    return ApiClassDefinition(
      className: 'WebMessageChannel',
      description: 'HTML5 message channel for two-way communication.',
      isClassSupported: () => WebMessageChannel.isClassSupported(),
      methods: [
        ApiMethodDefinition(
          name: 'dispose',
          signature: 'void dispose()',
          description: 'Disposes the channel.',
          className: 'WebMessageChannel',
        ),
      ],
    );
  }
}
