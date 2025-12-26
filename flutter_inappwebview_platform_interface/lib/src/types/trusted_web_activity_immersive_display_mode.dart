import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'trusted_web_activity_display_mode.dart';
import 'layout_in_display_cutout_mode.dart';
import 'enum_method.dart';

part 'trusted_web_activity_immersive_display_mode.g.dart';

///Class that represents the default display mode of a Trusted Web Activity.
///The system UI (status bar, navigation bar) is shown, and the browser toolbar is hidden while the user is on a verified origin.
@ExchangeableObject()
class TrustedWebActivityImmersiveDisplayMode_
    implements TrustedWebActivityDisplayMode_ {
  ///Whether the Trusted Web Activity should be in sticky immersive mode.
  bool isSticky;

  ///Use [displayCutoutMode] instead.
  @Deprecated("Use displayCutoutMode instead")
  AndroidLayoutInDisplayCutoutMode_? layoutInDisplayCutoutMode;

  ///The constant defining how to deal with display cutouts.
  LayoutInDisplayCutoutMode_ displayCutoutMode;

  static final _type = "IMMERSIVE_MODE";

  @ExchangeableObjectConstructor()
  TrustedWebActivityImmersiveDisplayMode_(
      {required this.isSticky,
      this.displayCutoutMode = LayoutInDisplayCutoutMode_.DEFAULT,
      this.layoutInDisplayCutoutMode}) {
    this.displayCutoutMode = this.layoutInDisplayCutoutMode != null
        ? LayoutInDisplayCutoutMode_.fromNativeValue(
            layoutInDisplayCutoutMode?.toNativeValue())!
        : this.displayCutoutMode;
  }

  @ExchangeableObjectMethod(toMapMergeWith: true)
  // ignore: unused_element
  Map<String, dynamic> _toMapMergeWith({EnumMethod? enumMethod}) {
    return {"type": _type};
  }

  @override
  @ExchangeableObjectMethod(ignore: true)
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
