// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_model.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Cache model for WebKitWebContext.
///
///Determines how caching is handled for web content.
class CacheModel {
  final int _value;
  final int? _nativeValue;
  const CacheModel._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory CacheModel._internalMultiPlatform(int value, Function nativeValue) =>
      CacheModel._internal(value, nativeValue());

  ///A cache model optimized for viewing a series of local files, such as ebooks,
  ///without browsing a variety of online content.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - WEBKIT_CACHE_MODEL_DOCUMENT_BROWSER](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/enum.CacheModel.html))
  static final DOCUMENT_BROWSER = CacheModel._internalMultiPlatform(2, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
        return 2;
      default:
        break;
    }
    return null;
  });

  ///Disable the cache completely, which is useful for ephemeral applications
  ///or applications without a persistent data storage.
  ///Using this cache model can have important security implications for your application.
  ///All pages are loaded from the server without caching.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - WEBKIT_CACHE_MODEL_DOCUMENT_VIEWER](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/enum.CacheModel.html))
  static final DOCUMENT_VIEWER = CacheModel._internalMultiPlatform(0, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
        return 0;
      default:
        break;
    }
    return null;
  });

  ///Improves document load speed substantially by caching a very large number of resources
  ///and previously visited content. This mode is optimal for web browser applications.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - WEBKIT_CACHE_MODEL_WEB_BROWSER](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/enum.CacheModel.html))
  static final WEB_BROWSER = CacheModel._internalMultiPlatform(1, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [CacheModel].
  static final Set<CacheModel> values = [
    CacheModel.DOCUMENT_BROWSER,
    CacheModel.DOCUMENT_VIEWER,
    CacheModel.WEB_BROWSER,
  ].toSet();

  ///Gets a possible [CacheModel] instance from [int] value.
  static CacheModel? fromValue(int? value) {
    if (value != null) {
      try {
        return CacheModel.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [CacheModel] instance from a native value.
  static CacheModel? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return CacheModel.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [CacheModel] instance value with name [name].
  ///
  /// Goes through [CacheModel.values] looking for a value with
  /// name [name], as reported by [CacheModel.name].
  /// Returns the first value with the given name, otherwise `null`.
  static CacheModel? byName(String? name) {
    if (name != null) {
      try {
        return CacheModel.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [CacheModel] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, CacheModel> asNameMap() => <String, CacheModel>{
    for (final value in CacheModel.values) value.name(): value,
  };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 2:
        return 'DOCUMENT_BROWSER';
      case 0:
        return 'DOCUMENT_VIEWER';
      case 1:
        return 'WEB_BROWSER';
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
    return name();
  }
}
