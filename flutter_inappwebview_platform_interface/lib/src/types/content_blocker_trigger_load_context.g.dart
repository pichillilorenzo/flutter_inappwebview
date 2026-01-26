// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_blocker_trigger_load_context.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the kind of load context that can be used with a [ContentBlockerTrigger].
class ContentBlockerTriggerLoadContext {
  final String _value;
  final String? _nativeValue;
  const ContentBlockerTriggerLoadContext._internal(
    this._value,
    this._nativeValue,
  );
  // ignore: unused_element
  factory ContentBlockerTriggerLoadContext._internalMultiPlatform(
    String value,
    Function nativeValue,
  ) => ContentBlockerTriggerLoadContext._internal(value, nativeValue());

  ///Child frame load context
  static const CHILD_FRAME = ContentBlockerTriggerLoadContext._internal(
    'child-frame',
    'child-frame',
  );

  ///Top frame load context
  static const TOP_FRAME = ContentBlockerTriggerLoadContext._internal(
    'top-frame',
    'top-frame',
  );

  ///Set of all values of [ContentBlockerTriggerLoadContext].
  static final Set<ContentBlockerTriggerLoadContext> values = [
    ContentBlockerTriggerLoadContext.CHILD_FRAME,
    ContentBlockerTriggerLoadContext.TOP_FRAME,
  ].toSet();

  ///Gets a possible [ContentBlockerTriggerLoadContext] instance from [String] value.
  static ContentBlockerTriggerLoadContext? fromValue(String? value) {
    if (value != null) {
      try {
        return ContentBlockerTriggerLoadContext.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ContentBlockerTriggerLoadContext] instance from a native value.
  static ContentBlockerTriggerLoadContext? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return ContentBlockerTriggerLoadContext.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [ContentBlockerTriggerLoadContext] instance value with name [name].
  ///
  /// Goes through [ContentBlockerTriggerLoadContext.values] looking for a value with
  /// name [name], as reported by [ContentBlockerTriggerLoadContext.name].
  /// Returns the first value with the given name, otherwise `null`.
  static ContentBlockerTriggerLoadContext? byName(String? name) {
    if (name != null) {
      try {
        return ContentBlockerTriggerLoadContext.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [ContentBlockerTriggerLoadContext] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, ContentBlockerTriggerLoadContext> asNameMap() =>
      <String, ContentBlockerTriggerLoadContext>{
        for (final value in ContentBlockerTriggerLoadContext.values)
          value.name(): value,
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value if supported by the current platform, otherwise `null`.
  String? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'child-frame':
        return 'CHILD_FRAME';
      case 'top-frame':
        return 'TOP_FRAME';
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
    return _value;
  }
}
