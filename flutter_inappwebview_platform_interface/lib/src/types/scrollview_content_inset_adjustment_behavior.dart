import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'scrollview_content_inset_adjustment_behavior.g.dart';

///Class used to configure how safe area insets are added to the adjusted content inset.
@ExchangeableEnum()
class ScrollViewContentInsetAdjustmentBehavior_ {
  // ignore: unused_field
  final int _value;
  const ScrollViewContentInsetAdjustmentBehavior_._internal(this._value);

  ///Automatically adjust the scroll view insets.
  static const AUTOMATIC =
      const ScrollViewContentInsetAdjustmentBehavior_._internal(0);

  ///Adjust the insets only in the scrollable directions.
  static const SCROLLABLE_AXES =
      const ScrollViewContentInsetAdjustmentBehavior_._internal(1);

  ///Do not adjust the scroll view insets.
  static const NEVER =
      const ScrollViewContentInsetAdjustmentBehavior_._internal(2);

  ///Always include the safe area insets in the content adjustment.
  static const ALWAYS =
      const ScrollViewContentInsetAdjustmentBehavior_._internal(3);
}

///An iOS-specific class used to configure how safe area insets are added to the adjusted content inset.
///
///**NOTE**: available on iOS 11.0+.
///
///Use [ScrollViewContentInsetAdjustmentBehavior] instead.
@Deprecated("Use ScrollViewContentInsetAdjustmentBehavior instead")
@ExchangeableEnum()
class IOSUIScrollViewContentInsetAdjustmentBehavior_ {
  // ignore: unused_field
  final int _value;
  const IOSUIScrollViewContentInsetAdjustmentBehavior_._internal(this._value);

  ///Automatically adjust the scroll view insets.
  static const AUTOMATIC =
      const IOSUIScrollViewContentInsetAdjustmentBehavior_._internal(0);

  ///Adjust the insets only in the scrollable directions.
  static const SCROLLABLE_AXES =
      const IOSUIScrollViewContentInsetAdjustmentBehavior_._internal(1);

  ///Do not adjust the scroll view insets.
  static const NEVER =
      const IOSUIScrollViewContentInsetAdjustmentBehavior_._internal(2);

  ///Always include the safe area insets in the content adjustment.
  static const ALWAYS =
      const IOSUIScrollViewContentInsetAdjustmentBehavior_._internal(3);
}
