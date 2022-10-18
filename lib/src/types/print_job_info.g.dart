// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_info.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing the description of a [PrintJobController].
///Note that the print jobs state may change over time and this class represents a snapshot of this state.
class PrintJobInfo {
  ///The state of the print job.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  PrintJobState? state;

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
  Printer? printer;

  ///The page order that will be used to generate the pages in this job.
  ///This is the physical page order of the pages.
  ///It depends on the stacking order of the printer, the capability of the app to reverse page order, etc.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  PrintJobPageOrder? pageOrder;

  ///The printing quality.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  PrintJobRenderingQuality? preferredRenderingQuality;

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
  PrintJobAttributes? attributes;
  PrintJobInfo(
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

  ///Gets a possible [PrintJobInfo] instance from a [Map] value.
  static PrintJobInfo? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = PrintJobInfo(
      state: PrintJobState.fromNativeValue(map['state']),
      copies: map['copies'],
      numberOfPages: map['numberOfPages'],
      creationTime: map['creationTime'],
      label: map['label'],
      printer: Printer.fromMap(map['printer']?.cast<String, dynamic>()),
      pageOrder: PrintJobPageOrder.fromNativeValue(map['pageOrder']),
      preferredRenderingQuality: PrintJobRenderingQuality.fromNativeValue(
          map['preferredRenderingQuality']),
      showsProgressPanel: map['showsProgressPanel'],
      showsPrintPanel: map['showsPrintPanel'],
      canSpawnSeparateThread: map['canSpawnSeparateThread'],
      isCopyingOperation: map['isCopyingOperation'],
      currentPage: map['currentPage'],
      firstPage: map['firstPage'],
      lastPage: map['lastPage'],
      attributes: PrintJobAttributes.fromMap(
          map['attributes']?.cast<String, dynamic>()),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "state": state?.toNativeValue(),
      "copies": copies,
      "numberOfPages": numberOfPages,
      "creationTime": creationTime,
      "label": label,
      "printer": printer?.toMap(),
      "pageOrder": pageOrder?.toNativeValue(),
      "preferredRenderingQuality": preferredRenderingQuality?.toNativeValue(),
      "showsProgressPanel": showsProgressPanel,
      "showsPrintPanel": showsPrintPanel,
      "canSpawnSeparateThread": canSpawnSeparateThread,
      "isCopyingOperation": isCopyingOperation,
      "currentPage": currentPage,
      "firstPage": firstPage,
      "lastPage": lastPage,
      "attributes": attributes?.toMap(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'PrintJobInfo{state: $state, copies: $copies, numberOfPages: $numberOfPages, creationTime: $creationTime, label: $label, printer: $printer, pageOrder: $pageOrder, preferredRenderingQuality: $preferredRenderingQuality, showsProgressPanel: $showsProgressPanel, showsPrintPanel: $showsPrintPanel, canSpawnSeparateThread: $canSpawnSeparateThread, isCopyingOperation: $isCopyingOperation, currentPage: $currentPage, firstPage: $firstPage, lastPage: $lastPage, attributes: $attributes}';
  }
}
