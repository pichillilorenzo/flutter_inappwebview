// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_settings.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the settings of a [PlatformPrintJobController].
///
///**Officially Supported Platforms/Implementations**:
///- Android WebView
///- iOS WKWebView
///- macOS WKWebView
///- Windows WebView2
class PrintJobSettings {
  ///`true` to animate the display of the sheet, `false` to display the sheet immediately.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  bool? animated;

  ///Whether the print operation should spawn a separate thread in which to run itself.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  bool? canSpawnSeparateThread;

  ///Whether printed pages should be collated.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  bool? collate;

  ///The color mode.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- macOS WKWebView
  ///- Windows WebView2
  PrintJobColorMode? colorMode;

  ///How many copies to print.
  ///The default value is `1`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///- Windows WebView2
  int? copies;

  ///If `true`, produce detailed reports when an error occurs.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  bool? detailedErrorReporting;

  ///The duplex mode to use for the print job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 23+
  ///- iOS WKWebView
  ///- Windows WebView2
  PrintJobDuplexMode? duplexMode;

  ///A fax number.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  String? faxNumber;

  ///An integer value that specifies the first page in the print job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  int? firstPage;

  ///The height of the page footer.
  ///
  ///The footer is measured in points from the bottom of [printableRect] and is below the content area.
  ///The default footer height is `0.0`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  double? footerHeight;

  ///The URI in the footer when [shouldPrintHeaderAndFooter] is `true`.
  ///The default value is the current URI.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  String? footerUri;

  ///Force rendering quality.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 14.5+
  PrintJobRenderingQuality? forceRenderingQuality;

  ///Set this to `true` to handle the [PlatformPrintJobController].
  ///Otherwise, it will be handled and disposed automatically by the system.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  bool? handledByClient;

  ///If `true`, a standard header and footer are added outside the margins of each page.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///- Windows WebView2
  bool? headerAndFooter;

  ///The height of the page header.
  ///
  ///The header is measured in points from the top of [printableRect] and is above the content area.
  ///The default header height is `0.0`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  double? headerHeight;

  ///The title in the header when [shouldPrintHeaderAndFooter] is `true`.
  ///The default value is the title of the current document.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  String? headerTitle;

  ///The horizontal pagination mode.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  PrintJobPaginationMode? horizontalPagination;

  ///Indicates whether the image is centered horizontally.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  bool? isHorizontallyCentered;

  ///Indicates whether the image is centered vertically.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  bool? isVerticallyCentered;

  ///The action specified for the job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  PrintJobDisposition? jobDisposition;

  ///The name of the print job.
  ///An application should set this property to a name appropriate to the content being printed.
  ///The default job name is the current webpage title concatenated with the "Document" word at the end.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  String? jobName;

  ///An URL containing the location to which the job file will be saved when the [jobDisposition] is [PrintJobDisposition.SAVE].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  WebUri? jobSavingURL;

  ///An integer value that specifies the last page in the print job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  int? lastPage;

  ///The margins for each printed page.
  ///Margins define the white space around the content where the left margin defines
  ///the amount of white space on the left of the content and so on.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  EdgeInsets? margins;

  ///The maximum height of the content area.
  ///
  ///The Print Formatter uses this value to determine where the content rectangle begins on the first page.
  ///It compares the value of this property with the printing rectangle’s height minus the header and footer heights and
  ///the top inset value; it uses the lower of the two values.
  ///The default value of this property is the maximum float value.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  double? maximumContentHeight;

  ///The maximum width of the content area.
  ///
  ///The Print Formatter uses this value to determine the maximum width of the content rectangle.
  ///It compares the value of this property with the printing rectangle’s width minus the left and right inset values and uses the lower of the two.
  ///The default value of this property is the maximum float value.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  double? maximumContentWidth;

  ///The media size.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- Windows WebView2
  PrintJobMediaSize? mediaSize;

  ///If `true`, collates output.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  bool? mustCollate;

  ///The number of pages to render.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  int? numberOfPages;

  ///The orientation of the printed content, portrait or landscape.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  PrintJobOrientation? orientation;

  ///The kind of printable content.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  PrintJobOutputType? outputType;

