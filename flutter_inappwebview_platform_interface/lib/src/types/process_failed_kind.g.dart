// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'process_failed_kind.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to indicate the kind of process failure that has occurred.
class ProcessFailedKind {
  final String _value;
  final dynamic _nativeValue;
  const ProcessFailedKind._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory ProcessFailedKind._internalMultiPlatform(
          String value, Function nativeValue) =>
      ProcessFailedKind._internal(value, nativeValue());

  ///Indicates that the browser process ended unexpectedly. The WebView automatically moves to the Closed state.
  ///The app has to recreate a new WebView to recover from this failure.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_PROCESS_FAILED_KIND_BROWSER_PROCESS_EXITED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_kind))
  static final BROWSER_PROCESS_EXITED =
      ProcessFailedKind._internalMultiPlatform('BROWSER_PROCESS_EXITED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 0;
      default:
        break;
    }
    return null;
  });

  ///Indicates that a frame-only render process ended unexpectedly.
  ///The process exit does not affect the top-level document, only a subset of the subframes within it.
  ///The content in these frames is replaced with an error page in the frame.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_PROCESS_FAILED_KIND_FRAME_RENDER_PROCESS_EXITED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_kind))
  static final FRAME_RENDER_PROCESS_EXITED =
      ProcessFailedKind._internalMultiPlatform('FRAME_RENDER_PROCESS_EXITED',
          () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 3;
      default:
        break;
    }
    return null;
  });

  ///Indicates that the GPU process ended unexpectedly.
  ///The failed process is recreated automatically.
  ///Your application does not need to handle recovery for this event.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_PROCESS_FAILED_KIND_GPU_PROCESS_EXITED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_kind))
  static final GPU_PROCESS_EXITED =
      ProcessFailedKind._internalMultiPlatform('GPU_PROCESS_EXITED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 6;
      default:
        break;
    }
    return null;
  });

  ///Indicates that a PPAPI plugin broker process ended unexpectedly.
  ///This failure is not fatal.
  ///Your application does not need to handle recovery for this event.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_PROCESS_FAILED_KIND_PPAPI_BROKER_PROCESS_EXITED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_kind))
  static final PPAPI_BROKER_PROCESS_EXITED =
      ProcessFailedKind._internalMultiPlatform('PPAPI_BROKER_PROCESS_EXITED',
          () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 8;
      default:
        break;
    }
    return null;
  });

  ///Indicates that a PPAPI plugin process ended unexpectedly.
  ///This failure is not fatal.
  ///Your application does not need to handle recovery for this event.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_PROCESS_FAILED_KIND_PPAPI_PLUGIN_PROCESS_EXITED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_kind))
  static final PPAPI_PLUGIN_PROCESS_EXITED =
      ProcessFailedKind._internalMultiPlatform('PPAPI_PLUGIN_PROCESS_EXITED',
          () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 7;
      default:
        break;
    }
    return null;
  });

  ///Indicates that the main frame's render process ended unexpectedly. Any subframes in the WebView will be gone too.
  ///A new render process is created automatically and navigated to an error page.
  ///You can use the reload method to try to recover from this failure. Alternatively, you can close and recreate the WebView.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_PROCESS_FAILED_KIND_RENDER_PROCESS_EXITED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_kind))
  static final RENDER_PROCESS_EXITED =
      ProcessFailedKind._internalMultiPlatform('RENDER_PROCESS_EXITED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///Indicates that the main frame's render process is unresponsive.
  ///Renderer process unresponsiveness can happen for the following reasons:
  ///
  ///* There is a **long-running script** being executed. For example, the
  ///web content in your WebView might be performing a synchronous XHR, or have
  ///entered an infinite loop.
  ///* The **system is busy**.
  ///
  ///The process failed event will continue to be raised every few seconds
  ///until the renderer process has become responsive again. The application
  ///can consider taking action if the event keeps being raised. For example,
  ///the application might show UI for the user to decide to keep waiting or
  ///reload the page, or navigate away.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_PROCESS_FAILED_KIND_RENDER_PROCESS_UNRESPONSIVE](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_kind))
  static final RENDER_PROCESS_UNRESPONSIVE =
      ProcessFailedKind._internalMultiPlatform('RENDER_PROCESS_UNRESPONSIVE',
          () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 2;
      default:
        break;
    }
    return null;
  });

  ///Indicates that a sandbox helper process ended unexpectedly.
  ///This failure is not fatal.
  ///Your application does not need to handle recovery for this event.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_PROCESS_FAILED_KIND_SANDBOX_HELPER_PROCESS_EXITED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_kind))
  static final SANDBOX_HELPER_PROCESS_EXITED =
      ProcessFailedKind._internalMultiPlatform('SANDBOX_HELPER_PROCESS_EXITED',
          () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 5;
      default:
        break;
    }
    return null;
  });

  ///Indicates that a process of unspecified kind ended unexpectedly.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_PROCESS_FAILED_KIND_UNKNOWN_PROCESS_EXITED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_kind))
  static final UNKNOWN_PROCESS_EXITED =
      ProcessFailedKind._internalMultiPlatform('UNKNOWN_PROCESS_EXITED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 9;
      default:
        break;
    }
    return null;
  });

  ///Indicates that a utility process ended unexpectedly.
  ///The failed process is recreated automatically.
  ///Your application does not need to handle recovery for this event.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - COREWEBVIEW2_PROCESS_FAILED_KIND_UTILITY_PROCESS_EXITED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_kind))
  static final UTILITY_PROCESS_EXITED =
      ProcessFailedKind._internalMultiPlatform('UTILITY_PROCESS_EXITED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 4;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [ProcessFailedKind].
  static final Set<ProcessFailedKind> values = [
    ProcessFailedKind.BROWSER_PROCESS_EXITED,
    ProcessFailedKind.FRAME_RENDER_PROCESS_EXITED,
    ProcessFailedKind.GPU_PROCESS_EXITED,
    ProcessFailedKind.PPAPI_BROKER_PROCESS_EXITED,
    ProcessFailedKind.PPAPI_PLUGIN_PROCESS_EXITED,
    ProcessFailedKind.RENDER_PROCESS_EXITED,
    ProcessFailedKind.RENDER_PROCESS_UNRESPONSIVE,
    ProcessFailedKind.SANDBOX_HELPER_PROCESS_EXITED,
    ProcessFailedKind.UNKNOWN_PROCESS_EXITED,
    ProcessFailedKind.UTILITY_PROCESS_EXITED,
  ].toSet();

  ///Gets a possible [ProcessFailedKind] instance from [String] value.
  static ProcessFailedKind? fromValue(String? value) {
    if (value != null) {
      try {
        return ProcessFailedKind.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ProcessFailedKind] instance from a native value.
  static ProcessFailedKind? fromNativeValue(dynamic value) {
    if (value != null) {
      try {
        return ProcessFailedKind.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [ProcessFailedKind] instance value with name [name].
  ///
  /// Goes through [ProcessFailedKind.values] looking for a value with
  /// name [name], as reported by [ProcessFailedKind.name].
  /// Returns the first value with the given name, otherwise `null`.
  static ProcessFailedKind? byName(String? name) {
    if (name != null) {
      try {
        return ProcessFailedKind.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [ProcessFailedKind] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, ProcessFailedKind> asNameMap() =>
      <String, ProcessFailedKind>{
        for (final value in ProcessFailedKind.values) value.name(): value
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [dynamic] native value.
  dynamic toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'BROWSER_PROCESS_EXITED':
        return 'BROWSER_PROCESS_EXITED';
      case 'FRAME_RENDER_PROCESS_EXITED':
        return 'FRAME_RENDER_PROCESS_EXITED';
      case 'GPU_PROCESS_EXITED':
        return 'GPU_PROCESS_EXITED';
      case 'PPAPI_BROKER_PROCESS_EXITED':
        return 'PPAPI_BROKER_PROCESS_EXITED';
      case 'PPAPI_PLUGIN_PROCESS_EXITED':
        return 'PPAPI_PLUGIN_PROCESS_EXITED';
      case 'RENDER_PROCESS_EXITED':
        return 'RENDER_PROCESS_EXITED';
      case 'RENDER_PROCESS_UNRESPONSIVE':
        return 'RENDER_PROCESS_UNRESPONSIVE';
      case 'SANDBOX_HELPER_PROCESS_EXITED':
        return 'SANDBOX_HELPER_PROCESS_EXITED';
      case 'UNKNOWN_PROCESS_EXITED':
        return 'UNKNOWN_PROCESS_EXITED';
      case 'UTILITY_PROCESS_EXITED':
        return 'UTILITY_PROCESS_EXITED';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
  }
}
