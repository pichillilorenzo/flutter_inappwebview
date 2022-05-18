import '../print_job/main.dart';

///Class representing how the printed content of a [PrintJobController] should be laid out.
class PrintJobColorMode {
  final int _value;

  const PrintJobColorMode._internal(this._value);

  ///Set of all values of [PrintJobColorMode].
  static final Set<PrintJobColorMode> values = [
    PrintJobColorMode.MONOCHROME,
    PrintJobColorMode.COLOR,
  ].toSet();

  ///Gets a possible [PrintJobColorMode] instance from an [int] value.
  static PrintJobColorMode? fromValue(int? value) {
    if (value != null) {
      try {
        return PrintJobColorMode.values
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
        return "MONOCHROME";
      case 2:
      default:
        return "COLOR";
    }
  }

  ///Monochrome color scheme, for example one color is used.
  static const MONOCHROME = const PrintJobColorMode._internal(1);

  ///Color color scheme, for example many colors are used.
  static const COLOR = const PrintJobColorMode._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}