  ///The page height in inches.
  ///The default height is 11 inches.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  double? pageHeight;

  ///The print order for the pages of the operation.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  PrintJobPageOrder? pageOrder;

  ///The page ranges to print.
  ///Pages are specified as a comma-separated list of page ranges where each page range specifies
  ///a start and end inclusive page numbers. For example "1-5, 13, 17-19".
  ///Use an empty string to specify printing all the pages.
  ///The default value is empty string.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  String? pageRanges;

  ///The page width in inches.
  ///The default width is 8.5 inches.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  double? pageWidth;

  ///The number of logical pages to be tiled horizontally on a physical sheet of paper.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  int? pagesAcross;

  ///The number of logical pages to be tiled vertically on a physical sheet of paper.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  int? pagesDown;

  ///The number of pages to print on each sheet.
  ///The value must be 1, 2, 4, 6, 9, or 16.
  ///The default value is `1`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  int? pagesPerSide;

  ///The name of the currently selected paper size.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  String? paperName;

  ///The print dialog kind to show when [showUI] is `true`.
  ///The default value is [PrintJobDialogKind.BROWSER].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  PrintJobDialogKind? printDialogKind;

  ///The name of the printer to use.
  ///Defaults to the user default printer.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  String? printerName;

  ///The supported resolution in DPI (dots per inch).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  PrintJobResolution? resolution;

  ///The current scaling factor. From `0.0` to `1.0`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///- Windows WebView2
  double? scalingFactor;

  ///`true` if background colors and images should be printed.
  ///The default is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  bool? shouldPrintBackgrounds;

  ///`true` if header and footer should be printed.
  ///The default is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  bool? shouldPrintHeaderAndFooter;

  ///`true` if only the current selection of HTML in the document should be printed.
  ///The default is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  bool? shouldPrintSelectionOnly;

  ///A Boolean value that determines whether the print UI should be shown.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  bool? showUI;

  ///A Boolean value that determines whether the printing options include the number of copies.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  bool? showsNumberOfCopies;

  ///A Boolean value that determines whether the Print panel includes a set of fields for manipulating the range of pages being printed.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  bool? showsPageRange;

  ///A Boolean value that determines whether the Print panel includes a separate accessory view for manipulating the paper size, orientation, and scaling attributes.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  bool? showsPageSetupAccessory;

  ///A Boolean value that determines whether the printing options include the paper orientation control when available.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+
  ///- macOS WKWebView
  bool? showsPaperOrientation;

  ///A Boolean value that determines whether the paper selection menu displays.
  ///The default value of this property is `false`.
  ///Setting the value to `true` enables a paper selection menu on printers that support different types of paper and have more than one paper type loaded.
  ///On printers where only one paper type is available, no paper selection menu is displayed, regardless of the value of this property.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  bool? showsPaperSelectionForLoadedPapers;

  ///A Boolean value that determines whether the print panel includes a control for manipulating the paper size of the printer.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  bool? showsPaperSize;

  ///A Boolean value that determines whether the Print panel displays a built-in preview of the document contents.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  bool? showsPreview;

  ///A Boolean value that determines whether the print operation displays a print panel.
  ///The default value is `true`.
  ///
  ///This property does not affect the display of a progress panel;
  ///that operation is controlled by the [showsProgressPanel] property.
  ///Operations that generate EPS or PDF data do no display a progress panel, regardless of the value in the flag parameter.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  bool? showsPrintPanel;

  ///A Boolean value that determines whether the Print panel includes an additional selection option for paper range.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  bool? showsPrintSelection;

  ///A Boolean value that determines whether the print operation displays a progress panel.
  ///The default value is `true`.
  ///
  ///This property does not affect the display of a print panel;
  ///that operation is controlled by the [showsPrintPanel] property.
  ///Operations that generate EPS or PDF data do no display a progress panel, regardless of the value in the flag parameter.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  bool? showsProgressPanel;

  ///A Boolean value that determines whether the Print panel includes a control for scaling the printed output.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  bool? showsScaling;

  ///A timestamp that specifies the time at which printing should begin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  int? time;

