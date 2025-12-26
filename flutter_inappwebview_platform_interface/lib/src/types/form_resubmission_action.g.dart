// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_resubmission_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the action to take used by the [PlatformWebViewCreationParams.onFormResubmission] event.
class FormResubmissionAction {
  final int _value;
  final int _nativeValue;
  const FormResubmissionAction._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory FormResubmissionAction._internalMultiPlatform(
          int value, Function nativeValue) =>
      FormResubmissionAction._internal(value, nativeValue());

  ///Don't resend data
  static const DONT_RESEND = FormResubmissionAction._internal(1, 1);

  ///Resend data
  static const RESEND = FormResubmissionAction._internal(0, 0);

  ///Set of all values of [FormResubmissionAction].
  static final Set<FormResubmissionAction> values = [
    FormResubmissionAction.DONT_RESEND,
    FormResubmissionAction.RESEND,
  ].toSet();

  ///Gets a possible [FormResubmissionAction] instance from [int] value.
  static FormResubmissionAction? fromValue(int? value) {
    if (value != null) {
      try {
        return FormResubmissionAction.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [FormResubmissionAction] instance from a native value.
  static FormResubmissionAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return FormResubmissionAction.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [FormResubmissionAction] instance value with name [name].
  ///
  /// Goes through [FormResubmissionAction.values] looking for a value with
  /// name [name], as reported by [FormResubmissionAction.name].
  /// Returns the first value with the given name, otherwise `null`.
  static FormResubmissionAction? byName(String? name) {
    if (name != null) {
      try {
        return FormResubmissionAction.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [FormResubmissionAction] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, FormResubmissionAction> asNameMap() =>
      <String, FormResubmissionAction>{
        for (final value in FormResubmissionAction.values) value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'DONT_RESEND';
      case 0:
        return 'RESEND';
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
