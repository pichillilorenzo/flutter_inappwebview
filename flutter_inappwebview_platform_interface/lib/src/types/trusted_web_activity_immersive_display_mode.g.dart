// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trusted_web_activity_immersive_display_mode.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the default display mode of a Trusted Web Activity.
///The system UI (status bar, navigation bar) is shown, and the browser toolbar is hidden while the user is on a verified origin.
class TrustedWebActivityImmersiveDisplayMode
    implements TrustedWebActivityDisplayMode {
  static final String _type = "IMMERSIVE_MODE";

  ///The constant defining how to deal with display cutouts.
  LayoutInDisplayCutoutMode displayCutoutMode;

  ///Whether the Trusted Web Activity should be in sticky immersive mode.
  bool isSticky;

  ///Use [displayCutoutMode] instead.
  @Deprecated('Use displayCutoutMode instead')
  AndroidLayoutInDisplayCutoutMode? layoutInDisplayCutoutMode;
  TrustedWebActivityImmersiveDisplayMode(
      {required this.isSticky,
      this.displayCutoutMode = LayoutInDisplayCutoutMode.DEFAULT,
      this.layoutInDisplayCutoutMode}) {
    this.displayCutoutMode = this.layoutInDisplayCutoutMode != null
        ? LayoutInDisplayCutoutMode.fromNativeValue(
            layoutInDisplayCutoutMode?.toNativeValue())!
        : this.displayCutoutMode;
  }

  ///Gets a possible [TrustedWebActivityImmersiveDisplayMode] instance from a [Map] value.
  static TrustedWebActivityImmersiveDisplayMode? fromMap(
      Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = TrustedWebActivityImmersiveDisplayMode(
      isSticky: map['isSticky'],
      layoutInDisplayCutoutMode:
          AndroidLayoutInDisplayCutoutMode.fromNativeValue(
              map['displayCutoutMode']),
    );
    instance.displayCutoutMode =
        LayoutInDisplayCutoutMode.fromNativeValue(map['displayCutoutMode'])!;
    return instance;
  }

  @ExchangeableObjectMethod(toMapMergeWith: true)
  Map<String, dynamic> _toMapMergeWith() {
    return {"type": _type};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "displayCutoutMode": displayCutoutMode.toNativeValue(),
      "isSticky": isSticky,
      ..._toMapMergeWith(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'TrustedWebActivityImmersiveDisplayMode{displayCutoutMode: $displayCutoutMode, isSticky: $isSticky}';
  }
}
