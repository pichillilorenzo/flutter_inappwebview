import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/widgets/common/app_drawer.dart';
import 'package:flutter_inappwebview_example/widgets/common/appbar_loading_indicator.dart';
import 'package:flutter_inappwebview_example/widgets/common/event_log_card.dart';
import 'package:flutter_inappwebview_example/widgets/common/resize_handle.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/providers/event_log_provider.dart';
import 'package:flutter_inappwebview_example/models/event_log_entry.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';
import 'package:flutter_inappwebview_example/widgets/common/support_badge.dart';
import 'package:flutter_inappwebview_example/widgets/common/parameter_dialog.dart';
import 'package:flutter_inappwebview_example/widgets/common/method_result_history.dart';

/// Screen for testing various WebView Controllers
class ControllersScreen extends StatefulWidget {
  const ControllersScreen({super.key});

  @override
  State<ControllersScreen> createState() => _ControllersScreenState();
}

class _ControllersScreenState extends State<ControllersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  InAppWebViewController? _webViewController;
  FindInteractionController? _findInteractionController;
  PullToRefreshController? _pullToRefreshController;
  bool _webViewReady = false;
  bool _isLoading = false;
  double _webViewHeight = 180;
  static const double _minWebViewHeight = 120;
  static const double _minContentHeight = 260;
  static const double _dividerHeight = 6;
  static const double _minChromeHeight = 140;

  // Find interaction state
  int _matchCount = 0;
  int _currentMatch = 0;

  // Pull to refresh state
  bool _pullToRefreshEnabled = true;
  Color _pullToRefreshColor = Colors.blue;

  // Web message channel state
  WebMessageChannel? _webMessageChannel;
  final List<String> _receivedMessages = [];

  final Map<String, List<MethodResultEntry>> _methodHistory = {};
  final Map<String, int> _selectedHistoryIndex = {};
  static const int _maxHistoryEntries = 3;

  SupportedPlatform? get _currentPlatform {
    if (kIsWeb) return SupportedPlatform.web;
    if (Platform.isAndroid) return SupportedPlatform.android;
    if (Platform.isIOS) return SupportedPlatform.ios;
    if (Platform.isMacOS) return SupportedPlatform.macos;
    if (Platform.isWindows) return SupportedPlatform.windows;
    if (Platform.isLinux) return SupportedPlatform.linux;
    return null;
  }

  Set<SupportedPlatform> _getFindSupportedPlatforms(
    PlatformFindInteractionControllerMethod method,
  ) {
    return SupportCheckHelper.supportedPlatformsForMethod(
      method: method,
      checker: FindInteractionController.isMethodSupported,
    );
  }

  Set<SupportedPlatform> _getPullToRefreshSupportedPlatforms(
    PlatformPullToRefreshControllerMethod method,
  ) {
    return SupportCheckHelper.supportedPlatformsForMethod(
      method: method,
      checker: PullToRefreshController.isMethodSupported,
    );
  }

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    try {
      _findInteractionController = FindInteractionController(
        onFindResultReceived:
            (controller, activeMatchOrdinal, numberOfMatches, isDoneCounting) {
              setState(() {
                _currentMatch = activeMatchOrdinal;
                _matchCount = numberOfMatches;
              });
              _logEvent(
                EventType.ui,
                PlatformFindInteractionControllerCreationParamsProperty
                    .onFindResultReceived
                    .name,
                data: {
                  'activeMatchOrdinal': activeMatchOrdinal,
                  'numberOfMatches': numberOfMatches,
                  'isDoneCounting': isDoneCounting,
                },
              );
            },
      );

      _pullToRefreshController = PullToRefreshController(
        settings: PullToRefreshSettings(
          enabled: _pullToRefreshEnabled,
          color: _pullToRefreshColor,
        ),
        onRefresh: () async {
          _logEvent(
            EventType.ui,
            PlatformPullToRefreshControllerCreationParamsProperty
                .onRefresh
                .name,
          );
          if (_webViewController != null) {
            await _webViewController!.reload();
          }
        },
      );
    } catch (e) {
      _showInitError('Unable to initialize controllers: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    _findInteractionController?.dispose();
    _pullToRefreshController?.dispose();
    _webMessageChannel?.dispose();
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

  void _showInitError(String message) {
    _recordMethodResult('initControllers', message, isError: true);
  }

  Widget _buildInitStatusSection() {
    final entries = _methodHistory['initControllers'] ?? const [];
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        _buildMethodHistory('initControllers', title: 'Initialization'),
        const SizedBox(height: 16),
      ],
    );
  }

  // Find Interaction methods
  Future<void> _findAll() async {
    final params = await showParameterDialog(
      context: context,
      title: 'Find All',
      parameters: {'find': _searchController.text.trim()},
      requiredPaths: ['find'],
    );

    if (params == null) return;
    final query = params['find']?.toString() ?? '';
    if (query.isEmpty) {
      _recordMethodResult(
        PlatformFindInteractionControllerMethod.findAll.name,
        'Please enter search text',
        isError: true,
      );
      return;
    }
    _searchController.text = query;
    await _findInteractionController?.findAll(find: query);
    _recordMethodResult(
      PlatformFindInteractionControllerMethod.findAll.name,
      'Searching for: $query',
      isError: false,
    );
  }

  Future<void> _findNext() async {
    await _findInteractionController?.findNext(forward: true);
    _recordMethodResult(
      PlatformFindInteractionControllerMethod.findNext.name,
      'Moved to next match',
      isError: false,
    );
  }

  Future<void> _findPrevious() async {
    await _findInteractionController?.findNext(forward: false);
    _recordMethodResult(
      '${PlatformFindInteractionControllerMethod.findNext.name} (previous)',
      'Moved to previous match',
      isError: false,
    );
  }

  Future<void> _clearMatches() async {
    await _findInteractionController?.clearMatches();
    setState(() {
      _matchCount = 0;
      _currentMatch = 0;
    });
    _recordMethodResult(
      PlatformFindInteractionControllerMethod.clearMatches.name,
      'Matches cleared',
      isError: false,
    );
  }

  Future<void> _setSearchText() async {
    final params = await showParameterDialog(
      context: context,
      title: 'Set Search Text',
      parameters: {'searchText': _searchController.text.trim()},
      requiredPaths: ['searchText'],
    );

    if (params == null) return;
    final text = params['searchText']?.toString() ?? '';
    if (text.isEmpty) {
      _recordMethodResult(
        PlatformFindInteractionControllerMethod.setSearchText.name,
        'Please enter search text',
        isError: true,
      );
      return;
    }
    _searchController.text = text;
    await _findInteractionController?.setSearchText(text);
    _recordMethodResult(
      PlatformFindInteractionControllerMethod.setSearchText.name,
      'Search text set',
      isError: false,
    );
  }

  Future<void> _getSearchText() async {
    final text = await _findInteractionController?.getSearchText();
    _recordMethodResult(
      PlatformFindInteractionControllerMethod.getSearchText.name,
      'Search text: $text',
      isError: false,
    );
  }

  Future<void> _presentFindNavigator() async {
    await _findInteractionController?.presentFindNavigator();
    _recordMethodResult(
      PlatformFindInteractionControllerMethod.presentFindNavigator.name,
      'Find navigator presented',
      isError: false,
    );
  }

  Future<void> _dismissFindNavigator() async {
    await _findInteractionController?.dismissFindNavigator();
    _recordMethodResult(
      PlatformFindInteractionControllerMethod.dismissFindNavigator.name,
      'Find navigator dismissed',
      isError: false,
    );
  }

  Future<void> _isFindNavigatorVisible() async {
    final visible = await _findInteractionController?.isFindNavigatorVisible();
    _recordMethodResult(
      PlatformFindInteractionControllerMethod.isFindNavigatorVisible.name,
      'Find navigator visible: $visible',
      isError: false,
    );
  }

  Future<void> _getActiveFindSession() async {
    final session = await _findInteractionController?.getActiveFindSession();
    _recordMethodResult(
      PlatformFindInteractionControllerMethod.getActiveFindSession.name,
      'Active session: ${session?.resultCount ?? 0} results, highlight index: ${session?.highlightedResultIndex ?? -1}',
      isError: false,
    );
  }

  // Pull to Refresh methods
  Future<void> _setEnabled(bool enabled) async {
    await _pullToRefreshController?.setEnabled(enabled);
    setState(() => _pullToRefreshEnabled = enabled);
    _recordMethodResult(
      PlatformPullToRefreshControllerMethod.setEnabled.name,
      'Pull to refresh ${enabled ? "enabled" : "disabled"}',
      isError: false,
    );
  }

  Future<void> _isEnabled() async {
    final enabled = await _pullToRefreshController?.isEnabled();
    _recordMethodResult(
      PlatformPullToRefreshControllerMethod.isEnabled.name,
      'Pull to refresh enabled: $enabled',
      isError: false,
    );
  }

  Future<void> _beginRefreshing() async {
    await _pullToRefreshController?.beginRefreshing();
    _recordMethodResult(
      PlatformPullToRefreshControllerMethod.beginRefreshing.name,
      'Refreshing started',
      isError: false,
    );
  }

  Future<void> _endRefreshing() async {
    await _pullToRefreshController?.endRefreshing();
    _recordMethodResult(
      PlatformPullToRefreshControllerMethod.endRefreshing.name,
      'Refreshing ended',
      isError: false,
    );
  }

  Future<void> _isRefreshing() async {
    final refreshing = await _pullToRefreshController?.isRefreshing();
    _recordMethodResult(
      PlatformPullToRefreshControllerMethod.isRefreshing.name,
      'Is refreshing: $refreshing',
      isError: false,
    );
  }

  Future<void> _setColor(Color color) async {
    await _pullToRefreshController?.setColor(color);
    setState(() => _pullToRefreshColor = color);
    _recordMethodResult(
      PlatformPullToRefreshControllerMethod.setColor.name,
      'Color set',
      isError: false,
    );
  }

  Future<void> _setBackgroundColor(Color color) async {
    await _pullToRefreshController?.setBackgroundColor(color);
    _recordMethodResult(
      PlatformPullToRefreshControllerMethod.setBackgroundColor.name,
      'Background color set',
      isError: false,
    );
  }

  Future<void> _promptSetColor() async {
    final params = await showParameterDialog(
      context: context,
      title: 'Set Refresh Indicator Color',
      parameters: {'color': _pullToRefreshColor},
      requiredPaths: ['color'],
    );

    if (params == null) return;
    final color = params['color'] as Color?;
    if (color == null) {
      _recordMethodResult(
        PlatformPullToRefreshControllerMethod.setColor.name,
        'Please pick a color',
        isError: true,
      );
      return;
    }
    await _setColor(color);
  }

  Future<void> _promptSetBackgroundColor() async {
    final params = await showParameterDialog(
      context: context,
      title: 'Set Background Color',
      parameters: {'color': Colors.grey.shade200},
      requiredPaths: ['color'],
    );

    if (params == null) return;
    final color = params['color'] as Color?;
    if (color == null) {
      _recordMethodResult(
        PlatformPullToRefreshControllerMethod.setBackgroundColor.name,
        'Please pick a color',
        isError: true,
      );
      return;
    }
    await _setBackgroundColor(color);
  }

  Future<void> _getDefaultSlingshotDistance() async {
    final distance = await _pullToRefreshController
        ?.getDefaultSlingshotDistance();
    _recordMethodResult(
      PlatformPullToRefreshControllerMethod.getDefaultSlingshotDistance.name,
      'Default slingshot distance: $distance',
      isError: false,
    );
  }

  // Web Message Channel methods
  Future<void> _createWebMessageChannel() async {
    if (_webViewController == null) {
      _recordMethodResult(
        PlatformInAppWebViewControllerMethod.createWebMessageChannel.name,
        'WebView not ready',
        isError: true,
      );
      return;
    }

    try {
      _webMessageChannel = await _webViewController!.createWebMessageChannel();
      if (_webMessageChannel != null) {
        await _webMessageChannel!.port1.setWebMessageCallback((message) {
          setState(() {
            _receivedMessages.add(message?.data?.toString() ?? 'null');
          });
          _logEvent(
            EventType.messaging,
            'Message received',
            data: {'message': message?.data?.toString()},
          );
        });
        _recordMethodResult(
          PlatformInAppWebViewControllerMethod.createWebMessageChannel.name,
          'Web message channel created',
          isError: false,
        );
      }
    } catch (e) {
      _recordMethodResult(
        PlatformInAppWebViewControllerMethod.createWebMessageChannel.name,
        'Error creating channel: $e',
        isError: true,
      );
    }
  }

  Future<void> _postWebMessage() async {
    if (_webMessageChannel == null) {
      _recordMethodResult(
        PlatformInAppWebViewControllerMethod.postWebMessage.name,
        'Create a channel first',
        isError: true,
      );
      return;
    }

    final params = await showParameterDialog(
      context: context,
      title: 'Post Web Message',
      parameters: {'message': _messageController.text.trim()},
      requiredPaths: ['message'],
    );

    if (params == null) return;
    final message = params['message']?.toString() ?? '';
    if (message.isEmpty) {
      _recordMethodResult(
        PlatformInAppWebViewControllerMethod.postWebMessage.name,
        'Please enter a message',
        isError: true,
      );
      return;
    }
    _messageController.text = message;

    try {
      await _webMessageChannel!.port1.postMessage(WebMessage(data: message));
      _recordMethodResult(
        PlatformInAppWebViewControllerMethod.postWebMessage.name,
        'Message sent',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformInAppWebViewControllerMethod.postWebMessage.name,
        'Error sending message: $e',
        isError: true,
      );
    }
  }

  void _closeWebMessageChannel() {
    _webMessageChannel?.dispose();
    _webMessageChannel = null;
    setState(() {
      _receivedMessages.clear();
    });
    _recordMethodResult(
      '$WebMessageChannel.${PlatformWebMessageChannelMethod.dispose.name}',
      'Channel closed',
      isError: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controllers'),
        actions: [
          AppBarLoadingIndicator(isLoading: _isLoading),
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
              _minContentHeight +
              _dividerHeight +
              _minChromeHeight;
          final useScroll = constraints.maxHeight < minRequiredHeight;

          if (useScroll) {
            return _buildScrollableBody();
          }

          return _buildResizableBody(constraints);
        },
      ),
    );
  }

  Widget _buildResizableBody(BoxConstraints constraints) {
    final maxWebViewHeight =
        constraints.maxHeight - _minContentHeight - _dividerHeight;
    final effectiveMax = maxWebViewHeight < _minWebViewHeight
        ? _minWebViewHeight
        : maxWebViewHeight;
    final webViewHeight = _webViewHeight
        .clamp(_minWebViewHeight, effectiveMax)
        .toDouble();

    return Column(
      children: [
        SizedBox(height: webViewHeight, child: _buildWebViewSection()),
        ResizeHandle(
          height: _dividerHeight,
          onDrag: (delta) {
            setState(() {
              _webViewHeight = (_webViewHeight + delta)
                  .clamp(_minWebViewHeight, effectiveMax)
                  .toDouble();
            });
          },
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildInitStatusSection(),
              _buildFindInteractionSection(),
              const SizedBox(height: 16),
              _buildPullToRefreshSection(),
              const SizedBox(height: 16),
              _buildWebMessageChannelSection(),
              const SizedBox(height: 16),
              _buildPrintJobSection(),
              const SizedBox(height: 16),
              const EventLogCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: _minWebViewHeight, child: _buildWebViewSection()),
          Container(height: _dividerHeight, color: Colors.grey.shade300),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInitStatusSection(),
                _buildFindInteractionSection(),
                const SizedBox(height: 16),
                _buildPullToRefreshSection(),
                const SizedBox(height: 16),
                _buildWebMessageChannelSection(),
                const SizedBox(height: 16),
                _buildPrintJobSection(),
                const SizedBox(height: 16),
                const EventLogCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebViewSection() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri('https://flutter.dev')),
            initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
            findInteractionController: _findInteractionController,
            pullToRefreshController: _pullToRefreshController,
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStop: (controller, url) {
              setState(() => _webViewReady = true);
              _pullToRefreshController?.endRefreshing();
            },
          ),
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _webViewReady ? 'WebView Ready ✓' : 'Loading...',
                style: TextStyle(
                  color: _webViewReady ? Colors.green : Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFindInteractionSection() {
    final supportedPlatforms = SupportChecker.getSupportedPlatformsForClass(
      '$FindInteractionController',
    );

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              '$FindInteractionController',
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
                // Search input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search text',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _webViewReady ? _findAll : null,
                      child: const Text('Find'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildMethodHistory(
                  PlatformFindInteractionControllerMethod.findAll.name,
                ),
                const SizedBox(height: 12),

                // Match navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _webViewReady ? _findPrevious : null,
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Previous',
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$_currentMatch / $_matchCount',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: _webViewReady ? _findNext : null,
                      icon: const Icon(Icons.arrow_forward),
                      tooltip: 'Next',
                    ),
                    IconButton(
                      onPressed: _webViewReady ? _clearMatches : null,
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear',
                    ),
                  ],
                ),
                const Divider(),

                // Other methods
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildMethodChip(
                      PlatformFindInteractionControllerMethod
                          .setSearchText
                          .name,
                      _getFindSupportedPlatforms(
                        PlatformFindInteractionControllerMethod.setSearchText,
                      ),
                      _webViewReady ? _setSearchText : null,
                    ),
                    _buildMethodChip(
                      PlatformFindInteractionControllerMethod
                          .getSearchText
                          .name,
                      _getFindSupportedPlatforms(
                        PlatformFindInteractionControllerMethod.getSearchText,
                      ),
                      _webViewReady ? _getSearchText : null,
                    ),
                    _buildMethodChip(
                      PlatformFindInteractionControllerMethod
                          .presentFindNavigator
                          .name,
                      _getFindSupportedPlatforms(
                        PlatformFindInteractionControllerMethod
                            .presentFindNavigator,
                      ),
                      _webViewReady ? _presentFindNavigator : null,
                    ),
                    _buildMethodChip(
                      PlatformFindInteractionControllerMethod
                          .dismissFindNavigator
                          .name,
                      _getFindSupportedPlatforms(
                        PlatformFindInteractionControllerMethod
                            .dismissFindNavigator,
                      ),
                      _webViewReady ? _dismissFindNavigator : null,
                    ),
                    _buildMethodChip(
                      PlatformFindInteractionControllerMethod
                          .isFindNavigatorVisible
                          .name,
                      _getFindSupportedPlatforms(
                        PlatformFindInteractionControllerMethod
                            .isFindNavigatorVisible,
                      ),
                      _webViewReady ? _isFindNavigatorVisible : null,
                    ),
                    _buildMethodChip(
                      PlatformFindInteractionControllerMethod
                          .getActiveFindSession
                          .name,
                      _getFindSupportedPlatforms(
                        PlatformFindInteractionControllerMethod
                            .getActiveFindSession,
                      ),
                      _webViewReady ? _getActiveFindSession : null,
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

  Widget _buildPullToRefreshSection() {
    final supportedPlatforms = SupportChecker.getSupportedPlatformsForClass(
      '$PullToRefreshController',
    );

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              '$PullToRefreshController',
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
                // Enable toggle
                SwitchListTile(
                  title: const Text('Enabled'),
                  value: _pullToRefreshEnabled,
                  onChanged: _webViewReady ? _setEnabled : null,
                ),
                _buildMethodHistory(
                  PlatformPullToRefreshControllerMethod.setEnabled.name,
                ),
                const Divider(),

                // Color selection
                Row(
                  children: [
                    const Text('Indicator Color:'),
                    const SizedBox(width: 16),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _pullToRefreshColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _webViewReady ? _promptSetColor : null,
                      child: const Text('Pick Color'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildMethodHistory(
                  PlatformPullToRefreshControllerMethod.setColor.name,
                ),
                const SizedBox(height: 16),

                // Methods
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildMethodChip(
                      PlatformPullToRefreshControllerMethod.isEnabled.name,
                      _getPullToRefreshSupportedPlatforms(
                        PlatformPullToRefreshControllerMethod.isEnabled,
                      ),
                      _webViewReady ? _isEnabled : null,
                    ),
                    _buildMethodChip(
                      PlatformPullToRefreshControllerMethod
                          .beginRefreshing
                          .name,
                      _getPullToRefreshSupportedPlatforms(
                        PlatformPullToRefreshControllerMethod.beginRefreshing,
                      ),
                      _webViewReady ? _beginRefreshing : null,
                    ),
                    _buildMethodChip(
                      PlatformPullToRefreshControllerMethod.endRefreshing.name,
                      _getPullToRefreshSupportedPlatforms(
                        PlatformPullToRefreshControllerMethod.endRefreshing,
                      ),
                      _webViewReady ? _endRefreshing : null,
                    ),
                    _buildMethodChip(
                      PlatformPullToRefreshControllerMethod.isRefreshing.name,
                      _getPullToRefreshSupportedPlatforms(
                        PlatformPullToRefreshControllerMethod.isRefreshing,
                      ),
                      _webViewReady ? _isRefreshing : null,
                    ),
                    _buildMethodChip(
                      PlatformPullToRefreshControllerMethod
                          .setBackgroundColor
                          .name,
                      _getPullToRefreshSupportedPlatforms(
                        PlatformPullToRefreshControllerMethod
                            .setBackgroundColor,
                      ),
                      _webViewReady ? _promptSetBackgroundColor : null,
                    ),
                    _buildMethodChip(
                      PlatformPullToRefreshControllerMethod
                          .getDefaultSlingshotDistance
                          .name,
                      _getPullToRefreshSupportedPlatforms(
                        PlatformPullToRefreshControllerMethod
                            .getDefaultSlingshotDistance,
                      ),
                      _webViewReady ? _getDefaultSlingshotDistance : null,
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

  Widget _buildWebMessageChannelSection() {
    final supportedPlatforms = SupportChecker.getSupportedPlatformsForClass(
      '$WebMessageChannel',
    );

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              '$WebMessageChannel',
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
                // Channel status
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _webMessageChannel != null
                        ? Colors.green.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _webMessageChannel != null
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: _webMessageChannel != null
                            ? Colors.green
                            : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _webMessageChannel != null
                            ? 'Channel Active'
                            : 'No Channel',
                        style: TextStyle(
                          color: _webMessageChannel != null
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Create/Close buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _webViewReady && _webMessageChannel == null
                            ? _createWebMessageChannel
                            : null,
                        child: const Text('Create Channel'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _webMessageChannel != null
                            ? _closeWebMessageChannel
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Close Channel'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildMethodHistory(
                  PlatformInAppWebViewControllerMethod
                      .createWebMessageChannel
                      .name,
                ),
                _buildMethodHistory(
                  '$WebMessageChannel.${PlatformWebMessageChannelMethod.dispose.name}',
                ),
                const SizedBox(height: 12),

                // Message input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          labelText: 'Message',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _webMessageChannel != null
                          ? _postWebMessage
                          : null,
                      child: const Text('Send'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildMethodHistory(
                  PlatformInAppWebViewControllerMethod.postWebMessage.name,
                ),
                const SizedBox(height: 12),

                // Received messages
                const Text(
                  'Received Messages:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 100,
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _receivedMessages.isEmpty
                      ? const Center(
                          child: Text(
                            'No messages received',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _receivedMessages.length,
                          itemBuilder: (context, index) {
                            return Text(
                              '${index + 1}. ${_receivedMessages[index]}',
                              style: const TextStyle(fontSize: 12),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrintJobSection() {
    final supportedPlatforms = SupportChecker.getSupportedPlatformsForClass(
      '$PrintJobController',
    );

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              '$PrintJobController',
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
                Text(
                  '$PrintJobController is obtained from onPrintRequest callback when printing.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _webViewReady
                      ? () async {
                          await _webViewController?.printCurrentPage();
                          _logEvent(EventType.ui, 'Print requested');
                        }
                      : null,
                  icon: const Icon(Icons.print),
                  label: const Text('Print Page'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Available methods when $PrintJobController is obtained:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildMethodChip(
                      PlatformPrintJobControllerMethod.cancel.name,
                      SupportCheckHelper.supportedPlatformsForMethod(
                        method: PlatformPrintJobControllerMethod.cancel,
                        checker: PrintJobController.isMethodSupported,
                      ),
                      null,
                      enabled: false,
                    ),
                    _buildMethodChip(
                      PlatformPrintJobControllerMethod.restart.name,
                      SupportCheckHelper.supportedPlatformsForMethod(
                        method: PlatformPrintJobControllerMethod.restart,
                        checker: PrintJobController.isMethodSupported,
                      ),
                      null,
                      enabled: false,
                    ),
                    _buildMethodChip(
                      PlatformPrintJobControllerMethod.dismiss.name,
                      SupportCheckHelper.supportedPlatformsForMethod(
                        method: PlatformPrintJobControllerMethod.dismiss,
                        checker: PrintJobController.isMethodSupported,
                      ),
                      null,
                      enabled: false,
                    ),
                    _buildMethodChip(
                      PlatformPrintJobControllerMethod.getInfo.name,
                      SupportCheckHelper.supportedPlatformsForMethod(
                        method: PlatformPrintJobControllerMethod.getInfo,
                        checker: PrintJobController.isMethodSupported,
                      ),
                      null,
                      enabled: false,
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

  Widget _buildMethodChip(
    String label,
    Set<SupportedPlatform> supportedPlatforms,
    VoidCallback? onPressed, {
    bool enabled = true,
  }) {
    final currentPlatform = _currentPlatform;
    final isSupported =
        currentPlatform != null && supportedPlatforms.contains(currentPlatform);
    final canPress = enabled && isSupported && onPressed != null;

    return Tooltip(
      message: 'Availability depends on platform',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ActionChip(
            label: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: canPress ? Colors.black : Colors.grey.shade600,
              ),
            ),
            backgroundColor: canPress
                ? Colors.blue.shade50
                : Colors.grey.shade100,
            side: canPress
                ? BorderSide(color: Colors.blue.shade200)
                : BorderSide(color: Colors.grey.shade300),
            onPressed: canPress ? onPressed : null,
          ),
          const SizedBox(height: 4),
          SupportBadgesRow(
            supportedPlatforms: supportedPlatforms,
            compact: true,
          ),
          const SizedBox(height: 6),
          _buildMethodHistory(label),
        ],
      ),
    );
  }
}
