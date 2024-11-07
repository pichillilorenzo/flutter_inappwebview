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
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
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

  /// Gets a possible [WebViewRenderProcessAction] instance value with name [name].
  ///
  /// Goes through [WebViewRenderProcessAction.values] looking for a value with
  /// name [name], as reported by [WebViewRenderProcessAction.name].
  /// Returns the first value with the given name, otherwise `null`.
  static WebViewRenderProcessAction? byName(String? name) {
    if (name != null) {
      try {
        return WebViewRenderProcessAction.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [WebViewRenderProcessAction] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, WebViewRenderProcessAction> asNameMap() =>
      <String, WebViewRenderProcessAction>{
        for (final value in WebViewRenderProcessAction.values)
          value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 0:
        return 'TERMINATE';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return name();
  }
}
