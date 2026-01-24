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
  TrustedWebActivityImmersiveDisplayMode({
    required this.isSticky,
    this.displayCutoutMode = LayoutInDisplayCutoutMode.DEFAULT,
    this.layoutInDisplayCutoutMode,
  }) {
    this.displayCutoutMode = this.layoutInDisplayCutoutMode != null
        ? LayoutInDisplayCutoutMode.fromNativeValue(
            layoutInDisplayCutoutMode?.toNativeValue(),
          )!
        : this.displayCutoutMode;
  }

  ///Gets a possible [TrustedWebActivityImmersiveDisplayMode] instance from a [Map] value.
  static TrustedWebActivityImmersiveDisplayMode? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = TrustedWebActivityImmersiveDisplayMode(
      isSticky: map['isSticky'],
      layoutInDisplayCutoutMode: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          AndroidLayoutInDisplayCutoutMode.fromNativeValue(
            map['displayCutoutMode'],
          ),
        EnumMethod.value => AndroidLayoutInDisplayCutoutMode.fromValue(
          map['displayCutoutMode'],
        ),
        EnumMethod.name => AndroidLayoutInDisplayCutoutMode.byName(
          map['displayCutoutMode'],
        ),
      },
    );
    if (map['displayCutoutMode'] != null) {
      instance.displayCutoutMode = switch (enumMethod ??
          EnumMethod.nativeValue) {
        EnumMethod.nativeValue => LayoutInDisplayCutoutMode.fromNativeValue(
          map['displayCutoutMode'],
        ),
        EnumMethod.value => LayoutInDisplayCutoutMode.fromValue(
          map['displayCutoutMode'],
        ),
        EnumMethod.name => LayoutInDisplayCutoutMode.byName(
          map['displayCutoutMode'],
        ),
      }!;
    }
    return instance;
  }

  @ExchangeableObjectMethod(toMapMergeWith: true)
  Map<String, dynamic> _toMapMergeWith({EnumMethod? enumMethod}) {
    return {"type": _type};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "displayCutoutMode": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => displayCutoutMode.toNativeValue(),
        EnumMethod.value => displayCutoutMode.toValue(),
        EnumMethod.name => displayCutoutMode.name(),
      },
      "isSticky": isSticky,
      ..._toMapMergeWith(enumMethod: enumMethod),
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
