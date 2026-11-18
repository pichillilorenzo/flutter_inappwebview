import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

part 'underline_style.g.dart';

///Class that represents the constants for the underline style and strikethrough style attribute keys.
@ExchangeableEnum()
class UnderlineStyle_ {
  // ignore: unused_field
  final int _value;
  const UnderlineStyle_._internal(this._value);

  ///Do not draw a line.
  static const STYLE_NONE = UnderlineStyle_._internal(0);

  ///Draw a single line.
  static const SINGLE = UnderlineStyle_._internal(1);

  ///Draw a thick line.
  static const THICK = UnderlineStyle_._internal(2);

  ///Draw a double line.
  static const DOUBLE = UnderlineStyle_._internal(9);

  ///Draw a line of dots.
  static const PATTERN_DOT = UnderlineStyle_._internal(256);

  ///Draw a line of dashes.
  static const PATTERN_DASH = UnderlineStyle_._internal(512);

  ///Draw a line of alternating dashes and dots.
  static const PATTERN_DASH_DOT = UnderlineStyle_._internal(768);

  ///Draw a line of alternating dashes and two dots.
  static const PATTERN_DASH_DOT_DOT = UnderlineStyle_._internal(1024);

  ///Draw the line only beneath or through words, not whitespace.
  static const BY_WORD = UnderlineStyle_._internal(32768);
}

///An iOS-specific Class that represents the constants for the underline style and strikethrough style attribute keys.
///Use [UnderlineStyle] instead.
@Deprecated("Use UnderlineStyle instead")
@ExchangeableEnum()
class IOSNSUnderlineStyle_ {
  // ignore: unused_field
  final int _value;
  const IOSNSUnderlineStyle_._internal(this._value);

  ///Do not draw a line.
  static const STYLE_NONE = IOSNSUnderlineStyle_._internal(0);

  ///Draw a single line.
  static const SINGLE = IOSNSUnderlineStyle_._internal(1);

  ///Draw a thick line.
  static const THICK = IOSNSUnderlineStyle_._internal(2);

  ///Draw a double line.
  static const DOUBLE = IOSNSUnderlineStyle_._internal(9);

  ///Draw a line of dots.
  static const PATTERN_DOT = IOSNSUnderlineStyle_._internal(256);

  ///Draw a line of dashes.
  static const PATTERN_DASH = IOSNSUnderlineStyle_._internal(512);

  ///Draw a line of alternating dashes and dots.
  static const PATTERN_DASH_DOT = IOSNSUnderlineStyle_._internal(768);

  ///Draw a line of alternating dashes and two dots.
  static const PATTERN_DASH_DOT_DOT = IOSNSUnderlineStyle_._internal(
    1024,
  );

  ///Draw the line only beneath or through words, not whitespace.
  static const BY_WORD = IOSNSUnderlineStyle_._internal(32768);
}
