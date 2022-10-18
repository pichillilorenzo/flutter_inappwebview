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
  ///- MacOS
  PrintJobColorMode? colorMode;

  ///The duplex mode to use for the print job.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView 23+
  ///- iOS
  ///- MacOS
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
  ///- MacOS
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
  ///- MacOS
  InAppWebViewRect? printableRect;

  ///The size of the paper used for printing.
  ///
  ///The value of this property is a rectangle that defines the size of paper chosen for the print job.
  ///The origin is always (0,0).
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
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

  ///The name of the currently selected paper size.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  String? paperName;

  ///The human-readable name of the currently selected paper size, suitable for presentation in user interfaces.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  String? localizedPaperName;

  ///The horizontal pagination mode.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  PrintJobPaginationMode? horizontalPagination;

  ///The vertical pagination to the specified mode.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  PrintJobPaginationMode? verticalPagination;

  ///The action specified for the job.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  PrintJobDisposition? jobDisposition;

  ///Indicates whether the image is centered horizontally.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  bool? isHorizontallyCentered;

  ///Indicates whether the image is centered vertically.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  bool? isVerticallyCentered;

  ///Indicates whether only the currently selected contents should be printed.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  bool? isSelectionOnly;

  ///The current scaling factor.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  double? scalingFactor;

  ///An URL containing the location to which the job file will be saved when the [jobDisposition] is [PrintJobDisposition.SAVE].
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  Uri? jobSavingURL;

  ///If `true`, produce detailed reports when an error occurs.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  bool? detailedErrorReporting;

  ///A fax number.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  String? faxNumber;

  ///If `true`, a standard header and footer are added outside the margins of each page.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  bool? headerAndFooter;

  ///If `true`, collates output.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  bool? mustCollate;

  ///The number of logical pages to be tiled horizontally on a physical sheet of paper.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  int? pagesAcross;

  ///The number of logical pages to be tiled vertically on a physical sheet of paper.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  int? pagesDown;

  ///A timestamp that specifies the time at which printing should begin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  int? time;
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
      this.maximumContentWidth,
      this.paperName,
      this.localizedPaperName,
      this.horizontalPagination,
      this.verticalPagination,
      this.jobDisposition,
      this.isHorizontallyCentered,
      this.isVerticallyCentered,
      this.isSelectionOnly,
      this.scalingFactor,
      this.jobSavingURL,
      this.detailedErrorReporting,
      this.faxNumber,
      this.headerAndFooter,
      this.mustCollate,
      this.pagesAcross,
      this.pagesDown,
      this.time});

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
      paperName: map['paperName'],
      localizedPaperName: map['localizedPaperName'],
      horizontalPagination:
          PrintJobPaginationMode.fromNativeValue(map['horizontalPagination']),
      verticalPagination:
          PrintJobPaginationMode.fromNativeValue(map['verticalPagination']),
      jobDisposition:
          PrintJobDisposition.fromNativeValue(map['jobDisposition']),
      isHorizontallyCentered: map['isHorizontallyCentered'],
      isVerticallyCentered: map['isVerticallyCentered'],
      isSelectionOnly: map['isSelectionOnly'],
      scalingFactor: map['scalingFactor'],
      jobSavingURL:
          map['jobSavingURL'] != null ? Uri.parse(map['jobSavingURL']) : null,
      detailedErrorReporting: map['detailedErrorReporting'],
      faxNumber: map['faxNumber'],
      headerAndFooter: map['headerAndFooter'],
      mustCollate: map['mustCollate'],
      pagesAcross: map['pagesAcross'],
      pagesDown: map['pagesDown'],
      time: map['time'],
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
      "paperName": paperName,
      "localizedPaperName": localizedPaperName,
      "horizontalPagination": horizontalPagination?.toNativeValue(),
      "verticalPagination": verticalPagination?.toNativeValue(),
      "jobDisposition": jobDisposition?.toNativeValue(),
      "isHorizontallyCentered": isHorizontallyCentered,
      "isVerticallyCentered": isVerticallyCentered,
      "isSelectionOnly": isSelectionOnly,
      "scalingFactor": scalingFactor,
      "jobSavingURL": jobSavingURL?.toString(),
      "detailedErrorReporting": detailedErrorReporting,
      "faxNumber": faxNumber,
      "headerAndFooter": headerAndFooter,
      "mustCollate": mustCollate,
      "pagesAcross": pagesAcross,
      "pagesDown": pagesDown,
      "time": time,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'PrintJobAttributes{colorMode: $colorMode, duplex: $duplex, orientation: $orientation, mediaSize: $mediaSize, resolution: $resolution, margins: $margins, footerHeight: $footerHeight, headerHeight: $headerHeight, printableRect: $printableRect, paperRect: $paperRect, maximumContentHeight: $maximumContentHeight, maximumContentWidth: $maximumContentWidth, paperName: $paperName, localizedPaperName: $localizedPaperName, horizontalPagination: $horizontalPagination, verticalPagination: $verticalPagination, jobDisposition: $jobDisposition, isHorizontallyCentered: $isHorizontallyCentered, isVerticallyCentered: $isVerticallyCentered, isSelectionOnly: $isSelectionOnly, scalingFactor: $scalingFactor, jobSavingURL: $jobSavingURL, detailedErrorReporting: $detailedErrorReporting, faxNumber: $faxNumber, headerAndFooter: $headerAndFooter, mustCollate: $mustCollate, pagesAcross: $pagesAcross, pagesDown: $pagesDown, time: $time}';
  }
}
