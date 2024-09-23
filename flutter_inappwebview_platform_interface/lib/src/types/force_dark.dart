import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'force_dark.g.dart';

///Class used to indicate the force dark mode.
@ExchangeableEnum()
class ForceDark_ {
  // ignore: unused_field
  final int _value;
  const ForceDark_._internal(this._value);

  ///Disable force dark, irrespective of the force dark mode of the WebView parent.
  ///In this mode, WebView content will always be rendered as-is, regardless of whether native views are being automatically darkened.
  static const OFF = const ForceDark_._internal(0);

  ///Enable force dark dependent on the state of the WebView parent view.
  static const AUTO = const ForceDark_._internal(1);

  ///Unconditionally enable force dark. In this mode WebView content will always be rendered so as to emulate a dark theme.
  static const ON = const ForceDark_._internal(2);
}

///An Android-specific class used to indicate the force dark mode.
///
///**NOTE**: available on Android 29+.
///
///Use [ForceDark] instead.
@Deprecated("Use ForceDark instead")
@ExchangeableEnum()
class AndroidForceDark_ {
  // ignore: unused_field
  final int _value;
  const AndroidForceDark_._internal(this._value);

  ///Disable force dark, irrespective of the force dark mode of the WebView parent.
  ///In this mode, WebView content will always be rendered as-is, regardless of whether native views are being automatically darkened.
  static const FORCE_DARK_OFF = const AndroidForceDark_._internal(0);

  ///Enable force dark dependent on the state of the WebView parent view.
  static const FORCE_DARK_AUTO = const AndroidForceDark_._internal(1);

  ///Unconditionally enable force dark. In this mode WebView content will always be rendered so as to emulate a dark theme.
  static const FORCE_DARK_ON = const AndroidForceDark_._internal(2);
}
