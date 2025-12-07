// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_cert_response_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used by [ClientCertResponse] class.
class ClientCertResponseAction {
  final int _value;
  final int _nativeValue;
  const ClientCertResponseAction._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory ClientCertResponseAction._internalMultiPlatform(
          int value, Function nativeValue) =>
      ClientCertResponseAction._internal(value, nativeValue());

  ///Cancel this request.
  static const CANCEL = ClientCertResponseAction._internal(0, 0);

  ///Ignore the request for now.
  static const IGNORE = ClientCertResponseAction._internal(2, 2);

  ///Proceed with the specified certificate.
  static const PROCEED = ClientCertResponseAction._internal(1, 1);

  ///Set of all values of [ClientCertResponseAction].
  static final Set<ClientCertResponseAction> values = [
    ClientCertResponseAction.CANCEL,
    ClientCertResponseAction.IGNORE,
    ClientCertResponseAction.PROCEED,
  ].toSet();

  ///Gets a possible [ClientCertResponseAction] instance from [int] value.
  static ClientCertResponseAction? fromValue(int? value) {
    if (value != null) {
      try {
        return ClientCertResponseAction.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ClientCertResponseAction] instance from a native value.
  static ClientCertResponseAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return ClientCertResponseAction.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [ClientCertResponseAction] instance value with name [name].
  ///
  /// Goes through [ClientCertResponseAction.values] looking for a value with
  /// name [name], as reported by [ClientCertResponseAction.name].
  /// Returns the first value with the given name, otherwise `null`.
  static ClientCertResponseAction? byName(String? name) {
    if (name != null) {
      try {
        return ClientCertResponseAction.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [ClientCertResponseAction] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, ClientCertResponseAction> asNameMap() =>
      <String, ClientCertResponseAction>{
        for (final value in ClientCertResponseAction.values) value.name(): value
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
      case 2:
        return 'IGNORE';
      case 1:
        return 'PROCEED';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return true;
  }

  @override
  String toString() {
    return name();
  }
}
