// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requested_with_header_mode.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to set how the WebView will set the `X-Requested-With` header on requests.
class RequestedWithHeaderMode {
  final int _value;
  final int _nativeValue;
  const RequestedWithHeaderMode._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory RequestedWithHeaderMode._internalMultiPlatform(
          int value, Function nativeValue) =>
      RequestedWithHeaderMode._internal(value, nativeValue());

  ///In this mode the WebView will not add an `X-Requested-With` header on HTTP requests automatically.
  static const NO_HEADER = RequestedWithHeaderMode._internal(0, 0);

  ///In this mode the WebView automatically add an `X-Requested-With` header to outgoing requests,
  ///if the application or the loaded webpage has not already set a header value.
  ///The value of this automatically added header will be the package name of the app. This is the default mode.
  static const APP_PACKAGE_NAME = RequestedWithHeaderMode._internal(1, 1);

  ///Set of all values of [RequestedWithHeaderMode].
  static final Set<RequestedWithHeaderMode> values = [
    RequestedWithHeaderMode.NO_HEADER,
    RequestedWithHeaderMode.APP_PACKAGE_NAME,
  ].toSet();

  ///Gets a possible [RequestedWithHeaderMode] instance from [int] value.
  static RequestedWithHeaderMode? fromValue(int? value) {
    if (value != null) {
      try {
        return RequestedWithHeaderMode.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [RequestedWithHeaderMode] instance from a native value.
  static RequestedWithHeaderMode? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return RequestedWithHeaderMode.values
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
        return 'NO_HEADER';
      case 1:
        return 'APP_PACKAGE_NAME';
    }
    return _value.toString();
  }
}
