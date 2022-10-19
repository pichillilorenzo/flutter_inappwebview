import 'dart:async';

import 'package:flutter/services.dart';

import '_static_channel.dart';
import 'android/web_storage_manager.dart';
import 'ios/web_storage_manager.dart';

import '../types/main.dart';

///Class that implements a singleton object (shared instance) which manages the web storage used by WebView instances.
///On Android, it is implemented using [WebStorage](https://developer.android.com/reference/android/webkit/WebStorage.html).
///On iOS and MacOS, it is implemented using [WKWebsiteDataStore.default()](https://developer.apple.com/documentation/webkit/wkwebsitedatastore).
///
///**NOTE for iOS**: available from iOS 9.0+.
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
class WebStorageManager {
  static WebStorageManager? _instance;
  static const MethodChannel _staticChannel = WEB_STORAGE_STATIC_CHANNEL;

  WebStorageManager._();

  ///Use [WebStorageManager] instead.
  @Deprecated("Use WebStorageManager instead")
  AndroidWebStorageManager android = AndroidWebStorageManager();

  ///Use [WebStorageManager] instead.
  @Deprecated("Use WebStorageManager instead")
  IOSWebStorageManager ios = IOSWebStorageManager();

  ///Gets the WebStorage manager shared instance.
  static WebStorageManager instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static WebStorageManager _init() {
    _staticChannel.setMethodCallHandler((call) async {
      try {
        return await _handleMethod(call);
      } on Error catch (e) {
        print(e);
        print(e.stackTrace);
      }
    });
    _instance = new WebStorageManager._();
    return _instance!;
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {}

  ///Gets the origins currently using either the Application Cache or Web SQL Database APIs.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebStorage.getOrigins](https://developer.android.com/reference/android/webkit/WebStorage#getOrigins(android.webkit.ValueCallback%3Cjava.util.Map%3E)))
  Future<List<WebStorageOrigin>> getOrigins() async {
    List<WebStorageOrigin> originsList = [];

    Map<String, dynamic> args = <String, dynamic>{};
    List<Map<dynamic, dynamic>> origins =
        (await _staticChannel.invokeMethod('getOrigins', args))
            .cast<Map<dynamic, dynamic>>();

    for (var origin in origins) {
      originsList.add(WebStorageOrigin(
          origin: origin["origin"],
          quota: origin["quota"],
          usage: origin["usage"]));
    }

    return originsList;
  }

  ///Clears all storage currently being used by the JavaScript storage APIs.
  ///This includes the Application Cache, Web SQL Database and the HTML5 Web Storage APIs.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebStorage.deleteAllData](https://developer.android.com/reference/android/webkit/WebStorage#deleteAllData()))
  Future<void> deleteAllData() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _staticChannel.invokeMethod('deleteAllData', args);
  }

  ///Clears the storage currently being used by both the Application Cache and Web SQL Database APIs by the given [origin].
  ///The origin is specified using its string representation.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebStorage.deleteOrigin](https://developer.android.com/reference/android/webkit/WebStorage#deleteOrigin(java.lang.String)))
  Future<void> deleteOrigin({required String origin}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("origin", () => origin);
    await _staticChannel.invokeMethod('deleteOrigin', args);
  }

  ///Gets the storage quota for the Web SQL Database API for the given [origin].
  ///The quota is given in bytes and the origin is specified using its string representation.
  ///Note that a quota is not enforced on a per-origin basis for the Application Cache API.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebStorage.getQuotaForOrigin](https://developer.android.com/reference/android/webkit/WebStorage#getQuotaForOrigin(java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.Long%3E)))
  Future<int> getQuotaForOrigin({required String origin}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("origin", () => origin);
    return await _staticChannel.invokeMethod('getQuotaForOrigin', args);
  }

  ///Gets the amount of storage currently being used by both the Application Cache and Web SQL Database APIs by the given [origin].
  ///The amount is given in bytes and the origin is specified using its string representation.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebStorage.getUsageForOrigin](https://developer.android.com/reference/android/webkit/WebStorage#getUsageForOrigin(java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.Long%3E)))
  Future<int> getUsageForOrigin({required String origin}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("origin", () => origin);
    return await _staticChannel.invokeMethod('getUsageForOrigin', args);
  }

  ///Fetches data records containing the given website data types.
  ///
  ///[dataTypes] represents the website data types to fetch records for.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebsiteDataStore.fetchDataRecords](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532932-fetchdatarecords))
  ///- MacOS ([Official API - WKWebsiteDataStore.fetchDataRecords](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532932-fetchdatarecords))
  Future<List<WebsiteDataRecord>> fetchDataRecords(
      {required Set<WebsiteDataType> dataTypes}) async {
    List<WebsiteDataRecord> recordList = [];
    List<String> dataTypesList = [];
    for (var dataType in dataTypes) {
      dataTypesList.add(dataType.toNativeValue());
    }
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("dataTypes", () => dataTypesList);
    List<Map<dynamic, dynamic>> records =
        (await _staticChannel.invokeMethod('fetchDataRecords', args))
            .cast<Map<dynamic, dynamic>>();
    for (var record in records) {
      List<String> dataTypesString = record["dataTypes"].cast<String>();
      Set<WebsiteDataType> dataTypes = Set();
      for (var dataTypeValue in dataTypesString) {
        var dataType = WebsiteDataType.fromNativeValue(dataTypeValue);
        if (dataType != null) {
          dataTypes.add(dataType);
        }
      }
      recordList.add(WebsiteDataRecord(
          displayName: record["displayName"], dataTypes: dataTypes));
    }
    return recordList;
  }

  ///Removes website data of the given types for the given data records.
  ///
  ///[dataTypes] represents the website data types that should be removed.
  ///
  ///[dataRecords] represents the website data records to delete website data for.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebsiteDataStore.removeData](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532936-removedata))
  ///- MacOS ([Official API - WKWebsiteDataStore.removeData](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532936-removedata))
  Future<void> removeDataFor(
      {required Set<WebsiteDataType> dataTypes,
      required List<WebsiteDataRecord> dataRecords}) async {
    List<String> dataTypesList = [];
    for (var dataType in dataTypes) {
      dataTypesList.add(dataType.toNativeValue());
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
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebsiteDataStore.removeData](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata))
  ///- MacOS ([Official API - WKWebsiteDataStore.removeData](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata))
  Future<void> removeDataModifiedSince(
      {required Set<WebsiteDataType> dataTypes, required DateTime date}) async {
    List<String> dataTypesList = [];
    for (var dataType in dataTypes) {
      dataTypesList.add(dataType.toNativeValue());
    }

    var timestamp = date.millisecondsSinceEpoch;

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("dataTypes", () => dataTypesList);
    args.putIfAbsent("timestamp", () => timestamp);
    await _staticChannel.invokeMethod('removeDataModifiedSince', args);
  }
}
