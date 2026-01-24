import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/widgets/common/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/providers/event_log_provider.dart';
import 'package:flutter_inappwebview_example/models/event_log_entry.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';
import 'package:flutter_inappwebview_example/widgets/common/support_badge.dart';
import 'package:flutter_inappwebview_example/widgets/common/parameter_dialog.dart';
import 'package:flutter_inappwebview_example/widgets/common/method_result_history.dart';
import 'package:flutter_inappwebview_example/providers/settings_manager.dart';
import 'package:flutter_inappwebview_example/widgets/common/profile_selector_card.dart';
import 'package:flutter_inappwebview_example/utils/responsive_utils.dart';
import 'package:flutter_inappwebview_example/widgets/common/responsive_row.dart';

/// Screen for testing service-level controllers
class ServiceControllersScreen extends StatefulWidget {
  const ServiceControllersScreen({super.key});

  @override
  State<ServiceControllersScreen> createState() =>
      _ServiceControllersScreenState();
}

class _ServiceControllersScreenState extends State<ServiceControllersScreen> {
  bool _isLoading = false;

  // ServiceWorkerController state
  bool _allowContentAccess = true;
  bool _allowFileAccess = true;
  bool _blockNetworkLoads = false;
  CacheMode? _cacheMode = CacheMode.LOAD_DEFAULT;

  // ProxyController state
  final TextEditingController _proxyHostController = TextEditingController(
    text: '127.0.0.1',
  );
  final TextEditingController _proxyPortController = TextEditingController(
    text: '8080',
  );
  final TextEditingController _bypassListController = TextEditingController();

  // TracingController state
  bool _isTracing = false;

  // WebViewEnvironment state
  String? _availableVersion;
  List<BrowserProcessInfo> _processInfos = [];
  int _lastEnvironmentRevision = -1;

  // ProcessGlobalConfig state
  final TextEditingController _dataDirSuffixController = TextEditingController(
    text: 'test_suffix',
  );

  final Map<String, List<MethodResultEntry>> _methodHistory = {};
  final Map<String, int> _selectedHistoryIndex = {};
  static const int _maxHistoryEntries = 3;

  Set<SupportedPlatform> _mergePlatforms(
    Set<SupportedPlatform> first,
    Set<SupportedPlatform> second,
  ) {
    return {...first, ...second};
  }

  Set<SupportedPlatform> _serviceWorkerPlatforms(
    PlatformServiceWorkerControllerMethod method,
  ) {
    return SupportCheckHelper.supportedPlatformsForMethod(
      method: method,
      checker: ServiceWorkerController.isMethodSupported,
    );
  }

  Set<SupportedPlatform> _proxyControllerPlatforms(
    PlatformProxyControllerMethod method,
  ) {
    return SupportCheckHelper.supportedPlatformsForMethod(
      method: method,
      checker: ProxyController.isMethodSupported,
    );
  }

  Set<SupportedPlatform> _tracingControllerPlatforms(
    PlatformTracingControllerMethod method,
  ) {
    return SupportCheckHelper.supportedPlatformsForMethod(
      method: method,
      checker: TracingController.isMethodSupported,
    );
  }

  Set<SupportedPlatform> _webViewEnvironmentPlatforms(
    PlatformWebViewEnvironmentMethod method,
  ) {
    return SupportCheckHelper.supportedPlatformsForMethod(
      method: method,
      checker: WebViewEnvironment.isMethodSupported,
    );
  }

  Set<SupportedPlatform> _processGlobalConfigPlatforms(
    PlatformProcessGlobalConfigMethod method,
  ) {
    return SupportCheckHelper.supportedPlatformsForMethod(
      method: method,
      checker: ProcessGlobalConfig.isMethodSupported,
    );
  }

  @override
  void dispose() {
    _proxyHostController.dispose();
    _proxyPortController.dispose();
    _bypassListController.dispose();
    _dataDirSuffixController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settingsManager = context.watch<SettingsManager>();
    if (_lastEnvironmentRevision != settingsManager.environmentRevision) {
      _lastEnvironmentRevision = settingsManager.environmentRevision;
      setState(() {
        _processInfos = [];
        _availableVersion = null;
      });
    }
  }

  void _logEvent(EventType type, String message, {Map<String, dynamic>? data}) {
    context.read<EventLogProvider>().addEvent(
      EventLogEntry(
        timestamp: DateTime.now(),
        eventType: type,
        message: message,
        data: data,
      ),
    );
  }

