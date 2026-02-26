import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';
import 'package:flutter_inappwebview_example/widgets/common/support_badge.dart';
import 'package:flutter_inappwebview_example/widgets/common/parameter_dialog.dart';
import 'package:flutter_inappwebview_example/widgets/common/method_result_history.dart';

/// Enum representing available static method types
enum StaticMethodType {
  // WebView controller methods
  getDefaultUserAgent,
  clearClientCertPreferences,
  getSafeBrowsingPrivacyPolicyUrl,
  setSafeBrowsingAllowlist,
  getCurrentWebViewPackage,
  setWebContentsDebuggingEnabled,
  getVariationsHeader,
  isMultiProcessEnabled,
  disableWebView,
  handlesURLScheme,
  clearAllCache,
  tRexRunnerHtml,
  tRexRunnerCss,

  // In-app browser methods
  openWithSystemBrowser,

  // Custom tab / Safari view controller methods
  isAvailable,
  getMaxToolbarItems,
  getPackageName,
  clearWebsiteData,
  prewarmConnections,

  // Web authentication methods
  // isAvailable - already defined above, reused

  // Service worker methods
  instance,

  // WebView feature checks
  isFeatureSupported,
  isStartupFeatureSupported,

  // Process global config methods
  apply,

  // Cookie methods
  // instance - already defined above, reused

  // HTTP auth credential database methods
  // instance - already defined above, reused

  // Web storage methods
  // instance - already defined above, reused
}

/// Enum representing static method class types
enum StaticClassType {
  inAppWebViewController(
    InAppWebViewController,
    'Static methods for WebView controller',
    Icons.web,
  ),
  inAppBrowser(
    InAppBrowser,
    'Static methods for in-app browser',
    Icons.open_in_browser,
  ),
  chromeSafariBrowser(
    ChromeSafariBrowser,
    'Static methods for Chrome Custom Tabs / SFSafariViewController',
    Icons.tab,
  ),
  webAuthenticationSession(
    WebAuthenticationSession,
    'Static methods for web authentication',
    Icons.security,
  ),
  serviceWorkerController(
    ServiceWorkerController,
    'Static methods for service worker control',
    Icons.work,
  ),
  webViewFeature(
    WebViewFeature,
    'Check WebView feature support (Android)',
    Icons.check_circle,
  ),
  processGlobalConfig(
    ProcessGlobalConfig,
    'Process-level configuration (Android)',
    Icons.settings_applications,
  ),
  cookieManager(CookieManager, 'Cookie management methods', Icons.cookie),
  httpAuthCredentialDatabase(
    HttpAuthCredentialDatabase,
    'HTTP authentication credential storage',
    Icons.lock,
  ),
  webStorageManager(WebStorageManager, 'Web storage management', Icons.storage);

  final Type apiType;
  final String description;
  final IconData icon;

  const StaticClassType(this.apiType, this.description, this.icon);

  String get displayName => apiType.toString();
}

/// Static method entry for a class's static method
class StaticMethodEntry {
  /// The method type enum - name is derived from this
  final StaticMethodType methodType;
  final String description;

  /// The class name for looking up support info via SupportChecker
  final Type classType;
  final Map<String, dynamic> parameters;
  final List<String> requiredParameters;
  final Future<dynamic> Function(Map<String, dynamic> params) execute;

  const StaticMethodEntry({
    required this.methodType,
    required this.description,
    required this.classType,
    this.parameters = const {},
    this.requiredParameters = const [],
    required this.execute,
  });

  /// The display name derived from methodType.name
  String get name => methodType.name;

  /// Returns supported platforms using runtime checks via SupportChecker
  Set<SupportedPlatform> get supportedPlatforms =>
      SupportChecker.getSupportedPlatformsForMethod(classType.toString(), name);
}

/// A class containing static methods
class StaticMethodClass {
  /// The class type enum - name, description and icon are derived from this
  final StaticClassType classType;
  final List<StaticMethodEntry> methods;