  ///The vertical pagination to the specified mode.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  PrintJobPaginationMode? verticalPagination;

  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  PrintJobSettings({
    this.animated = true,
    this.canSpawnSeparateThread = true,
    this.collate,
    this.colorMode,
    this.copies = 1,
    this.detailedErrorReporting = false,
    this.duplexMode,
    this.faxNumber,
    this.firstPage,
    this.footerHeight,
    this.footerUri,
    this.forceRenderingQuality,
    this.handledByClient = false,
    this.headerAndFooter = true,
    this.headerHeight,
    this.headerTitle,
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
    this.pageHeight,
    this.pageOrder,
    this.pageRanges,
    this.pageWidth,
    this.pagesAcross,
    this.pagesDown,
    this.pagesPerSide,
    this.paperName,
    PrintJobDialogKind? printDialogKind,
    this.printerName,
    this.resolution,
    this.scalingFactor,
    this.shouldPrintBackgrounds,
    this.shouldPrintHeaderAndFooter,
    this.shouldPrintSelectionOnly,
    this.showUI = true,
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
    this.verticalPagination,
  }) : printDialogKind = printDialogKind ?? PrintJobDialogKind.BROWSER;

  ///Gets a possible [PrintJobSettings] instance from a [Map] value.
  static PrintJobSettings? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = PrintJobSettings(
      collate: map['collate'],
      colorMode: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => PrintJobColorMode.fromNativeValue(
          map['colorMode'],
        ),
        EnumMethod.value => PrintJobColorMode.fromValue(map['colorMode']),
        EnumMethod.name => PrintJobColorMode.byName(map['colorMode']),
      },
      duplexMode: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => PrintJobDuplexMode.fromNativeValue(
          map['duplexMode'],
        ),
        EnumMethod.value => PrintJobDuplexMode.fromValue(map['duplexMode']),
        EnumMethod.name => PrintJobDuplexMode.byName(map['duplexMode']),
      },
      faxNumber: map['faxNumber'],
      firstPage: map['firstPage'],
      footerHeight: map['footerHeight'],
      footerUri: map['footerUri'],
      forceRenderingQuality: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => PrintJobRenderingQuality.fromNativeValue(
          map['forceRenderingQuality'],
        ),
        EnumMethod.value => PrintJobRenderingQuality.fromValue(
          map['forceRenderingQuality'],
        ),
        EnumMethod.name => PrintJobRenderingQuality.byName(
          map['forceRenderingQuality'],
        ),
      },
      headerHeight: map['headerHeight'],
      headerTitle: map['headerTitle'],
      horizontalPagination: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => PrintJobPaginationMode.fromNativeValue(
          map['horizontalPagination'],
        ),
        EnumMethod.value => PrintJobPaginationMode.fromValue(
          map['horizontalPagination'],
        ),
        EnumMethod.name => PrintJobPaginationMode.byName(
          map['horizontalPagination'],
        ),
      },
      jobDisposition: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => PrintJobDisposition.fromNativeValue(
          map['jobDisposition'],
        ),
        EnumMethod.value => PrintJobDisposition.fromValue(
          map['jobDisposition'],
        ),
        EnumMethod.name => PrintJobDisposition.byName(map['jobDisposition']),
      },
      jobName: map['jobName'],
      jobSavingURL: map['jobSavingURL'] != null
          ? WebUri(map['jobSavingURL'])
          : null,
      lastPage: map['lastPage'],
      margins: MapEdgeInsets.fromMap(map['margins']?.cast<String, dynamic>()),
      maximumContentHeight: map['maximumContentHeight'],
      maximumContentWidth: map['maximumContentWidth'],
      mediaSize: PrintJobMediaSize.fromMap(
        map['mediaSize']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
      mustCollate: map['mustCollate'],
      numberOfPages: map['numberOfPages'],
      orientation: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => PrintJobOrientation.fromNativeValue(
          map['orientation'],
        ),
        EnumMethod.value => PrintJobOrientation.fromValue(map['orientation']),
        EnumMethod.name => PrintJobOrientation.byName(map['orientation']),
      },
      outputType: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => PrintJobOutputType.fromNativeValue(
          map['outputType'],
        ),
        EnumMethod.value => PrintJobOutputType.fromValue(map['outputType']),
        EnumMethod.name => PrintJobOutputType.byName(map['outputType']),
      },
      pageHeight: map['pageHeight'],
      pageOrder: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => PrintJobPageOrder.fromNativeValue(
          map['pageOrder'],
        ),
        EnumMethod.value => PrintJobPageOrder.fromValue(map['pageOrder']),
        EnumMethod.name => PrintJobPageOrder.byName(map['pageOrder']),
      },
      pageRanges: map['pageRanges'],
      pageWidth: map['pageWidth'],
      pagesAcross: map['pagesAcross'],
      pagesDown: map['pagesDown'],
      pagesPerSide: map['pagesPerSide'],
      paperName: map['paperName'],
      printerName: map['printerName'],
      resolution: PrintJobResolution.fromMap(
        map['resolution']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
      scalingFactor: map['scalingFactor'],
      shouldPrintBackgrounds: map['shouldPrintBackgrounds'],
      shouldPrintHeaderAndFooter: map['shouldPrintHeaderAndFooter'],
      shouldPrintSelectionOnly: map['shouldPrintSelectionOnly'],
      time: map['time'],
      verticalPagination: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => PrintJobPaginationMode.fromNativeValue(
          map['verticalPagination'],
        ),
        EnumMethod.value => PrintJobPaginationMode.fromValue(
          map['verticalPagination'],
        ),
        EnumMethod.name => PrintJobPaginationMode.byName(
          map['verticalPagination'],
        ),
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
    instance.printDialogKind = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue => PrintJobDialogKind.fromNativeValue(
        map['printDialogKind'],
      ),
      EnumMethod.value => PrintJobDialogKind.fromValue(map['printDialogKind']),
      EnumMethod.name => PrintJobDialogKind.byName(map['printDialogKind']),
    };
    instance.showUI = map['showUI'];
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

  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isPropertySupported(
    PrintJobSettingsProperty property, {
    TargetPlatform? platform,
  }) => _PrintJobSettingsPropertySupported.isPropertySupported(
    property,
    platform: platform,
  );

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "animated": animated,
      "canSpawnSeparateThread": canSpawnSeparateThread,
      "collate": collate,
      "colorMode": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => colorMode?.toNativeValue(),
        EnumMethod.value => colorMode?.toValue(),
        EnumMethod.name => colorMode?.name(),
      },
      "copies": copies,
      "detailedErrorReporting": detailedErrorReporting,
      "duplexMode": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => duplexMode?.toNativeValue(),
        EnumMethod.value => duplexMode?.toValue(),
        EnumMethod.name => duplexMode?.name(),
      },
      "faxNumber": faxNumber,
      "firstPage": firstPage,
      "footerHeight": footerHeight,
      "footerUri": footerUri,
      "forceRenderingQuality": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => forceRenderingQuality?.toNativeValue(),
        EnumMethod.value => forceRenderingQuality?.toValue(),
        EnumMethod.name => forceRenderingQuality?.name(),
      },
      "handledByClient": handledByClient,
      "headerAndFooter": headerAndFooter,
      "headerHeight": headerHeight,
      "headerTitle": headerTitle,
      "horizontalPagination": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => horizontalPagination?.toNativeValue(),
        EnumMethod.value => horizontalPagination?.toValue(),
        EnumMethod.name => horizontalPagination?.name(),
      },
      "isHorizontallyCentered": isHorizontallyCentered,
      "isVerticallyCentered": isVerticallyCentered,
      "jobDisposition": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => jobDisposition?.toNativeValue(),
        EnumMethod.value => jobDisposition?.toValue(),
        EnumMethod.name => jobDisposition?.name(),
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
        EnumMethod.name => orientation?.name(),
      },
      "outputType": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => outputType?.toNativeValue(),
        EnumMethod.value => outputType?.toValue(),
        EnumMethod.name => outputType?.name(),
      },
      "pageHeight": pageHeight,
      "pageOrder": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => pageOrder?.toNativeValue(),
        EnumMethod.value => pageOrder?.toValue(),
        EnumMethod.name => pageOrder?.name(),
      },
      "pageRanges": pageRanges,
      "pageWidth": pageWidth,
      "pagesAcross": pagesAcross,
      "pagesDown": pagesDown,
      "pagesPerSide": pagesPerSide,
      "paperName": paperName,
      "printDialogKind": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => printDialogKind?.toNativeValue(),
        EnumMethod.value => printDialogKind?.toValue(),
        EnumMethod.name => printDialogKind?.name(),
      },
      "printerName": printerName,
      "resolution": resolution?.toMap(enumMethod: enumMethod),
      "scalingFactor": scalingFactor,
      "shouldPrintBackgrounds": shouldPrintBackgrounds,
      "shouldPrintHeaderAndFooter": shouldPrintHeaderAndFooter,
      "shouldPrintSelectionOnly": shouldPrintSelectionOnly,
      "showUI": showUI,
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
        EnumMethod.name => verticalPagination?.name(),
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
    return 'PrintJobSettings{animated: $animated, canSpawnSeparateThread: $canSpawnSeparateThread, collate: $collate, colorMode: $colorMode, copies: $copies, detailedErrorReporting: $detailedErrorReporting, duplexMode: $duplexMode, faxNumber: $faxNumber, firstPage: $firstPage, footerHeight: $footerHeight, footerUri: $footerUri, forceRenderingQuality: $forceRenderingQuality, handledByClient: $handledByClient, headerAndFooter: $headerAndFooter, headerHeight: $headerHeight, headerTitle: $headerTitle, horizontalPagination: $horizontalPagination, isHorizontallyCentered: $isHorizontallyCentered, isVerticallyCentered: $isVerticallyCentered, jobDisposition: $jobDisposition, jobName: $jobName, jobSavingURL: $jobSavingURL, lastPage: $lastPage, margins: $margins, maximumContentHeight: $maximumContentHeight, maximumContentWidth: $maximumContentWidth, mediaSize: $mediaSize, mustCollate: $mustCollate, numberOfPages: $numberOfPages, orientation: $orientation, outputType: $outputType, pageHeight: $pageHeight, pageOrder: $pageOrder, pageRanges: $pageRanges, pageWidth: $pageWidth, pagesAcross: $pagesAcross, pagesDown: $pagesDown, pagesPerSide: $pagesPerSide, paperName: $paperName, printDialogKind: $printDialogKind, printerName: $printerName, resolution: $resolution, scalingFactor: $scalingFactor, shouldPrintBackgrounds: $shouldPrintBackgrounds, shouldPrintHeaderAndFooter: $shouldPrintHeaderAndFooter, shouldPrintSelectionOnly: $shouldPrintSelectionOnly, showUI: $showUI, showsNumberOfCopies: $showsNumberOfCopies, showsPageRange: $showsPageRange, showsPageSetupAccessory: $showsPageSetupAccessory, showsPaperOrientation: $showsPaperOrientation, showsPaperSelectionForLoadedPapers: $showsPaperSelectionForLoadedPapers, showsPaperSize: $showsPaperSize, showsPreview: $showsPreview, showsPrintPanel: $showsPrintPanel, showsPrintSelection: $showsPrintSelection, showsProgressPanel: $showsProgressPanel, showsScaling: $showsScaling, time: $time, verticalPagination: $verticalPagination}';
  }
}

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

