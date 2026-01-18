import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/main.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';
import 'package:flutter_inappwebview_example/widgets/common/support_badge.dart';
import 'package:flutter_inappwebview_example/widgets/common/parameter_dialog.dart';
import 'package:flutter_inappwebview_example/widgets/common/method_result_history.dart';

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
  double _webViewHeight = 140;
  static const double _minWebViewHeight = 100;
  static const double _minContentHeight = 260;
  static const double _dividerHeight = 6;

  // LocalStorage state
  List<WebStorageItem> _localStorageItems = [];
  int? _localStorageLength;

  // SessionStorage state
  List<WebStorageItem> _sessionStorageItems = [];
  int? _sessionStorageLength;

  final TextEditingController _urlController = TextEditingController(
    text: 'https://example.com',
  );

  final Map<String, List<MethodResultEntry>> _methodHistory = {};
  final Map<String, int> _selectedHistoryIndex = {};
  static const int _maxHistoryEntries = 3;

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

  String _storageMethodKey(String methodName) {
    return '${_isLocalStorageTab ? 'localStorage' : 'sessionStorage'}.$methodName';
  }

  Set<SupportedPlatform> _getStorageMethodPlatforms(
    String methodName, {
    required bool isLocal,
  }) {
    if (isLocal) {
      final method = PlatformLocalStorageMethod.values.firstWhere(
        (m) => m.name == methodName,
      );
      return SupportCheckHelper.supportedPlatformsForMethod(
        method: method,
        checker: LocalStorage.isMethodSupported,
      );
    }

    final method = PlatformSessionStorageMethod.values.firstWhere(
      (m) => m.name == methodName,
    );
    return SupportCheckHelper.supportedPlatformsForMethod(
      method: method,
      checker: SessionStorage.isMethodSupported,
    );
  }

  Future<void> _loadUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _recordMethodResult('loadUrl', 'Please enter a URL', isError: true);
      return;
    }

    try {
      await _webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(url)),
      );
    } catch (e) {
      _recordMethodResult('loadUrl', 'Error loading URL: $e', isError: true);
    }
  }

  Future<void> _getLength() async {
    if (!_webViewReady) {
      _recordMethodResult(
        _storageMethodKey('length'),
        'WebView not ready. Load a page first.',
        isError: true,
      );
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
      _recordMethodResult(
        _storageMethodKey('length'),
        'Storage length: $length',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        _storageMethodKey('length'),
        'Error getting length: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getItems() async {
    if (!_webViewReady) {
      _recordMethodResult(
        _storageMethodKey('getItems'),
        'WebView not ready. Load a page first.',
        isError: true,
      );
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
      _recordMethodResult(
        _storageMethodKey('getItems'),
        'Found ${items.length} items',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        _storageMethodKey('getItems'),
        'Error getting items: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getItem(String key) async {
    if (!_webViewReady) {
      _recordMethodResult(
        _storageMethodKey('getItem'),
        'WebView not ready. Load a page first.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final storage = _isLocalStorageTab ? _localStorage : _sessionStorage;
      final value = await storage?.getItem(key: key);
      _recordMethodResult(
        _storageMethodKey('getItem'),
        'Value for "$key": ${value ?? "null"}',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        _storageMethodKey('getItem'),
        'Error getting item: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setItem() async {
    if (!_webViewReady) {
      _recordMethodResult(
        _storageMethodKey('setItem'),
        'WebView not ready. Load a page first.',
        isError: true,
      );
      return;
    }

    await _promptSetItem();
  }

  Future<void> _removeItem(String key) async {
    if (!_webViewReady) {
      _recordMethodResult(
        _storageMethodKey('removeItem'),
        'WebView not ready. Load a page first.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final storage = _isLocalStorageTab ? _localStorage : _sessionStorage;
      await storage?.removeItem(key: key);
      _recordMethodResult(
        _storageMethodKey('removeItem'),
        'Item "$key" removed',
        isError: false,
      );
      await _getItems();
    } catch (e) {
      _recordMethodResult(
        _storageMethodKey('removeItem'),
        'Error removing item: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _promptRemoveItem() async {
    final params = await showParameterDialog(
      context: context,
      title: 'Remove Item',
      parameters: {'key': ''},
      requiredPaths: ['key'],
    );

    if (params == null) return;
    final key = params['key']?.toString() ?? '';
    if (key.isEmpty) {
      _recordMethodResult(
        _storageMethodKey('removeItem'),
        'Please enter a key',
        isError: true,
      );
      return;
    }
    _removeItem(key);
  }

  Future<void> _clear() async {
    if (!_webViewReady) {
      _recordMethodResult(
        _storageMethodKey('clear'),
        'WebView not ready. Load a page first.',
        isError: true,
      );
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
      _recordMethodResult(
        _storageMethodKey('clear'),
        'Storage cleared',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        _storageMethodKey('clear'),
        'Error clearing storage: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _key(int index) async {
    if (!_webViewReady) {
      _recordMethodResult(
        _storageMethodKey('key'),
        'WebView not ready. Load a page first.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final storage = _isLocalStorageTab ? _localStorage : _sessionStorage;
      final keyName = await storage?.key(index: index);
      _recordMethodResult(
        _storageMethodKey('key'),
        'Key at index $index: ${keyName ?? "null"}',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        _storageMethodKey('key'),
        'Error getting key: $e',
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
        ),
      );
      if (entries.length > _maxHistoryEntries) {
        entries.removeRange(_maxHistoryEntries, entries.length);
      }
      _methodHistory[methodName] = entries;
      _selectedHistoryIndex[methodName] = 0;
    });
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

  Future<void> _promptSetItem() async {
    final params = await showParameterDialog(
      context: context,
      title:
          'Set Item (${_isLocalStorageTab ? "localStorage" : "sessionStorage"})',
      parameters: {'key': '', 'value': ''},
      requiredPaths: ['key', 'value'],
    );

    if (params == null) return;
    final key = params['key']?.toString() ?? '';
    final value = params['value']?.toString() ?? '';
    if (key.isEmpty || value.isEmpty) {
      _recordMethodResult(
        _storageMethodKey('setItem'),
        'Key and Value are required',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final storage = _isLocalStorageTab ? _localStorage : _sessionStorage;
      await storage?.setItem(key: key, value: value);
      _recordMethodResult(
        _storageMethodKey('setItem'),
        'Item set successfully',
        isError: false,
      );
      await _getItems();
    } catch (e) {
      _recordMethodResult(
        _storageMethodKey('setItem'),
        'Error setting item: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _promptKeyIndex() async {
    final params = await showParameterDialog(
      context: context,
      title: 'Get Key at Index',
      parameters: {'index': 0},
      requiredPaths: ['index'],
    );

    if (params == null) return;
    final index = (params['index'] as num?)?.toInt();
    if (index == null || index < 0) {
      _recordMethodResult(
        _storageMethodKey('key'),
        'Please enter a valid index',
        isError: true,
      );
      return;
    }
    _key(index);
  }

  Future<void> _promptGetItem() async {
    final params = await showParameterDialog(
      context: context,
      title: 'Get Item by Key',
      parameters: {'key': ''},
      requiredPaths: ['key'],
    );

    if (params == null) return;
    final key = params['key']?.toString() ?? '';
    if (key.isEmpty) {
      _recordMethodResult(
        _storageMethodKey('getItem'),
        'Please enter a key',
        isError: true,
      );
      return;
    }
    _getItem(key);
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
      body: LayoutBuilder(
        builder: (context, constraints) {
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
          );
        },
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
          _buildMethodHistory('loadUrl'),
          const SizedBox(height: 8),
          Expanded(
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
                    _recordMethodResult(
                      'loadUrl',
                      'Load error: $message',
                      isError: true,
                    );
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
          _getStorageMethodPlatforms('length', isLocal: isLocal),
          _getLength,
        ),
        _buildMethodSection(
          'setItem',
          'Set a key-value pair',
          _getStorageMethodPlatforms('setItem', isLocal: isLocal),
          _setItem,
        ),
        _buildMethodSection(
          'getItem',
          'Get value by key',
          _getStorageMethodPlatforms('getItem', isLocal: isLocal),
          _promptGetItem,
        ),
        _buildMethodSection(
          'removeItem',
          'Remove item by key (select from list)',
          _getStorageMethodPlatforms('removeItem', isLocal: isLocal),
          _promptRemoveItem,
        ),
        _buildMethodSection(
          'getItems',
          'Get all items',
          _getStorageMethodPlatforms('getItems', isLocal: isLocal),
          _getItems,
        ),
        _buildMethodSection(
          'clear',
          'Clear all items',
          _getStorageMethodPlatforms('clear', isLocal: isLocal),
          _clear,
        ),
        _buildMethodSection(
          'key',
          'Get key at index',
          _getStorageMethodPlatforms('key', isLocal: isLocal),
          _promptKeyIndex,
        ),
        const SizedBox(height: 16),
        _buildItemsList(items, length),
      ],
    );
  }

  Widget _buildMethodSection(
    String methodName,
    String description,
    Set<SupportedPlatform> supportedPlatforms,
    VoidCallback? onPressed,
  ) {
    final historyKey = _storageMethodKey(methodName);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
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
            _buildMethodHistory(historyKey, title: methodName),
          ],
        ),
        trailing: onPressed != null
            ? ElevatedButton(
                onPressed: !_isLoading && _webViewReady ? onPressed : null,
                child: const Text('Run'),
              )
            : null,
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
