// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment_release_channels.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///The WebView2 release channels searched for during [PlatformWebViewEnvironment] creation.
class EnvironmentReleaseChannels {
  final int _value;
  final int? _nativeValue;
  const EnvironmentReleaseChannels._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory EnvironmentReleaseChannels._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => EnvironmentReleaseChannels._internal(value, nativeValue());

  ///The Beta release channel that is released every 4 weeks, a week before the stable release.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  static final BETA = EnvironmentReleaseChannels._internalMultiPlatform(2, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 2;
      default:
        break;
    }
    return null;
  });

  ///The Canary release channel that is released daily.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  static final CANARY = EnvironmentReleaseChannels._internalMultiPlatform(
    8,
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.windows:
          return 8;
        default:
          break;
      }
      return null;
    },
  );

  ///The Dev release channel that is released weekly.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  static final DEV = EnvironmentReleaseChannels._internalMultiPlatform(4, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 4;
      default:
        break;
    }
    return null;
  });

  ///No release channel. Passing only this value results in `HRESULT_FROM_WIN32(ERROR_FILE_NOT_FOUND)`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  static final NONE = EnvironmentReleaseChannels._internalMultiPlatform(0, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 0;
      default:
        break;
    }
    return null;
  });

  ///The stable WebView2 Runtime that is released every 4 weeks.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  static final STABLE = EnvironmentReleaseChannels._internalMultiPlatform(
    1,
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.windows:
          return 1;
        default:
          break;
      }
      return null;
    },
  );

  ///Set of all values of [EnvironmentReleaseChannels].
  static final Set<EnvironmentReleaseChannels> values = [
    EnvironmentReleaseChannels.BETA,
    EnvironmentReleaseChannels.CANARY,
    EnvironmentReleaseChannels.DEV,
    EnvironmentReleaseChannels.NONE,
    EnvironmentReleaseChannels.STABLE,
  ].toSet();

  ///Gets a possible [EnvironmentReleaseChannels] instance from [int] value.
  static EnvironmentReleaseChannels? fromValue(int? value) {
    if (value != null) {
      try {
        return EnvironmentReleaseChannels.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return EnvironmentReleaseChannels._internal(value, value);
      }
    }
    return null;
  }

  ///Gets a possible [EnvironmentReleaseChannels] instance from a native value.
  static EnvironmentReleaseChannels? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return EnvironmentReleaseChannels.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [EnvironmentReleaseChannels] instance value with name [name].
  ///
  /// Goes through [EnvironmentReleaseChannels.values] looking for a value with
  /// name [name], as reported by [EnvironmentReleaseChannels.name].
  /// Returns the first value with the given name, otherwise `null`.
  static EnvironmentReleaseChannels? byName(String? name) {
    if (name != null) {
      try {
        return EnvironmentReleaseChannels.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [EnvironmentReleaseChannels] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, EnvironmentReleaseChannels> asNameMap() =>
      <String, EnvironmentReleaseChannels>{
        for (final value in EnvironmentReleaseChannels.values)
          value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 2:
        return 'BETA';
      case 8:
        return 'CANARY';
      case 4:
        return 'DEV';
      case 0:
        return 'NONE';
      case 1:
        return 'STABLE';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  EnvironmentReleaseChannels operator |(EnvironmentReleaseChannels value) =>
      EnvironmentReleaseChannels._internal(
        value.toValue() | _value,
        value.toNativeValue() != null && _nativeValue != null
            ? value.toNativeValue()! | _nativeValue!
            : null,
      );

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return _nativeValue != null;
  }

  @override
  String toString() {
    return name();
  }
}
