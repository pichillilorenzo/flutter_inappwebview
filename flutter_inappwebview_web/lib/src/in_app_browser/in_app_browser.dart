import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser}
class WebPlatformInAppBrowser extends PlatformInAppBrowser with ChannelController {
  /// Constructs a [WebPlatformInAppBrowser].
  WebPlatformInAppBrowser(PlatformInAppBrowserCreationParams params)
      : super.implementation(params) {
  }

  static final WebPlatformInAppBrowser _staticValue =
      WebPlatformInAppBrowser(PlatformInAppBrowserCreationParams());

  /// Provide static access.
  factory WebPlatformInAppBrowser.static() {
    return _staticValue;
  }
}