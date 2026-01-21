import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/widgets/common/app_drawer.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';
import 'package:flutter_inappwebview_example/widgets/common/support_badge.dart';
import 'package:flutter_inappwebview_example/widgets/common/parameter_dialog.dart';
import 'package:flutter_inappwebview_example/widgets/common/method_result_history.dart';
import 'package:flutter_inappwebview_example/widgets/common/responsive_row.dart';
import 'package:flutter_inappwebview_example/utils/responsive_utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/providers/event_log_provider.dart';
import 'package:flutter_inappwebview_example/models/event_log_entry.dart';
import 'package:flutter_inappwebview_example/providers/settings_manager.dart';
import 'package:flutter_inappwebview_example/widgets/common/profile_selector_card.dart';

/// Screen for testing HeadlessInAppWebView functionality
class HeadlessWebViewScreen extends StatefulWidget {
  const HeadlessWebViewScreen({super.key});

  @override
  State<HeadlessWebViewScreen> createState() => _HeadlessWebViewScreenState();
}

class _HeadlessWebViewScreenState extends State<HeadlessWebViewScreen> {
  final TextEditingController _urlController = TextEditingController(
    text: 'https://flutter.dev',
  );
  final TextEditingController _widthController = TextEditingController(
    text: '1024',
  );
  final TextEditingController _heightController = TextEditingController(
    text: '768',
  );

  HeadlessInAppWebView? _headlessWebView;
  InAppWebViewController? _webViewController;
  bool _isLoading = false;
  bool _isRunning = false;
  Size? _currentSize;
  Uint8List? _screenshotData;
  String? _currentUrl;
  String? _currentTitle;
  bool _isInitialized = false;
  int _lastEnvironmentRevision = -1;

  final Map<String, List<MethodResultEntry>> _methodHistory = {};
  final Map<String, int> _selectedHistoryIndex = {};
  static const int _maxHistoryEntries = 3;

