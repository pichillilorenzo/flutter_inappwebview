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

/// An immutable observation from one native widget creation or reattachment.
///
/// Unlike [WindowsWebViewCreationResult.renderMode], [renderMode] never uses a
/// compatibility default. An older native implementation returning only an id,
/// or a map without a recognized mode, leaves the backend unverified.
@immutable
class WindowsWebViewCreationDetails {
  /// The native platform view/texture id returned for this attachment.
  ///
  /// This can differ from the controller's channel id for keepAlive/headless
  /// views. It is not a process id or a permanent WebView identity; native ids
  /// can be reused after disposal.
  final int nativeViewId;

  /// The mode explicitly reported by native code, or `null` if unverified.
  final WindowsWebViewRenderMode? renderMode;

  /// The reported selection stage, including `forced` for the HWND test hook.
  ///
  /// A missing value does not mean that no fallback occurred. In particular,
  /// keepAlive reattachment reports the current mode without its original
  /// selection reason. Use [isFallbackReasonAvailable] for a complete reason.
  final String? fallbackStage;

  /// The reported creation HRESULT, normalized to an unsigned 32-bit value.
  ///
  /// This is independent of the signed HRESULTs in process-enumeration errors.
  /// Missing, non-integer, or out-of-range values remain `null`.
  final int? fallbackHresult;

  const WindowsWebViewCreationDetails._({
    required this.nativeViewId,
    this.renderMode,
    this.fallbackStage,
    this.fallbackHresult,
  });

  /// Whether native code explicitly identified a supported render mode.
  bool get isRenderModeVerified => renderMode != null;

  /// Whether both parts of the native selection reason were reported.
  ///
  /// A partial or absent reason stays unavailable, even when the render mode
  /// itself is verified. This never infers "no fallback" from absent fields.
  bool get isFallbackReasonAvailable =>
      fallbackStage != null && fallbackHresult != null;
}

/// The native result of `createInAppWebView`.
@immutable
class WindowsWebViewCreationResult {
  /// The view id, used for the per-view channels.
  final int id;

  /// The mode used for rendering, with a composition compatibility default.
  ///
  /// Use [creationDetails] to distinguish an observed mode from that default.
  final WindowsWebViewRenderMode renderMode;

  /// The observation parsed from native code, absent for manually built results.
  final WindowsWebViewCreationDetails? creationDetails;

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
  }) : creationDetails = null;

  const WindowsWebViewCreationResult._({
    required this.id,
    required this.renderMode,
    required this.creationDetails,
    this.fallbackStage,
    this.fallbackHresult,
  });

  /// Accepts both the map result and the bare id of older native code.
  factory WindowsWebViewCreationResult.fromNative(Object? value) {
    if (value is int) {
      return WindowsWebViewCreationResult._(
        id: value,
        renderMode: WindowsWebViewRenderMode.composition,
        creationDetails: WindowsWebViewCreationDetails._(nativeViewId: value),
      );
    }
    if (value is! Map) {
      throw ArgumentError.value(value, 'value', 'Not a creation result');
    }
    final id = value['id'] as int;
    final observedMode = switch (value['renderMode']) {
      'composition' => WindowsWebViewRenderMode.composition,
      'hwnd' => WindowsWebViewRenderMode.hwnd,
      _ => null,
    };
    final stage = value['fallbackStage'];
    final fallbackStage = stage is String && stage.isNotEmpty ? stage : null;
    final hresult = value['fallbackHresult'];
    final fallbackHresult =
        hresult is int && hresult >= -0x80000000 && hresult <= 0xFFFFFFFF
        ? hresult & 0xFFFFFFFF
        : null;
    return WindowsWebViewCreationResult._(
      id: id,
      renderMode: observedMode ?? WindowsWebViewRenderMode.composition,
      fallbackStage: fallbackStage,
      fallbackHresult: fallbackHresult,
      creationDetails: WindowsWebViewCreationDetails._(
        nativeViewId: id,
        renderMode: observedMode,
        fallbackStage: fallbackStage,
        fallbackHresult: fallbackHresult,
      ),
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
