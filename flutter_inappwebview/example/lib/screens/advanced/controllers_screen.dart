import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/providers/event_log_provider.dart';
import 'package:flutter_inappwebview_example/models/event_log_entry.dart';

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

  String get _currentPlatform {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  TargetPlatform? _getTargetPlatform(String platform) {
    switch (platform) {
      case 'android':
        return TargetPlatform.android;
      case 'ios':
        return TargetPlatform.iOS;
      case 'macos':
        return TargetPlatform.macOS;
      case 'windows':
        return TargetPlatform.windows;
      case 'linux':
        return TargetPlatform.linux;
      default:
        return null;
    }
  }

  List<String> _getFindSupportedPlatforms(
    PlatformFindInteractionControllerMethod method,
  ) {
    final platforms = <String>[];
    for (final platform in [
      'android',
      'ios',
      'macos',
      'web',
      'windows',
      'linux',
    ]) {
      final targetPlatform = _getTargetPlatform(platform);
      if (targetPlatform != null &&
          FindInteractionController.isMethodSupported(
            method,
            platform: targetPlatform,
          )) {
        platforms.add(platform);
      }
    }
    return platforms;
  }

  List<String> _getPullToRefreshSupportedPlatforms(
    PlatformPullToRefreshControllerMethod method,
  ) {
    final platforms = <String>[];
    for (final platform in [
      'android',
      'ios',
      'macos',
      'web',
      'windows',
      'linux',
    ]) {
      final targetPlatform = _getTargetPlatform(platform);
      if (targetPlatform != null &&
          PullToRefreshController.isMethodSupported(
            method,
            platform: targetPlatform,
          )) {
        platforms.add(platform);
      }
    }
    return platforms;
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
                'onFindResultReceived',
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
          _logEvent(EventType.ui, 'onRefresh');
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

  void _showInitError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showError(message);
    });
  }

  // Find Interaction methods
  Future<void> _findAll() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _showError('Please enter search text');
      return;
    }
    await _findInteractionController?.findAll(find: query);
    _showSuccess('Searching for: $query');
  }

  Future<void> _findNext() async {
    await _findInteractionController?.findNext(forward: true);
  }

  Future<void> _findPrevious() async {
    await _findInteractionController?.findNext(forward: false);
  }

  Future<void> _clearMatches() async {
    await _findInteractionController?.clearMatches();
    setState(() {
      _matchCount = 0;
      _currentMatch = 0;
    });
    _showSuccess('Matches cleared');
  }

  Future<void> _setSearchText() async {
    final text = _searchController.text.trim();
    await _findInteractionController?.setSearchText(text);
    _showSuccess('Search text set');
  }

  Future<void> _getSearchText() async {
    final text = await _findInteractionController?.getSearchText();
    _showSuccess('Search text: $text');
  }

  Future<void> _presentFindNavigator() async {
    await _findInteractionController?.presentFindNavigator();
    _showSuccess('Find navigator presented');
  }

  Future<void> _dismissFindNavigator() async {
    await _findInteractionController?.dismissFindNavigator();
    _showSuccess('Find navigator dismissed');
  }

  Future<void> _isFindNavigatorVisible() async {
    final visible = await _findInteractionController?.isFindNavigatorVisible();
    _showSuccess('Find navigator visible: $visible');
  }

  Future<void> _getActiveFindSession() async {
    final session = await _findInteractionController?.getActiveFindSession();
    _showSuccess(
      'Active session: ${session?.resultCount ?? 0} results, highlight index: ${session?.highlightedResultIndex ?? -1}',
    );
  }

  // Pull to Refresh methods
  Future<void> _setEnabled(bool enabled) async {
    await _pullToRefreshController?.setEnabled(enabled);
    setState(() => _pullToRefreshEnabled = enabled);
    _showSuccess('Pull to refresh ${enabled ? "enabled" : "disabled"}');
  }

  Future<void> _isEnabled() async {
    final enabled = await _pullToRefreshController?.isEnabled();
    _showSuccess('Pull to refresh enabled: $enabled');
  }

  Future<void> _beginRefreshing() async {
    await _pullToRefreshController?.beginRefreshing();
    _showSuccess('Refreshing started');
  }

  Future<void> _endRefreshing() async {
    await _pullToRefreshController?.endRefreshing();
    _showSuccess('Refreshing ended');
  }

  Future<void> _isRefreshing() async {
    final refreshing = await _pullToRefreshController?.isRefreshing();
    _showSuccess('Is refreshing: $refreshing');
  }

  Future<void> _setColor(Color color) async {
    await _pullToRefreshController?.setColor(color);
    setState(() => _pullToRefreshColor = color);
    _showSuccess('Color set');
  }

  Future<void> _setBackgroundColor(Color color) async {
    await _pullToRefreshController?.setBackgroundColor(color);
    _showSuccess('Background color set');
  }

  Future<void> _getDefaultSlingshotDistance() async {
    final distance = await _pullToRefreshController
        ?.getDefaultSlingshotDistance();
    _showSuccess('Default slingshot distance: $distance');
  }

  // Web Message Channel methods
  Future<void> _createWebMessageChannel() async {
    if (_webViewController == null) {
      _showError('WebView not ready');
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
        _showSuccess('Web message channel created');
      }
    } catch (e) {
      _showError('Error creating channel: $e');
    }
  }

  Future<void> _postWebMessage() async {
    if (_webMessageChannel == null) {
      _showError('Create a channel first');
      return;
    }

    final message = _messageController.text.trim();
    if (message.isEmpty) {
      _showError('Please enter a message');
      return;
    }

    try {
      await _webMessageChannel!.port1.postMessage(WebMessage(data: message));
      _showSuccess('Message sent');
    } catch (e) {
      _showError('Error sending message: $e');
    }
  }

  void _closeWebMessageChannel() {
    _webMessageChannel?.dispose();
    _webMessageChannel = null;
    setState(() {
      _receivedMessages.clear();
    });
    _showSuccess('Channel closed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controllers'),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final minRequiredHeight =
              _minWebViewHeight + _minContentHeight + _dividerHeight + _minChromeHeight;
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
    final webViewHeight =
        _webViewHeight.clamp(_minWebViewHeight, effectiveMax).toDouble();

    return Column(
      children: [
        SizedBox(height: webViewHeight, child: _buildWebViewSection()),
        _buildResizeHandle(
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
              _buildFindInteractionSection(),
              const SizedBox(height: 16),
              _buildPullToRefreshSection(),
              const SizedBox(height: 16),
              _buildWebMessageChannelSection(),
              const SizedBox(height: 16),
              _buildPrintJobSection(),
              const SizedBox(height: 16),
              _buildEventLog(),
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
                _buildFindInteractionSection(),
                const SizedBox(height: 16),
                _buildPullToRefreshSection(),
                const SizedBox(height: 16),
                _buildWebMessageChannelSection(),
                const SizedBox(height: 16),
                _buildPrintJobSection(),
                const SizedBox(height: 16),
                _buildEventLog(),
              ],
            ),
          ),
        ],
      ),
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
    final isSupported = FindInteractionController.isClassSupported();

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            const Text(
              'FindInteractionController',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSupported ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isSupported ? 'Supported' : 'Not Supported',
                style: const TextStyle(color: Colors.white, fontSize: 10),
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
                      'setSearchText',
                      _getFindSupportedPlatforms(
                        PlatformFindInteractionControllerMethod.setSearchText,
                      ),
                      _webViewReady ? _setSearchText : null,
                    ),
                    _buildMethodChip(
                      'getSearchText',
                      _getFindSupportedPlatforms(
                        PlatformFindInteractionControllerMethod.getSearchText,
                      ),
                      _webViewReady ? _getSearchText : null,
                    ),
                    _buildMethodChip(
                      'presentFindNavigator',
                      _getFindSupportedPlatforms(
                        PlatformFindInteractionControllerMethod
                            .presentFindNavigator,
                      ),
                      _webViewReady ? _presentFindNavigator : null,
                    ),
                    _buildMethodChip(
                      'dismissFindNavigator',
                      _getFindSupportedPlatforms(
                        PlatformFindInteractionControllerMethod
                            .dismissFindNavigator,
                      ),
                      _webViewReady ? _dismissFindNavigator : null,
                    ),
                    _buildMethodChip(
                      'isFindNavigatorVisible',
                      _getFindSupportedPlatforms(
                        PlatformFindInteractionControllerMethod
                            .isFindNavigatorVisible,
                      ),
                      _webViewReady ? _isFindNavigatorVisible : null,
                    ),
                    _buildMethodChip(
                      'getActiveFindSession',
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
    final isSupported = PullToRefreshController.isClassSupported();

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            const Text(
              'PullToRefreshController',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSupported ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isSupported ? 'Supported' : 'Not Supported',
                style: const TextStyle(color: Colors.white, fontSize: 10),
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
                const Divider(),

                // Color selection
                Row(
                  children: [
                    const Text('Indicator Color:'),
                    const SizedBox(width: 16),
                    ...[
                      Colors.blue,
                      Colors.green,
                      Colors.red,
                      Colors.purple,
                      Colors.orange,
                    ].map(
                      (color) => GestureDetector(
                        onTap: _webViewReady ? () => _setColor(color) : null,
                        child: Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _pullToRefreshColor == color
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Methods
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildMethodChip(
                      'isEnabled',
                      _getPullToRefreshSupportedPlatforms(
                        PlatformPullToRefreshControllerMethod.isEnabled,
                      ),
                      _webViewReady ? _isEnabled : null,
                    ),
                    _buildMethodChip(
                      'beginRefreshing',
                      _getPullToRefreshSupportedPlatforms(
                        PlatformPullToRefreshControllerMethod.beginRefreshing,
                      ),
                      _webViewReady ? _beginRefreshing : null,
                    ),
                    _buildMethodChip(
                      'endRefreshing',
                      _getPullToRefreshSupportedPlatforms(
                        PlatformPullToRefreshControllerMethod.endRefreshing,
                      ),
                      _webViewReady ? _endRefreshing : null,
                    ),
                    _buildMethodChip(
                      'isRefreshing',
                      _getPullToRefreshSupportedPlatforms(
                        PlatformPullToRefreshControllerMethod.isRefreshing,
                      ),
                      _webViewReady ? _isRefreshing : null,
                    ),
                    _buildMethodChip(
                      'setBackgroundColor',
                      _getPullToRefreshSupportedPlatforms(
                        PlatformPullToRefreshControllerMethod
                            .setBackgroundColor,
                      ),
                      _webViewReady
                          ? () => _setBackgroundColor(Colors.grey.shade200)
                          : null,
                    ),
                    _buildMethodChip(
                      'getDefaultSlingshotDistance',
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
    final isSupported = WebMessageChannel.isClassSupported();

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            const Text(
              'WebMessageChannel',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSupported ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isSupported ? 'Supported' : 'Not Supported',
                style: const TextStyle(color: Colors.white, fontSize: 10),
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
    final isSupported = PrintJobController.isClassSupported();

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            const Text(
              'PrintJobController',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSupported ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isSupported ? 'Supported' : 'Not Supported',
                style: const TextStyle(color: Colors.white, fontSize: 10),
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
                const Text(
                  'PrintJobController is obtained from onPrintRequest callback when printing.',
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
                const Text(
                  'Available methods when PrintJobController is obtained:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildMethodChip(
                      'cancel',
                      ['android', 'ios', 'macos'],
                      null,
                      enabled: false,
                    ),
                    _buildMethodChip(
                      'restart',
                      ['android'],
                      null,
                      enabled: false,
                    ),
                    _buildMethodChip(
                      'dismiss',
                      ['ios', 'macos'],
                      null,
                      enabled: false,
                    ),
                    _buildMethodChip(
                      'getInfo',
                      ['android', 'ios', 'macos'],
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
    List<String> supportedPlatforms,
    VoidCallback? onPressed, {
    bool enabled = true,
  }) {
    final isSupported = supportedPlatforms.contains(_currentPlatform);
    final canPress = enabled && isSupported && onPressed != null;

    return Tooltip(
      message: 'Availability depends on platform',
      child: ActionChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: canPress ? Colors.black : Colors.grey,
          ),
        ),
        backgroundColor: canPress ? Colors.blue.shade50 : Colors.grey.shade200,
        onPressed: canPress ? onPressed : null,
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