  void _recordMethodResult(
    String methodName,
    String message, {
    required bool isError,
    dynamic value,
  }) {
    setState(() {
      final entries = List<MethodResultEntry>.from(
        _methodHistory[methodName] ?? const [],
      );
      entries.insert(
        0,
        MethodResultEntry(
          message: message,
          isError: isError,
          timestamp: DateTime.now(),
          value: value,
        ),
      );
      if (entries.length > _maxHistoryEntries) {
        entries.removeRange(_maxHistoryEntries, entries.length);
      }
      _methodHistory[methodName] = entries;
      _selectedHistoryIndex[methodName] = 0;
    });
  }

  Widget _buildMethodHistory(String methodName, {String? title}) {
    final entries = _methodHistory[methodName] ?? const [];
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }
    return MethodResultHistory(
      entries: entries,
      selectedIndex: _selectedHistoryIndex[methodName],
      title: title ?? methodName,
      onSelected: (index) {
        setState(() => _selectedHistoryIndex[methodName] = index);
      },
    );
  }

  TracingMode _parseTracingMode(String? value) {
    if (value == null || value.isEmpty) {
      return TracingMode.RECORD_CONTINUOUSLY;
    }
    return TracingMode.values.firstWhere(
      (mode) => mode.name().toLowerCase() == value.toLowerCase(),
      orElse: () => TracingMode.RECORD_CONTINUOUSLY,
    );
  }

  List<TracingCategory> _parseTracingCategories(dynamic raw) {
    if (raw is! List) {
      return [TracingCategory.CATEGORIES_WEB_DEVELOPER];
    }
    final categories = <TracingCategory>[];
    for (final entry in raw) {
      final name = entry.toString().toLowerCase();
      final matched = TracingCategory.values.firstWhere(
        (category) => category.name().toLowerCase() == name,
        orElse: () => TracingCategory.CATEGORIES_WEB_DEVELOPER,
      );
      categories.add(matched);
    }
    return categories.isEmpty
        ? [TracingCategory.CATEGORIES_WEB_DEVELOPER]
        : categories;
  }

  // ServiceWorkerController methods
  Future<void> _getAllowContentAccess() async {
    setState(() => _isLoading = true);
    try {
      final value = await ServiceWorkerController.getAllowContentAccess();
      setState(() => _allowContentAccess = value);
      _recordMethodResult(
        PlatformServiceWorkerControllerMethod.getAllowContentAccess.name,
        'Allow content access: $value',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformServiceWorkerControllerMethod.getAllowContentAccess.name,
        'Error: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setAllowContentAccess(bool value) async {
    setState(() => _isLoading = true);
    try {
      await ServiceWorkerController.setAllowContentAccess(value);
      setState(() => _allowContentAccess = value);
      _recordMethodResult(
        PlatformServiceWorkerControllerMethod.setAllowContentAccess.name,
        'Allow content access set to: $value',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformServiceWorkerControllerMethod.setAllowContentAccess.name,
        'Error: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getAllowFileAccess() async {
    setState(() => _isLoading = true);
    try {
      final value = await ServiceWorkerController.getAllowFileAccess();
      setState(() => _allowFileAccess = value);
      _recordMethodResult(
        PlatformServiceWorkerControllerMethod.getAllowFileAccess.name,
        'Allow file access: $value',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformServiceWorkerControllerMethod.getAllowFileAccess.name,
        'Error: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setAllowFileAccess(bool value) async {
    setState(() => _isLoading = true);
    try {
      await ServiceWorkerController.setAllowFileAccess(value);
      setState(() => _allowFileAccess = value);
      _recordMethodResult(
        PlatformServiceWorkerControllerMethod.setAllowFileAccess.name,
        'Allow file access set to: $value',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformServiceWorkerControllerMethod.setAllowFileAccess.name,
        'Error: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getBlockNetworkLoads() async {
    setState(() => _isLoading = true);
    try {
      final value = await ServiceWorkerController.getBlockNetworkLoads();
      setState(() => _blockNetworkLoads = value);
      _recordMethodResult(
        PlatformServiceWorkerControllerMethod.getBlockNetworkLoads.name,
        'Block network loads: $value',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformServiceWorkerControllerMethod.getBlockNetworkLoads.name,
        'Error: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setBlockNetworkLoads(bool value) async {
    setState(() => _isLoading = true);
    try {
      await ServiceWorkerController.setBlockNetworkLoads(value);
      setState(() => _blockNetworkLoads = value);
      _recordMethodResult(
        PlatformServiceWorkerControllerMethod.setBlockNetworkLoads.name,
        'Block network loads set to: $value',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformServiceWorkerControllerMethod.setBlockNetworkLoads.name,
        'Error: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getCacheMode() async {
    setState(() => _isLoading = true);
    try {
      final value = await ServiceWorkerController.getCacheMode();
      setState(() => _cacheMode = value);
      _recordMethodResult(
        PlatformServiceWorkerControllerMethod.getCacheMode.name,
        'Cache mode: ${value?.name}',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformServiceWorkerControllerMethod.getCacheMode.name,
        'Error: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setCacheMode(CacheMode mode) async {
    setState(() => _isLoading = true);
    try {
      await ServiceWorkerController.setCacheMode(mode);
      setState(() => _cacheMode = mode);
      _recordMethodResult(
        PlatformServiceWorkerControllerMethod.setCacheMode.name,
        'Cache mode set to: ${mode.name}',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformServiceWorkerControllerMethod.setCacheMode.name,
        'Error: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ProxyController methods
  Future<void> _setProxyOverride() async {
    final params = await showParameterDialog(
      context: context,
      title: 'Set Proxy Override',
      parameters: {
        'host': _proxyHostController.text.trim(),
        'port': int.tryParse(_proxyPortController.text.trim()) ?? 8080,
        'bypassList': _bypassListController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      },
      requiredPaths: ['host', 'port'],
    );

    if (params == null) return;
    final host = params['host']?.toString() ?? '';
    final port = (params['port'] as num?)?.toInt() ?? 8080;
    final bypassList =
        (params['bypassList'] as List?)
            ?.map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];

    _proxyHostController.text = host;
    _proxyPortController.text = port.toString();
    _bypassListController.text = bypassList.join(', ');

    setState(() => _isLoading = true);
    try {
      await ProxyController.instance().setProxyOverride(
        settings: ProxySettings(
          proxyRules: [ProxyRule(url: '$host:$port')],
          bypassRules: bypassList,
        ),
      );
      _recordMethodResult(
        PlatformProxyControllerMethod.setProxyOverride.name,
        'Proxy override set',
        isError: false,
      );
      _logEvent(
        EventType.network,
        'Proxy set',
        data: {'host': host, 'port': port, 'bypassList': bypassList},
      );
    } catch (e) {
      _recordMethodResult(
        PlatformProxyControllerMethod.setProxyOverride.name,
        'Error: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearProxyOverride() async {
    setState(() => _isLoading = true);
    try {
      await ProxyController.instance().clearProxyOverride();
      _recordMethodResult(
        PlatformProxyControllerMethod.clearProxyOverride.name,
        'Proxy override cleared',
        isError: false,
      );
      _logEvent(EventType.network, 'Proxy cleared');
    } catch (e) {
      _recordMethodResult(
        PlatformProxyControllerMethod.clearProxyOverride.name,
        'Error: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // TracingController methods
  Future<void> _startTracing() async {
    final params = await showParameterDialog(
      context: context,
      title: 'Start Tracing',
      parameters: {
        'tracingMode': 'RECORD_CONTINUOUSLY',
        'categories': ['CATEGORIES_WEB_DEVELOPER'],
      },
      requiredPaths: ['tracingMode'],
    );

    if (params == null) return;
    final tracingMode = _parseTracingMode(params['tracingMode']?.toString());
    final categories = _parseTracingCategories(params['categories']);

    setState(() => _isLoading = true);
    try {
      await TracingController.instance().start(
        settings: TracingSettings(
          tracingMode: tracingMode,
          categories: categories,
        ),
      );
      setState(() => _isTracing = true);
      _recordMethodResult(
        PlatformTracingControllerMethod.start.name,
        'Tracing started',
        isError: false,
      );
      _logEvent(EventType.performance, 'Tracing started');
    } catch (e) {
      _recordMethodResult(
        PlatformTracingControllerMethod.start.name,
        'Error: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _stopTracing() async {
    setState(() => _isLoading = true);
    try {
      final result = await TracingController.instance().stop();
      setState(() => _isTracing = false);
      _recordMethodResult(
        PlatformTracingControllerMethod.stop.name,
        'Tracing stopped: $result',
        isError: false,
      );
      _logEvent(
        EventType.performance,
        'Tracing stopped',
        data: {'result': result},
      );
    } catch (e) {
      _recordMethodResult(
        PlatformTracingControllerMethod.stop.name,
        'Error: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkIsTracing() async {
    setState(() => _isLoading = true);
    try {
      final tracing = await TracingController.instance().isTracing();
      setState(() => _isTracing = tracing);
      _recordMethodResult(
        PlatformTracingControllerMethod.isTracing.name,
        'Is tracing: $tracing',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformTracingControllerMethod.isTracing.name,
        'Error: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // WebViewEnvironment methods
  Future<void> _createWebViewEnvironment() async {
    setState(() => _isLoading = true);
    try {
      await context.read<SettingsManager>().recreateEnvironment();
      _recordMethodResult(
        PlatformWebViewEnvironmentMethod.create.name,
        '$WebViewEnvironment created',
        isError: false,
      );
      _logEvent(EventType.ui, '$WebViewEnvironment created');
    } catch (e) {
      _recordMethodResult(
        PlatformWebViewEnvironmentMethod.create.name,
        'Error: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getAvailableVersion() async {
    setState(() => _isLoading = true);
    try {
      final version = await WebViewEnvironment.getAvailableVersion();
      setState(() => _availableVersion = version);
      _recordMethodResult(
        PlatformWebViewEnvironmentMethod.getAvailableVersion.name,
        'Available version: $version',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformWebViewEnvironmentMethod.getAvailableVersion.name,
        'Error: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _compareBrowserVersions() async {
    final params = await showParameterDialog(
      context: context,
      title: 'Compare Browser Versions',
      parameters: {'version1': '100.0.0.0', 'version2': '99.0.0.0'},
      requiredPaths: ['version1', 'version2'],
    );

    if (params == null) return;
    final version1 = params['version1']?.toString() ?? '';
    final version2 = params['version2']?.toString() ?? '';
    if (version1.isEmpty || version2.isEmpty) {
      _recordMethodResult(
        PlatformWebViewEnvironmentMethod.compareBrowserVersions.name,
        'Both versions are required',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await WebViewEnvironment.compareBrowserVersions(
        version1: version1,
        version2: version2,
      );
      _recordMethodResult(
        PlatformWebViewEnvironmentMethod.compareBrowserVersions.name,
        'Compare versions: $result (positive = v1 > v2, negative = v1 < v2)',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformWebViewEnvironmentMethod.compareBrowserVersions.name,
        'Error: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getProcessInfos() async {
    final environment = context.read<SettingsManager>().webViewEnvironment;
    if (environment == null) {
      _recordMethodResult(
        PlatformWebViewEnvironmentMethod.getProcessInfos.name,
        'Create or select $WebViewEnvironment first',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final infos = await environment.getProcessInfos();
      setState(() => _processInfos = infos);
      _recordMethodResult(
        PlatformWebViewEnvironmentMethod.getProcessInfos.name,
        'Found ${infos.length} processes',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformWebViewEnvironmentMethod.getProcessInfos.name,
        'Error: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getFailureReportFolderPath() async {
    final environment = context.read<SettingsManager>().webViewEnvironment;
    if (environment == null) {
      _recordMethodResult(
        PlatformWebViewEnvironmentMethod.getFailureReportFolderPath.name,
        'Create or select $WebViewEnvironment first',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final path = await environment.getFailureReportFolderPath();
      _recordMethodResult(
        PlatformWebViewEnvironmentMethod.getFailureReportFolderPath.name,
        'Failure report folder: $path',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformWebViewEnvironmentMethod.getFailureReportFolderPath.name,
        'Error: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _disposeWebViewEnvironment() async {
    setState(() => _isLoading = true);
    try {
      await context.read<SettingsManager>().disposeEnvironment();
      setState(() => _processInfos = []);
      _recordMethodResult(
        PlatformWebViewEnvironmentMethod.dispose.name,
        '$WebViewEnvironment disposed',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformWebViewEnvironmentMethod.dispose.name,
        'Error: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ProcessGlobalConfig methods
  Future<void> _applyProcessGlobalConfig() async {
    final params = await showParameterDialog(
      context: context,
      title: 'Apply Process Global Config',
      parameters: {'dataDirectorySuffix': _dataDirSuffixController.text.trim()},
      requiredPaths: ['dataDirectorySuffix'],
    );

    if (params == null) return;
    final suffix = params['dataDirectorySuffix']?.toString() ?? '';
    if (suffix.isEmpty) {
      _recordMethodResult(
        PlatformProcessGlobalConfigMethod.apply.name,
        'Please enter a data directory suffix',
        isError: true,
      );
      return;
    }
    _dataDirSuffixController.text = suffix;

    setState(() => _isLoading = true);
    try {
      await ProcessGlobalConfig.instance().apply(
        settings: ProcessGlobalConfigSettings(dataDirectorySuffix: suffix),
      );
      _recordMethodResult(
        PlatformProcessGlobalConfigMethod.apply.name,
        '$ProcessGlobalConfig applied',
        isError: false,
      );
      _logEvent(
        EventType.ui,
        '$ProcessGlobalConfig applied',
        data: {'dataDirectorySuffix': suffix},
      );
    } catch (e) {
      _recordMethodResult(
        PlatformProcessGlobalConfigMethod.apply.name,
        'Error: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Controllers'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear Events',
            onPressed: () {
              context.read<EventLogProvider>().clear();
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProfileSelectorCard(
            onEditSettingsProfile: () =>
                Navigator.pushNamed(context, '/settings'),
          ),
          const SizedBox(height: 16),
          _buildServiceWorkerSection(),
          const SizedBox(height: 16),
          _buildProxyControllerSection(),
          const SizedBox(height: 16),
          _buildTracingControllerSection(),
          const SizedBox(height: 16),
          _buildWebViewEnvironmentSection(),
          const SizedBox(height: 16),
          _buildProcessGlobalConfigSection(),
          const SizedBox(height: 16),
          _buildEventLog(),
        ],
      ),
    );
  }

  Widget _buildServiceWorkerSection() {
    final supportedPlatforms = SupportChecker.getSupportedPlatformsForClass(
      '$ServiceWorkerController',
    );

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              '$ServiceWorkerController',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SupportBadgesRow(
                  supportedPlatforms: supportedPlatforms,
                  compact: true,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Boolean settings
                _buildSwitchRow(
                  'Allow Content Access',
                  _allowContentAccess,
                  (value) => _setAllowContentAccess(value),
                  _getAllowContentAccess,
                  _mergePlatforms(
                    _serviceWorkerPlatforms(
                      PlatformServiceWorkerControllerMethod
                          .getAllowContentAccess,
                    ),
                    _serviceWorkerPlatforms(
                      PlatformServiceWorkerControllerMethod
                          .setAllowContentAccess,
                    ),
                  ),
                  getMethodName: PlatformServiceWorkerControllerMethod
                      .getAllowContentAccess
                      .name,
                  setMethodName: PlatformServiceWorkerControllerMethod
                      .setAllowContentAccess
                      .name,
                ),
                _buildSwitchRow(
                  'Allow File Access',
                  _allowFileAccess,
                  (value) => _setAllowFileAccess(value),
                  _getAllowFileAccess,
                  _mergePlatforms(
                    _serviceWorkerPlatforms(
                      PlatformServiceWorkerControllerMethod.getAllowFileAccess,
                    ),
                    _serviceWorkerPlatforms(
                      PlatformServiceWorkerControllerMethod.setAllowFileAccess,
                    ),
                  ),
                  getMethodName: PlatformServiceWorkerControllerMethod
                      .getAllowFileAccess
                      .name,
                  setMethodName: PlatformServiceWorkerControllerMethod
                      .setAllowFileAccess
                      .name,
                ),
                _buildSwitchRow(
                  'Block Network Loads',
                  _blockNetworkLoads,
                  (value) => _setBlockNetworkLoads(value),
                  _getBlockNetworkLoads,
                  _mergePlatforms(
                    _serviceWorkerPlatforms(
                      PlatformServiceWorkerControllerMethod
                          .getBlockNetworkLoads,
                    ),
                    _serviceWorkerPlatforms(
                      PlatformServiceWorkerControllerMethod
                          .setBlockNetworkLoads,
                    ),
                  ),
                  getMethodName: PlatformServiceWorkerControllerMethod
                      .getBlockNetworkLoads
                      .name,
                  setMethodName: PlatformServiceWorkerControllerMethod
                      .setBlockNetworkLoads
                      .name,
                ),
                const Divider(),

                // Cache mode dropdown
                Row(
                  children: [
                    const Text('Cache Mode:'),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButton<CacheMode>(
                        value: _cacheMode,
                        isExpanded: true,
                        items: CacheMode.values
                            .map(
                              (mode) => DropdownMenuItem(
                                value: mode,
                                child: Text(
                                  mode.name(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (mode) {
                          if (mode != null) {
                            _setCacheMode(mode);
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: _getCacheMode,
                      tooltip: 'Get current',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SupportBadgesRow(
                  supportedPlatforms: _mergePlatforms(
                    _serviceWorkerPlatforms(
                      PlatformServiceWorkerControllerMethod.getCacheMode,
                    ),
                    _serviceWorkerPlatforms(
                      PlatformServiceWorkerControllerMethod.setCacheMode,
                    ),
                  ),
                  compact: true,
                ),
                const SizedBox(height: 6),
                _buildMethodHistory(
                  PlatformServiceWorkerControllerMethod.getCacheMode.name,
                  title:
                      PlatformServiceWorkerControllerMethod.getCacheMode.name,
                ),
                _buildMethodHistory(
                  PlatformServiceWorkerControllerMethod.setCacheMode.name,
                  title:
                      PlatformServiceWorkerControllerMethod.setCacheMode.name,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
    String label,
    bool value,
    Function(bool) onChanged,
    VoidCallback onRefresh,
    Set<SupportedPlatform> supportedPlatforms, {
    required String getMethodName,
    required String setMethodName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = ResponsiveBreakpoints.isMobileWidth(
              constraints.maxWidth,
            );
            final controls = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(value: value, onChanged: onChanged),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: onRefresh,
                  tooltip: 'Get current',
                ),
              ],
            );

            return ResponsiveRow(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                isMobile ? Text(label) : Expanded(child: Text(label)),
                controls,
              ],
            );
          },
        ),
        SupportBadgesRow(supportedPlatforms: supportedPlatforms, compact: true),
        const SizedBox(height: 6),
        _buildMethodHistory(setMethodName, title: setMethodName),
        _buildMethodHistory(getMethodName, title: getMethodName),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildProxyControllerSection() {
    final supportedPlatforms = SupportChecker.getSupportedPlatformsForClass(
      '$ProxyController',
    );

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              '$ProxyController',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SupportBadgesRow(
                  supportedPlatforms: supportedPlatforms,
                  compact: true,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = ResponsiveBreakpoints.isMobileWidth(
                      constraints.maxWidth,
                    );
                    final hostField = TextField(
                      controller: _proxyHostController,
                      decoration: const InputDecoration(
                        labelText: 'Host',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    );
                    final portField = TextField(
                      controller: _proxyPortController,
                      decoration: const InputDecoration(
                        labelText: 'Port',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                    );

                    return ResponsiveRow(
                      rowKey: const Key('service_controllers_proxy_row'),
                      columnKey: const Key('service_controllers_proxy_column'),
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isMobile
                            ? hostField
                            : Expanded(flex: 2, child: hostField),
                        isMobile ? portField : Expanded(child: portField),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bypassListController,
                  decoration: const InputDecoration(
                    labelText: 'Bypass List (comma-separated)',
                    hintText: 'localhost, 127.0.0.1',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = ResponsiveBreakpoints.isMobileWidth(
                      constraints.maxWidth,
                    );
                    final setButton = _buildMethodButton(
                      'Set Proxy',
                      _setProxyOverride,
                      supportedPlatforms: _proxyControllerPlatforms(
                        PlatformProxyControllerMethod.setProxyOverride,
                      ),
                      methodName:
                          PlatformProxyControllerMethod.setProxyOverride.name,
                    );
                    final clearButton = _buildMethodButton(
                      'Clear Proxy',
                      _clearProxyOverride,
                      supportedPlatforms: _proxyControllerPlatforms(
                        PlatformProxyControllerMethod.clearProxyOverride,
                      ),
                      methodName:
                          PlatformProxyControllerMethod.clearProxyOverride.name,
                    );

                    return ResponsiveRow(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isMobile ? setButton : Expanded(child: setButton),
                        isMobile ? clearButton : Expanded(child: clearButton),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTracingControllerSection() {
    final supportedPlatforms = SupportChecker.getSupportedPlatformsForClass(
      '$TracingController',
    );

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              '$TracingController',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SupportBadgesRow(
                  supportedPlatforms: supportedPlatforms,
                  compact: true,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Status indicator
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isTracing
                        ? Colors.green.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isTracing ? Icons.fiber_manual_record : Icons.stop,
                        color: _isTracing ? Colors.red : Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isTracing ? 'Tracing Active' : 'Tracing Stopped',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isTracing ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Control buttons
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = ResponsiveBreakpoints.isMobileWidth(
                      constraints.maxWidth,
                    );
                    final startButton = _buildMethodButton(
                      'Start',
                      !_isTracing ? _startTracing : null,
                      supportedPlatforms: _tracingControllerPlatforms(
                        PlatformTracingControllerMethod.start,
                      ),
                      methodName: PlatformTracingControllerMethod.start.name,
                    );
                    final stopButton = _buildMethodButton(
                      'Stop',
                      _isTracing ? _stopTracing : null,
                      supportedPlatforms: _tracingControllerPlatforms(
                        PlatformTracingControllerMethod.stop,
                      ),
                      methodName: PlatformTracingControllerMethod.stop.name,
                    );
                    final statusButton = _buildMethodButton(
                      'Is Tracing',
                      _checkIsTracing,
                      supportedPlatforms: _tracingControllerPlatforms(
                        PlatformTracingControllerMethod.isTracing,
                      ),
                      methodName:
                          PlatformTracingControllerMethod.isTracing.name,
                    );

                    return ResponsiveRow(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isMobile ? startButton : Expanded(child: startButton),
                        isMobile ? stopButton : Expanded(child: stopButton),
                        isMobile ? statusButton : Expanded(child: statusButton),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebViewEnvironmentSection() {
    final settingsManager = context.watch<SettingsManager>();
    final environment = settingsManager.webViewEnvironment;
    final supportedPlatforms = SupportChecker.getSupportedPlatformsForClass(
      '$WebViewEnvironment',
    );

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              '$WebViewEnvironment',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SupportBadgesRow(
                  supportedPlatforms: supportedPlatforms,
                  compact: true,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Environment status
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: environment != null
                        ? Colors.green.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        environment != null ? Icons.check_circle : Icons.cancel,
                        color: environment != null ? Colors.green : Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              environment != null
                                  ? 'Environment Active'
                                  : 'No Environment',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (environment != null)
                              Text(
                                'ID: ${environment.id}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            if (_availableVersion != null)
                              Text(
                                'Version: $_availableVersion',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Create/Dispose buttons
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = ResponsiveBreakpoints.isMobileWidth(
                      constraints.maxWidth,
                    );
                    final createButton = _buildMethodButton(
                      'Create',
                      environment == null ? _createWebViewEnvironment : null,
                      supportedPlatforms: _webViewEnvironmentPlatforms(
                        PlatformWebViewEnvironmentMethod.create,
                      ),
                      methodName: PlatformWebViewEnvironmentMethod.create.name,
                    );
                    final disposeButton = _buildMethodButton(
                      'Dispose',
                      environment != null ? _disposeWebViewEnvironment : null,
                      supportedPlatforms: _webViewEnvironmentPlatforms(
                        PlatformWebViewEnvironmentMethod.dispose,
                      ),
                      methodName: PlatformWebViewEnvironmentMethod.dispose.name,
                    );

                    return ResponsiveRow(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isMobile ? createButton : Expanded(child: createButton),
                        isMobile
                            ? disposeButton
                            : Expanded(child: disposeButton),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),

                // Static methods
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = ResponsiveBreakpoints.isMobileWidth(
                      constraints.maxWidth,
                    );
                    final versionButton = _buildMethodButton(
                      'Get Version',
                      _getAvailableVersion,
                      supportedPlatforms: _webViewEnvironmentPlatforms(
                        PlatformWebViewEnvironmentMethod.getAvailableVersion,
                      ),
                      methodName: PlatformWebViewEnvironmentMethod
                          .getAvailableVersion
                          .name,
                    );
                    final compareButton = _buildMethodButton(
                      'Compare Versions',
                      _compareBrowserVersions,
                      supportedPlatforms: _webViewEnvironmentPlatforms(
                        PlatformWebViewEnvironmentMethod.compareBrowserVersions,
                      ),
                      methodName: PlatformWebViewEnvironmentMethod
                          .compareBrowserVersions
                          .name,
                    );

                    return ResponsiveRow(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isMobile
                            ? versionButton
                            : Expanded(child: versionButton),
                        isMobile
                            ? compareButton
                            : Expanded(child: compareButton),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),

                // Instance methods
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = ResponsiveBreakpoints.isMobileWidth(
                      constraints.maxWidth,
                    );
                    final processesButton = _buildMethodButton(
                      'Get Processes',
                      environment != null ? _getProcessInfos : null,
                      supportedPlatforms: _webViewEnvironmentPlatforms(
                        PlatformWebViewEnvironmentMethod.getProcessInfos,
                      ),
                      methodName:
                          PlatformWebViewEnvironmentMethod.getProcessInfos.name,
                    );
                    final failureButton = _buildMethodButton(
                      'Failure Folder',
                      environment != null ? _getFailureReportFolderPath : null,
                      supportedPlatforms: _webViewEnvironmentPlatforms(
                        PlatformWebViewEnvironmentMethod
                            .getFailureReportFolderPath,
                      ),
                      methodName: PlatformWebViewEnvironmentMethod
                          .getFailureReportFolderPath
                          .name,
                    );

                    return ResponsiveRow(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isMobile
                            ? processesButton
                            : Expanded(child: processesButton),
                        isMobile
                            ? failureButton
                            : Expanded(child: failureButton),
                      ],
                    );
                  },
                ),

                // Process list
                if (_processInfos.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Process Infos:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListView.builder(
                      itemCount: _processInfos.length,
                      itemBuilder: (context, index) {
                        final info = _processInfos[index];
                        return ListTile(
                          dense: true,
                          title: Text('Process ${index + 1}'),
                          subtitle: Text('Kind: ${info.kind.name()}'),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessGlobalConfigSection() {
    final supportedPlatforms = SupportChecker.getSupportedPlatformsForClass(
      '$ProcessGlobalConfig',
    );

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              '$ProcessGlobalConfig',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SupportBadgesRow(
                  supportedPlatforms: supportedPlatforms,
                  compact: true,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = ResponsiveBreakpoints.isMobileWidth(
                        constraints.maxWidth,
                      );
                      final noteText = Text(
                        'Note: $ProcessGlobalConfig can only be applied once, before any WebView is created.',
                        style: const TextStyle(fontSize: 12),
                      );

                      return ResponsiveRow(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning,
                            color: Colors.orange,
                            size: 20,
                          ),
                          isMobile ? noteText : Expanded(child: noteText),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _dataDirSuffixController,
                  decoration: const InputDecoration(
                    labelText: 'Data Directory Suffix',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _buildMethodButton(
                    'Apply Config',
                    _applyProcessGlobalConfig,
                    supportedPlatforms: _processGlobalConfigPlatforms(
                      PlatformProcessGlobalConfigMethod.apply,
                    ),
                    methodName: PlatformProcessGlobalConfigMethod.apply.name,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodButton(
    String label,
    VoidCallback? onPressed, {
    Set<SupportedPlatform>? supportedPlatforms,
    String? methodName,
  }) {
    final canPress = onPressed != null && !_isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: canPress ? onPressed : null,
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
        if (supportedPlatforms != null) ...[
          const SizedBox(height: 6),
          SupportBadgesRow(
            supportedPlatforms: supportedPlatforms,
            compact: true,
          ),
        ],
        if (methodName != null) ...[
          const SizedBox(height: 6),
          _buildMethodHistory(methodName, title: methodName),
        ],
      ],
    );
  }

  Widget _buildEventLog() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Event Log',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.read<EventLogProvider>().clear(),
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Consumer<EventLogProvider>(
              builder: (context, provider, _) {
                final events = provider.events.reversed.take(15).toList();
                if (events.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: Text(
                        'No events yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                return Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return ListTile(
                        dense: true,
                        title: Text(
                          event.message,
                          style: const TextStyle(fontSize: 12),
                        ),
                        subtitle: Text(
                          event.data?.toString() ?? '',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: Text(
                          '${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}:${event.timestamp.second.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
