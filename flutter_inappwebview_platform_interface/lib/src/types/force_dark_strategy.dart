import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'force_dark_strategy.g.dart';

///Class used to indicate how `WebView` content should be darkened.
@ExchangeableEnum()
class ForceDarkStrategy_ {
  // ignore: unused_field
  final int _value;
  const ForceDarkStrategy_._internal(this._value);

  ///In this mode `WebView` content will be darkened by a user agent and it will ignore the web page's dark theme if it exists.
  ///To avoid mixing two different darkening strategies, the `prefers-color-scheme` media query will evaluate to light.
  ///
  ///See [specification](https://drafts.csswg.org/css-color-adjust-1/) for more information.
  static const USER_AGENT_DARKENING_ONLY = const ForceDarkStrategy_._internal(
    0,
  );

  ///In this mode `WebView` content will always be darkened using dark theme provided by web page.
  ///If web page does not provide dark theme support `WebView` content will be rendered with a default theme.
  ///
  ///See [specification](https://drafts.csswg.org/css-color-adjust-1/) for more information.
  static const WEB_THEME_DARKENING_ONLY = const ForceDarkStrategy_._internal(1);

  ///In this mode `WebView` content will be darkened by a user agent unless web page supports dark theme.
  ///`WebView` determines whether web pages supports dark theme by the presence of `color-scheme` metadata containing `"dark"` value.
  ///For example, `<meta name="color-scheme" content="dark light">`.
  ///If the metadata is not presented `WebView` content will be darkened by a user agent and `prefers-color-scheme` media query will evaluate to light.
  ///
  ///See [specification](https://drafts.csswg.org/css-color-adjust-1/) for more information.
  static const PREFER_WEB_THEME_OVER_USER_AGENT_DARKENING =
      const ForceDarkStrategy_._internal(2);
}
