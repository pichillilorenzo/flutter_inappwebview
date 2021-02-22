import 'dart:async';

import 'package:flutter/services.dart';

import '../../types.dart';
import '../_static_channel.dart';

///Class that represents various types of data that a website might make use of.
///This includes cookies, disk and memory caches, and persistent data such as WebSQL, IndexedDB databases, and local storage.
///
///**NOTE**: available on iOS 9.0+.
class IOSWebStorageManager {
  static MethodChannel _staticChannel = WEB_STORAGE_STATIC_CHANNEL;

  ///Fetches data records containing the given website data types.
  ///
  ///[dataTypes] represents the website data types to fetch records for.
  Future<List<IOSWKWebsiteDataRecord>> fetchDataRecords(
      {required Set<IOSWKWebsiteDataType> dataTypes}) async {
    List<IOSWKWebsiteDataRecord> recordList = [];
    List<String> dataTypesList = [];
    for (var dataType in dataTypes) {
      dataTypesList.add(dataType.toValue());
    }
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("dataTypes", () => dataTypesList);
    List<Map<dynamic, dynamic>> records =
        (await _staticChannel.invokeMethod('fetchDataRecords', args))
            .cast<Map<dynamic, dynamic>>();
    for (var record in records) {
      List<String> dataTypesString = record["dataTypes"].cast<String>();
      Set<IOSWKWebsiteDataType> dataTypes = Set();
      for (var dataTypeValue in dataTypesString) {
        var dataType = IOSWKWebsiteDataType.fromValue(dataTypeValue);
        if (dataType != null) {
          dataTypes.add(dataType);
        }
      }
      recordList.add(IOSWKWebsiteDataRecord(
          displayName: record["displayName"], dataTypes: dataTypes));
    }
    return recordList;
  }

  ///Removes website data of the given types for the given data records.
  ///
  ///[dataTypes] represents the website data types that should be removed.
  ///
  ///[dataRecords] represents the website data records to delete website data for.
  Future<void> removeDataFor(
      {required Set<IOSWKWebsiteDataType> dataTypes,
      required List<IOSWKWebsiteDataRecord> dataRecords}) async {
    List<String> dataTypesList = [];
    for (var dataType in dataTypes) {
      dataTypesList.add(dataType.toValue());
    }

    List<Map<String, dynamic>> recordList = [];
    for (var record in dataRecords) {
      recordList.add(record.toMap());
    }

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("dataTypes", () => dataTypesList);
    args.putIfAbsent("recordList", () => recordList);
    await _staticChannel.invokeMethod('removeDataFor', args);
  }

  ///Removes all website data of the given types that has been modified since the given date.
  ///
  ///[dataTypes] represents the website data types that should be removed.
  ///
  ///[date] represents a date. All website data modified after this date will be removed.
  Future<void> removeDataModifiedSince(
      {required Set<IOSWKWebsiteDataType> dataTypes,
      required DateTime date}) async {
    List<String> dataTypesList = [];
    for (var dataType in dataTypes) {
      dataTypesList.add(dataType.toValue());
    }

    var timestamp = date.millisecondsSinceEpoch;

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("dataTypes", () => dataTypesList);
    args.putIfAbsent("timestamp", () => timestamp);
    await _staticChannel.invokeMethod('removeDataModifiedSince', args);
  }
}
