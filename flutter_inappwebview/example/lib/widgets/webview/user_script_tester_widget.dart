import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Widget to test user script injection
class UserScriptTesterWidget extends StatefulWidget {
  final Future<void> Function(UserScript script) onAddScript;
  final Future<void> Function(UserScript script) onRemoveScript;
  final List<UserScript>? scripts;

  const UserScriptTesterWidget({
    super.key,
    required this.onAddScript,
    required this.onRemoveScript,
    this.scripts,
  });

  @override
  State<UserScriptTesterWidget> createState() => _UserScriptTesterWidgetState();
}

class _UserScriptTesterWidgetState extends State<UserScriptTesterWidget> {
  final TextEditingController _sourceController = TextEditingController();
  UserScriptInjectionTime _injectionTime =
      UserScriptInjectionTime.AT_DOCUMENT_START;
  bool _forMainFrameOnly = false;
  bool _isAdding = false;

  @override
  void dispose() {
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(child: _buildForm()),
        _buildScriptList(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: const Row(
        children: [
          Text(
            'User Scripts',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add User Script',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _sourceController,
            decoration: const InputDecoration(
              hintText: 'Enter JavaScript source code',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
            maxLines: 2,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Injection Time',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButton<UserScriptInjectionTime>(
                      value: _injectionTime,
                      isExpanded: true,
                      items: UserScriptInjectionTime.values.map((time) {
                        return DropdownMenuItem(
                          value: time,
                          child: Text(
                            time.toString().split('.').last,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _injectionTime = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Main Frame Only',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: _forMainFrameOnly,
                    onChanged: (value) {
                      setState(() {
                        _forMainFrameOnly = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sourceController.text.trim().isEmpty || _isAdding
                  ? null
                  : _addScript,
              child: _isAdding
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add Script'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScriptList() {
    final scripts = widget.scripts ?? [];

    if (scripts.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'No user scripts added',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final script = scripts[index];
        return _buildScriptItem(script, index);
      }, childCount: scripts.length),
    );
  }

  Widget _buildScriptItem(UserScript script, int index) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Script ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Remove',
                  onPressed: () => _removeScript(script),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                script.source,
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(
                    script.injectionTime.toString().split('.').last,
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.blue.shade100,
                  padding: EdgeInsets.zero,
                ),
                if (script.forMainFrameOnly)
                  Chip(
                    label: const Text(
                      'Main Frame Only',
                      style: TextStyle(fontSize: 10),
                    ),
                    backgroundColor: Colors.green.shade100,
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addScript() async {
    final source = _sourceController.text.trim();
    if (source.isEmpty) return;

    setState(() {
      _isAdding = true;
    });

    try {
      final script = UserScript(
        source: source,
        injectionTime: _injectionTime,
        forMainFrameOnly: _forMainFrameOnly,
      );

      await widget.onAddScript(script);

      setState(() {
        _sourceController.clear();
        _isAdding = false;
      });
    } catch (e) {
      setState(() {
        _isAdding = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add script: $e')));
      }
    }
  }

  Future<void> _removeScript(UserScript script) async {
    try {
      await widget.onRemoveScript(script);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to remove script: $e')));
      }
    }
  }
}
