// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webview_implementation.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the [WebView] native implementation to be used.
class WebViewImplementation {
  final int _value;
  final int _nativeValue;
  const WebViewImplementation._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory WebViewImplementation._internalMultiPlatform(
          int value, Function nativeValue) =>
      WebViewImplementation._internal(value, nativeValue());

  ///Default native implementation, such as `WKWebView` for iOS and `android.webkit.WebView` for Android.
  static const NATIVE = WebViewImplementation._internal(0, 0);

  ///Set of all values of [WebViewImplementation].
  static final Set<WebViewImplementation> values = [
    WebViewImplementation.NATIVE,
  ].toSet();

  ///Gets a possible [WebViewImplementation] instance from [int] value.
  static WebViewImplementation? fromValue(int? value) {
    if (value != null) {
      try {
        return WebViewImplementation.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [WebViewImplementation] instance from a native value.
  static WebViewImplementation? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return WebViewImplementation.values
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
        return 'NATIVE';
    }
    return _value.toString();
  }
}
