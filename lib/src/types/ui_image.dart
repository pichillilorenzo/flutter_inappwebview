import 'dart:typed_data';

import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'ui_image.g.dart';

///Class that represents an object that manages iOS image data in your app.
///
///Check [UIKit.UIImage](https://developer.apple.com/documentation/uikit/uiimage) for more details.
///
///**Supported Platforms/Implementations**:
///- iOS
@ExchangeableObject()
class UIImage_ {
  ///The name of the image asset or file.
  String? name;

  ///The name of the system symbol image.
  ///
  ///**NOTE**: available on iOS 13.0+.
  String? systemName;

  ///The data object containing the image data.
  Uint8List? data;

  @ExchangeableObjectConstructor()
  UIImage_({this.name, this.systemName, this.data}) {
    assert(this.name != null || this.systemName != null || this.data != null);
  }
}
