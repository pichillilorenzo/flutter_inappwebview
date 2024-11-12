// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_settings.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the settings of a [PlatformPrintJobController].
class PrintJobSettings {
  ///`true` to animate the display of the sheet, `false` to display the sheet immediately.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  bool? animated;

  ///Whether the print operation should spawn a separate thread in which to run itself.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? canSpawnSeparateThread;

  ///The color mode.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- MacOS
  PrintJobColorMode? colorMode;

  ///How many copies to print.
  ///The default value is `1`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  int? copies;

  ///If `true`, produce detailed reports when an error occurs.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? detailedErrorReporting;

  ///The duplex mode to use for the print job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView 23+
  ///- iOS
  PrintJobDuplexMode? duplexMode;

  ///A fax number.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  String? faxNumber;

  ///An integer value that specifies the first page in the print job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  int? firstPage;

  ///The height of the page footer.
  ///
  ///The footer is measured in points from the bottom of [printableRect] and is below the content area.
  ///The default footer height is `0.0`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  double? footerHeight;

  ///Force rendering quality.
  ///
  ///**NOTE for iOS**: available only on iOS 14.5+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  PrintJobRenderingQuality? forceRenderingQuality;

  ///Set this to `true` to handle the [PlatformPrintJobController].
  ///Otherwise, it will be handled and disposed automatically by the system.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  bool? handledByClient;

  ///If `true`, a standard header and footer are added outside the margins of each page.
  ///The default value is `true`.
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
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? isHorizontallyCentered;

  ///Indicates whether the image is centered vertically.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? isVerticallyCentered;

  ///The action specified for the job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  PrintJobDisposition? jobDisposition;

  ///The name of the print job.
  ///An application should set this property to a name appropriate to the content being printed.
  ///The default job name is the current webpage title concatenated with the "Document" word at the end.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  String? jobName;

  ///An URL containing the location to which the job file will be saved when the [jobDisposition] is [PrintJobDisposition.SAVE].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  WebUri? jobSavingURL;

  ///An integer value that specifies the last page in the print job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  int? lastPage;

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

  ///The number of pages to render.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  int? numberOfPages;

  ///The orientation of the printed content, portrait or landscape.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  PrintJobOrientation? orientation;

  ///The kind of printable content.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  PrintJobOutputType? outputType;

  ///The print order for the pages of the operation.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  PrintJobPageOrder? pageOrder;

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

  ///The supported resolution in DPI (dots per inch).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  PrintJobResolution? resolution;

  ///The current scaling factor. From `0.0` to `1.0`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  double? scalingFactor;

  ///A Boolean value that determines whether the printing options include the number of copies.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  bool? showsNumberOfCopies;

  ///A Boolean value that determines whether the Print panel includes a set of fields for manipulating the range of pages being printed.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? showsPageRange;

  ///A Boolean value that determines whether the Print panel includes a separate accessory view for manipulating the paper size, orientation, and scaling attributes.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? showsPageSetupAccessory;

  ///A Boolean value that determines whether the printing options include the paper orientation control when available.
  ///The default value is `true`.
  ///
  ///**NOTE for iOS**: available only on iOS 15.0+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  bool? showsPaperOrientation;

  ///A Boolean value that determines whether the paper selection menu displays.
  ///The default value of this property is `false`.
  ///Setting the value to `true` enables a paper selection menu on printers that support different types of paper and have more than one paper type loaded.
  ///On printers where only one paper type is available, no paper selection menu is displayed, regardless of the value of this property.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  bool? showsPaperSelectionForLoadedPapers;

  ///A Boolean value that determines whether the print panel includes a control for manipulating the paper size of the printer.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? showsPaperSize;

  ///A Boolean value that determines whether the Print panel displays a built-in preview of the document contents.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? showsPreview;

  ///A Boolean value that determines whether the print operation displays a print panel.
  ///The default value is `true`.
  ///
  ///This property does not affect the display of a progress panel;
  ///that operation is controlled by the [showsProgressPanel] property.
  ///Operations that generate EPS or PDF data do no display a progress panel, regardless of the value in the flag parameter.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? showsPrintPanel;

