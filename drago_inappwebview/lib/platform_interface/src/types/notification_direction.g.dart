// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_direction.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Constants that describe the text direction.
///
///This corresponds to [COREWEBVIEW2_TEXT_DIRECTION_KIND](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.3595.46#corewebview2_text_direction_kind).
class TextDirectionKind {
  final int _value;
  final int? _nativeValue;
  const TextDirectionKind._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory TextDirectionKind._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => TextDirectionKind._internal(value, nativeValue());

  ///Default text direction.
  static const DEFAULT = TextDirectionKind._internal(0, 0);

  ///Left-to-right text direction.
  static const LEFT_TO_RIGHT = TextDirectionKind._internal(1, 1);

  ///Right-to-left text direction.
  static const RIGHT_TO_LEFT = TextDirectionKind._internal(2, 2);

  ///Set of all values of [TextDirectionKind].
  static final Set<TextDirectionKind> values = [
    TextDirectionKind.DEFAULT,
    TextDirectionKind.LEFT_TO_RIGHT,
    TextDirectionKind.RIGHT_TO_LEFT,
  ].toSet();

  ///Gets a possible [TextDirectionKind] instance from [int] value.
  static TextDirectionKind? fromValue(int? value) {
    if (value != null) {
      try {
        return TextDirectionKind.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [TextDirectionKind] instance from a native value.
  static TextDirectionKind? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return TextDirectionKind.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [TextDirectionKind] instance value with name [name].
  ///
  /// Goes through [TextDirectionKind.values] looking for a value with
  /// name [name], as reported by [TextDirectionKind.name].
  /// Returns the first value with the given name, otherwise `null`.
  static TextDirectionKind? byName(String? name) {
    if (name != null) {
      try {
        return TextDirectionKind.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [TextDirectionKind] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, TextDirectionKind> asNameMap() =>
      <String, TextDirectionKind>{
        for (final value in TextDirectionKind.values) value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 0:
        return 'DEFAULT';
      case 1:
        return 'LEFT_TO_RIGHT';
      case 2:
        return 'RIGHT_TO_LEFT';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return _nativeValue != null;
  }

  @override
  String toString() {
    return name();
  }
}
