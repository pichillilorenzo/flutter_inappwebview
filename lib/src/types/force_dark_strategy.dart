import '../in_app_webview/webview.dart';

///Class used to indicate how [WebView] content should be darkened.
class ForceDarkStrategy {
  final int _value;

  const ForceDarkStrategy._internal(this._value);

  ///Set of all values of [ForceDarkStrategy].
  static final Set<ForceDarkStrategy> values = [
    ForceDarkStrategy.USER_AGENT_DARKENING_ONLY,
    ForceDarkStrategy.WEB_THEME_DARKENING_ONLY,
    ForceDarkStrategy.PREFER_WEB_THEME_OVER_USER_AGENT_DARKENING,
  ].toSet();

  ///Gets a possible [ForceDarkStrategy] instance from an [int] value.
  static ForceDarkStrategy? fromValue(int? value) {
    if (value != null) {
      try {
        return ForceDarkStrategy.values
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
      case 1:
        return "WEB_THEME_DARKENING_ONLY";
      case 2:
        return "PREFER_WEB_THEME_OVER_USER_AGENT_DARKENING";
      case 0:
      default:
        return "USER_AGENT_DARKENING_ONLY";
    }
  }

  ///In this mode [WebView] content will be darkened by a user agent and it will ignore the web page's dark theme if it exists.
  ///To avoid mixing two different darkening strategies, the `prefers-color-scheme` media query will evaluate to light.
  ///
  ///See [specification](https://drafts.csswg.org/css-color-adjust-1/) for more information.
  static const USER_AGENT_DARKENING_ONLY = const ForceDarkStrategy._internal(0);

  ///In this mode [WebView] content will always be darkened using dark theme provided by web page.
  ///If web page does not provide dark theme support [WebView] content will be rendered with a default theme.
  ///
  ///See [specification](https://drafts.csswg.org/css-color-adjust-1/) for more information.
  static const WEB_THEME_DARKENING_ONLY = const ForceDarkStrategy._internal(1);

  ///In this mode [WebView] content will be darkened by a user agent unless web page supports dark theme.
  ///[WebView] determines whether web pages supports dark theme by the presence of `color-scheme` metadata containing `"dark"` value.
  ///For example, `<meta name="color-scheme" content="dark light">`.
  ///If the metadata is not presented [WebView] content will be darkened by a user agent and `prefers-color-scheme` media query will evaluate to light.
  ///
  ///See [specification](https://drafts.csswg.org/css-color-adjust-1/) for more information.
  static const PREFER_WEB_THEME_OVER_USER_AGENT_DARKENING = const ForceDarkStrategy._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}
