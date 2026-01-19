import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/main.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';
import 'package:flutter_inappwebview_example/widgets/common/support_badge.dart';
import 'package:flutter_inappwebview_example/widgets/common/parameter_dialog.dart';
import 'package:flutter_inappwebview_example/widgets/common/method_result_history.dart';

/// Screen for testing CookieManager functionality
class CookieManagerScreen extends StatefulWidget {
  const CookieManagerScreen({super.key});

  @override
  State<CookieManagerScreen> createState() => _CookieManagerScreenState();
}

class _CookieManagerScreenState extends State<CookieManagerScreen> {
  final CookieManager _cookieManager = CookieManager.instance();
  final TextEditingController _urlController = TextEditingController(
    text: 'https://example.com',
  );
  final TextEditingController _searchController = TextEditingController();

  List<Cookie> _cookies = [];
  bool _isLoading = false;

  // Sorting state
  String _sortColumn = 'name';
  bool _sortAscending = true;

  // Search state
  String _searchQuery = '';

  final Map<String, List<MethodResultEntry>> _methodHistory = {};
  final Map<String, int> _selectedHistoryIndex = {};
  static const int _maxHistoryEntries = 3;

  Future<void> _getCookies() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _recordMethodResult('getCookies', 'Please enter a URL', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final cookies = await _cookieManager.getCookies(url: WebUri(url));
      setState(() => _cookies = cookies);
      _recordMethodResult(
        'getCookies',
        'Found ${cookies.length} cookies',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        'getCookies',
        'Error getting cookies: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getAllCookies() async {
    setState(() => _isLoading = true);
    try {
      final cookies = await _cookieManager.getAllCookies();
      setState(() => _cookies = cookies);
      _recordMethodResult(
        'getAllCookies',
        'Found ${cookies.length} cookies',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        'getAllCookies',
        'Error getting all cookies: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getCookie({required String url, required String name}) async {
    setState(() => _isLoading = true);
    try {
      final cookie = await _cookieManager.getCookie(
        url: WebUri(url),
        name: name,
      );
      if (cookie != null) {
        _showCookieDetailsDialog(cookie);
        _recordMethodResult(
          'getCookie',
          'Cookie found for "$name"',
          isError: false,
        );
      } else {
        _recordMethodResult('getCookie', 'Cookie not found', isError: true);
      }
    } catch (e) {
      _recordMethodResult(
        'getCookie',
        'Error getting cookie: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setCookie() async {
    final params = await showParameterDialog(
      context: context,
      title: 'Set Cookie',
      parameters: {
        'url': _urlController.text.trim(),
        'name': '',
        'value': '',
        'path': '/',
        'domain': '',
        'expiresDate': const ParameterValueHint<DateTime?>(
          null,
          ParameterValueType.date,
        ),
        'maxAge': 3600,
        'isSecure': false,
        'isHttpOnly': false,
        'sameSite': '',
      },
      requiredPaths: ['url', 'name', 'value'],
    );

    if (params == null) return;

    final url = params['url']?.toString() ?? '';
    if (url.isEmpty) {
      _recordMethodResult('setCookie', 'Please enter a URL', isError: true);
      return;
    }

    final sameSiteValue = params['sameSite']?.toString();
    HTTPCookieSameSitePolicy? sameSite;
    if (sameSiteValue != null && sameSiteValue.trim().isNotEmpty) {
      sameSite = HTTPCookieSameSitePolicy.values.firstWhere(
        (policy) => policy.name().toLowerCase() == sameSiteValue.toLowerCase(),
        orElse: () => HTTPCookieSameSitePolicy.LAX,
      );
    }

    setState(() => _isLoading = true);
    try {
      final path = params['path']?.toString();
      final result = await _cookieManager.setCookie(
        url: WebUri(url),
        name: params['name']?.toString() ?? '',
        value: params['value']?.toString() ?? '',
        path: path?.isNotEmpty == true ? path! : '/',
        domain: params['domain']?.toString().isNotEmpty == true
            ? params['domain']?.toString()
            : null,
        expiresDate:
            (params['expiresDate'] as DateTime?)?.millisecondsSinceEpoch,
        maxAge: (params['maxAge'] as num?)?.toInt(),
        isSecure: params['isSecure'] as bool? ?? false,
        isHttpOnly: params['isHttpOnly'] as bool? ?? false,
        sameSite: sameSite,
      );
      if (result) {
        _recordMethodResult(
          'setCookie',
          'Cookie set successfully',
          isError: false,
        );
        await _getCookies();
      } else {
        _recordMethodResult('setCookie', 'Failed to set cookie', isError: true);
      }
    } catch (e) {
      _recordMethodResult(
        'setCookie',
        'Error setting cookie: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCookie(Cookie cookie, {String? urlOverride}) async {
    final url = urlOverride ?? _urlController.text.trim();
    if (url.isEmpty) {
      _recordMethodResult('deleteCookie', 'Please enter a URL', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final result = await _cookieManager.deleteCookie(
        url: WebUri(url),
        name: cookie.name,
        path: cookie.path ?? '/',
        domain: cookie.domain,
      );
      if (result) {
        _recordMethodResult(
          'deleteCookie',
          'Cookie "${cookie.name}" deleted',
          isError: false,
        );
        // Remove the cookie from local list
        setState(() {
          _cookies.removeWhere(
            (c) =>
                c.name == cookie.name &&
                c.domain == cookie.domain &&
                c.path == cookie.path,
          );
        });
      } else {
        _recordMethodResult(
          'deleteCookie',
          'Failed to delete cookie',
          isError: true,
        );
      }
    } catch (e) {
      _recordMethodResult(
        'deleteCookie',
        'Error deleting cookie: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmAndDeleteCookie(Cookie cookie) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Cookie'),
            content: Text(
              'Are you sure you want to delete the cookie "${cookie.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    // Determine URL to use for deletion
    // If we have a URL in the field, use that. Otherwise, try to construct one from the domain
    String url = _urlController.text.trim();
    if (url.isEmpty && cookie.domain != null) {
      // Construct a URL from the cookie domain
      final domain = cookie.domain!.startsWith('.')
          ? cookie.domain!.substring(1)
          : cookie.domain!;
      url = 'https://$domain${cookie.path ?? '/'}';
    }

    if (url.isEmpty) {
      _recordMethodResult(
        'deleteCookie',
        'Cannot delete cookie: No URL provided and cookie has no domain',
        isError: true,
      );
      return;
    }

    await _deleteCookie(cookie, urlOverride: url);
  }

  Future<void> _deleteCookieByParams({
    required String url,
    required String name,
    String? path,
    String? domain,
  }) async {
    setState(() => _isLoading = true);
    try {
      final result = await _cookieManager.deleteCookie(
        url: WebUri(url),
        name: name,
        path: path ?? '/',
        domain: domain,
      );
      if (result) {
        _recordMethodResult('deleteCookie', 'Cookie deleted', isError: false);
        await _getCookies();
      } else {
        _recordMethodResult(
          'deleteCookie',
          'Failed to delete cookie',
          isError: true,
        );
      }
    } catch (e) {
      _recordMethodResult(
        'deleteCookie',
        'Error deleting cookie: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _promptGetCookie() async {
    final params = await showParameterDialog(
      context: context,
      title: 'Get Cookie',
      parameters: {'url': _urlController.text.trim(), 'name': ''},
      requiredPaths: ['url', 'name'],
    );

    if (params == null) return;
    final url = params['url']?.toString() ?? '';
    final name = params['name']?.toString() ?? '';
    if (url.isEmpty || name.isEmpty) {
      _recordMethodResult(
        'getCookie',
        'URL and name are required',
        isError: true,
      );
      return;
    }
    _urlController.text = url;
    await _getCookie(url: url, name: name);
  }

  Future<void> _promptDeleteCookie() async {
    final params = await showParameterDialog(
      context: context,
      title: 'Delete Cookie',
      parameters: {
        'url': _urlController.text.trim(),
        'name': '',
        'path': '/',
        'domain': '',
      },
      requiredPaths: ['url', 'name'],
    );

    if (params == null) return;
    final url = params['url']?.toString() ?? '';
    final name = params['name']?.toString() ?? '';
    if (url.isEmpty || name.isEmpty) {
      _recordMethodResult(
        'deleteCookie',
        'URL and name are required',
        isError: true,
      );
      return;
    }
    _urlController.text = url;
    await _deleteCookieByParams(
      url: url,
      name: name,
      path: params['path']?.toString().isNotEmpty == true
          ? params['path']?.toString()
          : '/',
      domain: params['domain']?.toString().isNotEmpty == true
          ? params['domain']?.toString()
          : null,
    );
  }

  Future<void> _deleteCookies() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _recordMethodResult('deleteCookies', 'Please enter a URL', isError: true);
      return;
    }

    final confirmed = await _showConfirmDialog(
      'Delete All Cookies for URL',
      'Are you sure you want to delete all cookies for this URL?',
    );
    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      final result = await _cookieManager.deleteCookies(url: WebUri(url));
      if (result) {
        _recordMethodResult(
          'deleteCookies',
          'Cookies deleted for URL',
          isError: false,
        );
        setState(() => _cookies = []);
      } else {
        _recordMethodResult(
          'deleteCookies',
          'Failed to delete cookies',
          isError: true,
        );
      }
    } catch (e) {
      _recordMethodResult(
        'deleteCookies',
        'Error deleting cookies: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAllCookies() async {
    final confirmed = await _showConfirmDialog(
      'Delete All Cookies',
      'Are you sure you want to delete ALL cookies?',
    );
    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      final result = await _cookieManager.deleteAllCookies();
      if (result) {
        _recordMethodResult(
          'deleteAllCookies',
          'All cookies deleted',
          isError: false,
        );
        setState(() => _cookies = []);
      } else {
        _recordMethodResult(
          'deleteAllCookies',
          'Failed to delete all cookies',
          isError: true,
        );
      }
    } catch (e) {
      _recordMethodResult(
        'deleteAllCookies',
        'Error deleting all cookies: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeSessionCookies() async {
    setState(() => _isLoading = true);
    try {
      final result = await _cookieManager.removeSessionCookies();
      _recordMethodResult(
        'removeSessionCookies',
        result ? 'Session cookies removed' : 'No session cookies to remove',
        isError: !result,
      );
    } catch (e) {
      _recordMethodResult(
        'removeSessionCookies',
        'Error removing session cookies: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _flush() async {
    setState(() => _isLoading = true);
    try {
      await _cookieManager.flush();
      _recordMethodResult(
        'flush',
        'Cookies flushed to persistent storage',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult('flush', 'Error flushing cookies: $e', isError: true);
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
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showCookieDetailsDialog(Cookie cookie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(cookie.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Value', cookie.value?.toString() ?? 'null'),
              _buildDetailRow('Domain', cookie.domain ?? 'null'),
              _buildDetailRow('Path', cookie.path ?? 'null'),
              _buildDetailRow(
                'Expires',
                cookie.expiresDate != null
                    ? DateTime.fromMillisecondsSinceEpoch(
                        cookie.expiresDate!,
                      ).toString()
                    : 'null',
              ),
              _buildDetailRow('Secure', cookie.isSecure?.toString() ?? 'null'),
              _buildDetailRow(
                'HttpOnly',
                cookie.isHttpOnly?.toString() ?? 'null',
              ),
              _buildDetailRow(
                'Session Only',
                cookie.isSessionOnly?.toString() ?? 'null',
              ),
              _buildDetailRow(
                'SameSite',
                cookie.sameSite?.toString() ?? 'null',
              ),
            ],
          ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cookie Manager'),
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
      ),
      drawer: buildDrawer(context: context),
      body: Column(
        children: [
          _buildUrlInput(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMethodSection(
                  'setCookie',
                  'Set a cookie for the given URL',
                  PlatformCookieManagerMethod.setCookie,
                  _setCookie,
                ),
                _buildMethodSection(
                  'getCookies',
                  'Get all cookies for the given URL',
                  PlatformCookieManagerMethod.getCookies,
                  _getCookies,
                ),
                _buildMethodSection(
                  'getCookie',
                  'Get a specific cookie by name (requires cookie list)',
                  PlatformCookieManagerMethod.getCookie,
                  _promptGetCookie,
                ),
                _buildMethodSection(
                  'deleteCookie',
                  'Delete a specific cookie (select from list)',
                  PlatformCookieManagerMethod.deleteCookie,
                  _promptDeleteCookie,
                ),
                _buildMethodSection(
                  'deleteCookies',
                  'Delete all cookies for the URL',
                  PlatformCookieManagerMethod.deleteCookies,
                  _deleteCookies,
                ),
                _buildMethodSection(
                  'deleteAllCookies',
                  'Delete all cookies',
                  PlatformCookieManagerMethod.deleteAllCookies,
                  _deleteAllCookies,
                ),
                _buildMethodSection(
                  'getAllCookies',
                  'Get all cookies',
                  PlatformCookieManagerMethod.getAllCookies,
                  _getAllCookies,
                ),
                _buildMethodSection(
                  'removeSessionCookies',
                  'Remove session cookies',
                  PlatformCookieManagerMethod.removeSessionCookies,
                  _removeSessionCookies,
                ),
                _buildMethodSection(
                  'flush',
                  'Flush cookies to persistent storage',
                  PlatformCookieManagerMethod.flush,
                  _flush,
                ),
                const SizedBox(height: 16),
                _buildCookiesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
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
          ElevatedButton(
            onPressed: _isLoading ? null : _getCookies,
            child: const Text('Get Cookies'),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodSection(
    String methodName,
    String description,
    PlatformCookieManagerMethod method,
    VoidCallback? onPressed,
  ) {
    final supportedPlatforms = SupportCheckHelper.supportedPlatformsForMethod(
      method: method,
      checker: CookieManager.isMethodSupported,
    );

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
            _buildMethodHistory(methodName),
          ],
        ),
        trailing: onPressed != null
            ? ElevatedButton(
                onPressed: !_isLoading ? onPressed : null,
                child: const Text('Run'),
              )
            : null,
      ),
    );
  }

  Widget _buildCookiesList() {
    if (_cookies.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.cookie_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No cookies found',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter a URL and click "Get Cookies" to fetch cookies',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final filteredCookies = _filteredAndSortedCookies;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Cookies (${filteredCookies.length}${filteredCookies.length != _cookies.length ? ' of ${_cookies.length}' : ''})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _isLoading ? null : _getCookies,
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search cookies...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (filteredCookies.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No cookies match your search',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortColumnIndex: _getSortColumnIndex(),
                sortAscending: _sortAscending,
                headingRowHeight: 48,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 56,
                columnSpacing: 16,
                horizontalMargin: 16,
                columns: [
                  DataColumn(
                    label: const Text(
                      'Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onSort: (_, __) => _onSort('name'),
                  ),
                  DataColumn(
                    label: const Text(
                      'Value',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onSort: (_, __) => _onSort('value'),
                  ),
                  DataColumn(
                    label: const Text(
                      'Domain',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onSort: (_, __) => _onSort('domain'),
                  ),
                  DataColumn(
                    label: const Text(
                      'Path',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onSort: (_, __) => _onSort('path'),
                  ),
                  DataColumn(
                    label: const Text(
                      'Expires',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onSort: (_, __) => _onSort('expires'),
                  ),
                  DataColumn(
                    label: const Text(
                      'Secure',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onSort: (_, __) => _onSort('secure'),
                  ),
                  const DataColumn(
                    label: Text(
                      'Actions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: filteredCookies
                    .map(
                      (cookie) => DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: 120,
                              child: Text(
                                cookie.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 150,
                              child: Text(
                                cookie.value?.toString() ?? 'null',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cookie.value != null
                                      ? Colors.black87
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 100,
                              child: Text(
                                cookie.domain ?? '-',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 60,
                              child: Text(
                                cookie.path ?? '/',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 140,
                              child: Text(
                                cookie.expiresDate != null
                                    ? DateTime.fromMillisecondsSinceEpoch(
                                        cookie.expiresDate!,
                                      ).toLocal().toString().split('.')[0]
                                    : 'Session',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                          DataCell(
                            Icon(
                              cookie.isSecure == true
                                  ? Icons.lock
                                  : Icons.lock_open,
                              size: 18,
                              color: cookie.isSecure == true
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.visibility_outlined,
                                    size: 18,
                                  ),
                                  onPressed: () =>
                                      _showCookieDetailsDialog(cookie),
                                  tooltip: 'View Details',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _confirmAndDeleteCookie(cookie),
                                  tooltip: 'Delete',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  int? _getSortColumnIndex() {
    switch (_sortColumn) {
      case 'name':
        return 0;
      case 'value':
        return 1;
      case 'domain':
        return 2;
      case 'path':
        return 3;
      case 'expires':
        return 4;
      case 'secure':
        return 5;
      default:
        return null;
    }
  }

  /// Get filtered and sorted cookies
  List<Cookie> get _filteredAndSortedCookies {
    var result = List<Cookie>.from(_cookies);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((cookie) {
        return cookie.name.toLowerCase().contains(query) ||
            (cookie.value?.toString().toLowerCase().contains(query) ?? false) ||
            (cookie.domain?.toLowerCase().contains(query) ?? false) ||
            (cookie.path?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply sorting
    result.sort((a, b) {
      int comparison;
      switch (_sortColumn) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'value':
          comparison = (a.value?.toString() ?? '').compareTo(
            b.value?.toString() ?? '',
          );
          break;
        case 'domain':
          comparison = (a.domain ?? '').compareTo(b.domain ?? '');
          break;
        case 'path':
          comparison = (a.path ?? '').compareTo(b.path ?? '');
          break;
        case 'expires':
          comparison = (a.expiresDate ?? 0).compareTo(b.expiresDate ?? 0);
          break;
        case 'secure':
          comparison = (a.isSecure == true ? 1 : 0).compareTo(
            b.isSecure == true ? 1 : 0,
          );
          break;
        default:
          comparison = 0;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return result;
  }

  void _onSort(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
