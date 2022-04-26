import 'dart:ui';

import '../pull_to_refresh/main.dart';
import 'underline_style.dart';
import 'attributed_string_text_effect_style.dart';
import '../util.dart';

///Class that represents a string with associated attributes
///used by the [PullToRefreshController] and [PullToRefreshSettings] classes.
class AttributedString {
  ///The characters for the new object.
  String string;

  ///The color of the background behind the text.
  ///
  ///The value of this attribute is a [Color] object.
  ///Use this attribute to specify the color of the background area behind the text.
  ///If you do not specify this attribute, no background color is drawn.
  Color? backgroundColor;

  ///The vertical offset for the position of the text.
  ///
  ///The value of this attribute is a number containing a floating point value indicating the character’s offset from the baseline, in points.
  ///The default value is `0`.
  double? baselineOffset;

  ///The expansion factor of the text.
  ///
  ///The value of this attribute is a number containing a floating point value indicating the log of the expansion factor to be applied to glyphs.
  ///The default value is `0`, indicating no expansion.
  double? expansion;

  ///The color of the text.
  ///
  ///The value of this attribute is a [Color] object.
  ///Use this attribute to specify the color of the text during rendering.
  ///If you do not specify this attribute, the text is rendered in black.
  Color? foregroundColor;

  ///The kerning of the text.
  ///
  ///The value of this attribute is a number containing a floating-point value.
  ///This value specifies the number of points by which to adjust kern-pair characters.
  ///Kerning prevents unwanted space from occurring between specific characters and depends on the font.
  ///The value `0` means kerning is disabled. The default value for this attribute is `0`.
  double? kern;

  ///The ligature of the text.
  ///
  ///The value of this attribute is a number containing an integer.
  ///Ligatures cause specific character combinations to be rendered using a single custom glyph that corresponds to those characters.
  ///The value `0` indicates no ligatures. The value `1` indicates the use of the default ligatures.
  ///The value `2` indicates the use of all ligatures.
  ///The default value for this attribute is `1`. (Value `2` is unsupported on iOS.)
  int? ligature;

  ///The obliqueness of the text.
  ///
  ///The value of this attribute is a number containing a floating point value indicating skew to be applied to glyphs.
  ///The default value is `0`, indicating no skew.
  double? obliqueness;

  ///The color of the strikethrough.
  ///
  ///The value of this attribute is a [Color] object. The default value is `null`, indicating same as foreground color.
  Color? strikethroughColor;

  ///The strikethrough style of the text.
  ///
  ///This value indicates whether the text has a line through it and corresponds to one of the constants described in [UnderlineStyle].
  ///The default value for this attribute is [UnderlineStyle.STYLE_NONE].
  UnderlineStyle? strikethroughStyle;

  ///The color of the stroke.
  ///
  ///The value of this parameter is a [Color] object.
  ///If it is not defined (which is the case by default), it is assumed to be the same as the value of foregroundColor;
  ///otherwise, it describes the outline color.
  Color? strokeColor;

  ///The width of the stroke.
  ///
  ///The value of this attribute is a number containing a floating-point value.
  ///This value represents the amount to change the stroke width and is specified as a percentage of the font point size.
  ///Specify `0` (the default) for no additional changes.
  ///Specify positive values to change the stroke width alone.
  ///Specify negative values to stroke and fill the text.
  ///For example, a typical value for outlined text would be `3.0`.
  double? strokeWidth;

  ///The text effect.
  ///
  ///The value of this attribute is a [AttributedStringTextEffectStyle] object.
  ///The default value of this property is `null`, indicating no text effect.
  AttributedStringTextEffectStyle? textEffect;

  ///The color of the underline.
  ///
  ///The value of this attribute is a [Color] object.
  ///The default value is `null`, indicating same as foreground color.
  Color? underlineColor;

  ///The underline style of the text.
  ///
  ///This value indicates whether the text is underlined and corresponds to one of the constants described in [UnderlineStyle].
  ///The default value for this attribute is [UnderlineStyle.STYLE_NONE].
  UnderlineStyle? underlineStyle;

  AttributedString({
    required this.string,
    this.backgroundColor,
    this.baselineOffset,
    this.expansion,
    this.foregroundColor,
    this.kern,
    this.ligature,
    this.obliqueness,
    this.strikethroughColor,
    this.strikethroughStyle,
    this.strokeColor,
    this.strokeWidth,
    this.textEffect,
    this.underlineColor,
    this.underlineStyle,
  });

