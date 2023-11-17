import 'dart:async';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'android/web_storage_manager.dart';
import 'ios/web_storage_manager.dart';

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
  /// Constructs a [WebStorageManager].
  ///
  /// See [WebStorageManager.fromPlatformCreationParams] for setting
  /// parameters for a specific platform.
  WebStorageManager()
      : this.fromPlatformCreationParams(
          const PlatformWebStorageManagerCreationParams(),
        );

  /// Constructs a [WebStorageManager] from creation params for a specific
  /// platform.
  WebStorageManager.fromPlatformCreationParams(
    PlatformWebStorageManagerCreationParams params,
  ) : this.fromPlatform(PlatformWebStorageManager(params));

  /// Constructs a [WebStorageManager] from a specific platform
  /// implementation.
  WebStorageManager.fromPlatform(this.platform);

  /// Implementation of [PlatformWebViewCookieManager] for the current platform.
  final PlatformWebStorageManager platform;

  static WebStorageManager? _instance;

  ///Use [WebStorageManager] instead.
  @Deprecated("Use WebStorageManager instead")
  AndroidWebStorageManager android = AndroidWebStorageManager();

  ///Use [WebStorageManager] instead.
  @Deprecated("Use WebStorageManager instead")
  IOSWebStorageManager ios = IOSWebStorageManager();

  ///Gets the [WebStorageManager] shared instance.
  static WebStorageManager instance() {
    if (_instance == null) {
      _instance = WebStorageManager();
    }
    return _instance!;
  }

  ///Gets the origins currently using either the Application Cache or Web SQL Database APIs.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebStorage.getOrigins](https://developer.android.com/reference/android/webkit/WebStorage#getOrigins(android.webkit.ValueCallback%3Cjava.util.Map%3E)))
  Future<List<WebStorageOrigin>> getOrigins() => platform.getOrigins();

  ///Clears all storage currently being used by the JavaScript storage APIs.
  ///This includes the Application Cache, Web SQL Database and the HTML5 Web Storage APIs.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebStorage.deleteAllData](https://developer.android.com/reference/android/webkit/WebStorage#deleteAllData()))
  Future<void> deleteAllData() => platform.deleteAllData();

  ///Clears the storage currently being used by both the Application Cache and Web SQL Database APIs by the given [origin].
  ///The origin is specified using its string representation.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebStorage.deleteOrigin](https://developer.android.com/reference/android/webkit/WebStorage#deleteOrigin(java.lang.String)))
  Future<void> deleteOrigin({required String origin}) =>
      platform.deleteOrigin(origin: origin);

  ///Gets the storage quota for the Web SQL Database API for the given [origin].
  ///The quota is given in bytes and the origin is specified using its string representation.
  ///Note that a quota is not enforced on a per-origin basis for the Application Cache API.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebStorage.getQuotaForOrigin](https://developer.android.com/reference/android/webkit/WebStorage#getQuotaForOrigin(java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.Long%3E)))
  Future<int> getQuotaForOrigin({required String origin}) =>
      platform.getQuotaForOrigin(origin: origin);

  ///Gets the amount of storage currently being used by both the Application Cache and Web SQL Database APIs by the given [origin].
  ///The amount is given in bytes and the origin is specified using its string representation.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebStorage.getUsageForOrigin](https://developer.android.com/reference/android/webkit/WebStorage#getUsageForOrigin(java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.Long%3E)))
  Future<int> getUsageForOrigin({required String origin}) =>
      platform.getUsageForOrigin(origin: origin);

  ///Fetches data records containing the given website data types.
  ///
  ///[dataTypes] represents the website data types to fetch records for.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebsiteDataStore.fetchDataRecords](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532932-fetchdatarecords))
  ///- MacOS ([Official API - WKWebsiteDataStore.fetchDataRecords](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532932-fetchdatarecords))
  Future<List<WebsiteDataRecord>> fetchDataRecords(
          {required Set<WebsiteDataType> dataTypes}) =>
      platform.fetchDataRecords(dataTypes: dataTypes);

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
          required List<WebsiteDataRecord> dataRecords}) =>
      platform.removeDataFor(dataTypes: dataTypes, dataRecords: dataRecords);

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
          {required Set<WebsiteDataType> dataTypes, required DateTime date}) =>
      platform.removeDataModifiedSince(dataTypes: dataTypes, date: date);
}
