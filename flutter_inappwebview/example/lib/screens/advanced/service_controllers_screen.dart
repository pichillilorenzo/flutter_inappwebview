import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/providers/event_log_provider.dart';
import 'package:flutter_inappwebview_example/models/event_log_entry.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';
import 'package:flutter_inappwebview_example/widgets/common/support_badge.dart';
import 'package:flutter_inappwebview_example/widgets/common/parameter_dialog.dart';

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
  WebViewEnvironment? _webViewEnvironment;
  String? _availableVersion;
  List<BrowserProcessInfo> _processInfos = [];

  // ProcessGlobalConfig state
  final TextEditingController _dataDirSuffixController = TextEditingController(
    text: 'test_suffix',
  );

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
    _webViewEnvironment?.dispose();
    super.dispose();
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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
      _showSuccess('Allow content access: $value');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setAllowContentAccess(bool value) async {
    setState(() => _isLoading = true);
    try {
      await ServiceWorkerController.setAllowContentAccess(value);
      setState(() => _allowContentAccess = value);
      _showSuccess('Allow content access set to: $value');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getAllowFileAccess() async {
    setState(() => _isLoading = true);
    try {
      final value = await ServiceWorkerController.getAllowFileAccess();
      setState(() => _allowFileAccess = value);
      _showSuccess('Allow file access: $value');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setAllowFileAccess(bool value) async {
    setState(() => _isLoading = true);
    try {
      await ServiceWorkerController.setAllowFileAccess(value);
      setState(() => _allowFileAccess = value);
      _showSuccess('Allow file access set to: $value');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getBlockNetworkLoads() async {
    setState(() => _isLoading = true);
    try {
      final value = await ServiceWorkerController.getBlockNetworkLoads();
      setState(() => _blockNetworkLoads = value);
      _showSuccess('Block network loads: $value');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setBlockNetworkLoads(bool value) async {
    setState(() => _isLoading = true);
    try {
      await ServiceWorkerController.setBlockNetworkLoads(value);
      setState(() => _blockNetworkLoads = value);
      _showSuccess('Block network loads set to: $value');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getCacheMode() async {
    setState(() => _isLoading = true);
    try {
      final value = await ServiceWorkerController.getCacheMode();
      setState(() => _cacheMode = value);
      _showSuccess('Cache mode: ${value?.name}');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setCacheMode(CacheMode mode) async {
    setState(() => _isLoading = true);
    try {
      await ServiceWorkerController.setCacheMode(mode);
      setState(() => _cacheMode = mode);
      _showSuccess('Cache mode set to: ${mode.name}');
    } catch (e) {
      _showError('Error: $e');
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
      _showSuccess('Proxy override set');
      _logEvent(
        EventType.network,
        'Proxy set',
        data: {'host': host, 'port': port, 'bypassList': bypassList},
      );
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearProxyOverride() async {
    setState(() => _isLoading = true);
    try {
      await ProxyController.instance().clearProxyOverride();
      _showSuccess('Proxy override cleared');
      _logEvent(EventType.network, 'Proxy cleared');
    } catch (e) {
      _showError('Error: $e');
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
      _showSuccess('Tracing started');
      _logEvent(EventType.performance, 'Tracing started');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _stopTracing() async {
    setState(() => _isLoading = true);
    try {
      final result = await TracingController.instance().stop();
      setState(() => _isTracing = false);
      _showSuccess('Tracing stopped: $result');
      _logEvent(
        EventType.performance,
        'Tracing stopped',
        data: {'result': result},
      );
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkIsTracing() async {
    setState(() => _isLoading = true);
    try {
      final tracing = await TracingController.instance().isTracing();
      setState(() => _isTracing = tracing);
      _showSuccess('Is tracing: $tracing');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // WebViewEnvironment methods
  Future<void> _createWebViewEnvironment() async {
    final params = await showParameterDialog(
      context: context,
      title: 'Create WebViewEnvironment',
      parameters: {'userDataFolder': 'custom_env_folder'},
    );

    if (params == null) return;
    final userDataFolder = params['userDataFolder']?.toString();

    setState(() => _isLoading = true);
    try {
      _webViewEnvironment = await WebViewEnvironment.create(
        settings: WebViewEnvironmentSettings(
          userDataFolder: userDataFolder?.isNotEmpty == true
              ? userDataFolder
              : null,
        ),
      );
      _showSuccess('WebViewEnvironment created: ${_webViewEnvironment?.id}');
      _logEvent(
        EventType.ui,
        'WebViewEnvironment created',
        data: {'id': _webViewEnvironment?.id},
      );
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getAvailableVersion() async {
    setState(() => _isLoading = true);
    try {
      final version = await WebViewEnvironment.getAvailableVersion();
      setState(() => _availableVersion = version);
      _showSuccess('Available version: $version');
    } catch (e) {
      _showError('Error: $e');
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
      _showError('Both versions are required');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await WebViewEnvironment.compareBrowserVersions(
        version1: version1,
        version2: version2,
      );
      _showSuccess(
        'Compare versions: $result (positive = v1 > v2, negative = v1 < v2)',
      );
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getProcessInfos() async {
    if (_webViewEnvironment == null) {
      _showError('Create WebViewEnvironment first');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final infos = await _webViewEnvironment!.getProcessInfos();
      setState(() => _processInfos = infos);
      _showSuccess('Found ${infos.length} processes');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getFailureReportFolderPath() async {
    if (_webViewEnvironment == null) {
      _showError('Create WebViewEnvironment first');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final path = await _webViewEnvironment!.getFailureReportFolderPath();
      _showSuccess('Failure report folder: $path');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _disposeWebViewEnvironment() async {
    setState(() => _isLoading = true);
    try {
      await _webViewEnvironment?.dispose();
      _webViewEnvironment = null;
      setState(() => _processInfos = []);
      _showSuccess('WebViewEnvironment disposed');
    } catch (e) {
      _showError('Error: $e');
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
      _showError('Please enter a data directory suffix');
      return;
    }
    _dataDirSuffixController.text = suffix;

    setState(() => _isLoading = true);
    try {
      await ProcessGlobalConfig.instance().apply(
        settings: ProcessGlobalConfigSettings(dataDirectorySuffix: suffix),
      );
      _showSuccess('ProcessGlobalConfig applied');
      _logEvent(
        EventType.ui,
        'ProcessGlobalConfig applied',
        data: {'dataDirectorySuffix': suffix},
      );
    } catch (e) {
      _showError('Error: $e');
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
      drawer: buildDrawer(context: context),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
      'ServiceWorkerController',
    );

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            const Text(
              'ServiceWorkerController',
              style: TextStyle(fontWeight: FontWeight.bold),
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
    Set<SupportedPlatform> supportedPlatforms,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Switch(value: value, onChanged: onChanged),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: onRefresh,
              tooltip: 'Get current',
            ),
          ],
        ),
        SupportBadgesRow(supportedPlatforms: supportedPlatforms, compact: true),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildProxyControllerSection() {
    final supportedPlatforms = SupportChecker.getSupportedPlatformsForClass(
      'ProxyController',
    );

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            const Text(
              'ProxyController',
              style: TextStyle(fontWeight: FontWeight.bold),
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
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _proxyHostController,
                        decoration: const InputDecoration(
                          labelText: 'Host',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _proxyPortController,
                        decoration: const InputDecoration(
                          labelText: 'Port',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
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
                Row(
                  children: [
                    Expanded(
                      child: _buildMethodButton(
                        'Set Proxy',
                        _setProxyOverride,
                        supportedPlatforms: _proxyControllerPlatforms(
                          PlatformProxyControllerMethod.setProxyOverride,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMethodButton(
                        'Clear Proxy',
                        _clearProxyOverride,
                        supportedPlatforms: _proxyControllerPlatforms(
                          PlatformProxyControllerMethod.clearProxyOverride,
                        ),
                      ),
                    ),
                  ],
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
      'TracingController',
    );

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            const Text(
              'TracingController',
              style: TextStyle(fontWeight: FontWeight.bold),
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
                Row(
                  children: [
                    Expanded(
                      child: _buildMethodButton(
                        'Start',
                        !_isTracing ? _startTracing : null,
                        supportedPlatforms: _tracingControllerPlatforms(
                          PlatformTracingControllerMethod.start,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMethodButton(
                        'Stop',
                        _isTracing ? _stopTracing : null,
                        supportedPlatforms: _tracingControllerPlatforms(
                          PlatformTracingControllerMethod.stop,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMethodButton(
                        'Is Tracing',
                        _checkIsTracing,
                        supportedPlatforms: _tracingControllerPlatforms(
                          PlatformTracingControllerMethod.isTracing,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebViewEnvironmentSection() {
    final supportedPlatforms = SupportChecker.getSupportedPlatformsForClass(
      'WebViewEnvironment',
    );

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            const Text(
              'WebViewEnvironment',
              style: TextStyle(fontWeight: FontWeight.bold),
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
                    color: _webViewEnvironment != null
                        ? Colors.green.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _webViewEnvironment != null
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: _webViewEnvironment != null
                            ? Colors.green
                            : Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _webViewEnvironment != null
                                  ? 'Environment Active'
                                  : 'No Environment',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_webViewEnvironment != null)
                              Text(
                                'ID: ${_webViewEnvironment!.id}',
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
                Row(
                  children: [
                    Expanded(
                      child: _buildMethodButton(
                        'Create',
                        _webViewEnvironment == null
                            ? _createWebViewEnvironment
                            : null,
                        supportedPlatforms: _webViewEnvironmentPlatforms(
                          PlatformWebViewEnvironmentMethod.create,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMethodButton(
                        'Dispose',
                        _webViewEnvironment != null
                            ? _disposeWebViewEnvironment
                            : null,
                        supportedPlatforms: _webViewEnvironmentPlatforms(
                          PlatformWebViewEnvironmentMethod.dispose,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Static methods
                Row(
                  children: [
                    Expanded(
                      child: _buildMethodButton(
                        'Get Version',
                        _getAvailableVersion,
                        supportedPlatforms: _webViewEnvironmentPlatforms(
                          PlatformWebViewEnvironmentMethod.getAvailableVersion,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMethodButton(
                        'Compare Versions',
                        _compareBrowserVersions,
                        supportedPlatforms: _webViewEnvironmentPlatforms(
                          PlatformWebViewEnvironmentMethod
                              .compareBrowserVersions,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Instance methods
                Row(
                  children: [
                    Expanded(
                      child: _buildMethodButton(
                        'Get Processes',
                        _webViewEnvironment != null ? _getProcessInfos : null,
                        supportedPlatforms: _webViewEnvironmentPlatforms(
                          PlatformWebViewEnvironmentMethod.getProcessInfos,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMethodButton(
                        'Failure Folder',
                        _webViewEnvironment != null
                            ? _getFailureReportFolderPath
                            : null,
                        supportedPlatforms: _webViewEnvironmentPlatforms(
                          PlatformWebViewEnvironmentMethod
                              .getFailureReportFolderPath,
                        ),
                      ),
                    ),
                  ],
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
      'ProcessGlobalConfig',
    );

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            const Text(
              'ProcessGlobalConfig',
              style: TextStyle(fontWeight: FontWeight.bold),
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
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Note: ProcessGlobalConfig can only be applied once, before any WebView is created.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
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
