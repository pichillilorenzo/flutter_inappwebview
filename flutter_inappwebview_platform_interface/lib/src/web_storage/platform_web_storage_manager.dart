import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../inappwebview_platform.dart';
import '../types/main.dart';

/// Object specifying creation parameters for creating a [PlatformWebStorageManager].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformWebStorageManagerCreationParams {
  /// Used by the platform implementation to create a new [PlatformWebStorageManager].
  const PlatformWebStorageManagerCreationParams();
}

///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManager}
///Class that implements a singleton object (shared instance) which manages the web storage used by WebView instances.
///On Android, it is implemented using [WebStorage](https://developer.android.com/reference/android/webkit/WebStorage.html).
///On iOS and MacOS, it is implemented using [WKWebsiteDataStore.default()](https://developer.apple.com/documentation/webkit/wkwebsitedatastore).
///
///**NOTE for iOS**: available from iOS 9.0+.
///
///**Officially Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
///{@endtemplate}
abstract class PlatformWebStorageManager extends PlatformInterface {
  /// Creates a new [PlatformCookieManager]
  factory PlatformWebStorageManager(
      PlatformWebStorageManagerCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformWebStorageManager cookieManager =
        InAppWebViewPlatform.instance!.createPlatformWebStorageManager(params);
    PlatformInterface.verify(cookieManager, _token);
    return cookieManager;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformWebStorageManager].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformWebStorageManager.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformWebStorageManager].
  final PlatformWebStorageManagerCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManager.getOrigins}
  ///Gets the origins currently using either the Application Cache or Web SQL Database APIs.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebStorage.getOrigins](https://developer.android.com/reference/android/webkit/WebStorage#getOrigins(android.webkit.ValueCallback%3Cjava.util.Map%3E)))
  ///{@endtemplate}
  Future<List<WebStorageOrigin>> getOrigins() {
    throw UnimplementedError(
        'getOrigins is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManager.deleteAllData}
  ///Clears all storage currently being used by the JavaScript storage APIs.
  ///This includes the Application Cache, Web SQL Database and the HTML5 Web Storage APIs.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebStorage.deleteAllData](https://developer.android.com/reference/android/webkit/WebStorage#deleteAllData()))
  ///{@endtemplate}
  Future<void> deleteAllData() {
    throw UnimplementedError(
        'deleteAllData is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManager.deleteOrigin}
  ///Clears the storage currently being used by both the Application Cache and Web SQL Database APIs by the given [origin].
  ///The origin is specified using its string representation.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebStorage.deleteOrigin](https://developer.android.com/reference/android/webkit/WebStorage#deleteOrigin(java.lang.String)))
  ///{@endtemplate}
  Future<void> deleteOrigin({required String origin}) {
    throw UnimplementedError(
        'deleteOrigin is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManager.getQuotaForOrigin}
  ///Gets the storage quota for the Web SQL Database API for the given [origin].
  ///The quota is given in bytes and the origin is specified using its string representation.
  ///Note that a quota is not enforced on a per-origin basis for the Application Cache API.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebStorage.getQuotaForOrigin](https://developer.android.com/reference/android/webkit/WebStorage#getQuotaForOrigin(java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.Long%3E)))
  ///{@endtemplate}
  Future<int> getQuotaForOrigin({required String origin}) {
    throw UnimplementedError(
        'getQuotaForOrigin is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManager.getUsageForOrigin}
  ///Gets the amount of storage currently being used by both the Application Cache and Web SQL Database APIs by the given [origin].
  ///The amount is given in bytes and the origin is specified using its string representation.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebStorage.getUsageForOrigin](https://developer.android.com/reference/android/webkit/WebStorage#getUsageForOrigin(java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.Long%3E)))
  ///{@endtemplate}
  Future<int> getUsageForOrigin({required String origin}) {
    throw UnimplementedError(
        'getUsageForOrigin is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManager.fetchDataRecords}
  ///Fetches data records containing the given website data types.
  ///
  ///[dataTypes] represents the website data types to fetch records for.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebsiteDataStore.fetchDataRecords](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532932-fetchdatarecords))
  ///- MacOS ([Official API - WKWebsiteDataStore.fetchDataRecords](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532932-fetchdatarecords))
  ///{@endtemplate}
  Future<List<WebsiteDataRecord>> fetchDataRecords(
      {required Set<WebsiteDataType> dataTypes}) {
    throw UnimplementedError(
        'fetchDataRecords is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManager.removeDataFor}
  ///Removes website data of the given types for the given data records.
  ///
  ///[dataTypes] represents the website data types that should be removed.
  ///
  ///[dataRecords] represents the website data records to delete website data for.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebsiteDataStore.removeData](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532936-removedata))
  ///- MacOS ([Official API - WKWebsiteDataStore.removeData](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532936-removedata))
  ///{@endtemplate}
  Future<void> removeDataFor(
      {required Set<WebsiteDataType> dataTypes,
      required List<WebsiteDataRecord> dataRecords}) {
    throw UnimplementedError(
        'removeDataFor is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManager.removeDataModifiedSince}
  ///Removes all website data of the given types that has been modified since the given date.
  ///
  ///[dataTypes] represents the website data types that should be removed.
  ///
  ///[date] represents a date. All website data modified after this date will be removed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebsiteDataStore.removeData](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata))
  ///- MacOS ([Official API - WKWebsiteDataStore.removeData](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata))
  ///{@endtemplate}
  Future<void> removeDataModifiedSince(
      {required Set<WebsiteDataType> dataTypes, required DateTime date}) {
    throw UnimplementedError(
        'removeDataModifiedSince is not implemented on the current platform');
  }
}
