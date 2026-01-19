import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/main.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';
import 'package:flutter_inappwebview_example/widgets/common/support_badge.dart';
import 'package:flutter_inappwebview_example/widgets/common/parameter_dialog.dart';
import 'package:flutter_inappwebview_example/widgets/common/method_result_history.dart';

/// Screen for testing HttpAuthCredentialDatabase functionality
class HttpAuthScreen extends StatefulWidget {
  const HttpAuthScreen({super.key});

  @override
  State<HttpAuthScreen> createState() => _HttpAuthScreenState();
}

class _HttpAuthScreenState extends State<HttpAuthScreen> {
  final HttpAuthCredentialDatabase _db = HttpAuthCredentialDatabase.instance();
  List<URLProtectionSpaceHttpAuthCredentials> _allCredentials = [];
  bool _isLoading = false;

  final Map<String, List<MethodResultEntry>> _methodHistory = {};
  final Map<String, int> _selectedHistoryIndex = {};
  static const int _maxHistoryEntries = 3;

  @override
  void initState() {
    super.initState();
    _getAllAuthCredentials();
  }

  Future<void> _getAllAuthCredentials() async {
    setState(() => _isLoading = true);
    try {
      final credentials = await _db.getAllAuthCredentials();
      setState(() => _allCredentials = credentials);
      _recordMethodResult(
        'getAllAuthCredentials',
        'Found ${credentials.length} protection spaces',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        'getAllAuthCredentials',
        'Error getting credentials: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getHttpAuthCredentials(
    URLProtectionSpace protectionSpace,
  ) async {
    setState(() => _isLoading = true);
    try {
      final credentials = await _db.getHttpAuthCredentials(
        protectionSpace: protectionSpace,
      );
      _showCredentialsDialog(protectionSpace, credentials);
      _recordMethodResult(
        'getHttpAuthCredentials',
        'Found ${credentials.length} credential(s)',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        'getHttpAuthCredentials',
        'Error getting credentials: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setHttpAuthCredential() async {
    final params = await showParameterDialog(
      context: context,
      title: 'Add Credential',
      parameters: {
        'protectionSpace': {
          'host': '',
          'protocol': 'https',
          'port': 443,
          'realm': '',
        },
        'credential': {'username': '', 'password': ''},
      },
      requiredPaths: [
        'protectionSpace.host',
        'credential.username',
        'credential.password',
      ],
    );

    if (params == null) return;
    await _applyCredentialFromParams(params);
  }

  Future<void> _removeHttpAuthCredential(
    URLProtectionSpace protectionSpace,
    URLCredential credential,
  ) async {
    final confirmed = await _showConfirmDialog(
      'Remove Credential',
      'Are you sure you want to remove the credential for "${credential.username}"?',
    );
    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      await _db.removeHttpAuthCredential(
        protectionSpace: protectionSpace,
        credential: credential,
      );
      _recordMethodResult(
        'removeHttpAuthCredential',
        'Credential removed',
        isError: false,
      );
      await _getAllAuthCredentials();
    } catch (e) {
      _recordMethodResult(
        'removeHttpAuthCredential',
        'Error removing credential: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _promptGetHttpAuthCredentials() async {
    final params = await showParameterDialog(
      context: context,
      title: 'Get Credentials',
      parameters: {
        'protectionSpace': {
          'host': '',
          'protocol': 'https',
          'port': 443,
          'realm': '',
        },
      },
      requiredPaths: ['protectionSpace.host'],
    );

    if (params == null) return;
    final space = _protectionSpaceFromParams(params['protectionSpace']);
    if (space == null) {
      _recordMethodResult(
        'getHttpAuthCredentials',
        'Protection space host is required',
        isError: true,
      );
      return;
    }
    await _getHttpAuthCredentials(space);
  }

  Future<void> _promptRemoveHttpAuthCredential() async {
    final params = await showParameterDialog(
      context: context,
      title: 'Remove Credential',
      parameters: {
        'protectionSpace': {
          'host': '',
          'protocol': 'https',
          'port': 443,
          'realm': '',
        },
        'credential': {'username': '', 'password': ''},
      },
      requiredPaths: [
        'protectionSpace.host',
        'credential.username',
        'credential.password',
      ],
    );

    if (params == null) return;
    final space = _protectionSpaceFromParams(params['protectionSpace']);
    if (space == null) {
      _recordMethodResult(
        'removeHttpAuthCredential',
        'Protection space host is required',
        isError: true,
      );
      return;
    }
    final credential = _credentialFromParams(params['credential']);
    if (credential == null) {
      _recordMethodResult(
        'removeHttpAuthCredential',
        'Credential username and password are required',
        isError: true,
      );
      return;
    }
    await _removeHttpAuthCredential(space, credential);
  }

  Future<void> _promptRemoveHttpAuthCredentials() async {
    final params = await showParameterDialog(
      context: context,
      title: 'Remove Credentials',
      parameters: {
        'protectionSpace': {
          'host': '',
          'protocol': 'https',
          'port': 443,
          'realm': '',
        },
      },
      requiredPaths: ['protectionSpace.host'],
    );

    if (params == null) return;
    final space = _protectionSpaceFromParams(params['protectionSpace']);
    if (space == null) {
      _recordMethodResult(
        'removeHttpAuthCredentials',
        'Protection space host is required',
        isError: true,
      );
      return;
    }
    await _removeHttpAuthCredentials(space);
  }

  Future<void> _removeHttpAuthCredentials(
    URLProtectionSpace protectionSpace,
  ) async {
    final confirmed = await _showConfirmDialog(
      'Remove All Credentials for Protection Space',
      'Are you sure you want to remove all credentials for ${protectionSpace.host}?',
    );
    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      await _db.removeHttpAuthCredentials(protectionSpace: protectionSpace);
      _recordMethodResult(
        'removeHttpAuthCredentials',
        'Credentials removed for protection space',
        isError: false,
      );
      await _getAllAuthCredentials();
    } catch (e) {
      _recordMethodResult(
        'removeHttpAuthCredentials',
        'Error removing credentials: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearAllAuthCredentials() async {
    final confirmed = await _showConfirmDialog(
      'Clear All Credentials',
      'Are you sure you want to clear ALL HTTP auth credentials?',
    );
    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      await _db.clearAllAuthCredentials();
      setState(() => _allCredentials = []);
      _recordMethodResult(
        'clearAllAuthCredentials',
        'All credentials cleared',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        'clearAllAuthCredentials',
        'Error clearing credentials: $e',
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

  URLProtectionSpace? _protectionSpaceFromParams(dynamic raw) {
    if (raw is! Map) return null;
    final host = raw['host']?.toString() ?? '';
    if (host.isEmpty) return null;
    final protocol = raw['protocol']?.toString();
    final realm = raw['realm']?.toString();
    final port = (raw['port'] as num?)?.toInt();
    return URLProtectionSpace(
      host: host,
      protocol: protocol?.isNotEmpty == true ? protocol : null,
      port: port,
      realm: realm?.isNotEmpty == true ? realm : null,
    );
  }

  URLCredential? _credentialFromParams(dynamic raw) {
    if (raw is! Map) return null;
    final username = raw['username']?.toString() ?? '';
    final password = raw['password']?.toString() ?? '';
    if (username.isEmpty || password.isEmpty) return null;
    return URLCredential(username: username, password: password);
  }

  Future<void> _applyCredentialFromParams(Map<String, dynamic> params) async {
    final space = _protectionSpaceFromParams(params['protectionSpace']);
    final credential = _credentialFromParams(params['credential']);
    if (space == null || credential == null) {
      _recordMethodResult(
        'setHttpAuthCredential',
        'Protection space, username, and password are required',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _db.setHttpAuthCredential(
        protectionSpace: space,
        credential: credential,
      );
      _recordMethodResult(
        'setHttpAuthCredential',
        'Credential saved',
        isError: false,
      );
      await _getAllAuthCredentials();
    } catch (e) {
      _recordMethodResult(
        'setHttpAuthCredential',
        'Error saving credential: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
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

  void _showCredentialsDialog(
    URLProtectionSpace protectionSpace,
    List<URLCredential> credentials,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Credentials for ${protectionSpace.host}'),
        content: SizedBox(
          width: double.maxFinite,
          child: credentials.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No credentials found'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: credentials.length,
                  itemBuilder: (context, index) {
                    final cred = credentials[index];
                    return ListTile(
                      title: Text(cred.username ?? 'null'),
                      subtitle: Text(
                        'Password: ${'*' * (cred.password?.length ?? 0)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red,
                        onPressed: () {
                          Navigator.pop(context);
                          _removeHttpAuthCredential(protectionSpace, cred);
                        },
                      ),
                    );
                  },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTTP Auth Credentials'),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMethodSection(
            'getAllAuthCredentials',
            'Get all saved credentials',
            PlatformHttpAuthCredentialDatabaseMethod.getAllAuthCredentials,
            _getAllAuthCredentials,
          ),
          _buildMethodSection(
            'getHttpAuthCredentials',
            'Get credentials for a protection space (select from list)',
            PlatformHttpAuthCredentialDatabaseMethod.getHttpAuthCredentials,
            _promptGetHttpAuthCredentials,
          ),
          _buildMethodSection(
            'setHttpAuthCredential',
            'Save a new credential',
            PlatformHttpAuthCredentialDatabaseMethod.setHttpAuthCredential,
            _setHttpAuthCredential,
          ),
          _buildMethodSection(
            'removeHttpAuthCredential',
            'Remove a specific credential (select from list)',
            PlatformHttpAuthCredentialDatabaseMethod.removeHttpAuthCredential,
            _promptRemoveHttpAuthCredential,
          ),
          _buildMethodSection(
            'removeHttpAuthCredentials',
            'Remove all credentials for a protection space',
            PlatformHttpAuthCredentialDatabaseMethod.removeHttpAuthCredentials,
            _promptRemoveHttpAuthCredentials,
          ),
          _buildMethodSection(
            'clearAllAuthCredentials',
            'Clear all credentials',
            PlatformHttpAuthCredentialDatabaseMethod.clearAllAuthCredentials,
            _clearAllAuthCredentials,
          ),
          const SizedBox(height: 16),
          _buildCredentialsList(),
        ],
      ),
    );
  }

  Widget _buildMethodSection(
    String methodName,
    String description,
    PlatformHttpAuthCredentialDatabaseMethod method,
    VoidCallback? onPressed,
  ) {
    final supportedPlatforms = SupportCheckHelper.supportedPlatformsForMethod(
      method: method,
      checker: HttpAuthCredentialDatabase.isMethodSupported,
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

  Widget _buildCredentialsList() {
    if (_allCredentials.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.lock_outline, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No credentials found',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Click "Save a new credential" to add HTTP auth credentials',
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
                  'Protection Spaces (${_allCredentials.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isLoading ? null : _getAllAuthCredentials,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _allCredentials.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = _allCredentials[index];
              final protectionSpace = item.protectionSpace;
              final credentials = item.credentials ?? [];

              return ExpansionTile(
                title: Text(
                  protectionSpace?.host ?? 'Unknown Host',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  _buildProtectionSpaceDescription(protectionSpace),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${credentials.length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.visibility, size: 20),
                      onPressed: protectionSpace != null
                          ? () => _getHttpAuthCredentials(protectionSpace)
                          : null,
                      tooltip: 'View Credentials',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: protectionSpace != null
                          ? () => _removeHttpAuthCredentials(protectionSpace)
                          : null,
                      tooltip: 'Remove All for Protection Space',
                      color: Colors.red,
                    ),
                  ],
                ),
                children: [
                  if (credentials.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No credentials for this protection space',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  else
                    ...credentials.map((credential) {
                      return ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(credential.username ?? 'Unknown'),
                        subtitle: Text(
                          'Password: ${'*' * (credential.password?.length ?? 0)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: Colors.red,
                          onPressed: protectionSpace != null
                              ? () => _removeHttpAuthCredential(
                                  protectionSpace,
                                  credential,
                                )
                              : null,
                          tooltip: 'Remove Credential',
                        ),
                      );
                    }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _buildProtectionSpaceDescription(URLProtectionSpace? space) {
    if (space == null) return 'Unknown';

    final parts = <String>[];
    if (space.protocol != null) parts.add(space.protocol!);
    if (space.port != null) parts.add('Port: ${space.port}');
    if (space.realm != null) parts.add('Realm: ${space.realm}');

    return parts.isEmpty ? 'No additional details' : parts.join(' • ');
  }
}
