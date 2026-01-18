import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_example/utils/parameter_dialog_utils.dart';

enum ParameterValueType {
  string,
  number,
  boolean,
  color,
  date,
  bytes,
  list,
  map,
}

class ParameterValueHint<T> {
  final T? value;
  final ParameterValueType type;

  const ParameterValueHint(this.value, this.type);
}

Future<Map<String, dynamic>?> showParameterDialog({
  required BuildContext context,
  required String title,
  required Map<String, dynamic> parameters,
  String? description,
  List<String> requiredPaths = const [],
}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => ParameterDialog(
      title: title,
      parameters: parameters,
      description: description,
      requiredPaths: requiredPaths,
    ),
  );
}

class ParameterDialog extends StatefulWidget {
  final String title;
  final String? description;
  final Map<String, dynamic> parameters;
  final List<String> requiredPaths;

  const ParameterDialog({
    super.key,
    required this.title,
    required this.parameters,
    this.description,
    this.requiredPaths = const [],
  });

  @override
  State<ParameterDialog> createState() => _ParameterDialogState();
}

class _ParameterDialogState extends State<ParameterDialog> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, ParameterValueType> _controllerTypes = {};
  final Map<String, List<Object>> _controllerPaths = {};
  final Map<String, ParameterValueType> _hintedTypes = {};
  final Map<String, String?> _errors = {};

  late Map<String, dynamic> _editedParameters;

  @override
  void initState() {
    super.initState();
    _editedParameters = _normalizeParameters(widget.parameters);
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> _normalizeParameters(Map<String, dynamic> parameters) {
    final cloned = ParameterDialogUtils.deepCloneMap(parameters);

    void walk(dynamic value, List<Object> path) {
      if (value is Map) {
        value.forEach((key, nested) => walk(nested, [...path, key]));
        return;
      }
      if (value is List) {
        for (var i = 0; i < value.length; i++) {
          walk(value[i], [...path, i]);
        }
        return;
      }
      if (value is ParameterValueHint) {
        final key = _pathKey(path);
        _hintedTypes[key] = value.type;
        ParameterDialogUtils.setValueAtPath(
          cloned,
          path,
          ParameterDialogUtils.deepCloneValue(value.value),
        );
      }
    }

    walk(cloned, []);
    return cloned;
  }

  String _pathKey(List<Object> path) {
    final buffer = StringBuffer();
    for (final segment in path) {
      if (segment is int) {
        buffer.write('[${segment}]');
      } else {
        if (buffer.isNotEmpty) buffer.write('.');
        buffer.write(segment.toString());
      }
    }
    return buffer.toString();
  }

  List<Object> _parsePathKey(String pathKey) {
    final result = <Object>[];
    final buffer = StringBuffer();
    var index = 0;

    void flushBuffer() {
      if (buffer.isNotEmpty) {
        result.add(buffer.toString());
        buffer.clear();
      }
    }

    while (index < pathKey.length) {
      final char = pathKey[index];
      if (char == '.') {
        flushBuffer();
        index++;
        continue;
      }
      if (char == '[') {
        flushBuffer();
        final endIndex = pathKey.indexOf(']', index);
        if (endIndex == -1) {
          buffer.write(pathKey.substring(index));
          break;
        }
        final rawIndex = pathKey.substring(index + 1, endIndex);
        final parsedIndex = int.tryParse(rawIndex);
        if (parsedIndex != null) {
          result.add(parsedIndex);
        } else {
          buffer.write(pathKey.substring(index, endIndex + 1));
        }
        index = endIndex + 1;
        continue;
      }
      buffer.write(char);
      index++;
    }

    flushBuffer();
    return result;
  }

  bool _isValueEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is Uint8List) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }

  ParameterValueType _inferType(dynamic value, List<Object> path) {
    final hinted = _hintedTypes[_pathKey(path)];
    if (hinted != null) return hinted;
    if (value is bool) return ParameterValueType.boolean;
    if (value is num) return ParameterValueType.number;
    if (value is Color) return ParameterValueType.color;
    if (value is DateTime) return ParameterValueType.date;
    if (value is Uint8List) return ParameterValueType.bytes;
    if (value is List) return ParameterValueType.list;
    if (value is Map) return ParameterValueType.map;
    return ParameterValueType.string;
  }

  TextEditingController _getController(
    List<Object> path,
    String initialValue,
    ParameterValueType type,
  ) {
    final key = _pathKey(path);
    if (_controllers.containsKey(key)) {
      return _controllers[key]!;
    }

    final controller = TextEditingController(text: initialValue);
    _controllers[key] = controller;
    _controllerTypes[key] = type;
    _controllerPaths[key] = path;
    return controller;
  }

  Future<void> _pickBytes(List<Object> path) async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;

    final bytes = result.files.first.bytes;
    if (bytes == null) return;

    setState(() {
      ParameterDialogUtils.setValueAtPath(_editedParameters, path, bytes);
      final key = _pathKey(path);
      _controllers[key]?.text = 'base64:${base64.encode(bytes)}';
      _errors[key] = null;
    });
  }

  Future<void> _pickDate(List<Object> path, DateTime? current) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: now.subtract(const Duration(days: 3650)),
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (date == null) return;

    setState(() {
      ParameterDialogUtils.setValueAtPath(_editedParameters, path, date);
    });
  }

  Future<void> _pickColor(List<Object> path, Color? current) async {
    final picked = await showDialog<Color>(
      context: context,
      builder: (context) => _ColorPickerDialog(current: current),
    );

    if (picked == null) return;
    setState(() {
      ParameterDialogUtils.setValueAtPath(_editedParameters, path, picked);
    });
  }

  void _addMapEntry(List<Object> path) {
    final keyController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Field'),
        content: TextField(
          controller: keyController,
          decoration: const InputDecoration(
            labelText: 'Key',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final key = keyController.text.trim();
              if (key.isEmpty) return;
              setState(() {
                final map = ParameterDialogUtils.getValueAtPath(
                  _editedParameters,
                  path,
                );
                if (map is Map) {
                  map[key] = '';
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addListEntry(List<Object> path) {
    setState(() {
      final list =
          ParameterDialogUtils.getValueAtPath(_editedParameters, path) as List;
      if (list.isEmpty) {
        list.add('');
        return;
      }
      list.add(ParameterDialogUtils.deepCloneValue(list.last));
    });
  }

  void _removeEntry(List<Object> path, Object keyOrIndex) {
    setState(() {
      final container = ParameterDialogUtils.getValueAtPath(
        _editedParameters,
        path,
      );
      if (container is Map) {
        container.remove(keyOrIndex);
      } else if (container is List && keyOrIndex is int) {
        if (keyOrIndex >= 0 && keyOrIndex < container.length) {
          container.removeAt(keyOrIndex);
        }
      }
    });
  }

  void _apply() {
    _errors.clear();

    for (final entry in _controllers.entries) {
      final key = entry.key;
      final controller = entry.value;
      final path = _controllerPaths[key]!;
      final type = _controllerTypes[key]!;
      final text = controller.text.trim();

      switch (type) {
        case ParameterValueType.number:
          final parsed = ParameterDialogUtils.parseNumber(text);
          if (text.isNotEmpty && parsed == null) {
            _errors[key] = 'Invalid number';
            continue;
          }
          ParameterDialogUtils.setValueAtPath(_editedParameters, path, parsed);
          break;
        case ParameterValueType.bytes:
          final parsed = ParameterDialogUtils.parseBytes(text);
          if (text.isNotEmpty && parsed == null) {
            _errors[key] = 'Invalid base64';
            continue;
          }
          ParameterDialogUtils.setValueAtPath(_editedParameters, path, parsed);
          break;
        default:
          ParameterDialogUtils.setValueAtPath(_editedParameters, path, text);
          break;
      }
    }

    for (final requiredPath in widget.requiredPaths) {
      if (_errors.containsKey(requiredPath)) {
        continue;
      }
      final parsedPath = _parsePathKey(requiredPath);
      final value = ParameterDialogUtils.getValueAtPath(
        _editedParameters,
        parsedPath,
      );
      if (_isValueEmpty(value)) {
        _errors[requiredPath] = 'Required';
      }
    }

    if (_errors.isNotEmpty) {
      setState(() {});
      return;
    }

    Navigator.pop(context, _editedParameters);
  }

  @override
  Widget build(BuildContext context) {
    final parameterWidgets = _buildParameterWidgets(_editedParameters, []);

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.description != null) ...[
                Text(
                  widget.description!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
              ],
              ...parameterWidgets,
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _apply, child: const Text('Apply')),
      ],
    );
  }

  List<Widget> _buildParameterWidgets(dynamic value, List<Object> path) {
    if (value is Map) {
      return [
        ...value.entries.map((entry) {
          final entryPath = <Object>[...path, entry.key.toString()];
          final type = _inferType(entry.value, entryPath);
          return _buildField(
            entry.key.toString(),
            entry.value,
            entryPath,
            type,
            canRemove: path.isNotEmpty,
            onRemove: () => _removeEntry(path, entry.key),
          );
        }),
        if (path.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _addMapEntry(path),
              icon: const Icon(Icons.add),
              label: const Text('Add field'),
            ),
          ),
      ];
    }

    if (value is List) {
      return [
        ...value.asMap().entries.map((entry) {
          final index = entry.key;
          final itemPath = <Object>[...path, index];
          final type = _inferType(entry.value, itemPath);
          return _buildField(
            '[${entry.key}]',
            entry.value,
            itemPath,
            type,
            canRemove: true,
            onRemove: () => _removeEntry(path, index),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => _addListEntry(path),
            icon: const Icon(Icons.add),
            label: const Text('Add item'),
          ),
        ),
      ];
    }

    final type = _inferType(value, path);
    return [_buildField(path.last.toString(), value, path, type)];
  }

  Widget _buildField(
    String label,
    dynamic value,
    List<Object> path,
    ParameterValueType type, {
    bool canRemove = false,
    VoidCallback? onRemove,
  }) {
    final key = _pathKey(path);
    final errorText = _errors[key];

    Widget field;

    switch (type) {
      case ParameterValueType.boolean:
        field = SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          value: (value as bool?) ?? false,
          onChanged: (updated) {
            setState(() {
              ParameterDialogUtils.setValueAtPath(
                _editedParameters,
                path,
                updated,
              );
            });
          },
        );
        break;
      case ParameterValueType.color:
        final color = value as Color?;
        field = Row(
          children: [
            Expanded(child: Text(label)),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color ?? Colors.transparent,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => _pickColor(path, color),
              child: const Text('Pick'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  ParameterDialogUtils.setValueAtPath(
                    _editedParameters,
                    path,
                    null,
                  );
                });
              },
              child: const Text('Clear'),
            ),
          ],
        );
        break;
      case ParameterValueType.date:
        final date = value as DateTime?;
        field = Row(
          children: [
            Expanded(
              child: Text(
                '$label: ${date?.toIso8601String().split('T').first ?? 'Not set'}',
              ),
            ),
            TextButton(
              onPressed: () => _pickDate(path, date),
              child: const Text('Pick'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  ParameterDialogUtils.setValueAtPath(
                    _editedParameters,
                    path,
                    null,
                  );
                });
              },
              child: const Text('Clear'),
            ),
          ],
        );
        break;
      case ParameterValueType.bytes:
        final controller = _getController(
          path,
          value is Uint8List ? 'base64:${base64.encode(value)}' : '',
          type,
        );
        field = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Base64 (prefix with base64:) or text',
                border: const OutlineInputBorder(),
                errorText: errorText,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _pickBytes(path),
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Pick file'),
                ),
                if (value is Uint8List) Text('(${value.length} bytes)'),
              ],
            ),
          ],
        );
        break;
      case ParameterValueType.number:
        final controller = _getController(path, value?.toString() ?? '', type);
        field = TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            errorText: errorText,
          ),
        );
        break;
      case ParameterValueType.list:
        field = ExpansionTile(
          title: Text(label),
          children: _buildParameterWidgets(value, path),
        );
        break;
      case ParameterValueType.map:
        field = ExpansionTile(
          title: Text(label),
          children: _buildParameterWidgets(value, path),
        );
        break;
      case ParameterValueType.string:
        final controller = _getController(path, value?.toString() ?? '', type);
        field = TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            errorText: errorText,
          ),
        );
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: field),
              if (canRemove && onRemove != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onRemove,
                ),
              ],
            ],
          ),
          if (errorText != null &&
              type != ParameterValueType.string &&
              type != ParameterValueType.number &&
              type != ParameterValueType.bytes)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                errorText,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ColorPickerDialog extends StatelessWidget {
  final Color? current;

  const _ColorPickerDialog({this.current});

  @override
  Widget build(BuildContext context) {
    final colors = <Color>[
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
    ];

    return AlertDialog(
      title: const Text('Pick a color'),
      content: SizedBox(
        width: 280,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors
              .map(
                (color) => GestureDetector(
                  onTap: () => Navigator.pop(context, color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: current == color
                            ? Colors.black
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
