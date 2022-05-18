///Class used to set the custom style for the dismiss button.
class DismissButtonStyle {
  final int _value;

  const DismissButtonStyle._internal(this._value);

  ///Set of all values of [DismissButtonStyle].
  static final Set<DismissButtonStyle> values = [
    DismissButtonStyle.DONE,
    DismissButtonStyle.CLOSE,
    DismissButtonStyle.CANCEL,
  ].toSet();

  ///Gets a possible [DismissButtonStyle] instance from an [int] value.
  static DismissButtonStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return DismissButtonStyle.values
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
        return "CLOSE";
      case 2:
        return "CANCEL";
      case 0:
      default:
        return "DONE";
    }
  }

  ///Makes the button title the localized string "Done".
  static const DONE = const DismissButtonStyle._internal(0);

  ///Makes the button title the localized string "Close".
  static const CLOSE = const DismissButtonStyle._internal(1);

  ///Makes the button title the localized string "Cancel".
  static const CANCEL = const DismissButtonStyle._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///An iOS-specific class used to set the custom style for the dismiss button.
///
///**NOTE**: available on iOS 11.0+.
///
///Use [DismissButtonStyle] instead.
@Deprecated("Use DismissButtonStyle instead")
class IOSSafariDismissButtonStyle {
  final int _value;

  const IOSSafariDismissButtonStyle._internal(this._value);

  ///Set of all values of [IOSSafariDismissButtonStyle].
  static final Set<IOSSafariDismissButtonStyle> values = [
    IOSSafariDismissButtonStyle.DONE,
    IOSSafariDismissButtonStyle.CLOSE,
    IOSSafariDismissButtonStyle.CANCEL,
  ].toSet();

  ///Gets a possible [IOSSafariDismissButtonStyle] instance from an [int] value.
  static IOSSafariDismissButtonStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSSafariDismissButtonStyle.values
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
        return "CLOSE";
      case 2:
        return "CANCEL";
      case 0:
      default:
        return "DONE";
    }
  }

  ///Makes the button title the localized string "Done".
  static const DONE = const IOSSafariDismissButtonStyle._internal(0);

  ///Makes the button title the localized string "Close".
  static const CLOSE = const IOSSafariDismissButtonStyle._internal(1);

  ///Makes the button title the localized string "Cancel".
  static const CANCEL = const IOSSafariDismissButtonStyle._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}