import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/test_configuration.dart';
import '../../utils/controller_methods_registry.dart';
import '../../widgets/common/parameter_dialog.dart';

/// Dialog for creating/editing custom test steps
class CustomTestStepDialog extends StatefulWidget {
  final CustomTestStep? existingStep;
  final Function(CustomTestStep) onSave;

  const CustomTestStepDialog({
    super.key,
    this.existingStep,
    required this.onSave,
  });

  @override
  State<CustomTestStepDialog> createState() => _CustomTestStepDialogState();
}

class _CustomTestStepDialogState extends State<CustomTestStepDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _scriptController;
  late final TextEditingController _urlController;
  late final TextEditingController _htmlController;
  late final TextEditingController _selectorController;
  late final TextEditingController _textController;
  late final TextEditingController _xController;
  late final TextEditingController _yController;
  late final TextEditingController _delayController;
  late final TextEditingController _expectedResultController;

  CustomTestActionType _selectedActionType =
      CustomTestActionType.evaluateJavascript;
  String _selectedCategory = 'custom';
  bool _enabled = true;
  ExpectedResultType _expectedResultType = ExpectedResultType.any;

  // Controller method selection
  ControllerMethodEntry? _selectedMethod;
  Map<String, dynamic> _methodParameters = {};

  final List<String> _categories = [
    'custom',
    'navigation',
    'javascript',
    'content',
    'storage',
    'advanced',
  ];

  @override
  void initState() {
    super.initState();
    final step = widget.existingStep;
    _nameController = TextEditingController(text: step?.name ?? '');
    _descriptionController = TextEditingController(
      text: step?.description ?? '',
    );
    _scriptController = TextEditingController(text: step?.action.script ?? '');
    _urlController = TextEditingController(text: step?.action.url ?? '');
    _htmlController = TextEditingController(text: step?.action.html ?? '');
    _selectorController = TextEditingController(
      text: step?.action.selector ?? '',
    );
    _textController = TextEditingController(text: step?.action.text ?? '');
    _xController = TextEditingController(
      text: step?.action.x?.toString() ?? '0',
    );
    _yController = TextEditingController(
      text: step?.action.y?.toString() ?? '0',
    );
    _delayController = TextEditingController(
      text: step?.action.delayMs?.toString() ?? '1000',
    );
    _expectedResultController = TextEditingController(
      text: step?.expectedResult ?? '',
    );

    if (step != null) {
      _selectedActionType = step.action.type;
      _selectedCategory = step.category;
      _enabled = step.enabled;
      _expectedResultType = step.expectedResultType;

      // Load controller method if applicable
      if (step.action.type == CustomTestActionType.controllerMethod) {
        final methodId = step.action.methodId;
        if (methodId != null) {
          _selectedMethod = ControllerMethodsRegistry.instance.findMethodById(
            methodId,
          );
          _methodParameters = Map.from(step.action.methodParameters ?? {});
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _scriptController.dispose();
    _urlController.dispose();
    _htmlController.dispose();
    _selectorController.dispose();
    _textController.dispose();
    _xController.dispose();
    _yController.dispose();
    _delayController.dispose();
    _expectedResultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingStep != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Test Step' : 'Create Test Step'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic info
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  hintText: 'Enter test step name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe what this test does',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(
                      c.substring(0, 1).toUpperCase() + c.substring(1),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Action type dropdown
              const Text(
                'Action Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<CustomTestActionType>(
                value: _selectedActionType,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: CustomTestActionType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getActionTypeName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedActionType = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Action-specific fields
              ..._buildActionFields(),

              const SizedBox(height: 16),
              const Text(
                'Expected Result Validation',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ExpectedResultType>(
                value: _expectedResultType,
                decoration: const InputDecoration(
                  labelText: 'Validation Type',
                  border: OutlineInputBorder(),
                ),
                items: ExpectedResultType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getExpectedResultTypeName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _expectedResultType = value);
                  }
                },
              ),
              if (_needsExpectedResultValue(_expectedResultType)) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _expectedResultController,
                  decoration: InputDecoration(
                    labelText: _getExpectedResultLabel(_expectedResultType),
                    hintText: _getExpectedResultHint(_expectedResultType),
                    border: const OutlineInputBorder(),
                  ),
                  maxLines:
                      _expectedResultType == ExpectedResultType.regex ||
                          _expectedResultType ==
                              ExpectedResultType.customExpression
                      ? 3
                      : 1,
                  style:
                      _expectedResultType == ExpectedResultType.regex ||
                          _expectedResultType ==
                              ExpectedResultType.customExpression
                      ? const TextStyle(fontFamily: 'monospace')
                      : null,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                _getExpectedResultTypeDescription(_expectedResultType),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),

              // Enabled switch
              SwitchListTile(
                title: const Text('Enabled'),
                subtitle: const Text('Include this step in test runs'),
                value: _enabled,
                onChanged: (value) {
                  setState(() => _enabled = value);
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveStep,
          child: Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  List<Widget> _buildActionFields() {
    switch (_selectedActionType) {
      case CustomTestActionType.evaluateJavascript:
        return [
          TextField(
            controller: _scriptController,
            decoration: const InputDecoration(
              labelText: 'JavaScript Code *',
              hintText: 'Enter JavaScript to evaluate',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ];

      case CustomTestActionType.loadUrl:
        return [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'URL *',
              hintText: 'https://example.com',
              border: OutlineInputBorder(),
            ),
          ),
        ];

      case CustomTestActionType.loadHtml:
        return [
          TextField(
            controller: _htmlController,
            decoration: const InputDecoration(
              labelText: 'HTML Content *',
              hintText: '<html>...</html>',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ];

      case CustomTestActionType.checkUrl:
        return [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Expected URL (partial match) *',
              hintText: 'example.com',
              border: OutlineInputBorder(),
            ),
          ),
        ];

      case CustomTestActionType.checkTitle:
        return [
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Expected Title *',
              hintText: 'Page Title',
              border: OutlineInputBorder(),
            ),
          ),
        ];

      case CustomTestActionType.checkElement:
      case CustomTestActionType.waitForElement:
      case CustomTestActionType.clickElement:
        return [
          TextField(
            controller: _selectorController,
            decoration: const InputDecoration(
              labelText: 'CSS Selector *',
              hintText: '#myElement or .myClass',
              border: OutlineInputBorder(),
            ),
          ),
          if (_selectedActionType == CustomTestActionType.waitForElement) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _delayController,
              decoration: const InputDecoration(
                labelText: 'Timeout (ms)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ];

      case CustomTestActionType.typeText:
        return [
          TextField(
            controller: _selectorController,
            decoration: const InputDecoration(
              labelText: 'CSS Selector *',
              hintText: '#inputField',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Text to Type *',
              hintText: 'Hello World',
              border: OutlineInputBorder(),
            ),
          ),
        ];

      case CustomTestActionType.scrollTo:
        return [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _xController,
                  decoration: const InputDecoration(
                    labelText: 'X Position',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _yController,
                  decoration: const InputDecoration(
                    labelText: 'Y Position',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
        ];

      case CustomTestActionType.delay:
        return [
          TextField(
            controller: _delayController,
            decoration: const InputDecoration(
              labelText: 'Delay (milliseconds) *',
              hintText: '1000',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ];

      case CustomTestActionType.takeScreenshot:
        return [
          const Text(
            'No additional configuration needed.\nScreenshot will be captured and returned.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ];

      case CustomTestActionType.custom:
        return [
          TextField(
            controller: _scriptController,
            decoration: const InputDecoration(
              labelText: 'Custom JavaScript Code *',
              hintText:
                  'return { passed: true, message: "Custom test passed" };',
              border: OutlineInputBorder(),
            ),
            maxLines: 8,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ];

      case CustomTestActionType.controllerMethod:
        return _buildControllerMethodFields();
    }
  }

  List<Widget> _buildControllerMethodFields() {
    return [
      // Method selector
      const Text(
        'Select Controller Method',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 8),
      InkWell(
        onTap: () => _showMethodPickerDialog(),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              const Icon(Icons.code, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: _selectedMethod != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedMethod!.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _selectedMethod!.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Select a controller method...',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),

      // Parameters section
      if (_selectedMethod != null &&
          _selectedMethod!.parameters.isNotEmpty) ...[
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Method Parameters',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            TextButton.icon(
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Configure'),
              onPressed: () => _showParameterDialog(),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _selectedMethod!.parameters.entries.map((entry) {
              final value = _methodParameters[entry.key] ?? entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text(
                      '${entry.key}: ',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _formatParameterValue(value),
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.grey.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ];
  }

  String _formatParameterValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"$value"';
    if (value is Map) return '{...}';
    if (value is List) return '[${value.length} items]';
    if (value is ParameterValueHint) return _formatParameterValue(value.value);
    return value.toString();
  }

  Future<void> _showMethodPickerDialog() async {
    final result = await showDialog<ControllerMethodEntry>(
      context: context,
      builder: (context) =>
          _MethodPickerDialog(selectedMethodId: _selectedMethod?.id),
    );

    if (result != null) {
      setState(() {
        _selectedMethod = result;
        _methodParameters = Map.from(result.parameters);
      });
    }
  }

  Future<void> _showParameterDialog() async {
    if (_selectedMethod == null) return;

    // Merge current values into parameters
    final params = <String, dynamic>{
      ..._selectedMethod!.parameters,
      ..._methodParameters,
    };

    final result = await showParameterDialog(
      context: context,
      title: '${_selectedMethod!.name} Parameters',
      parameters: params,
      requiredPaths: _selectedMethod!.requiredParameters,
    );

    if (result != null) {
      setState(() {
        _methodParameters = result;
      });
    }
  }

  String _getActionTypeName(CustomTestActionType type) {
    switch (type) {
      case CustomTestActionType.evaluateJavascript:
        return 'Evaluate JavaScript';
      case CustomTestActionType.loadUrl:
        return 'Load URL';
      case CustomTestActionType.loadHtml:
        return 'Load HTML';
      case CustomTestActionType.checkUrl:
        return 'Check URL';
      case CustomTestActionType.checkTitle:
        return 'Check Title';
      case CustomTestActionType.checkElement:
        return 'Check Element Exists';
      case CustomTestActionType.waitForElement:
        return 'Wait for Element';
      case CustomTestActionType.clickElement:
        return 'Click Element';
      case CustomTestActionType.typeText:
        return 'Type Text';
      case CustomTestActionType.scrollTo:
        return 'Scroll To';
      case CustomTestActionType.takeScreenshot:
        return 'Take Screenshot';
      case CustomTestActionType.delay:
        return 'Delay/Wait';
      case CustomTestActionType.controllerMethod:
        return 'Controller Method';
      case CustomTestActionType.custom:
        return 'Custom Action';
    }
  }

  String _getExpectedResultTypeName(ExpectedResultType type) {
    switch (type) {
      case ExpectedResultType.any:
        return 'Any (No Validation)';
      case ExpectedResultType.exact:
        return 'Exact Match';
      case ExpectedResultType.contains:
        return 'Contains (Case Sensitive)';
      case ExpectedResultType.containsIgnoreCase:
        return 'Contains (Case Insensitive)';
      case ExpectedResultType.regex:
        return 'Regex Pattern';
      case ExpectedResultType.notNull:
        return 'Not Null';
      case ExpectedResultType.isNull:
        return 'Is Null';
      case ExpectedResultType.truthy:
        return 'Truthy Value';
      case ExpectedResultType.falsy:
        return 'Falsy Value';
      case ExpectedResultType.typeIs:
        return 'Type Check';
      case ExpectedResultType.notEmpty:
        return 'Not Empty';
      case ExpectedResultType.hasKey:
        return 'Has Key (Map)';
      case ExpectedResultType.lengthEquals:
        return 'Length Equals';
      case ExpectedResultType.greaterThan:
        return 'Greater Than';
      case ExpectedResultType.lessThan:
        return 'Less Than';
      case ExpectedResultType.customExpression:
        return 'Custom Expression';
    }
  }

  String _getExpectedResultTypeDescription(ExpectedResultType type) {
    switch (type) {
      case ExpectedResultType.any:
        return 'Test passes as long as it executes without errors';
      case ExpectedResultType.exact:
        return 'Result must exactly match the expected value (as string)';
      case ExpectedResultType.contains:
        return 'Result string must contain the expected value';
      case ExpectedResultType.containsIgnoreCase:
        return 'Result string must contain the expected value (ignoring case)';
      case ExpectedResultType.regex:
        return 'Result must match the regular expression pattern';
      case ExpectedResultType.notNull:
        return 'Result must not be null';
      case ExpectedResultType.isNull:
        return 'Result must be null';
      case ExpectedResultType.truthy:
        return 'Result must be truthy (not null, false, 0, or empty)';
      case ExpectedResultType.falsy:
        return 'Result must be falsy (null, false, 0, or empty)';
      case ExpectedResultType.typeIs:
        return 'Result type must match (e.g., String, int, Map, List)';
      case ExpectedResultType.notEmpty:
        return 'Result must not be empty (string, list, or map)';
      case ExpectedResultType.hasKey:
        return 'Result Map must contain the specified key';
      case ExpectedResultType.lengthEquals:
        return 'Result length must equal the specified number';
      case ExpectedResultType.greaterThan:
        return 'Numeric result must be greater than the expected value';
      case ExpectedResultType.lessThan:
        return 'Numeric result must be less than the expected value';
      case ExpectedResultType.customExpression:
        return 'Custom JavaScript expression (receives "result" variable)';
    }
  }

  bool _needsExpectedResultValue(ExpectedResultType type) {
    switch (type) {
      case ExpectedResultType.any:
      case ExpectedResultType.notNull:
      case ExpectedResultType.isNull:
      case ExpectedResultType.truthy:
      case ExpectedResultType.falsy:
      case ExpectedResultType.notEmpty:
        return false;
      default:
        return true;
    }
  }

  String _getExpectedResultLabel(ExpectedResultType type) {
    switch (type) {
      case ExpectedResultType.exact:
        return 'Expected Value';
      case ExpectedResultType.contains:
      case ExpectedResultType.containsIgnoreCase:
        return 'Contains Text';
      case ExpectedResultType.regex:
        return 'Regex Pattern';
      case ExpectedResultType.typeIs:
        return 'Type Name';
      case ExpectedResultType.hasKey:
        return 'Key Name';
      case ExpectedResultType.lengthEquals:
        return 'Expected Length';
      case ExpectedResultType.greaterThan:
      case ExpectedResultType.lessThan:
        return 'Comparison Value';
      case ExpectedResultType.customExpression:
        return 'JavaScript Expression';
      default:
        return 'Expected Value';
    }
  }

  String _getExpectedResultHint(ExpectedResultType type) {
    switch (type) {
      case ExpectedResultType.exact:
        return 'Enter the exact expected result';
      case ExpectedResultType.contains:
      case ExpectedResultType.containsIgnoreCase:
        return 'Enter text to search for';
      case ExpectedResultType.regex:
        return '^https?://.*\\.com\$';
      case ExpectedResultType.typeIs:
        return 'String, int, Map, List, etc.';
      case ExpectedResultType.hasKey:
        return 'Key name to check';
      case ExpectedResultType.lengthEquals:
        return '10';
      case ExpectedResultType.greaterThan:
      case ExpectedResultType.lessThan:
        return 'Numeric value';
      case ExpectedResultType.customExpression:
        return 'return result != null && result.length > 0;';
      default:
        return '';
    }
  }

  void _saveStep() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name for the test step')),
      );
      return;
    }

    final action = _buildAction();
    if (action == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields')),
      );
      return;
    }

    // Validate expected result if needed
    if (_needsExpectedResultValue(_expectedResultType) &&
        _expectedResultController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide an expected result value'),
        ),
      );
      return;
    }

    final step = CustomTestStep(
      id:
          widget.existingStep?.id ??
          'step_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      action: action,
      expectedResult: _expectedResultController.text.trim().isNotEmpty
          ? _expectedResultController.text.trim()
          : null,
      expectedResultType: _expectedResultType,
      enabled: _enabled,
      order: widget.existingStep?.order ?? 0,
    );

    widget.onSave(step);
    Navigator.pop(context);
  }

  CustomTestAction? _buildAction() {
    switch (_selectedActionType) {
      case CustomTestActionType.evaluateJavascript:
        final script = _scriptController.text.trim();
        if (script.isEmpty) return null;
        return CustomTestAction.evaluateJs(script);

      case CustomTestActionType.loadUrl:
        final url = _urlController.text.trim();
        if (url.isEmpty) return null;
        return CustomTestAction.loadUrl(url);

      case CustomTestActionType.loadHtml:
        final html = _htmlController.text.trim();
        if (html.isEmpty) return null;
        return CustomTestAction.loadHtml(html);

      case CustomTestActionType.checkUrl:
        final url = _urlController.text.trim();
        if (url.isEmpty) return null;
        return CustomTestAction.checkUrl(url);

      case CustomTestActionType.checkTitle:
        final title = _textController.text.trim();
        if (title.isEmpty) return null;
        return CustomTestAction.checkTitle(title);

      case CustomTestActionType.checkElement:
        final selector = _selectorController.text.trim();
        if (selector.isEmpty) return null;
        return CustomTestAction.checkElement(selector);

      case CustomTestActionType.waitForElement:
        final selector = _selectorController.text.trim();
        if (selector.isEmpty) return null;
        final timeout = int.tryParse(_delayController.text) ?? 5000;
        return CustomTestAction.waitForElement(selector, timeoutMs: timeout);

      case CustomTestActionType.clickElement:
        final selector = _selectorController.text.trim();
        if (selector.isEmpty) return null;
        return CustomTestAction.clickElement(selector);

      case CustomTestActionType.typeText:
        final selector = _selectorController.text.trim();
        final text = _textController.text;
        if (selector.isEmpty || text.isEmpty) return null;
        return CustomTestAction.typeText(selector, text);

      case CustomTestActionType.scrollTo:
        final x = int.tryParse(_xController.text) ?? 0;
        final y = int.tryParse(_yController.text) ?? 0;
        return CustomTestAction.scrollTo(x, y);

      case CustomTestActionType.takeScreenshot:
        return const CustomTestAction(
          type: CustomTestActionType.takeScreenshot,
        );

      case CustomTestActionType.delay:
        final delay = int.tryParse(_delayController.text);
        if (delay == null || delay <= 0) return null;
        return CustomTestAction.delay(delay);

      case CustomTestActionType.custom:
        final code = _scriptController.text.trim();
        if (code.isEmpty) return null;
        return CustomTestAction(
          type: CustomTestActionType.custom,
          customCode: code,
        );

      case CustomTestActionType.controllerMethod:
        if (_selectedMethod == null) return null;
        return CustomTestAction.controllerMethod(
          _selectedMethod!.id,
          parameters: _methodParameters.isNotEmpty ? _methodParameters : null,
        );
    }
  }
}

/// Dialog for picking a controller method
class _MethodPickerDialog extends StatefulWidget {
  final String? selectedMethodId;

  const _MethodPickerDialog({this.selectedMethodId});

  @override
  State<_MethodPickerDialog> createState() => _MethodPickerDialogState();
}

class _MethodPickerDialogState extends State<_MethodPickerDialog> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registry = ControllerMethodsRegistry.instance;
    final filteredCategories = registry.searchCategories(_searchQuery);

    return AlertDialog(
      title: const Text('Select Controller Method'),
      content: SizedBox(
        width: 500,
        height: 450,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search methods...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filteredCategories.isEmpty
                  ? const Center(child: Text('No methods found'))
                  : ListView.builder(
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = filteredCategories[index];
                        return ExpansionTile(
                          leading: Icon(category.icon, size: 20),
                          title: Text(
                            category.name,
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: Text('${category.methods.length} methods'),
                          children: category.methods.map((method) {
                            final isSelected =
                                widget.selectedMethodId == method.id;
                            return ListTile(
                              dense: true,
                              selected: isSelected,
                              leading: isSelected
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 20,
                                    )
                                  : const Icon(Icons.code, size: 20),
                              title: Text(method.name),
                              subtitle: Text(
                                method.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: method.parameters.isNotEmpty
                                  ? Chip(
                                      label: Text(
                                        '${method.parameters.length}',
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    )
                                  : null,
                              onTap: () => Navigator.of(context).pop(method),
                            );
                          }).toList(),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
