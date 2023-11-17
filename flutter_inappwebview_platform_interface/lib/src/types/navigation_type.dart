import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';



part 'navigation_type.g.dart';

///Class that represents the type of action triggering a navigation for the [WebView.shouldOverrideUrlLoading] event.
@ExchangeableEnum()
class NavigationType_ {
  // ignore: unused_field
  final int _value;
  const NavigationType_._internal(this._value);

  ///A link with an href attribute was activated by the user.
  static const LINK_ACTIVATED = const NavigationType_._internal(0);

  ///A form was submitted.
  static const FORM_SUBMITTED = const NavigationType_._internal(1);

  ///An item from the back-forward list was requested.
  static const BACK_FORWARD = const NavigationType_._internal(2);

  ///The webpage was reloaded.
  static const RELOAD = const NavigationType_._internal(3);

  ///A form was resubmitted (for example by going back, going forward, or reloading).
  static const FORM_RESUBMITTED = const NavigationType_._internal(4);

  ///Navigation is taking place for some other reason.
  static const OTHER = const NavigationType_._internal(-1);
}

///Class that represents the type of action triggering a navigation on iOS for the [WebView.shouldOverrideUrlLoading] event.
///Use [NavigationType] instead.
@Deprecated("Use NavigationType instead")
@ExchangeableEnum()
class IOSWKNavigationType_ {
  // ignore: unused_field
  final int _value;
  const IOSWKNavigationType_._internal(this._value);

  ///A link with an href attribute was activated by the user.
  static const LINK_ACTIVATED = const IOSWKNavigationType_._internal(0);

  ///A form was submitted.
  static const FORM_SUBMITTED = const IOSWKNavigationType_._internal(1);

  ///An item from the back-forward list was requested.
  static const BACK_FORWARD = const IOSWKNavigationType_._internal(2);

  ///The webpage was reloaded.
  static const RELOAD = const IOSWKNavigationType_._internal(3);

  ///A form was resubmitted (for example by going back, going forward, or reloading).
  static const FORM_RESUBMITTED = const IOSWKNavigationType_._internal(4);

  ///Navigation is taking place for some other reason.
  static const OTHER = const IOSWKNavigationType_._internal(-1);
}
