///Class used to disable the action mode menu items.
class ActionModeMenuItem {
  final int _value;

  const ActionModeMenuItem._internal(this._value);

  ///Set of all values of [ActionModeMenuItem].
  static final Set<ActionModeMenuItem> values = [
    ActionModeMenuItem.MENU_ITEM_NONE,
    ActionModeMenuItem.MENU_ITEM_SHARE,
    ActionModeMenuItem.MENU_ITEM_WEB_SEARCH,
    ActionModeMenuItem.MENU_ITEM_PROCESS_TEXT,
  ].toSet();

  ///Gets a possible [ActionModeMenuItem] instance from an [int] value.
  static ActionModeMenuItem? fromValue(int? value) {
    if (value != null) {
      try {
        return ActionModeMenuItem.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        // maybe coming from a Bitwise OR operator
        return ActionModeMenuItem._internal(value);
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
        return "MENU_ITEM_SHARE";
      case 2:
        return "MENU_ITEM_WEB_SEARCH";
      case 4:
        return "MENU_ITEM_PROCESS_TEXT";
      case 0:
        return "MENU_ITEM_NONE";
    }
    return _value.toString();
  }

  ///No menu items should be disabled.
  static const MENU_ITEM_NONE = const ActionModeMenuItem._internal(0);

  ///Disable menu item "Share".
  static const MENU_ITEM_SHARE = const ActionModeMenuItem._internal(1);

  ///Disable menu item "Web Search".
  static const MENU_ITEM_WEB_SEARCH = const ActionModeMenuItem._internal(2);

  ///Disable all the action mode menu items for text processing.
  static const MENU_ITEM_PROCESS_TEXT = const ActionModeMenuItem._internal(4);

  bool operator ==(value) => value == _value;

  ActionModeMenuItem operator |(ActionModeMenuItem value) =>
      ActionModeMenuItem._internal(value.toValue() | _value);

  @override
  int get hashCode => _value.hashCode;
}

///An Android-specific class used to disable the action mode menu items.
///
///**NOTE**: available on Android 24+.
///
///Use [ActionModeMenuItem] instead.
@Deprecated("Use ActionModeMenuItem instead")
class AndroidActionModeMenuItem {
  final int _value;

  const AndroidActionModeMenuItem._internal(this._value);

  ///Set of all values of [AndroidActionModeMenuItem].
  static final Set<AndroidActionModeMenuItem> values = [
    AndroidActionModeMenuItem.MENU_ITEM_NONE,
    AndroidActionModeMenuItem.MENU_ITEM_SHARE,
    AndroidActionModeMenuItem.MENU_ITEM_WEB_SEARCH,
    AndroidActionModeMenuItem.MENU_ITEM_PROCESS_TEXT,
  ].toSet();

  ///Gets a possible [AndroidActionModeMenuItem] instance from an [int] value.
  static AndroidActionModeMenuItem? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidActionModeMenuItem.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        // maybe coming from a Bitwise OR operator
        return AndroidActionModeMenuItem._internal(value);
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
        return "MENU_ITEM_SHARE";
      case 2:
        return "MENU_ITEM_WEB_SEARCH";
      case 4:
        return "MENU_ITEM_PROCESS_TEXT";
      case 0:
        return "MENU_ITEM_NONE";
    }
    return _value.toString();
  }

  ///No menu items should be disabled.
  static const MENU_ITEM_NONE = const AndroidActionModeMenuItem._internal(0);

  ///Disable menu item "Share".
  static const MENU_ITEM_SHARE = const AndroidActionModeMenuItem._internal(1);

  ///Disable menu item "Web Search".
  static const MENU_ITEM_WEB_SEARCH =
  const AndroidActionModeMenuItem._internal(2);

  ///Disable all the action mode menu items for text processing.
  static const MENU_ITEM_PROCESS_TEXT =
  const AndroidActionModeMenuItem._internal(4);

  bool operator ==(value) => value == _value;

  AndroidActionModeMenuItem operator |(AndroidActionModeMenuItem value) =>
      AndroidActionModeMenuItem._internal(value.toValue() | _value);

  @override
  int get hashCode => _value.hashCode;
}