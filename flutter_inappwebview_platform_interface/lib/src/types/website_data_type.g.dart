// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_data_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents a website data type.
class WebsiteDataType {
  final String _value;
  final String? _nativeValue;
  const WebsiteDataType._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory WebsiteDataType._internalMultiPlatform(
    String value,
    Function nativeValue,
  ) => WebsiteDataType._internal(value, nativeValue());

  ///Returns a set of all available website data types.
  static final ALL = [
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

  ///Cookies.
  static const WKWebsiteDataTypeCookies = WebsiteDataType._internal(
    'WKWebsiteDataTypeCookies',
    'WKWebsiteDataTypeCookies',
  );

  ///On-disk caches.
  static const WKWebsiteDataTypeDiskCache = WebsiteDataType._internal(
    'WKWebsiteDataTypeDiskCache',
    'WKWebsiteDataTypeDiskCache',
  );

  ///On-disk Fetch caches.
  ///
  ///**NOTE**: available on iOS 11.3+.
  static const WKWebsiteDataTypeFetchCache = WebsiteDataType._internal(
    'WKWebsiteDataTypeFetchCache',
    'WKWebsiteDataTypeFetchCache',
  );

  ///IndexedDB databases.
  static const WKWebsiteDataTypeIndexedDBDatabases = WebsiteDataType._internal(
    'WKWebsiteDataTypeIndexedDBDatabases',
    'WKWebsiteDataTypeIndexedDBDatabases',
  );

  ///HTML local storage.
  static const WKWebsiteDataTypeLocalStorage = WebsiteDataType._internal(
    'WKWebsiteDataTypeLocalStorage',
    'WKWebsiteDataTypeLocalStorage',
  );

  ///In-memory caches.
  static const WKWebsiteDataTypeMemoryCache = WebsiteDataType._internal(
    'WKWebsiteDataTypeMemoryCache',
    'WKWebsiteDataTypeMemoryCache',
  );

  ///HTML offline web application caches.
  static const WKWebsiteDataTypeOfflineWebApplicationCache =
      WebsiteDataType._internal(
        'WKWebsiteDataTypeOfflineWebApplicationCache',
        'WKWebsiteDataTypeOfflineWebApplicationCache',
      );

  ///Service worker registrations.
  ///
  ///**NOTE**: available on iOS 11.3+.
  static const WKWebsiteDataTypeServiceWorkerRegistrations =
      WebsiteDataType._internal(
        'WKWebsiteDataTypeServiceWorkerRegistrations',
        'WKWebsiteDataTypeServiceWorkerRegistrations',
      );

  ///HTML session storage.
  static const WKWebsiteDataTypeSessionStorage = WebsiteDataType._internal(
    'WKWebsiteDataTypeSessionStorage',
    'WKWebsiteDataTypeSessionStorage',
  );

  ///WebSQL databases.
  static const WKWebsiteDataTypeWebSQLDatabases = WebsiteDataType._internal(
    'WKWebsiteDataTypeWebSQLDatabases',
    'WKWebsiteDataTypeWebSQLDatabases',
  );

  ///Set of all values of [WebsiteDataType].
  static final Set<WebsiteDataType> values = [
    WebsiteDataType.WKWebsiteDataTypeCookies,
    WebsiteDataType.WKWebsiteDataTypeDiskCache,
    WebsiteDataType.WKWebsiteDataTypeFetchCache,
    WebsiteDataType.WKWebsiteDataTypeIndexedDBDatabases,
    WebsiteDataType.WKWebsiteDataTypeLocalStorage,
    WebsiteDataType.WKWebsiteDataTypeMemoryCache,
    WebsiteDataType.WKWebsiteDataTypeOfflineWebApplicationCache,
    WebsiteDataType.WKWebsiteDataTypeServiceWorkerRegistrations,
    WebsiteDataType.WKWebsiteDataTypeSessionStorage,
    WebsiteDataType.WKWebsiteDataTypeWebSQLDatabases,
  ].toSet();

  ///Gets a possible [WebsiteDataType] instance from [String] value.
  static WebsiteDataType? fromValue(String? value) {
    if (value != null) {
      try {
        return WebsiteDataType.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [WebsiteDataType] instance from a native value.
  static WebsiteDataType? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return WebsiteDataType.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [WebsiteDataType] instance value with name [name].
  ///
  /// Goes through [WebsiteDataType.values] looking for a value with
  /// name [name], as reported by [WebsiteDataType.name].
  /// Returns the first value with the given name, otherwise `null`.
  static WebsiteDataType? byName(String? name) {
    if (name != null) {
      try {
        return WebsiteDataType.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [WebsiteDataType] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, WebsiteDataType> asNameMap() => <String, WebsiteDataType>{
    for (final value in WebsiteDataType.values) value.name(): value,
  };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value if supported by the current platform, otherwise `null`.
  String? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'WKWebsiteDataTypeCookies':
        return 'WKWebsiteDataTypeCookies';
      case 'WKWebsiteDataTypeDiskCache':
        return 'WKWebsiteDataTypeDiskCache';
      case 'WKWebsiteDataTypeFetchCache':
        return 'WKWebsiteDataTypeFetchCache';
      case 'WKWebsiteDataTypeIndexedDBDatabases':
        return 'WKWebsiteDataTypeIndexedDBDatabases';
      case 'WKWebsiteDataTypeLocalStorage':
        return 'WKWebsiteDataTypeLocalStorage';
      case 'WKWebsiteDataTypeMemoryCache':
        return 'WKWebsiteDataTypeMemoryCache';
      case 'WKWebsiteDataTypeOfflineWebApplicationCache':
        return 'WKWebsiteDataTypeOfflineWebApplicationCache';
      case 'WKWebsiteDataTypeServiceWorkerRegistrations':
        return 'WKWebsiteDataTypeServiceWorkerRegistrations';
      case 'WKWebsiteDataTypeSessionStorage':
        return 'WKWebsiteDataTypeSessionStorage';
      case 'WKWebsiteDataTypeWebSQLDatabases':
        return 'WKWebsiteDataTypeWebSQLDatabases';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return _nativeValue != null;
  }

  @override
  String toString() {
    return _value;
  }
}

///Class that represents a website data type.
///
///**NOTE**: available on iOS 9.0+.
///
///Use [WebsiteDataType] instead.
@Deprecated('Use WebsiteDataType instead')
class IOSWKWebsiteDataType {
  final String _value;
  final String? _nativeValue;
  const IOSWKWebsiteDataType._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory IOSWKWebsiteDataType._internalMultiPlatform(
    String value,
    Function nativeValue,
  ) => IOSWKWebsiteDataType._internal(value, nativeValue());

  ///Returns a set of all available website data types.
  static final ALL = [
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

  ///Cookies.
  static const WKWebsiteDataTypeCookies = IOSWKWebsiteDataType._internal(
    'WKWebsiteDataTypeCookies',
    'WKWebsiteDataTypeCookies',
  );

  ///On-disk caches.
  static const WKWebsiteDataTypeDiskCache = IOSWKWebsiteDataType._internal(
    'WKWebsiteDataTypeDiskCache',
    'WKWebsiteDataTypeDiskCache',
  );

  ///On-disk Fetch caches.
  ///
  ///**NOTE**: available on iOS 11.3+.
  static const WKWebsiteDataTypeFetchCache = IOSWKWebsiteDataType._internal(
    'WKWebsiteDataTypeFetchCache',
    'WKWebsiteDataTypeFetchCache',
  );

  ///IndexedDB databases.
  static const WKWebsiteDataTypeIndexedDBDatabases =
      IOSWKWebsiteDataType._internal(
        'WKWebsiteDataTypeIndexedDBDatabases',
        'WKWebsiteDataTypeIndexedDBDatabases',
      );

  ///HTML local storage.
  static const WKWebsiteDataTypeLocalStorage = IOSWKWebsiteDataType._internal(
    'WKWebsiteDataTypeLocalStorage',
    'WKWebsiteDataTypeLocalStorage',
  );

  ///In-memory caches.
  static const WKWebsiteDataTypeMemoryCache = IOSWKWebsiteDataType._internal(
    'WKWebsiteDataTypeMemoryCache',
    'WKWebsiteDataTypeMemoryCache',
  );

  ///HTML offline web application caches.
  static const WKWebsiteDataTypeOfflineWebApplicationCache =
      IOSWKWebsiteDataType._internal(
        'WKWebsiteDataTypeOfflineWebApplicationCache',
        'WKWebsiteDataTypeOfflineWebApplicationCache',
      );

  ///Service worker registrations.
  ///
  ///**NOTE**: available on iOS 11.3+.
  static const WKWebsiteDataTypeServiceWorkerRegistrations =
      IOSWKWebsiteDataType._internal(
        'WKWebsiteDataTypeServiceWorkerRegistrations',
        'WKWebsiteDataTypeServiceWorkerRegistrations',
      );

  ///HTML session storage.
  static const WKWebsiteDataTypeSessionStorage = IOSWKWebsiteDataType._internal(
    'WKWebsiteDataTypeSessionStorage',
    'WKWebsiteDataTypeSessionStorage',
  );

  ///WebSQL databases.
  static const WKWebsiteDataTypeWebSQLDatabases =
      IOSWKWebsiteDataType._internal(
        'WKWebsiteDataTypeWebSQLDatabases',
        'WKWebsiteDataTypeWebSQLDatabases',
      );

  ///Set of all values of [IOSWKWebsiteDataType].
  static final Set<IOSWKWebsiteDataType> values = [
    IOSWKWebsiteDataType.WKWebsiteDataTypeCookies,
    IOSWKWebsiteDataType.WKWebsiteDataTypeDiskCache,
    IOSWKWebsiteDataType.WKWebsiteDataTypeFetchCache,
    IOSWKWebsiteDataType.WKWebsiteDataTypeIndexedDBDatabases,
    IOSWKWebsiteDataType.WKWebsiteDataTypeLocalStorage,
    IOSWKWebsiteDataType.WKWebsiteDataTypeMemoryCache,
    IOSWKWebsiteDataType.WKWebsiteDataTypeOfflineWebApplicationCache,
    IOSWKWebsiteDataType.WKWebsiteDataTypeServiceWorkerRegistrations,
    IOSWKWebsiteDataType.WKWebsiteDataTypeSessionStorage,
    IOSWKWebsiteDataType.WKWebsiteDataTypeWebSQLDatabases,
  ].toSet();

  ///Gets a possible [IOSWKWebsiteDataType] instance from [String] value.
  static IOSWKWebsiteDataType? fromValue(String? value) {
    if (value != null) {
      try {
        return IOSWKWebsiteDataType.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [IOSWKWebsiteDataType] instance from a native value.
  static IOSWKWebsiteDataType? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return IOSWKWebsiteDataType.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [IOSWKWebsiteDataType] instance value with name [name].
  ///
  /// Goes through [IOSWKWebsiteDataType.values] looking for a value with
  /// name [name], as reported by [IOSWKWebsiteDataType.name].
  /// Returns the first value with the given name, otherwise `null`.
  static IOSWKWebsiteDataType? byName(String? name) {
    if (name != null) {
      try {
        return IOSWKWebsiteDataType.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [IOSWKWebsiteDataType] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, IOSWKWebsiteDataType> asNameMap() =>
      <String, IOSWKWebsiteDataType>{
        for (final value in IOSWKWebsiteDataType.values) value.name(): value,
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value if supported by the current platform, otherwise `null`.
  String? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'WKWebsiteDataTypeCookies':
        return 'WKWebsiteDataTypeCookies';
      case 'WKWebsiteDataTypeDiskCache':
        return 'WKWebsiteDataTypeDiskCache';
      case 'WKWebsiteDataTypeFetchCache':
        return 'WKWebsiteDataTypeFetchCache';
      case 'WKWebsiteDataTypeIndexedDBDatabases':
        return 'WKWebsiteDataTypeIndexedDBDatabases';
      case 'WKWebsiteDataTypeLocalStorage':
        return 'WKWebsiteDataTypeLocalStorage';
      case 'WKWebsiteDataTypeMemoryCache':
        return 'WKWebsiteDataTypeMemoryCache';
      case 'WKWebsiteDataTypeOfflineWebApplicationCache':
        return 'WKWebsiteDataTypeOfflineWebApplicationCache';
      case 'WKWebsiteDataTypeServiceWorkerRegistrations':
        return 'WKWebsiteDataTypeServiceWorkerRegistrations';
      case 'WKWebsiteDataTypeSessionStorage':
        return 'WKWebsiteDataTypeSessionStorage';
      case 'WKWebsiteDataTypeWebSQLDatabases':
        return 'WKWebsiteDataTypeWebSQLDatabases';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return _nativeValue != null;
  }

  @override
  String toString() {
    return _value;
  }
}
