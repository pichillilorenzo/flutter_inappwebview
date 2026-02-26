// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_resource_request_source_kind.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Constants that describe the source kinds for web resource requests.
class WebResourceRequestSourceKind {
  final int _value;
  final int? _nativeValue;
  const WebResourceRequestSourceKind._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory WebResourceRequestSourceKind._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => WebResourceRequestSourceKind._internal(value, nativeValue());

  ///All request source kinds.
  static const ALL = WebResourceRequestSourceKind._internal(
    4294967295,
    4294967295,
  );

  ///Request originated from a document.
  static const DOCUMENT = WebResourceRequestSourceKind._internal(1, 1);

  ///No request source kind.
  static const NONE = WebResourceRequestSourceKind._internal(0, 0);

  ///Request originated from a service worker.
  static const SERVICE_WORKER = WebResourceRequestSourceKind._internal(4, 4);

  ///Request originated from a shared worker.
  static const SHARED_WORKER = WebResourceRequestSourceKind._internal(2, 2);

  ///Set of all values of [WebResourceRequestSourceKind].
  static final Set<WebResourceRequestSourceKind> values = [
    WebResourceRequestSourceKind.ALL,
    WebResourceRequestSourceKind.DOCUMENT,
    WebResourceRequestSourceKind.NONE,
    WebResourceRequestSourceKind.SERVICE_WORKER,
    WebResourceRequestSourceKind.SHARED_WORKER,
  ].toSet();

  ///Gets a possible [WebResourceRequestSourceKind] instance from [int] value.
  static WebResourceRequestSourceKind? fromValue(int? value) {
    if (value != null) {
      try {
        return WebResourceRequestSourceKind.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [WebResourceRequestSourceKind] instance from a native value.
  static WebResourceRequestSourceKind? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return WebResourceRequestSourceKind.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [WebResourceRequestSourceKind] instance value with name [name].
  ///
  /// Goes through [WebResourceRequestSourceKind.values] looking for a value with
  /// name [name], as reported by [WebResourceRequestSourceKind.name].
  /// Returns the first value with the given name, otherwise `null`.
  static WebResourceRequestSourceKind? byName(String? name) {
    if (name != null) {
      try {
        return WebResourceRequestSourceKind.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [WebResourceRequestSourceKind] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, WebResourceRequestSourceKind> asNameMap() =>
      <String, WebResourceRequestSourceKind>{
        for (final value in WebResourceRequestSourceKind.values)
          value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 4294967295:
        return 'ALL';
      case 1:
        return 'DOCUMENT';
      case 0:
        return 'NONE';
      case 4:
        return 'SERVICE_WORKER';
      case 2:
        return 'SHARED_WORKER';
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