  Map<String, dynamic> toMap() {
    return {
      "string": this.string,
      "backgroundColor": this.backgroundColor?.toHex(),
      "baselineOffset": this.baselineOffset,
      "expansion": this.expansion,
      "foregroundColor": this.foregroundColor?.toHex(),
      "kern": this.kern,
      "ligature": this.ligature,
      "obliqueness": this.obliqueness,
      "strikethroughColor": this.strikethroughColor?.toHex(),
      "strikethroughStyle": this.strikethroughStyle?.toValue(),
      "strokeColor": this.strokeColor?.toHex(),
      "strokeWidth": this.strokeWidth,
      "textEffect": this.textEffect?.toValue(),
      "underlineColor": this.underlineColor?.toHex(),
      "underlineStyle": this.underlineStyle?.toValue(),
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///An iOS-specific class that represents a string with associated attributes
///used by the [PullToRefreshController] and [PullToRefreshOptions] classes.
///Use [AttributedString] instead.
@Deprecated("Use AttributedString instead")
class IOSNSAttributedString {
  ///The characters for the new object.
  String string;

  ///The color of the background behind the text.
  ///
  ///The value of this attribute is a [Color] object.
  ///Use this attribute to specify the color of the background area behind the text.
  ///If you do not specify this attribute, no background color is drawn.
  Color? backgroundColor;

  ///The vertical offset for the position of the text.
  ///
  ///The value of this attribute is a number containing a floating point value indicating the character’s offset from the baseline, in points.
  ///The default value is `0`.
  double? baselineOffset;

  ///The expansion factor of the text.
  ///
  ///The value of this attribute is a number containing a floating point value indicating the log of the expansion factor to be applied to glyphs.
  ///The default value is `0`, indicating no expansion.
  double? expansion;

  ///The color of the text.
  ///
  ///The value of this attribute is a [Color] object.
  ///Use this attribute to specify the color of the text during rendering.
  ///If you do not specify this attribute, the text is rendered in black.
  Color? foregroundColor;

  ///The kerning of the text.
  ///
  ///The value of this attribute is a number containing a floating-point value.
  ///This value specifies the number of points by which to adjust kern-pair characters.
  ///Kerning prevents unwanted space from occurring between specific characters and depends on the font.
  ///The value `0` means kerning is disabled. The default value for this attribute is `0`.
  double? kern;

  ///The ligature of the text.
  ///
  ///The value of this attribute is a number containing an integer.
  ///Ligatures cause specific character combinations to be rendered using a single custom glyph that corresponds to those characters.
  ///The value `0` indicates no ligatures. The value `1` indicates the use of the default ligatures.
  ///The value `2` indicates the use of all ligatures.
  ///The default value for this attribute is `1`. (Value `2` is unsupported on iOS.)
  int? ligature;

  ///The obliqueness of the text.
  ///
  ///The value of this attribute is a number containing a floating point value indicating skew to be applied to glyphs.
  ///The default value is `0`, indicating no skew.
  double? obliqueness;

  ///The color of the strikethrough.
  ///
  ///The value of this attribute is a [Color] object. The default value is `null`, indicating same as foreground color.
  Color? strikethroughColor;

  ///The strikethrough style of the text.
  ///
  ///This value indicates whether the text has a line through it and corresponds to one of the constants described in [IOSNSUnderlineStyle].
  ///The default value for this attribute is [IOSNSUnderlineStyle.STYLE_NONE].
  IOSNSUnderlineStyle? strikethroughStyle;

  ///The color of the stroke.
  ///
  ///The value of this parameter is a [Color] object.
  ///If it is not defined (which is the case by default), it is assumed to be the same as the value of foregroundColor;
  ///otherwise, it describes the outline color.
  Color? strokeColor;

  ///The width of the stroke.
  ///
  ///The value of this attribute is a number containing a floating-point value.
  ///This value represents the amount to change the stroke width and is specified as a percentage of the font point size.
  ///Specify `0` (the default) for no additional changes.
  ///Specify positive values to change the stroke width alone.
  ///Specify negative values to stroke and fill the text.
  ///For example, a typical value for outlined text would be `3.0`.
  double? strokeWidth;

  ///The text effect.
  ///
  ///The value of this attribute is a [IOSNSAttributedStringTextEffectStyle] object.
  ///The default value of this property is `null`, indicating no text effect.
  IOSNSAttributedStringTextEffectStyle? textEffect;

  ///The color of the underline.
  ///
  ///The value of this attribute is a [Color] object.
  ///The default value is `null`, indicating same as foreground color.
  Color? underlineColor;

  ///The underline style of the text.
  ///
  ///This value indicates whether the text is underlined and corresponds to one of the constants described in [IOSNSUnderlineStyle].
  ///The default value for this attribute is [IOSNSUnderlineStyle.STYLE_NONE].
  IOSNSUnderlineStyle? underlineStyle;

  IOSNSAttributedString({
    required this.string,
    this.backgroundColor,
    this.baselineOffset,
    this.expansion,
    this.foregroundColor,
    this.kern,
    this.ligature,
    this.obliqueness,
    this.strikethroughColor,
    this.strikethroughStyle,
    this.strokeColor,
    this.strokeWidth,
    this.textEffect,
    this.underlineColor,
    this.underlineStyle,
  });

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "string": this.string,
      "backgroundColor": this.backgroundColor?.toHex(),
      "baselineOffset": this.baselineOffset,
      "expansion": this.expansion,
      "foregroundColor": this.foregroundColor?.toHex(),
      "kern": this.kern,
      "ligature": this.ligature,
      "obliqueness": this.obliqueness,
      "strikethroughColor": this.strikethroughColor?.toHex(),
      "strikethroughStyle": this.strikethroughStyle?.toValue(),
      "strokeColor": this.strokeColor?.toHex(),
      "strokeWidth": this.strokeWidth,
      "textEffect": this.textEffect?.toValue(),
      "underlineColor": this.underlineColor?.toHex(),
      "underlineStyle": this.underlineStyle?.toValue(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}