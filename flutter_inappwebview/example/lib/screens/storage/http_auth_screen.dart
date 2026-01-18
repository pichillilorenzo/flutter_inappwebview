import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/main.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';
import 'package:flutter_inappwebview_example/widgets/common/support_badge.dart';

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
      _showSuccess('Found ${credentials.length} protection spaces');
    } catch (e) {
      _showError('Error getting credentials: $e');
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
    } catch (e) {
      _showError('Error getting credentials: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setHttpAuthCredential() async {
    await _showAddCredentialDialog();
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
      _showSuccess('Credential removed');
      await _getAllAuthCredentials();
    } catch (e) {
      _showError('Error removing credential: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
      _showSuccess('Credentials removed for protection space');
      await _getAllAuthCredentials();
    } catch (e) {
      _showError('Error removing credentials: $e');
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
      _showSuccess('All credentials cleared');
    } catch (e) {
      _showError('Error clearing credentials: $e');
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

  Future<void> _showAddCredentialDialog() async {
    final hostController = TextEditingController();
    final portController = TextEditingController(text: '443');
    final protocolController = TextEditingController(text: 'https');
    final realmController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Credential'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Protection Space',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hostController,
                decoration: const InputDecoration(
                  labelText: 'Host *',
                  hintText: 'example.com',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: protocolController,
                      decoration: const InputDecoration(
                        labelText: 'Protocol',
                        hintText: 'https',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: portController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Port',
                        hintText: '443',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: realmController,
                decoration: const InputDecoration(
                  labelText: 'Realm',
                  hintText: 'Secure Area',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Credential',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password *',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (hostController.text.isEmpty ||
                  usernameController.text.isEmpty ||
                  passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Host, Username and Password are required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              setState(() => _isLoading = true);
              try {
                await _db.setHttpAuthCredential(
                  protectionSpace: URLProtectionSpace(
                    host: hostController.text,
                    port: int.tryParse(portController.text),
                    protocol: protocolController.text.isNotEmpty
                        ? protocolController.text
                        : null,
                    realm: realmController.text.isNotEmpty
                        ? realmController.text
                        : null,
                  ),
                  credential: URLCredential(
                    username: usernameController.text,
                    password: passwordController.text,
                  ),
                );
                _showSuccess('Credential saved');
                await _getAllAuthCredentials();
              } catch (e) {
                _showError('Error saving credential: $e');
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Save'),
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
            null,
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
            null,
          ),
          _buildMethodSection(
            'removeHttpAuthCredentials',
            'Remove all credentials for a protection space',
            PlatformHttpAuthCredentialDatabaseMethod.removeHttpAuthCredentials,
            null,
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
