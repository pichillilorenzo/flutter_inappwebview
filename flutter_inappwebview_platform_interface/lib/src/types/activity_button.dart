import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'enum_method.dart';
import 'ui_image.dart';

part 'activity_button.g.dart';

///Class that represents a custom button to show in `SFSafariViewController`'s toolbar.
///When tapped, it will invoke a Share or Action Extension bundled with your app.
///The default VoiceOver description of this button is the `CFBundleDisplayName` set in the extension's `Info.plist`.
///
///Check [Official Apple App Extensions](https://developer.apple.com/app-extensions/) for more details.
///
///**Officially Supported Platforms/Implementations**:
///- iOS
@ExchangeableObject()
class ActivityButton_ {
  ///The name of the image asset or file.
  UIImage_ templateImage;

  ///The name of the App or Share Extension to be called.
  String extensionIdentifier;

  @ExchangeableObjectConstructor()
  ActivityButton_(
      {required this.templateImage, required this.extensionIdentifier});
}
