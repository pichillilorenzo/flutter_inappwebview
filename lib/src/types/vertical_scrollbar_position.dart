import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'vertical_scrollbar_position.g.dart';

///Class used to configure the position of the vertical scroll bar.
@ExchangeableEnum()
class VerticalScrollbarPosition_ {
  // ignore: unused_field
  final int _value;
  const VerticalScrollbarPosition_._internal(this._value);

  ///Position the scroll bar at the default position as determined by the system.
  static const SCROLLBAR_POSITION_DEFAULT =
      const VerticalScrollbarPosition_._internal(0);

  ///Position the scroll bar along the left edge.
  static const SCROLLBAR_POSITION_LEFT =
      const VerticalScrollbarPosition_._internal(1);

  ///Position the scroll bar along the right edge.
  static const SCROLLBAR_POSITION_RIGHT =
      const VerticalScrollbarPosition_._internal(2);
}

///An Android-specific class used to configure the position of the vertical scroll bar.
///Use [VerticalScrollbarPosition] instead.
@Deprecated("Use VerticalScrollbarPosition instead")
@ExchangeableEnum()
class AndroidVerticalScrollbarPosition_ {
  // ignore: unused_field
  final int _value;
  const AndroidVerticalScrollbarPosition_._internal(this._value);

  ///Position the scroll bar at the default position as determined by the system.
  static const SCROLLBAR_POSITION_DEFAULT =
      const AndroidVerticalScrollbarPosition_._internal(0);

  ///Position the scroll bar along the left edge.
  static const SCROLLBAR_POSITION_LEFT =
      const AndroidVerticalScrollbarPosition_._internal(1);

  ///Position the scroll bar along the right edge.
  static const SCROLLBAR_POSITION_RIGHT =
      const AndroidVerticalScrollbarPosition_._internal(2);
}
