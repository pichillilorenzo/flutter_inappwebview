// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_configuration.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the configuration data to use when generating a PDF representation of a web view's contents.
class PDFConfiguration {
  ///The portion of your web view to capture, specified as a rectangle in the view's coordinate system.
  ///The default value of this property is `null`, which captures everything in the view's bounds rectangle.
  ///If you specify a custom rectangle, it must lie within the bounds rectangle of the `WebView` object.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  InAppWebViewRect? rect;

  ///The print settings to use when generating the PDF.
  ///These settings control page size, orientation, margins, and other printing options.
  ///If not specified, default print settings will be used.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  PrintJobSettings? settings;
  PDFConfiguration({this.rect, this.settings});

  ///Gets a possible [PDFConfiguration] instance from a [Map] value.
  static PDFConfiguration? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = PDFConfiguration(
      rect: InAppWebViewRect.fromMap(
        map['rect']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
      settings: PrintJobSettings.fromMap(
        map['settings']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "rect": rect?.toMap(enumMethod: enumMethod),
      "settings": settings?.toMap(enumMethod: enumMethod),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'PDFConfiguration{rect: $rect, settings: $settings}';
  }
}

///An iOS-specific class that represents the configuration data to use when generating a PDF representation of a web view’s contents.
///
///**NOTE**: available on iOS 14.0+.
///
///Use [PDFConfiguration] instead.
@Deprecated('Use PDFConfiguration instead')
class IOSWKPDFConfiguration {
  ///The portion of your web view to capture, specified as a rectangle in the view’s coordinate system.
  ///The default value of this property is `null`, which captures everything in the view’s bounds rectangle.
  ///If you specify a custom rectangle, it must lie within the bounds rectangle of the `WebView` object.
  InAppWebViewRect? rect;
  IOSWKPDFConfiguration({this.rect});

  ///Gets a possible [IOSWKPDFConfiguration] instance from a [Map] value.
  static IOSWKPDFConfiguration? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = IOSWKPDFConfiguration(
      rect: InAppWebViewRect.fromMap(
        map['rect']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {"rect": rect?.toMap(enumMethod: enumMethod)};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'IOSWKPDFConfiguration{rect: $rect}';
  }
}
