///Class used to configure the style of the scrollbars.
///The scrollbars can be overlaid or inset.
///When inset, they add to the padding of the view. And the scrollbars can be drawn inside the padding area or on the edge of the view.
///For example, if a view has a background drawable and you want to draw the scrollbars inside the padding specified by the drawable,
///you can use [ScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY] or [ScrollBarStyle.SCROLLBARS_INSIDE_INSET].
///If you want them to appear at the edge of the view, ignoring the padding,
///then you can use [ScrollBarStyle.SCROLLBARS_OUTSIDE_OVERLAY] or [ScrollBarStyle.SCROLLBARS_OUTSIDE_INSET].
class ScrollBarStyle {
  final int _value;

  const ScrollBarStyle._internal(this._value);

  ///Set of all values of [ScrollBarStyle].
  static final Set<ScrollBarStyle> values = [
    ScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY,
    ScrollBarStyle.SCROLLBARS_INSIDE_INSET,
    ScrollBarStyle.SCROLLBARS_OUTSIDE_OVERLAY,
    ScrollBarStyle.SCROLLBARS_OUTSIDE_INSET,
  ].toSet();

  ///Gets a possible [ScrollBarStyle] instance from an [int] value.
  static ScrollBarStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return ScrollBarStyle.values
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
      case 16777216:
        return "SCROLLBARS_INSIDE_INSET";
      case 33554432:
        return "SCROLLBARS_OUTSIDE_OVERLAY";
      case 50331648:
        return "SCROLLBARS_OUTSIDE_INSET";
      case 0:
      default:
        return "SCROLLBARS_INSIDE_OVERLAY";
    }
  }

  ///The scrollbar style to display the scrollbars inside the content area, without increasing the padding.
  ///The scrollbars will be overlaid with translucency on the view's content.
  static const SCROLLBARS_INSIDE_OVERLAY = const ScrollBarStyle._internal(0);

  ///The scrollbar style to display the scrollbars inside the padded area, increasing the padding of the view.
  ///The scrollbars will not overlap the content area of the view.
  static const SCROLLBARS_INSIDE_INSET =
  const ScrollBarStyle._internal(16777216);

  ///The scrollbar style to display the scrollbars at the edge of the view, without increasing the padding.
  ///The scrollbars will be overlaid with translucency.
  static const SCROLLBARS_OUTSIDE_OVERLAY =
  const ScrollBarStyle._internal(33554432);

  ///The scrollbar style to display the scrollbars at the edge of the view, increasing the padding of the view.
  ///The scrollbars will only overlap the background, if any.
  static const SCROLLBARS_OUTSIDE_INSET =
  const ScrollBarStyle._internal(50331648);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///An Android-specific class used to configure the style of the scrollbars.
///The scrollbars can be overlaid or inset.
///When inset, they add to the padding of the view. And the scrollbars can be drawn inside the padding area or on the edge of the view.
///For example, if a view has a background drawable and you want to draw the scrollbars inside the padding specified by the drawable,
///you can use [AndroidScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY] or [AndroidScrollBarStyle.SCROLLBARS_INSIDE_INSET].
///If you want them to appear at the edge of the view, ignoring the padding,
///then you can use [AndroidScrollBarStyle.SCROLLBARS_OUTSIDE_OVERLAY] or [AndroidScrollBarStyle.SCROLLBARS_OUTSIDE_INSET].
///
///Use [ScrollBarStyle] instead.
@Deprecated("Use ScrollBarStyle instead")
class AndroidScrollBarStyle {
  final int _value;

  const AndroidScrollBarStyle._internal(this._value);

  ///Set of all values of [AndroidScrollBarStyle].
  static final Set<AndroidScrollBarStyle> values = [
    AndroidScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY,
    AndroidScrollBarStyle.SCROLLBARS_INSIDE_INSET,
    AndroidScrollBarStyle.SCROLLBARS_OUTSIDE_OVERLAY,
    AndroidScrollBarStyle.SCROLLBARS_OUTSIDE_INSET,
  ].toSet();

  ///Gets a possible [AndroidScrollBarStyle] instance from an [int] value.
  static AndroidScrollBarStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidScrollBarStyle.values
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
      case 16777216:
        return "SCROLLBARS_INSIDE_INSET";
      case 33554432:
        return "SCROLLBARS_OUTSIDE_OVERLAY";
      case 50331648:
        return "SCROLLBARS_OUTSIDE_INSET";
      case 0:
      default:
        return "SCROLLBARS_INSIDE_OVERLAY";
    }
  }

  ///The scrollbar style to display the scrollbars inside the content area, without increasing the padding.
  ///The scrollbars will be overlaid with translucency on the view's content.
  static const SCROLLBARS_INSIDE_OVERLAY =
  const AndroidScrollBarStyle._internal(0);

  ///The scrollbar style to display the scrollbars inside the padded area, increasing the padding of the view.
  ///The scrollbars will not overlap the content area of the view.
  static const SCROLLBARS_INSIDE_INSET =
  const AndroidScrollBarStyle._internal(16777216);

  ///The scrollbar style to display the scrollbars at the edge of the view, without increasing the padding.
  ///The scrollbars will be overlaid with translucency.
  static const SCROLLBARS_OUTSIDE_OVERLAY =
  const AndroidScrollBarStyle._internal(33554432);

  ///The scrollbar style to display the scrollbars at the edge of the view, increasing the padding of the view.
  ///The scrollbars will only overlap the background, if any.
  static const SCROLLBARS_OUTSIDE_INSET =
  const AndroidScrollBarStyle._internal(50331648);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}