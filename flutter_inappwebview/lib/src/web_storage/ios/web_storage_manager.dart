import 'dart:async';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../web_storage_manager.dart';

///Class that represents various types of data that a website might make use of.
///This includes cookies, disk and memory caches, and persistent data such as WebSQL, IndexedDB databases, and local storage.
///
///**NOTE**: available on iOS 9.0+.
///
///Use [WebStorageManager] instead.
@Deprecated("Use WebStorageManager instead")
class IOSWebStorageManager {
  ///Fetches data records containing the given website data types.
  ///
  ///[dataTypes] represents the website data types to fetch records for.
  Future<List<IOSWKWebsiteDataRecord>> fetchDataRecords({
    required Set<IOSWKWebsiteDataType> dataTypes,
  }) async {
    List<IOSWKWebsiteDataRecord> recordList = [];
    Set<WebsiteDataType> dataTypesList = Set();
    for (var dataType in dataTypes) {
      dataTypesList.add(
        WebsiteDataType.fromNativeValue(dataType.toNativeValue())!,
      );
    }

    List<WebsiteDataRecord> records = await WebStorageManager.instance()
        .fetchDataRecords(dataTypes: dataTypesList);

    for (var record in records) {
      Set<WebsiteDataType> dataTypesString = record.dataTypes ?? Set();
      Set<IOSWKWebsiteDataType> dataTypes = Set();
      for (var dataTypeValue in dataTypesString) {
        var dataType = IOSWKWebsiteDataType.fromNativeValue(
          dataTypeValue.toNativeValue(),
        );
        if (dataType != null) {
          dataTypes.add(dataType);
        }
      }
      recordList.add(
        IOSWKWebsiteDataRecord(
          displayName: record.displayName,
          dataTypes: dataTypes,
        ),
      );
    }
    return recordList;
  }

  ///Removes website data of the given types for the given data records.
  ///
  ///[dataTypes] represents the website data types that should be removed.
  ///
  ///[dataRecords] represents the website data records to delete website data for.
  Future<void> removeDataFor({
    required Set<IOSWKWebsiteDataType> dataTypes,
    required List<IOSWKWebsiteDataRecord> dataRecords,
  }) async {
    Set<WebsiteDataType> dataTypesList = Set();
    for (var dataType in dataTypes) {
      dataTypesList.add(
        WebsiteDataType.fromNativeValue(dataType.toNativeValue())!,
      );
    }

    List<WebsiteDataRecord> recordList = [];
    for (var record in dataRecords) {
      recordList.add(WebsiteDataRecord.fromMap(record.toMap())!);
    }

    await WebStorageManager.instance().removeDataFor(
      dataRecords: recordList,
      dataTypes: dataTypesList,
    );
  }

  ///Removes all website data of the given types that has been modified since the given date.
  ///
  ///[dataTypes] represents the website data types that should be removed.
  ///
  ///[date] represents a date. All website data modified after this date will be removed.
  Future<void> removeDataModifiedSince({
    required Set<IOSWKWebsiteDataType> dataTypes,
    required DateTime date,
  }) async {
    Set<WebsiteDataType> dataTypesList = Set();
    for (var dataType in dataTypes) {
      dataTypesList.add(
        WebsiteDataType.fromNativeValue(dataType.toNativeValue())!,
      );
    }

    await WebStorageManager.instance().removeDataModifiedSince(
      dataTypes: dataTypesList,
      date: date,
    );
  }
}
