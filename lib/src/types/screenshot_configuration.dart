import '../in_app_webview/webview.dart';
import '../in_app_webview/in_app_webview_controller.dart';
import 'in_app_webview_rect.dart';
import 'compress_format.dart';

///Class that represents the configuration data to use when generating an image from a web view’s contents using [InAppWebViewController.takeScreenshot].
class ScreenshotConfiguration {
  ///The portion of your web view to capture, specified as a rectangle in the view’s coordinate system.
  ///The default value of this property is `null`, which captures everything in the view’s bounds rectangle.
  ///If you specify a custom rectangle, it must lie within the bounds rectangle of the [WebView] object.
  InAppWebViewRect? rect;

  ///The width of the captured image, in points.
  ///Use this property to scale the generated image to the specified width.
  ///The web view maintains the aspect ratio of the captured content, but scales it to match the width you specify.
  ///
  ///The default value of this property is `null`, which returns an image whose size matches the original size of the captured rectangle.
  double? snapshotWidth;

  ///The compression format of the captured image.
  ///The default value is [CompressFormat.PNG].
  CompressFormat compressFormat;

  ///Hint to the compressor, `0-100`. The value is interpreted differently depending on the [CompressFormat].
  ///[CompressFormat.PNG] is lossless, so this value is ignored.
  int quality;

  ///Use [afterScreenUpdates] instead.
  @Deprecated("Use afterScreenUpdates instead")
  bool? iosAfterScreenUpdates;

  ///A Boolean value that indicates whether to take the snapshot after incorporating any pending screen updates.
  ///The default value of this property is `true`, which causes the web view to incorporate any recent changes to the view’s content and then generate the snapshot.
  ///If you change the value to `false`, the [WebView] takes the snapshot immediately, and before incorporating any new changes.
  ///
  ///**NOTE**: available only on iOS.
  ///
  ///**NOTE for iOS**: Available from iOS 13.0+.
  bool afterScreenUpdates;

  ScreenshotConfiguration(
      {this.rect,
        this.snapshotWidth,
        this.compressFormat = CompressFormat.PNG,
        this.quality = 100,
        @Deprecated("Use afterScreenUpdates instead") this.iosAfterScreenUpdates,
        this.afterScreenUpdates = true}) {
    assert(this.quality >= 0);
    // ignore: deprecated_member_use_from_same_package
    this.afterScreenUpdates = this.iosAfterScreenUpdates != null
    // ignore: deprecated_member_use_from_same_package
        ? this.iosAfterScreenUpdates!
        : this.afterScreenUpdates;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "rect": rect?.toMap(),
      "snapshotWidth": snapshotWidth,
      "compressFormat": compressFormat.toValue(),
      "quality": quality,
      "iosAfterScreenUpdates": afterScreenUpdates,
      "afterScreenUpdates": afterScreenUpdates
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