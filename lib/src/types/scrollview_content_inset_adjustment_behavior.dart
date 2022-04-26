///Class used to configure how safe area insets are added to the adjusted content inset.
class ScrollViewContentInsetAdjustmentBehavior {
  final int _value;

  const ScrollViewContentInsetAdjustmentBehavior._internal(this._value);

  ///Set of all values of [ScrollViewContentInsetAdjustmentBehavior].
  static final Set<ScrollViewContentInsetAdjustmentBehavior> values = [
    ScrollViewContentInsetAdjustmentBehavior.AUTOMATIC,
    ScrollViewContentInsetAdjustmentBehavior.SCROLLABLE_AXES,
    ScrollViewContentInsetAdjustmentBehavior.NEVER,
    ScrollViewContentInsetAdjustmentBehavior.ALWAYS,
  ].toSet();

  ///Gets a possible [ScrollViewContentInsetAdjustmentBehavior] instance from an [int] value.
  static ScrollViewContentInsetAdjustmentBehavior? fromValue(int? value) {
    if (value != null) {
      try {
        return ScrollViewContentInsetAdjustmentBehavior.values
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
        return "SCROLLABLE_AXES";
      case 2:
        return "NEVER";
      case 3:
        return "ALWAYS";
      case 0:
      default:
        return "AUTOMATIC";
    }
  }

  ///Automatically adjust the scroll view insets.
  static const AUTOMATIC =
  const ScrollViewContentInsetAdjustmentBehavior._internal(0);

  ///Adjust the insets only in the scrollable directions.
  static const SCROLLABLE_AXES =
  const ScrollViewContentInsetAdjustmentBehavior._internal(1);

  ///Do not adjust the scroll view insets.
  static const NEVER =
  const ScrollViewContentInsetAdjustmentBehavior._internal(2);

  ///Always include the safe area insets in the content adjustment.
  static const ALWAYS =
  const ScrollViewContentInsetAdjustmentBehavior._internal(3);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///An iOS-specific class used to configure how safe area insets are added to the adjusted content inset.
///
///**NOTE**: available on iOS 11.0+.
///
///Use [ScrollViewContentInsetAdjustmentBehavior] instead.
@Deprecated("Use ScrollViewContentInsetAdjustmentBehavior instead")
class IOSUIScrollViewContentInsetAdjustmentBehavior {
  final int _value;

  const IOSUIScrollViewContentInsetAdjustmentBehavior._internal(this._value);

  ///Set of all values of [IOSUIScrollViewContentInsetAdjustmentBehavior].
  static final Set<IOSUIScrollViewContentInsetAdjustmentBehavior> values = [
    IOSUIScrollViewContentInsetAdjustmentBehavior.AUTOMATIC,
    IOSUIScrollViewContentInsetAdjustmentBehavior.SCROLLABLE_AXES,
    IOSUIScrollViewContentInsetAdjustmentBehavior.NEVER,
    IOSUIScrollViewContentInsetAdjustmentBehavior.ALWAYS,
  ].toSet();

  ///Gets a possible [IOSUIScrollViewContentInsetAdjustmentBehavior] instance from an [int] value.
  static IOSUIScrollViewContentInsetAdjustmentBehavior? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSUIScrollViewContentInsetAdjustmentBehavior.values
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
        return "SCROLLABLE_AXES";
      case 2:
        return "NEVER";
      case 3:
        return "ALWAYS";
      case 0:
      default:
        return "AUTOMATIC";
    }
  }

  ///Automatically adjust the scroll view insets.
  static const AUTOMATIC =
  const IOSUIScrollViewContentInsetAdjustmentBehavior._internal(0);

  ///Adjust the insets only in the scrollable directions.
  static const SCROLLABLE_AXES =
  const IOSUIScrollViewContentInsetAdjustmentBehavior._internal(1);

  ///Do not adjust the scroll view insets.
  static const NEVER =
  const IOSUIScrollViewContentInsetAdjustmentBehavior._internal(2);

  ///Always include the safe area insets in the content adjustment.
  static const ALWAYS =
  const IOSUIScrollViewContentInsetAdjustmentBehavior._internal(3);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}