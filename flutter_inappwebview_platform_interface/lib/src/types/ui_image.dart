import 'dart:typed_data';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'enum_method.dart';

part 'ui_image.g.dart';

///Class that represents an object that manages iOS and MacOS image data in your app.
///
///Check iOS [UIKit.UIImage](https://developer.apple.com/documentation/uikit/uiimage) for more details.
///Check MacOS [AppKit.NSImage](https://developer.apple.com/documentation/appkit/nsimage) for more details.
///
///**Officially Supported Platforms/Implementations**:
///- iOS
///- MacOS
@ExchangeableObject()
class UIImage_ {
  ///The name of the image asset or file.
  String? name;

  ///The name of the system symbol image.
  @SupportedPlatforms(platforms: [
    IOSPlatform(available: "13.0"),
    MacOSPlatform(available: "11.0"),
  ])
  String? systemName;

  ///The data object containing the image data.
  Uint8List? data;

  @ExchangeableObjectConstructor()
  UIImage_({this.name, this.systemName, this.data}) {
    assert(this.name != null || this.systemName != null || this.data != null);
  }
}
