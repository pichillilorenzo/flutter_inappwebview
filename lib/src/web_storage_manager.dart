import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'types.dart';

///Class that implements a singleton object (shared instance) which manages the web storage used by WebView instances.
///On Android, it is implemented using [WebStorage](https://developer.android.com/reference/android/webkit/WebStorage.html).
///On iOS, it is implemented using [WKWebsiteDataStore.default()](https://developer.apple.com/documentation/webkit/wkwebsitedatastore).
///
///**NOTE for iOS**: available from iOS 9.0+.
class WebStorageManager {
  static WebStorageManager _instance;
  static const MethodChannel _channel = const MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_webstoragemanager');

  AndroidWebStorageManager android = AndroidWebStorageManager();
  IOSWebStorageManager ios = IOSWebStorageManager();

  ///Gets the WebStorage manager shared instance.
  static WebStorageManager instance() {
    return (_instance != null) ? _instance : _init();
  }

  static WebStorageManager _init() {
    _channel.setMethodCallHandler(_handleMethod);
    _instance = new WebStorageManager();
    return _instance;
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {}
}

///Class that is used to manage the JavaScript storage APIs provided by the WebView.
///It manages the Application Cache API, the Web SQL Database API and the HTML5 Web Storage API.
class AndroidWebStorageManager {
  ///Gets the origins currently using either the Application Cache or Web SQL Database APIs.
  Future<List<AndroidWebStorageOrigin>> getOrigins() async {
    List<AndroidWebStorageOrigin> originsList = [];

    Map<String, dynamic> args = <String, dynamic>{};
    List<Map<dynamic, dynamic>> origins =
        (await WebStorageManager._channel.invokeMethod('getOrigins', args))
            .cast<Map<dynamic, dynamic>>();

    for (var origin in origins) {
      originsList.add(AndroidWebStorageOrigin(
          origin: origin["origin"],
          quota: origin["quota"],
          usage: origin["usage"]));
    }

    return originsList;
  }

  ///Clears all storage currently being used by the JavaScript storage APIs.
  ///This includes the Application Cache, Web SQL Database and the HTML5 Web Storage APIs.
  Future<void> deleteAllData() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await WebStorageManager._channel.invokeMethod('deleteAllData', args);
  }

  ///Clears the storage currently being used by both the Application Cache and Web SQL Database APIs by the given [origin].
  ///The origin is specified using its string representation.
  Future<void> deleteOrigin({@required String origin}) async {
    assert(origin != null);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("origin", () => origin);
    await WebStorageManager._channel.invokeMethod('deleteOrigin', args);
  }

  ///Gets the storage quota for the Web SQL Database API for the given [origin].
  ///The quota is given in bytes and the origin is specified using its string representation.
  ///Note that a quota is not enforced on a per-origin basis for the Application Cache API.
  Future<int> getQuotaForOrigin({@required String origin}) async {
    assert(origin != null);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("origin", () => origin);
    return await WebStorageManager._channel
        .invokeMethod('getQuotaForOrigin', args);
  }

  ///Gets the amount of storage currently being used by both the Application Cache and Web SQL Database APIs by the given [origin].
  ///The amount is given in bytes and the origin is specified using its string representation.
  Future<int> getUsageForOrigin({@required String origin}) async {
    assert(origin != null);
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("origin", () => origin);
    return await WebStorageManager._channel
        .invokeMethod('getUsageForOrigin', args);
  }
}

///Class that represents various types of data that a website might make use of.
///This includes cookies, disk and memory caches, and persistent data such as WebSQL, IndexedDB databases, and local storage.
///
///**NOTE**: available on iOS 9.0+.
class IOSWebStorageManager {
  ///Fetches data records containing the given website data types.
  ///
  ///[dataTypes] represents the website data types to fetch records for.
  Future<List<IOSWKWebsiteDataRecord>> fetchDataRecords(
      {@required Set<IOSWKWebsiteDataType> dataTypes}) async {
    assert(dataTypes != null);
    List<IOSWKWebsiteDataRecord> recordList = [];
    List<String> dataTypesList = [];
    for (var dataType in dataTypes) {
      dataTypesList.add(dataType.toValue());
    }
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("dataTypes", () => dataTypesList);
    List<Map<dynamic, dynamic>> records = (await WebStorageManager._channel
            .invokeMethod('fetchDataRecords', args))
        .cast<Map<dynamic, dynamic>>();
    for (var record in records) {
      List<String> dataTypesString = record["dataTypes"].cast<String>();
      Set<IOSWKWebsiteDataType> dataTypes = Set();
      for (var dataType in dataTypesString) {
        dataTypes.add(IOSWKWebsiteDataType.fromValue(dataType));
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
      {@required Set<IOSWKWebsiteDataType> dataTypes,
      @required List<IOSWKWebsiteDataRecord> dataRecords}) async {
    assert(dataTypes != null && dataRecords != null);

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
    await WebStorageManager._channel.invokeMethod('removeDataFor', args);
  }

  ///Removes all website data of the given types that has been modified since the given date.
  ///
  ///[dataTypes] represents the website data types that should be removed.
  ///
  ///[date] represents a date. All website data modified after this date will be removed.
  Future<void> removeDataModifiedSince(
      {@required Set<IOSWKWebsiteDataType> dataTypes,
      @required DateTime date}) async {
    assert(dataTypes != null && date != null);

    List<String> dataTypesList = [];
    for (var dataType in dataTypes) {
      dataTypesList.add(dataType.toValue());
    }

    var timestamp = date.millisecondsSinceEpoch;

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("dataTypes", () => dataTypesList);
    args.putIfAbsent("timestamp", () => timestamp);
    await WebStorageManager._channel
        .invokeMethod('removeDataModifiedSince', args);
  }
}