///List of [PrintJobSettings]'s properties that can be used to check i they are supported or not by the current platform.
enum PrintJobSettingsProperty {
  ///Can be used to check if the [PrintJobSettings.animated] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.animated.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  animated,

  ///Can be used to check if the [PrintJobSettings.canSpawnSeparateThread] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.canSpawnSeparateThread.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  canSpawnSeparateThread,

  ///Can be used to check if the [PrintJobSettings.collate] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.collate.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  collate,

  ///Can be used to check if the [PrintJobSettings.colorMode] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.colorMode.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  colorMode,

  ///Can be used to check if the [PrintJobSettings.copies] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.copies.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///- Windows WebView2
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  copies,

  ///Can be used to check if the [PrintJobSettings.detailedErrorReporting] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.detailedErrorReporting.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  detailedErrorReporting,

  ///Can be used to check if the [PrintJobSettings.duplexMode] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.duplexMode.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 23+
  ///- iOS WKWebView
  ///- Windows WebView2
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  duplexMode,

  ///Can be used to check if the [PrintJobSettings.faxNumber] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.faxNumber.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  faxNumber,

  ///Can be used to check if the [PrintJobSettings.firstPage] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.firstPage.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  firstPage,

  ///Can be used to check if the [PrintJobSettings.footerHeight] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.footerHeight.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  footerHeight,

