// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'js_prompt_response_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used by [JsPromptResponse] class.
class JsPromptResponseAction {
  final int _value;
  final int _nativeValue;
  const JsPromptResponseAction._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory JsPromptResponseAction._internalMultiPlatform(
          int value, Function nativeValue) =>
      JsPromptResponseAction._internal(value, nativeValue());

  ///Confirm that the user hit cancel button.
  static const CANCEL = JsPromptResponseAction._internal(1, 1);

  ///Confirm that the user hit confirm button.
  static const CONFIRM = JsPromptResponseAction._internal(0, 0);

  ///Set of all values of [JsPromptResponseAction].
  static final Set<JsPromptResponseAction> values = [
    JsPromptResponseAction.CANCEL,
    JsPromptResponseAction.CONFIRM,
  ].toSet();

  ///Gets a possible [JsPromptResponseAction] instance from [int] value.
  static JsPromptResponseAction? fromValue(int? value) {
    if (value != null) {
      try {
        return JsPromptResponseAction.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [JsPromptResponseAction] instance from a native value.
  static JsPromptResponseAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return JsPromptResponseAction.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [JsPromptResponseAction] instance value with name [name].
  ///
  /// Goes through [JsPromptResponseAction.values] looking for a value with
  /// name [name], as reported by [JsPromptResponseAction.name].
  /// Returns the first value with the given name, otherwise `null`.
  static JsPromptResponseAction? byName(String? name) {
    if (name != null) {
      try {
        return JsPromptResponseAction.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [JsPromptResponseAction] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, JsPromptResponseAction> asNameMap() =>
      <String, JsPromptResponseAction>{
        for (final value in JsPromptResponseAction.values) value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'CANCEL';
      case 0:
        return 'CONFIRM';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return true;
  }

  @override
  String toString() {
    return name();
  }
}
