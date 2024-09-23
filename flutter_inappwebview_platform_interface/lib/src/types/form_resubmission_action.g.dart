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

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return 'DONT_RESEND';
      case 0:
        return 'RESEND';
    }
    return _value.toString();
  }
}
