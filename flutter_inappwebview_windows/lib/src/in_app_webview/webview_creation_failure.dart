import 'dart:async';

/// A native WebView creation failure, as reported by the Windows plugin.
class WindowsWebViewCreationFailure {
  /// The error thrown by the `createInAppWebView` platform call. On Windows it
  /// carries the failing HRESULT in its message.
  final Object error;

  final StackTrace stackTrace;

  const WindowsWebViewCreationFailure(this.error, this.stackTrace);

  @override
  String toString() => 'WindowsWebViewCreationFailure($error)';
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

  static void report(Object error, StackTrace stackTrace) {
    if (_controller.hasListener) {
      _controller.add(WindowsWebViewCreationFailure(error, stackTrace));
    }
  }
}
