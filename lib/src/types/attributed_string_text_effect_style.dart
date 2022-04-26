///Class that represents the supported proxy types.
class AttributedStringTextEffectStyle {
  final String _value;

  const AttributedStringTextEffectStyle._internal(this._value);

  ///Set of all values of [AttributedStringTextEffectStyle].
  static final Set<AttributedStringTextEffectStyle> values = [
    AttributedStringTextEffectStyle.LETTERPRESS_STYLE,
  ].toSet();

  ///Gets a possible [AttributedStringTextEffectStyle] instance from a [String] value.
  static AttributedStringTextEffectStyle? fromValue(String? value) {
    if (value != null) {
      try {
        return AttributedStringTextEffectStyle.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  @override
  String toString() => _value;

  ///A graphical text effect that gives glyphs the appearance of letterpress printing, which involves pressing the type into the paper.
  static const LETTERPRESS_STYLE =
  const AttributedStringTextEffectStyle._internal("letterpressStyle");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///An iOS-specific Class that represents the supported proxy types.
///Use [AttributedStringTextEffectStyle] instead.
@Deprecated("Use AttributedStringTextEffectStyle instead")
class IOSNSAttributedStringTextEffectStyle {
  final String _value;

  const IOSNSAttributedStringTextEffectStyle._internal(this._value);

  ///Set of all values of [IOSNSAttributedStringTextEffectStyle].
  static final Set<IOSNSAttributedStringTextEffectStyle> values = [
    IOSNSAttributedStringTextEffectStyle.LETTERPRESS_STYLE,
  ].toSet();

  ///Gets a possible [IOSNSAttributedStringTextEffectStyle] instance from a [String] value.
  static IOSNSAttributedStringTextEffectStyle? fromValue(String? value) {
    if (value != null) {
      try {
        return IOSNSAttributedStringTextEffectStyle.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  @override
  String toString() => _value;

  ///A graphical text effect that gives glyphs the appearance of letterpress printing, which involves pressing the type into the paper.
  static const LETTERPRESS_STYLE =
  const IOSNSAttributedStringTextEffectStyle._internal("letterpressStyle");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}