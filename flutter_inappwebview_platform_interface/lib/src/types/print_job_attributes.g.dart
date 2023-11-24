// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_attributes.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing the attributes of a [PlatformPrintJobController].
///These attributes describe how the printed content should be laid out.
class PrintJobAttributes {
  ///The color mode.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- MacOS
  PrintJobColorMode? colorMode;

  ///If `true`, produce detailed reports when an error occurs.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? detailedErrorReporting;

  ///The duplex mode to use for the print job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView 23+
  ///- iOS
  ///- MacOS
  PrintJobDuplexMode? duplex;

  ///A fax number.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  String? faxNumber;

  ///The height of the page footer.
  ///
  ///The footer is measured in points from the bottom of [printableRect] and is below the content area.
  ///The default footer height is `0.0`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  double? footerHeight;

  ///If `true`, a standard header and footer are added outside the margins of each page.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? headerAndFooter;

  ///The height of the page header.
  ///
  ///The header is measured in points from the top of [printableRect] and is above the content area.
  ///The default header height is `0.0`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  double? headerHeight;

  ///The horizontal pagination mode.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  PrintJobPaginationMode? horizontalPagination;

  ///Indicates whether the image is centered horizontally.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? isHorizontallyCentered;

  ///Indicates whether only the currently selected contents should be printed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? isSelectionOnly;

  ///Indicates whether the image is centered vertically.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? isVerticallyCentered;

  ///The action specified for the job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  PrintJobDisposition? jobDisposition;

  ///An URL containing the location to which the job file will be saved when the [jobDisposition] is [PrintJobDisposition.SAVE].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  WebUri? jobSavingURL;

  ///The human-readable name of the currently selected paper size, suitable for presentation in user interfaces.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  String? localizedPaperName;

  ///The margins for each printed page.
  ///Margins define the white space around the content where the left margin defines
  ///the amount of white space on the left of the content and so on.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  EdgeInsets? margins;

  ///The maximum height of the content area.
  ///
  ///The Print Formatter uses this value to determine where the content rectangle begins on the first page.
  ///It compares the value of this property with the printing rectangle’s height minus the header and footer heights and
  ///the top inset value; it uses the lower of the two values.
  ///The default value of this property is the maximum float value.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  double? maximumContentHeight;

  ///The maximum width of the content area.
  ///
  ///The Print Formatter uses this value to determine the maximum width of the content rectangle.
  ///It compares the value of this property with the printing rectangle’s width minus the left and right inset values and uses the lower of the two.
  ///The default value of this property is the maximum float value.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  double? maximumContentWidth;

  ///The media size.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  PrintJobMediaSize? mediaSize;

  ///If `true`, collates output.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? mustCollate;

  ///The orientation of the printed content, portrait or landscape.
  PrintJobOrientation? orientation;

  ///The number of logical pages to be tiled horizontally on a physical sheet of paper.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  int? pagesAcross;

  ///The number of logical pages to be tiled vertically on a physical sheet of paper.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  int? pagesDown;

  ///The name of the currently selected paper size.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  String? paperName;

  ///The size of the paper used for printing.
  ///
  ///The value of this property is a rectangle that defines the size of paper chosen for the print job.
  ///The origin is always (0,0).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  InAppWebViewRect? paperRect;

  ///The area in which printing can occur.
  ///
  ///The value of this property is a rectangle that defines the area in which the printer can print content.
  ///Sometimes this is referred to as the imageable area of the paper.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  InAppWebViewRect? printableRect;

  ///The supported resolution in DPI (dots per inch).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  PrintJobResolution? resolution;

  ///The current scaling factor.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  double? scalingFactor;

  ///A timestamp that specifies the time at which printing should begin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  int? time;

  ///The vertical pagination to the specified mode.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  PrintJobPaginationMode? verticalPagination;
  PrintJobAttributes(
      {this.colorMode,
      this.detailedErrorReporting,
      this.duplex,
      this.faxNumber,
      this.footerHeight,
      this.headerAndFooter,
      this.headerHeight,
      this.horizontalPagination,
      this.isHorizontallyCentered,
      this.isSelectionOnly,
      this.isVerticallyCentered,
      this.jobDisposition,
      this.jobSavingURL,
      this.localizedPaperName,
      this.margins,
      this.maximumContentHeight,
      this.maximumContentWidth,
      this.mediaSize,
      this.mustCollate,
      this.orientation,
      this.pagesAcross,
      this.pagesDown,
      this.paperName,
      this.paperRect,
      this.printableRect,
      this.resolution,
      this.scalingFactor,
      this.time,
      this.verticalPagination});

