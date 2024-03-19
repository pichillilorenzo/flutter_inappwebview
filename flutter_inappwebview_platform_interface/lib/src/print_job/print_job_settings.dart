import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../types/main.dart';
import '../types/print_job_color_mode.dart';
import '../types/print_job_disposition.dart';
import '../types/print_job_duplex_mode.dart';
import '../types/print_job_media_size.dart';
import '../types/print_job_orientation.dart';
import '../types/print_job_output_type.dart';
import '../types/print_job_page_order.dart';
import '../types/print_job_pagination_mode.dart';
import '../types/print_job_rendering_quality.dart';
import '../types/print_job_resolution.dart';
import '../util.dart';
import '../web_uri.dart';
import 'platform_print_job_controller.dart';

part 'print_job_settings.g.dart';

///Class that represents the settings of a [PlatformPrintJobController].
@ExchangeableObject(copyMethod: true)
class PrintJobSettings_ {
  ///Set this to `true` to handle the [PlatformPrintJobController].
  ///Otherwise, it will be handled and disposed automatically by the system.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  bool? handledByClient;

  ///The name of the print job.
  ///An application should set this property to a name appropriate to the content being printed.
  ///The default job name is the current webpage title concatenated with the "Document" word at the end.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  String? jobName;

  ///`true` to animate the display of the sheet, `false` to display the sheet immediately.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  bool? animated;

  ///The orientation of the printed content, portrait or landscape.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  PrintJobOrientation_? orientation;

  ///The number of pages to render.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  int? numberOfPages;

  ///Force rendering quality.
  ///
  ///**NOTE for iOS**: available only on iOS 14.5+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  PrintJobRenderingQuality_? forceRenderingQuality;

  ///The margins for each printed page.
  ///Margins define the white space around the content where the left margin defines
  ///the amount of white space on the left of the content and so on.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  EdgeInsets? margins;

  ///The media size.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  PrintJobMediaSize_? mediaSize;

  ///The color mode.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- MacOS
  PrintJobColorMode_? colorMode;

  ///The duplex mode to use for the print job.
  ///
  ///**NOTE for Android native WebView**: available only on Android 23+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  PrintJobDuplexMode_? duplexMode;

  ///The kind of printable content.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  PrintJobOutputType_? outputType;

  ///The supported resolution in DPI (dots per inch).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  PrintJobResolution_? resolution;

  ///A Boolean value that determines whether the printing options include the number of copies.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  bool? showsNumberOfCopies;

  ///A Boolean value that determines whether the paper selection menu displays.
  ///The default value of this property is `false`.
  ///Setting the value to `true` enables a paper selection menu on printers that support different types of paper and have more than one paper type loaded.
  ///On printers where only one paper type is available, no paper selection menu is displayed, regardless of the value of this property.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  bool? showsPaperSelectionForLoadedPapers;

  ///A Boolean value that determines whether the printing options include the paper orientation control when available.
  ///The default value is `true`.
  ///
  ///**NOTE for iOS**: available only on iOS 15.0+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  bool? showsPaperOrientation;

  ///A Boolean value that determines whether the print panel includes a control for manipulating the paper size of the printer.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? showsPaperSize;

  ///A Boolean value that determines whether the Print panel includes a control for scaling the printed output.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? showsScaling;

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

  ///A Boolean value that determines whether the Print panel displays a built-in preview of the document contents.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? showsPreview;

  ///A Boolean value that determines whether the Print panel includes an additional selection option for paper range.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? showsPrintSelection;

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

  ///The height of the page footer.
  ///
  ///The footer is measured in points from the bottom of [printableRect] and is below the content area.
  ///The default footer height is `0.0`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  double? footerHeight;

  ///The height of the page header.
  ///
  ///The header is measured in points from the top of [printableRect] and is above the content area.
  ///The default header height is `0.0`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  double? headerHeight;

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

  ///The current scaling factor. From `0.0` to `1.0`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  double? scalingFactor;

  ///The action specified for the job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  PrintJobDisposition_? jobDisposition;

  ///An URL containing the location to which the job file will be saved when the [jobDisposition] is [PrintJobDisposition.SAVE].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  WebUri? jobSavingURL;

  ///The name of the currently selected paper size.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  String? paperName;

  ///The horizontal pagination mode.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  PrintJobPaginationMode_? horizontalPagination;

  ///The vertical pagination to the specified mode.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  PrintJobPaginationMode_? verticalPagination;

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

  ///The print order for the pages of the operation.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  PrintJobPageOrder_? pageOrder;

  ///Whether the print operation should spawn a separate thread in which to run itself.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? canSpawnSeparateThread;

  ///How many copies to print.
  ///The default value is `1`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  int? copies;

  ///An integer value that specifies the first page in the print job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  int? firstPage;

  ///An integer value that specifies the last page in the print job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  int? lastPage;

  ///If `true`, produce detailed reports when an error occurs.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? detailedErrorReporting;

  ///A fax number.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  String? faxNumber;

  ///If `true`, a standard header and footer are added outside the margins of each page.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? headerAndFooter;

  ///If `true`, collates output.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? mustCollate;

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

  ///A timestamp that specifies the time at which printing should begin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  int? time;

  PrintJobSettings_(
      {this.handledByClient = false,
      this.jobName,
      this.animated = true,
      this.orientation,
      this.numberOfPages,
      this.forceRenderingQuality,
      this.margins,
      this.mediaSize,
      this.colorMode,
      this.duplexMode,
      this.outputType,
      this.resolution,
      this.showsNumberOfCopies = true,
      this.showsPaperSelectionForLoadedPapers = false,
      this.showsPaperOrientation = true,
      this.maximumContentHeight,
      this.maximumContentWidth,
      this.footerHeight,
      this.headerHeight,
      this.showsPaperSize = true,
      this.showsScaling = true,
      this.showsPageRange = true,
      this.showsPageSetupAccessory = true,
      this.showsPreview = true,
      this.showsPrintSelection = true,
      this.scalingFactor,
      this.showsPrintPanel = true,
      this.showsProgressPanel = true,
      this.jobDisposition,
      this.jobSavingURL,
      this.paperName,
      this.horizontalPagination,
      this.verticalPagination,
      this.isHorizontallyCentered = true,
      this.isVerticallyCentered = true,
      this.pageOrder,
      this.canSpawnSeparateThread = true,
      this.copies = 1,
      this.firstPage,
      this.lastPage,
      this.detailedErrorReporting = false,
      this.faxNumber,
      this.headerAndFooter = true,
      this.mustCollate,
      this.pagesAcross,
      this.pagesDown,
      this.time});
}
