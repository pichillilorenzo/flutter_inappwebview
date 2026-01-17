import 'dart:convert';
import 'package:flutter/material.dart';

/// Method definition with parameters
class MethodDefinition {
  final String name;
  final String description;
  final List<MethodParameter> parameters;

  const MethodDefinition({
    required this.name,
    required this.description,
    this.parameters = const [],
  });
}

/// Method parameter definition
class MethodParameter {
  final String name;
  final String type;
  final bool isRequired;
  final dynamic defaultValue;

  const MethodParameter({
    required this.name,
    required this.type,
    this.isRequired = true,
    this.defaultValue,
  });
}

/// Widget to test InAppWebViewController methods
class MethodTesterWidget extends StatefulWidget {
  final Future<dynamic> Function(String method, Map<String, dynamic> params)
      onExecuteMethod;
  final Future<bool> Function(String method)? isMethodSupported;

  const MethodTesterWidget({
    super.key,
    required this.onExecuteMethod,
    this.isMethodSupported,
  });

  @override
  State<MethodTesterWidget> createState() => _MethodTesterWidgetState();
}

class _MethodTesterWidgetState extends State<MethodTesterWidget> {
  String? _selectedMethod;
  final Map<String, TextEditingController> _paramControllers = {};
  bool _isExecuting = false;
  dynamic _result;
  String? _error;
  bool? _isSupported;

  // Common WebView controller methods
  static const List<MethodDefinition> _methods = [
    MethodDefinition(
      name: 'getUrl',
      description: 'Get the current URL',
    ),
    MethodDefinition(
      name: 'getTitle',
      description: 'Get the current page title',
    ),
    MethodDefinition(
      name: 'canGoBack',
      description: 'Check if can navigate back',
    ),
    MethodDefinition(
      name: 'canGoForward',
      description: 'Check if can navigate forward',
    ),
    MethodDefinition(
      name: 'goBack',
      description: 'Navigate back in history',
    ),
    MethodDefinition(
      name: 'goForward',
      description: 'Navigate forward in history',
    ),
    MethodDefinition(
      name: 'reload',
      description: 'Reload the current page',
    ),
    MethodDefinition(
      name: 'stopLoading',
      description: 'Stop loading the current page',
    ),
    MethodDefinition(
      name: 'evaluateJavascript',
      description: 'Execute JavaScript code',
      parameters: [
        MethodParameter(name: 'source', type: 'String'),
      ],
    ),
    MethodDefinition(
      name: 'clearCache',
      description: 'Clear the WebView cache',
    ),
    MethodDefinition(
      name: 'clearHistory',
      description: 'Clear navigation history',
    ),
    MethodDefinition(
      name: 'getProgress',
      description: 'Get current page load progress',
    ),
    MethodDefinition(
      name: 'getContentHeight',
      description: 'Get content height in pixels',
    ),
    MethodDefinition(
      name: 'zoomBy',
      description: 'Zoom by factor',
      parameters: [
        MethodParameter(name: 'zoomFactor', type: 'double'),
      ],
    ),
    MethodDefinition(
      name: 'getSelectedText',
      description: 'Get currently selected text',
    ),
  ];

  @override
  void dispose() {
    for (var controller in _paramControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildMethodSelector(),
        if (_selectedMethod != null) ...[
          _buildParameterInputs(),
          _buildExecuteButton(),
        ],
        Expanded(child: _buildResultArea()),
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
            'Method Tester',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Method',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: _selectedMethod,
            isExpanded: true,
            hint: const Text('Choose a method to test'),
            items: _methods.map((method) {
              return DropdownMenuItem(
                value: method.name,
                child: Text(method.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedMethod = value;
                _result = null;
                _error = null;
                _isSupported = null;
                _paramControllers.clear();
              });
              if (value != null) {
                _checkMethodSupport(value);
              }
            },
          ),
          if (_selectedMethod != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _methods
                        .firstWhere((m) => m.name == _selectedMethod)
                        .description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
                if (_isSupported != null)
                  Icon(
                    _isSupported! ? Icons.check_circle : Icons.cancel,
                    color: _isSupported! ? Colors.green : Colors.red,
                    size: 20,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParameterInputs() {
    final method = _methods.firstWhere((m) => m.name == _selectedMethod);
    if (method.parameters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Parameters',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...method.parameters.map((param) {
            _paramControllers.putIfAbsent(
              param.name,
              () => TextEditingController(),
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: _paramControllers[param.name],
                decoration: InputDecoration(
                  labelText: param.name,
                  hintText:
                      '${param.type}${param.isRequired ? ' (required)' : ' (optional)'}',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExecuteButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed:
              _selectedMethod == null || _isExecuting ? null : _executeMethod,
          child: _isExecuting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Execute'),
        ),
      ),
    );
  }

  Widget _buildResultArea() {
    if (_result == null && _error == null) {
      return const Center(
        child: Text(
          'Select and execute a method to see results',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Error',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Result',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatResult(_result),
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
    );
  }

  Future<void> _checkMethodSupport(String method) async {
    if (widget.isMethodSupported != null) {
      try {
        final supported = await widget.isMethodSupported!(method);
        if (mounted) {
          setState(() {
            _isSupported = supported;
          });
        }
      } catch (e) {
        // Ignore errors in support checking
      }
    }
  }

  Future<void> _executeMethod() async {
    if (_selectedMethod == null) return;

    setState(() {
      _isExecuting = true;
      _result = null;
      _error = null;
    });

    try {
      final params = <String, dynamic>{};
      for (var entry in _paramControllers.entries) {
        final value = entry.value.text.trim();
        if (value.isNotEmpty) {
          // Try to parse as number or bool
          if (value == 'true' || value == 'false') {
            params[entry.key] = value == 'true';
          } else if (double.tryParse(value) != null) {
            params[entry.key] = double.parse(value);
          } else {
            params[entry.key] = value;
          }
        }
      }

      final result = await widget.onExecuteMethod(_selectedMethod!, params);

      if (mounted) {
        setState(() {
          _result = result;
          _isExecuting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isExecuting = false;
        });
      }
    }
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