  ///Gets a possible [PrintJobAttributes] instance from a [Map] value.
  static PrintJobAttributes? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = PrintJobAttributes(
      colorMode: PrintJobColorMode.fromNativeValue(map['colorMode']),
      detailedErrorReporting: map['detailedErrorReporting'],
      duplex: PrintJobDuplexMode.fromNativeValue(map['duplex']),
      faxNumber: map['faxNumber'],
      footerHeight: map['footerHeight'],
      headerAndFooter: map['headerAndFooter'],
      headerHeight: map['headerHeight'],
      horizontalPagination:
          PrintJobPaginationMode.fromNativeValue(map['horizontalPagination']),
      isHorizontallyCentered: map['isHorizontallyCentered'],
      isSelectionOnly: map['isSelectionOnly'],
      isVerticallyCentered: map['isVerticallyCentered'],
      jobDisposition:
          PrintJobDisposition.fromNativeValue(map['jobDisposition']),
      jobSavingURL:
          map['jobSavingURL'] != null ? WebUri(map['jobSavingURL']) : null,
      localizedPaperName: map['localizedPaperName'],
      margins: MapEdgeInsets.fromMap(map['margins']?.cast<String, dynamic>()),
      maximumContentHeight: map['maximumContentHeight'],
      maximumContentWidth: map['maximumContentWidth'],
      mediaSize:
          PrintJobMediaSize.fromMap(map['mediaSize']?.cast<String, dynamic>()),
      mustCollate: map['mustCollate'],
      orientation: PrintJobOrientation.fromNativeValue(map['orientation']),
      pagesAcross: map['pagesAcross'],
      pagesDown: map['pagesDown'],
      paperName: map['paperName'],
      paperRect:
          InAppWebViewRect.fromMap(map['paperRect']?.cast<String, dynamic>()),
      printableRect: InAppWebViewRect.fromMap(
          map['printableRect']?.cast<String, dynamic>()),
      resolution: PrintJobResolution.fromMap(
          map['resolution']?.cast<String, dynamic>()),
      scalingFactor: map['scalingFactor'],
      time: map['time'],
      verticalPagination:
          PrintJobPaginationMode.fromNativeValue(map['verticalPagination']),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "colorMode": colorMode?.toNativeValue(),
      "detailedErrorReporting": detailedErrorReporting,
      "duplex": duplex?.toNativeValue(),
      "faxNumber": faxNumber,
      "footerHeight": footerHeight,
      "headerAndFooter": headerAndFooter,
      "headerHeight": headerHeight,
      "horizontalPagination": horizontalPagination?.toNativeValue(),
      "isHorizontallyCentered": isHorizontallyCentered,
      "isSelectionOnly": isSelectionOnly,
      "isVerticallyCentered": isVerticallyCentered,
      "jobDisposition": jobDisposition?.toNativeValue(),
      "jobSavingURL": jobSavingURL?.toString(),
      "localizedPaperName": localizedPaperName,
      "margins": margins?.toMap(),
      "maximumContentHeight": maximumContentHeight,
      "maximumContentWidth": maximumContentWidth,
      "mediaSize": mediaSize?.toMap(),
      "mustCollate": mustCollate,
      "orientation": orientation?.toNativeValue(),
      "pagesAcross": pagesAcross,
      "pagesDown": pagesDown,
      "paperName": paperName,
      "paperRect": paperRect?.toMap(),
      "printableRect": printableRect?.toMap(),
      "resolution": resolution?.toMap(),
      "scalingFactor": scalingFactor,
      "time": time,
      "verticalPagination": verticalPagination?.toNativeValue(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'PrintJobAttributes{colorMode: $colorMode, detailedErrorReporting: $detailedErrorReporting, duplex: $duplex, faxNumber: $faxNumber, footerHeight: $footerHeight, headerAndFooter: $headerAndFooter, headerHeight: $headerHeight, horizontalPagination: $horizontalPagination, isHorizontallyCentered: $isHorizontallyCentered, isSelectionOnly: $isSelectionOnly, isVerticallyCentered: $isVerticallyCentered, jobDisposition: $jobDisposition, jobSavingURL: $jobSavingURL, localizedPaperName: $localizedPaperName, margins: $margins, maximumContentHeight: $maximumContentHeight, maximumContentWidth: $maximumContentWidth, mediaSize: $mediaSize, mustCollate: $mustCollate, orientation: $orientation, pagesAcross: $pagesAcross, pagesDown: $pagesDown, paperName: $paperName, paperRect: $paperRect, printableRect: $printableRect, resolution: $resolution, scalingFactor: $scalingFactor, time: $time, verticalPagination: $verticalPagination}';
  }
}