  ///Can be used to check if the [PrintJobSettings.footerUri] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.footerUri.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  footerUri,

  ///Can be used to check if the [PrintJobSettings.forceRenderingQuality] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.forceRenderingQuality.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 14.5+
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  forceRenderingQuality,

  ///Can be used to check if the [PrintJobSettings.handledByClient] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.handledByClient.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  handledByClient,

  ///Can be used to check if the [PrintJobSettings.headerAndFooter] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.headerAndFooter.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///- Windows WebView2
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  headerAndFooter,

  ///Can be used to check if the [PrintJobSettings.headerHeight] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.headerHeight.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  headerHeight,

  ///Can be used to check if the [PrintJobSettings.headerTitle] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.headerTitle.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  headerTitle,

  ///Can be used to check if the [PrintJobSettings.horizontalPagination] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.horizontalPagination.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  horizontalPagination,

  ///Can be used to check if the [PrintJobSettings.isHorizontallyCentered] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.isHorizontallyCentered.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isHorizontallyCentered,

  ///Can be used to check if the [PrintJobSettings.isVerticallyCentered] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.isVerticallyCentered.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isVerticallyCentered,

  ///Can be used to check if the [PrintJobSettings.jobDisposition] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.jobDisposition.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  jobDisposition,

  ///Can be used to check if the [PrintJobSettings.jobName] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.jobName.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  jobName,

