import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

import 'enum_method.dart';

part 'in_app_webview_rect.g.dart';

///A class that represents a structure that contains the location and dimensions of a rectangle.
@ExchangeableObject()
class InAppWebViewRect_ {
  ///x position
  double x;

  ///y position
  double y;

  ///rect width
  double width;

  ///rect height
  double height;

  @ExchangeableObjectConstructor()
  InAppWebViewRect_({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  }) {
    assert(width >= 0 && height >= 0);
  }
}
