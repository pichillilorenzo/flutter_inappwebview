import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'font_hinting_style.g.dart';

///Font hinting style used for text rendering on Linux.
@ExchangeableEnum()
class FontHintingStyle_ {
  // ignore: unused_field
  final int _value;
  const FontHintingStyle_._internal(this._value);

  ///No hinting. Text is rendered without any hinting.
  static const NONE = const FontHintingStyle_._internal(0);

  ///Slight hinting. A minimal amount of hinting is applied.
  static const SLIGHT = const FontHintingStyle_._internal(1);

  ///Medium hinting. A moderate amount of hinting is applied.
  static const MEDIUM = const FontHintingStyle_._internal(2);

  ///Full hinting. Maximum hinting is applied for crispest text.
  static const FULL = const FontHintingStyle_._internal(3);
}