  @override
  void dispose() {
    _urlController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _headlessWebView?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settingsManager = context.watch<SettingsManager>();

    if (!_isInitialized) {
      _isInitialized = true;
      _lastEnvironmentRevision = settingsManager.environmentRevision;
      return;
    }

    if (_lastEnvironmentRevision != settingsManager.environmentRevision) {
      _lastEnvironmentRevision = settingsManager.environmentRevision;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resetForEnvironmentChange();
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

  bool _createHeadlessWebView({
    required String url,
    required double width,
    required double height,
    bool javaScriptEnabled = true,
    required SettingsManager settingsManager,
  }) {
    if (url.isEmpty) {
      _recordMethodResult(
        PlatformHeadlessInAppWebViewMethod.run.name,
        'Please enter a URL',
        isError: true,
      );
      return false;
    }
    try {
      final baseSettings = settingsManager.buildSettings();
      final mergedSettings =
          InAppWebViewSettings.fromMap({
            ...baseSettings.toMap(),
            'javaScriptEnabled': javaScriptEnabled,
          }) ??
          InAppWebViewSettings();
      _headlessWebView = HeadlessInAppWebView(
        initialSize: Size(width, height),
        initialUrlRequest: URLRequest(url: WebUri(url)),
        webViewEnvironment: settingsManager.webViewEnvironment,
        initialSettings: mergedSettings,
        onWebViewCreated: (controller) {
          _webViewController = controller;
          _logEvent(
            EventType.ui,
            PlatformWebViewCreationParamsProperty.onWebViewCreated.name,
            data: {'viewId': controller.getViewId()},
          );
        },
        onLoadStart: (controller, url) {
          _logEvent(
            EventType.navigation,
            PlatformWebViewCreationParamsProperty.onLoadStart.name,
            data: {'url': url?.toString()},
          );
          setState(() => _currentUrl = url?.toString());
        },
        onLoadStop: (controller, url) async {
          _logEvent(
            EventType.navigation,
            PlatformWebViewCreationParamsProperty.onLoadStop.name,
            data: {'url': url?.toString()},
          );
          final title = await controller.getTitle();
          setState(() {
            _currentUrl = url?.toString();
            _currentTitle = title;
          });
        },
        onReceivedError: (controller, request, error) {
          _logEvent(
            EventType.error,
            PlatformWebViewCreationParamsProperty.onReceivedError.name,
            data: {
              'url': request.url.toString(),
              'errorType': error.type.name(),
              'description': error.description,
            },
          );
        },
        onProgressChanged: (controller, progress) {
          _logEvent(
            EventType.performance,
            PlatformWebViewCreationParamsProperty.onProgressChanged.name,
            data: {'progress': progress},
          );
        },
        onConsoleMessage: (controller, consoleMessage) {
          _logEvent(
            EventType.console,
            PlatformWebViewCreationParamsProperty.onConsoleMessage.name,
            data: {
              'message': consoleMessage.message,
              'level': consoleMessage.messageLevel.name(),
            },
          );
        },
        onTitleChanged: (controller, title) {
          _logEvent(
            EventType.ui,
            PlatformWebViewCreationParamsProperty.onTitleChanged.name,
            data: {'title': title},
          );
          setState(() => _currentTitle = title);
        },
      );
    } catch (e) {
      _recordMethodResult(
        PlatformHeadlessInAppWebViewMethod.run.name,
        'Error creating $HeadlessInAppWebView: $e',
        isError: true,
      );
      return false;
    }
    return true;
  }

  Future<void> _run() async {
    final settingsManager = context.read<SettingsManager>();

    // Use the values from the inline form instead of showing a dialog
    final url = _urlController.text.trim();
    final width = double.tryParse(_widthController.text) ?? 1024;
    final height = double.tryParse(_heightController.text) ?? 768;

    if (url.isEmpty) {
      _recordMethodResult(
        PlatformHeadlessInAppWebViewMethod.run.name,
        'Please enter a URL',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final created = _createHeadlessWebView(
        url: url,
        width: width,
        height: height,
        javaScriptEnabled: true,
        settingsManager: settingsManager,
      );
      if (!created) return;
      await _headlessWebView?.run();
      setState(() => _isRunning = _headlessWebView?.isRunning() ?? false);
      _recordMethodResult(
        PlatformHeadlessInAppWebViewMethod.run.name,
        '$HeadlessInAppWebView started',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformHeadlessInAppWebViewMethod.run.name,
        'Error starting $HeadlessInAppWebView: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _checkIsRunning() {
    final running = _headlessWebView?.isRunning() ?? false;
    setState(() => _isRunning = running);
    _recordMethodResult(
      PlatformHeadlessInAppWebViewMethod.isRunning.name,
      '$HeadlessInAppWebView is running: $running',
      isError: false,
    );
  }

  Future<void> _setSize() async {
    final params = await showParameterDialog(
      context: context,
      title: 'Set Size',
      parameters: {
        'width': double.tryParse(_widthController.text) ?? 1024,
        'height': double.tryParse(_heightController.text) ?? 768,
      },
      requiredPaths: ['width', 'height'],
    );

    if (params == null) return;
    final width = (params['width'] as num?)?.toDouble();
    final height = (params['height'] as num?)?.toDouble();
    if (width == null || height == null) {
      _recordMethodResult(
        PlatformHeadlessInAppWebViewMethod.setSize.name,
        'Please enter valid width and height',
        isError: true,
      );
      return;
    }
    _widthController.text = width.toString();
    _heightController.text = height.toString();

    setState(() => _isLoading = true);
    try {
      await _headlessWebView?.setSize(Size(width, height));
      _recordMethodResult(
        PlatformHeadlessInAppWebViewMethod.setSize.name,
        'Size set to ${width}x$height',
        isError: false,
      );
      await _getSize();
    } catch (e) {
      _recordMethodResult(
        PlatformHeadlessInAppWebViewMethod.setSize.name,
        'Error setting size: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getSize() async {
    setState(() => _isLoading = true);
    try {
      final size = await _headlessWebView?.getSize();
      setState(() => _currentSize = size);
      _recordMethodResult(
        PlatformHeadlessInAppWebViewMethod.getSize.name,
        'Current size: ${size?.width}x${size?.height}',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformHeadlessInAppWebViewMethod.getSize.name,
        'Error getting size: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _dispose() async {
    setState(() => _isLoading = true);
    try {
      await _headlessWebView?.dispose();
      setState(() {
        _isRunning = false;
        _currentSize = null;
        _screenshotData = null;
        _currentUrl = null;
        _currentTitle = null;
      });
      _headlessWebView = null;
      _webViewController = null;
      _recordMethodResult(
        PlatformHeadlessInAppWebViewMethod.dispose.name,
        '$HeadlessInAppWebView disposed',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformHeadlessInAppWebViewMethod.dispose.name,
        'Error disposing: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _takeScreenshot() async {
    if (_webViewController == null) {
      _recordMethodResult(
        PlatformInAppWebViewControllerMethod.takeScreenshot.name,
        'WebView not initialized',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final screenshot = await _webViewController?.takeScreenshot();
      setState(() => _screenshotData = screenshot);
      if (screenshot != null) {
        _recordMethodResult(
          PlatformInAppWebViewControllerMethod.takeScreenshot.name,
          'Screenshot taken (${screenshot.length} bytes)',
          isError: false,
        );
      } else {
        _recordMethodResult(
          PlatformInAppWebViewControllerMethod.takeScreenshot.name,
          'Failed to take screenshot',
          isError: true,
        );
      }
    } catch (e) {
      _recordMethodResult(
        PlatformInAppWebViewControllerMethod.takeScreenshot.name,
        'Error taking screenshot: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUrl() async {
    final params = await showParameterDialog(
      context: context,
      title: 'Load URL',
      parameters: {'url': _urlController.text.trim()},
      requiredPaths: ['url'],
    );

    if (params == null) return;
    final url = params['url']?.toString() ?? '';
    if (url.isEmpty) {
      _recordMethodResult(
        PlatformInAppWebViewControllerMethod.loadUrl.name,
        'Please enter a URL',
        isError: true,
      );
      return;
    }
    _urlController.text = url;

    if (_webViewController == null) {
      _recordMethodResult(
        PlatformInAppWebViewControllerMethod.loadUrl.name,
        'WebView not initialized. Run first.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(url)),
      );
      _recordMethodResult(
        PlatformInAppWebViewControllerMethod.loadUrl.name,
        'Loading URL: $url',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformInAppWebViewControllerMethod.loadUrl.name,
        'Error loading URL: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _evaluateJavaScript() async {
    if (_webViewController == null) {
      _recordMethodResult(
        PlatformInAppWebViewControllerMethod.evaluateJavascript.name,
        'WebView not initialized',
        isError: true,
      );
      return;
    }

    final params = await showParameterDialog(
      context: context,
      title: 'Evaluate JavaScript',
      parameters: {'source': 'document.title'},
      requiredPaths: ['source'],
    );

    if (params == null) return;
    final source = params['source']?.toString() ?? '';
    if (source.isEmpty) {
      _recordMethodResult(
        PlatformInAppWebViewControllerMethod.evaluateJavascript.name,
        'Please enter JavaScript source',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _webViewController?.evaluateJavascript(
        source: source,
      );
      _recordMethodResult(
        PlatformInAppWebViewControllerMethod.evaluateJavascript.name,
        'JavaScript result: $result',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformInAppWebViewControllerMethod.evaluateJavascript.name,
        'Error evaluating JavaScript: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
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

  Future<void> _resetForEnvironmentChange() async {
    if (_headlessWebView != null) {
      await _headlessWebView?.dispose();
    }
    setState(() {
      _headlessWebView = null;
      _webViewController = null;
      _isRunning = false;
      _currentSize = null;
      _screenshotData = null;
      _currentUrl = null;
      _currentTitle = null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$HeadlessInAppWebView'),
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
        key: const Key('headless_webview_main_list'),
        padding: const EdgeInsets.all(16),
        children: [
          ProfileSelectorCard(
            onEditSettingsProfile: () =>
                Navigator.pushNamed(context, '/settings'),
          ),
          const SizedBox(height: 16),
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildInputSection(),
          const SizedBox(height: 16),
          _buildMainMethods(),
          const SizedBox(height: 16),
          _buildSizeMethods(),
          const SizedBox(height: 16),
          _buildWebViewActions(),
          const SizedBox(height: 16),
          _buildPreviewSection(),
          const SizedBox(height: 16),
          _buildEventLog(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: _isRunning ? Colors.green.shade50 : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isRunning ? Icons.play_circle : Icons.pause_circle,
                  color: _isRunning ? Colors.green : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isRunning ? 'Running' : 'Stopped',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _isRunning ? Colors.green : Colors.grey,
                        ),
                      ),
                      Text(
                        'ID: ${_headlessWebView?.id ?? "N/A"}',
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
            if (_isRunning) ...[
              const Divider(),
              if (_currentUrl != null)
                Text(
                  'URL: $_currentUrl',
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (_currentTitle != null)
                Text(
                  'Title: $_currentTitle',
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (_currentSize != null)
                Text(
                  'Size: ${_currentSize!.width.toInt()}x${_currentSize!.height.toInt()}',
                  style: const TextStyle(fontSize: 12),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuration',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://flutter.dev',
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
                const spacing = 12.0;
                final fieldWidth = isMobile
                    ? constraints.maxWidth
                    : (constraints.maxWidth - spacing) / 2;

                return ResponsiveRow(
                  key: const Key('headless_webview_size_layout'),
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    SizedBox(
                      width: fieldWidth,
                      child: TextField(
                        key: const Key('headless_webview_width_field'),
                        controller: _widthController,
                        decoration: const InputDecoration(
                          labelText: 'Width',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: TextField(
                        key: const Key('headless_webview_height_field'),
                        controller: _heightController,
                        decoration: const InputDecoration(
                          labelText: 'Height',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMethods() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Main Methods',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildMethodTile(
              PlatformHeadlessInAppWebViewMethod.run.name,
              'Start the headless WebView',
              PlatformHeadlessInAppWebViewMethod.run,
              !_isRunning ? _run : null,
            ),
            _buildMethodTile(
              PlatformHeadlessInAppWebViewMethod.isRunning.name,
              'Check if the headless WebView is running',
              PlatformHeadlessInAppWebViewMethod.isRunning,
              _checkIsRunning,
            ),
            _buildMethodTile(
              PlatformHeadlessInAppWebViewMethod.dispose.name,
              'Stop and dispose the headless WebView',
              PlatformHeadlessInAppWebViewMethod.dispose,
              _isRunning ? _dispose : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeMethods() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Size Methods',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildMethodTile(
              PlatformHeadlessInAppWebViewMethod.setSize.name,
              'Set the WebView size',
              PlatformHeadlessInAppWebViewMethod.setSize,
              _isRunning ? _setSize : null,
            ),
            _buildMethodTile(
              PlatformHeadlessInAppWebViewMethod.getSize.name,
              'Get the current WebView size',
              PlatformHeadlessInAppWebViewMethod.getSize,
              _isRunning ? _getSize : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebViewActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WebView Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'These use the internal WebViewController',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isRunning ? _loadUrl : null,
                  icon: const Icon(Icons.link, size: 18),
                  label: const Text('Load URL'),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunning ? _takeScreenshot : null,
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Screenshot'),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunning ? _evaluateJavaScript : null,
                  icon: const Icon(Icons.code, size: 18),
                  label: const Text('Eval JS'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildMethodHistory(
              PlatformInAppWebViewControllerMethod.loadUrl.name,
            ),
            _buildMethodHistory(
              PlatformInAppWebViewControllerMethod.takeScreenshot.name,
            ),
            _buildMethodHistory(
              PlatformInAppWebViewControllerMethod.evaluateJavascript.name,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
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
                  'Screenshot Preview',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (_screenshotData != null)
                  TextButton(
                    onPressed: () => setState(() => _screenshotData = null),
                    child: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _screenshotData != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        _screenshotData!,
                        fit: BoxFit.contain,
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No screenshot available',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Run the headless WebView and take a screenshot',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTile(
    String methodName,
    String description,
    PlatformHeadlessInAppWebViewMethod method,
    VoidCallback? onPressed,
  ) {
    final supportedPlatforms = SupportCheckHelper.supportedPlatformsForMethod(
      method: method,
      checker: HeadlessInAppWebView.isMethodSupported,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        title: Text(
          methodName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 6),
            SupportBadgesRow(
              supportedPlatforms: supportedPlatforms,
              compact: true,
            ),
            const SizedBox(height: 6),
            _buildMethodHistory(methodName),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: !_isLoading ? onPressed : null,
          child: const Text('Run'),
        ),
      ),
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
                final events = provider.events.reversed.take(20).toList();
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
                  height: 200,
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
