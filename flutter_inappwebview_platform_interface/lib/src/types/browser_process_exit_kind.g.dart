// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_process_exit_kind.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///The kind of browser process exit that has occurred.
class BrowserProcessExitKind {
  final int _value;
  final int? _nativeValue;
  const BrowserProcessExitKind._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory BrowserProcessExitKind._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => BrowserProcessExitKind._internal(value, nativeValue());

  ///Indicates that the browser process ended unexpectedly.
  ///A [PlatformWebViewCreationParams.onProcessFailed] event will also be
  ///raised to listening WebViews from the [PlatformWebViewEnvironment] associated to the failed process.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  static final FAILED = BrowserProcessExitKind._internalMultiPlatform(1, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///Indicates that the browser process ended normally.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  static final NORMAL = BrowserProcessExitKind._internalMultiPlatform(0, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 0;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [BrowserProcessExitKind].
  static final Set<BrowserProcessExitKind> values = [
    BrowserProcessExitKind.FAILED,
    BrowserProcessExitKind.NORMAL,
  ].toSet();

  ///Gets a possible [BrowserProcessExitKind] instance from [int] value.
  static BrowserProcessExitKind? fromValue(int? value) {
    if (value != null) {
      try {
        return BrowserProcessExitKind.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return BrowserProcessExitKind._internal(value, value);
      }
    }
    return null;
  }

  ///Gets a possible [BrowserProcessExitKind] instance from a native value.
  static BrowserProcessExitKind? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return BrowserProcessExitKind.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [BrowserProcessExitKind] instance value with name [name].
  ///
  /// Goes through [BrowserProcessExitKind.values] looking for a value with
  /// name [name], as reported by [BrowserProcessExitKind.name].
  /// Returns the first value with the given name, otherwise `null`.
  static BrowserProcessExitKind? byName(String? name) {
    if (name != null) {
      try {
        return BrowserProcessExitKind.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [BrowserProcessExitKind] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, BrowserProcessExitKind> asNameMap() =>
      <String, BrowserProcessExitKind>{
        for (final value in BrowserProcessExitKind.values) value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'FAILED';
      case 0:
        return 'NORMAL';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  BrowserProcessExitKind operator |(BrowserProcessExitKind value) =>
      BrowserProcessExitKind._internal(
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
