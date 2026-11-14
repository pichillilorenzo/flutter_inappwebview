// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_authentication_session_error.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the error code for a web authentication session error.
class WebAuthenticationSessionError {
  final int _value;
  final int? _nativeValue;
  const WebAuthenticationSessionError._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory WebAuthenticationSessionError._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => WebAuthenticationSessionError._internal(value, nativeValue());

  ///The login has been canceled.
  static const CANCELED_LOGIN = WebAuthenticationSessionError._internal(1, 1);

  ///The context was invalid.
  static const PRESENTATION_CONTEXT_INVALID =
      WebAuthenticationSessionError._internal(3, 3);

  ///A context wasn’t provided.
  static const PRESENTATION_CONTEXT_NOT_PROVIDED =
      WebAuthenticationSessionError._internal(2, 2);

  ///Set of all values of [WebAuthenticationSessionError].
  static final Set<WebAuthenticationSessionError> values = [
    WebAuthenticationSessionError.CANCELED_LOGIN,
    WebAuthenticationSessionError.PRESENTATION_CONTEXT_INVALID,
    WebAuthenticationSessionError.PRESENTATION_CONTEXT_NOT_PROVIDED,
  ].toSet();

  ///Gets a possible [WebAuthenticationSessionError] instance from [int] value.
  static WebAuthenticationSessionError? fromValue(int? value) {
    if (value != null) {
      try {
        return WebAuthenticationSessionError.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [WebAuthenticationSessionError] instance from a native value.
  static WebAuthenticationSessionError? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return WebAuthenticationSessionError.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [WebAuthenticationSessionError] instance value with name [name].
  ///
  /// Goes through [WebAuthenticationSessionError.values] looking for a value with
  /// name [name], as reported by [WebAuthenticationSessionError.name].
  /// Returns the first value with the given name, otherwise `null`.
  static WebAuthenticationSessionError? byName(String? name) {
    if (name != null) {
      try {
        return WebAuthenticationSessionError.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [WebAuthenticationSessionError] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, WebAuthenticationSessionError> asNameMap() =>
      <String, WebAuthenticationSessionError>{
        for (final value in WebAuthenticationSessionError.values)
          value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'CANCELED_LOGIN';
      case 3:
        return 'PRESENTATION_CONTEXT_INVALID';
      case 2:
        return 'PRESENTATION_CONTEXT_NOT_PROVIDED';
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
