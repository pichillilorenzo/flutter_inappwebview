import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../print_job/main.dart';
import 'print_job_attributes.dart';
import 'print_job_state.dart';

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
  PrintJobState_? state;

  ///How many copies to print.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  int? copies;

  ///The number of pages to print.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  int? numberOfPages;

  ///The timestamp when the print job was created.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  int? creationTime;

  ///The human readable print job label.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  String? label;

  ///The unique id of the printer.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  String? printerId;

  ///The attributes of a print job.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  PrintJobAttributes_? attributes;

  PrintJobInfo_(
      {this.state,
      this.copies,
      this.numberOfPages,
      this.creationTime,
      this.label,
      this.printerId,
      this.attributes});
}
