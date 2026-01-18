import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/providers/event_log_provider.dart';
import 'package:flutter_inappwebview_example/models/event_log_entry.dart';

/// Custom InAppBrowser implementation for testing
class TestInAppBrowser extends InAppBrowser {
  final void Function(String event, Map<String, dynamic>? data)? onEvent;

  TestInAppBrowser({this.onEvent});

  @override
  void onBrowserCreated() {
    onEvent?.call('onBrowserCreated', {'id': id});
  }

  @override
  void onLoadStart(WebUri? url) {
    onEvent?.call('onLoadStart', {'url': url?.toString()});
  }

  @override
  void onLoadStop(WebUri? url) {
    onEvent?.call('onLoadStop', {'url': url?.toString()});
  }

  @override
  void onReceivedError(WebResourceRequest request, WebResourceError error) {
    onEvent?.call('onReceivedError', {
      'url': request.url.toString(),
      'errorType': error.type.name,
      'description': error.description,
    });
  }

  @override
  void onProgressChanged(int progress) {
    onEvent?.call('onProgressChanged', {'progress': progress});
  }

  @override
  void onExit() {
    onEvent?.call('onExit', null);
  }

  @override
  void onMainWindowWillClose() {
    onEvent?.call('onMainWindowWillClose', null);
  }

  @override
  void onConsoleMessage(ConsoleMessage consoleMessage) {
    onEvent?.call('onConsoleMessage', {
      'message': consoleMessage.message,
      'level': consoleMessage.messageLevel.name,
    });
  }
}

/// Screen for testing InAppBrowser functionality
class InAppBrowserScreen extends StatefulWidget {
  const InAppBrowserScreen({super.key});

  @override
  State<InAppBrowserScreen> createState() => _InAppBrowserScreenState();
}

class _InAppBrowserScreenState extends State<InAppBrowserScreen> {
  final TextEditingController _urlController = TextEditingController(
    text: 'https://flutter.dev',
  );
  final TextEditingController _dataController = TextEditingController(
    text:
        '<html><body><h1>Hello InAppBrowser!</h1><p>This is HTML data.</p></body></html>',
  );
  final TextEditingController _menuItemIdController = TextEditingController();
  final TextEditingController _menuItemTitleController = TextEditingController(
    text: 'Custom Menu Item',
  );

  TestInAppBrowser? _browser;
  bool _isLoading = false;
  bool _browserOpened = false;
  final List<InAppBrowserMenuItem> _menuItems = [];

