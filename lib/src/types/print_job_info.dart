import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../print_job/main.dart';
import 'print_job_attributes.dart';
import 'print_job_rendering_quality.dart';
import 'print_job_state.dart';
import 'print_job_page_order.dart';
import 'printer.dart';

part 'print_job_info.g.dart';

///Class representing the description of a [PrintJobController].
///Note that the print jobs state may change over time and this class represents a snapshot of this state.
@ExchangeableObject()
class PrintJobInfo_ {
  ///The state of the print job.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  PrintJobState_? state;

  ///How many copies to print.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- MacOS
  int? copies;

  ///The number of pages to print.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  int? numberOfPages;

  ///The timestamp when the print job was created.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  int? creationTime;

  ///The human readable print job label.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  String? label;

  ///The printer object to be used for printing.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Printer_? printer;

  ///The page order that will be used to generate the pages in this job.
  ///This is the physical page order of the pages.
  ///It depends on the stacking order of the printer, the capability of the app to reverse page order, etc.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  PrintJobPageOrder_? pageOrder;

  ///The printing quality.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  PrintJobRenderingQuality_? preferredRenderingQuality;

  ///Whether the progress panel is shown during the operation.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  bool? showsProgressPanel;

  ///Whether the print panel is shown during the operation.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  bool? showsPrintPanel;

  ///Whether the print operation should spawn a separate thread in which to run itself.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  bool? canSpawnSeparateThread;

  ///A Boolean value that indicates whether the print operation is an EPS or PDF copy operation.
  ///It's `true` if the receiver is an EPS or PDF copy operation; otherwise, `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  bool? isCopyingOperation;

  ///The current page number being previewed or printed.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  int? currentPage;

  ///An integer value that specifies the first page in the print job.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  int? firstPage;

  ///An integer value that specifies the last page in the print job.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  int? lastPage;

  ///The attributes of a print job.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  PrintJobAttributes_? attributes;

  PrintJobInfo_(
      {this.state,
      this.copies,
      this.numberOfPages,
      this.creationTime,
      this.label,
      this.printer,
      this.pageOrder,
      this.preferredRenderingQuality,
      this.showsProgressPanel,
      this.showsPrintPanel,
      this.canSpawnSeparateThread,
      this.isCopyingOperation,
      this.currentPage,
      this.firstPage,
      this.lastPage,
      this.attributes});
}
