import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/main.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';
import 'package:flutter_inappwebview_example/widgets/common/support_badge.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/providers/event_log_provider.dart';
import 'package:flutter_inappwebview_example/models/event_log_entry.dart';

/// Custom ChromeSafariBrowser implementation for testing
class TestChromeSafariBrowser extends ChromeSafariBrowser {
  final void Function(String event, Map<String, dynamic>? data)? onEvent;

  TestChromeSafariBrowser({this.onEvent});

  @override
  void onOpened() {
    onEvent?.call('onOpened', {'id': id});
  }

  @override
  void onCompletedInitialLoad(bool? didLoadSuccessfully) {
    onEvent?.call('onCompletedInitialLoad', {
      'didLoadSuccessfully': didLoadSuccessfully,
    });
  }

  @override
  void onInitialLoadDidRedirect(WebUri? url) {
    onEvent?.call('onInitialLoadDidRedirect', {'url': url?.toString()});
  }

  @override
  void onNavigationEvent(CustomTabsNavigationEventType? navigationEvent) {
    onEvent?.call('onNavigationEvent', {
      'navigationEvent': navigationEvent?.name(),
    });
  }

  @override
  void onServiceConnected() {
    onEvent?.call('onServiceConnected', null);
  }

  @override
  void onClosed() {
    onEvent?.call('onClosed', null);
  }

  @override
  void onWillOpenInBrowser() {
    onEvent?.call('onWillOpenInBrowser', null);
  }

  @override
  void onRelationshipValidationResult(
    CustomTabsRelationType? relation,
    WebUri? requestedOrigin,
    bool result,
  ) {
    onEvent?.call('onRelationshipValidationResult', {
      'relation': relation?.name(),
      'requestedOrigin': requestedOrigin?.toString(),
      'result': result,
    });
  }

  @override
  void onMessageChannelReady() {
    onEvent?.call('onMessageChannelReady', null);
  }

  @override
  void onPostMessage(String message) {
    onEvent?.call('onPostMessage', {'message': message});
  }

  @override
  void onVerticalScrollEvent(bool isDirectionUp) {
    onEvent?.call('onVerticalScrollEvent', {'isDirectionUp': isDirectionUp});
  }

  @override
  void onGreatestScrollPercentageIncreased(int scrollPercentage) {
    onEvent?.call('onGreatestScrollPercentageIncreased', {
      'scrollPercentage': scrollPercentage,
    });
  }

  @override
  void onSessionEnded(bool didUserInteract) {
    onEvent?.call('onSessionEnded', {'didUserInteract': didUserInteract});
  }
}

/// Screen for testing ChromeSafariBrowser functionality
class ChromeSafariBrowserScreen extends StatefulWidget {
  const ChromeSafariBrowserScreen({super.key});

  @override
  State<ChromeSafariBrowserScreen> createState() =>
      _ChromeSafariBrowserScreenState();
}

class _ChromeSafariBrowserScreenState extends State<ChromeSafariBrowserScreen> {
  final TextEditingController _urlController = TextEditingController(
    text: 'https://flutter.dev',
  );
  final TextEditingController _messageController = TextEditingController();

  TestChromeSafariBrowser? _browser;
  bool _isLoading = false;
  bool _browserOpened = false;
  Color _toolbarColor = Colors.blue;
  final List<ChromeSafariBrowserMenuItem> _menuItems = [];

