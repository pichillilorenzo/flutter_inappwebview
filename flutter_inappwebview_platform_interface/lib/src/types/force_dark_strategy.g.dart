// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'force_dark_strategy.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to indicate how `WebView` content should be darkened.
class ForceDarkStrategy {
  final int _value;
  final int _nativeValue;
  const ForceDarkStrategy._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory ForceDarkStrategy._internalMultiPlatform(
          int value, Function nativeValue) =>
      ForceDarkStrategy._internal(value, nativeValue());

  ///In this mode `WebView` content will be darkened by a user agent unless web page supports dark theme.
  ///`WebView` determines whether web pages supports dark theme by the presence of `color-scheme` metadata containing `"dark"` value.
  ///For example, `<meta name="color-scheme" content="dark light">`.
  ///If the metadata is not presented `WebView` content will be darkened by a user agent and `prefers-color-scheme` media query will evaluate to light.
  ///
  ///See [specification](https://drafts.csswg.org/css-color-adjust-1/) for more information.
  static const PREFER_WEB_THEME_OVER_USER_AGENT_DARKENING =
      ForceDarkStrategy._internal(2, 2);

  ///In this mode `WebView` content will be darkened by a user agent and it will ignore the web page's dark theme if it exists.
  ///To avoid mixing two different darkening strategies, the `prefers-color-scheme` media query will evaluate to light.
  ///
  ///See [specification](https://drafts.csswg.org/css-color-adjust-1/) for more information.
  static const USER_AGENT_DARKENING_ONLY = ForceDarkStrategy._internal(0, 0);

  ///In this mode `WebView` content will always be darkened using dark theme provided by web page.
  ///If web page does not provide dark theme support `WebView` content will be rendered with a default theme.
  ///
  ///See [specification](https://drafts.csswg.org/css-color-adjust-1/) for more information.
  static const WEB_THEME_DARKENING_ONLY = ForceDarkStrategy._internal(1, 1);

  ///Set of all values of [ForceDarkStrategy].
  static final Set<ForceDarkStrategy> values = [
    ForceDarkStrategy.PREFER_WEB_THEME_OVER_USER_AGENT_DARKENING,
    ForceDarkStrategy.USER_AGENT_DARKENING_ONLY,
    ForceDarkStrategy.WEB_THEME_DARKENING_ONLY,
  ].toSet();

  ///Gets a possible [ForceDarkStrategy] instance from [int] value.
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

  ///Gets a possible [ForceDarkStrategy] instance from a native value.
  static ForceDarkStrategy? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return ForceDarkStrategy.values
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
      case 2:
        return 'PREFER_WEB_THEME_OVER_USER_AGENT_DARKENING';
      case 0:
        return 'USER_AGENT_DARKENING_ONLY';
      case 1:
        return 'WEB_THEME_DARKENING_ONLY';
    }
    return _value.toString();
  }
}
