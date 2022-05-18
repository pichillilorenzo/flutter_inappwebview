import '../print_job/main.dart';

///Class representing the rendering quality of a [PrintJobController].
class PrintJobRenderingQuality {
  final int _value;

  const PrintJobRenderingQuality._internal(this._value);

  ///Set of all values of [PrintJobRenderingQuality].
  static final Set<PrintJobRenderingQuality> values = [
    PrintJobRenderingQuality.BEST,
    PrintJobRenderingQuality.RESPONSIVE,
  ].toSet();

  ///Gets a possible [PrintJobRenderingQuality] instance from an [int] value.
  static PrintJobRenderingQuality? fromValue(int? value) {
    if (value != null) {
      try {
        return PrintJobRenderingQuality.values
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
        return "RESPONSIVE";
      case 0:
      default:
        return "BEST";
    }
  }

  ///Renders the printing at the best possible quality, regardless of speed.
  static const BEST = const PrintJobRenderingQuality._internal(0);

  ///Sacrifices the least possible amount of rendering quality for speed to maintain a responsive user interface.
  ///This option should be used only after establishing that best quality rendering does indeed make the user interface unresponsive.
  static const RESPONSIVE = const PrintJobRenderingQuality._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}
