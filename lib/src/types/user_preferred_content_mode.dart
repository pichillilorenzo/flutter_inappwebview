///Class that represents the content mode to prefer when loading and rendering a webpage.
class UserPreferredContentMode {
  final int _value;

  const UserPreferredContentMode._internal(this._value);

  ///Set of all values of [UserPreferredContentMode].
  static final Set<UserPreferredContentMode> values = [
    UserPreferredContentMode.RECOMMENDED,
    UserPreferredContentMode.MOBILE,
    UserPreferredContentMode.DESKTOP,
  ].toSet();

  ///Gets a possible [UserPreferredContentMode] instance from an [int] value.
  static UserPreferredContentMode? fromValue(int? value) {
    if (value != null) {
      try {
        return UserPreferredContentMode.values
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
        return "MOBILE";
      case 2:
        return "DESKTOP";
      case 0:
      default:
        return "RECOMMENDED";
    }
  }

  ///The recommended content mode for the current platform.
  static const RECOMMENDED = const UserPreferredContentMode._internal(0);

  ///Represents content targeting mobile browsers.
  static const MOBILE = const UserPreferredContentMode._internal(1);

  ///Represents content targeting desktop browsers.
  static const DESKTOP = const UserPreferredContentMode._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}