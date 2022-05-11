import '../print_job/main.dart';

///Class representing the orientation of a [PrintJobController].
class PrintJobOrientation {
  final int _value;

  const PrintJobOrientation._internal(this._value);

  ///Set of all values of [PrintJobOrientation].
  static final Set<PrintJobOrientation> values = [
    PrintJobOrientation.PORTRAIT,
    PrintJobOrientation.LANDSCAPE,
  ].toSet();

  ///Gets a possible [PrintJobOrientation] instance from an [int] value.
  static PrintJobOrientation? fromValue(int? value) {
    if (value != null) {
      try {
        return PrintJobOrientation.values
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
        return "LANDSCAPE";
      case 0:
      default:
        return "PORTRAIT";
    }
  }

  ///Pages are printed in portrait orientation.
  static const PORTRAIT = const PrintJobOrientation._internal(0);

  ///Pages are printed in landscape orientation.
  static const LANDSCAPE = const PrintJobOrientation._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}
