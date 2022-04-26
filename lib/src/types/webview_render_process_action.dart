import '../in_app_webview/webview.dart';

///Class that represents the action to take used by the [WebView.onRenderProcessUnresponsive] and [WebView.onRenderProcessResponsive] event
///to terminate the Android [WebViewRenderProcess](https://developer.android.com/reference/android/webkit/WebViewRenderProcess).
class WebViewRenderProcessAction {
  final int _value;

  const WebViewRenderProcessAction._internal(this._value);

  ///Gets [int] value.
  int toValue() => _value;

  ///Cause this renderer to terminate.
  static const TERMINATE = const WebViewRenderProcessAction._internal(0);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;

  Map<String, dynamic> toMap() {
    return {"action": _value};
  }
}