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
  PrintJobState? state;

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
  PrintJobAttributes? attributes;
  PrintJobInfo(
      {this.state,
      this.copies,
      this.numberOfPages,
      this.creationTime,
      this.label,
      this.printerId,
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
      printerId: map['printerId'],
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
      "printerId": printerId,
      "attributes": attributes?.toMap(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'PrintJobInfo{state: $state, copies: $copies, numberOfPages: $numberOfPages, creationTime: $creationTime, label: $label, printerId: $printerId, attributes: $attributes}';
  }
}