  ///Can be used to check if the [PrintJobSettings.jobSavingURL] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.jobSavingURL.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  jobSavingURL,

  ///Can be used to check if the [PrintJobSettings.lastPage] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.lastPage.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  lastPage,

  ///Can be used to check if the [PrintJobSettings.margins] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.margins.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  margins,

  ///Can be used to check if the [PrintJobSettings.maximumContentHeight] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.maximumContentHeight.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  maximumContentHeight,

  ///Can be used to check if the [PrintJobSettings.maximumContentWidth] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.maximumContentWidth.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  maximumContentWidth,

  ///Can be used to check if the [PrintJobSettings.mediaSize] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.mediaSize.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- Windows WebView2
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  mediaSize,

  ///Can be used to check if the [PrintJobSettings.mustCollate] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.mustCollate.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  mustCollate,

  ///Can be used to check if the [PrintJobSettings.numberOfPages] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.numberOfPages.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  numberOfPages,

  ///Can be used to check if the [PrintJobSettings.orientation] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.orientation.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  orientation,

  ///Can be used to check if the [PrintJobSettings.outputType] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.outputType.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  outputType,

  ///Can be used to check if the [PrintJobSettings.pageHeight] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.pageHeight.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  pageHeight,

  ///Can be used to check if the [PrintJobSettings.pageOrder] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.pageOrder.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  pageOrder,

  ///Can be used to check if the [PrintJobSettings.pageRanges] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.pageRanges.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  pageRanges,

  ///Can be used to check if the [PrintJobSettings.pageWidth] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.pageWidth.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  pageWidth,

  ///Can be used to check if the [PrintJobSettings.pagesAcross] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.pagesAcross.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  pagesAcross,

  ///Can be used to check if the [PrintJobSettings.pagesDown] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.pagesDown.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  pagesDown,

  ///Can be used to check if the [PrintJobSettings.pagesPerSide] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.pagesPerSide.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  pagesPerSide,

  ///Can be used to check if the [PrintJobSettings.paperName] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.paperName.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  paperName,

  ///Can be used to check if the [PrintJobSettings.printDialogKind] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.printDialogKind.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  printDialogKind,

  ///Can be used to check if the [PrintJobSettings.printerName] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.printerName.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  printerName,

  ///Can be used to check if the [PrintJobSettings.resolution] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.resolution.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  resolution,

  ///Can be used to check if the [PrintJobSettings.scalingFactor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.scalingFactor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///- Windows WebView2
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  scalingFactor,

