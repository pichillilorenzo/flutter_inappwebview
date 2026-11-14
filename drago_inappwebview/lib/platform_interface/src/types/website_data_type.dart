import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

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
  static const WKWebsiteDataTypeFetchCache = WebsiteDataType_._internal(
    "WKWebsiteDataTypeFetchCache",
  );

  ///On-disk caches.
  static const WKWebsiteDataTypeDiskCache = WebsiteDataType_._internal(
    "WKWebsiteDataTypeDiskCache",
  );

  ///In-memory caches.
  static const WKWebsiteDataTypeMemoryCache = WebsiteDataType_._internal(
    "WKWebsiteDataTypeMemoryCache",
  );

  ///HTML offline web application caches.
  static const WKWebsiteDataTypeOfflineWebApplicationCache =
      WebsiteDataType_._internal(
        "WKWebsiteDataTypeOfflineWebApplicationCache",
      );

  ///Cookies.
  static const WKWebsiteDataTypeCookies = WebsiteDataType_._internal(
    "WKWebsiteDataTypeCookies",
  );

  ///HTML session storage.
  static const WKWebsiteDataTypeSessionStorage =
      WebsiteDataType_._internal("WKWebsiteDataTypeSessionStorage");

  ///HTML local storage.
  static const WKWebsiteDataTypeLocalStorage = WebsiteDataType_._internal(
    "WKWebsiteDataTypeLocalStorage",
  );

  ///WebSQL databases.
  static const WKWebsiteDataTypeWebSQLDatabases =
      WebsiteDataType_._internal("WKWebsiteDataTypeWebSQLDatabases");

  ///IndexedDB databases.
  static const WKWebsiteDataTypeIndexedDBDatabases =
      WebsiteDataType_._internal("WKWebsiteDataTypeIndexedDBDatabases");

  ///Service worker registrations.
  ///
  ///**NOTE**: available on iOS 11.3+.
  static const WKWebsiteDataTypeServiceWorkerRegistrations =
      WebsiteDataType_._internal(
        "WKWebsiteDataTypeServiceWorkerRegistrations",
      );

  ///Returns a set of all available website data types.
  @ExchangeableEnumCustomValue()
  // ignore: non_constant_identifier_names
  static final Set<WebsiteDataType_> ALL = {
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
  };
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
      IOSWKWebsiteDataType_._internal("WKWebsiteDataTypeFetchCache");

  ///On-disk caches.
  static const WKWebsiteDataTypeDiskCache =
      IOSWKWebsiteDataType_._internal("WKWebsiteDataTypeDiskCache");

  ///In-memory caches.
  static const WKWebsiteDataTypeMemoryCache =
      IOSWKWebsiteDataType_._internal("WKWebsiteDataTypeMemoryCache");

  ///HTML offline web application caches.
  static const WKWebsiteDataTypeOfflineWebApplicationCache =
      IOSWKWebsiteDataType_._internal(
        "WKWebsiteDataTypeOfflineWebApplicationCache",
      );

  ///Cookies.
  static const WKWebsiteDataTypeCookies = IOSWKWebsiteDataType_._internal(
    "WKWebsiteDataTypeCookies",
  );

  ///HTML session storage.
  static const WKWebsiteDataTypeSessionStorage =
      IOSWKWebsiteDataType_._internal("WKWebsiteDataTypeSessionStorage");

  ///HTML local storage.
  static const WKWebsiteDataTypeLocalStorage =
      IOSWKWebsiteDataType_._internal("WKWebsiteDataTypeLocalStorage");

  ///WebSQL databases.
  static const WKWebsiteDataTypeWebSQLDatabases =
      IOSWKWebsiteDataType_._internal("WKWebsiteDataTypeWebSQLDatabases");

  ///IndexedDB databases.
  static const WKWebsiteDataTypeIndexedDBDatabases =
      IOSWKWebsiteDataType_._internal(
        "WKWebsiteDataTypeIndexedDBDatabases",
      );

  ///Service worker registrations.
  ///
  ///**NOTE**: available on iOS 11.3+.
  static const WKWebsiteDataTypeServiceWorkerRegistrations =
      IOSWKWebsiteDataType_._internal(
        "WKWebsiteDataTypeServiceWorkerRegistrations",
      );

  ///Returns a set of all available website data types.
  @ExchangeableEnumCustomValue()
  // ignore: non_constant_identifier_names
  static final Set<IOSWKWebsiteDataType_> ALL = {
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
  };
}
