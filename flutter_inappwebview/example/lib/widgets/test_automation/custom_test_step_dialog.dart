import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/test_configuration.dart';

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
              TextField(
                controller: _expectedResultController,
                decoration: const InputDecoration(
                  labelText: 'Expected Result (optional)',
                  hintText: 'Enter expected result for comparison',
                  border: OutlineInputBorder(),
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
      case CustomTestActionType.custom:
        return 'Custom Action';
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
    }
  }
}
