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
import 'package:flutter_inappwebview_example/widgets/common/app_drawer.dart';
import 'package:flutter_inappwebview_example/providers/settings_manager.dart';
import 'package:flutter_inappwebview_example/widgets/common/profile_selector_card.dart';
import 'package:flutter_inappwebview_example/utils/responsive_utils.dart';

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
  bool _forceShowReloadAfterStop = false;
  String? _currentUrl;
  String? _currentTitle;
  late TabController _tabController;
  final List<UserScript> _userScripts = [];
  double _webViewHeight = 320;
  static const double _minWebViewHeight = 160;
  static const double _minTabsHeight = 220;
  static const double _dividerHeight = 6;
  static const double _minChromeHeight = 140;
  bool _settingsExpanded = false;

  bool get _shouldShowStopButton {
    return _progress > 0 && _progress < 1.0 && !_forceShowReloadAfterStop;
  }

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
    final settingsManager = context.watch<SettingsManager>();

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
      drawer: AppDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final minRequiredHeight =
              _minWebViewHeight +
              _minTabsHeight +
              _dividerHeight +
              _minChromeHeight;
          final useScroll = constraints.maxHeight < minRequiredHeight;

          if (useScroll) {
            return _buildScrollableBody(settingsManager);
          }

          return _buildStandardBody(settingsManager);
        },
      ),
    );
  }

  Widget _buildStandardBody(SettingsManager settingsManager) {
    final isMobile = context.isMobile;
    return Column(
      children: [
        _buildCombinedControlBar(isMobile),
        Expanded(child: _buildResizableContent(settingsManager, isMobile)),
      ],
    );
  }

  Widget _buildScrollableBody(SettingsManager settingsManager) {
    final isMobile = context.isMobile;
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCombinedControlBar(isMobile),
          SizedBox(
            height: _minWebViewHeight,
            child: _buildWebViewWithProgress(settingsManager),
          ),
          if (isMobile)
            _buildCollapsibleSettings()
          else
            ProfileSelectorCard(
              compact: true,
              onEditSettingsProfile: () =>
                  Navigator.pushNamed(context, '/settings'),
              onEditEnvironmentProfile: () =>
                  Navigator.pushNamed(context, '/environment-settings'),
            ),
          Container(height: _dividerHeight, color: Colors.grey.shade300),
          SizedBox(height: _minTabsHeight, child: _buildBottomTabs()),
        ],
      ),
    );
  }

  Widget _buildResizableContent(
    SettingsManager settingsManager,
    bool isMobile,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Account for ProfileSelectorCard height - smaller on mobile when collapsed
        final profileCardHeight = isMobile
            ? (_settingsExpanded ? 100.0 : 40.0)
            : 120.0;
        final maxWebViewHeight =
            constraints.maxHeight -
            _minTabsHeight -
            _dividerHeight -
            profileCardHeight;
        final effectiveMax = maxWebViewHeight < _minWebViewHeight
            ? _minWebViewHeight
            : maxWebViewHeight;
        final webViewHeight = _webViewHeight
            .clamp(_minWebViewHeight, effectiveMax)
            .toDouble();

        return Column(
          children: [
            _buildWebViewWithProgress(settingsManager, height: webViewHeight),
            if (isMobile)
              _buildCollapsibleSettings()
            else
              ProfileSelectorCard(
                compact: true,
                onEditSettingsProfile: () =>
                    Navigator.pushNamed(context, '/settings'),
                onEditEnvironmentProfile: () =>
                    Navigator.pushNamed(context, '/environment-settings'),
              ),
            _buildResizeHandle(
              onDrag: (delta) {
                setState(() {
                  _webViewHeight = (_webViewHeight + delta)
                      .clamp(_minWebViewHeight, effectiveMax)
                      .toDouble();
                });
              },
            ),
            Expanded(child: _buildBottomTabs()),
          ],
        );
      },
    );
  }

  Widget _buildResizeHandle({required ValueChanged<double> onDrag}) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeRow,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragUpdate: (details) => onDrag(details.delta.dy),
        child: Container(
          height: _dividerHeight,
          color: Colors.grey.shade300,
          child: Center(
            child: Container(
              width: 40,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebViewWithProgress(
    SettingsManager settingsManager, {
    double? height,
  }) {
    final webView = _buildWebView(settingsManager);

    final stack = Stack(
      children: [
        Positioned.fill(child: webView),
        if (_progress < 1.0)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
      ],
    );

    if (height != null) {
      return SizedBox(height: height, child: stack);
    }

    return stack;
  }

  /// Combined URL bar and navigation controls - optimized for mobile
  Widget _buildCombinedControlBar(bool isMobile) {
    if (isMobile) {
      // Mobile: single compact row with URL field containing nav buttons
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            // Compact nav buttons
            _buildCompactNavButton(
              Icons.arrow_back,
              'Back',
              _canGoBack ? () => _webViewController?.goBack() : null,
            ),
            _buildCompactNavButton(
              Icons.arrow_forward,
              'Forward',
              _canGoForward ? () => _webViewController?.goForward() : null,
            ),
            _buildCompactNavButton(
              _shouldShowStopButton ? Icons.stop : Icons.refresh,
              _shouldShowStopButton ? 'Stop' : 'Reload',
              _shouldShowStopButton
                  ? () {
                      setState(() => _forceShowReloadAfterStop = true);
                      _webViewController?.stopLoading();
                    }
                  : () {
                      setState(() => _forceShowReloadAfterStop = false);
                      _webViewController?.reload();
                    },
            ),
            const SizedBox(width: 4),
            // URL field takes remaining space
            Expanded(child: _buildUrlTextField(isMobile: true)),
          ],
        ),
      );
    }

    // Desktop: separate URL bar and navigation controls
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Expanded(child: _buildUrlTextField()),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                tooltip: 'Go',
                onPressed: _loadUrl,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              _buildNavigationButtons(false),
              const SizedBox(width: 12),
              Expanded(child: _buildTitleAndUrlInfo(false)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactNavButton(
    IconData icon,
    String tooltip,
    VoidCallback? onPressed,
  ) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        icon: Icon(icon, size: 18),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: onPressed,
      ),
    );
  }

  /// Collapsible settings section for mobile
  Widget _buildCollapsibleSettings() {
    return GestureDetector(
      onTap: () => setState(() => _settingsExpanded = !_settingsExpanded),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _settingsExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                Text(
                  context.watch<SettingsManager>().currentProfile?.name ??
                      'Default',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                  child: Icon(
                    Icons.edit,
                    size: 14,
                    color: Colors.blue.shade400,
                  ),
                ),
              ],
            ),
            if (_settingsExpanded) ...[
              const SizedBox(height: 8),
              ProfileSelectorCard(
                compact: true,
                onEditSettingsProfile: () =>
                    Navigator.pushNamed(context, '/settings'),
                onEditEnvironmentProfile: () =>
                    Navigator.pushNamed(context, '/environment-settings'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUrlTextField({bool isMobile = false}) {
    return TextField(
      controller: _urlController,
      style: TextStyle(fontSize: isMobile ? 13 : 14),
      decoration: InputDecoration(
        hintText: 'Enter URL',
        isDense: isMobile,
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 12,
          vertical: isMobile ? 6 : 8,
        ),
        suffixIcon: isMobile
            ? SizedBox(
                width: 32,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  tooltip: 'Go',
                  padding: EdgeInsets.zero,
                  onPressed: _loadUrl,
                ),
              )
            : null,
      ),
      onSubmitted: (_) => _loadUrl(),
    );
  }

  Widget _buildNavigationButtons(bool isMobile) {
    final buttons = <Widget>[
      IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Back',
        onPressed: _canGoBack ? () => _webViewController?.goBack() : null,
      ),
      IconButton(
        icon: const Icon(Icons.arrow_forward),
        tooltip: 'Forward',
        onPressed: _canGoForward ? () => _webViewController?.goForward() : null,
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
    ];

    if (isMobile) {
      return Wrap(spacing: 4, runSpacing: 4, children: buttons);
    }

    return Row(mainAxisSize: MainAxisSize.min, children: buttons);
  }

  Widget _buildTitleAndUrlInfo(bool isMobile) {
    final titleStyle = TextStyle(
      fontSize: isMobile ? 11 : 12,
      fontWeight: FontWeight.bold,
    );
    final urlStyle = TextStyle(
      fontSize: isMobile ? 9 : 10,
      color: Colors.grey.shade600,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_currentTitle != null)
          Text(
            _currentTitle!,
            style: titleStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (_currentUrl != null)
          Text(
            _currentUrl!,
            style: urlStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildWebView(SettingsManager settingsManager) {
    final baseSettings = settingsManager.buildSettings();
    final mergedSettings =
        InAppWebViewSettings.fromMap({
          ...baseSettings.toMap(),
          'useShouldOverrideUrlLoading': true,
          'useShouldInterceptAjaxRequest': true,
          'useShouldInterceptFetchRequest': true,
          'useShouldInterceptRequest': true,
          'useOnLoadResource': true,
          'useOnDownloadStart': true,
          'mediaPlaybackRequiresUserGesture': false,
          'javaScriptEnabled': true,
          'javaScriptCanOpenWindowsAutomatically': true,
        }) ??
        InAppWebViewSettings();

    return InAppWebView(
      key: ValueKey(
        'webview-${settingsManager.settingsRevision}-${settingsManager.environmentRevision}',
      ),
      initialUrlRequest: URLRequest(url: WebUri(_urlController.text)),
      webViewEnvironment: settingsManager.webViewEnvironment,
      initialSettings: mergedSettings,

      // ============================================================
      // CORE EVENTS (8)
      // ============================================================

      // 1. onWebViewCreated
      onWebViewCreated: (controller) {
        _webViewController = controller;
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty.onWebViewCreated.name,
          data: {'viewId': controller.getViewId()},
        );
      },

      // 2. onLoadStart
      onLoadStart: (controller, url) {
        _forceShowReloadAfterStop = false;
        _logEvent(
          EventType.navigation,
          PlatformWebViewCreationParamsProperty.onLoadStart.name,
          data: {'url': url?.toString()},
        );
        if (url != null) {
          _urlController.text = url.toString();
        }
        _updateNavigationState();
      },

      // 3. onLoadStop
      onLoadStop: (controller, url) async {
        _forceShowReloadAfterStop = false;
        _logEvent(
          EventType.navigation,
          PlatformWebViewCreationParamsProperty.onLoadStop.name,
          data: {'url': url?.toString()},
        );
        if (url != null) {
          _urlController.text = url.toString();
        }
        _updateNavigationState();
        final title = await controller.getTitle();
        setState(() {
          _currentUrl = url?.toString();
          _currentTitle = title;
        });
      },

      // 4. onReceivedError
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

      // 5. onReceivedHttpError
      onReceivedHttpError: (controller, request, response) {
        _logEvent(
          EventType.error,
          PlatformWebViewCreationParamsProperty.onReceivedHttpError.name,
          data: {
            'url': request.url.toString(),
            'statusCode': response.statusCode,
            'reasonPhrase': response.reasonPhrase,
          },
        );
      },

      // 6. onProgressChanged
      onProgressChanged: (controller, progress) {
        setState(() {
          _progress = progress / 100;
          if (_progress >= 1.0) {
            _forceShowReloadAfterStop = false;
          }
        });
        _logEvent(
          EventType.performance,
          PlatformWebViewCreationParamsProperty.onProgressChanged.name,
          data: {'progress': progress},
        );
      },

      // 7. onConsoleMessage
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

      // 8. onTitleChanged
      onTitleChanged: (controller, title) {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty.onTitleChanged.name,
          data: {'title': title},
        );
        setState(() {
          _currentTitle = title;
        });
      },

      // ============================================================
      // NAVIGATION EVENTS (6)
      // ============================================================

      // 9. shouldOverrideUrlLoading
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final url = navigationAction.request.url;
        _logEvent(
          EventType.navigation,
          PlatformWebViewCreationParamsProperty.shouldOverrideUrlLoading.name,
          data: {
            'url': url?.toString(),
            'isForMainFrame': navigationAction.isForMainFrame,
            'navigationType': navigationAction.navigationType?.name(),
          },
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

      // 10. onLoadResource
      onLoadResource: (controller, resource) {
        // _logEvent(
        //   EventType.network,
        //   PlatformWebViewCreationParamsProperty.onLoadResource.name,
        //   data: {
        //     'url': resource.url?.toString(),
        //     'initiatorType': resource.initiatorType,
        //     'startTime': resource.startTime,
        //     'duration': resource.duration,
        //   },
        // );
      },

      // 11. onUpdateVisitedHistory
      onUpdateVisitedHistory: (controller, url, isReload) {
        _logEvent(
          EventType.navigation,
          PlatformWebViewCreationParamsProperty.onUpdateVisitedHistory.name,
          data: {'url': url?.toString(), 'isReload': isReload},
        );
        if (url != null) {
          _urlController.text = url.toString();
        }
        _updateNavigationState();
      },

      // 12. onPageCommitVisible
      onPageCommitVisible: (controller, url) {
        _logEvent(
          EventType.navigation,
          PlatformWebViewCreationParamsProperty.onPageCommitVisible.name,
          data: {'url': url?.toString()},
        );
        if (url != null) {
          _urlController.text = url.toString();
        }
      },

      // 13. onNavigationResponse
      onNavigationResponse: (controller, navigationResponse) async {
        _logEvent(
          EventType.navigation,
          PlatformWebViewCreationParamsProperty.onNavigationResponse.name,
          data: {
            'url': navigationResponse.response?.url?.toString(),
            'statusCode': navigationResponse.response?.statusCode,
            'isForMainFrame': navigationResponse.isForMainFrame,
            'canShowMIMEType': navigationResponse.canShowMIMEType,
          },
        );
        return NavigationResponseAction.ALLOW;
      },

      // 14. onDidReceiveServerRedirectForProvisionalNavigation
      onDidReceiveServerRedirectForProvisionalNavigation: (controller) {
        _logEvent(
          EventType.navigation,
          PlatformWebViewCreationParamsProperty
              .onDidReceiveServerRedirectForProvisionalNavigation
              .name,
        );
      },

      // ============================================================
      // WINDOW EVENTS (4)
      // ============================================================

      // 15. onCreateWindow
      onCreateWindow: (controller, createWindowAction) async {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty.onCreateWindow.name,
          data: {
            'url': createWindowAction.request.url?.toString(),
            'windowId': createWindowAction.windowId,
            'isForMainFrame': createWindowAction.isForMainFrame,
          },
        );
        return false; // Don't create a new window
      },

      // 16. onCloseWindow
      onCloseWindow: (controller) {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty.onCloseWindow.name,
        );
      },

      // 17. onWindowFocus
      onWindowFocus: (controller) {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty.onWindowFocus.name,
        );
      },

      // 18. onWindowBlur
      onWindowBlur: (controller) {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty.onWindowBlur.name,
        );
      },

      // ============================================================
      // JAVASCRIPT DIALOG EVENTS (4)
      // ============================================================

      // 19. onJsAlert
      onJsAlert: (controller, jsAlertRequest) async {
        _logEvent(
          EventType.javascript,
          PlatformWebViewCreationParamsProperty.onJsAlert.name,
          data: {
            'message': jsAlertRequest.message,
            'url': jsAlertRequest.url?.toString(),
          },
        );
        return JsAlertResponse(handledByClient: false);
      },

      // 20. onJsConfirm
      onJsConfirm: (controller, jsConfirmRequest) async {
        _logEvent(
          EventType.javascript,
          PlatformWebViewCreationParamsProperty.onJsConfirm.name,
          data: {
            'message': jsConfirmRequest.message,
            'url': jsConfirmRequest.url?.toString(),
          },
        );
        return JsConfirmResponse(handledByClient: false);
      },

      // 21. onJsPrompt
      onJsPrompt: (controller, jsPromptRequest) async {
        _logEvent(
          EventType.javascript,
          PlatformWebViewCreationParamsProperty.onJsPrompt.name,
          data: {
            'message': jsPromptRequest.message,
            'defaultValue': jsPromptRequest.defaultValue,
            'url': jsPromptRequest.url?.toString(),
          },
        );
        return JsPromptResponse(handledByClient: false);
      },

      // 22. onJsBeforeUnload
      onJsBeforeUnload: (controller, jsBeforeUnloadRequest) async {
        _logEvent(
          EventType.javascript,
          PlatformWebViewCreationParamsProperty.onJsBeforeUnload.name,
          data: {
            'message': jsBeforeUnloadRequest.message,
            'url': jsBeforeUnloadRequest.url?.toString(),
          },
        );
        return JsBeforeUnloadResponse(handledByClient: false);
      },

      // ============================================================
      // AUTHENTICATION EVENTS (3)
      // ============================================================

      // 23. onReceivedHttpAuthRequest
      onReceivedHttpAuthRequest: (controller, challenge) async {
        _logEvent(
          EventType.network,
          PlatformWebViewCreationParamsProperty.onReceivedHttpAuthRequest.name,
          data: {
            'host': challenge.protectionSpace.host,
            'port': challenge.protectionSpace.port,
            'protocol': challenge.protectionSpace.protocol,
            'realm': challenge.protectionSpace.realm,
          },
        );
        return HttpAuthResponse(action: HttpAuthResponseAction.CANCEL);
      },

      // 24. onReceivedServerTrustAuthRequest
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        _logEvent(
          EventType.network,
          PlatformWebViewCreationParamsProperty
              .onReceivedServerTrustAuthRequest
              .name,
          data: {
            'host': challenge.protectionSpace.host,
            'port': challenge.protectionSpace.port,
            'protocol': challenge.protectionSpace.protocol,
          },
        );
        return ServerTrustAuthResponse(
          action: ServerTrustAuthResponseAction.PROCEED,
        );
      },

      // 25. onReceivedClientCertRequest
      onReceivedClientCertRequest: (controller, challenge) async {
        _logEvent(
          EventType.network,
          PlatformWebViewCreationParamsProperty
              .onReceivedClientCertRequest
              .name,
          data: {
            'host': challenge.protectionSpace.host,
            'port': challenge.protectionSpace.port,
            'protocol': challenge.protectionSpace.protocol,
          },
        );
        return ClientCertResponse(action: ClientCertResponseAction.CANCEL);
      },

      // ============================================================
      // NETWORK INTERCEPTION EVENTS (6)
      // ============================================================

      // 26. shouldInterceptAjaxRequest
      shouldInterceptAjaxRequest: (controller, ajaxRequest) async {
        _logEvent(
          EventType.network,
          PlatformWebViewCreationParamsProperty.shouldInterceptAjaxRequest.name,
          data: {
            'url': ajaxRequest.url?.toString(),
            'method': ajaxRequest.method,
            'isAsync': ajaxRequest.isAsync,
          },
        );
        return ajaxRequest;
      },

      // 27. onAjaxReadyStateChange
      onAjaxReadyStateChange: (controller, ajaxRequest) async {
        _logEvent(
          EventType.network,
          PlatformWebViewCreationParamsProperty.onAjaxReadyStateChange.name,
          data: {
            'url': ajaxRequest.url?.toString(),
            'method': ajaxRequest.method,
            'readyState': ajaxRequest.readyState?.name(),
            'status': ajaxRequest.status,
          },
        );
        return AjaxRequestAction.PROCEED;
      },

      // 28. onAjaxProgress
      onAjaxProgress: (controller, ajaxRequest) async {
        _logEvent(
          EventType.network,
          PlatformWebViewCreationParamsProperty.onAjaxProgress.name,
          data: {
            'url': ajaxRequest.url?.toString(),
            'method': ajaxRequest.method,
            'status': ajaxRequest.status,
          },
        );
        return AjaxRequestAction.PROCEED;
      },

      // 29. shouldInterceptFetchRequest
      shouldInterceptFetchRequest: (controller, fetchRequest) async {
        _logEvent(
          EventType.network,
          PlatformWebViewCreationParamsProperty
              .shouldInterceptFetchRequest
              .name,
          data: {
            'url': fetchRequest.url?.toString(),
            'method': fetchRequest.method,
            'mode': fetchRequest.mode,
            'credentialsType': fetchRequest.credentials?.type,
          },
        );
        return fetchRequest;
      },

      // 30. shouldInterceptRequest
      shouldInterceptRequest: (controller, request) async {
        _logEvent(
          EventType.network,
          PlatformWebViewCreationParamsProperty.shouldInterceptRequest.name,
          data: {
            'url': request.url.toString(),
            'method': request.method,
            'isForMainFrame': request.isForMainFrame,
          },
        );
        return null; // Don't intercept
      },

      // 31. onLoadResourceWithCustomScheme
      onLoadResourceWithCustomScheme: (controller, request) async {
        _logEvent(
          EventType.network,
          PlatformWebViewCreationParamsProperty
              .onLoadResourceWithCustomScheme
              .name,
          data: {'url': request.url.toString(), 'scheme': request.url.scheme},
        );
        return null; // Don't handle custom scheme
      },

      // ============================================================
      // DOWNLOAD EVENTS (1)
      // ============================================================

      // 32. onDownloadStarting
      onDownloadStarting: (controller, downloadStartRequest) async {
        _logEvent(
          EventType.network,
          PlatformWebViewCreationParamsProperty.onDownloadStarting.name,
          data: {
            'url': downloadStartRequest.url.toString(),
            'mimeType': downloadStartRequest.mimeType,
            'contentLength': downloadStartRequest.contentLength,
            'suggestedFilename': downloadStartRequest.suggestedFilename,
          },
        );
        return DownloadStartResponse(
          handled: true,
          action: DownloadStartResponseAction.CANCEL,
        );
      },

      // ============================================================
      // SCROLL EVENTS (2)
      // ============================================================

      // 33. onScrollChanged
      onScrollChanged: (controller, x, y) {
        // _logEvent(
        //   EventType.ui,
        //   PlatformWebViewCreationParamsProperty.onScrollChanged.name,
        //   data: {'x': x, 'y': y},
        // );
      },

      // 34. onOverScrolled
      onOverScrolled: (controller, x, y, clampedX, clampedY) {
        // _logEvent(
        //   EventType.ui,
        //   PlatformWebViewCreationParamsProperty.onOverScrolled.name,
        //   data: {'x': x, 'y': y, 'clampedX': clampedX, 'clampedY': clampedY},
        // );
      },

      // ============================================================
      // ZOOM EVENTS (1)
      // ============================================================

      // 35. onZoomScaleChanged
      onZoomScaleChanged: (controller, oldScale, newScale) {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty.onZoomScaleChanged.name,
          data: {'oldScale': oldScale, 'newScale': newScale},
        );
      },

      // ============================================================
      // PRINT EVENTS (1)
      // ============================================================

      // 36. onPrintRequest
      onPrintRequest: (controller, url, printJobController) async {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty.onPrintRequest.name,
          data: {'url': url?.toString()},
        );
        return false; // Don't handle print
      },

      // ============================================================
      // FULLSCREEN EVENTS (2)
      // ============================================================

      // 37. onEnterFullscreen
      onEnterFullscreen: (controller) {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty.onEnterFullscreen.name,
        );
      },

      // 38. onExitFullscreen
      onExitFullscreen: (controller) {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty.onExitFullscreen.name,
        );
      },

      // ============================================================
      // PERMISSION EVENTS (4)
      // ============================================================

      // 39. onPermissionRequest
      onPermissionRequest: (controller, permissionRequest) async {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty.onPermissionRequest.name,
          data: {
            'resources': permissionRequest.resources
                .map((r) => r.name)
                .toList(),
          },
        );
        return PermissionResponse(
          resources: permissionRequest.resources,
          action: PermissionResponseAction.GRANT,
        );
      },

      // 40. onPermissionRequestCanceled
      onPermissionRequestCanceled: (controller, permissionRequest) {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty
              .onPermissionRequestCanceled
              .name,
          data: {
            'resources': permissionRequest.resources
                .map((r) => r.name)
                .toList(),
          },
        );
      },

      // 41. onGeolocationPermissionsShowPrompt
      onGeolocationPermissionsShowPrompt: (controller, origin) async {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty
              .onGeolocationPermissionsShowPrompt
              .name,
          data: {'origin': origin},
        );
        return GeolocationPermissionShowPromptResponse(
          origin: origin,
          allow: false,
          retain: false,
        );
      },

      // 42. onGeolocationPermissionsHidePrompt
      onGeolocationPermissionsHidePrompt: (controller) {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty
              .onGeolocationPermissionsHidePrompt
              .name,
        );
      },

      // ============================================================
      // TOUCH & HIT TEST EVENTS (1)
      // ============================================================

      // 43. onLongPressHitTestResult
      onLongPressHitTestResult: (controller, hitTestResult) async {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty.onLongPressHitTestResult.name,
          data: {
            'type': hitTestResult.type?.name(),
            'extra': hitTestResult.extra,
          },
        );
      },

      // ============================================================
      // RENDER PROCESS EVENTS (3)
      // ============================================================

      // 44. onRenderProcessUnresponsive
      onRenderProcessUnresponsive: (controller, url) async {
        _logEvent(
          EventType.error,
          PlatformWebViewCreationParamsProperty
              .onRenderProcessUnresponsive
              .name,
          data: {'url': url?.toString()},
        );
        return WebViewRenderProcessAction.TERMINATE;
      },

      // 45. onRenderProcessResponsive
      onRenderProcessResponsive: (controller, url) async {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty.onRenderProcessResponsive.name,
          data: {'url': url?.toString()},
        );
        return WebViewRenderProcessAction.TERMINATE;
      },

      // 46. onRenderProcessGone
      onRenderProcessGone: (controller, detail) {
        _logEvent(
          EventType.error,
          PlatformWebViewCreationParamsProperty.onRenderProcessGone.name,
          data: {
            'didCrash': detail.didCrash,
            'rendererPriorityAtExit': detail.rendererPriorityAtExit?.name(),
          },
        );
      },

      // ============================================================
      // FORM EVENTS (2)
      // ============================================================

      // 47. onFormResubmission
      onFormResubmission: (controller, url) async {
        _logEvent(
          EventType.navigation,
          PlatformWebViewCreationParamsProperty.onFormResubmission.name,
          data: {'url': url?.toString()},
        );
        return FormResubmissionAction.DONT_RESEND;
      },

      // 48. onReceivedLoginRequest
      onReceivedLoginRequest: (controller, loginRequest) {
        _logEvent(
          EventType.network,
          PlatformWebViewCreationParamsProperty.onReceivedLoginRequest.name,
          data: {
            'realm': loginRequest.realm,
            'account': loginRequest.account,
            'args': loginRequest.args,
          },
        );
      },

      // ============================================================
      // ICON EVENTS (2)
      // ============================================================

      // 49. onReceivedIcon
      onReceivedIcon: (controller, icon) {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty.onReceivedIcon.name,
          data: {'iconSize': icon.length},
        );
      },

      // 50. onReceivedTouchIconUrl
      onReceivedTouchIconUrl: (controller, url, precomposed) {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty.onReceivedTouchIconUrl.name,
          data: {'url': url.toString(), 'precomposed': precomposed},
        );
      },

      // ============================================================
      // SAFE BROWSING EVENTS (1)
      // ============================================================

      // 51. onSafeBrowsingHit
      onSafeBrowsingHit: (controller, url, threatType) async {
        _logEvent(
          EventType.error,
          PlatformWebViewCreationParamsProperty.onSafeBrowsingHit.name,
          data: {'url': url.toString(), 'threatType': threatType?.name},
        );
        return SafeBrowsingResponse(
          report: true,
          action: SafeBrowsingResponseAction.BACK_TO_SAFETY,
        );
      },

      // ============================================================
      // ADDITIONAL EVENTS (5)
      // ============================================================

      // 52. onWebContentProcessDidTerminate
      onWebContentProcessDidTerminate: (controller) {
        _logEvent(
          EventType.error,
          PlatformWebViewCreationParamsProperty
              .onWebContentProcessDidTerminate
              .name,
        );
      },

      // 53. shouldAllowDeprecatedTLS
      shouldAllowDeprecatedTLS: (controller, challenge) async {
        _logEvent(
          EventType.network,
          PlatformWebViewCreationParamsProperty.shouldAllowDeprecatedTLS.name,
          data: {
            'host': challenge.protectionSpace.host,
            'port': challenge.protectionSpace.port,
            'protocol': challenge.protectionSpace.protocol,
          },
        );
        return ShouldAllowDeprecatedTLSAction.CANCEL;
      },

      // 54. onCameraCaptureStateChanged
      onCameraCaptureStateChanged: (controller, oldState, newState) {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty
              .onCameraCaptureStateChanged
              .name,
          data: {'oldState': oldState?.name(), 'newState': newState?.name()},
        );
      },

      // 55. onMicrophoneCaptureStateChanged
      onMicrophoneCaptureStateChanged: (controller, oldState, newState) {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty
              .onMicrophoneCaptureStateChanged
              .name,
          data: {'oldState': oldState?.name(), 'newState': newState?.name()},
        );
      },

      // 56. onContentSizeChanged
      onContentSizeChanged: (controller, oldContentSize, newContentSize) {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty.onContentSizeChanged.name,
          data: {
            'oldWidth': oldContentSize.width,
            'oldHeight': oldContentSize.height,
            'newWidth': newContentSize.width,
            'newHeight': newContentSize.height,
          },
        );
      },

      // ============================================================
      // SYSTEM EVENTS (2)
      // ============================================================

      // 57. onProcessFailed
      onProcessFailed: (controller, detail) {
        _logEvent(
          EventType.error,
          PlatformWebViewCreationParamsProperty.onProcessFailed.name,
          data: {
            'kind': detail.kind.name(),
            'reason': detail.reason?.name(),
            'exitCode': detail.exitCode,
          },
        );
      },

      // 58. onAcceleratorKeyPressed
      onAcceleratorKeyPressed: (controller, keyEventInfo) {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty.onAcceleratorKeyPressed.name,
          data: {
            'keyEventKind': keyEventInfo.keyEventKind,
            'virtualKey': keyEventInfo.virtualKey,
            'physicalKeyStatus': keyEventInfo.physicalKeyStatus?.toMap(),
          },
        );
      },

      // ============================================================
      // OTHER EVENTS (2)
      // ============================================================

      // 59. onRequestFocus
      onRequestFocus: (controller) {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty.onRequestFocus.name,
        );
      },

      // 60. onShowFileChooser
      onShowFileChooser: (controller, fileChooserParams) async {
        _logEvent(
          EventType.ui,
          PlatformWebViewCreationParamsProperty.onShowFileChooser.name,
          data: {
            'mode': fileChooserParams.mode.name(),
            'acceptTypes': fileChooserParams.acceptTypes,
            'isCaptureEnabled': fileChooserParams.isCaptureEnabled,
          },
        );
        return ShowFileChooserResponse(handledByClient: false);
      },
    );
  }

  Widget _buildBottomTabs() {
    final isMobile = context.isMobile;
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: isMobile,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            labelStyle: TextStyle(fontSize: isMobile ? 12 : 14),
            unselectedLabelStyle: TextStyle(fontSize: isMobile ? 12 : 14),
            labelPadding: isMobile
                ? const EdgeInsets.symmetric(horizontal: 10)
                : null,
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
                MethodTesterWidget(controller: _webViewController),
                JavaScriptConsoleWidget(
                  onExecute: (code) =>
                      _webViewController!.evaluateJavascript(source: code),
                  onExecuteAsync: (code) => _webViewController!
                      .callAsyncJavaScript(functionBody: code),
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

  Future<void> _addUserScript(UserScript script) async {
    if (_webViewController == null) {
      throw Exception('WebView not initialized');
    }

    await _webViewController!.addUserScript(userScript: script);

    setState(() {
      _userScripts.add(script);
    });

    _logEvent(
      EventType.javascript,
      'User script added',
      data: {'injectionTime': script.injectionTime.name},
    );
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
