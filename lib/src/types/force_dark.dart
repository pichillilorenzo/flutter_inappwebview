///Class used to indicate the force dark mode.
class ForceDark {
  final int _value;

  const ForceDark._internal(this._value);

  ///Set of all values of [ForceDark].
  static final Set<ForceDark> values = [
    ForceDark.FORCE_DARK_OFF,
    ForceDark.FORCE_DARK_AUTO,
    ForceDark.FORCE_DARK_ON,
  ].toSet();

  ///Gets a possible [ForceDark] instance from an [int] value.
  static ForceDark? fromValue(int? value) {
    if (value != null) {
      try {
        return ForceDark.values
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
        return "FORCE_DARK_AUTO";
      case 2:
        return "FORCE_DARK_ON";
      case 0:
      default:
        return "FORCE_DARK_OFF";
    }
  }

  ///Disable force dark, irrespective of the force dark mode of the WebView parent.
  ///In this mode, WebView content will always be rendered as-is, regardless of whether native views are being automatically darkened.
  static const FORCE_DARK_OFF = const ForceDark._internal(0);

  ///Enable force dark dependent on the state of the WebView parent view.
  static const FORCE_DARK_AUTO = const ForceDark._internal(1);

  ///Unconditionally enable force dark. In this mode WebView content will always be rendered so as to emulate a dark theme.
  static const FORCE_DARK_ON = const ForceDark._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///An Android-specific class used to indicate the force dark mode.
///
///**NOTE**: available on Android 29+.
///
///Use [ForceDark] instead.
@Deprecated("Use ForceDark instead")
class AndroidForceDark {
  final int _value;

  const AndroidForceDark._internal(this._value);

  ///Set of all values of [AndroidForceDark].
  static final Set<AndroidForceDark> values = [
    AndroidForceDark.FORCE_DARK_OFF,
    AndroidForceDark.FORCE_DARK_AUTO,
    AndroidForceDark.FORCE_DARK_ON,
  ].toSet();

  ///Gets a possible [AndroidForceDark] instance from an [int] value.
  static AndroidForceDark? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidForceDark.values
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
        return "FORCE_DARK_AUTO";
      case 2:
        return "FORCE_DARK_ON";
      case 0:
      default:
        return "FORCE_DARK_OFF";
    }
  }

  ///Disable force dark, irrespective of the force dark mode of the WebView parent.
  ///In this mode, WebView content will always be rendered as-is, regardless of whether native views are being automatically darkened.
  static const FORCE_DARK_OFF = const AndroidForceDark._internal(0);

  ///Enable force dark dependent on the state of the WebView parent view.
  static const FORCE_DARK_AUTO = const AndroidForceDark._internal(1);

  ///Unconditionally enable force dark. In this mode WebView content will always be rendered so as to emulate a dark theme.
  static const FORCE_DARK_ON = const AndroidForceDark._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}