import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// How a Windows WebView reaches the screen.
enum WindowsWebViewRenderMode {
  /// WebView2 renders into a visual that is captured into a Flutter texture.
  composition,

  /// WebView2 renders into its own child window above the Flutter view.
  ///
  /// Used when composition hosting is unavailable. Flutter cannot paint over
  /// the window, so the view hides it while Flutter content covers it.
  hwnd,
}

/// The native result of `createInAppWebView`.
@immutable
class WindowsWebViewCreationResult {
  /// The view id, used for the per-view channels.
  final int id;

  final WindowsWebViewRenderMode renderMode;

  /// The native step whose failure selected [WindowsWebViewRenderMode.hwnd],
  /// or `forced` when the test hook requested it.
  final String? fallbackStage;

  /// The HRESULT of [fallbackStage], as an unsigned 32-bit value.
  final int? fallbackHresult;

  const WindowsWebViewCreationResult({
    required this.id,
    this.renderMode = WindowsWebViewRenderMode.composition,
    this.fallbackStage,
    this.fallbackHresult,
  });

  /// Accepts both the map result and the bare id of older native code.
  factory WindowsWebViewCreationResult.fromNative(Object? value) {
    if (value is int) return WindowsWebViewCreationResult(id: value);
    if (value is! Map) {
      throw ArgumentError.value(value, 'value', 'Not a creation result');
    }
    final hresult = value['fallbackHresult'];
    return WindowsWebViewCreationResult(
      id: value['id'] as int,
      renderMode: value['renderMode'] == 'hwnd'
          ? WindowsWebViewRenderMode.hwnd
          : WindowsWebViewRenderMode.composition,
      fallbackStage: value['fallbackStage'] as String?,
      fallbackHresult: hresult is int ? hresult & 0xFFFFFFFF : null,
    );
  }
}

/// A WebView that was created in [WindowsWebViewRenderMode.hwnd].
@immutable
class WindowsWebViewHwndFallback {
  /// See [WindowsWebViewCreationResult.fallbackStage].
  final String stage;

  /// See [WindowsWebViewCreationResult.fallbackHresult].
  final int? hresult;

  /// The URL (or file path) the webview was asked to load.
  final String? requestedUrl;

  /// The [InAppWebView] key of the creation attempt.
  final Key? creationKey;

  const WindowsWebViewHwndFallback({
    required this.stage,
    this.hresult,
    this.requestedUrl,
    this.creationKey,
  });

  /// [hresult] as `0x8007139F`, or `null`.
  String? get hresultHex => hresult == null
      ? null
      : '0x${hresult!.toRadixString(16).toUpperCase().padLeft(8, '0')}';

  @override
  String toString() =>
      'WindowsWebViewHwndFallback(stage: $stage, hresult: $hresultHex, '
      'requestedUrl: $requestedUrl, creationKey: $creationKey)';
}

/// Broadcasts every WebView that was created in HWND mode.
///
/// The fallback is otherwise invisible to the host, which may want to log
/// why composition hosting failed on the user's machine.
class WindowsWebViewHwndFallbacks {
  WindowsWebViewHwndFallbacks._();

  static final StreamController<WindowsWebViewHwndFallback> _controller =
      StreamController<WindowsWebViewHwndFallback>.broadcast();

  static Stream<WindowsWebViewHwndFallback> get stream => _controller.stream;

  static void report(WindowsWebViewHwndFallback fallback) {
    if (_controller.hasListener) {
      _controller.add(fallback);
    }
  }
}
