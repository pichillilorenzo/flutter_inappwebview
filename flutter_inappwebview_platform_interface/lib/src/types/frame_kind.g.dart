// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frame_kind.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to indicate the the frame kind.
class FrameKind {
  final String _value;
  final int? _nativeValue;
  const FrameKind._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory FrameKind._internalMultiPlatform(
          String value, Function nativeValue) =>
      FrameKind._internal(value, nativeValue());

  ///Indicates that the frame is an embed element.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_FRAME_KIND_EMBED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_frame_kind))
  static final EMBED = FrameKind._internalMultiPlatform('EMBED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 3;
      default:
        break;
    }
    return null;
  });

  ///Indicates that the frame is an iframe.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_FRAME_KIND_IFRAME](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_frame_kind))
  static final IFRAME = FrameKind._internalMultiPlatform('IFRAME', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 2;
      default:
        break;
    }
    return null;
  });

  ///Indicates that the frame is a primary main frame(webview).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_FRAME_KIND_MAIN_FRAME](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_frame_kind))
  static final MAIN_FRAME = FrameKind._internalMultiPlatform('MAIN_FRAME', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///Indicates that the frame is an object element.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_FRAME_KIND_OBJECT](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_frame_kind))
  static final OBJECT = FrameKind._internalMultiPlatform('OBJECT', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 4;
      default:
        break;
    }
    return null;
  });

  ///Indicates that the frame is an unknown type frame. We may extend this enum type to identify more frame kinds in the future.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_FRAME_KIND_UNKNOWN](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_frame_kind))
  static final UNKNOWN = FrameKind._internalMultiPlatform('UNKNOWN', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 0;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [FrameKind].
  static final Set<FrameKind> values = [
    FrameKind.EMBED,
    FrameKind.IFRAME,
    FrameKind.MAIN_FRAME,
    FrameKind.OBJECT,
    FrameKind.UNKNOWN,
  ].toSet();

  ///Gets a possible [FrameKind] instance from [String] value.
  static FrameKind? fromValue(String? value) {
    if (value != null) {
      try {
        return FrameKind.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [FrameKind] instance from a native value.
  static FrameKind? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return FrameKind.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [FrameKind] instance value with name [name].
  ///
  /// Goes through [FrameKind.values] looking for a value with
  /// name [name], as reported by [FrameKind.name].
  /// Returns the first value with the given name, otherwise `null`.
  static FrameKind? byName(String? name) {
    if (name != null) {
      try {
        return FrameKind.values.firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [FrameKind] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, FrameKind> asNameMap() => <String, FrameKind>{
        for (final value in FrameKind.values) value.name(): value
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'EMBED':
        return 'EMBED';
      case 'IFRAME':
        return 'IFRAME';
      case 'MAIN_FRAME':
        return 'MAIN_FRAME';
      case 'OBJECT':
        return 'OBJECT';
      case 'UNKNOWN':
        return 'UNKNOWN';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return toNativeValue() != null;
  }

  @override
  String toString() {
    return _value;
  }
}
