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

  List<Cookie> _cookies = [];
  bool _isLoading = false;

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
        _recordMethodResult(
          'setCookie',
          'Failed to set cookie',
          isError: true,
        );
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
          'Cookie deleted',
          isError: false,
        );
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
        _recordMethodResult(
          'deleteCookie',
          'Cookie deleted',
          isError: false,
        );
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
      _recordMethodResult(
        'flush',
        'Error flushing cookies: $e',
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

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Cookies (${_cookies.length})',
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
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _cookies.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final cookie = _cookies[index];
              return ExpansionTile(
                title: Text(
                  cookie.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  cookie.value?.toString() ?? 'null',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.info_outline, size: 20),
                      onPressed: () => _getCookie(
                        url: _urlController.text.trim(),
                        name: cookie.name,
                      ),
                      tooltip: 'Get Cookie Details',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => _deleteCookie(cookie),
                      tooltip: 'Delete Cookie',
                      color: Colors.red,
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCookieAttribute('Domain', cookie.domain),
                        _buildCookieAttribute('Path', cookie.path),
                        _buildCookieAttribute(
                          'Expires',
                          cookie.expiresDate != null
                              ? DateTime.fromMillisecondsSinceEpoch(
                                  cookie.expiresDate!,
                                ).toString()
                              : null,
                        ),
                        _buildCookieAttribute(
                          'Secure',
                          cookie.isSecure?.toString(),
                        ),
                        _buildCookieAttribute(
                          'HttpOnly',
                          cookie.isHttpOnly?.toString(),
                        ),
                        _buildCookieAttribute(
                          'Session Only',
                          cookie.isSessionOnly?.toString(),
                        ),
                        _buildCookieAttribute(
                          'SameSite',
                          cookie.sameSite?.toString(),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCookieAttribute(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'null',
              style: TextStyle(
                fontSize: 12,
                color: value != null ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
