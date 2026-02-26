import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/widgets/common/app_drawer.dart';
import 'package:flutter_inappwebview_example/widgets/common/appbar_loading_indicator.dart';
import 'package:flutter_inappwebview_example/widgets/common/empty_state.dart';
import 'package:flutter_inappwebview_example/widgets/common/method_card.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';
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
        PlatformHttpAuthCredentialDatabaseMethod.getAllAuthCredentials.name,
        'Found ${credentials.length} protection spaces',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformHttpAuthCredentialDatabaseMethod.getAllAuthCredentials.name,
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
        PlatformHttpAuthCredentialDatabaseMethod.getHttpAuthCredentials.name,
        'Found ${credentials.length} credential(s)',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformHttpAuthCredentialDatabaseMethod.getHttpAuthCredentials.name,
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
        PlatformHttpAuthCredentialDatabaseMethod.removeHttpAuthCredential.name,
        'Credential removed',
        isError: false,
      );
      await _getAllAuthCredentials();
    } catch (e) {
      _recordMethodResult(
        PlatformHttpAuthCredentialDatabaseMethod.removeHttpAuthCredential.name,
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
        PlatformHttpAuthCredentialDatabaseMethod.getHttpAuthCredentials.name,
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
        PlatformHttpAuthCredentialDatabaseMethod.removeHttpAuthCredential.name,
        'Protection space host is required',
        isError: true,
      );
      return;
    }
    final credential = _credentialFromParams(params['credential']);
    if (credential == null) {
      _recordMethodResult(
        PlatformHttpAuthCredentialDatabaseMethod.removeHttpAuthCredential.name,
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
        PlatformHttpAuthCredentialDatabaseMethod.removeHttpAuthCredentials.name,
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
        PlatformHttpAuthCredentialDatabaseMethod.removeHttpAuthCredentials.name,
        'Credentials removed for protection space',
        isError: false,
      );
      await _getAllAuthCredentials();
    } catch (e) {
      _recordMethodResult(
        PlatformHttpAuthCredentialDatabaseMethod.removeHttpAuthCredentials.name,
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
        PlatformHttpAuthCredentialDatabaseMethod.clearAllAuthCredentials.name,
        'All credentials cleared',
        isError: false,
      );
    } catch (e) {
      _recordMethodResult(
        PlatformHttpAuthCredentialDatabaseMethod.clearAllAuthCredentials.name,
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
        PlatformHttpAuthCredentialDatabaseMethod.setHttpAuthCredential.name,
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
        PlatformHttpAuthCredentialDatabaseMethod.setHttpAuthCredential.name,
        'Credential saved',
        isError: false,
      );
      await _getAllAuthCredentials();
    } catch (e) {
      _recordMethodResult(
        PlatformHttpAuthCredentialDatabaseMethod.setHttpAuthCredential.name,
        'Error saving credential: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
        actions: [AppBarLoadingIndicator(isLoading: _isLoading)],
      ),
      drawer: AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMethodSection(
            PlatformHttpAuthCredentialDatabaseMethod.getAllAuthCredentials,
            'Get all saved credentials',
            _getAllAuthCredentials,
          ),
          _buildMethodSection(
            PlatformHttpAuthCredentialDatabaseMethod.getHttpAuthCredentials,
            'Get credentials for a protection space (select from list)',
            _promptGetHttpAuthCredentials,
          ),
          _buildMethodSection(
            PlatformHttpAuthCredentialDatabaseMethod.setHttpAuthCredential,
            'Save a new credential',
            _setHttpAuthCredential,
          ),
          _buildMethodSection(
            PlatformHttpAuthCredentialDatabaseMethod.removeHttpAuthCredential,
            'Remove a specific credential (select from list)',
            _promptRemoveHttpAuthCredential,
          ),
          _buildMethodSection(
            PlatformHttpAuthCredentialDatabaseMethod.removeHttpAuthCredentials,
            'Remove all credentials for a protection space',
            _promptRemoveHttpAuthCredentials,
          ),
          _buildMethodSection(
            PlatformHttpAuthCredentialDatabaseMethod.clearAllAuthCredentials,
            'Clear all credentials',
            _clearAllAuthCredentials,
          ),
          const SizedBox(height: 16),
          _buildCredentialsList(),
        ],
      ),
    );
  }

  Widget _buildMethodSection(
    PlatformHttpAuthCredentialDatabaseMethod method,
    String description,
    VoidCallback? onPressed,
  ) {
    final methodName = method.name;
    final supportedPlatforms = SupportCheckHelper.supportedPlatformsForMethod(
      method: method,
      checker: HttpAuthCredentialDatabase.isMethodSupported,
    );

    return MethodTile(
      methodName: methodName,
      description: description,
      supportedPlatforms: supportedPlatforms,
      onRun: !_isLoading ? onPressed : null,
      historyEntries: _methodHistory[methodName],
      selectedHistoryIndex: _selectedHistoryIndex[methodName],
      onHistorySelected: (index) {
        setState(() => _selectedHistoryIndex[methodName] = index);
      },
    );
  }

  Widget _buildCredentialsList() {
    if (_allCredentials.isEmpty) {
      return EmptyStateCard(
        icon: Icons.lock_outline,
        title: 'No credentials found',
        description:
            'Click "${PlatformHttpAuthCredentialDatabaseMethod.setHttpAuthCredential.name}" to add HTTP auth credentials',
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
