// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_process_kind.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Indicates the process type used in the [BrowserProcessInfo] interface.
class BrowserProcessKind {
  final int _value;
  final int _nativeValue;
  const BrowserProcessKind._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory BrowserProcessKind._internalMultiPlatform(
          int value, Function nativeValue) =>
      BrowserProcessKind._internal(value, nativeValue());

  ///Indicates the browser process kind.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  static final BROWSER = BrowserProcessKind._internalMultiPlatform(0, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 0;
      default:
        break;
    }
    return null;
  });

  ///Indicates the GPU process kind.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  static final GPU = BrowserProcessKind._internalMultiPlatform(4, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 4;
      default:
        break;
    }
    return null;
  });

  ///Indicates the PPAPI plugin broker process kind.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  static final PPAPI_BROKER = BrowserProcessKind._internalMultiPlatform(6, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 6;
      default:
        break;
    }
    return null;
  });

  ///Indicates the PPAPI plugin process kind.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  static final PPAPI_PLUGIN = BrowserProcessKind._internalMultiPlatform(5, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 5;
      default:
        break;
    }
    return null;
  });

  ///Indicates the render process kind.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  static final RENDERER = BrowserProcessKind._internalMultiPlatform(1, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///Indicates the sandbox helper process kind.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  static final SANDBOX_HELPER =
      BrowserProcessKind._internalMultiPlatform(3, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 3;
      default:
        break;
    }
    return null;
  });

  ///Indicates the utility process kind.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  static final UTILITY = BrowserProcessKind._internalMultiPlatform(2, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 2;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [BrowserProcessKind].
  static final Set<BrowserProcessKind> values = [
    BrowserProcessKind.BROWSER,
    BrowserProcessKind.GPU,
    BrowserProcessKind.PPAPI_BROKER,
    BrowserProcessKind.PPAPI_PLUGIN,
    BrowserProcessKind.RENDERER,
    BrowserProcessKind.SANDBOX_HELPER,
    BrowserProcessKind.UTILITY,
  ].toSet();

  ///Gets a possible [BrowserProcessKind] instance from [int] value.
  static BrowserProcessKind? fromValue(int? value) {
    if (value != null) {
      try {
        return BrowserProcessKind.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return BrowserProcessKind._internal(value, value);
      }
    }
    return null;
  }

  ///Gets a possible [BrowserProcessKind] instance from a native value.
  static BrowserProcessKind? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return BrowserProcessKind.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return BrowserProcessKind._internal(value, value);
      }
    }
    return null;
  }

  /// Gets a possible [BrowserProcessKind] instance value with name [name].
  ///
  /// Goes through [BrowserProcessKind.values] looking for a value with
  /// name [name], as reported by [BrowserProcessKind.name].
  /// Returns the first value with the given name, otherwise `null`.
  static BrowserProcessKind? byName(String? name) {
    if (name != null) {
      try {
        return BrowserProcessKind.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [BrowserProcessKind] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, BrowserProcessKind> asNameMap() =>
      <String, BrowserProcessKind>{
        for (final value in BrowserProcessKind.values) value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 0:
        return 'BROWSER';
      case 4:
        return 'GPU';
      case 6:
        return 'PPAPI_BROKER';
      case 5:
        return 'PPAPI_PLUGIN';
      case 1:
        return 'RENDERER';
      case 3:
        return 'SANDBOX_HELPER';
      case 2:
        return 'UTILITY';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  BrowserProcessKind operator |(BrowserProcessKind value) =>
      BrowserProcessKind._internal(
          value.toValue() | _value, value.toNativeValue() | _nativeValue);
  @override
  String toString() {
    return name();
  }
}
