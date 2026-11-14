// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_state.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class representing the state of a native download reported by [DownloadProgress].
class DownloadState {
  final int _value;
  final int? _nativeValue;
  const DownloadState._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory DownloadState._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => DownloadState._internal(value, nativeValue());

  ///The download was canceled.
  static const CANCELED = DownloadState._internal(3, 3);

  ///The download completed successfully.
  static const COMPLETED = DownloadState._internal(1, 1);

  ///The download failed. See [DownloadProgress.error].
  static const FAILED = DownloadState._internal(2, 2);

  ///The download is in progress.
  static const IN_PROGRESS = DownloadState._internal(0, 0);

  ///Set of all values of [DownloadState].
  static final Set<DownloadState> values = [
    DownloadState.CANCELED,
    DownloadState.COMPLETED,
    DownloadState.FAILED,
    DownloadState.IN_PROGRESS,
  ].toSet();

  ///Gets a possible [DownloadState] instance from [int] value.
  static DownloadState? fromValue(int? value) {
    if (value != null) {
      try {
        return DownloadState.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [DownloadState] instance from a native value.
  static DownloadState? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return DownloadState.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [DownloadState] instance value with name [name].
  ///
  /// Goes through [DownloadState.values] looking for a value with
  /// name [name], as reported by [DownloadState.name].
  /// Returns the first value with the given name, otherwise `null`.
  static DownloadState? byName(String? name) {
    if (name != null) {
      try {
        return DownloadState.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [DownloadState] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, DownloadState> asNameMap() => <String, DownloadState>{
    for (final value in DownloadState.values) value.name(): value,
  };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 3:
        return 'CANCELED';
      case 1:
        return 'COMPLETED';
      case 2:
        return 'FAILED';
      case 0:
        return 'IN_PROGRESS';
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
