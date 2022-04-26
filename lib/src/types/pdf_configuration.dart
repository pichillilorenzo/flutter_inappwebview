import '../in_app_webview/webview.dart';
import 'in_app_webview_rect.dart';

///Class that represents the configuration data to use when generating a PDF representation of a web view’s contents.
class PDFConfiguration {
  ///The portion of your web view to capture, specified as a rectangle in the view’s coordinate system.
  ///The default value of this property is `null`, which captures everything in the view’s bounds rectangle.
  ///If you specify a custom rectangle, it must lie within the bounds rectangle of the [WebView] object.
  InAppWebViewRect? rect;

  PDFConfiguration({this.rect});

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"rect": rect?.toMap()};
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

///An iOS-specific class that represents the configuration data to use when generating a PDF representation of a web view’s contents.
///
///**NOTE**: available on iOS 14.0+.
///
///Use [PDFConfiguration] instead.
@Deprecated("Use PDFConfiguration instead")
class IOSWKPDFConfiguration {
  ///The portion of your web view to capture, specified as a rectangle in the view’s coordinate system.
  ///The default value of this property is `null`, which captures everything in the view’s bounds rectangle.
  ///If you specify a custom rectangle, it must lie within the bounds rectangle of the [WebView] object.
  InAppWebViewRect? rect;

  IOSWKPDFConfiguration({this.rect});

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"rect": rect?.toMap()};
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