  ///Can be used to check if the [PrintJobSettings.shouldPrintBackgrounds] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.shouldPrintBackgrounds.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  shouldPrintBackgrounds,

  ///Can be used to check if the [PrintJobSettings.shouldPrintHeaderAndFooter] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.shouldPrintHeaderAndFooter.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  shouldPrintHeaderAndFooter,

  ///Can be used to check if the [PrintJobSettings.shouldPrintSelectionOnly] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.shouldPrintSelectionOnly.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  shouldPrintSelectionOnly,

  ///Can be used to check if the [PrintJobSettings.showUI] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.showUI.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  showUI,

  ///Can be used to check if the [PrintJobSettings.showsNumberOfCopies] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.showsNumberOfCopies.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  showsNumberOfCopies,

  ///Can be used to check if the [PrintJobSettings.showsPageRange] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.showsPageRange.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  showsPageRange,

  ///Can be used to check if the [PrintJobSettings.showsPageSetupAccessory] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.showsPageSetupAccessory.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  showsPageSetupAccessory,

  ///Can be used to check if the [PrintJobSettings.showsPaperOrientation] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.showsPaperOrientation.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  showsPaperOrientation,

  ///Can be used to check if the [PrintJobSettings.showsPaperSelectionForLoadedPapers] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.showsPaperSelectionForLoadedPapers.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  showsPaperSelectionForLoadedPapers,

  ///Can be used to check if the [PrintJobSettings.showsPaperSize] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.showsPaperSize.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  showsPaperSize,

  ///Can be used to check if the [PrintJobSettings.showsPreview] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.showsPreview.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  showsPreview,

  ///Can be used to check if the [PrintJobSettings.showsPrintPanel] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.showsPrintPanel.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  showsPrintPanel,

  ///Can be used to check if the [PrintJobSettings.showsPrintSelection] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.showsPrintSelection.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  showsPrintSelection,

  ///Can be used to check if the [PrintJobSettings.showsProgressPanel] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.showsProgressPanel.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  showsProgressPanel,

  ///Can be used to check if the [PrintJobSettings.showsScaling] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.showsScaling.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  showsScaling,

  ///Can be used to check if the [PrintJobSettings.time] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.time.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  time,

  ///Can be used to check if the [PrintJobSettings.verticalPagination] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PrintJobSettings.verticalPagination.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [PrintJobSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  verticalPagination,
}

extension _PrintJobSettingsPropertySupported on PrintJobSettings {
  static bool isPropertySupported(
    PrintJobSettingsProperty property, {
    TargetPlatform? platform,
  }) {
    switch (property) {
      case PrintJobSettingsProperty.animated:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.canSpawnSeparateThread:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.collate:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.colorMode:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.macOS,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.copies:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.macOS,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.detailedErrorReporting:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.duplexMode:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.faxNumber:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.firstPage:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.footerHeight:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.footerUri:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.forceRenderingQuality:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.handledByClient:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.headerAndFooter:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.macOS,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.headerHeight:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.headerTitle:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.horizontalPagination:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.isHorizontallyCentered:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.isVerticallyCentered:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.jobDisposition:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.jobName:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.jobSavingURL:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.lastPage:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.margins:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.maximumContentHeight:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.maximumContentWidth:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.mediaSize:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.mustCollate:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.numberOfPages:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.iOS,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.orientation:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.outputType:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.pageHeight:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.pageOrder:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.pageRanges:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.pageWidth:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.pagesAcross:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.pagesDown:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.pagesPerSide:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.paperName:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.printDialogKind:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.printerName:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.resolution:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.scalingFactor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.macOS,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.shouldPrintBackgrounds:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.shouldPrintHeaderAndFooter:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.shouldPrintSelectionOnly:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.showUI:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.showsNumberOfCopies:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.iOS,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.showsPageRange:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.showsPageSetupAccessory:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.showsPaperOrientation:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.iOS,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.showsPaperSelectionForLoadedPapers:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.showsPaperSize:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.showsPreview:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.showsPrintPanel:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.showsPrintSelection:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.showsProgressPanel:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.showsScaling:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.time:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case PrintJobSettingsProperty.verticalPagination:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
    }
  }
}
