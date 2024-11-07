// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_trust_auth_response_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used by [ServerTrustAuthResponse] class.
class ServerTrustAuthResponseAction {
  final int _value;
  final int _nativeValue;
  const ServerTrustAuthResponseAction._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory ServerTrustAuthResponseAction._internalMultiPlatform(
          int value, Function nativeValue) =>
      ServerTrustAuthResponseAction._internal(value, nativeValue());

  ///Instructs the WebView to cancel the authentication challenge.
  static const CANCEL = ServerTrustAuthResponseAction._internal(0, 0);

  ///Instructs the WebView to proceed with the authentication challenge.
  static const PROCEED = ServerTrustAuthResponseAction._internal(1, 1);

  ///Set of all values of [ServerTrustAuthResponseAction].
  static final Set<ServerTrustAuthResponseAction> values = [
    ServerTrustAuthResponseAction.CANCEL,
    ServerTrustAuthResponseAction.PROCEED,
  ].toSet();

  ///Gets a possible [ServerTrustAuthResponseAction] instance from [int] value.
  static ServerTrustAuthResponseAction? fromValue(int? value) {
    if (value != null) {
      try {
        return ServerTrustAuthResponseAction.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ServerTrustAuthResponseAction] instance from a native value.
  static ServerTrustAuthResponseAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return ServerTrustAuthResponseAction.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [ServerTrustAuthResponseAction] instance value with name [name].
  ///
  /// Goes through [ServerTrustAuthResponseAction.values] looking for a value with
  /// name [name], as reported by [ServerTrustAuthResponseAction.name].
  /// Returns the first value with the given name, otherwise `null`.
  static ServerTrustAuthResponseAction? byName(String? name) {
    if (name != null) {
      try {
        return ServerTrustAuthResponseAction.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [ServerTrustAuthResponseAction] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, ServerTrustAuthResponseAction> asNameMap() =>
      <String, ServerTrustAuthResponseAction>{
        for (final value in ServerTrustAuthResponseAction.values)
          value.name(): value
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
