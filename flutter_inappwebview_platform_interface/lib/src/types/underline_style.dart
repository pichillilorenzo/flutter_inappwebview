import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'underline_style.g.dart';

///Class that represents the constants for the underline style and strikethrough style attribute keys.
@ExchangeableEnum()
class UnderlineStyle_ {
  // ignore: unused_field
  final int _value;
  const UnderlineStyle_._internal(this._value);

  ///Do not draw a line.
  static const STYLE_NONE = const UnderlineStyle_._internal(0);

  ///Draw a single line.
  static const SINGLE = const UnderlineStyle_._internal(1);

  ///Draw a thick line.
  static const THICK = const UnderlineStyle_._internal(2);

  ///Draw a double line.
  static const DOUBLE = const UnderlineStyle_._internal(9);

  ///Draw a line of dots.
  static const PATTERN_DOT = const UnderlineStyle_._internal(256);

  ///Draw a line of dashes.
  static const PATTERN_DASH = const UnderlineStyle_._internal(512);

  ///Draw a line of alternating dashes and dots.
  static const PATTERN_DASH_DOT = const UnderlineStyle_._internal(768);

  ///Draw a line of alternating dashes and two dots.
  static const PATTERN_DASH_DOT_DOT = const UnderlineStyle_._internal(1024);

  ///Draw the line only beneath or through words, not whitespace.
  static const BY_WORD = const UnderlineStyle_._internal(32768);
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
  static const STYLE_NONE = const IOSNSUnderlineStyle_._internal(0);

  ///Draw a single line.
  static const SINGLE = const IOSNSUnderlineStyle_._internal(1);

  ///Draw a thick line.
  static const THICK = const IOSNSUnderlineStyle_._internal(2);

  ///Draw a double line.
  static const DOUBLE = const IOSNSUnderlineStyle_._internal(9);

  ///Draw a line of dots.
  static const PATTERN_DOT = const IOSNSUnderlineStyle_._internal(256);

  ///Draw a line of dashes.
  static const PATTERN_DASH = const IOSNSUnderlineStyle_._internal(512);

  ///Draw a line of alternating dashes and dots.
  static const PATTERN_DASH_DOT = const IOSNSUnderlineStyle_._internal(768);

  ///Draw a line of alternating dashes and two dots.
  static const PATTERN_DASH_DOT_DOT = const IOSNSUnderlineStyle_._internal(
    1024,
  );

  ///Draw the line only beneath or through words, not whitespace.
  static const BY_WORD = const IOSNSUnderlineStyle_._internal(32768);
}
