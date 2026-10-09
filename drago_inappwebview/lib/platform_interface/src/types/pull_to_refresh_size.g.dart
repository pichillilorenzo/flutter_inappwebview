// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_to_refresh_size.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class representing the size of the refresh indicator.
class PullToRefreshSize {
  final int _value;
  final int? _nativeValue;
  const PullToRefreshSize._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory PullToRefreshSize._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => PullToRefreshSize._internal(value, nativeValue());

  ///Default size.
  static const DEFAULT = PullToRefreshSize._internal(1, 1);

  ///Large size.
  static const LARGE = PullToRefreshSize._internal(0, 0);

  ///Set of all values of [PullToRefreshSize].
  static final Set<PullToRefreshSize> values = [
    PullToRefreshSize.DEFAULT,
    PullToRefreshSize.LARGE,
  ].toSet();

  ///Gets a possible [PullToRefreshSize] instance from [int] value.
  static PullToRefreshSize? fromValue(int? value) {
    if (value != null) {
      try {
        return PullToRefreshSize.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [PullToRefreshSize] instance from a native value.
  static PullToRefreshSize? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return PullToRefreshSize.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [PullToRefreshSize] instance value with name [name].
  ///
  /// Goes through [PullToRefreshSize.values] looking for a value with
  /// name [name], as reported by [PullToRefreshSize.name].
  /// Returns the first value with the given name, otherwise `null`.
  static PullToRefreshSize? byName(String? name) {
    if (name != null) {
      try {
        return PullToRefreshSize.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [PullToRefreshSize] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, PullToRefreshSize> asNameMap() =>
      <String, PullToRefreshSize>{
        for (final value in PullToRefreshSize.values) value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'DEFAULT';
      case 0:
        return 'LARGE';
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

///Android-specific class representing the size of the refresh indicator.
///Use [PullToRefreshSize] instead.
@Deprecated('Use PullToRefreshSize instead')
class AndroidPullToRefreshSize {
  final int _value;
  final int? _nativeValue;
  const AndroidPullToRefreshSize._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory AndroidPullToRefreshSize._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => AndroidPullToRefreshSize._internal(value, nativeValue());

  ///Default size.
  static const DEFAULT = AndroidPullToRefreshSize._internal(1, 1);

  ///Large size.
  static const LARGE = AndroidPullToRefreshSize._internal(0, 0);

  ///Set of all values of [AndroidPullToRefreshSize].
  static final Set<AndroidPullToRefreshSize> values = [
    AndroidPullToRefreshSize.DEFAULT,
    AndroidPullToRefreshSize.LARGE,
  ].toSet();

  ///Gets a possible [AndroidPullToRefreshSize] instance from [int] value.
  static AndroidPullToRefreshSize? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidPullToRefreshSize.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [AndroidPullToRefreshSize] instance from a native value.
  static AndroidPullToRefreshSize? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return AndroidPullToRefreshSize.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [AndroidPullToRefreshSize] instance value with name [name].
  ///
  /// Goes through [AndroidPullToRefreshSize.values] looking for a value with
  /// name [name], as reported by [AndroidPullToRefreshSize.name].
  /// Returns the first value with the given name, otherwise `null`.
  static AndroidPullToRefreshSize? byName(String? name) {
    if (name != null) {
      try {
        return AndroidPullToRefreshSize.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [AndroidPullToRefreshSize] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, AndroidPullToRefreshSize> asNameMap() =>
      <String, AndroidPullToRefreshSize>{
        for (final value in AndroidPullToRefreshSize.values)
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
        return 'DEFAULT';
      case 0:
        return 'LARGE';
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
