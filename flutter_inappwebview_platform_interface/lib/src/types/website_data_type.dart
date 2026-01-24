import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'website_data_type.g.dart';

///Class that represents a website data type.
@ExchangeableEnum()
class WebsiteDataType_ {
  // ignore: unused_field
  final String _value;
  const WebsiteDataType_._internal(this._value);

  ///On-disk Fetch caches.
  ///
  ///**NOTE**: available on iOS 11.3+.
  static const WKWebsiteDataTypeFetchCache = const WebsiteDataType_._internal(
    "WKWebsiteDataTypeFetchCache",
  );

  ///On-disk caches.
  static const WKWebsiteDataTypeDiskCache = const WebsiteDataType_._internal(
    "WKWebsiteDataTypeDiskCache",
  );

  ///In-memory caches.
  static const WKWebsiteDataTypeMemoryCache = const WebsiteDataType_._internal(
    "WKWebsiteDataTypeMemoryCache",
  );

  ///HTML offline web application caches.
  static const WKWebsiteDataTypeOfflineWebApplicationCache =
      const WebsiteDataType_._internal(
        "WKWebsiteDataTypeOfflineWebApplicationCache",
      );

  ///Cookies.
  static const WKWebsiteDataTypeCookies = const WebsiteDataType_._internal(
    "WKWebsiteDataTypeCookies",
  );

  ///HTML session storage.
  static const WKWebsiteDataTypeSessionStorage =
      const WebsiteDataType_._internal("WKWebsiteDataTypeSessionStorage");

  ///HTML local storage.
  static const WKWebsiteDataTypeLocalStorage = const WebsiteDataType_._internal(
    "WKWebsiteDataTypeLocalStorage",
  );

  ///WebSQL databases.
  static const WKWebsiteDataTypeWebSQLDatabases =
      const WebsiteDataType_._internal("WKWebsiteDataTypeWebSQLDatabases");

  ///IndexedDB databases.
  static const WKWebsiteDataTypeIndexedDBDatabases =
      const WebsiteDataType_._internal("WKWebsiteDataTypeIndexedDBDatabases");

  ///Service worker registrations.
  ///
  ///**NOTE**: available on iOS 11.3+.
  static const WKWebsiteDataTypeServiceWorkerRegistrations =
      const WebsiteDataType_._internal(
        "WKWebsiteDataTypeServiceWorkerRegistrations",
      );

  ///Returns a set of all available website data types.
  @ExchangeableEnumCustomValue()
  // ignore: non_constant_identifier_names
  static final Set<WebsiteDataType_> ALL = [
    WebsiteDataType_.WKWebsiteDataTypeFetchCache,
    WebsiteDataType_.WKWebsiteDataTypeDiskCache,
    WebsiteDataType_.WKWebsiteDataTypeMemoryCache,
    WebsiteDataType_.WKWebsiteDataTypeOfflineWebApplicationCache,
    WebsiteDataType_.WKWebsiteDataTypeCookies,
    WebsiteDataType_.WKWebsiteDataTypeSessionStorage,
    WebsiteDataType_.WKWebsiteDataTypeLocalStorage,
    WebsiteDataType_.WKWebsiteDataTypeWebSQLDatabases,
    WebsiteDataType_.WKWebsiteDataTypeIndexedDBDatabases,
    WebsiteDataType_.WKWebsiteDataTypeServiceWorkerRegistrations,
  ].toSet();
}

///Class that represents a website data type.
///
///**NOTE**: available on iOS 9.0+.
///
///Use [WebsiteDataType] instead.
@Deprecated("Use WebsiteDataType instead")
@ExchangeableEnum()
class IOSWKWebsiteDataType_ {
  // ignore: unused_field
  final String _value;
  const IOSWKWebsiteDataType_._internal(this._value);

  ///On-disk Fetch caches.
  ///
  ///**NOTE**: available on iOS 11.3+.
  static const WKWebsiteDataTypeFetchCache =
      const IOSWKWebsiteDataType_._internal("WKWebsiteDataTypeFetchCache");

  ///On-disk caches.
  static const WKWebsiteDataTypeDiskCache =
      const IOSWKWebsiteDataType_._internal("WKWebsiteDataTypeDiskCache");

  ///In-memory caches.
  static const WKWebsiteDataTypeMemoryCache =
      const IOSWKWebsiteDataType_._internal("WKWebsiteDataTypeMemoryCache");

  ///HTML offline web application caches.
  static const WKWebsiteDataTypeOfflineWebApplicationCache =
      const IOSWKWebsiteDataType_._internal(
        "WKWebsiteDataTypeOfflineWebApplicationCache",
      );

  ///Cookies.
  static const WKWebsiteDataTypeCookies = const IOSWKWebsiteDataType_._internal(
    "WKWebsiteDataTypeCookies",
  );

  ///HTML session storage.
  static const WKWebsiteDataTypeSessionStorage =
      const IOSWKWebsiteDataType_._internal("WKWebsiteDataTypeSessionStorage");

  ///HTML local storage.
  static const WKWebsiteDataTypeLocalStorage =
      const IOSWKWebsiteDataType_._internal("WKWebsiteDataTypeLocalStorage");

  ///WebSQL databases.
  static const WKWebsiteDataTypeWebSQLDatabases =
      const IOSWKWebsiteDataType_._internal("WKWebsiteDataTypeWebSQLDatabases");

  ///IndexedDB databases.
  static const WKWebsiteDataTypeIndexedDBDatabases =
      const IOSWKWebsiteDataType_._internal(
        "WKWebsiteDataTypeIndexedDBDatabases",
      );

  ///Service worker registrations.
  ///
  ///**NOTE**: available on iOS 11.3+.
  static const WKWebsiteDataTypeServiceWorkerRegistrations =
      const IOSWKWebsiteDataType_._internal(
        "WKWebsiteDataTypeServiceWorkerRegistrations",
      );

  ///Returns a set of all available website data types.
  @ExchangeableEnumCustomValue()
  // ignore: non_constant_identifier_names
  static final Set<IOSWKWebsiteDataType_> ALL = [
    IOSWKWebsiteDataType_.WKWebsiteDataTypeFetchCache,
    IOSWKWebsiteDataType_.WKWebsiteDataTypeDiskCache,
    IOSWKWebsiteDataType_.WKWebsiteDataTypeMemoryCache,
    IOSWKWebsiteDataType_.WKWebsiteDataTypeOfflineWebApplicationCache,
    IOSWKWebsiteDataType_.WKWebsiteDataTypeCookies,
    IOSWKWebsiteDataType_.WKWebsiteDataTypeSessionStorage,
    IOSWKWebsiteDataType_.WKWebsiteDataTypeLocalStorage,
    IOSWKWebsiteDataType_.WKWebsiteDataTypeWebSQLDatabases,
    IOSWKWebsiteDataType_.WKWebsiteDataTypeIndexedDBDatabases,
    IOSWKWebsiteDataType_.WKWebsiteDataTypeServiceWorkerRegistrations,
  ].toSet();
}
