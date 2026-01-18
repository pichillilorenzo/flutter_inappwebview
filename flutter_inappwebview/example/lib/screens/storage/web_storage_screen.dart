import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/main.dart';
import 'package:flutter_inappwebview_example/widgets/common/support_badge.dart';

/// Screen for testing WebStorage (localStorage and sessionStorage) functionality
class WebStorageScreen extends StatefulWidget {
  const WebStorageScreen({super.key});

  @override
  State<WebStorageScreen> createState() => _WebStorageScreenState();
}

class _WebStorageScreenState extends State<WebStorageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  InAppWebViewController? _webViewController;
  bool _isLoading = false;
  bool _webViewReady = false;

  // LocalStorage state
  List<WebStorageItem> _localStorageItems = [];
  int? _localStorageLength;

  // SessionStorage state
  List<WebStorageItem> _sessionStorageItems = [];
  int? _sessionStorageLength;

  final TextEditingController _urlController = TextEditingController(
    text: 'https://example.com',
  );

  String get _currentPlatform {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  List<String> _getSupportedPlatformsForMethod(
    PlatformLocalStorageMethod method,
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
          LocalStorage.isMethodSupported(method, platform: targetPlatform)) {
        platforms.add(platform);
      } else if (platform == 'web' && LocalStorage.isMethodSupported(method)) {
        if (kIsWeb) platforms.add(platform);
      }
    }
    return platforms;
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  WebStorage? get _webStorage => _webViewController?.webStorage;
  LocalStorage? get _localStorage => _webStorage?.localStorage;
  SessionStorage? get _sessionStorage => _webStorage?.sessionStorage;

  bool get _isLocalStorageTab => _tabController.index == 0;

  Future<void> _loadUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showError('Please enter a URL');
      return;
    }

    try {
      await _webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(url)),
      );
    } catch (e) {
      _showError('Error loading URL: $e');
    }
  }

  Future<void> _getLength() async {
    if (!_webViewReady) {
      _showError('WebView not ready. Load a page first.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final storage = _isLocalStorageTab ? _localStorage : _sessionStorage;
      final length = await storage?.length();

      setState(() {
        if (_isLocalStorageTab) {
          _localStorageLength = length;
        } else {
          _sessionStorageLength = length;
        }
      });
      _showSuccess('Storage length: $length');
    } catch (e) {
      _showError('Error getting length: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getItems() async {
    if (!_webViewReady) {
      _showError('WebView not ready. Load a page first.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final storage = _isLocalStorageTab ? _localStorage : _sessionStorage;
      final items = await storage?.getItems() ?? [];

      setState(() {
        if (_isLocalStorageTab) {
          _localStorageItems = items;
          _localStorageLength = items.length;
        } else {
          _sessionStorageItems = items;
          _sessionStorageLength = items.length;
        }
      });
      _showSuccess('Found ${items.length} items');
    } catch (e) {
      _showError('Error getting items: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getItem(String key) async {
    if (!_webViewReady) {
      _showError('WebView not ready. Load a page first.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final storage = _isLocalStorageTab ? _localStorage : _sessionStorage;
      final value = await storage?.getItem(key: key);
      _showSuccess('Value for "$key": ${value ?? "null"}');
    } catch (e) {
      _showError('Error getting item: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setItem() async {
    if (!_webViewReady) {
      _showError('WebView not ready. Load a page first.');
      return;
    }

    await _showSetItemDialog();
  }

  Future<void> _removeItem(String key) async {
    if (!_webViewReady) {
      _showError('WebView not ready. Load a page first.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final storage = _isLocalStorageTab ? _localStorage : _sessionStorage;
      await storage?.removeItem(key: key);
      _showSuccess('Item "$key" removed');
      await _getItems();
    } catch (e) {
      _showError('Error removing item: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clear() async {
    if (!_webViewReady) {
      _showError('WebView not ready. Load a page first.');
      return;
    }

    final confirmed = await _showConfirmDialog(
      'Clear Storage',
      'Are you sure you want to clear all ${_isLocalStorageTab ? "localStorage" : "sessionStorage"} items?',
    );
    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      final storage = _isLocalStorageTab ? _localStorage : _sessionStorage;
      await storage?.clear();
      setState(() {
        if (_isLocalStorageTab) {
          _localStorageItems = [];
          _localStorageLength = 0;
        } else {
          _sessionStorageItems = [];
          _sessionStorageLength = 0;
        }
      });
      _showSuccess('Storage cleared');
    } catch (e) {
      _showError('Error clearing storage: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _key(int index) async {
    if (!_webViewReady) {
      _showError('WebView not ready. Load a page first.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final storage = _isLocalStorageTab ? _localStorage : _sessionStorage;
      final keyName = await storage?.key(index: index);
      _showSuccess('Key at index $index: ${keyName ?? "null"}');
    } catch (e) {
      _showError('Error getting key: $e');
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

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Clear'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _showSetItemDialog() async {
    final keyController = TextEditingController();
    final valueController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Set Item (${_isLocalStorageTab ? "localStorage" : "sessionStorage"})',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Key *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Value *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (keyController.text.isEmpty || valueController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Key and Value are required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              setState(() => _isLoading = true);
              try {
                final storage = _isLocalStorageTab
                    ? _localStorage
                    : _sessionStorage;
                await storage?.setItem(
                  key: keyController.text,
                  value: valueController.text,
                );
                _showSuccess('Item set successfully');
                await _getItems();
              } catch (e) {
                _showError('Error setting item: $e');
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Set Item'),
          ),
        ],
      ),
    );
  }

  Future<void> _showKeyIndexDialog() async {
    final indexController = TextEditingController(text: '0');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Get Key at Index'),
        content: TextField(
          controller: indexController,
          decoration: const InputDecoration(
            labelText: 'Index',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final index = int.tryParse(indexController.text);
              if (index == null || index < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid index'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _key(index);
            },
            child: const Text('Get Key'),
          ),
        ],
      ),
    );
  }

  Future<void> _showGetItemDialog() async {
    final keyController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Get Item by Key'),
        content: TextField(
          controller: keyController,
          decoration: const InputDecoration(
            labelText: 'Key',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (keyController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a key'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _getItem(keyController.text);
            },
            child: const Text('Get Item'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Storage'),
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
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'LocalStorage'),
            Tab(text: 'SessionStorage'),
          ],
          indicatorColor: Colors.white,
        ),
      ),
      drawer: buildDrawer(context: context),
      body: Column(
        children: [
          _buildWebViewSection(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStorageView(
                  items: _localStorageItems,
                  length: _localStorageLength,
                  isLocal: true,
                ),
                _buildStorageView(
                  items: _sessionStorageItems,
                  length: _sessionStorageLength,
                  isLocal: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebViewSection() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    hintText: 'https://example.com',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _loadUrl, child: const Text('Load')),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri(_urlController.text),
                  ),
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                  ),
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                  },
                  onLoadStop: (controller, url) {
                    setState(() => _webViewReady = true);
                  },
                  onLoadError: (controller, url, code, message) {
                    _showError('Load error: $message');
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.all(4),
                  child: Text(
                    _webViewReady ? 'WebView Ready ✓' : 'Loading WebView...',
                    style: TextStyle(
                      color: _webViewReady ? Colors.green : Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!_webViewReady)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'WebStorage requires a loaded WebView. Load a page to enable storage methods.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStorageView({
    required List<WebStorageItem> items,
    required int? length,
    required bool isLocal,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMethodSection(
          'length',
          'Get number of items in storage',
          PlatformLocalStorageMethod.length,
          _getLength,
        ),
        _buildMethodSection(
          'setItem',
          'Set a key-value pair',
          PlatformLocalStorageMethod.setItem,
          _setItem,
        ),
        _buildMethodSection(
          'getItem',
          'Get value by key',
          PlatformLocalStorageMethod.getItem,
          _showGetItemDialog,
        ),
        _buildMethodSection(
          'removeItem',
          'Remove item by key (select from list)',
          PlatformLocalStorageMethod.removeItem,
          null,
        ),
        _buildMethodSection(
          'getItems',
          'Get all items',
          PlatformLocalStorageMethod.getItems,
          _getItems,
        ),
        _buildMethodSection(
          'clear',
          'Clear all items',
          PlatformLocalStorageMethod.clear,
          _clear,
        ),
        _buildMethodSection(
          'key',
          'Get key at index',
          PlatformLocalStorageMethod.key,
          _showKeyIndexDialog,
        ),
        const SizedBox(height: 16),
        _buildItemsList(items, length),
      ],
    );
  }

  Widget _buildMethodSection(
    String methodName,
    String description,
    PlatformLocalStorageMethod method,
    VoidCallback? onPressed,
  ) {
    final supportedPlatforms = _getSupportedPlatformsForMethod(method);
    final isSupported = supportedPlatforms.contains(_currentPlatform);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          methodName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSupported ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isSupported ? Colors.grey.shade600 : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            SupportBadge(
              supportedPlatforms: supportedPlatforms,
              currentPlatform: _currentPlatform,
            ),
          ],
        ),
        trailing: onPressed != null
            ? ElevatedButton(
                onPressed: isSupported && !_isLoading && _webViewReady
                    ? onPressed
                    : null,
                child: const Text('Run'),
              )
            : null,
        isThreeLine: true,
      ),
    );
  }

  Widget _buildItemsList(List<WebStorageItem> items, int? length) {
    final storageName = _isLocalStorageTab ? 'localStorage' : 'sessionStorage';

    if (items.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.storage_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No $storageName items found',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  _webViewReady
                      ? 'Click "Get All Items" to fetch storage contents'
                      : 'Load a page first, then fetch items',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '$storageName (${length ?? items.length} items)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isLoading || !_webViewReady ? null : _getItems,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(
                  item.key ?? 'null',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  item.value?.toString() ?? 'null',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.content_copy, size: 20),
                      onPressed: () {
                        _getItem(item.key ?? '');
                      },
                      tooltip: 'Get Item Value',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () {
                        _removeItem(item.key ?? '');
                      },
                      tooltip: 'Remove Item',
                      color: Colors.red,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
