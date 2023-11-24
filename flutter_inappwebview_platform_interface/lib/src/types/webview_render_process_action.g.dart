// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webview_render_process_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the action to take used by the [PlatformWebViewCreationParams.onRenderProcessUnresponsive] and [PlatformWebViewCreationParams.onRenderProcessResponsive] event
///to terminate the Android [WebViewRenderProcess](https://developer.android.com/reference/android/webkit/WebViewRenderProcess).
class WebViewRenderProcessAction {
  final int _value;
  final int _nativeValue;
  const WebViewRenderProcessAction._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory WebViewRenderProcessAction._internalMultiPlatform(
          int value, Function nativeValue) =>
      WebViewRenderProcessAction._internal(value, nativeValue());

  ///Cause this renderer to terminate.
  static const TERMINATE = WebViewRenderProcessAction._internal(0, 0);

  ///Set of all values of [WebViewRenderProcessAction].
  static final Set<WebViewRenderProcessAction> values = [
    WebViewRenderProcessAction.TERMINATE,
  ].toSet();

  ///Gets a possible [WebViewRenderProcessAction] instance from [int] value.
  static WebViewRenderProcessAction? fromValue(int? value) {
    if (value != null) {
      try {
        return WebViewRenderProcessAction.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [WebViewRenderProcessAction] instance from a native value.
  static WebViewRenderProcessAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return WebViewRenderProcessAction.values
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
        return 'TERMINATE';
    }
    return _value.toString();
  }
}
