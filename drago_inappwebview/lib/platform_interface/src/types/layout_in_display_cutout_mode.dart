import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

part 'layout_in_display_cutout_mode.g.dart';

///Class representing the share state that should be applied to the custom tab.
@ExchangeableEnum()
class LayoutInDisplayCutoutMode_ {
  // ignore: unused_field
  final int _value;
  const LayoutInDisplayCutoutMode_._internal(this._value);

  ///With this default setting, content renders into the cutout area when displayed in portrait mode, but content is letterboxed when displayed in landscape mode.
  ///
  ///**NOTE**: available on Android 28+.
  static const DEFAULT = LayoutInDisplayCutoutMode_._internal(0);

  ///Content renders into the cutout area in both portrait and landscape modes.
  ///
  ///**NOTE**: available on Android 28+.
  static const SHORT_EDGES = LayoutInDisplayCutoutMode_._internal(1);

  ///Content never renders into the cutout area.
  ///
  ///**NOTE**: available on Android 28+.
  static const NEVER = LayoutInDisplayCutoutMode_._internal(2);

  ///The window is always allowed to extend into the DisplayCutout areas on the all edges of the screen.
  ///
  ///**NOTE**: available on Android 30+.
  static const ALWAYS = LayoutInDisplayCutoutMode_._internal(3);

  @ExchangeableObjectMethod(ignore: true)
  static LayoutInDisplayCutoutMode_? fromNativeValue(int? value) {
    return null;
  }
}

///Android-specific class representing the share state that should be applied to the custom tab.
///
///**NOTE**: available on Android 28+.
///
///Use [LayoutInDisplayCutoutMode] instead.
@Deprecated("Use LayoutInDisplayCutoutMode instead")
@ExchangeableEnum()
class AndroidLayoutInDisplayCutoutMode_ {
  // ignore: unused_field
  final int _value;
  const AndroidLayoutInDisplayCutoutMode_._internal(this._value);

  ///With this default setting, content renders into the cutout area when displayed in portrait mode, but content is letterboxed when displayed in landscape mode.
  ///
  ///**NOTE**: available on Android 28+.
  static const DEFAULT = AndroidLayoutInDisplayCutoutMode_._internal(0);

  ///Content renders into the cutout area in both portrait and landscape modes.
  ///
  ///**NOTE**: available on Android 28+.
  static const SHORT_EDGES = AndroidLayoutInDisplayCutoutMode_._internal(
    1,
  );

  ///Content never renders into the cutout area.
  ///
  ///**NOTE**: available on Android 28+.
  static const NEVER = AndroidLayoutInDisplayCutoutMode_._internal(2);

  ///The window is always allowed to extend into the DisplayCutout areas on the all edges of the screen.
  ///
  ///**NOTE**: available on Android 30+.
  static const ALWAYS = AndroidLayoutInDisplayCutoutMode_._internal(3);

  @ExchangeableObjectMethod(ignore: true)
  int toNativeValue() => 0;
}
