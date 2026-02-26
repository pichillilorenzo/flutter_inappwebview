import 'dart:convert';
import 'package:flutter/material.dart';

/// Result of a JavaScript execution
class JsExecutionResult {
  final String code;
  final DateTime timestamp;
  final dynamic result;
  final String? error;
  final bool isAsync;

  JsExecutionResult({
    required this.code,
    required this.timestamp,
    this.result,
    this.error,
    this.isAsync = false,
  });
}

/// Widget to execute JavaScript and view results
class JavaScriptConsoleWidget extends StatefulWidget {
  final Future<dynamic> Function(String code) onExecute;
  final Future<dynamic> Function(String code)? onExecuteAsync;

  const JavaScriptConsoleWidget({
    super.key,
    required this.onExecute,
    this.onExecuteAsync,
  });

  @override
  State<JavaScriptConsoleWidget> createState() =>
      _JavaScriptConsoleWidgetState();
}

class _JavaScriptConsoleWidgetState extends State<JavaScriptConsoleWidget> {
  final TextEditingController _codeController = TextEditingController();
  final List<JsExecutionResult> _history = [];
  bool _isExecuting = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(child: _buildInputArea()),
        _buildResultsArea(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      // ... (unchanged code, but I need to include it for context match or just replace build)
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          const Text(
            'JavaScript Console',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Clear',
            onPressed: _clear,
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _codeController,
            decoration: const InputDecoration(
              hintText: 'Enter JavaScript code',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
            maxLines: 3,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _codeController.text.trim().isEmpty || _isExecuting
                      ? null
                      : () => _execute(false),
                  child: _isExecuting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Execute'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      _codeController.text.trim().isEmpty ||
                          _isExecuting ||
                          widget.onExecuteAsync == null
                      ? null
                      : () => _execute(true),
                  child: const Text('Execute Async'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsArea() {
    if (_history.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'Execute JavaScript to see results',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final result = _history[index];
        return _buildResultItem(result);
      }, childCount: _history.length),
    );
  }

  Widget _buildResultItem(JsExecutionResult result) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.error != null ? Icons.error : Icons.check_circle,
                  color: result.error != null ? Colors.red : Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  result.isAsync ? 'Async Execution' : 'Execution',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(result.timestamp),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
                result.code,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 8),
            if (result.error != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Error: ${result.error}',
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Result:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatResult(result.result),
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _execute(bool isAsync) async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isExecuting = true;
    });

    try {
      final result = isAsync && widget.onExecuteAsync != null
          ? await widget.onExecuteAsync!(code)
          : await widget.onExecute(code);

      setState(() {
        _history.add(
          JsExecutionResult(
            code: code,
            timestamp: DateTime.now(),
            result: result,
            isAsync: isAsync,
          ),
        );
        _isExecuting = false;
      });
    } catch (e) {
      setState(() {
        _history.add(
          JsExecutionResult(
            code: code,
            timestamp: DateTime.now(),
            error: e.toString(),
            isAsync: isAsync,
          ),
        );
        _isExecuting = false;
      });
    }
  }

  void _clear() {
    setState(() {
      _codeController.clear();
      _history.clear();
    });
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }

  String _formatResult(dynamic result) {
    if (result == null) return 'null';
    if (result is String) return result;
    if (result is Map || result is List) {
      try {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(result);
      } catch (e) {
        return result.toString();
      }
    }
    return result.toString();
  }
}
