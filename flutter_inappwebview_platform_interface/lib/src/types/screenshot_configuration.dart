import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_inappwebview_controller.dart';
import 'in_app_webview_rect.dart';
import 'compress_format.dart';
import 'enum_method.dart';

part 'screenshot_configuration.g.dart';

///Class that represents the configuration data to use when generating an image from a web view’s contents using [PlatformInAppWebViewController.takeScreenshot].
@ExchangeableObject()
class ScreenshotConfiguration_ {
  ///The portion of your web view to capture, specified as a rectangle in the view’s coordinate system.
  ///The default value of this property is `null`, which captures everything in the view’s bounds rectangle.
  ///If you specify a custom rectangle, it must lie within the bounds rectangle of the `WebView` object.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  InAppWebViewRect_? rect;

  ///The width of the captured image, in points.
  ///Use this property to scale the generated image to the specified width.
  ///The web view maintains the aspect ratio of the captured content, but scales it to match the width you specify.
  ///
  ///The default value of this property is `null`, which returns an image whose size matches the original size of the captured rectangle.
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  double? snapshotWidth;

  ///The compression format of the captured image.
  ///The default value is [CompressFormat.PNG].
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  CompressFormat_ compressFormat;

  ///Hint to the compressor, `0-100`. The value is interpreted differently depending on the [CompressFormat].
  ///[CompressFormat.PNG] is lossless, so this value is ignored.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  int quality;

  ///Use [afterScreenUpdates] instead.
  @Deprecated("Use afterScreenUpdates instead")
  bool? iosAfterScreenUpdates;

  ///A Boolean value that indicates whether to take the snapshot after incorporating any pending screen updates.
  ///The default value of this property is `true`, which causes the web view to incorporate any recent changes to the view’s content and then generate the snapshot.
  ///If you change the value to `false`, the `WebView` takes the snapshot immediately, and before incorporating any new changes.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(available: '13.0'),
      MacOSPlatform(available: '10.15'),
    ],
  )
  bool afterScreenUpdates;

  @ExchangeableObjectConstructor()
  ScreenshotConfiguration_({
    this.rect,
    this.snapshotWidth,
    CompressFormat_? compressFormat,
    this.quality = 100,
    @Deprecated("Use afterScreenUpdates instead") this.iosAfterScreenUpdates,
    this.afterScreenUpdates = true,
  }) : compressFormat = compressFormat ?? CompressFormat_.PNG {
    assert(this.quality >= 0);
    // ignore: deprecated_member_use_from_same_package
    this.afterScreenUpdates = this.iosAfterScreenUpdates != null
        // ignore: deprecated_member_use_from_same_package
        ? this.iosAfterScreenUpdates!
        : this.afterScreenUpdates;
  }
}
