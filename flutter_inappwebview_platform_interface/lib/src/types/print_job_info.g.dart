// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_info.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing the description of a [PlatformPrintJobController].
///Note that the print jobs state may change over time and this class represents a snapshot of this state.
class PrintJobInfo {
  ///The attributes of a print job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  PrintJobAttributes? attributes;

  ///Whether the print operation should spawn a separate thread in which to run itself.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? canSpawnSeparateThread;

  ///How many copies to print.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- MacOS
  int? copies;

  ///The timestamp when the print job was created.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  int? creationTime;

  ///The current page number being previewed or printed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  int? currentPage;

  ///An integer value that specifies the first page in the print job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  int? firstPage;

  ///A Boolean value that indicates whether the print operation is an EPS or PDF copy operation.
  ///It's `true` if the receiver is an EPS or PDF copy operation; otherwise, `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? isCopyingOperation;

  ///The human readable print job label.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  String? label;

  ///An integer value that specifies the last page in the print job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  int? lastPage;

  ///The number of pages to print.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  int? numberOfPages;

  ///The page order that will be used to generate the pages in this job.
  ///This is the physical page order of the pages.
  ///It depends on the stacking order of the printer, the capability of the app to reverse page order, etc.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  PrintJobPageOrder? pageOrder;

  ///The printing quality.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  PrintJobRenderingQuality? preferredRenderingQuality;

  ///The printer object to be used for printing.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Printer? printer;

  ///Whether the print panel is shown during the operation.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? showsPrintPanel;

  ///Whether the progress panel is shown during the operation.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  bool? showsProgressPanel;

  ///The state of the print job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  PrintJobState? state;
  PrintJobInfo(
      {this.attributes,
      this.canSpawnSeparateThread,
      this.copies,
      this.creationTime,
      this.currentPage,
      this.firstPage,
      this.isCopyingOperation,
      this.label,
      this.lastPage,
      this.numberOfPages,
      this.pageOrder,
      this.preferredRenderingQuality,
      this.printer,
      this.showsPrintPanel,
      this.showsProgressPanel,
      this.state});

  ///Gets a possible [PrintJobInfo] instance from a [Map] value.
  static PrintJobInfo? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = PrintJobInfo(
      attributes: PrintJobAttributes.fromMap(
          map['attributes']?.cast<String, dynamic>()),
      canSpawnSeparateThread: map['canSpawnSeparateThread'],
      copies: map['copies'],
      creationTime: map['creationTime'],
      currentPage: map['currentPage'],
      firstPage: map['firstPage'],
      isCopyingOperation: map['isCopyingOperation'],
      label: map['label'],
      lastPage: map['lastPage'],
      numberOfPages: map['numberOfPages'],
      pageOrder: PrintJobPageOrder.fromNativeValue(map['pageOrder']),
      preferredRenderingQuality: PrintJobRenderingQuality.fromNativeValue(
          map['preferredRenderingQuality']),
      printer: Printer.fromMap(map['printer']?.cast<String, dynamic>()),
      showsPrintPanel: map['showsPrintPanel'],
      showsProgressPanel: map['showsProgressPanel'],
      state: PrintJobState.fromNativeValue(map['state']),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "attributes": attributes?.toMap(),
      "canSpawnSeparateThread": canSpawnSeparateThread,
      "copies": copies,
      "creationTime": creationTime,
      "currentPage": currentPage,
      "firstPage": firstPage,
      "isCopyingOperation": isCopyingOperation,
      "label": label,
      "lastPage": lastPage,
      "numberOfPages": numberOfPages,
      "pageOrder": pageOrder?.toNativeValue(),
      "preferredRenderingQuality": preferredRenderingQuality?.toNativeValue(),
      "printer": printer?.toMap(),
      "showsPrintPanel": showsPrintPanel,
      "showsProgressPanel": showsProgressPanel,
      "state": state?.toNativeValue(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'PrintJobInfo{attributes: $attributes, canSpawnSeparateThread: $canSpawnSeparateThread, copies: $copies, creationTime: $creationTime, currentPage: $currentPage, firstPage: $firstPage, isCopyingOperation: $isCopyingOperation, label: $label, lastPage: $lastPage, numberOfPages: $numberOfPages, pageOrder: $pageOrder, preferredRenderingQuality: $preferredRenderingQuality, printer: $printer, showsPrintPanel: $showsPrintPanel, showsProgressPanel: $showsProgressPanel, state: $state}';
  }
}
