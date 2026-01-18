import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'preferred_color_scheme.g.dart';

///Class used to indicate the preferred color scheme for the WebView.
@ExchangeableEnum()
class PreferredColorScheme_ {
  // ignore: unused_field
  final int _value;
  const PreferredColorScheme_._internal(this._value);

  ///Light color scheme.
  static const LIGHT = const PreferredColorScheme_._internal(1);

  ///Dark color scheme.
  static const DARK = const PreferredColorScheme_._internal(2);

  ///Automatically match the system color scheme.
  static const AUTO = const PreferredColorScheme_._internal(0);
}