  void _initBrowser() {
    _browser = TestInAppBrowser(
      onEvent: (event, data) {
        _logEvent(EventType.ui, event, data: data);
        if (event == 'onExit') {
          setState(() => _browserOpened = false);
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initBrowser();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _dataController.dispose();
    _menuItemIdController.dispose();
    _menuItemTitleController.dispose();
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

  Future<void> _openUrlRequest() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showError('Please enter a URL');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _browser?.openUrlRequest(
        urlRequest: URLRequest(url: WebUri(url)),
        settings: InAppBrowserClassSettings(
          browserSettings: InAppBrowserSettings(
            toolbarTopBackgroundColor: Colors.blue,
            presentationStyle: ModalPresentationStyle.FULL_SCREEN,
          ),
          webViewSettings: InAppWebViewSettings(javaScriptEnabled: true),
        ),
      );
      setState(() => _browserOpened = true);
      _showSuccess('Browser opened with URL');
    } catch (e) {
      _showError('Error opening browser: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openFile() async {
    setState(() => _isLoading = true);
    try {
      await _browser?.openFile(
        assetFilePath: 'assets/index.html',
        settings: InAppBrowserClassSettings(
          browserSettings: InAppBrowserSettings(
            toolbarTopBackgroundColor: Colors.green,
          ),
        ),
      );
      setState(() => _browserOpened = true);
      _showSuccess('Browser opened with file');
    } catch (e) {
      _showError('Error opening file: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openData() async {
    final data = _dataController.text.trim();
    if (data.isEmpty) {
      _showError('Please enter HTML data');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _browser?.openData(
        data: data,
        mimeType: 'text/html',
        encoding: 'utf8',
        settings: InAppBrowserClassSettings(
          browserSettings: InAppBrowserSettings(
            toolbarTopBackgroundColor: Colors.purple,
          ),
        ),
      );
      setState(() => _browserOpened = true);
      _showSuccess('Browser opened with data');
    } catch (e) {
      _showError('Error opening data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openWithSystemBrowser() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showError('Please enter a URL');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await InAppBrowser.openWithSystemBrowser(url: WebUri(url));
      _showSuccess('Opened in system browser');
    } catch (e) {
      _showError('Error opening system browser: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addMenuItem() {
    final id = _menuItemIdController.text.trim();
    final title = _menuItemTitleController.text.trim();

    if (id.isEmpty || title.isEmpty) {
      _showError('Please enter menu item ID and title');
      return;
    }

    final menuItem = InAppBrowserMenuItem(
      id: id.hashCode,
      title: title,
      onClick: () {
        _logEvent(EventType.ui, 'Menu item clicked', data: {'id': id});
        _showSuccess('Menu item "$title" clicked');
      },
    );

    _browser?.addMenuItem(menuItem);
    setState(() {
      _menuItems.add(menuItem);
    });
    _menuItemIdController.clear();
    _showSuccess('Menu item added');
  }

  void _removeMenuItem(InAppBrowserMenuItem menuItem) {
    final removed = _browser?.removeMenuItem(menuItem) ?? false;
    if (removed) {
      setState(() {
        _menuItems.remove(menuItem);
      });
      _showSuccess('Menu item removed');
    } else {
      _showError('Failed to remove menu item');
    }
  }

  void _removeAllMenuItems() {
    _browser?.removeAllMenuItem();
    setState(() {
      _menuItems.clear();
    });
    _showSuccess('All menu items removed');
  }

  Future<void> _show() async {
    setState(() => _isLoading = true);
    try {
      await _browser?.show();
      _showSuccess('Browser shown');
    } catch (e) {
      _showError('Error showing browser: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _hide() async {
    setState(() => _isLoading = true);
    try {
      await _browser?.hide();
      _showSuccess('Browser hidden');
    } catch (e) {
      _showError('Error hiding browser: $e');
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

  Future<void> _isHidden() async {
    setState(() => _isLoading = true);
    try {
      final hidden = await _browser?.isHidden();
      _showSuccess('Browser is hidden: $hidden');
    } catch (e) {
      _showError('Error checking hidden state: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getSettings() async {
    setState(() => _isLoading = true);
    try {
      final settings = await _browser?.getSettings();
      _showSettingsDialog(settings);
    } catch (e) {
      _showError('Error getting settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setSettings() async {
    setState(() => _isLoading = true);
    try {
      await _browser?.setSettings(
        settings: InAppBrowserClassSettings(
          browserSettings: InAppBrowserSettings(
            toolbarTopBackgroundColor: Colors.orange,
            hideToolbarTop: false,
          ),
        ),
      );
      _showSuccess('Settings updated');
    } catch (e) {
      _showError('Error setting settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _checkIsOpened() {
    final opened = _browser?.isOpened() ?? false;
    _showSuccess('Browser is opened: $opened');
  }

  void _showSettingsDialog(InAppBrowserClassSettings? settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Browser Settings'),
        content: SingleChildScrollView(
          child: Text(settings?.toMap().toString() ?? 'No settings'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InAppBrowser'),
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
          _buildUrlInput(),
          const SizedBox(height: 16),
          _buildOpenMethods(),
          const SizedBox(height: 16),
          _buildMenuItemsSection(),
          const SizedBox(height: 16),
          _buildControlMethods(),
          const SizedBox(height: 16),
          _buildSettingsMethods(),
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

  Widget _buildUrlInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'URL / Data Input',
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
              controller: _dataController,
              decoration: const InputDecoration(
                labelText: 'HTML Data',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 3,
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
              'openUrlRequest',
              'Open browser with URL request',
              PlatformInAppBrowserMethod.openUrlRequest,
              _openUrlRequest,
            ),
            _buildMethodTile(
              'openFile',
              'Open browser with local file',
              PlatformInAppBrowserMethod.openFile,
              _openFile,
            ),
            _buildMethodTile(
              'openData',
              'Open browser with HTML data',
              PlatformInAppBrowserMethod.openData,
              _openData,
            ),
            _buildMethodTile(
              'openWithSystemBrowser (static)',
              'Open URL in system browser',
              PlatformInAppBrowserMethod.openWithSystemBrowser,
              _openWithSystemBrowser,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Menu Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _menuItemIdController,
                    decoration: const InputDecoration(
                      labelText: 'ID',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _menuItemTitleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addMenuItem,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_menuItems.isNotEmpty) ...[
              const Divider(),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  return ListTile(
                    dense: true,
                    title: Text(item.title),
                    subtitle: Text('ID: ${item.id}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _removeMenuItem(item),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _removeAllMenuItems,
                icon: const Icon(Icons.clear_all),
                label: const Text('Remove All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControlMethods() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Control Methods',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildMethodTile(
              'show',
              'Show the browser',
              PlatformInAppBrowserMethod.show,
              _browserOpened ? _show : null,
            ),
            _buildMethodTile(
              'hide',
              'Hide the browser',
              PlatformInAppBrowserMethod.hide,
              _browserOpened ? _hide : null,
            ),
            _buildMethodTile(
              'close',
              'Close the browser',
              PlatformInAppBrowserMethod.close,
              _browserOpened ? _close : null,
            ),
            _buildMethodTile(
              'isHidden',
              'Check if browser is hidden',
              PlatformInAppBrowserMethod.isHidden,
              _browserOpened ? _isHidden : null,
            ),
            _buildMethodTile(
              'isOpened',
              'Check if browser is opened',
              PlatformInAppBrowserMethod.isOpened,
              _checkIsOpened,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsMethods() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings Methods',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildMethodTile(
              'getSettings',
              'Get current browser settings',
              PlatformInAppBrowserMethod.getSettings,
              _browserOpened ? _getSettings : null,
            ),
            _buildMethodTile(
              'setSettings',
              'Update browser settings',
              PlatformInAppBrowserMethod.setSettings,
              _browserOpened ? _setSettings : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTile(
    String methodName,
    String description,
    PlatformInAppBrowserMethod method,
    VoidCallback? onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        title: Text(
          methodName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          description,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
