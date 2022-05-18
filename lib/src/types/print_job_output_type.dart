import '../print_job/main.dart';

///Class representing the kind of printable content of a [PrintJobController].
class PrintJobOutputType {
  final int _value;

  const PrintJobOutputType._internal(this._value);

  ///Set of all values of [PrintJobOutputType].
  static final Set<PrintJobOutputType> values = [
    PrintJobOutputType.GENERAL,
    PrintJobOutputType.PHOTO,
    PrintJobOutputType.GRAYSCALE,
    PrintJobOutputType.PHOTO_GRAYSCALE
  ].toSet();

  ///Gets a possible [PrintJobOutputType] instance from an [int] value.
  static PrintJobOutputType? fromValue(int? value) {
    if (value != null) {
      try {
        return PrintJobOutputType.values
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
        return "PHOTO";
      case 2:
        return "GRAYSCALE";
      case 3:
        return "PHOTO_GRAYSCALE";
      case 0:
      default:
        return "GENERAL";
    }
  }

  ///Specifies that the printed content consists of mixed text, graphics, and images.
  ///The default paper is Letter, A4, or similar locale-specific designation.
  ///Output is normal quality, duplex.
  static const GENERAL = const PrintJobOutputType._internal(0);

  ///Specifies that the printed content consists of black-and-white or color images.
  ///The default paper is 4x6, A6, or similar locale-specific designation.
  ///Output is high quality, simplex.
  static const PHOTO = const PrintJobOutputType._internal(1);

  ///Specifies that the printed content is grayscale.
  ///Set the output type to this value when your printable content contains no color—for example, it’s black text only.
  ///The default paper is Letter/A4. Output is grayscale quality, duplex.
  ///This content type can produce a performance improvement in some cases.
  static const GRAYSCALE = const PrintJobOutputType._internal(2);

  ///Specifies that the printed content is a grayscale image.
  ///Set the output type to this value when your printable content contains no color—for example, it’s black text only.
  ///The default paper is Letter/A4.
  ///Output is high quality grayscale, duplex.
  static const PHOTO_GRAYSCALE = const PrintJobOutputType._internal(3);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}
