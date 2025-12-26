import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../types/ui_image.dart';
import 'platform_chrome_safari_browser.dart';
import '../web_uri.dart';
import '../types/enum_method.dart';

part 'chrome_safari_browser_menu_item.g.dart';

///Class that represents a custom menu item for a [PlatformChromeSafariBrowser] instance.
@SupportedPlatforms(platforms: [
  AndroidPlatform(note: 'Not available in an Android Trusted Web Activity.'),
  IOSPlatform()
])
@ExchangeableObject()
class ChromeSafariBrowserMenuItem_ {
  ///The menu item id. It should be different from [ChromeSafariBrowserActionButton.id].
  int id;

  ///The label of the menu item.
  String label;

  ///Item image.
  UIImage_? image;

  ///Use onClick instead.
  @Deprecated("Use onClick instead")
  void Function(String url, String title)? action;

  ///Callback function to be invoked when the menu item is clicked
  void Function(WebUri? url, String title)? onClick;

  @ExchangeableObjectConstructor()
  ChromeSafariBrowserMenuItem_(
      {required this.id,
      required this.label,
      this.image,
      @Deprecated("Use onClick instead") this.action,
      this.onClick});
}
