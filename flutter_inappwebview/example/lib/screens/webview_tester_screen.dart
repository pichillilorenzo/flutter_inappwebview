import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/models/event_log_entry.dart';
import 'package:flutter_inappwebview_example/models/network_request.dart';
import 'package:flutter_inappwebview_example/providers/event_log_provider.dart';
import 'package:flutter_inappwebview_example/providers/network_monitor.dart';
import 'package:flutter_inappwebview_example/widgets/webview/event_console_widget.dart';
import 'package:flutter_inappwebview_example/widgets/webview/network_monitor_widget.dart';
import 'package:flutter_inappwebview_example/widgets/webview/method_tester_widget.dart';
import 'package:flutter_inappwebview_example/widgets/webview/javascript_console_widget.dart';
import 'package:flutter_inappwebview_example/widgets/webview/user_script_tester_widget.dart';

/// Main screen for testing InAppWebView functionality
class WebViewTesterScreen extends StatefulWidget {
  const WebViewTesterScreen({super.key});

  @override
  State<WebViewTesterScreen> createState() => _WebViewTesterScreenState();
}

class _WebViewTesterScreenState extends State<WebViewTesterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _urlController = TextEditingController(
    text: 'https://flutter.dev',
  );

  InAppWebViewController? _webViewController;
  bool _canGoBack = false;
  bool _canGoForward = false;
  double _progress = 0;
  String? _currentUrl;
  String? _currentTitle;
  late TabController _tabController;
  final List<UserScript> _userScripts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView Tester'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear Events',
            onPressed: () {
              context.read<EventLogProvider>().clear();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildUrlBar(),
          _buildNavigationControls(),
          if (_progress < 1.0)
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey.shade200,
            ),
          Expanded(child: _buildWebView()),
          _buildBottomTabs(),
        ],
      ),
    );
  }

  Widget _buildUrlBar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                hintText: 'Enter URL',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onSubmitted: (_) => _loadUrl(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            tooltip: 'Go',
            onPressed: _loadUrl,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
            onPressed: _canGoBack ? () => _webViewController?.goBack() : null,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            tooltip: 'Forward',
            onPressed:
                _canGoForward ? () => _webViewController?.goForward() : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: () => _webViewController?.reload(),
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            tooltip: 'Stop',
            onPressed: () => _webViewController?.stopLoading(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_currentTitle != null)
                  Text(
                    _currentTitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (_currentUrl != null)
                  Text(
                    _currentUrl!,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri(_urlController.text),
      ),
      initialSettings: InAppWebViewSettings(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        javaScriptEnabled: true,
        javaScriptCanOpenWindowsAutomatically: true,
      ),
      onWebViewCreated: (controller) {
        _webViewController = controller;
        _logEvent(EventType.ui, 'WebView created');
      },
      onLoadStart: (controller, url) {
        _logEvent(EventType.navigation, 'Load started: ${url?.toString()}');
        _updateNavigationState();
      },
      onLoadStop: (controller, url) async {
        _logEvent(EventType.navigation, 'Load stopped: ${url?.toString()}');
        _updateNavigationState();
        final title = await controller.getTitle();
        setState(() {
          _currentUrl = url?.toString();
          _currentTitle = title;
        });
      },
      onProgressChanged: (controller, progress) {
        setState(() {
          _progress = progress / 100;
        });
        _logEvent(
          EventType.performance,
          'Progress: $progress%',
          data: {'progress': progress},
        );
      },
      onConsoleMessage: (controller, consoleMessage) {
        _logEvent(
          EventType.console,
          consoleMessage.message,
          data: {
            'level': consoleMessage.messageLevel.name,
          },
        );
      },
      onLoadError: (controller, url, code, message) {
        _logEvent(
          EventType.error,
          'Load error: $message',
          data: {'url': url?.toString(), 'code': code},
        );
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final url = navigationAction.request.url;
        _logEvent(
          EventType.navigation,
          'Navigation: ${url?.toString()}',
          data: {'navigationType': navigationAction.navigationType?.name},
        );

        // Monitor network requests if enabled
        final monitor = context.read<NetworkMonitor>();
        if (monitor.isMonitoring) {
          final requestId = DateTime.now().millisecondsSinceEpoch.toString();
          monitor.addRequest(
            NetworkRequest(
              id: requestId,
              method: 'GET',
              url: url?.toString() ?? '',
              timestamp: DateTime.now(),
            ),
          );
        }

        return NavigationActionPolicy.ALLOW;
      },
    );
  }

  Widget _buildBottomTabs() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: const [
              Tab(text: 'Events'),
              Tab(text: 'Network'),
              Tab(text: 'Methods'),
              Tab(text: 'JavaScript'),
              Tab(text: 'UserScripts'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const EventConsoleWidget(),
                const NetworkMonitorWidget(),
                MethodTesterWidget(
                  onExecuteMethod: _executeMethod,
                  isMethodSupported: _isMethodSupported,
                ),
                JavaScriptConsoleWidget(
                  onExecute: (code) => _webViewController!.evaluateJavascript(
                    source: code,
                  ),
                  onExecuteAsync: (code) =>
                      _webViewController!.callAsyncJavaScript(
                    functionBody: code,
                  ),
                ),
                UserScriptTesterWidget(
                  onAddScript: _addUserScript,
                  onRemoveScript: _removeUserScript,
                  scripts: _userScripts,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    // Add https:// if no protocol specified
    String finalUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      finalUrl = 'https://$url';
    }

    await _webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(finalUrl)),
    );

    _logEvent(EventType.navigation, 'Loading URL: $finalUrl');
  }

  Future<void> _updateNavigationState() async {
    if (_webViewController == null) return;

    final canGoBack = await _webViewController!.canGoBack();
    final canGoForward = await _webViewController!.canGoForward();

    if (mounted) {
      setState(() {
        _canGoBack = canGoBack;
        _canGoForward = canGoForward;
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

  Future<dynamic> _executeMethod(
      String method, Map<String, dynamic> params) async {
    if (_webViewController == null) {
      throw Exception('WebView not initialized');
    }

    _logEvent(EventType.javascript, 'Executing method: $method',
        data: {'params': params});

    switch (method) {
      case 'getUrl':
        return await _webViewController!.getUrl();
      case 'getTitle':
        return await _webViewController!.getTitle();
      case 'canGoBack':
        return await _webViewController!.canGoBack();
      case 'canGoForward':
        return await _webViewController!.canGoForward();
      case 'goBack':
        await _webViewController!.goBack();
        return 'Navigation executed';
      case 'goForward':
        await _webViewController!.goForward();
        return 'Navigation executed';
      case 'reload':
        await _webViewController!.reload();
        return 'Reload executed';
      case 'stopLoading':
        await _webViewController!.stopLoading();
        return 'Stop executed';
      case 'evaluateJavascript':
        final source = params['source'] as String?;
        if (source == null) throw Exception('source parameter required');
        return await _webViewController!.evaluateJavascript(source: source);
      case 'clearCache':
        await _webViewController!.clearCache();
        return 'Cache cleared';
      case 'clearHistory':
        await _webViewController!.clearHistory();
        return 'History cleared';
      case 'getProgress':
        return await _webViewController!.getProgress();
      case 'getContentHeight':
        return await _webViewController!.getContentHeight();
      case 'zoomBy':
        final zoomFactor = params['zoomFactor'] as double?;
        if (zoomFactor == null)
          throw Exception('zoomFactor parameter required');
        await _webViewController!.zoomBy(
          zoomFactor: zoomFactor,
          animated: true,
        );
        return 'Zoom applied';
      case 'getSelectedText':
        return await _webViewController!.getSelectedText();
      default:
        throw Exception('Unknown method: $method');
    }
  }

  Future<bool> _isMethodSupported(String method) async {
    // For now, assume all methods are supported
    // In a real implementation, would call InAppWebViewController.isMethodSupported
    return true;
  }

  Future<void> _addUserScript(UserScript script) async {
    if (_webViewController == null) {
      throw Exception('WebView not initialized');
    }

    await _webViewController!.addUserScript(userScript: script);

    setState(() {
      _userScripts.add(script);
    });

    _logEvent(EventType.javascript, 'User script added',
        data: {'injectionTime': script.injectionTime.name});
  }

  Future<void> _removeUserScript(UserScript script) async {
    if (_webViewController == null) {
      throw Exception('WebView not initialized');
    }

    await _webViewController!.removeUserScript(userScript: script);

    setState(() {
      _userScripts.remove(script);
    });

    _logEvent(EventType.javascript, 'User script removed');
  }
}