  const StaticMethodClass({required this.classType, required this.methods});

  /// The display name derived from classType.displayName
  String get name => classType.displayName;

  /// The description derived from classType.description
  String get description => classType.description;

  /// The icon derived from classType.icon
  IconData get icon => classType.icon;
}

/// Widget to test static methods across WebView-related classes
/// Tests static methods from the controller, browser, and other helpers.
class StaticMethodTesterWidget extends StatefulWidget {
  const StaticMethodTesterWidget({super.key});

  @override
  State<StaticMethodTesterWidget> createState() =>
      _StaticMethodTesterWidgetState();
}

class _StaticMethodTesterWidgetState extends State<StaticMethodTesterWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Map<String, List<MethodResultEntry>> _methodHistory = {};
  final Map<String, int> _selectedHistoryIndex = {};
  final Map<String, bool> _executing = {};
  final Set<int> _expandedClasses = {0}; // First class expanded by default

  late final List<StaticMethodClass> _classes;

  @override
  void initState() {
    super.initState();
    _classes = _buildStaticMethodClasses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StaticMethodClass> _buildStaticMethodClasses() {
    return [
      // WebView controller static methods
      StaticMethodClass(
        classType: StaticClassType.inAppWebViewController,
        methods: [
          StaticMethodEntry(
            methodType: StaticMethodType.getDefaultUserAgent,
            description: 'Gets the default User-Agent string',
            classType: InAppWebViewController,
            execute: (params) async {
              return await InAppWebViewController.getDefaultUserAgent();
            },
          ),
          StaticMethodEntry(
            methodType: StaticMethodType.clearClientCertPreferences,
            description: 'Clears the client certificate preferences',
            classType: InAppWebViewController,
            execute: (params) async {
              await InAppWebViewController.clearClientCertPreferences();
              return 'Client cert preferences cleared';
            },
          ),
          StaticMethodEntry(
            methodType: StaticMethodType.getSafeBrowsingPrivacyPolicyUrl,
            description: 'Gets the Safe Browsing privacy policy URL',
            classType: InAppWebViewController,
            execute: (params) async {
              final url =
                  await InAppWebViewController.getSafeBrowsingPrivacyPolicyUrl();
              return url?.toString() ?? 'No URL available';
            },
          ),
          StaticMethodEntry(
            methodType: StaticMethodType.setSafeBrowsingAllowlist,
            description: 'Sets the Safe Browsing allowlist',
            classType: InAppWebViewController,
            parameters: {'hosts': 'example.com,test.com'},
            requiredParameters: ['hosts'],
            execute: (params) async {
              final hostsStr = params['hosts']?.toString() ?? '';
              final hosts = hostsStr.split(',').map((h) => h.trim()).toList();
              final result =
                  await InAppWebViewController.setSafeBrowsingAllowlist(
                    hosts: hosts,
                  );
              return result
                  ? 'Allowlist set successfully'
                  : 'Failed to set allowlist';
            },
          ),
          StaticMethodEntry(
            methodType: StaticMethodType.getCurrentWebViewPackage,
            description: 'Gets the current WebView package info',
            classType: InAppWebViewController,
            execute: (params) async {
              final pkg =
                  await InAppWebViewController.getCurrentWebViewPackage();
              if (pkg == null) return 'No WebView package info';
              return 'Package: ${pkg.packageName}\nVersion: ${pkg.versionName}';
            },
          ),
          StaticMethodEntry(
            methodType: StaticMethodType.setWebContentsDebuggingEnabled,
            description: 'Enables or disables WebView debugging',
            classType: InAppWebViewController,
            parameters: {'debuggingEnabled': true},
            requiredParameters: ['debuggingEnabled'],
            execute: (params) async {
              final enabled = params['debuggingEnabled'] as bool? ?? true;
              await InAppWebViewController.setWebContentsDebuggingEnabled(
                enabled,
              );
              return 'Debugging ${enabled ? "enabled" : "disabled"}';
            },
          ),
          StaticMethodEntry(
            methodType: StaticMethodType.getVariationsHeader,
            description: 'Gets the variations header',
            classType: InAppWebViewController,
            execute: (params) async {
              final header = await InAppWebViewController.getVariationsHeader();
              return header ?? 'No variations header';
            },
          ),
          StaticMethodEntry(
            methodType: StaticMethodType.isMultiProcessEnabled,
            description: 'Checks if multi-process is enabled',
            classType: InAppWebViewController,
            execute: (params) async {
              return await InAppWebViewController.isMultiProcessEnabled();
            },
          ),
          StaticMethodEntry(
            methodType: StaticMethodType.disableWebView,
            description: 'Disables the WebView',
            classType: InAppWebViewController,
            execute: (params) async {
              await InAppWebViewController.disableWebView();
              return 'WebView disabled';
            },
          ),
          StaticMethodEntry(
            methodType: StaticMethodType.handlesURLScheme,
            description: 'Checks if WebView handles a URL scheme',
            classType: InAppWebViewController,
            parameters: {'urlScheme': 'https'},
            requiredParameters: ['urlScheme'],
            execute: (params) async {
              final scheme = params['urlScheme']?.toString() ?? 'https';
              return await InAppWebViewController.handlesURLScheme(scheme);
            },
          ),
          StaticMethodEntry(
            methodType: StaticMethodType.clearAllCache,
            description: 'Clears all WebView caches',
            classType: InAppWebViewController,
            parameters: {'includeDiskFiles': true},
            execute: (params) async {
              final includeDiskFiles =
                  params['includeDiskFiles'] as bool? ?? true;
              await InAppWebViewController.clearAllCache(
                includeDiskFiles: includeDiskFiles,
              );
              return 'Cache cleared';
            },
          ),
          StaticMethodEntry(
            methodType: StaticMethodType.tRexRunnerHtml,
            description: 'Gets the T-Rex Runner game HTML',
            classType: InAppWebViewController,
            execute: (params) async {
              final html = await InAppWebViewController.tRexRunnerHtml;
              if (html.length > 200) {
                return '${html.substring(0, 200)}... (${html.length} chars total)';
              }
              return html;
            },
          ),
          StaticMethodEntry(
            methodType: StaticMethodType.tRexRunnerCss,
            description: 'Gets the T-Rex Runner game CSS',
            classType: InAppWebViewController,
            execute: (params) async {
              final css = await InAppWebViewController.tRexRunnerCss;
              if (css.length > 200) {
                return '${css.substring(0, 200)}... (${css.length} chars total)';
              }
              return css;
            },
          ),
        ],
      ),

      // In-app browser static methods
      StaticMethodClass(
        classType: StaticClassType.inAppBrowser,
        methods: [
          StaticMethodEntry(
            methodType: StaticMethodType.openWithSystemBrowser,
            description: 'Opens a URL in the system browser',
            classType: InAppBrowser,
            parameters: {'url': 'https://flutter.dev'},
            requiredParameters: ['url'],
            execute: (params) async {
              final url = params['url']?.toString() ?? 'https://flutter.dev';
              await InAppBrowser.openWithSystemBrowser(url: WebUri(url));
              return 'Opened in system browser';
            },
          ),
        ],
      ),

      // Custom tab / Safari view controller static methods
      StaticMethodClass(
        classType: StaticClassType.chromeSafariBrowser,
        methods: [
          StaticMethodEntry(
            methodType: StaticMethodType.isAvailable,
            description:
                'Checks if Chrome Custom Tabs / SFSafariViewController is available',
            classType: ChromeSafariBrowser,
            execute: (params) async {
              return await ChromeSafariBrowser.isAvailable();
            },
          ),
          StaticMethodEntry(
            methodType: StaticMethodType.getMaxToolbarItems,
            description: 'Gets the maximum toolbar items (Android only)',
            classType: ChromeSafariBrowser,
            execute: (params) async {
              return await ChromeSafariBrowser.getMaxToolbarItems();
            },
          ),
          StaticMethodEntry(
            methodType: StaticMethodType.getPackageName,
            description: 'Gets the package name for Custom Tabs (Android only)',
            classType: ChromeSafariBrowser,
            execute: (params) async {
              final packageName = await ChromeSafariBrowser.getPackageName();
              return packageName ?? 'No package available';
            },
          ),
          StaticMethodEntry(
            methodType: StaticMethodType.clearWebsiteData,
            description: 'Clears website data (Android only)',
            classType: ChromeSafariBrowser,
            execute: (params) async {
              await ChromeSafariBrowser.clearWebsiteData();
              return 'Website data cleared';
            },
          ),
          StaticMethodEntry(
            methodType: StaticMethodType.prewarmConnections,
            description: 'Prewarms connections (iOS only)',
            classType: ChromeSafariBrowser,
            parameters: {'urls': 'https://flutter.dev,https://dart.dev'},
            requiredParameters: ['urls'],
            execute: (params) async {
              final urlsStr = params['urls']?.toString() ?? '';
              final urls = urlsStr
                  .split(',')
                  .map((u) => WebUri(u.trim()))
                  .toList();
              final token = await ChromeSafariBrowser.prewarmConnections(urls);
              return token != null
                  ? 'Prewarming token: ${token.hashCode}'
                  : 'Prewarming failed';
            },
          ),
        ],
      ),

      // WebAuthenticationSession static methods
      StaticMethodClass(
        classType: StaticClassType.webAuthenticationSession,
        methods: [
          StaticMethodEntry(
            methodType: StaticMethodType.isAvailable,
            description: 'Checks if web authentication is available',
            classType: WebAuthenticationSession,
            execute: (params) async {
              return await WebAuthenticationSession.isAvailable();
            },
          ),
        ],
      ),

      // ServiceWorkerController static methods
      StaticMethodClass(
        classType: StaticClassType.serviceWorkerController,
        methods: [
          StaticMethodEntry(
            methodType: StaticMethodType.instance,
            description: 'Gets the singleton instance',
            classType: ServiceWorkerController,
            execute: (params) async {
              final controller = ServiceWorkerController.instance();
              return '${ServiceWorkerController} instance: ${controller.hashCode}';
            },
          ),
        ],
      ),

      // WebViewFeature static methods
      StaticMethodClass(
        classType: StaticClassType.webViewFeature,
        methods: [
          StaticMethodEntry(
            methodType: StaticMethodType.isFeatureSupported,
            description: 'Checks if a WebView feature is supported',
            classType: WebViewFeature,
            parameters: {'feature': WebViewFeature.WEB_MESSAGE_LISTENER.name()},
            requiredParameters: ['feature'],
            execute: (params) async {
              final featureName =
                  params['feature']?.toString() ??
                  WebViewFeature.WEB_MESSAGE_LISTENER.name();
              final feature = WebViewFeature.values.firstWhere(
                (f) => f.name().toUpperCase() == featureName.toUpperCase(),
                orElse: () => WebViewFeature.WEB_MESSAGE_LISTENER,
              );
              return await WebViewFeature.isFeatureSupported(feature);
            },
          ),
          StaticMethodEntry(
            methodType: StaticMethodType.isStartupFeatureSupported,
            description: 'Checks if a startup feature is supported',
            classType: WebViewFeature,
            parameters: {
              'feature': WebViewFeature
                  .STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX
                  .name(),
            },
            requiredParameters: ['feature'],
            execute: (params) async {
              final featureName =
                  params['feature']?.toString() ??
                  WebViewFeature.STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX
                      .name();
              final feature = WebViewFeature.values.firstWhere(
                (f) => f.name().toUpperCase() == featureName.toUpperCase(),
                orElse: () =>
                    WebViewFeature.STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX,
              );
              return await WebViewFeature.isStartupFeatureSupported(feature);
            },
          ),
        ],
      ),

      // ProcessGlobalConfig static methods
      StaticMethodClass(
        classType: StaticClassType.processGlobalConfig,
        methods: [
          StaticMethodEntry(
            methodType: StaticMethodType.apply,
            description: 'Applies process global config',
            classType: ProcessGlobalConfig,
            parameters: {'dataDirectorySuffix': ''},
            execute: (params) async {
              final suffix = params['dataDirectorySuffix']?.toString();
              await ProcessGlobalConfig.instance().apply(
                settings: ProcessGlobalConfigSettings(
                  dataDirectorySuffix: suffix?.isNotEmpty == true
                      ? suffix
                      : null,
                ),
              );
              return 'Config applied';
            },
          ),
        ],
      ),

      // CookieManager static methods
      StaticMethodClass(
        classType: StaticClassType.cookieManager,
        methods: [
          StaticMethodEntry(
            methodType: StaticMethodType.instance,
            description: 'Gets the singleton instance',
            classType: CookieManager,
            execute: (params) async {
              final manager = CookieManager.instance();
              return '${CookieManager} instance: ${manager.hashCode}';
            },
          ),
        ],
      ),

      // HttpAuthCredentialDatabase static methods
      StaticMethodClass(
        classType: StaticClassType.httpAuthCredentialDatabase,
        methods: [
          StaticMethodEntry(
            methodType: StaticMethodType.instance,
            description: 'Gets the singleton instance',
            classType: HttpAuthCredentialDatabase,
            execute: (params) async {
              final db = HttpAuthCredentialDatabase.instance();
              return '${HttpAuthCredentialDatabase} instance: ${db.hashCode}';
            },
          ),
        ],
      ),

      // WebStorageManager static methods
      StaticMethodClass(
        classType: StaticClassType.webStorageManager,
        methods: [
          StaticMethodEntry(
            methodType: StaticMethodType.instance,
            description: 'Gets the singleton instance',
            classType: WebStorageManager,
            execute: (params) async {
              final manager = WebStorageManager.instance();
              return '${WebStorageManager} instance: ${manager.hashCode}';
            },
          ),
        ],
      ),
    ];
  }

  List<StaticMethodClass> _getFilteredClasses() {
    if (_searchQuery.isEmpty) {
      return _classes;
    }

    final query = _searchQuery.toLowerCase();
    return _classes
        .map((cls) {
          final filteredMethods = cls.methods
              .where(
                (method) =>
                    method.name.toLowerCase().contains(query) ||
                    method.description.toLowerCase().contains(query) ||
                    cls.name.toLowerCase().contains(query),
              )
              .toList();
          return StaticMethodClass(
            classType: cls.classType,
            methods: filteredMethods,
          );
        })
        .where((cls) => cls.methods.isNotEmpty)
        .toList();
  }

  String _methodKey(String className, String methodName) =>
      '$className.$methodName';

  Future<void> _executeMethod(
    StaticMethodClass cls,
    StaticMethodEntry entry,
  ) async {
    final key = _methodKey(cls.name, entry.name);
    setState(() {
      _executing[key] = true;
    });

    try {
      Map<String, dynamic> params = entry.parameters;
      if (entry.parameters.isNotEmpty) {
        final updatedParams = await showParameterDialog(
          context: context,
          title: '${cls.name}.${entry.name} parameters',
          parameters: entry.parameters,
          requiredPaths: entry.requiredParameters,
        );

        if (updatedParams == null) {
          if (mounted) {
            setState(() {
              _executing[key] = false;
            });
          }
          return;
        }
        params = updatedParams;
      }

      final result = await entry.execute(params);
      if (mounted) {
        setState(() {
          _addMethodHistoryEntry(
            key,
            _formatResult(result),
            isError: false,
            value: result,
          );
          _executing[key] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _addMethodHistoryEntry(key, e.toString(), isError: true);
          _executing[key] = false;
        });
      }
    }
  }

  void _addMethodHistoryEntry(
    String methodKey,
    String message, {
    required bool isError,
    dynamic value,
  }) {
    final current = List<MethodResultEntry>.from(
      _methodHistory[methodKey] ?? const [],
    );
    current.insert(
      0,
      MethodResultEntry(
        message: message,
        isError: isError,
        timestamp: DateTime.now(),
        value: value,
      ),
    );
    if (current.length > 3) {
      current.removeRange(3, current.length);
    }
    _methodHistory[methodKey] = current;
    _selectedHistoryIndex[methodKey] = 0;
  }

  String _formatResult(dynamic result) {
    if (result == null) return 'null';
    if (result is String) return result;

    final mapResult = _toMapIfPossible(result);
    if (mapResult != null) {
      try {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(mapResult);
      } catch (e) {
        return mapResult.toString();
      }
    }

    if (result is Map || result is List) {
      try {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(result);
      } catch (e) {
        return result.toString();
      }
    }
    return result.toString();
  }

  dynamic _toMapIfPossible(dynamic value) {
    if (value == null) return null;
    if (value is Map || value is List) return value;

    try {
      final toMapResult = (value as dynamic).toMap?.call();
      if (toMapResult is Map) return toMapResult;
    } catch (_) {}

    try {
      final toJsonResult = (value as dynamic).toJson?.call();
      if (toJsonResult is Map) return toJsonResult;
    } catch (_) {}

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final filteredClasses = _getFilteredClasses();
    final totalMethods = _classes.fold<int>(
      0,
      (sum, cls) => sum + cls.methods.length,
    );

    return Column(
      children: [
        // Header with search
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.functions, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Static Method Tester ($totalMethods methods)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search static methods...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  isDense: true,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ],
          ),
        ),

        // Info banner
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.blue.shade50,
          child: const Row(
            children: [
              Icon(Icons.info, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Static methods can be called without a WebView instance.',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),

        // Method classes
        Expanded(
          child: ListView.builder(
            itemCount: filteredClasses.length,
            itemBuilder: (context, classIndex) {
              final cls = filteredClasses[classIndex];
              final originalIndex = _classes.indexOf(cls);
              final isExpanded =
                  _searchQuery.isNotEmpty ||
                  _expandedClasses.contains(originalIndex);

              return ExpansionTile(
                key: Key(cls.name),
                initiallyExpanded: isExpanded,
                leading: Icon(cls.icon, size: 24),
                title: Text(
                  '${cls.name} (${cls.methods.length})',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  cls.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                onExpansionChanged: (expanded) {
                  setState(() {
                    if (expanded) {
                      _expandedClasses.add(originalIndex);
                    } else {
                      _expandedClasses.remove(originalIndex);
                    }
                  });
                },
                children: cls.methods
                    .map((method) => _buildMethodTile(cls, method))
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMethodTile(StaticMethodClass cls, StaticMethodEntry method) {
    final key = _methodKey(cls.name, method.name);
    final isExecuting = _executing[key] == true;
    final historyEntries = _methodHistory[key] ?? const [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Method header
          ListTile(
            dense: true,
            title: Text(
              '${cls.name}.${method.name}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  SupportBadgesRow(
                    supportedPlatforms: method.supportedPlatforms,
                    compact: true,
                  ),
                ],
              ),
            ),
            trailing: SizedBox(
              width: 80,
              height: 32,
              child: ElevatedButton(
                onPressed: isExecuting
                    ? null
                    : () => _executeMethod(cls, method),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  textStyle: const TextStyle(fontSize: 11),
                ),
                child: isExecuting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Execute'),
              ),
            ),
          ),

          if (historyEntries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: MethodResultHistory(
                entries: historyEntries,
                selectedIndex: _selectedHistoryIndex[key],
                onSelected: (index) {
                  setState(() => _selectedHistoryIndex[key] = index);
                },
              ),
            ),
        ],
      ),
    );
  }
}
