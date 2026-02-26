import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_example/utils/controller_methods_registry.dart';
import 'package:flutter_inappwebview_example/widgets/common/method_card.dart';
import 'package:flutter_inappwebview_example/widgets/common/parameter_dialog.dart';

/// A widget that allows users to select a controller method and configure its parameters
class MethodSelectorWidget extends StatefulWidget {
  /// The currently selected method ID
  final String? selectedMethodId;

  /// The current parameters for the selected method
  final Map<String, dynamic> parameters;

  /// Called when a method is selected
  final ValueChanged<ControllerMethodEntry?> onMethodSelected;

  /// Called when parameters are updated
  final ValueChanged<Map<String, dynamic>> onParametersChanged;

  const MethodSelectorWidget({
    super.key,
    this.selectedMethodId,
    this.parameters = const {},
    required this.onMethodSelected,
    required this.onParametersChanged,
  });

  @override
  State<MethodSelectorWidget> createState() => _MethodSelectorWidgetState();
}

class _MethodSelectorWidgetState extends State<MethodSelectorWidget> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  ControllerMethodEntry? _selectedMethod;
  Map<String, dynamic> _parameters = {};

  @override
  void initState() {
    super.initState();
    _parameters = Map.from(widget.parameters);
    if (widget.selectedMethodId != null) {
      _selectedMethod = ControllerMethodsRegistry.instance.findMethodById(
        widget.selectedMethodId!,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registry = ControllerMethodsRegistry.instance;
    final filteredCategories = registry.searchCategories(_searchQuery);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected method display
        if (_selectedMethod != null) ...[
          _buildSelectedMethodCard(),
          const SizedBox(height: 16),
        ],

        // Search and selection
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Search Methods',
            hintText: 'Type to search...',
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
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),
        const SizedBox(height: 12),

        // Method categories list
        Expanded(
          child: filteredCategories.isEmpty
              ? const Center(child: Text('No methods found'))
              : ListView.builder(
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    return _buildCategorySection(category);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSelectedMethodCard() {
    final method = _selectedMethod!;
    return MethodCard(
      methodName: method.name,
      description: method.description,
      leading: const Icon(Icons.check_circle, color: Colors.green),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      trailing: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          setState(() {
            _selectedMethod = null;
            _parameters = {};
          });
          widget.onMethodSelected(null);
          widget.onParametersChanged({});
        },
        tooltip: 'Clear selection',
      ),
      extraContent: method.parameters.isNotEmpty
          ? _buildParametersSection()
          : null,
    );
  }

  Widget _buildParametersSection() {
    final method = _selectedMethod!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Parameters', style: Theme.of(context).textTheme.titleSmall),
            TextButton.icon(
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Configure'),
              onPressed: () => _showParameterDialog(),
            ),
          ],
        ),
        if (_parameters.isNotEmpty)
          ...method.parameters.entries
              .where((e) => _parameters.containsKey(e.key))
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '${e.key}: ',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Expanded(
                        child: Text(
                          _formatParameterValue(_parameters[e.key]),
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
        else
          Text(
            'Using default values',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          ),
      ],
    );
  }

  String _formatParameterValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"$value"';
    if (value is Map) return '{...}';
    if (value is List) return '[${value.length} items]';
    return value.toString();
  }

  Widget _buildCategorySection(ControllerMethodCategory category) {
    return ExpansionTile(
      leading: Icon(category.icon),
      title: Text(category.name),
      subtitle: Text('${category.methods.length} methods'),
      children: category.methods.map((method) {
        final isSelected = _selectedMethod?.id == method.id;
        return ListTile(
          selected: isSelected,
          leading: isSelected
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.code),
          title: Text(method.name),
          subtitle: Text(
            method.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: method.parameters.isNotEmpty
              ? Chip(
                  label: Text('${method.parameters.length} params'),
                  visualDensity: VisualDensity.compact,
                )
              : null,
          onTap: () => _selectMethod(method),
        );
      }).toList(),
    );
  }

  void _selectMethod(ControllerMethodEntry method) {
    setState(() {
      _selectedMethod = method;
      _parameters = Map.from(method.parameters);
    });
    widget.onMethodSelected(method);
    widget.onParametersChanged(_parameters);
  }

  Future<void> _showParameterDialog() async {
    if (_selectedMethod == null) return;

    // Merge current values into parameters
    final params = <String, dynamic>{
      ..._selectedMethod!.parameters,
      ..._parameters,
    };

    final result = await showParameterDialog(
      context: context,
      title: '${_selectedMethod!.name} Parameters',
      parameters: params,
      requiredPaths: _selectedMethod!.requiredParameters,
    );

    if (result != null) {
      setState(() {
        _parameters = result;
      });
      widget.onParametersChanged(result);
    }
  }
}

/// A compact method selector for use in dialogs
class CompactMethodSelector extends StatelessWidget {
  final String? selectedMethodId;
  final ValueChanged<ControllerMethodEntry?> onMethodSelected;

  const CompactMethodSelector({
    super.key,
    this.selectedMethodId,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final registry = ControllerMethodsRegistry.instance;
    final selectedMethod = selectedMethodId != null
        ? registry.findMethodById(selectedMethodId!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Controller Method',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showMethodPickerDialog(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.code),
                const SizedBox(width: 12),
                Expanded(
                  child: selectedMethod != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedMethod.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              selectedMethod.description,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        )
                      : const Text('Select a method...'),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showMethodPickerDialog(BuildContext context) async {
    final result = await showMethodPickerDialog(
      context: context,
      selectedMethodId: selectedMethodId,
    );

    onMethodSelected(result);
  }
}

/// Shows a dialog for picking a controller method.
///
/// Returns the selected [ControllerMethodEntry] or null if cancelled.
Future<ControllerMethodEntry?> showMethodPickerDialog({
  required BuildContext context,
  String? selectedMethodId,
  String title = 'Select Method',
}) {
  return showDialog<ControllerMethodEntry>(
    context: context,
    builder: (context) =>
        MethodPickerDialog(selectedMethodId: selectedMethodId, title: title),
  );
}

/// Dialog for picking a controller method from the registry.
///
/// Displays categorized methods with search functionality.
class MethodPickerDialog extends StatefulWidget {
  /// The currently selected method ID, if any.
  final String? selectedMethodId;

  /// The title to display in the dialog.
  final String title;

  const MethodPickerDialog({
    super.key,
    this.selectedMethodId,
    this.title = 'Select Method',
  });

  @override
  State<MethodPickerDialog> createState() => _MethodPickerDialogState();
}

class _MethodPickerDialogState extends State<MethodPickerDialog> {
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
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
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
