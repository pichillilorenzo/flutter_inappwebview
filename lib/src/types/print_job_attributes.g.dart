// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_attributes.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing the attributes of a [PrintJobController].
///These attributes describe how the printed content should be laid out.
class PrintJobAttributes {
  ///The color mode.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  PrintJobColorMode? colorMode;

  ///The duplex mode to use for the print job.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView 23+
  ///- iOS
  PrintJobDuplexMode? duplex;

  ///The orientation of the printed content, portrait or landscape.
  PrintJobOrientation? orientation;

  ///The media size.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  PrintJobMediaSize? mediaSize;

  ///The supported resolution in DPI (dots per inch).
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  PrintJobResolution? resolution;

  ///The margins for each printed page.
  ///Margins define the white space around the content where the left margin defines
  ///the amount of white space on the left of the content and so on.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  EdgeInsets? margins;

  ///The height of the page footer.
  ///
  ///The footer is measured in points from the bottom of [printableRect] and is below the content area.
  ///The default footer height is `0.0`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  double? footerHeight;

  ///The height of the page header.
  ///
  ///The header is measured in points from the top of [printableRect] and is above the content area.
  ///The default header height is `0.0`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  double? headerHeight;

  ///The area in which printing can occur.
  ///
  ///The value of this property is a rectangle that defines the area in which the printer can print content.
  ///Sometimes this is referred to as the imageable area of the paper.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  InAppWebViewRect? printableRect;

  ///The size of the paper used for printing.
  ///
  ///The value of this property is a rectangle that defines the size of paper chosen for the print job.
  ///The origin is always (0,0).
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  InAppWebViewRect? paperRect;

  ///The maximum height of the content area.
  ///
  ///The Print Formatter uses this value to determine where the content rectangle begins on the first page.
  ///It compares the value of this property with the printing rectangle’s height minus the header and footer heights and
  ///the top inset value; it uses the lower of the two values.
  ///The default value of this property is the maximum float value.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  double? maximumContentHeight;

  ///The maximum width of the content area.
  ///
  ///The Print Formatter uses this value to determine the maximum width of the content rectangle.
  ///It compares the value of this property with the printing rectangle’s width minus the left and right inset values and uses the lower of the two.
  ///The default value of this property is the maximum float value.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  double? maximumContentWidth;
  PrintJobAttributes(
      {this.colorMode,
      this.duplex,
      this.orientation,
      this.mediaSize,
      this.resolution,
      this.margins,
      this.footerHeight,
      this.headerHeight,
      this.printableRect,
      this.paperRect,
      this.maximumContentHeight,
      this.maximumContentWidth});

  ///Gets a possible [PrintJobAttributes] instance from a [Map] value.
  static PrintJobAttributes? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = PrintJobAttributes(
      colorMode: PrintJobColorMode.fromNativeValue(map['colorMode']),
      duplex: PrintJobDuplexMode.fromNativeValue(map['duplex']),
      orientation: PrintJobOrientation.fromNativeValue(map['orientation']),
      mediaSize:
          PrintJobMediaSize.fromMap(map['mediaSize']?.cast<String, dynamic>()),
      resolution: PrintJobResolution.fromMap(
          map['resolution']?.cast<String, dynamic>()),
      margins: MapEdgeInsets.fromMap(map['margins']?.cast<String, dynamic>()),
      footerHeight: map['footerHeight'],
      headerHeight: map['headerHeight'],
      printableRect: InAppWebViewRect.fromMap(
          map['printableRect']?.cast<String, dynamic>()),
      paperRect:
          InAppWebViewRect.fromMap(map['paperRect']?.cast<String, dynamic>()),
      maximumContentHeight: map['maximumContentHeight'],
      maximumContentWidth: map['maximumContentWidth'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "colorMode": colorMode?.toNativeValue(),
      "duplex": duplex?.toNativeValue(),
      "orientation": orientation?.toNativeValue(),
      "mediaSize": mediaSize?.toMap(),
      "resolution": resolution?.toMap(),
      "margins": margins?.toMap(),
      "footerHeight": footerHeight,
      "headerHeight": headerHeight,
      "printableRect": printableRect?.toMap(),
      "paperRect": paperRect?.toMap(),
      "maximumContentHeight": maximumContentHeight,
      "maximumContentWidth": maximumContentWidth,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'PrintJobAttributes{colorMode: $colorMode, duplex: $duplex, orientation: $orientation, mediaSize: $mediaSize, resolution: $resolution, margins: $margins, footerHeight: $footerHeight, headerHeight: $headerHeight, printableRect: $printableRect, paperRect: $paperRect, maximumContentHeight: $maximumContentHeight, maximumContentWidth: $maximumContentWidth}';
  }
}
