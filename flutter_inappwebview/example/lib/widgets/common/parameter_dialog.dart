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
  enumeration,
}

class ParameterValueHint<T> {
  final T? value;
  final ParameterValueType type;

  const ParameterValueHint(this.value, this.type);
}

/// A specialized hint for enum parameters that includes available values.
/// Works with both standard Dart enums and custom enum-like classes
/// (like UserScriptInjectionTime, CompressFormat) that have a `values` property
/// and a `name()` method.
class EnumParameterValueHint<T> extends ParameterValueHint<Object?> {
  /// The list of all available enum values.
  /// Accepts both List<T> and Set<T> (will be converted to List internally).
  final List<T> enumValues;

  /// Whether the enum should allow multiple selections.
  /// Useful for bitmask/flag-style enums.
  final bool isMultiSelect;

  /// Optional display names for enum values.
  /// For standard Dart enums, defaults to `e.name`.
  /// For custom enum-like classes, this is optional; the default
  /// resolver tries `name()` then `.name` before falling back to `toString()`.
  final String Function(T)? displayName;

  /// Creates an enum parameter value hint.
  /// [values] can be a List<T> or Set<T> (common for custom enum-like classes).
  const EnumParameterValueHint(
    Object? value,
    this.enumValues, {
    this.displayName,
    this.isMultiSelect = false,
  }) : super(value, ParameterValueType.enumeration);

  /// Factory constructor that accepts an Iterable (List or Set).
  factory EnumParameterValueHint.fromIterable(
    Object? value,
    Iterable<T> values, {
    String Function(T)? displayName,
    bool isMultiSelect = false,
  }) {
    return EnumParameterValueHint(
      value,
      values.toList(),
      displayName: displayName,
      isMultiSelect: isMultiSelect,
    );
  }
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

  /// Stores enum metadata for enum parameters (key -> EnumInfo)
  final Map<String, _EnumInfo> _enumInfoMap = {};

  late Map<String, dynamic> _editedParameters;

  /// Default display name function that works with both Dart enums and custom enum-like classes.
  /// Tries to call `.name()` method first (for custom classes), then falls back to `.name` property (for Dart enums).
  static String _defaultEnumDisplayName(dynamic e) {
    if (e == null) return '(none)';
    // Try calling name() method first (for custom enum-like classes)
    try {
      final dynamic result = (e as dynamic).name();
      if (result is String) return result;
    } catch (_) {}
    // Fall back to .name property (for Dart enums)
    try {
      final dynamic result = (e as dynamic).name;
      if (result is String) return result;
    } catch (_) {}
    // Last resort: toString
    return e.toString();
  }

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
      if (value is EnumParameterValueHint) {
        final key = _pathKey(path);
        _hintedTypes[key] = ParameterValueType.enumeration;
        // Wrap the typed displayName function in a dynamic closure to handle
        // the generic type properly (e.g., String Function(CompressFormat) -> String Function(dynamic))
        // We use dynamic access here to bypass covariant check failures with generic functions
        final userDisplayName = (value as dynamic).displayName;
        String Function(dynamic) displayNameFn;
        if (userDisplayName != null) {
          displayNameFn = (dynamic e) => userDisplayName(e);
        } else {
          displayNameFn = _defaultEnumDisplayName;
        }
        final enumValues = (value as dynamic).enumValues.toList();
        final isMultiSelect = (value as dynamic).isMultiSelect == true;
        _enumInfoMap[key] = _EnumInfo(
          values: enumValues,
          displayName: displayNameFn,
          isMultiSelect: isMultiSelect,
        );
        final normalizedValue = isMultiSelect
            ? _normalizeEnumMultiSelectValue(value.value, enumValues)
            : value.value;
        ParameterDialogUtils.setValueAtPath(cloned, path, normalizedValue);
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

  List<dynamic> _normalizeEnumMultiSelectValue(
    dynamic value,
    List<dynamic> allowedValues,
  ) {
    if (value == null) return <dynamic>[];

    Iterable<dynamic> rawValues;
    if (value is Set) {
      rawValues = value;
    } else if (value is List) {
      rawValues = value;
    } else {
      rawValues = [value];
    }

    return rawValues.where(allowedValues.contains).toList();
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
                labelText: 'Enter text (UTF-8) or base64:... for binary',
                hintText: 'Type text here or paste base64:...',
                border: const OutlineInputBorder(),
                errorText: errorText,
              ),
              maxLines: 4,
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
            Text(
              'Tip: Plain text is converted to UTF-8 bytes. Use "base64:..." prefix for binary data.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
      case ParameterValueType.enumeration:
        final enumInfo = _enumInfoMap[key];
        if (enumInfo == null) {
          // Fallback to string field if no enum info
          final controller = _getController(
            path,
            value?.toString() ?? '',
            ParameterValueType.string,
          );
          field = TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              errorText: errorText,
            ),
          );
        } else if (enumInfo.isMultiSelect) {
          final selectedValues = _normalizeEnumMultiSelectValue(
            value,
            enumInfo.values,
          );
          field = InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              errorText: errorText,
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: enumInfo.values.map((enumValue) {
                final isSelected = selectedValues.contains(enumValue);
                return FilterChip(
                  label: Text(enumInfo.displayName(enumValue)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      final updated = List<dynamic>.from(selectedValues);
                      if (selected) {
                        if (!updated.contains(enumValue)) {
                          updated.add(enumValue);
                        }
                      } else {
                        updated.remove(enumValue);
                      }
                      ParameterDialogUtils.setValueAtPath(
                        _editedParameters,
                        path,
                        updated,
                      );
                    });
                  },
                );
              }).toList(),
            ),
          );
        } else {
          field = DropdownButtonFormField<dynamic>(
            value: value,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              errorText: errorText,
            ),
            items: [
              const DropdownMenuItem<dynamic>(
                value: null,
                child: Text('(none)'),
              ),
              ...enumInfo.values.map(
                (enumValue) => DropdownMenuItem<dynamic>(
                  value: enumValue,
                  child: Text(enumInfo.displayName(enumValue)),
                ),
              ),
            ],
            onChanged: (newValue) {
              setState(() {
                ParameterDialogUtils.setValueAtPath(
                  _editedParameters,
                  path,
                  newValue,
                );
              });
            },
          );
        }
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