  void _initBrowser() {
    try {
      _browser = TestChromeSafariBrowser(
        onEvent: (event, data) {
          _logEvent(EventType.ui, event, data: data);
          if (event == 'onClosed') {
            setState(() => _browserOpened = false);
          } else if (event == 'onOpened') {
            setState(() => _browserOpened = true);
          }
        },
      );
    } catch (e) {
      _showInitError('Unable to create browser: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _initBrowser();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _messageController.dispose();
    _browser?.dispose();
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

  Future<void> _open() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showError('Please enter a URL');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _browser?.open(
        url: WebUri(url),
        settings: ChromeSafariBrowserSettings(
          shareState: CustomTabsShareState.SHARE_STATE_ON,
          toolbarBackgroundColor: _toolbarColor,
          isSingleInstance: false,
          isTrustedWebActivity: false,
          keepAliveEnabled: true,
          barCollapsingEnabled: true,
          presentationStyle: ModalPresentationStyle.FULL_SCREEN,
          dismissButtonStyle: DismissButtonStyle.CLOSE,
        ),
      );
      _showSuccess('Browser opened');
    } catch (e) {
      _showError('Error opening browser: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _launchUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showError('Please enter a URL');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _browser?.launchUrl(url: WebUri(url));
      _showSuccess('URL launched');
    } catch (e) {
      _showError('Error launching URL: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _mayLaunchUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showError('Please enter a URL');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _browser?.mayLaunchUrl(url: WebUri(url));
      _showSuccess('mayLaunchUrl result: $result');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _validateRelationship() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showError('Please enter a URL');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _browser?.validateRelationship(
        relation: CustomTabsRelationType.USE_AS_ORIGIN,
        origin: WebUri(url),
      );
      _showSuccess('validateRelationship result: $result');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _close() async {
    setState(() => _isLoading = true);
    try {
      await _browser?.close();
      setState(() => _browserOpened = false);
      _showSuccess('Browser closed');
    } catch (e) {
      _showError('Error closing browser: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setActionButton() async {
    setState(() => _isLoading = true);
    try {
      // Create a simple colored icon
      final iconData = await _createActionButtonIcon();
      _browser?.setActionButton(
        ChromeSafariBrowserActionButton(
          id: 1,
          description: 'Test Action',
          icon: iconData,
          onClick: (url, title) {
            _logEvent(
              EventType.ui,
              'Action button clicked',
              data: {'url': url?.toString(), 'title': title},
            );
            _showSuccess('Action button clicked');
          },
        ),
      );
      _showSuccess('Action button set');
    } catch (e) {
      _showError('Error setting action button: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Uint8List> _createActionButtonIcon() async {
    // Return a simple icon bytes - in real app you'd load from assets
    try {
      final byteData = await rootBundle.load('assets/images/flutter-logo.png');
      return byteData.buffer.asUint8List();
    } catch (e) {
      // Return empty bytes if asset not found
      return Uint8List(0);
    }
  }

  Future<void> _updateActionButton() async {
    setState(() => _isLoading = true);
    try {
      final iconData = await _createActionButtonIcon();
      await _browser?.updateActionButton(
        icon: iconData,
        description: 'Updated Action',
      );
      _showSuccess('Action button updated');
    } catch (e) {
      _showError('Error updating action button: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addMenuItem() {
    final menuItem = ChromeSafariBrowserMenuItem(
      id: _menuItems.length + 1,
      label: 'Menu Item ${_menuItems.length + 1}',
      onClick: (url, title) {
        _logEvent(
          EventType.ui,
          'Menu item clicked',
          data: {'url': url, 'title': title},
        );
        _showSuccess('Menu item clicked');
      },
    );

    _browser?.addMenuItem(menuItem);
    setState(() {
      _menuItems.add(menuItem);
    });
    _showSuccess('Menu item added');
  }

  Future<void> _requestPostMessageChannel() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showError('Please enter a URL');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _browser?.requestPostMessageChannel(
        sourceOrigin: WebUri(url),
      );
      _showSuccess('requestPostMessageChannel result: $result');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _postMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      _showError('Please enter a message');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _browser?.postMessage(message);
      _showSuccess('postMessage result: ${result?.name}');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _isEngagementSignalsApiAvailable() async {
    setState(() => _isLoading = true);
    try {
      final result = await _browser?.isEngagementSignalsApiAvailable();
      _showSuccess('isEngagementSignalsApiAvailable: $result');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _checkIsOpened() {
    final opened = _browser?.isOpened() ?? false;
    _showSuccess('Browser is opened: $opened');
  }

  Future<void> _isAvailable() async {
    setState(() => _isLoading = true);
    try {
      final available = await ChromeSafariBrowser.isAvailable();
      _showSuccess('ChromeSafariBrowser is available: $available');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getMaxToolbarItems() async {
    setState(() => _isLoading = true);
    try {
      final maxItems = await ChromeSafariBrowser.getMaxToolbarItems();
      _showSuccess('Max toolbar items: $maxItems');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getPackageName() async {
    setState(() => _isLoading = true);
    try {
      final packageName = await ChromeSafariBrowser.getPackageName();
      _showSuccess('Package name: $packageName');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearWebsiteData() async {
    setState(() => _isLoading = true);
    try {
      await ChromeSafariBrowser.clearWebsiteData();
      _showSuccess('Website data cleared');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _prewarmConnections() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showError('Please enter a URL');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final token = await ChromeSafariBrowser.prewarmConnections([WebUri(url)]);
      _showSuccess('Prewarm token: ${token?.id}');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chrome/Safari Browser'),
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
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildInputSection(),
          const SizedBox(height: 16),
          _buildOpenMethods(),
          const SizedBox(height: 16),
          _buildToolbarMethods(),
          const SizedBox(height: 16),
          _buildMessagingMethods(),
          const SizedBox(height: 16),
          _buildStaticMethods(),
          const SizedBox(height: 16),
          _buildEventLog(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: _browserOpened ? Colors.green.shade50 : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _browserOpened ? Icons.web : Icons.web_asset_off,
              color: _browserOpened ? Colors.green : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _browserOpened ? 'Browser Open' : 'Browser Closed',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _browserOpened ? Colors.green : Colors.grey,
                    ),
                  ),
                  Text(
                    'ID: ${_browser?.id ?? "N/A"}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
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
              'Input',
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
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message (for postMessage)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Toolbar Color:'),
                const SizedBox(width: 16),
                ...[
                  Colors.blue,
                  Colors.green,
                  Colors.red,
                  Colors.purple,
                  Colors.orange,
                ].map(
                  (color) => GestureDetector(
                    onTap: () => setState(() => _toolbarColor = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _toolbarColor == color
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
          ],
        ),
      ),
    );
  }

  Widget _buildOpenMethods() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Open Methods',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildMethodTile(
              'open',
              'Open Chrome Custom Tab / Safari View Controller',
              PlatformChromeSafariBrowserMethod.open,
              _open,
            ),
            _buildMethodTile(
              'launchUrl',
              'Launch URL in already opened browser',
              PlatformChromeSafariBrowserMethod.launchUrl,
              _browserOpened ? _launchUrl : null,
            ),
            _buildMethodTile(
              'mayLaunchUrl',
              'Hint browser to preload URL',
              PlatformChromeSafariBrowserMethod.mayLaunchUrl,
              _mayLaunchUrl,
            ),
            _buildMethodTile(
              'validateRelationship',
              'Validate Digital Asset Links',
              PlatformChromeSafariBrowserMethod.validateRelationship,
              _validateRelationship,
            ),
            _buildMethodTile(
              'close',
              'Close the browser',
              PlatformChromeSafariBrowserMethod.close,
              _browserOpened ? _close : null,
            ),
            _buildMethodTile(
              'isOpened',
              'Check if browser is opened',
              PlatformChromeSafariBrowserMethod.isOpened,
              _checkIsOpened,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarMethods() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Toolbar & Menu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildMethodTile(
              'setActionButton',
              'Set action button (before open)',
              PlatformChromeSafariBrowserMethod.setActionButton,
              _setActionButton,
            ),
            _buildMethodTile(
              'updateActionButton',
              'Update action button icon',
              PlatformChromeSafariBrowserMethod.updateActionButton,
              _browserOpened ? _updateActionButton : null,
            ),
            _buildMethodTile(
              'addMenuItem',
              'Add menu item (before open)',
              PlatformChromeSafariBrowserMethod.addMenuItem,
              _addMenuItem,
            ),
            if (_menuItems.isNotEmpty) ...[
              const Divider(),
              Text(
                'Menu Items: ${_menuItems.length}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessagingMethods() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Messaging',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildMethodTile(
              'requestPostMessageChannel',
              'Request post message channel',
              PlatformChromeSafariBrowserMethod.requestPostMessageChannel,
              _browserOpened ? _requestPostMessageChannel : null,
            ),
            _buildMethodTile(
              'postMessage',
              'Send a message to the browser',
              PlatformChromeSafariBrowserMethod.postMessage,
              _browserOpened ? _postMessage : null,
            ),
            _buildMethodTile(
              'isEngagementSignalsApiAvailable',
              'Check if engagement signals API is available',
              PlatformChromeSafariBrowserMethod.isEngagementSignalsApiAvailable,
              _isEngagementSignalsApiAvailable,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticMethods() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Static Methods',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildMethodTile(
              'isAvailable (static)',
              'Check if Chrome Custom Tabs / Safari VC is available',
              PlatformChromeSafariBrowserMethod.isAvailable,
              _isAvailable,
            ),
            _buildMethodTile(
              'getMaxToolbarItems (static)',
              'Get max toolbar items',
              PlatformChromeSafariBrowserMethod.getMaxToolbarItems,
              _getMaxToolbarItems,
            ),
            _buildMethodTile(
              'getPackageName (static)',
              'Get Custom Tabs package name',
              PlatformChromeSafariBrowserMethod.getPackageName,
              _getPackageName,
            ),
            _buildMethodTile(
              'clearWebsiteData (static)',
              'Clear website data',
              PlatformChromeSafariBrowserMethod.clearWebsiteData,
              _clearWebsiteData,
            ),
            _buildMethodTile(
              'prewarmConnections (static)',
              'Prewarm connections',
              PlatformChromeSafariBrowserMethod.prewarmConnections,
              _prewarmConnections,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTile(
    String methodName,
    String description,
    PlatformChromeSafariBrowserMethod method,
    VoidCallback? onPressed,
  ) {
    final supportedPlatforms = SupportCheckHelper.supportedPlatformsForMethod(
      method: method,
      checker: ChromeSafariBrowser.isMethodSupported,
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
