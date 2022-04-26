///Class representing the share state that should be applied to the custom tab.
class CustomTabsShareState {
  final int _value;

  const CustomTabsShareState._internal(this._value);

  ///Set of all values of [CustomTabsShareState].
  static final Set<CustomTabsShareState> values = [
    CustomTabsShareState.SHARE_STATE_DEFAULT,
    CustomTabsShareState.SHARE_STATE_ON,
    CustomTabsShareState.SHARE_STATE_OFF,
  ].toSet();

  ///Gets a possible [CustomTabsShareState] instance from an [int] value.
  static CustomTabsShareState? fromValue(int? value) {
    if (value != null) {
      try {
        return CustomTabsShareState.values
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
        return "SHARE_STATE_ON";
      case 2:
        return "SHARE_STATE_OFF";
      case 0:
      default:
        return "SHARE_STATE_DEFAULT";
    }
  }

  ///Applies the default share settings depending on the browser.
  static const SHARE_STATE_DEFAULT = const CustomTabsShareState._internal(0);

  ///Shows a share option in the tab.
  static const SHARE_STATE_ON = const CustomTabsShareState._internal(1);

  ///Explicitly does not show a share option in the tab.
  static const SHARE_STATE_OFF = const CustomTabsShareState._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}