///Class representing the share state that should be applied to the custom tab.
///
///**NOTE**: available on Android 28+.
class LayoutInDisplayCutoutMode {
  final int _value;

  const LayoutInDisplayCutoutMode._internal(this._value);

  ///Set of all values of [LayoutInDisplayCutoutMode].
  static final Set<LayoutInDisplayCutoutMode> values = [
    LayoutInDisplayCutoutMode.DEFAULT,
    LayoutInDisplayCutoutMode.SHORT_EDGES,
    LayoutInDisplayCutoutMode.NEVER,
    LayoutInDisplayCutoutMode.ALWAYS
  ].toSet();

  ///Gets a possible [LayoutInDisplayCutoutMode] instance from an [int] value.
  static LayoutInDisplayCutoutMode? fromValue(int? value) {
    if (value != null) {
      try {
        return LayoutInDisplayCutoutMode.values
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
        return "SHORT_EDGES";
      case 2:
        return "NEVER";
      case 3:
        return "ALWAYS";
      case 0:
      default:
        return "DEFAULT";
    }
  }

  ///With this default setting, content renders into the cutout area when displayed in portrait mode, but content is letterboxed when displayed in landscape mode.
  ///
  ///**NOTE**: available on Android 28+.
  static const DEFAULT = const LayoutInDisplayCutoutMode._internal(0);

  ///Content renders into the cutout area in both portrait and landscape modes.
  ///
  ///**NOTE**: available on Android 28+.
  static const SHORT_EDGES = const LayoutInDisplayCutoutMode._internal(1);

  ///Content never renders into the cutout area.
  ///
  ///**NOTE**: available on Android 28+.
  static const NEVER = const LayoutInDisplayCutoutMode._internal(2);

  ///The window is always allowed to extend into the DisplayCutout areas on the all edges of the screen.
  ///
  ///**NOTE**: available on Android 30+.
  static const ALWAYS = const LayoutInDisplayCutoutMode._internal(3);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Android-specific class representing the share state that should be applied to the custom tab.
///
///**NOTE**: available on Android 28+.
///
///Use [LayoutInDisplayCutoutMode] instead.
@Deprecated("Use LayoutInDisplayCutoutMode instead")
class AndroidLayoutInDisplayCutoutMode {
  final int _value;

  const AndroidLayoutInDisplayCutoutMode._internal(this._value);

  ///Set of all values of [AndroidLayoutInDisplayCutoutMode].
  static final Set<AndroidLayoutInDisplayCutoutMode> values = [
    AndroidLayoutInDisplayCutoutMode.DEFAULT,
    AndroidLayoutInDisplayCutoutMode.SHORT_EDGES,
    AndroidLayoutInDisplayCutoutMode.NEVER,
    AndroidLayoutInDisplayCutoutMode.ALWAYS
  ].toSet();

  ///Gets a possible [AndroidLayoutInDisplayCutoutMode] instance from an [int] value.
  static AndroidLayoutInDisplayCutoutMode? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidLayoutInDisplayCutoutMode.values
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
        return "SHORT_EDGES";
      case 2:
        return "NEVER";
      case 3:
        return "ALWAYS";
      case 0:
      default:
        return "DEFAULT";
    }
  }

  ///With this default setting, content renders into the cutout area when displayed in portrait mode, but content is letterboxed when displayed in landscape mode.
  ///
  ///**NOTE**: available on Android 28+.
  static const DEFAULT = const AndroidLayoutInDisplayCutoutMode._internal(0);

  ///Content renders into the cutout area in both portrait and landscape modes.
  ///
  ///**NOTE**: available on Android 28+.
  static const SHORT_EDGES =
  const AndroidLayoutInDisplayCutoutMode._internal(1);

  ///Content never renders into the cutout area.
  ///
  ///**NOTE**: available on Android 28+.
  static const NEVER = const AndroidLayoutInDisplayCutoutMode._internal(2);

  ///The window is always allowed to extend into the DisplayCutout areas on the all edges of the screen.
  ///
  ///**NOTE**: available on Android 30+.
  static const ALWAYS = const AndroidLayoutInDisplayCutoutMode._internal(3);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}