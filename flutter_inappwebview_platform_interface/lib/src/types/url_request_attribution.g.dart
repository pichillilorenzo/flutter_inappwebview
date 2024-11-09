// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_request_attribution.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the constants used to indicate the entities that can make a network request.
class URLRequestAttribution {
  final int _value;
  final int _nativeValue;
  const URLRequestAttribution._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory URLRequestAttribution._internalMultiPlatform(
          int value, Function nativeValue) =>
      URLRequestAttribution._internal(value, nativeValue());

  ///A developer-initiated network request.
  ///
  ///Use this value for the attribution parameter of a [URLRequest] that your app makes for any purpose other than when the user explicitly accesses a link.
  ///This includes requests that your app makes to get user data. This is the default value.
  ///
  ///For cases where the user enters a URL, like in the navigation bar of a web browser, or taps or clicks a URL to load the content it represents, use the [URLRequestAttribution.USER] value instead.
  static const DEVELOPER = URLRequestAttribution._internal(0, 0);

  ///Use this value for the attribution parameter of a [URLRequest] that satisfies a user request to access an explicit, unmodified URL.
  ///In all other cases, use the [URLRequestAttribution.DEVELOPER] value instead.
  static const USER = URLRequestAttribution._internal(1, 1);

  ///Set of all values of [URLRequestAttribution].
  static final Set<URLRequestAttribution> values = [
    URLRequestAttribution.DEVELOPER,
    URLRequestAttribution.USER,
  ].toSet();

  ///Gets a possible [URLRequestAttribution] instance from [int] value.
  static URLRequestAttribution? fromValue(int? value) {
    if (value != null) {
      try {
        return URLRequestAttribution.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [URLRequestAttribution] instance from a native value.
  static URLRequestAttribution? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return URLRequestAttribution.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [URLRequestAttribution] instance value with name [name].
  ///
  /// Goes through [URLRequestAttribution.values] looking for a value with
  /// name [name], as reported by [URLRequestAttribution.name].
  /// Returns the first value with the given name, otherwise `null`.
  static URLRequestAttribution? byName(String? name) {
    if (name != null) {
      try {
        return URLRequestAttribution.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [URLRequestAttribution] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, URLRequestAttribution> asNameMap() =>
      <String, URLRequestAttribution>{
        for (final value in URLRequestAttribution.values) value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 0:
        return 'DEVELOPER';
      case 1:
        return 'USER';
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
