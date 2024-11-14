// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment_channel_search_kind.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///The channel search kind determines the order that release
///channels are searched for during [PlatformWebViewEnvironment] creation.
class EnvironmentChannelSearchKind {
  final int _value;
  final int _nativeValue;
  const EnvironmentChannelSearchKind._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory EnvironmentChannelSearchKind._internalMultiPlatform(
          int value, Function nativeValue) =>
      EnvironmentChannelSearchKind._internal(value, nativeValue());

  ///Search for a release channel from least to most stable: Canary -> Dev -> Beta -> WebView2 Runtime.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  static final LEAST_STABLE =
      EnvironmentChannelSearchKind._internalMultiPlatform(1, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///Search for a release channel from most to least stable: WebView2 Runtime -> Beta -> Dev -> Canary. This is the default behavior.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  static final MOST_STABLE =
      EnvironmentChannelSearchKind._internalMultiPlatform(0, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 0;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [EnvironmentChannelSearchKind].
  static final Set<EnvironmentChannelSearchKind> values = [
    EnvironmentChannelSearchKind.LEAST_STABLE,
    EnvironmentChannelSearchKind.MOST_STABLE,
  ].toSet();

  ///Gets a possible [EnvironmentChannelSearchKind] instance from [int] value.
  static EnvironmentChannelSearchKind? fromValue(int? value) {
    if (value != null) {
      try {
        return EnvironmentChannelSearchKind.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [EnvironmentChannelSearchKind] instance from a native value.
  static EnvironmentChannelSearchKind? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return EnvironmentChannelSearchKind.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [EnvironmentChannelSearchKind] instance value with name [name].
  ///
  /// Goes through [EnvironmentChannelSearchKind.values] looking for a value with
  /// name [name], as reported by [EnvironmentChannelSearchKind.name].
  /// Returns the first value with the given name, otherwise `null`.
  static EnvironmentChannelSearchKind? byName(String? name) {
    if (name != null) {
      try {
        return EnvironmentChannelSearchKind.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [EnvironmentChannelSearchKind] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, EnvironmentChannelSearchKind> asNameMap() =>
      <String, EnvironmentChannelSearchKind>{
        for (final value in EnvironmentChannelSearchKind.values)
          value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'LEAST_STABLE';
      case 0:
        return 'MOST_STABLE';
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
