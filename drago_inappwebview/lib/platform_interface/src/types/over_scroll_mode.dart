import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

part 'over_scroll_mode.g.dart';

///Class used to configure the `WebView`'s over-scroll mode.
///Setting the over-scroll mode of a WebView will have an effect only if the `WebView` is capable of scrolling.
@ExchangeableEnum()
class OverScrollMode_ {
  // ignore: unused_field
  final int _value;
  const OverScrollMode_._internal(this._value);

  ///Always allow a user to over-scroll this view, provided it is a view that can scroll.
  static const ALWAYS = OverScrollMode_._internal(0);

  ///Allow a user to over-scroll this view only if the content is large enough to meaningfully scroll, provided it is a view that can scroll.
  static const IF_CONTENT_SCROLLS = OverScrollMode_._internal(1);

  ///Never allow a user to over-scroll this view.
  static const NEVER = OverScrollMode_._internal(2);
}

///An Android-specific class used to configure the `WebView`'s over-scroll mode.
///Setting the over-scroll mode of a WebView will have an effect only if the `WebView` is capable of scrolling.
///Use [OverScrollMode] instead.
@Deprecated("Use OverScrollMode instead")
@ExchangeableEnum()
class AndroidOverScrollMode_ {
  // ignore: unused_field
  final int _value;
  const AndroidOverScrollMode_._internal(this._value);

  ///Always allow a user to over-scroll this view, provided it is a view that can scroll.
  static const OVER_SCROLL_ALWAYS = AndroidOverScrollMode_._internal(0);

  ///Allow a user to over-scroll this view only if the content is large enough to meaningfully scroll, provided it is a view that can scroll.
  static const OVER_SCROLL_IF_CONTENT_SCROLLS =
      AndroidOverScrollMode_._internal(1);

  ///Never allow a user to over-scroll this view.
  static const OVER_SCROLL_NEVER = AndroidOverScrollMode_._internal(2);
}
