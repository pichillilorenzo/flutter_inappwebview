// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_auth_response_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used by [HttpAuthResponse] class.
class HttpAuthResponseAction {
  final int _value;
  final int _nativeValue;
  const HttpAuthResponseAction._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory HttpAuthResponseAction._internalMultiPlatform(
          int value, Function nativeValue) =>
      HttpAuthResponseAction._internal(value, nativeValue());

  ///Instructs the WebView to cancel the authentication request.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  static const CANCEL = HttpAuthResponseAction._internal(0, 0);

  ///Instructs the WebView to proceed with the authentication with the given credentials.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  static const PROCEED = HttpAuthResponseAction._internal(1, 1);

  ///Uses the credentials stored for the current host.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  static const USE_SAVED_HTTP_AUTH_CREDENTIALS =
      HttpAuthResponseAction._internal(2, 2);

  ///Set of all values of [HttpAuthResponseAction].
  static final Set<HttpAuthResponseAction> values = [
    HttpAuthResponseAction.CANCEL,
    HttpAuthResponseAction.PROCEED,
    HttpAuthResponseAction.USE_SAVED_HTTP_AUTH_CREDENTIALS,
  ].toSet();

  ///Gets a possible [HttpAuthResponseAction] instance from [int] value.
  static HttpAuthResponseAction? fromValue(int? value) {
    if (value != null) {
      try {
        return HttpAuthResponseAction.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [HttpAuthResponseAction] instance from a native value.
  static HttpAuthResponseAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return HttpAuthResponseAction.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [HttpAuthResponseAction] instance value with name [name].
  ///
  /// Goes through [HttpAuthResponseAction.values] looking for a value with
  /// name [name], as reported by [HttpAuthResponseAction.name].
  /// Returns the first value with the given name, otherwise `null`.
  static HttpAuthResponseAction? byName(String? name) {
    if (name != null) {
      try {
        return HttpAuthResponseAction.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [HttpAuthResponseAction] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, HttpAuthResponseAction> asNameMap() =>
      <String, HttpAuthResponseAction>{
        for (final value in HttpAuthResponseAction.values) value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 0:
        return 'CANCEL';
      case 1:
        return 'PROCEED';
      case 2:
        return 'USE_SAVED_HTTP_AUTH_CREDENTIALS';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return name();
  }
}
