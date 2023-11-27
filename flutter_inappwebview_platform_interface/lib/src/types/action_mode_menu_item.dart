import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'action_mode_menu_item.g.dart';

///Class used to disable the action mode menu items.
@ExchangeableEnum(bitwiseOrOperator: true)
class ActionModeMenuItem_ {
  // ignore: unused_field
  final int _value;
  const ActionModeMenuItem_._internal(this._value);

  ///No menu items should be disabled.
  static const MENU_ITEM_NONE = ActionModeMenuItem_._internal(0);

  ///Disable menu item "Share".
  static const MENU_ITEM_SHARE = ActionModeMenuItem_._internal(1);

  ///Disable menu item "Web Search".
  static const MENU_ITEM_WEB_SEARCH = ActionModeMenuItem_._internal(2);

  ///Disable all the action mode menu items for text processing.
  static const MENU_ITEM_PROCESS_TEXT = ActionModeMenuItem_._internal(4);
}

///An Android-specific class used to disable the action mode menu items.
///
///**NOTE**: available on Android 24+.
///
///Use [ActionModeMenuItem] instead.
@Deprecated("Use ActionModeMenuItem instead")
@ExchangeableEnum(bitwiseOrOperator: true)
class AndroidActionModeMenuItem_ {
  // ignore: unused_field
  final int _value;
  const AndroidActionModeMenuItem_._internal(this._value);

  ///No menu items should be disabled.
  static const MENU_ITEM_NONE = const AndroidActionModeMenuItem_._internal(0);

  ///Disable menu item "Share".
  static const MENU_ITEM_SHARE = const AndroidActionModeMenuItem_._internal(1);

  ///Disable menu item "Web Search".
  static const MENU_ITEM_WEB_SEARCH =
      const AndroidActionModeMenuItem_._internal(2);

  ///Disable all the action mode menu items for text processing.
  static const MENU_ITEM_PROCESS_TEXT =
      const AndroidActionModeMenuItem_._internal(4);
}
