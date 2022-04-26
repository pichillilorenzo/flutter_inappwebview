///Class that represents the constants for the underline style and strikethrough style attribute keys.
class UnderlineStyle {
  final int _value;

  const UnderlineStyle._internal(this._value);

  ///Set of all values of [UnderlineStyle].
  static final Set<UnderlineStyle> values = [
    UnderlineStyle.STYLE_NONE,
    UnderlineStyle.SINGLE,
    UnderlineStyle.THICK,
    UnderlineStyle.DOUBLE,
    UnderlineStyle.PATTERN_DOT,
    UnderlineStyle.PATTERN_DASH,
    UnderlineStyle.PATTERN_DASH_DOT,
    UnderlineStyle.PATTERN_DASH_DOT_DOT,
    UnderlineStyle.BY_WORD,
  ].toSet();

  ///Gets a possible [UnderlineStyle] instance from an [int] value.
  static UnderlineStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return UnderlineStyle.values
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
        return "SINGLE";
      case 2:
        return "THICK";
      case 9:
        return "DOUBLE";
      case 256:
        return "PATTERN_DOT";
      case 512:
        return "PATTERN_DASH";
      case 768:
        return "PATTERN_DASH_DOT";
      case 1024:
        return "PATTERN_DASH_DOT_DOT";
      case 32768:
        return "BY_WORD";
      case 0:
      default:
        return "STYLE_NONE";
    }
  }

  ///Do not draw a line.
  static const STYLE_NONE = const UnderlineStyle._internal(0);

  ///Draw a single line.
  static const SINGLE = const UnderlineStyle._internal(1);

  ///Draw a thick line.
  static const THICK = const UnderlineStyle._internal(2);

  ///Draw a double line.
  static const DOUBLE = const UnderlineStyle._internal(9);

  ///Draw a line of dots.
  static const PATTERN_DOT = const UnderlineStyle._internal(256);

  ///Draw a line of dashes.
  static const PATTERN_DASH = const UnderlineStyle._internal(512);

  ///Draw a line of alternating dashes and dots.
  static const PATTERN_DASH_DOT = const UnderlineStyle._internal(768);

  ///Draw a line of alternating dashes and two dots.
  static const PATTERN_DASH_DOT_DOT = const UnderlineStyle._internal(1024);

  ///Draw the line only beneath or through words, not whitespace.
  static const BY_WORD = const UnderlineStyle._internal(32768);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///An iOS-specific Class that represents the constants for the underline style and strikethrough style attribute keys.
///Use [UnderlineStyle] instead.
@Deprecated("Use UnderlineStyle instead")
class IOSNSUnderlineStyle {
  final int _value;

  const IOSNSUnderlineStyle._internal(this._value);

  ///Set of all values of [IOSNSUnderlineStyle].
  static final Set<IOSNSUnderlineStyle> values = [
    IOSNSUnderlineStyle.STYLE_NONE,
    IOSNSUnderlineStyle.SINGLE,
    IOSNSUnderlineStyle.THICK,
    IOSNSUnderlineStyle.DOUBLE,
    IOSNSUnderlineStyle.PATTERN_DOT,
    IOSNSUnderlineStyle.PATTERN_DASH,
    IOSNSUnderlineStyle.PATTERN_DASH_DOT,
    IOSNSUnderlineStyle.PATTERN_DASH_DOT_DOT,
    IOSNSUnderlineStyle.BY_WORD,
  ].toSet();

  ///Gets a possible [IOSNSUnderlineStyle] instance from an [int] value.
  static IOSNSUnderlineStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSNSUnderlineStyle.values
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
        return "SINGLE";
      case 2:
        return "THICK";
      case 9:
        return "DOUBLE";
      case 256:
        return "PATTERN_DOT";
      case 512:
        return "PATTERN_DASH";
      case 768:
        return "PATTERN_DASH_DOT";
      case 1024:
        return "PATTERN_DASH_DOT_DOT";
      case 32768:
        return "BY_WORD";
      case 0:
      default:
        return "STYLE_NONE";
    }
  }

  ///Do not draw a line.
  static const STYLE_NONE = const IOSNSUnderlineStyle._internal(0);

  ///Draw a single line.
  static const SINGLE = const IOSNSUnderlineStyle._internal(1);

  ///Draw a thick line.
  static const THICK = const IOSNSUnderlineStyle._internal(2);

  ///Draw a double line.
  static const DOUBLE = const IOSNSUnderlineStyle._internal(9);

  ///Draw a line of dots.
  static const PATTERN_DOT = const IOSNSUnderlineStyle._internal(256);

  ///Draw a line of dashes.
  static const PATTERN_DASH = const IOSNSUnderlineStyle._internal(512);

  ///Draw a line of alternating dashes and dots.
  static const PATTERN_DASH_DOT = const IOSNSUnderlineStyle._internal(768);

  ///Draw a line of alternating dashes and two dots.
  static const PATTERN_DASH_DOT_DOT = const IOSNSUnderlineStyle._internal(1024);

  ///Draw the line only beneath or through words, not whitespace.
  static const BY_WORD = const IOSNSUnderlineStyle._internal(32768);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}