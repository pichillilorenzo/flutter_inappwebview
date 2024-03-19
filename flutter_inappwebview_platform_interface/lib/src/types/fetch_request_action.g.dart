// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fetch_request_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used by [FetchRequest] class.
class FetchRequestAction {
  final int _value;
  final int _nativeValue;
  const FetchRequestAction._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory FetchRequestAction._internalMultiPlatform(
          int value, Function nativeValue) =>
      FetchRequestAction._internal(value, nativeValue());

  ///Aborts the fetch request.
  static const ABORT = FetchRequestAction._internal(0, 0);

  ///Proceeds with the fetch request.
  static const PROCEED = FetchRequestAction._internal(1, 1);

  ///Set of all values of [FetchRequestAction].
  static final Set<FetchRequestAction> values = [
    FetchRequestAction.ABORT,
    FetchRequestAction.PROCEED,
  ].toSet();

  ///Gets a possible [FetchRequestAction] instance from [int] value.
  static FetchRequestAction? fromValue(int? value) {
    if (value != null) {
      try {
        return FetchRequestAction.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [FetchRequestAction] instance from a native value.
  static FetchRequestAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return FetchRequestAction.values
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
      case 0:
        return 'ABORT';
      case 1:
        return 'PROCEED';
    }
    return _value.toString();
  }
}
