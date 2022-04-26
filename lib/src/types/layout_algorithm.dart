///Class used to set the underlying layout algorithm.
class LayoutAlgorithm {
  final String _value;

  const LayoutAlgorithm._internal(this._value);

  ///Set of all values of [LayoutAlgorithm].
  static final Set<LayoutAlgorithm> values = [
    LayoutAlgorithm.NORMAL,
    LayoutAlgorithm.TEXT_AUTOSIZING,
    LayoutAlgorithm.NARROW_COLUMNS,
  ].toSet();

  ///Gets a possible [LayoutAlgorithm] instance from a [String] value.
  static LayoutAlgorithm? fromValue(String? value) {
    if (value != null) {
      try {
        return LayoutAlgorithm.values
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

  ///NORMAL means no rendering changes. This is the recommended choice for maximum compatibility across different platforms and Android versions.
  static const NORMAL = const LayoutAlgorithm._internal("NORMAL");

  ///TEXT_AUTOSIZING boosts font size of paragraphs based on heuristics to make the text readable when viewing a wide-viewport layout in the overview mode.
  ///It is recommended to enable zoom support [AndroidInAppWebViewOptions.supportZoom] when using this mode.
  ///
  ///**NOTE**: available on Android 19+.
  static const TEXT_AUTOSIZING =
  const LayoutAlgorithm._internal("TEXT_AUTOSIZING");

  ///NARROW_COLUMNS makes all columns no wider than the screen if possible. Only use this for API levels prior to `Build.VERSION_CODES.KITKAT`.
  static const NARROW_COLUMNS =
  const LayoutAlgorithm._internal("NARROW_COLUMNS");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///An Android-specific class used to set the underlying layout algorithm.
///Use [LayoutAlgorithm] instead.
@Deprecated("Use LayoutAlgorithm instead")
class AndroidLayoutAlgorithm {
  final String _value;

  const AndroidLayoutAlgorithm._internal(this._value);

  ///Set of all values of [AndroidLayoutAlgorithm].
  static final Set<AndroidLayoutAlgorithm> values = [
    AndroidLayoutAlgorithm.NORMAL,
    AndroidLayoutAlgorithm.TEXT_AUTOSIZING,
    AndroidLayoutAlgorithm.NARROW_COLUMNS,
  ].toSet();

  ///Gets a possible [AndroidLayoutAlgorithm] instance from a [String] value.
  static AndroidLayoutAlgorithm? fromValue(String? value) {
    if (value != null) {
      try {
        return AndroidLayoutAlgorithm.values
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

  ///NORMAL means no rendering changes. This is the recommended choice for maximum compatibility across different platforms and Android versions.
  static const NORMAL = const AndroidLayoutAlgorithm._internal("NORMAL");

  ///TEXT_AUTOSIZING boosts font size of paragraphs based on heuristics to make the text readable when viewing a wide-viewport layout in the overview mode.
  ///It is recommended to enable zoom support [AndroidInAppWebViewOptions.supportZoom] when using this mode.
  ///
  ///**NOTE**: available on Android 19+.
  static const TEXT_AUTOSIZING =
  const AndroidLayoutAlgorithm._internal("TEXT_AUTOSIZING");

  ///NARROW_COLUMNS makes all columns no wider than the screen if possible. Only use this for API levels prior to `Build.VERSION_CODES.KITKAT`.
  static const NARROW_COLUMNS =
  const AndroidLayoutAlgorithm._internal("NARROW_COLUMNS");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}