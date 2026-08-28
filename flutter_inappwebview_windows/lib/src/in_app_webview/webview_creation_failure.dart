import 'dart:async';

/// A native WebView creation failure, as reported by the Windows plugin.
class WindowsWebViewCreationFailure {
  /// The error thrown by the `createInAppWebView` platform call. On Windows it
  /// carries the failing HRESULT in its message.
  final Object error;

  final StackTrace stackTrace;

  /// The URL (or file path) the failed webview was asked to load, taken from
  /// its creation params. Hosts use it to tell whose creation failed: several
  /// webviews can be created concurrently and this stream is global.
  final String? requestedUrl;

  const WindowsWebViewCreationFailure(
    this.error,
    this.stackTrace, {
    this.requestedUrl,
  });

  @override
  String toString() =>
      'WindowsWebViewCreationFailure($error, requestedUrl: $requestedUrl)';
}

/// Broadcasts native WebView creation failures to the host application.
///
/// The failure happens before any webview callback exists, so without this the
/// only symptom is a blank area and an unhandled async error. Hosts listen to
/// [stream] to show their own message instead.
class WindowsWebViewCreationFailures {
  WindowsWebViewCreationFailures._();

  static final StreamController<WindowsWebViewCreationFailure> _controller =
      StreamController<WindowsWebViewCreationFailure>.broadcast();

  static Stream<WindowsWebViewCreationFailure> get stream => _controller.stream;

  static void report(
    Object error,
    StackTrace stackTrace, {
    String? requestedUrl,
  }) {
    if (_controller.hasListener) {
      _controller.add(
        WindowsWebViewCreationFailure(
          error,
          stackTrace,
          requestedUrl: requestedUrl,
        ),
      );
    }
  }
}