  ///A Boolean value that determines whether the Print panel includes an additional selection option for paper range.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? showsPrintSelection;

  ///A Boolean value that determines whether the print operation displays a progress panel.
  ///The default value is `true`.
  ///
  ///This property does not affect the display of a print panel;
  ///that operation is controlled by the [showsPrintPanel] property.
  ///Operations that generate EPS or PDF data do no display a progress panel, regardless of the value in the flag parameter.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? showsProgressPanel;

  ///A Boolean value that determines whether the Print panel includes a control for scaling the printed output.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? showsScaling;

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
  PrintJobSettings(
      {this.animated = true,
      this.canSpawnSeparateThread = true,
      this.colorMode,
      this.copies = 1,
      this.detailedErrorReporting = false,
      this.duplexMode,
      this.faxNumber,
      this.firstPage,
      this.footerHeight,
      this.forceRenderingQuality,
      this.handledByClient = false,
      this.headerAndFooter = true,
      this.headerHeight,
      this.horizontalPagination,
      this.isHorizontallyCentered = true,
      this.isVerticallyCentered = true,
      this.jobDisposition,
      this.jobName,
      this.jobSavingURL,
      this.lastPage,
      this.margins,
      this.maximumContentHeight,
      this.maximumContentWidth,
      this.mediaSize,
      this.mustCollate,
      this.numberOfPages,
      this.orientation,
      this.outputType,
      this.pageOrder,
      this.pagesAcross,
      this.pagesDown,
      this.paperName,
      this.resolution,
      this.scalingFactor,
      this.showsNumberOfCopies = true,
      this.showsPageRange = true,
      this.showsPageSetupAccessory = true,
      this.showsPaperOrientation = true,
      this.showsPaperSelectionForLoadedPapers = false,
      this.showsPaperSize = true,
      this.showsPreview = true,
      this.showsPrintPanel = true,
      this.showsPrintSelection = true,
      this.showsProgressPanel = true,
      this.showsScaling = true,
      this.time,
      this.verticalPagination});

