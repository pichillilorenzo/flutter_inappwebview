import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'process_failed_kind.g.dart';

///Class used to indicate the kind of process failure that has occurred.
@ExchangeableEnum()
class ProcessFailedKind_ {
  // ignore: unused_field
  final String _value;
  // ignore: unused_field
  final dynamic _nativeValue = null;
  const ProcessFailedKind_._internal(this._value);

  ///Indicates that the browser process ended unexpectedly. The WebView automatically moves to the Closed state.
  ///The app has to recreate a new WebView to recover from this failure.
  @EnumSupportedPlatforms(platforms: [
    EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PROCESS_FAILED_KIND_BROWSER_PROCESS_EXITED',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_kind',
        value: 0),
  ])
  static const BROWSER_PROCESS_EXITED =
      const ProcessFailedKind_._internal('BROWSER_PROCESS_EXITED');

  ///Indicates that the main frame's render process ended unexpectedly. Any subframes in the WebView will be gone too.
  ///A new render process is created automatically and navigated to an error page.
  ///You can use the reload method to try to recover from this failure. Alternatively, you can close and recreate the WebView.
  @EnumSupportedPlatforms(platforms: [
    EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PROCESS_FAILED_KIND_RENDER_PROCESS_EXITED',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_kind',
        value: 1),
  ])
  static const RENDER_PROCESS_EXITED =
      const ProcessFailedKind_._internal('RENDER_PROCESS_EXITED');

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
  @EnumSupportedPlatforms(platforms: [
    EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PROCESS_FAILED_KIND_RENDER_PROCESS_UNRESPONSIVE',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_kind',
        value: 2),
  ])
  static const RENDER_PROCESS_UNRESPONSIVE =
      const ProcessFailedKind_._internal('RENDER_PROCESS_UNRESPONSIVE');

  ///Indicates that a frame-only render process ended unexpectedly.
  ///The process exit does not affect the top-level document, only a subset of the subframes within it.
  ///The content in these frames is replaced with an error page in the frame.
  @EnumSupportedPlatforms(platforms: [
    EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PROCESS_FAILED_KIND_FRAME_RENDER_PROCESS_EXITED',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_kind',
        value: 3),
  ])
  static const FRAME_RENDER_PROCESS_EXITED =
      const ProcessFailedKind_._internal('FRAME_RENDER_PROCESS_EXITED');

  ///Indicates that a utility process ended unexpectedly.
  ///The failed process is recreated automatically.
  ///Your application does not need to handle recovery for this event.
  @EnumSupportedPlatforms(platforms: [
    EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PROCESS_FAILED_KIND_UTILITY_PROCESS_EXITED',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_kind',
        value: 4),
  ])
  static const UTILITY_PROCESS_EXITED =
      const ProcessFailedKind_._internal('UTILITY_PROCESS_EXITED');

  ///Indicates that a sandbox helper process ended unexpectedly.
  ///This failure is not fatal.
  ///Your application does not need to handle recovery for this event.
  @EnumSupportedPlatforms(platforms: [
    EnumWindowsPlatform(
        apiName:
            'COREWEBVIEW2_PROCESS_FAILED_KIND_SANDBOX_HELPER_PROCESS_EXITED',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_kind',
        value: 5),
  ])
  static const SANDBOX_HELPER_PROCESS_EXITED =
      const ProcessFailedKind_._internal('SANDBOX_HELPER_PROCESS_EXITED');

  ///Indicates that the GPU process ended unexpectedly.
  ///The failed process is recreated automatically.
  ///Your application does not need to handle recovery for this event.
  @EnumSupportedPlatforms(platforms: [
    EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PROCESS_FAILED_KIND_GPU_PROCESS_EXITED',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_kind',
        value: 6),
  ])
  static const GPU_PROCESS_EXITED =
      const ProcessFailedKind_._internal('GPU_PROCESS_EXITED');

  ///Indicates that a PPAPI plugin process ended unexpectedly.
  ///This failure is not fatal.
  ///Your application does not need to handle recovery for this event.
  @EnumSupportedPlatforms(platforms: [
    EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PROCESS_FAILED_KIND_PPAPI_PLUGIN_PROCESS_EXITED',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_kind',
        value: 7),
  ])
  static const PPAPI_PLUGIN_PROCESS_EXITED =
      const ProcessFailedKind_._internal('PPAPI_PLUGIN_PROCESS_EXITED');

  ///Indicates that a PPAPI plugin broker process ended unexpectedly.
  ///This failure is not fatal.
  ///Your application does not need to handle recovery for this event.
  @EnumSupportedPlatforms(platforms: [
    EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PROCESS_FAILED_KIND_PPAPI_BROKER_PROCESS_EXITED',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_kind',
        value: 8),
  ])
  static const PPAPI_BROKER_PROCESS_EXITED =
      const ProcessFailedKind_._internal('PPAPI_BROKER_PROCESS_EXITED');

  ///Indicates that a process of unspecified kind ended unexpectedly.
  @EnumSupportedPlatforms(platforms: [
    EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PROCESS_FAILED_KIND_UNKNOWN_PROCESS_EXITED',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_kind',
        value: 9),
  ])
  static const UNKNOWN_PROCESS_EXITED =
      const ProcessFailedKind_._internal('UNKNOWN_PROCESS_EXITED');
}
