import '../in_app_webview/webview.dart';

///Class that represents the [WebView] native implementation to be used.
class WebViewImplementation {
  final int _value;

  const WebViewImplementation._internal(this._value);

  ///Set of all values of [WebViewImplementation].
  static final Set<WebViewImplementation> values =
  [WebViewImplementation.NATIVE].toSet();

  ///Gets a possible [WebViewImplementation] instance from an [int] value.
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

  ///Gets [int] value.
  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 0:
      default:
        return "NATIVE";
    }
  }

  ///Default native implementation, such as `WKWebView` for iOS and `android.webkit.WebView` for Android.
  static const NATIVE = const WebViewImplementation._internal(0);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}