  ///Gets a possible [PrintJobSettings] instance from a [Map] value.
  static PrintJobSettings? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = PrintJobSettings(
      colorMode: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          PrintJobColorMode.fromNativeValue(map['colorMode']),
        EnumMethod.value => PrintJobColorMode.fromValue(map['colorMode']),
        EnumMethod.name => PrintJobColorMode.byName(map['colorMode'])
      },
      duplexMode: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          PrintJobDuplexMode.fromNativeValue(map['duplexMode']),
        EnumMethod.value => PrintJobDuplexMode.fromValue(map['duplexMode']),
        EnumMethod.name => PrintJobDuplexMode.byName(map['duplexMode'])
      },
      faxNumber: map['faxNumber'],
      firstPage: map['firstPage'],
      footerHeight: map['footerHeight'],
      forceRenderingQuality: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => PrintJobRenderingQuality.fromNativeValue(
            map['forceRenderingQuality']),
        EnumMethod.value =>
          PrintJobRenderingQuality.fromValue(map['forceRenderingQuality']),
        EnumMethod.name =>
          PrintJobRenderingQuality.byName(map['forceRenderingQuality'])
      },
      headerHeight: map['headerHeight'],
      horizontalPagination: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          PrintJobPaginationMode.fromNativeValue(map['horizontalPagination']),
        EnumMethod.value =>
          PrintJobPaginationMode.fromValue(map['horizontalPagination']),
        EnumMethod.name =>
          PrintJobPaginationMode.byName(map['horizontalPagination'])
      },
      jobDisposition: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          PrintJobDisposition.fromNativeValue(map['jobDisposition']),
        EnumMethod.value =>
          PrintJobDisposition.fromValue(map['jobDisposition']),
        EnumMethod.name => PrintJobDisposition.byName(map['jobDisposition'])
      },
      jobName: map['jobName'],
      jobSavingURL:
          map['jobSavingURL'] != null ? WebUri(map['jobSavingURL']) : null,
      lastPage: map['lastPage'],
      margins: MapEdgeInsets.fromMap(map['margins']?.cast<String, dynamic>()),
      maximumContentHeight: map['maximumContentHeight'],
      maximumContentWidth: map['maximumContentWidth'],
      mediaSize: PrintJobMediaSize.fromMap(
          map['mediaSize']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
      mustCollate: map['mustCollate'],
      numberOfPages: map['numberOfPages'],
      orientation: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          PrintJobOrientation.fromNativeValue(map['orientation']),
        EnumMethod.value => PrintJobOrientation.fromValue(map['orientation']),
        EnumMethod.name => PrintJobOrientation.byName(map['orientation'])
      },
      outputType: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          PrintJobOutputType.fromNativeValue(map['outputType']),
        EnumMethod.value => PrintJobOutputType.fromValue(map['outputType']),
        EnumMethod.name => PrintJobOutputType.byName(map['outputType'])
      },
      pageOrder: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          PrintJobPageOrder.fromNativeValue(map['pageOrder']),
        EnumMethod.value => PrintJobPageOrder.fromValue(map['pageOrder']),
        EnumMethod.name => PrintJobPageOrder.byName(map['pageOrder'])
      },
      pagesAcross: map['pagesAcross'],
      pagesDown: map['pagesDown'],
      paperName: map['paperName'],
      resolution: PrintJobResolution.fromMap(
          map['resolution']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
      scalingFactor: map['scalingFactor'],
      time: map['time'],
      verticalPagination: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          PrintJobPaginationMode.fromNativeValue(map['verticalPagination']),
        EnumMethod.value =>
          PrintJobPaginationMode.fromValue(map['verticalPagination']),
        EnumMethod.name =>
          PrintJobPaginationMode.byName(map['verticalPagination'])
      },
    );
    instance.animated = map['animated'];
    instance.canSpawnSeparateThread = map['canSpawnSeparateThread'];
    instance.copies = map['copies'];
    instance.detailedErrorReporting = map['detailedErrorReporting'];
    instance.handledByClient = map['handledByClient'];
    instance.headerAndFooter = map['headerAndFooter'];
    instance.isHorizontallyCentered = map['isHorizontallyCentered'];
    instance.isVerticallyCentered = map['isVerticallyCentered'];
    instance.showsNumberOfCopies = map['showsNumberOfCopies'];
    instance.showsPageRange = map['showsPageRange'];
    instance.showsPageSetupAccessory = map['showsPageSetupAccessory'];
    instance.showsPaperOrientation = map['showsPaperOrientation'];
    instance.showsPaperSelectionForLoadedPapers =
        map['showsPaperSelectionForLoadedPapers'];
    instance.showsPaperSize = map['showsPaperSize'];
    instance.showsPreview = map['showsPreview'];
    instance.showsPrintPanel = map['showsPrintPanel'];
    instance.showsPrintSelection = map['showsPrintSelection'];
    instance.showsProgressPanel = map['showsProgressPanel'];
    instance.showsScaling = map['showsScaling'];
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "animated": animated,
      "canSpawnSeparateThread": canSpawnSeparateThread,
      "colorMode": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => colorMode?.toNativeValue(),
        EnumMethod.value => colorMode?.toValue(),
        EnumMethod.name => colorMode?.name()
      },
      "copies": copies,
      "detailedErrorReporting": detailedErrorReporting,
      "duplexMode": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => duplexMode?.toNativeValue(),
        EnumMethod.value => duplexMode?.toValue(),
        EnumMethod.name => duplexMode?.name()
      },
      "faxNumber": faxNumber,
      "firstPage": firstPage,
      "footerHeight": footerHeight,
      "forceRenderingQuality": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => forceRenderingQuality?.toNativeValue(),
        EnumMethod.value => forceRenderingQuality?.toValue(),
        EnumMethod.name => forceRenderingQuality?.name()
      },
      "handledByClient": handledByClient,
      "headerAndFooter": headerAndFooter,
      "headerHeight": headerHeight,
      "horizontalPagination": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => horizontalPagination?.toNativeValue(),
        EnumMethod.value => horizontalPagination?.toValue(),
        EnumMethod.name => horizontalPagination?.name()
      },
      "isHorizontallyCentered": isHorizontallyCentered,
      "isVerticallyCentered": isVerticallyCentered,
      "jobDisposition": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => jobDisposition?.toNativeValue(),
        EnumMethod.value => jobDisposition?.toValue(),
        EnumMethod.name => jobDisposition?.name()
      },
      "jobName": jobName,
      "jobSavingURL": jobSavingURL?.toString(),
      "lastPage": lastPage,
      "margins": margins?.toMap(),
      "maximumContentHeight": maximumContentHeight,
      "maximumContentWidth": maximumContentWidth,
      "mediaSize": mediaSize?.toMap(enumMethod: enumMethod),
      "mustCollate": mustCollate,
      "numberOfPages": numberOfPages,
      "orientation": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => orientation?.toNativeValue(),
        EnumMethod.value => orientation?.toValue(),
        EnumMethod.name => orientation?.name()
      },
      "outputType": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => outputType?.toNativeValue(),
        EnumMethod.value => outputType?.toValue(),
        EnumMethod.name => outputType?.name()
      },
      "pageOrder": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => pageOrder?.toNativeValue(),
        EnumMethod.value => pageOrder?.toValue(),
        EnumMethod.name => pageOrder?.name()
      },
      "pagesAcross": pagesAcross,
      "pagesDown": pagesDown,
      "paperName": paperName,
      "resolution": resolution?.toMap(enumMethod: enumMethod),
      "scalingFactor": scalingFactor,
      "showsNumberOfCopies": showsNumberOfCopies,
      "showsPageRange": showsPageRange,
      "showsPageSetupAccessory": showsPageSetupAccessory,
      "showsPaperOrientation": showsPaperOrientation,
      "showsPaperSelectionForLoadedPapers": showsPaperSelectionForLoadedPapers,
      "showsPaperSize": showsPaperSize,
      "showsPreview": showsPreview,
      "showsPrintPanel": showsPrintPanel,
      "showsPrintSelection": showsPrintSelection,
      "showsProgressPanel": showsProgressPanel,
      "showsScaling": showsScaling,
      "time": time,
      "verticalPagination": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => verticalPagination?.toNativeValue(),
        EnumMethod.value => verticalPagination?.toValue(),
        EnumMethod.name => verticalPagination?.name()
      },
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  ///Returns a copy of PrintJobSettings.
  PrintJobSettings copy() {
    return PrintJobSettings.fromMap(toMap()) ?? PrintJobSettings();
  }

  @override
  String toString() {
    return 'PrintJobSettings{animated: $animated, canSpawnSeparateThread: $canSpawnSeparateThread, colorMode: $colorMode, copies: $copies, detailedErrorReporting: $detailedErrorReporting, duplexMode: $duplexMode, faxNumber: $faxNumber, firstPage: $firstPage, footerHeight: $footerHeight, forceRenderingQuality: $forceRenderingQuality, handledByClient: $handledByClient, headerAndFooter: $headerAndFooter, headerHeight: $headerHeight, horizontalPagination: $horizontalPagination, isHorizontallyCentered: $isHorizontallyCentered, isVerticallyCentered: $isVerticallyCentered, jobDisposition: $jobDisposition, jobName: $jobName, jobSavingURL: $jobSavingURL, lastPage: $lastPage, margins: $margins, maximumContentHeight: $maximumContentHeight, maximumContentWidth: $maximumContentWidth, mediaSize: $mediaSize, mustCollate: $mustCollate, numberOfPages: $numberOfPages, orientation: $orientation, outputType: $outputType, pageOrder: $pageOrder, pagesAcross: $pagesAcross, pagesDown: $pagesDown, paperName: $paperName, resolution: $resolution, scalingFactor: $scalingFactor, showsNumberOfCopies: $showsNumberOfCopies, showsPageRange: $showsPageRange, showsPageSetupAccessory: $showsPageSetupAccessory, showsPaperOrientation: $showsPaperOrientation, showsPaperSelectionForLoadedPapers: $showsPaperSelectionForLoadedPapers, showsPaperSize: $showsPaperSize, showsPreview: $showsPreview, showsPrintPanel: $showsPrintPanel, showsPrintSelection: $showsPrintSelection, showsProgressPanel: $showsProgressPanel, showsScaling: $showsScaling, time: $time, verticalPagination: $verticalPagination}';
  }
}
