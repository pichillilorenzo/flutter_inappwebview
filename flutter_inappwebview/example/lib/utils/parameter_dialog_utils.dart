import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class ParameterDialogUtils {
  static Map<String, dynamic> deepCloneMap(Map<String, dynamic> input) {
    return input.map((key, value) => MapEntry(key, deepCloneValue(value)));
  }

  static dynamic deepCloneValue(dynamic value) {
    if (value is Map) {
      return value.map((key, nested) => MapEntry(key, deepCloneValue(nested)));
    }
    if (value is List) {
      return value.map(deepCloneValue).toList();
    }
    if (value is Uint8List) {
      return Uint8List.fromList(value);
    }
    if (value is DateTime) {
      return DateTime.fromMillisecondsSinceEpoch(value.millisecondsSinceEpoch);
    }
    if (value is Color) {
      return Color(value.value);
    }
    return value;
  }

  static Uint8List? parseBytes(String input) {
    final normalized = input.trim();
    if (normalized.isEmpty) return null;

    String? base64Payload;
    if (normalized.startsWith('base64:')) {
      base64Payload = normalized.substring('base64:'.length).trim();
    } else if (normalized.startsWith('data:')) {
      final base64Marker = ';base64,';
      final markerIndex = normalized.indexOf(base64Marker);
      if (markerIndex != -1) {
        base64Payload = normalized.substring(markerIndex + base64Marker.length);
      }
    }

    if (base64Payload != null) {
      try {
        return Uint8List.fromList(base64.decode(base64Payload));
      } catch (_) {
        return null;
      }
    }

    return Uint8List.fromList(utf8.encode(normalized));
  }

  static num? parseNumber(String input) {
    final normalized = input.trim();
    if (normalized.isEmpty) return null;
    return num.tryParse(normalized);
  }

  static dynamic getValueAtPath(dynamic root, List<Object> path) {
    dynamic current = root;
    for (final segment in path) {
      if (segment is int) {
        if (current is List && segment < current.length) {
          current = current[segment];
        } else {
          return null;
        }
      } else {
        if (current is Map && current.containsKey(segment)) {
          current = current[segment];
        } else {
          return null;
        }
      }
    }
    return current;
  }

  static void setValueAtPath(dynamic root, List<Object> path, dynamic value) {
    if (path.isEmpty) return;

    dynamic current = root;
    for (var i = 0; i < path.length - 1; i++) {
      final segment = path[i];
      if (segment is int) {
        if (current is List) {
          if (segment >= current.length) {
            current.length = segment + 1;
          }
          current = current[segment];
        } else {
          return;
        }
      } else {
        if (current is Map) {
          current = current[segment];
        } else {
          return;
        }
      }
    }

    final last = path.last;
    if (last is int && current is List) {
      if (last >= current.length) {
        current.length = last + 1;
      }
      current[last] = value;
    } else if (last is String && current is Map) {
      current[last] = value;
    }
  }
}
