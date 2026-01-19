import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';
import 'package:flutter_inappwebview_example/widgets/common/support_badge.dart';
import 'package:flutter_inappwebview_example/widgets/common/parameter_dialog.dart';
import 'package:flutter_inappwebview_example/widgets/common/method_result_history.dart';

/// Static method entry for a class's static method
class StaticMethodEntry {
  final String name;
  final String description;
  final Set<SupportedPlatform> supportedPlatforms;
  final Map<String, dynamic> parameters;
  final List<String> requiredParameters;
  final Future<dynamic> Function(Map<String, dynamic> params) execute;

  const StaticMethodEntry({
    required this.name,
    required this.description,
    required this.supportedPlatforms,
    this.parameters = const {},
    this.requiredParameters = const [],
    required this.execute,
  });
}

/// A class containing static methods
class StaticMethodClass {
  final String name;
  final String description;
  final IconData icon;
  final List<StaticMethodEntry> methods;

  const StaticMethodClass({
    required this.name,
    required this.description,
    required this.icon,
    required this.methods,
  });
}

/// Widget to test static methods across InAppWebView classes
/// Tests static methods from InAppWebViewController, InAppBrowser, ChromeSafariBrowser, etc.
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
    const mobilePlatforms = {SupportedPlatform.android, SupportedPlatform.ios};
    const applePlatforms = {SupportedPlatform.ios, SupportedPlatform.macos};
    const nativePlatforms = {
      SupportedPlatform.android,
      SupportedPlatform.ios,
      SupportedPlatform.macos,
      SupportedPlatform.windows,
      SupportedPlatform.linux,
    };

    return [
      // InAppWebViewController static methods
      StaticMethodClass(
        name: 'InAppWebViewController',
        description: 'Static methods for WebView controller',
        icon: Icons.web,
        methods: [
          StaticMethodEntry(
            name: 'getDefaultUserAgent',
            description: 'Gets the default User-Agent string',
            supportedPlatforms: {
              ...mobilePlatforms,
              SupportedPlatform.macos,
              SupportedPlatform.windows,
            },
            execute: (params) async {
              return await InAppWebViewController.getDefaultUserAgent();
            },
          ),
          StaticMethodEntry(
            name: 'clearClientCertPreferences',
            description: 'Clears the client certificate preferences',
            supportedPlatforms: {SupportedPlatform.android},
            execute: (params) async {
              await InAppWebViewController.clearClientCertPreferences();
              return 'Client cert preferences cleared';
            },
          ),
          StaticMethodEntry(
            name: 'getSafeBrowsingPrivacyPolicyUrl',
            description: 'Gets the Safe Browsing privacy policy URL',
            supportedPlatforms: {SupportedPlatform.android},
            execute: (params) async {
              final url =
                  await InAppWebViewController.getSafeBrowsingPrivacyPolicyUrl();
              return url?.toString() ?? 'No URL available';
            },
          ),
          StaticMethodEntry(
            name: 'setSafeBrowsingAllowlist',
            description: 'Sets the Safe Browsing allowlist',
            supportedPlatforms: {SupportedPlatform.android},
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
            name: 'getCurrentWebViewPackage',
            description: 'Gets the current WebView package info',
            supportedPlatforms: {SupportedPlatform.android},
            execute: (params) async {
              final pkg =
                  await InAppWebViewController.getCurrentWebViewPackage();
              if (pkg == null) return 'No WebView package info';
              return 'Package: ${pkg.packageName}\nVersion: ${pkg.versionName}';
            },
          ),
          StaticMethodEntry(
            name: 'setWebContentsDebuggingEnabled',
            description: 'Enables or disables WebView debugging',
            supportedPlatforms: {SupportedPlatform.android},
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
            name: 'getVariationsHeader',
            description: 'Gets the variations header',
            supportedPlatforms: {SupportedPlatform.android},
            execute: (params) async {
              final header = await InAppWebViewController.getVariationsHeader();
              return header ?? 'No variations header';
            },
          ),
          StaticMethodEntry(
            name: 'isMultiProcessEnabled',
            description: 'Checks if multi-process is enabled',
            supportedPlatforms: {SupportedPlatform.android},
            execute: (params) async {
              return await InAppWebViewController.isMultiProcessEnabled();
            },
          ),
          StaticMethodEntry(
            name: 'disableWebView',
            description: 'Disables the WebView',
            supportedPlatforms: {SupportedPlatform.android},
            execute: (params) async {
              await InAppWebViewController.disableWebView();
              return 'WebView disabled';
            },
          ),
          StaticMethodEntry(
            name: 'handlesURLScheme',
            description: 'Checks if WebView handles a URL scheme',
            supportedPlatforms: applePlatforms,
            parameters: {'urlScheme': 'https'},
            requiredParameters: ['urlScheme'],
            execute: (params) async {
              final scheme = params['urlScheme']?.toString() ?? 'https';
              return await InAppWebViewController.handlesURLScheme(scheme);
            },
          ),
          StaticMethodEntry(
            name: 'clearAllCache',
            description: 'Clears all WebView caches',
            supportedPlatforms: nativePlatforms,
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
            name: 'tRexRunnerHtml',
            description: 'Gets the T-Rex Runner game HTML',
            supportedPlatforms: SupportedPlatform.values.toSet(),
            execute: (params) async {
              final html = await InAppWebViewController.tRexRunnerHtml;
              if (html.length > 200) {
                return '${html.substring(0, 200)}... (${html.length} chars total)';
              }
              return html;
            },
          ),
          StaticMethodEntry(
            name: 'tRexRunnerCss',
            description: 'Gets the T-Rex Runner game CSS',
            supportedPlatforms: SupportedPlatform.values.toSet(),
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

      // InAppBrowser static methods
      StaticMethodClass(
        name: 'InAppBrowser',
        description: 'Static methods for in-app browser',
        icon: Icons.open_in_browser,
        methods: [
          StaticMethodEntry(
            name: 'openWithSystemBrowser',
            description: 'Opens a URL in the system browser',
            supportedPlatforms: nativePlatforms,
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

      // ChromeSafariBrowser static methods
      StaticMethodClass(
        name: 'ChromeSafariBrowser',
        description:
            'Static methods for Chrome Custom Tabs / SFSafariViewController',
        icon: Icons.tab,
        methods: [
          StaticMethodEntry(
            name: 'isAvailable',
            description:
                'Checks if Chrome Custom Tabs / SFSafariViewController is available',
            supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
            execute: (params) async {
              return await ChromeSafariBrowser.isAvailable();
            },
          ),
          StaticMethodEntry(
            name: 'getMaxToolbarItems',
            description: 'Gets the maximum toolbar items (Android only)',
            supportedPlatforms: {SupportedPlatform.android},
            execute: (params) async {
              return await ChromeSafariBrowser.getMaxToolbarItems();
            },
          ),
          StaticMethodEntry(
            name: 'getPackageName',
            description: 'Gets the package name for Custom Tabs (Android only)',
            supportedPlatforms: {SupportedPlatform.android},
            execute: (params) async {
              final packageName = await ChromeSafariBrowser.getPackageName();
              return packageName ?? 'No package available';
            },
          ),
          StaticMethodEntry(
            name: 'clearWebsiteData',
            description: 'Clears website data (Android only)',
            supportedPlatforms: {SupportedPlatform.android},
            execute: (params) async {
              await ChromeSafariBrowser.clearWebsiteData();
              return 'Website data cleared';
            },
          ),
          StaticMethodEntry(
            name: 'prewarmConnections',
            description: 'Prewarms connections (iOS only)',
            supportedPlatforms: {SupportedPlatform.ios},
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
        name: 'WebAuthenticationSession',
        description: 'Static methods for web authentication',
        icon: Icons.security,
        methods: [
          StaticMethodEntry(
            name: 'isAvailable',
            description: 'Checks if web authentication is available',
            supportedPlatforms: applePlatforms,
            execute: (params) async {
              return await WebAuthenticationSession.isAvailable();
            },
          ),
        ],
      ),

      // ServiceWorkerController static methods
      StaticMethodClass(
        name: 'ServiceWorkerController',
        description: 'Static methods for service worker control',
        icon: Icons.work,
        methods: [
          StaticMethodEntry(
            name: 'instance',
            description: 'Gets the singleton instance',
            supportedPlatforms: {SupportedPlatform.android},
            execute: (params) async {
              final controller = ServiceWorkerController.instance();
              return 'ServiceWorkerController instance: ${controller.hashCode}';
            },
          ),
        ],
      ),

      // WebViewFeature static methods
      StaticMethodClass(
        name: 'WebViewFeature',
        description: 'Check WebView feature support (Android)',
        icon: Icons.check_circle,
        methods: [
          StaticMethodEntry(
            name: 'isFeatureSupported',
            description: 'Checks if a WebView feature is supported',
            supportedPlatforms: {SupportedPlatform.android},
            parameters: {'feature': 'WEB_MESSAGE_LISTENER'},
            requiredParameters: ['feature'],
            execute: (params) async {
              final featureName =
                  params['feature']?.toString() ?? 'WEB_MESSAGE_LISTENER';
              final feature = WebViewFeature.values.firstWhere(
                (f) => f.name().toUpperCase() == featureName.toUpperCase(),
                orElse: () => WebViewFeature.WEB_MESSAGE_LISTENER,
              );
              return await WebViewFeature.isFeatureSupported(feature);
            },
          ),
          StaticMethodEntry(
            name: 'isStartupFeatureSupported',
            description: 'Checks if a startup feature is supported',
            supportedPlatforms: {SupportedPlatform.android},
            parameters: {
              'feature': 'STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX',
            },
            requiredParameters: ['feature'],
            execute: (params) async {
              final featureName =
                  params['feature']?.toString() ??
                  'STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX';
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
        name: 'ProcessGlobalConfig',
        description: 'Process-level configuration (Android)',
        icon: Icons.settings_applications,
        methods: [
          StaticMethodEntry(
            name: 'apply',
            description: 'Applies process global config',
            supportedPlatforms: {SupportedPlatform.android},
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
        name: 'CookieManager',
        description: 'Cookie management methods',
        icon: Icons.cookie,
        methods: [
          StaticMethodEntry(
            name: 'instance',
            description: 'Gets the singleton instance',
            supportedPlatforms: SupportedPlatform.values.toSet(),
            execute: (params) async {
              final manager = CookieManager.instance();
              return 'CookieManager instance: ${manager.hashCode}';
            },
          ),
        ],
      ),

      // HttpAuthCredentialDatabase static methods
      StaticMethodClass(
        name: 'HttpAuthCredentialDatabase',
        description: 'HTTP authentication credential storage',
        icon: Icons.lock,
        methods: [
          StaticMethodEntry(
            name: 'instance',
            description: 'Gets the singleton instance',
            supportedPlatforms: {...mobilePlatforms, SupportedPlatform.macos},
            execute: (params) async {
              final db = HttpAuthCredentialDatabase.instance();
              return 'HttpAuthCredentialDatabase instance: ${db.hashCode}';
            },
          ),
        ],
      ),

      // WebStorageManager static methods
      StaticMethodClass(
        name: 'WebStorageManager',
        description: 'Web storage management',
        icon: Icons.storage,
        methods: [
          StaticMethodEntry(
            name: 'instance',
            description: 'Gets the singleton instance',
            supportedPlatforms: nativePlatforms,
            execute: (params) async {
              final manager = WebStorageManager.instance();
              return 'WebStorageManager instance: ${manager.hashCode}';
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
            name: cls.name,
            description: cls.description,
            icon: cls.icon,
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
                  Text(
                    'Static Method Tester ($totalMethods methods)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
