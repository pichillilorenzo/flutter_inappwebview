import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'in_app_webview_rect.dart';
import 'enum_method.dart';
import '../print_job/print_job_settings.dart';

part 'pdf_configuration.g.dart';

///Class that represents the configuration data to use when generating a PDF representation of a web view's contents.
@ExchangeableObject()
class PDFConfiguration_ {
  ///The portion of your web view to capture, specified as a rectangle in the view's coordinate system.
  ///The default value of this property is `null`, which captures everything in the view's bounds rectangle.
  ///If you specify a custom rectangle, it must lie within the bounds rectangle of the `WebView` object.
  @SupportedPlatforms(platforms: [IOSPlatform(), MacOSPlatform()])
  InAppWebViewRect_? rect;

  ///The print settings to use when generating the PDF.
  ///These settings control page size, orientation, margins, and other printing options.
  ///If not specified, default print settings will be used.
  @SupportedPlatforms(platforms: [WindowsPlatform()])
  PrintJobSettings_? settings;

  PDFConfiguration_({this.rect, this.settings});
}

///An iOS-specific class that represents the configuration data to use when generating a PDF representation of a web view’s contents.
///
///**NOTE**: available on iOS 14.0+.
///
///Use [PDFConfiguration] instead.
@Deprecated("Use PDFConfiguration instead")
@ExchangeableObject()
class IOSWKPDFConfiguration_ {
  ///The portion of your web view to capture, specified as a rectangle in the view’s coordinate system.
  ///The default value of this property is `null`, which captures everything in the view’s bounds rectangle.
  ///If you specify a custom rectangle, it must lie within the bounds rectangle of the `WebView` object.
  InAppWebViewRect_? rect;

  IOSWKPDFConfiguration_({this.rect});
}
