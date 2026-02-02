// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_archive_format.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the known Web Archive formats used when saving a web page.
class WebArchiveFormat {
  final String _value;
  final String? _nativeValue;
  const WebArchiveFormat._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory WebArchiveFormat._internalMultiPlatform(
    String value,
    Function nativeValue,
  ) => WebArchiveFormat._internal(value, nativeValue());

  ///MHT (MIME HTML) is a web Archive format that saves a web page's HTML code, images, CSS, and scripts into one document, allowing for offline viewing.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- Linux WPE WebKit
  static final MHT = WebArchiveFormat._internalMultiPlatform('mht', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'mht';
      case TargetPlatform.linux:
        return 'mht';
      default:
        break;
    }
    return null;
  });

  ///WebArchive is a web Archive format used primarily on iOS and macOS platforms to save web pages, including HTML content, images, stylesheets, and scripts, into a single file for offline access.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  static final WEBARCHIVE = WebArchiveFormat._internalMultiPlatform(
    'webarchive',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          return 'webarchive';
        case TargetPlatform.macOS:
          return 'webarchive';
        default:
          break;
      }
      return null;
    },
  );

  ///Set of all values of [WebArchiveFormat].
  static final Set<WebArchiveFormat> values = [
    WebArchiveFormat.MHT,
    WebArchiveFormat.WEBARCHIVE,
  ].toSet();

  ///Gets a possible [WebArchiveFormat] instance from [String] value.
  static WebArchiveFormat? fromValue(String? value) {
    if (value != null) {
      try {
        return WebArchiveFormat.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [WebArchiveFormat] instance from a native value.
  static WebArchiveFormat? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return WebArchiveFormat.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [WebArchiveFormat] instance value with name [name].
  ///
  /// Goes through [WebArchiveFormat.values] looking for a value with
  /// name [name], as reported by [WebArchiveFormat.name].
  /// Returns the first value with the given name, otherwise `null`.
  static WebArchiveFormat? byName(String? name) {
    if (name != null) {
      try {
        return WebArchiveFormat.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [WebArchiveFormat] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, WebArchiveFormat> asNameMap() =>
      <String, WebArchiveFormat>{
        for (final value in WebArchiveFormat.values) value.name(): value,
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value if supported by the current platform, otherwise `null`.
  String? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'mht':
        return 'MHT';
      case 'webarchive':
        return 'WEBARCHIVE';
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
