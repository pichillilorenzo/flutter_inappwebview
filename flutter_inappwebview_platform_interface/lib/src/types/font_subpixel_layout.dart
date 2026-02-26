import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'font_subpixel_layout.g.dart';

///Font subpixel layout order used for text rendering on Linux.
///This setting determines how subpixel rendering is performed based on
///the physical arrangement of the display's RGB subpixels.
@ExchangeableEnum()
class FontSubpixelLayout_ {
  // ignore: unused_field
  final int _value;
  const FontSubpixelLayout_._internal(this._value);

  ///RGB subpixel layout (horizontal RGB order).
  ///Used for most LCD displays with horizontal RGB subpixel arrangement.
  static const RGB = const FontSubpixelLayout_._internal(0);

  ///BGR subpixel layout (horizontal BGR order).
  ///Used for LCD displays with horizontal BGR subpixel arrangement.
  static const BGR = const FontSubpixelLayout_._internal(1);

  ///Vertical RGB subpixel layout.
  ///Used for displays with vertical RGB subpixel arrangement.
  static const VRGB = const FontSubpixelLayout_._internal(2);

  ///Vertical BGR subpixel layout.
  ///Used for displays with vertical BGR subpixel arrangement.
  static const VBGR = const FontSubpixelLayout_._internal(3);
}
