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
  final Set<SupportedPlatform> supportedPlatforms;
  final bool isStatic;
  final bool isDeprecated;
  final String? category;

  const ApiMethodDefinition({
    required this.name,
    this.signature = '',
    this.description = '',
    required this.supportedPlatforms,
    this.isStatic = false,
    this.isDeprecated = false,
    this.category,
  });

  bool isSupported(SupportedPlatform platform) =>
      supportedPlatforms.contains(platform);
}

/// Definition of an API event with platform support information.
class ApiEventDefinition {
  final String name;
  final String signature;
  final String description;
  final Set<SupportedPlatform> supportedPlatforms;
  final String? category;

  const ApiEventDefinition({
    required this.name,
    this.signature = '',
    this.description = '',
    required this.supportedPlatforms,
    this.category,
  });

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
    'InAppWebViewController': InAppWebViewController.isClassSupported,
    'InAppWebView Events': InAppWebView.isClassSupported,
    'HeadlessInAppWebView': HeadlessInAppWebView.isClassSupported,
    'InAppBrowser': InAppBrowser.isClassSupported,
    'ChromeSafariBrowser': ChromeSafariBrowser.isClassSupported,
    'CookieManager': CookieManager.isClassSupported,
    'WebStorage': WebStorage.isClassSupported,
    'FindInteractionController': FindInteractionController.isClassSupported,
    'PullToRefreshController': PullToRefreshController.isClassSupported,
    'PrintJobController': PrintJobController.isClassSupported,
    'WebAuthenticationSession': WebAuthenticationSession.isClassSupported,
    'ServiceWorkerController': ServiceWorkerController.isClassSupported,
    'ProxyController': ProxyController.isClassSupported,
    'TracingController': TracingController.isClassSupported,
    'HttpAuthCredentialDatabase': HttpAuthCredentialDatabase.isClassSupported,
    'WebViewEnvironment': WebViewEnvironment.isClassSupported,
    'ProcessGlobalConfig': ProcessGlobalConfig.isClassSupported,
    'WebMessageChannel': WebMessageChannel.isClassSupported,
  };

  static final Map<String, _MethodSupportResolver> _methodSupportResolvers = {
    'InAppWebViewController': _buildMethodResolver(
      values: PlatformInAppWebViewControllerMethod.values,
      checker: InAppWebViewController.isMethodSupported,
    ),
    'HeadlessInAppWebView': _buildMethodResolver(
      values: PlatformHeadlessInAppWebViewMethod.values,
      checker: HeadlessInAppWebView.isMethodSupported,
    ),
    'InAppBrowser': _buildMethodResolver(
      values: PlatformInAppBrowserMethod.values,
      checker: InAppBrowser.isMethodSupported,
    ),
    'ChromeSafariBrowser': _buildMethodResolver(
      values: PlatformChromeSafariBrowserMethod.values,
      checker: ChromeSafariBrowser.isMethodSupported,
    ),
    'CookieManager': _buildMethodResolver(
      values: PlatformCookieManagerMethod.values,
      checker: CookieManager.isMethodSupported,
    ),
    'WebStorage': _buildMethodResolver(
      values: PlatformLocalStorageMethod.values,
      checker: LocalStorage.isMethodSupported,
    ),
    'FindInteractionController': _buildMethodResolver(
      values: PlatformFindInteractionControllerMethod.values,
      checker: FindInteractionController.isMethodSupported,
    ),
    'PullToRefreshController': _buildMethodResolver(
      values: PlatformPullToRefreshControllerMethod.values,
      checker: PullToRefreshController.isMethodSupported,
    ),
    'PrintJobController': _buildMethodResolver(
      values: PlatformPrintJobControllerMethod.values,
      checker: PrintJobController.isMethodSupported,
    ),
    'WebAuthenticationSession': _buildMethodResolver(
      values: PlatformWebAuthenticationSessionMethod.values,
      checker: WebAuthenticationSession.isMethodSupported,
    ),
    'ServiceWorkerController': _buildMethodResolver(
      values: PlatformServiceWorkerControllerMethod.values,
      checker: ServiceWorkerController.isMethodSupported,
    ),
    'ProxyController': _buildMethodResolver(
      values: PlatformProxyControllerMethod.values,
      checker: ProxyController.isMethodSupported,
    ),
    'TracingController': _buildMethodResolver(
      values: PlatformTracingControllerMethod.values,
      checker: TracingController.isMethodSupported,
    ),
    'HttpAuthCredentialDatabase': _buildMethodResolver(
      values: PlatformHttpAuthCredentialDatabaseMethod.values,
      checker: HttpAuthCredentialDatabase.isMethodSupported,
    ),
    'WebViewEnvironment': _buildMethodResolver(
      values: PlatformWebViewEnvironmentMethod.values,
      checker: WebViewEnvironment.isMethodSupported,
    ),
    'ProcessGlobalConfig': _buildMethodResolver(
      values: PlatformProcessGlobalConfigMethod.values,
      checker: ProcessGlobalConfig.isMethodSupported,
    ),
    'WebMessageChannel': _buildMethodResolver(
      values: PlatformWebMessageChannelMethod.values,
      checker: WebMessageChannel.isMethodSupported,
    ),
  };

  static final Map<String, _PropertySupportResolver> _eventSupportResolvers = {
    'InAppWebView Events': _buildPropertyResolver(
      values: PlatformWebViewCreationParamsProperty.values,
      checker: InAppWebView.isPropertySupported,
    ),
    'FindInteractionController': _buildPropertyResolver(
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

    final definitions = getAllApiDefinitions();
    final classDef = definitions.cast<ApiClassDefinition?>().firstWhere(
      (c) => c?.className == className,
      orElse: () => null,
    );

    final method = classDef?.methods.cast<ApiMethodDefinition?>().firstWhere(
      (m) => m?.name == methodName,
      orElse: () => null,
    );

    return method?.supportedPlatforms ?? <SupportedPlatform>{};
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

    final definitions = getAllApiDefinitions();
    final classDef = definitions.cast<ApiClassDefinition?>().firstWhere(
      (c) => c?.className == className,
      orElse: () => null,
    );

    final event = classDef?.events.cast<ApiEventDefinition?>().firstWhere(
      (e) => e?.name == eventName,
      orElse: () => null,
    );

    return event?.supportedPlatforms ?? <SupportedPlatform>{};
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
          supportedPlatforms: allPlatforms,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'postUrl',
          signature:
              'Future<void> postUrl({required WebUri url, required Uint8List postData})',
          description: 'Loads the URL with POST data.',
          supportedPlatforms: {
            ...mobilePlatforms,
            SupportedPlatform.macos,
            SupportedPlatform.windows,
          },
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'loadData',
          signature: 'Future<void> loadData({required String data, ...})',
          description: 'Loads HTML data directly into the WebView.',
          supportedPlatforms: allPlatforms,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'loadFile',
          signature: 'Future<void> loadFile({required String assetFilePath})',
          description: 'Loads a file from the asset bundle.',
          supportedPlatforms: allPlatforms,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'reload',
          signature: 'Future<void> reload()',
          description: 'Reloads the current page.',
          supportedPlatforms: allPlatforms,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'reloadFromOrigin',
          signature: 'Future<void> reloadFromOrigin()',
          description:
              'Reloads the current page, performing end-to-end validation.',
          supportedPlatforms: applePlatforms,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'goBack',
          signature: 'Future<void> goBack()',
          description: 'Goes back in the history of the WebView.',
          supportedPlatforms: allPlatforms,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'goForward',
          signature: 'Future<void> goForward()',
          description: 'Goes forward in the history of the WebView.',
          supportedPlatforms: allPlatforms,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'goBackOrForward',
          signature: 'Future<void> goBackOrForward({required int steps})',
          description: 'Goes to the history item at the given offset.',
          supportedPlatforms: {...nativePlatforms},
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'goTo',
          signature: 'Future<void> goTo({required WebHistoryItem historyItem})',
          description: 'Goes to the specified history item.',
          supportedPlatforms: {...applePlatforms, SupportedPlatform.android},
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'canGoBack',
          signature: 'Future<bool> canGoBack()',
          description: 'Returns whether the WebView can go back in history.',
          supportedPlatforms: allPlatforms,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'canGoForward',
          signature: 'Future<bool> canGoForward()',
          description: 'Returns whether the WebView can go forward in history.',
          supportedPlatforms: allPlatforms,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'canGoBackOrForward',
          signature: 'Future<bool> canGoBackOrForward({required int steps})',
          description:
              'Returns whether the WebView can go to the specified offset.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'isLoading',
          signature: 'Future<bool> isLoading()',
          description: 'Returns whether the WebView is currently loading.',
          supportedPlatforms: {...nativePlatforms},
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'stopLoading',
          signature: 'Future<void> stopLoading()',
          description: 'Stops the current page load.',
          supportedPlatforms: allPlatforms,
          category: 'Navigation',
        ),
        ApiMethodDefinition(
          name: 'loadSimulatedRequest',
          signature:
              'Future<void> loadSimulatedRequest({required URLRequest urlRequest, ...})',
          description:
              'Navigates to a requested URL with simulated response data.',
          supportedPlatforms: applePlatforms,
          category: 'Navigation',
        ),

        // Page Info methods
        ApiMethodDefinition(
          name: 'getUrl',
          signature: 'Future<WebUri?> getUrl()',
          description: 'Gets the current URL of the WebView.',
          supportedPlatforms: allPlatforms,
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: 'getTitle',
          signature: 'Future<String?> getTitle()',
          description: 'Gets the title of the current page.',
          supportedPlatforms: allPlatforms,
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: 'getProgress',
          signature: 'Future<int?> getProgress()',
          description: 'Gets the current loading progress.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: 'getHtml',
          signature: 'Future<String?> getHtml()',
          description: 'Gets the HTML content of the current page.',
          supportedPlatforms: allPlatforms,
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: 'getFavicons',
          signature: 'Future<List<Favicon>> getFavicons()',
          description: 'Gets the favicons of the current page.',
          supportedPlatforms: allPlatforms,
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: 'getOriginalUrl',
          signature: 'Future<WebUri?> getOriginalUrl()',
          description: 'Gets the original URL before redirects.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: 'getSelectedText',
          signature: 'Future<String?> getSelectedText()',
          description: 'Gets the currently selected text.',
          supportedPlatforms: {...nativePlatforms},
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: 'getHitTestResult',
          signature: 'Future<InAppWebViewHitTestResult?> getHitTestResult()',
          description: 'Gets a hit test result for the last tap.',
          supportedPlatforms: {
            SupportedPlatform.android,
            SupportedPlatform.linux,
          },
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: 'getMetaTags',
          signature: 'Future<List<MetaTag>> getMetaTags()',
          description: 'Gets all meta tags of the current page.',
          supportedPlatforms: allPlatforms,
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: 'getMetaThemeColor',
          signature: 'Future<Color?> getMetaThemeColor()',
          description: 'Gets the meta theme color of the page.',
          supportedPlatforms: allPlatforms,
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: 'getCertificate',
          signature: 'Future<SslCertificate?> getCertificate()',
          description: 'Gets the SSL certificate for the main resource.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
          category: 'Page Info',
        ),
        ApiMethodDefinition(
          name: 'getCopyBackForwardList',
          signature: 'Future<WebHistory?> getCopyBackForwardList()',
          description: 'Gets a copy of the back/forward list.',
          supportedPlatforms: {...nativePlatforms},
          category: 'Page Info',
        ),

        // JavaScript methods
        ApiMethodDefinition(
          name: 'evaluateJavascript',
          signature:
              'Future<dynamic> evaluateJavascript({required String source, ...})',
          description: 'Evaluates JavaScript code and returns the result.',
          supportedPlatforms: allPlatforms,
          category: 'JavaScript',
        ),
        ApiMethodDefinition(
          name: 'callAsyncJavaScript',
          signature:
              'Future<CallAsyncJavaScriptResult?> callAsyncJavaScript({...})',
          description: 'Calls a JavaScript function asynchronously.',
          supportedPlatforms: {...nativePlatforms, SupportedPlatform.web},
          category: 'JavaScript',
        ),
        ApiMethodDefinition(
          name: 'injectJavascriptFileFromUrl',
          signature:
              'Future<void> injectJavascriptFileFromUrl({required WebUri urlFile, ...})',
          description: 'Injects a JavaScript file from a URL.',
          supportedPlatforms: allPlatforms,
          category: 'JavaScript',
        ),
        ApiMethodDefinition(
          name: 'injectJavascriptFileFromAsset',
          signature:
              'Future<dynamic> injectJavascriptFileFromAsset({required String assetFilePath})',
          description: 'Injects a JavaScript file from assets.',
          supportedPlatforms: allPlatforms,
          category: 'JavaScript',
        ),
        ApiMethodDefinition(
          name: 'injectCSSCode',
          signature: 'Future<void> injectCSSCode({required String source})',
          description: 'Injects CSS code into the page.',
          supportedPlatforms: allPlatforms,
          category: 'JavaScript',
        ),
        ApiMethodDefinition(
          name: 'injectCSSFileFromUrl',
          signature:
              'Future<void> injectCSSFileFromUrl({required WebUri urlFile, ...})',
          description: 'Injects a CSS file from a URL.',
          supportedPlatforms: allPlatforms,
          category: 'JavaScript',
        ),
        ApiMethodDefinition(
          name: 'injectCSSFileFromAsset',
          signature:
              'Future<void> injectCSSFileFromAsset({required String assetFilePath})',
          description: 'Injects a CSS file from assets.',
          supportedPlatforms: allPlatforms,
          category: 'JavaScript',
        ),

        // JavaScript Handler methods
        ApiMethodDefinition(
          name: 'addJavaScriptHandler',
          signature:
              'void addJavaScriptHandler({required String handlerName, ...})',
          description: 'Adds a handler for JavaScript to call.',
          supportedPlatforms: allPlatforms,
          category: 'Handlers',
        ),
        ApiMethodDefinition(
          name: 'removeJavaScriptHandler',
          signature:
              'JavaScriptHandlerCallback? removeJavaScriptHandler({required String handlerName})',
          description: 'Removes a JavaScript handler.',
          supportedPlatforms: allPlatforms,
          category: 'Handlers',
        ),
        ApiMethodDefinition(
          name: 'hasJavaScriptHandler',
          signature: 'bool hasJavaScriptHandler({required String handlerName})',
          description: 'Checks if a JavaScript handler exists.',
          supportedPlatforms: allPlatforms,
          category: 'Handlers',
        ),

        // User Scripts methods
        ApiMethodDefinition(
          name: 'addUserScript',
          signature:
              'Future<void> addUserScript({required UserScript userScript})',
          description: 'Adds a user script to the WebView.',
          supportedPlatforms: allPlatforms,
          category: 'User Scripts',
        ),
        ApiMethodDefinition(
          name: 'removeUserScript',
          signature:
              'Future<bool> removeUserScript({required UserScript userScript})',
          description: 'Removes a user script.',
          supportedPlatforms: allPlatforms,
          category: 'User Scripts',
        ),
        ApiMethodDefinition(
          name: 'removeUserScriptsByGroupName',
          signature:
              'Future<void> removeUserScriptsByGroupName({required String groupName})',
          description: 'Removes user scripts by group name.',
          supportedPlatforms: allPlatforms,
          category: 'User Scripts',
        ),
        ApiMethodDefinition(
          name: 'removeAllUserScripts',
          signature: 'Future<void> removeAllUserScripts()',
          description: 'Removes all user scripts.',
          supportedPlatforms: allPlatforms,
          category: 'User Scripts',
        ),
        ApiMethodDefinition(
          name: 'hasUserScript',
          signature: 'bool hasUserScript({required UserScript userScript})',
          description: 'Checks if a user script exists.',
          supportedPlatforms: allPlatforms,
          category: 'User Scripts',
        ),

        // Scrolling methods
        ApiMethodDefinition(
          name: 'scrollTo',
          signature:
              'Future<void> scrollTo({required int x, required int y, bool animated})',
          description: 'Scrolls the WebView to the specified position.',
          supportedPlatforms: allPlatforms,
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: 'scrollBy',
          signature:
              'Future<void> scrollBy({required int x, required int y, bool animated})',
          description: 'Scrolls the WebView by the specified amount.',
          supportedPlatforms: allPlatforms,
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: 'getScrollX',
          signature: 'Future<int?> getScrollX()',
          description: 'Gets the current horizontal scroll position.',
          supportedPlatforms: nativePlatforms,
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: 'getScrollY',
          signature: 'Future<int?> getScrollY()',
          description: 'Gets the current vertical scroll position.',
          supportedPlatforms: nativePlatforms,
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: 'getContentHeight',
          signature: 'Future<int?> getContentHeight()',
          description: 'Gets the height of the HTML content.',
          supportedPlatforms: nativePlatforms,
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: 'getContentWidth',
          signature: 'Future<int?> getContentWidth()',
          description: 'Gets the width of the HTML content.',
          supportedPlatforms: nativePlatforms,
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: 'canScrollVertically',
          signature: 'Future<bool> canScrollVertically()',
          description: 'Checks if the WebView can scroll vertically.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: 'canScrollHorizontally',
          signature: 'Future<bool> canScrollHorizontally()',
          description: 'Checks if the WebView can scroll horizontally.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: 'pageDown',
          signature: 'Future<bool> pageDown({required bool bottom})',
          description: 'Scrolls down by half or full page.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Scrolling',
        ),
        ApiMethodDefinition(
          name: 'pageUp',
          signature: 'Future<bool> pageUp({required bool top})',
          description: 'Scrolls up by half or full page.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Scrolling',
        ),

        // Zoom methods
        ApiMethodDefinition(
          name: 'zoomBy',
          signature: 'Future<void> zoomBy({required double zoomFactor, ...})',
          description: 'Zooms by the specified factor.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.windows},
          category: 'Zoom',
        ),
        ApiMethodDefinition(
          name: 'zoomIn',
          signature: 'Future<bool> zoomIn()',
          description: 'Zooms in by a standard amount.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Zoom',
        ),
        ApiMethodDefinition(
          name: 'zoomOut',
          signature: 'Future<bool> zoomOut()',
          description: 'Zooms out by a standard amount.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Zoom',
        ),
        ApiMethodDefinition(
          name: 'getZoomScale',
          signature: 'Future<double?> getZoomScale()',
          description: 'Gets the current zoom scale.',
          supportedPlatforms: {...nativePlatforms},
          category: 'Zoom',
        ),

        // Settings methods
        ApiMethodDefinition(
          name: 'setSettings',
          signature:
              'Future<void> setSettings({required InAppWebViewSettings settings})',
          description: 'Updates the WebView settings.',
          supportedPlatforms: allPlatforms,
          category: 'Settings',
        ),
        ApiMethodDefinition(
          name: 'getSettings',
          signature: 'Future<InAppWebViewSettings?> getSettings()',
          description: 'Gets the current WebView settings.',
          supportedPlatforms: allPlatforms,
          category: 'Settings',
        ),
        ApiMethodDefinition(
          name: 'setContextMenu',
          signature: 'Future<void> setContextMenu(ContextMenu? contextMenu)',
          description: 'Sets the context menu.',
          supportedPlatforms: {SupportedPlatform.android, ...applePlatforms},
          category: 'Settings',
        ),
        ApiMethodDefinition(
          name: 'requestFocus',
          signature: 'Future<void> requestFocus()',
          description: 'Requests focus for the WebView.',
          supportedPlatforms: {
            SupportedPlatform.android,
            SupportedPlatform.windows,
          },
          category: 'Settings',
        ),
        ApiMethodDefinition(
          name: 'clearFocus',
          signature: 'Future<void> clearFocus()',
          description: 'Clears focus from the WebView.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Settings',
        ),

        // Screenshot methods
        ApiMethodDefinition(
          name: 'takeScreenshot',
          signature:
              'Future<Uint8List?> takeScreenshot({ScreenshotConfiguration? screenshotConfiguration})',
          description: 'Takes a screenshot of the WebView.',
          supportedPlatforms: nativePlatforms,
          category: 'Screenshot',
        ),
        ApiMethodDefinition(
          name: 'printCurrentPage',
          signature:
              'Future<PrintJobController?> printCurrentPage({PrintJobSettings? settings})',
          description: 'Prints the current page.',
          supportedPlatforms: {...nativePlatforms},
          category: 'Screenshot',
        ),
        ApiMethodDefinition(
          name: 'createPdf',
          signature:
              'Future<Uint8List?> createPdf({PdfConfiguration? pdfConfiguration})',
          description: 'Creates a PDF from the current page.',
          supportedPlatforms: applePlatforms,
          category: 'Screenshot',
        ),

        // Cache methods
        ApiMethodDefinition(
          name: 'clearHistory',
          signature: 'Future<void> clearHistory()',
          description: 'Clears the WebView history.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Cache',
        ),
        ApiMethodDefinition(
          name: 'clearFormData',
          signature: 'Future<void> clearFormData()',
          description: 'Clears form data.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Cache',
        ),
        ApiMethodDefinition(
          name: 'clearSslPreferences',
          signature: 'Future<void> clearSslPreferences()',
          description: 'Clears SSL preferences.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Cache',
        ),

        // Pause/Resume methods
        ApiMethodDefinition(
          name: 'pause',
          signature: 'Future<void> pause()',
          description: 'Pauses the WebView.',
          supportedPlatforms: {
            SupportedPlatform.android,
            SupportedPlatform.windows,
          },
          category: 'Pause/Resume',
        ),
        ApiMethodDefinition(
          name: 'resume',
          signature: 'Future<void> resume()',
          description: 'Resumes the WebView.',
          supportedPlatforms: {
            SupportedPlatform.android,
            SupportedPlatform.windows,
          },
          category: 'Pause/Resume',
        ),
        ApiMethodDefinition(
          name: 'pauseTimers',
          signature: 'Future<void> pauseTimers()',
          description: 'Pauses all layout, parsing, and JavaScript timers.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Pause/Resume',
        ),
        ApiMethodDefinition(
          name: 'resumeTimers',
          signature: 'Future<void> resumeTimers()',
          description: 'Resumes all layout, parsing, and JavaScript timers.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Pause/Resume',
        ),

        // Web Messaging methods
        ApiMethodDefinition(
          name: 'createWebMessageChannel',
          signature: 'Future<WebMessageChannel?> createWebMessageChannel()',
          description: 'Creates a message channel for communication.',
          supportedPlatforms: {...nativePlatforms},
          category: 'Web Messaging',
        ),
        ApiMethodDefinition(
          name: 'postWebMessage',
          signature:
              'Future<void> postWebMessage({required WebMessage message, ...})',
          description: 'Posts a message to the WebView.',
          supportedPlatforms: {...nativePlatforms},
          category: 'Web Messaging',
        ),
        ApiMethodDefinition(
          name: 'addWebMessageListener',
          signature:
              'Future<void> addWebMessageListener(WebMessageListener webMessageListener)',
          description: 'Adds a listener for web messages.',
          supportedPlatforms: {...nativePlatforms},
          category: 'Web Messaging',
        ),
        ApiMethodDefinition(
          name: 'hasWebMessageListener',
          signature:
              'bool hasWebMessageListener({required String jsObjectName})',
          description: 'Checks if a web message listener exists.',
          supportedPlatforms: {...nativePlatforms},
          category: 'Web Messaging',
        ),

        // Media methods
        ApiMethodDefinition(
          name: 'isInFullscreen',
          signature: 'Future<bool?> isInFullscreen()',
          description: 'Returns whether the WebView is in fullscreen mode.',
          supportedPlatforms: {...nativePlatforms},
          category: 'Media',
        ),
        ApiMethodDefinition(
          name: 'pauseAllMediaPlayback',
          signature: 'Future<void> pauseAllMediaPlayback()',
          description: 'Pauses all media playback.',
          supportedPlatforms: applePlatforms,
          category: 'Media',
        ),
        ApiMethodDefinition(
          name: 'setAllMediaPlaybackSuspended',
          signature:
              'Future<void> setAllMediaPlaybackSuspended({required bool suspended})',
          description: 'Suspends or resumes all media playback.',
          supportedPlatforms: applePlatforms,
          category: 'Media',
        ),
        ApiMethodDefinition(
          name: 'closeAllMediaPresentations',
          signature: 'Future<void> closeAllMediaPresentations()',
          description: 'Closes all media presentations.',
          supportedPlatforms: applePlatforms,
          category: 'Media',
        ),
        ApiMethodDefinition(
          name: 'requestMediaPlaybackState',
          signature: 'Future<MediaPlaybackState?> requestMediaPlaybackState()',
          description: 'Gets the current media playback state.',
          supportedPlatforms: applePlatforms,
          category: 'Media',
        ),
        ApiMethodDefinition(
          name: 'isPlayingAudio',
          signature: 'Future<bool?> isPlayingAudio()',
          description: 'Checks if audio is currently playing.',
          supportedPlatforms: applePlatforms,
          category: 'Media',
        ),
        ApiMethodDefinition(
          name: 'isMuted',
          signature: 'Future<bool?> isMuted()',
          description: 'Checks if audio is muted.',
          supportedPlatforms: applePlatforms,
          category: 'Media',
        ),
        ApiMethodDefinition(
          name: 'setMuted',
          signature: 'Future<void> setMuted({required bool muted})',
          description: 'Sets the muted state.',
          supportedPlatforms: applePlatforms,
          category: 'Media',
        ),

        // Camera/Mic methods
        ApiMethodDefinition(
          name: 'getCameraCaptureState',
          signature: 'Future<MediaCaptureState?> getCameraCaptureState()',
          description: 'Gets the camera capture state.',
          supportedPlatforms: applePlatforms,
          category: 'Camera/Mic',
        ),
        ApiMethodDefinition(
          name: 'setCameraCaptureState',
          signature:
              'Future<void> setCameraCaptureState({required MediaCaptureState state})',
          description: 'Sets the camera capture state.',
          supportedPlatforms: applePlatforms,
          category: 'Camera/Mic',
        ),
        ApiMethodDefinition(
          name: 'getMicrophoneCaptureState',
          signature: 'Future<MediaCaptureState?> getMicrophoneCaptureState()',
          description: 'Gets the microphone capture state.',
          supportedPlatforms: applePlatforms,
          category: 'Camera/Mic',
        ),
        ApiMethodDefinition(
          name: 'setMicrophoneCaptureState',
          signature:
              'Future<void> setMicrophoneCaptureState({required MediaCaptureState state})',
          description: 'Sets the microphone capture state.',
          supportedPlatforms: applePlatforms,
          category: 'Camera/Mic',
        ),

        // Security methods
        ApiMethodDefinition(
          name: 'isSecureContext',
          signature: 'Future<bool> isSecureContext()',
          description: 'Checks if the current context is secure (HTTPS).',
          supportedPlatforms: allPlatforms,
          category: 'Security',
        ),
        ApiMethodDefinition(
          name: 'hasOnlySecureContent',
          signature: 'Future<bool> hasOnlySecureContent()',
          description: 'Checks if the page has only secure content.',
          supportedPlatforms: applePlatforms,
          category: 'Security',
        ),

        // Android-specific methods
        ApiMethodDefinition(
          name: 'startSafeBrowsing',
          signature: 'Future<bool> startSafeBrowsing()',
          description: 'Starts the Safe Browsing initialization.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Android',
        ),
        ApiMethodDefinition(
          name: 'saveWebArchive',
          signature:
              'Future<String?> saveWebArchive({required String basename, ...})',
          description: 'Saves the current page as a web archive.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Android',
        ),
        ApiMethodDefinition(
          name: 'requestFocusNodeHref',
          signature:
              'Future<RequestFocusNodeHrefResult?> requestFocusNodeHref()',
          description: 'Requests the URL of the focused anchor.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Android',
        ),
        ApiMethodDefinition(
          name: 'requestImageRef',
          signature: 'Future<RequestImageRefResult?> requestImageRef()',
          description: 'Requests the URL of the focused image.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Android',
        ),
        ApiMethodDefinition(
          name: 'saveState',
          signature: 'Future<Uint8List?> saveState()',
          description: 'Saves the WebView state to a bundle.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Android',
        ),
        ApiMethodDefinition(
          name: 'restoreState',
          signature: 'Future<void> restoreState({required Uint8List state})',
          description: 'Restores the WebView state from a bundle.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Android',
        ),

        // iOS/macOS-specific methods
        ApiMethodDefinition(
          name: 'createWebArchiveData',
          signature: 'Future<Uint8List?> createWebArchiveData()',
          description: 'Creates a web archive of the current page.',
          supportedPlatforms: applePlatforms,
          category: 'iOS/macOS',
        ),
        ApiMethodDefinition(
          name: 'terminateWebProcess',
          signature: 'Future<void> terminateWebProcess()',
          description: 'Terminates the web content process.',
          supportedPlatforms: applePlatforms,
          category: 'iOS/macOS',
        ),

        // Windows-specific methods
        ApiMethodDefinition(
          name: 'openDevTools',
          signature: 'Future<void> openDevTools()',
          description: 'Opens the browser DevTools.',
          supportedPlatforms: {SupportedPlatform.windows},
          category: 'Windows',
        ),
        ApiMethodDefinition(
          name: 'callDevToolsProtocolMethod',
          signature:
              'Future<dynamic> callDevToolsProtocolMethod({required String methodName, ...})',
          description: 'Calls a DevTools Protocol method.',
          supportedPlatforms: {SupportedPlatform.windows},
          category: 'Windows',
        ),
        ApiMethodDefinition(
          name: 'addDevToolsProtocolEventListener',
          signature:
              'Future<void> addDevToolsProtocolEventListener({required String eventName, ...})',
          description: 'Adds a DevTools Protocol event listener.',
          supportedPlatforms: {SupportedPlatform.windows},
          category: 'Windows',
        ),
        ApiMethodDefinition(
          name: 'removeDevToolsProtocolEventListener',
          signature:
              'Future<void> removeDevToolsProtocolEventListener({required String eventName})',
          description: 'Removes a DevTools Protocol event listener.',
          supportedPlatforms: {SupportedPlatform.windows},
          category: 'Windows',
        ),

        // Web-specific methods
        ApiMethodDefinition(
          name: 'getIFrameId',
          signature: 'Future<String?> getIFrameId()',
          description: 'Gets the iframe ID on web platform.',
          supportedPlatforms: {SupportedPlatform.web},
          category: 'Web',
        ),

        // Other methods
        ApiMethodDefinition(
          name: 'getViewId',
          signature: 'int getViewId()',
          description: 'Gets the view ID of the WebView.',
          supportedPlatforms: allPlatforms,
          category: 'Other',
        ),
        ApiMethodDefinition(
          name: 'dispose',
          signature: 'void dispose()',
          description: 'Disposes the controller and releases resources.',
          supportedPlatforms: allPlatforms,
          category: 'Other',
        ),

        // Static methods
        ApiMethodDefinition(
          name: 'getDefaultUserAgent',
          signature: 'static Future<String> getDefaultUserAgent()',
          description: 'Gets the default User-Agent string.',
          supportedPlatforms: {
            ...mobilePlatforms,
            SupportedPlatform.macos,
            SupportedPlatform.windows,
          },
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'clearClientCertPreferences',
          signature: 'static Future<void> clearClientCertPreferences()',
          description: 'Clears the client certificate preferences.',
          supportedPlatforms: {SupportedPlatform.android},
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'getSafeBrowsingPrivacyPolicyUrl',
          signature: 'static Future<WebUri?> getSafeBrowsingPrivacyPolicyUrl()',
          description: 'Gets the Safe Browsing privacy policy URL.',
          supportedPlatforms: {SupportedPlatform.android},
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'setSafeBrowsingAllowlist',
          signature:
              'static Future<bool> setSafeBrowsingAllowlist({required List<String> hosts})',
          description: 'Sets the Safe Browsing allowlist.',
          supportedPlatforms: {SupportedPlatform.android},
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'getCurrentWebViewPackage',
          signature:
              'static Future<WebViewPackageInfo?> getCurrentWebViewPackage()',
          description: 'Gets the current WebView package info.',
          supportedPlatforms: {SupportedPlatform.android},
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'setWebContentsDebuggingEnabled',
          signature:
              'static Future<void> setWebContentsDebuggingEnabled(bool debuggingEnabled)',
          description: 'Enables or disables debugging.',
          supportedPlatforms: {SupportedPlatform.android},
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'getVariationsHeader',
          signature: 'static Future<String?> getVariationsHeader()',
          description: 'Gets the variations header.',
          supportedPlatforms: {SupportedPlatform.android},
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'isMultiProcessEnabled',
          signature: 'static Future<bool> isMultiProcessEnabled()',
          description: 'Checks if multi-process is enabled.',
          supportedPlatforms: {SupportedPlatform.android},
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'disableWebView',
          signature: 'static Future<void> disableWebView()',
          description: 'Disables the WebView.',
          supportedPlatforms: {SupportedPlatform.android},
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'handlesURLScheme',
          signature: 'static Future<bool> handlesURLScheme(String urlScheme)',
          description: 'Checks if the WebView handles a URL scheme.',
          supportedPlatforms: applePlatforms,
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'disposeKeepAlive',
          signature:
              'static Future<void> disposeKeepAlive(InAppWebViewKeepAlive keepAlive)',
          description: 'Disposes a keep-alive instance.',
          supportedPlatforms: nativePlatforms,
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'clearAllCache',
          signature:
              'static Future<void> clearAllCache({bool includeDiskFiles = true})',
          description: 'Clears all WebView caches.',
          supportedPlatforms: nativePlatforms,
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'enableSlowWholeDocumentDraw',
          signature: 'static Future<void> enableSlowWholeDocumentDraw()',
          description: 'Enables slow whole document draw.',
          supportedPlatforms: {SupportedPlatform.android},
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'setJavaScriptBridgeName',
          signature:
              'static Future<void> setJavaScriptBridgeName(String bridgeName)',
          description: 'Sets the JavaScript bridge name.',
          supportedPlatforms: allPlatforms,
          isStatic: true,
          category: 'Static',
        ),
        ApiMethodDefinition(
          name: 'getJavaScriptBridgeName',
          signature: 'static Future<String> getJavaScriptBridgeName()',
          description: 'Gets the JavaScript bridge name.',
          supportedPlatforms: allPlatforms,
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
          supportedPlatforms: allPlatforms,
          category: 'Core',
        ),
        ApiEventDefinition(
          name: 'onLoadStart',
          description: 'Called when a page starts loading.',
          supportedPlatforms: allPlatforms,
          category: 'Core',
        ),
        ApiEventDefinition(
          name: 'onLoadStop',
          description: 'Called when a page finishes loading.',
          supportedPlatforms: allPlatforms,
          category: 'Core',
        ),
        ApiEventDefinition(
          name: 'onLoadError',
          description: 'Called when a page fails to load.',
          supportedPlatforms: allPlatforms,
          category: 'Core',
        ),
        ApiEventDefinition(
          name: 'onLoadHttpError',
          description: 'Called when an HTTP error is received.',
          supportedPlatforms: allPlatforms,
          category: 'Core',
        ),
        ApiEventDefinition(
          name: 'onProgressChanged',
          description: 'Called when the loading progress changes.',
          supportedPlatforms: allPlatforms,
          category: 'Core',
        ),
        ApiEventDefinition(
          name: 'onConsoleMessage',
          description: 'Called when a console message is received.',
          supportedPlatforms: allPlatforms,
          category: 'Core',
        ),
        ApiEventDefinition(
          name: 'onTitleChanged',
          description: 'Called when the page title changes.',
          supportedPlatforms: allPlatforms,
          category: 'Core',
        ),
        ApiEventDefinition(
          name: 'onUpdateVisitedHistory',
          description: 'Called when the visited history is updated.',
          supportedPlatforms: allPlatforms,
          category: 'Core',
        ),

        // Navigation events
        ApiEventDefinition(
          name: 'shouldOverrideUrlLoading',
          description: 'Called to handle URL navigation requests.',
          supportedPlatforms: allPlatforms,
          category: 'Navigation',
        ),
        ApiEventDefinition(
          name: 'onNavigationResponse',
          description: 'Called when receiving a navigation response.',
          supportedPlatforms: applePlatforms,
          category: 'Navigation',
        ),
        ApiEventDefinition(
          name: 'shouldAllowDeprecatedTLS',
          description: 'Called to check if deprecated TLS should be allowed.',
          supportedPlatforms: applePlatforms,
          category: 'Navigation',
        ),

        // Window events
        ApiEventDefinition(
          name: 'onCreateWindow',
          description: 'Called when a new window is requested.',
          supportedPlatforms: allPlatforms,
          category: 'Window',
        ),
        ApiEventDefinition(
          name: 'onCloseWindow',
          description: 'Called when a window should be closed.',
          supportedPlatforms: allPlatforms,
          category: 'Window',
        ),
        ApiEventDefinition(
          name: 'onWindowFocus',
          description: 'Called when the window receives focus.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Window',
        ),
        ApiEventDefinition(
          name: 'onWindowBlur',
          description: 'Called when the window loses focus.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Window',
        ),

        // JS Dialog events
        ApiEventDefinition(
          name: 'onJsAlert',
          description: 'Called when a JavaScript alert is shown.',
          supportedPlatforms: nativePlatforms,
          category: 'JS Dialogs',
        ),
        ApiEventDefinition(
          name: 'onJsConfirm',
          description: 'Called when a JavaScript confirm is shown.',
          supportedPlatforms: nativePlatforms,
          category: 'JS Dialogs',
        ),
        ApiEventDefinition(
          name: 'onJsPrompt',
          description: 'Called when a JavaScript prompt is shown.',
          supportedPlatforms: nativePlatforms,
          category: 'JS Dialogs',
        ),
        ApiEventDefinition(
          name: 'onJsBeforeUnload',
          description: 'Called before the page is unloaded.',
          supportedPlatforms: {
            SupportedPlatform.android,
            SupportedPlatform.windows,
          },
          category: 'JS Dialogs',
        ),

        // Authentication events
        ApiEventDefinition(
          name: 'onReceivedHttpAuthRequest',
          description: 'Called for HTTP authentication requests.',
          supportedPlatforms: nativePlatforms,
          category: 'Authentication',
        ),
        ApiEventDefinition(
          name: 'onReceivedServerTrustAuthRequest',
          description: 'Called for server trust authentication.',
          supportedPlatforms: nativePlatforms,
          category: 'Authentication',
        ),
        ApiEventDefinition(
          name: 'onReceivedClientCertRequest',
          description: 'Called when a client certificate is requested.',
          supportedPlatforms: {SupportedPlatform.android, ...applePlatforms},
          category: 'Authentication',
        ),

        // Network events
        ApiEventDefinition(
          name: 'shouldInterceptRequest',
          description: 'Called to intercept resource requests.',
          supportedPlatforms: {
            SupportedPlatform.android,
            SupportedPlatform.macos,
          },
          category: 'Network',
        ),
        ApiEventDefinition(
          name: 'onLoadResource',
          description: 'Called when a resource is loaded.',
          supportedPlatforms: allPlatforms,
          category: 'Network',
        ),
        ApiEventDefinition(
          name: 'onLoadResourceWithCustomScheme',
          description: 'Called when loading a custom scheme resource.',
          supportedPlatforms: nativePlatforms,
          category: 'Network',
        ),
        ApiEventDefinition(
          name: 'onReceivedError',
          description: 'Called when a resource load error occurs.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Network',
        ),
        ApiEventDefinition(
          name: 'onReceivedHttpError',
          description: 'Called when an HTTP error occurs.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Network',
        ),

        // Download events
        ApiEventDefinition(
          name: 'onDownloadStartRequest',
          description: 'Called when a download is requested.',
          supportedPlatforms: nativePlatforms,
          category: 'Download',
        ),
        ApiEventDefinition(
          name: 'onDownloadStarting',
          description: 'Called when a download is starting.',
          supportedPlatforms: {SupportedPlatform.windows},
          category: 'Download',
        ),

        // Scroll events
        ApiEventDefinition(
          name: 'onScrollChanged',
          description: 'Called when the scroll position changes.',
          supportedPlatforms: nativePlatforms,
          category: 'Scroll',
        ),
        ApiEventDefinition(
          name: 'onOverScrolled',
          description: 'Called when the WebView is over-scrolled.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Scroll',
        ),

        // Zoom events
        ApiEventDefinition(
          name: 'onZoomScaleChanged',
          description: 'Called when the zoom scale changes.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.windows},
          category: 'Zoom',
        ),

        // Print events
        ApiEventDefinition(
          name: 'onPrintRequest',
          description: 'Called when a print request is made.',
          supportedPlatforms: nativePlatforms,
          category: 'Print',
        ),

        // Fullscreen events
        ApiEventDefinition(
          name: 'onEnterFullscreen',
          description: 'Called when entering fullscreen mode.',
          supportedPlatforms: nativePlatforms,
          category: 'Fullscreen',
        ),
        ApiEventDefinition(
          name: 'onExitFullscreen',
          description: 'Called when exiting fullscreen mode.',
          supportedPlatforms: nativePlatforms,
          category: 'Fullscreen',
        ),

        // Permission events
        ApiEventDefinition(
          name: 'onPermissionRequest',
          description: 'Called when a permission is requested.',
          supportedPlatforms: {
            ...mobilePlatforms,
            SupportedPlatform.macos,
            SupportedPlatform.windows,
          },
          category: 'Permission',
        ),
        ApiEventDefinition(
          name: 'onPermissionRequestCanceled',
          description: 'Called when a permission request is canceled.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Permission',
        ),

        // Touch/Gesture events
        ApiEventDefinition(
          name: 'onLongPressHitTestResult',
          description: 'Called on a long press.',
          supportedPlatforms: {
            SupportedPlatform.android,
            SupportedPlatform.linux,
          },
          category: 'Touch',
        ),
        ApiEventDefinition(
          name: 'onGeolocationPermissionsShowPrompt',
          description: 'Called when requesting geolocation permission.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Permission',
        ),
        ApiEventDefinition(
          name: 'onGeolocationPermissionsHidePrompt',
          description: 'Called when hiding geolocation permission prompt.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Permission',
        ),

        // Render Process events
        ApiEventDefinition(
          name: 'onRenderProcessGone',
          description: 'Called when the render process terminates.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Render Process',
        ),
        ApiEventDefinition(
          name: 'onRenderProcessResponsive',
          description: 'Called when the render process becomes responsive.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Render Process',
        ),
        ApiEventDefinition(
          name: 'onRenderProcessUnresponsive',
          description: 'Called when the render process becomes unresponsive.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Render Process',
        ),
        ApiEventDefinition(
          name: 'onWebContentProcessDidTerminate',
          description: 'Called when the web content process terminates.',
          supportedPlatforms: applePlatforms,
          category: 'Render Process',
        ),

        // Form events
        ApiEventDefinition(
          name: 'onFormResubmission',
          description: 'Called when a form is resubmitted.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Form',
        ),

        // Icon events
        ApiEventDefinition(
          name: 'onReceivedIcon',
          description: 'Called when a favicon is received.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Icon',
        ),
        ApiEventDefinition(
          name: 'onReceivedTouchIconUrl',
          description: 'Called when a touch icon URL is received.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Icon',
        ),

        // Safe Browsing events
        ApiEventDefinition(
          name: 'onSafeBrowsingHit',
          description: 'Called when Safe Browsing detects a threat.',
          supportedPlatforms: {SupportedPlatform.android},
          category: 'Safe Browsing',
        ),

        // iOS/macOS events
        ApiEventDefinition(
          name: 'onDidReceiveServerRedirectForProvisionalNavigation',
          description: 'Called when a server redirect is received.',
          supportedPlatforms: applePlatforms,
          category: 'iOS/macOS',
        ),
        ApiEventDefinition(
          name: 'onCameraCaptureStateChanged',
          description: 'Called when camera capture state changes.',
          supportedPlatforms: applePlatforms,
          category: 'iOS/macOS',
        ),
        ApiEventDefinition(
          name: 'onMicrophoneCaptureStateChanged',
          description: 'Called when microphone capture state changes.',
          supportedPlatforms: applePlatforms,
          category: 'iOS/macOS',
        ),

        // Windows events
        ApiEventDefinition(
          name: 'onProcessFailed',
          description: 'Called when a process failure occurs.',
          supportedPlatforms: {SupportedPlatform.windows},
          category: 'Windows',
        ),
        ApiEventDefinition(
          name: 'onNewWindowRequested',
          description: 'Called when a new window is requested.',
          supportedPlatforms: {SupportedPlatform.windows},
          category: 'Windows',
        ),

        // Other events
        ApiEventDefinition(
          name: 'onPageCommitVisible',
          description: 'Called when the page becomes visible.',
          supportedPlatforms: {...nativePlatforms},
          category: 'Other',
        ),
        ApiEventDefinition(
          name: 'onContentSizeChanged',
          description: 'Called when the content size changes.',
          supportedPlatforms: applePlatforms,
          category: 'Other',
        ),
        ApiEventDefinition(
          name: 'onAjaxReadyStateChange',
          description: 'Called when an AJAX ready state changes.',
          supportedPlatforms: allPlatforms,
          category: 'Other',
        ),
        ApiEventDefinition(
          name: 'onAjaxProgress',
          description: 'Called for AJAX progress updates.',
          supportedPlatforms: allPlatforms,
          category: 'Other',
        ),
        ApiEventDefinition(
          name: 'shouldInterceptAjaxRequest',
          description: 'Called to intercept AJAX requests.',
          supportedPlatforms: allPlatforms,
          category: 'Other',
        ),
        ApiEventDefinition(
          name: 'onFetchPost',
          description: 'Called when a fetch POST request is made.',
          supportedPlatforms: allPlatforms,
          category: 'Other',
        ),
        ApiEventDefinition(
          name: 'shouldInterceptFetchRequest',
          description: 'Called to intercept fetch requests.',
          supportedPlatforms: allPlatforms,
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
          supportedPlatforms: allPlatforms,
        ),
        ApiMethodDefinition(
          name: 'isRunning',
          signature: 'Future<bool> isRunning()',
          description: 'Checks if the WebView is running.',
          supportedPlatforms: allPlatforms,
        ),
        ApiMethodDefinition(
          name: 'setSize',
          signature: 'Future<void> setSize(Size size)',
          description: 'Sets the WebView size.',
          supportedPlatforms: allPlatforms,
        ),
        ApiMethodDefinition(
          name: 'getSize',
          signature: 'Future<Size?> getSize()',
          description: 'Gets the WebView size.',
          supportedPlatforms: allPlatforms,
        ),
        ApiMethodDefinition(
          name: 'dispose',
          signature: 'Future<void> dispose()',
          description: 'Disposes the headless WebView.',
          supportedPlatforms: allPlatforms,
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
          supportedPlatforms: nativePlatforms,
        ),
        ApiMethodDefinition(
          name: 'openFile',
          signature:
              'Future<void> openFile({required String assetFilePath, ...})',
          description: 'Opens a file from assets.',
          supportedPlatforms: nativePlatforms,
        ),
        ApiMethodDefinition(
          name: 'openData',
          signature: 'Future<void> openData({required String data, ...})',
          description: 'Opens HTML data.',
          supportedPlatforms: nativePlatforms,
        ),
        ApiMethodDefinition(
          name: 'openWithSystemBrowser',
          signature:
              'static Future<void> openWithSystemBrowser({required WebUri url})',
          description: 'Opens a URL in the system browser.',
          supportedPlatforms: nativePlatforms,
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'show',
          signature: 'Future<void> show()',
          description: 'Shows the browser.',
          supportedPlatforms: nativePlatforms,
        ),
        ApiMethodDefinition(
          name: 'hide',
          signature: 'Future<void> hide()',
          description: 'Hides the browser.',
          supportedPlatforms: nativePlatforms,
        ),
        ApiMethodDefinition(
          name: 'close',
          signature: 'Future<void> close()',
          description: 'Closes the browser.',
          supportedPlatforms: nativePlatforms,
        ),
        ApiMethodDefinition(
          name: 'isHidden',
          signature: 'Future<bool> isHidden()',
          description: 'Checks if the browser is hidden.',
          supportedPlatforms: nativePlatforms,
        ),
        ApiMethodDefinition(
          name: 'setSettings',
          signature:
              'Future<void> setSettings({required InAppBrowserClassSettings settings})',
          description: 'Sets the browser settings.',
          supportedPlatforms: nativePlatforms,
        ),
        ApiMethodDefinition(
          name: 'getSettings',
          signature: 'Future<InAppBrowserClassSettings?> getSettings()',
          description: 'Gets the browser settings.',
          supportedPlatforms: nativePlatforms,
        ),
        ApiMethodDefinition(
          name: 'isOpened',
          signature: 'bool isOpened()',
          description: 'Checks if the browser is opened.',
          supportedPlatforms: nativePlatforms,
        ),
      ],
      events: [
        ApiEventDefinition(
          name: 'onBrowserCreated',
          description: 'Called when the browser is created.',
          supportedPlatforms: nativePlatforms,
        ),
        ApiEventDefinition(
          name: 'onExit',
          description: 'Called when the browser exits.',
          supportedPlatforms: nativePlatforms,
        ),
        ApiEventDefinition(
          name: 'onMainWindowCreated',
          description: 'Called when the main window is created.',
          supportedPlatforms: {SupportedPlatform.windows},
        ),
        ApiEventDefinition(
          name: 'onMainWindowWillClose',
          description: 'Called when the main window will close.',
          supportedPlatforms: {SupportedPlatform.windows},
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
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
        ),
        ApiMethodDefinition(
          name: 'launchUrl',
          signature: 'Future<void> launchUrl({required WebUri url, ...})',
          description: 'Launches a URL.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'mayLaunchUrl',
          signature: 'Future<bool> mayLaunchUrl({WebUri? url, ...})',
          description: 'Hints to the browser to start loading a URL.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'validateRelationship',
          signature:
              'Future<bool> validateRelationship({required CustomTabsRelationType relation, ...})',
          description: 'Validates a relationship.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'close',
          signature: 'Future<void> close()',
          description: 'Closes the browser.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
        ),
        ApiMethodDefinition(
          name: 'isOpened',
          signature: 'bool isOpened()',
          description: 'Checks if the browser is opened.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
        ),
        ApiMethodDefinition(
          name: 'isAvailable',
          signature: 'static Future<bool> isAvailable()',
          description: 'Checks if the browser is available.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'getMaxToolbarItems',
          signature: 'static Future<int> getMaxToolbarItems()',
          description: 'Gets the maximum toolbar items.',
          supportedPlatforms: {SupportedPlatform.android},
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'getPackageName',
          signature:
              'static Future<String?> getPackageName({List<String>? packages, ...})',
          description: 'Gets the package name for Custom Tabs.',
          supportedPlatforms: {SupportedPlatform.android},
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'clearWebsiteData',
          signature: 'static Future<void> clearWebsiteData()',
          description: 'Clears website data.',
          supportedPlatforms: {SupportedPlatform.android},
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'prewarmConnections',
          signature:
              'static Future<PrewarmingToken?> prewarmConnections({required List<WebUri> urls})',
          description: 'Prewarms connections.',
          supportedPlatforms: {SupportedPlatform.ios},
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'invalidatePrewarmingToken',
          signature:
              'static Future<void> invalidatePrewarmingToken({required PrewarmingToken prewarmingToken})',
          description: 'Invalidates a prewarming token.',
          supportedPlatforms: {SupportedPlatform.ios},
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'setActionButton',
          signature:
              'Future<void> setActionButton(ChromeSafariBrowserActionButton actionButton)',
          description: 'Sets an action button.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'updateActionButton',
          signature:
              'Future<void> updateActionButton({required Uint8List icon, required String description})',
          description: 'Updates the action button.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'setSecondaryToolbar',
          signature:
              'Future<void> setSecondaryToolbar(ChromeSafariBrowserSecondaryToolbar secondaryToolbar)',
          description: 'Sets a secondary toolbar.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'updateSecondaryToolbar',
          signature:
              'Future<void> updateSecondaryToolbar(ChromeSafariBrowserSecondaryToolbar secondaryToolbar)',
          description: 'Updates the secondary toolbar.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'requestPostMessageChannel',
          signature:
              'Future<bool> requestPostMessageChannel({required WebUri sourceOrigin, ...})',
          description: 'Requests a post message channel.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'postMessage',
          signature:
              'Future<CustomTabsPostMessageResultType> postMessage({required String message})',
          description: 'Posts a message.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'isEngagementSignalsApiAvailable',
          signature: 'Future<bool> isEngagementSignalsApiAvailable()',
          description: 'Checks if engagement signals API is available.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
      ],
      events: [
        ApiEventDefinition(
          name: 'onOpened',
          description: 'Called when the browser is opened.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
        ),
        ApiEventDefinition(
          name: 'onClosed',
          description: 'Called when the browser is closed.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
        ),
        ApiEventDefinition(
          name: 'onCompletedInitialLoad',
          description: 'Called when the initial load completes.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
        ),
        ApiEventDefinition(
          name: 'onInitialLoadDidRedirect',
          description: 'Called when the initial load redirects.',
          supportedPlatforms: {SupportedPlatform.ios, SupportedPlatform.macos},
        ),
        ApiEventDefinition(
          name: 'onWillOpenInBrowser',
          description: 'Called when opening in the browser.',
          supportedPlatforms: {SupportedPlatform.ios, SupportedPlatform.macos},
        ),
        ApiEventDefinition(
          name: 'onNavigationEvent',
          description: 'Called on navigation events.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiEventDefinition(
          name: 'onServiceConnected',
          description: 'Called when the service connects.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiEventDefinition(
          name: 'onRelationshipValidationResult',
          description: 'Called with relationship validation results.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiEventDefinition(
          name: 'onMessageChannelReady',
          description: 'Called when the message channel is ready.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiEventDefinition(
          name: 'onPostMessage',
          description: 'Called when a post message is received.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiEventDefinition(
          name: 'onVerticalScrollEvent',
          description: 'Called on vertical scroll events.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiEventDefinition(
          name: 'onGreatestScrollPercentageIncreased',
          description: 'Called when the greatest scroll percentage increases.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiEventDefinition(
          name: 'onSessionEnded',
          description: 'Called when the session ends.',
          supportedPlatforms: {SupportedPlatform.android},
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
          supportedPlatforms: allPlatforms,
        ),
        ApiMethodDefinition(
          name: 'getCookies',
          signature: 'Future<List<Cookie>> getCookies({required WebUri url})',
          description: 'Gets all cookies for a URL.',
          supportedPlatforms: allPlatforms,
        ),
        ApiMethodDefinition(
          name: 'getCookie',
          signature:
              'Future<Cookie?> getCookie({required WebUri url, required String name})',
          description: 'Gets a specific cookie.',
          supportedPlatforms: allPlatforms,
        ),
        ApiMethodDefinition(
          name: 'deleteCookie',
          signature:
              'Future<void> deleteCookie({required WebUri url, required String name, ...})',
          description: 'Deletes a cookie.',
          supportedPlatforms: allPlatforms,
        ),
        ApiMethodDefinition(
          name: 'deleteCookies',
          signature:
              'Future<void> deleteCookies({required WebUri url, String? domain, String? path})',
          description: 'Deletes cookies for a URL.',
          supportedPlatforms: allPlatforms,
        ),
        ApiMethodDefinition(
          name: 'deleteAllCookies',
          signature: 'Future<void> deleteAllCookies()',
          description: 'Deletes all cookies.',
          supportedPlatforms: allPlatforms,
        ),
        ApiMethodDefinition(
          name: 'removeSessionCookies',
          signature: 'Future<bool> removeSessionCookies()',
          description: 'Removes all session cookies.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'flush',
          signature: 'Future<void> flush()',
          description: 'Flushes cookies to persistent storage.',
          supportedPlatforms: {...nativePlatforms},
        ),
        ApiMethodDefinition(
          name: 'getAllCookies',
          signature: 'Future<List<Cookie>> getAllCookies()',
          description: 'Gets all cookies.',
          supportedPlatforms: {SupportedPlatform.windows},
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
          supportedPlatforms: allPlatforms,
        ),
        ApiMethodDefinition(
          name: 'setItem',
          signature:
              'Future<void> setItem({required String key, required dynamic value})',
          description: 'Sets an item.',
          supportedPlatforms: allPlatforms,
        ),
        ApiMethodDefinition(
          name: 'getItem',
          signature: 'Future<dynamic> getItem({required String key})',
          description: 'Gets an item.',
          supportedPlatforms: allPlatforms,
        ),
        ApiMethodDefinition(
          name: 'removeItem',
          signature: 'Future<void> removeItem({required String key})',
          description: 'Removes an item.',
          supportedPlatforms: allPlatforms,
        ),
        ApiMethodDefinition(
          name: 'getItems',
          signature: 'Future<List<WebStorageItem>> getItems()',
          description: 'Gets all items.',
          supportedPlatforms: allPlatforms,
        ),
        ApiMethodDefinition(
          name: 'clear',
          signature: 'Future<void> clear()',
          description: 'Clears all items.',
          supportedPlatforms: allPlatforms,
        ),
        ApiMethodDefinition(
          name: 'key',
          signature: 'Future<String> key({required int index})',
          description: 'Gets the key at an index.',
          supportedPlatforms: allPlatforms,
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
          supportedPlatforms: {...nativePlatforms},
        ),
        ApiMethodDefinition(
          name: 'findNext',
          signature: 'Future<void> findNext({bool forward = true})',
          description: 'Finds the next occurrence.',
          supportedPlatforms: {...nativePlatforms},
        ),
        ApiMethodDefinition(
          name: 'clearMatches',
          signature: 'Future<void> clearMatches()',
          description: 'Clears all matches.',
          supportedPlatforms: {...nativePlatforms},
        ),
        ApiMethodDefinition(
          name: 'setSearchText',
          signature: 'Future<void> setSearchText(String? searchText)',
          description: 'Sets the search text.',
          supportedPlatforms: applePlatforms,
        ),
        ApiMethodDefinition(
          name: 'getSearchText',
          signature: 'Future<String?> getSearchText()',
          description: 'Gets the search text.',
          supportedPlatforms: applePlatforms,
        ),
        ApiMethodDefinition(
          name: 'isFindNavigatorVisible',
          signature: 'Future<bool?> isFindNavigatorVisible()',
          description: 'Checks if the find navigator is visible.',
          supportedPlatforms: applePlatforms,
        ),
        ApiMethodDefinition(
          name: 'presentFindNavigator',
          signature: 'Future<void> presentFindNavigator()',
          description: 'Presents the find navigator.',
          supportedPlatforms: applePlatforms,
        ),
        ApiMethodDefinition(
          name: 'dismissFindNavigator',
          signature: 'Future<void> dismissFindNavigator()',
          description: 'Dismisses the find navigator.',
          supportedPlatforms: applePlatforms,
        ),
        ApiMethodDefinition(
          name: 'getActiveFindSession',
          signature: 'Future<FindSession?> getActiveFindSession()',
          description: 'Gets the active find session.',
          supportedPlatforms: applePlatforms,
        ),
        ApiMethodDefinition(
          name: 'dispose',
          signature: 'void dispose()',
          description: 'Disposes the controller.',
          supportedPlatforms: {...nativePlatforms},
        ),
      ],
      events: [
        ApiEventDefinition(
          name: 'onFindResultReceived',
          description: 'Called when find results are received.',
          supportedPlatforms: {...nativePlatforms},
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
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
        ),
        ApiMethodDefinition(
          name: 'isEnabled',
          signature: 'Future<bool> isEnabled()',
          description: 'Checks if pull-to-refresh is enabled.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
        ),
        ApiMethodDefinition(
          name: 'beginRefreshing',
          signature: 'Future<void> beginRefreshing()',
          description: 'Starts the refresh animation.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
        ),
        ApiMethodDefinition(
          name: 'endRefreshing',
          signature: 'Future<void> endRefreshing()',
          description: 'Stops the refresh animation.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
        ),
        ApiMethodDefinition(
          name: 'isRefreshing',
          signature: 'Future<bool> isRefreshing()',
          description: 'Checks if currently refreshing.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
        ),
        ApiMethodDefinition(
          name: 'setColor',
          signature: 'Future<void> setColor(Color color)',
          description: 'Sets the indicator color.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
        ),
        ApiMethodDefinition(
          name: 'setBackgroundColor',
          signature: 'Future<void> setBackgroundColor(Color color)',
          description: 'Sets the background color.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
        ),
        ApiMethodDefinition(
          name: 'setDistanceToTrigger',
          signature:
              'Future<void> setDistanceToTrigger(double distanceToTrigger)',
          description: 'Sets the distance to trigger refresh.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'setSlingshotDistance',
          signature:
              'Future<void> setSlingshotDistance(double slingshotDistance)',
          description: 'Sets the slingshot distance.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'getDefaultSlingshotDistance',
          signature: 'Future<double> getDefaultSlingshotDistance()',
          description: 'Gets the default slingshot distance.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'setIndicatorSize',
          signature: 'Future<void> setIndicatorSize(PullToRefreshSize size)',
          description: 'Sets the indicator size.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'dispose',
          signature: 'void dispose()',
          description: 'Disposes the controller.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
        ),
      ],
      events: [
        ApiEventDefinition(
          name: 'onRefresh',
          description: 'Called when a refresh is triggered.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
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
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
        ),
        ApiMethodDefinition(
          name: 'restart',
          signature: 'Future<void> restart()',
          description: 'Restarts the print job.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'dismiss',
          signature: 'Future<void> dismiss({bool animated = true})',
          description: 'Dismisses the print interface.',
          supportedPlatforms: applePlatforms,
        ),
        ApiMethodDefinition(
          name: 'getInfo',
          signature: 'Future<PrintJobInfo?> getInfo()',
          description: 'Gets the print job info.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
        ),
      ],
      events: [
        ApiEventDefinition(
          name: 'onComplete',
          description: 'Called when the print job completes.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
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
          supportedPlatforms: applePlatforms,
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'canStart',
          signature: 'Future<bool> canStart()',
          description: 'Checks if the session can start.',
          supportedPlatforms: applePlatforms,
        ),
        ApiMethodDefinition(
          name: 'start',
          signature: 'Future<void> start()',
          description: 'Starts the authentication session.',
          supportedPlatforms: applePlatforms,
        ),
        ApiMethodDefinition(
          name: 'cancel',
          signature: 'Future<void> cancel()',
          description: 'Cancels the session.',
          supportedPlatforms: applePlatforms,
        ),
        ApiMethodDefinition(
          name: 'dispose',
          signature: 'Future<void> dispose()',
          description: 'Disposes the session.',
          supportedPlatforms: applePlatforms,
        ),
        ApiMethodDefinition(
          name: 'isAvailable',
          signature: 'static Future<bool> isAvailable()',
          description: 'Checks if web authentication is available.',
          supportedPlatforms: applePlatforms,
          isStatic: true,
        ),
      ],
      events: [
        ApiEventDefinition(
          name: 'onComplete',
          description: 'Called when authentication completes.',
          supportedPlatforms: applePlatforms,
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
          supportedPlatforms: {SupportedPlatform.android},
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'setServiceWorkerClient',
          signature:
              'Future<void> setServiceWorkerClient(ServiceWorkerClient? value)',
          description: 'Sets the service worker client.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'getServiceWorkerClient',
          signature: 'Future<ServiceWorkerClient?> getServiceWorkerClient()',
          description: 'Gets the service worker client.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'getAllowContentAccess',
          signature: 'Future<bool> getAllowContentAccess()',
          description: 'Gets allow content access setting.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'setAllowContentAccess',
          signature: 'Future<void> setAllowContentAccess(bool allow)',
          description: 'Sets allow content access setting.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'getAllowFileAccess',
          signature: 'Future<bool> getAllowFileAccess()',
          description: 'Gets allow file access setting.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'setAllowFileAccess',
          signature: 'Future<void> setAllowFileAccess(bool allow)',
          description: 'Sets allow file access setting.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'getBlockNetworkLoads',
          signature: 'Future<bool> getBlockNetworkLoads()',
          description: 'Gets block network loads setting.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'setBlockNetworkLoads',
          signature: 'Future<void> setBlockNetworkLoads(bool block)',
          description: 'Sets block network loads setting.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
      ],
      events: [
        ApiEventDefinition(
          name: 'shouldInterceptRequest',
          description: 'Called to intercept service worker requests.',
          supportedPlatforms: {SupportedPlatform.android},
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
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'clearProxyOverride',
          signature: 'Future<void> clearProxyOverride()',
          description: 'Clears the proxy override.',
          supportedPlatforms: {SupportedPlatform.android},
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
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'stop',
          signature: 'Future<bool> stop({String? filePath})',
          description: 'Stops tracing.',
          supportedPlatforms: {SupportedPlatform.android},
        ),
        ApiMethodDefinition(
          name: 'isTracing',
          signature: 'Future<bool> isTracing()',
          description: 'Checks if tracing is active.',
          supportedPlatforms: {SupportedPlatform.android},
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
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
        ),
        ApiMethodDefinition(
          name: 'getHttpAuthCredentials',
          signature:
              'Future<List<URLCredential>> getHttpAuthCredentials({...})',
          description: 'Gets credentials for a protection space.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
        ),
        ApiMethodDefinition(
          name: 'setHttpAuthCredential',
          signature: 'Future<void> setHttpAuthCredential({...})',
          description: 'Sets a credential.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
        ),
        ApiMethodDefinition(
          name: 'removeHttpAuthCredential',
          signature: 'Future<void> removeHttpAuthCredential({...})',
          description: 'Removes a credential.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
        ),
        ApiMethodDefinition(
          name: 'removeHttpAuthCredentials',
          signature: 'Future<void> removeHttpAuthCredentials({...})',
          description: 'Removes all credentials for a protection space.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
        ),
        ApiMethodDefinition(
          name: 'clearAllAuthCredentials',
          signature: 'Future<void> clearAllAuthCredentials()',
          description: 'Clears all credentials.',
          supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
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
          supportedPlatforms: {SupportedPlatform.windows},
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'getAvailableVersion',
          signature:
              'static Future<String?> getAvailableVersion({String? browserExecutableFolder})',
          description: 'Gets the available WebView2 version.',
          supportedPlatforms: {SupportedPlatform.windows},
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'getProcessInfos',
          signature: 'Future<List<BrowserProcessInfo>> getProcessInfos()',
          description: 'Gets running process information.',
          supportedPlatforms: {SupportedPlatform.windows},
        ),
        ApiMethodDefinition(
          name: 'compareBrowserVersions',
          signature: 'static Future<int> compareBrowserVersions({...})',
          description: 'Compares browser versions.',
          supportedPlatforms: {SupportedPlatform.windows},
          isStatic: true,
        ),
        ApiMethodDefinition(
          name: 'dispose',
          signature: 'Future<void> dispose()',
          description: 'Disposes the environment.',
          supportedPlatforms: {SupportedPlatform.windows},
        ),
      ],
      events: [
        ApiEventDefinition(
          name: 'onBrowserProcessExited',
          description: 'Called when the browser process exits.',
          supportedPlatforms: {SupportedPlatform.windows},
        ),
        ApiEventDefinition(
          name: 'onProcessInfosChanged',
          description: 'Called when process info changes.',
          supportedPlatforms: {SupportedPlatform.windows},
        ),
        ApiEventDefinition(
          name: 'onNewBrowserVersionAvailable',
          description: 'Called when a new browser version is available.',
          supportedPlatforms: {SupportedPlatform.windows},
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
          supportedPlatforms: {SupportedPlatform.android},
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
          supportedPlatforms: nativePlatforms,
        ),
      ],
    );
  }
}