/// Internal class to store enum metadata.
/// Works with both standard Dart enums and custom enum-like classes.
class _EnumInfo {
  final List<dynamic> values;
  final String Function(dynamic) displayName;
  final bool isMultiSelect;

  const _EnumInfo({
    required this.values,
    required this.displayName,
    required this.isMultiSelect,
  });
}

class _ColorPickerDialog extends StatefulWidget {
  final Color? current;

  const _ColorPickerDialog({this.current});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late HSVColor _hsvColor;
  late TextEditingController _hexController;

  // Common preset colors for quick selection
  static const List<Color> _presetColors = [
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
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    _hsvColor = HSVColor.fromColor(widget.current ?? Colors.blue);
    _hexController = TextEditingController(
      text: _colorToHex(_hsvColor.toColor()),
    );
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  Color? _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    if (hex.length != 8) return null;
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return null;
    return Color(value);
  }

  void _updateFromHex(String hex) {
    final color = _hexToColor(hex);
    if (color != null) {
      setState(() {
        _hsvColor = HSVColor.fromColor(color);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _hsvColor.toColor();

    return AlertDialog(
      title: const Text('Pick a color'),
      content: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Color preview
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: currentColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(height: 16),

              // Hue slider
              _buildSliderRow(
                label: 'Hue',
                value: _hsvColor.hue,
                max: 360,
                activeColor: HSVColor.fromAHSV(
                  1,
                  _hsvColor.hue,
                  1,
                  1,
                ).toColor(),
                gradient: LinearGradient(
                  colors: List.generate(
                    7,
                    (i) => HSVColor.fromAHSV(1, i * 60.0, 1, 1).toColor(),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _hsvColor = _hsvColor.withHue(value);
                    _hexController.text = _colorToHex(_hsvColor.toColor());
                  });
                },
              ),

              // Saturation slider
              _buildSliderRow(
                label: 'Saturation',
                value: _hsvColor.saturation * 100,
                max: 100,
                activeColor: currentColor,
                gradient: LinearGradient(
                  colors: [
                    HSVColor.fromAHSV(
                      1,
                      _hsvColor.hue,
                      0,
                      _hsvColor.value,
                    ).toColor(),
                    HSVColor.fromAHSV(
                      1,
                      _hsvColor.hue,
                      1,
                      _hsvColor.value,
                    ).toColor(),
                  ],
                ),
                onChanged: (value) {
                  setState(() {
                    _hsvColor = _hsvColor.withSaturation(value / 100);
                    _hexController.text = _colorToHex(_hsvColor.toColor());
                  });
                },
              ),

              // Value/Brightness slider
              _buildSliderRow(
                label: 'Brightness',
                value: _hsvColor.value * 100,
                max: 100,
                activeColor: currentColor,
                gradient: LinearGradient(
                  colors: [
                    Colors.black,
                    HSVColor.fromAHSV(
                      1,
                      _hsvColor.hue,
                      _hsvColor.saturation,
                      1,
                    ).toColor(),
                  ],
                ),
                onChanged: (value) {
                  setState(() {
                    _hsvColor = _hsvColor.withValue(value / 100);
                    _hexController.text = _colorToHex(_hsvColor.toColor());
                  });
                },
              ),

              const SizedBox(height: 12),

              // Hex input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _hexController,
                      decoration: const InputDecoration(
                        labelText: 'Hex',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixText: '#',
                      ),
                      onChanged: _updateFromHex,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // RGB display
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'R: ${currentColor.red}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      Text(
                        'G: ${currentColor.green}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      Text(
                        'B: ${currentColor.blue}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Preset colors
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Presets',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _presetColors
                    .map(
                      (color) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _hsvColor = HSVColor.fromColor(color);
                            _hexController.text = _colorToHex(color);
                          });
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _hsvColor.toColor().value == color.value
                                  ? Colors.black
                                  : Colors.grey.shade300,
                              width: _hsvColor.toColor().value == color.value
                                  ? 2
                                  : 1,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
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
          onPressed: () => Navigator.pop(context, currentColor),
          child: const Text('Select'),
        ),
      ],
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double max,
    required Color activeColor,
    required Gradient gradient,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              Text(
                value.toStringAsFixed(0),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 24,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 24,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                trackShape: const RoundedRectSliderTrackShape(),
                activeTrackColor: Colors.transparent,
                inactiveTrackColor: Colors.transparent,
                thumbColor: Colors.white,
                overlayColor: activeColor.withOpacity(0.2),
              ),
              child: Slider(
                value: value,
                min: 0,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
