///Class representing the level of a console message.
class ConsoleMessageLevel {
  final int _value;

  const ConsoleMessageLevel._internal(this._value);

  ///Set of all values of [ConsoleMessageLevel].
  static final Set<ConsoleMessageLevel> values = [
    ConsoleMessageLevel.TIP,
    ConsoleMessageLevel.LOG,
    ConsoleMessageLevel.WARNING,
    ConsoleMessageLevel.ERROR,
    ConsoleMessageLevel.DEBUG,
  ].toSet();

  ///Gets a possible [ConsoleMessageLevel] instance from an [int] value.
  static ConsoleMessageLevel? fromValue(int? value) {
    if (value != null) {
      try {
        return ConsoleMessageLevel.values
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
      case 0:
        return "TIP";
      case 2:
        return "WARNING";
      case 3:
        return "ERROR";
      case 4:
        return "DEBUG";
      case 1:
      default:
        return "LOG";
    }
  }

  ///Console TIP level
  static const TIP = const ConsoleMessageLevel._internal(0);

  ///Console LOG level
  static const LOG = const ConsoleMessageLevel._internal(1);

  ///Console WARNING level
  static const WARNING = const ConsoleMessageLevel._internal(2);

  ///Console ERROR level
  static const ERROR = const ConsoleMessageLevel._internal(3);

  ///Console DEBUG level
  static const DEBUG = const ConsoleMessageLevel._internal(4);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}