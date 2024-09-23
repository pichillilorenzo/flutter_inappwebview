import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'dismiss_button_style.g.dart';

///Class used to set the custom style for the dismiss button.
@ExchangeableEnum()
class DismissButtonStyle_ {
  // ignore: unused_field
  final int _value;
  const DismissButtonStyle_._internal(this._value);

  ///Makes the button title the localized string "Done".
  static const DONE = const DismissButtonStyle_._internal(0);

  ///Makes the button title the localized string "Close".
  static const CLOSE = const DismissButtonStyle_._internal(1);

  ///Makes the button title the localized string "Cancel".
  static const CANCEL = const DismissButtonStyle_._internal(2);
}

///An iOS-specific class used to set the custom style for the dismiss button.
///
///**NOTE**: available on iOS 11.0+.
///
///Use [DismissButtonStyle] instead.
@Deprecated("Use DismissButtonStyle instead")
@ExchangeableEnum()
class IOSSafariDismissButtonStyle_ {
  // ignore: unused_field
  final int _value;
  const IOSSafariDismissButtonStyle_._internal(this._value);

  ///Makes the button title the localized string "Done".
  static const DONE = const IOSSafariDismissButtonStyle_._internal(0);

  ///Makes the button title the localized string "Close".
  static const CLOSE = const IOSSafariDismissButtonStyle_._internal(1);

  ///Makes the button title the localized string "Cancel".
  static const CANCEL = const IOSSafariDismissButtonStyle_._internal(2);
}
