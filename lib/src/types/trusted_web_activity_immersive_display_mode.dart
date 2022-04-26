import 'trusted_web_activity_display_mode.dart';
import 'layout_in_display_cutout_mode.dart';

///Class that represents the default display mode of a Trusted Web Activity.
///The system UI (status bar, navigation bar) is shown, and the browser toolbar is hidden while the user is on a verified origin.
class TrustedWebActivityImmersiveDisplayMode
    implements TrustedWebActivityDisplayMode {
  ///Whether the Trusted Web Activity should be in sticky immersive mode.
  bool isSticky;

  ///Use [displayCutoutMode] instead.
  @Deprecated("Use displayCutoutMode instead")
  AndroidLayoutInDisplayCutoutMode? layoutInDisplayCutoutMode;

  ///The constant defining how to deal with display cutouts.
  LayoutInDisplayCutoutMode displayCutoutMode;

  String _type = "IMMERSIVE_MODE";

  TrustedWebActivityImmersiveDisplayMode(
      {required this.isSticky,
        this.displayCutoutMode = LayoutInDisplayCutoutMode.DEFAULT,
        this.layoutInDisplayCutoutMode}) {
    // ignore: deprecated_member_use_from_same_package
    this.displayCutoutMode = this.layoutInDisplayCutoutMode != null
        ? LayoutInDisplayCutoutMode.fromValue(
      // ignore: deprecated_member_use_from_same_package
        this.layoutInDisplayCutoutMode!.toValue())!
        : this.displayCutoutMode;
  }

  ///Gets a possible [TrustedWebActivityImmersiveDisplayMode] instance from a [Map] value.
  static TrustedWebActivityImmersiveDisplayMode? fromMap(
      Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }

    return TrustedWebActivityImmersiveDisplayMode(
        isSticky: map["isSticky"],
        displayCutoutMode: map["layoutInDisplayCutoutMode"],
        layoutInDisplayCutoutMode: map["layoutInDisplayCutoutMode"]);
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "isSticky": isSticky,
      "layoutInDisplayCutoutMode": displayCutoutMode.toValue(),
      "displayCutoutMode": displayCutoutMode.toValue(),
      "type": _type
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