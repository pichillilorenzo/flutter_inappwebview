///Class that represents a website data type.
class WebsiteDataType {
  final String _value;

  const WebsiteDataType._internal(this._value);

  ///Set of all values of [WebsiteDataType].
  static final Set<WebsiteDataType> values = [
    WebsiteDataType.WKWebsiteDataTypeFetchCache,
    WebsiteDataType.WKWebsiteDataTypeDiskCache,
    WebsiteDataType.WKWebsiteDataTypeMemoryCache,
    WebsiteDataType.WKWebsiteDataTypeOfflineWebApplicationCache,
    WebsiteDataType.WKWebsiteDataTypeCookies,
    WebsiteDataType.WKWebsiteDataTypeSessionStorage,
    WebsiteDataType.WKWebsiteDataTypeLocalStorage,
    WebsiteDataType.WKWebsiteDataTypeWebSQLDatabases,
    WebsiteDataType.WKWebsiteDataTypeIndexedDBDatabases,
    WebsiteDataType.WKWebsiteDataTypeServiceWorkerRegistrations,
  ].toSet();

  ///Gets a possible [WebsiteDataType] instance from a [String] value.
  static WebsiteDataType? fromValue(String? value) {
    if (value != null) {
      try {
        return WebsiteDataType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  @override
  String toString() => _value;

  ///On-disk Fetch caches.
  ///
  ///**NOTE**: available on iOS 11.3+.
  static const WKWebsiteDataTypeFetchCache =
  const WebsiteDataType._internal("WKWebsiteDataTypeFetchCache");

  ///On-disk caches.
  static const WKWebsiteDataTypeDiskCache =
  const WebsiteDataType._internal("WKWebsiteDataTypeDiskCache");

  ///In-memory caches.
  static const WKWebsiteDataTypeMemoryCache =
  const WebsiteDataType._internal("WKWebsiteDataTypeMemoryCache");

  ///HTML offline web application caches.
  static const WKWebsiteDataTypeOfflineWebApplicationCache =
  const WebsiteDataType._internal(
      "WKWebsiteDataTypeOfflineWebApplicationCache");

  ///Cookies.
  static const WKWebsiteDataTypeCookies =
  const WebsiteDataType._internal("WKWebsiteDataTypeCookies");

  ///HTML session storage.
  static const WKWebsiteDataTypeSessionStorage =
  const WebsiteDataType._internal("WKWebsiteDataTypeSessionStorage");

  ///HTML local storage.
  static const WKWebsiteDataTypeLocalStorage =
  const WebsiteDataType._internal("WKWebsiteDataTypeLocalStorage");

  ///WebSQL databases.
  static const WKWebsiteDataTypeWebSQLDatabases =
  const WebsiteDataType._internal("WKWebsiteDataTypeWebSQLDatabases");

  ///IndexedDB databases.
  static const WKWebsiteDataTypeIndexedDBDatabases =
  const WebsiteDataType._internal("WKWebsiteDataTypeIndexedDBDatabases");

  ///Service worker registrations.
  ///
  ///**NOTE**: available on iOS 11.3+.
  static const WKWebsiteDataTypeServiceWorkerRegistrations =
  const WebsiteDataType._internal(
      "WKWebsiteDataTypeServiceWorkerRegistrations");

  ///Returns a set of all available website data types.
  // ignore: non_constant_identifier_names
  static final Set<WebsiteDataType> ALL = [
    WebsiteDataType.WKWebsiteDataTypeFetchCache,
    WebsiteDataType.WKWebsiteDataTypeDiskCache,
    WebsiteDataType.WKWebsiteDataTypeMemoryCache,
    WebsiteDataType.WKWebsiteDataTypeOfflineWebApplicationCache,
    WebsiteDataType.WKWebsiteDataTypeCookies,
    WebsiteDataType.WKWebsiteDataTypeSessionStorage,
    WebsiteDataType.WKWebsiteDataTypeLocalStorage,
    WebsiteDataType.WKWebsiteDataTypeWebSQLDatabases,
    WebsiteDataType.WKWebsiteDataTypeIndexedDBDatabases,
    WebsiteDataType.WKWebsiteDataTypeServiceWorkerRegistrations
  ].toSet();

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents a website data type.
///
///**NOTE**: available on iOS 9.0+.
///
///Use [WebsiteDataType] instead.
@Deprecated("Use WebsiteDataType instead")
class IOSWKWebsiteDataType {
  final String _value;

  const IOSWKWebsiteDataType._internal(this._value);

  ///Set of all values of [IOSWKWebsiteDataType].
  static final Set<IOSWKWebsiteDataType> values = [
    IOSWKWebsiteDataType.WKWebsiteDataTypeFetchCache,
    IOSWKWebsiteDataType.WKWebsiteDataTypeDiskCache,
    IOSWKWebsiteDataType.WKWebsiteDataTypeMemoryCache,
    IOSWKWebsiteDataType.WKWebsiteDataTypeOfflineWebApplicationCache,
    IOSWKWebsiteDataType.WKWebsiteDataTypeCookies,
    IOSWKWebsiteDataType.WKWebsiteDataTypeSessionStorage,
    IOSWKWebsiteDataType.WKWebsiteDataTypeLocalStorage,
    IOSWKWebsiteDataType.WKWebsiteDataTypeWebSQLDatabases,
    IOSWKWebsiteDataType.WKWebsiteDataTypeIndexedDBDatabases,
    IOSWKWebsiteDataType.WKWebsiteDataTypeServiceWorkerRegistrations,
  ].toSet();

  ///Gets a possible [IOSWKWebsiteDataType] instance from a [String] value.
  static IOSWKWebsiteDataType? fromValue(String? value) {
    if (value != null) {
      try {
        return IOSWKWebsiteDataType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  @override
  String toString() => _value;

  ///On-disk Fetch caches.
  ///
  ///**NOTE**: available on iOS 11.3+.
  static const WKWebsiteDataTypeFetchCache =
  const IOSWKWebsiteDataType._internal("WKWebsiteDataTypeFetchCache");

  ///On-disk caches.
  static const WKWebsiteDataTypeDiskCache =
  const IOSWKWebsiteDataType._internal("WKWebsiteDataTypeDiskCache");

  ///In-memory caches.
  static const WKWebsiteDataTypeMemoryCache =
  const IOSWKWebsiteDataType._internal("WKWebsiteDataTypeMemoryCache");

  ///HTML offline web application caches.
  static const WKWebsiteDataTypeOfflineWebApplicationCache =
  const IOSWKWebsiteDataType._internal(
      "WKWebsiteDataTypeOfflineWebApplicationCache");

  ///Cookies.
  static const WKWebsiteDataTypeCookies =
  const IOSWKWebsiteDataType._internal("WKWebsiteDataTypeCookies");

  ///HTML session storage.
  static const WKWebsiteDataTypeSessionStorage =
  const IOSWKWebsiteDataType._internal("WKWebsiteDataTypeSessionStorage");

  ///HTML local storage.
  static const WKWebsiteDataTypeLocalStorage =
  const IOSWKWebsiteDataType._internal("WKWebsiteDataTypeLocalStorage");

  ///WebSQL databases.
  static const WKWebsiteDataTypeWebSQLDatabases =
  const IOSWKWebsiteDataType._internal("WKWebsiteDataTypeWebSQLDatabases");

  ///IndexedDB databases.
  static const WKWebsiteDataTypeIndexedDBDatabases =
  const IOSWKWebsiteDataType._internal(
      "WKWebsiteDataTypeIndexedDBDatabases");

  ///Service worker registrations.
  ///
  ///**NOTE**: available on iOS 11.3+.
  static const WKWebsiteDataTypeServiceWorkerRegistrations =
  const IOSWKWebsiteDataType._internal(
      "WKWebsiteDataTypeServiceWorkerRegistrations");

  ///Returns a set of all available website data types.
  // ignore: non_constant_identifier_names
  static final Set<IOSWKWebsiteDataType> ALL = [
    IOSWKWebsiteDataType.WKWebsiteDataTypeFetchCache,
    IOSWKWebsiteDataType.WKWebsiteDataTypeDiskCache,
    IOSWKWebsiteDataType.WKWebsiteDataTypeMemoryCache,
    IOSWKWebsiteDataType.WKWebsiteDataTypeOfflineWebApplicationCache,
    IOSWKWebsiteDataType.WKWebsiteDataTypeCookies,
    IOSWKWebsiteDataType.WKWebsiteDataTypeSessionStorage,
    IOSWKWebsiteDataType.WKWebsiteDataTypeLocalStorage,
    IOSWKWebsiteDataType.WKWebsiteDataTypeWebSQLDatabases,
    IOSWKWebsiteDataType.WKWebsiteDataTypeIndexedDBDatabases,
    IOSWKWebsiteDataType.WKWebsiteDataTypeServiceWorkerRegistrations
  ].toSet();

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}