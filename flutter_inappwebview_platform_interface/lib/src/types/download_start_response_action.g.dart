// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_start_response_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class representing the action of a [DownloadStartResponse].
class DownloadStartResponseAction {
  final int _value;
  final int? _nativeValue;
  const DownloadStartResponseAction._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory DownloadStartResponseAction._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => DownloadStartResponseAction._internal(value, nativeValue());

  ///Cancel the download.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///- Linux WPE WebKit
  static final CANCEL = DownloadStartResponseAction._internalMultiPlatform(
    0,
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.windows:
          return 0;
        case TargetPlatform.linux:
          return 0;
        default:
          break;
      }
      return null;
    },
  );

  ///Set of all values of [DownloadStartResponseAction].
  static final Set<DownloadStartResponseAction> values = [
    DownloadStartResponseAction.CANCEL,
  ].toSet();

  ///Gets a possible [DownloadStartResponseAction] instance from [int] value.
  static DownloadStartResponseAction? fromValue(int? value) {
    if (value != null) {
      try {
        return DownloadStartResponseAction.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [DownloadStartResponseAction] instance from a native value.
  static DownloadStartResponseAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return DownloadStartResponseAction.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [DownloadStartResponseAction] instance value with name [name].
  ///
  /// Goes through [DownloadStartResponseAction.values] looking for a value with
  /// name [name], as reported by [DownloadStartResponseAction.name].
  /// Returns the first value with the given name, otherwise `null`.
  static DownloadStartResponseAction? byName(String? name) {
    if (name != null) {
      try {
        return DownloadStartResponseAction.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [DownloadStartResponseAction] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, DownloadStartResponseAction> asNameMap() =>
      <String, DownloadStartResponseAction>{
        for (final value in DownloadStartResponseAction.values)
          value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 0:
        return 'CANCEL';
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
