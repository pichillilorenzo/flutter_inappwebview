import 'dart:async';

import '../in_app_webview/platform_inappwebview_controller.dart';

///Cooperative cancellation token for [PlatformInAppWebViewController.takeScreenshot].
///
///Create one signal per capture you may want to abandon, pass it as the
///`cancellationSignal` argument, and call [cancel] when the image is no longer
///wanted. The `takeScreenshot` future then completes with `null` right away and
///a result that arrives later from the platform is discarded.
///
///A signal is one-shot: once cancelled it stays cancelled, and any
///`takeScreenshot` call that receives an already-cancelled signal returns
///`null` without contacting the platform. One signal may be shared by several
///concurrent calls; cancelling it cancels all of them.
///
///What happens natively depends on the platform:
///- Android WebView: the request is tracked natively. A cancel that arrives
///  while the capture is still queued skips it entirely; one that arrives while
///  the bitmap is being scaled or compressed on the worker thread aborts that
///  work at the next checkpoint and releases the bitmap. `draw()` itself cannot
///  be interrupted, so a cancel that lands mid-draw takes effect right after it.
///- iOS, macOS, Windows, Linux: pre-cancel rejection and late-result
///  suppression only; native snapshot work already started runs to completion.
class ScreenshotCancellationSignal {
  ScreenshotCancellationSignal();

  bool _cancelled = false;
  String? _reason;
  final List<void Function(String? reason)> _listeners =
      <void Function(String? reason)>[];

  ///Whether [cancel] has been called.
  bool get isCancelled => _cancelled;

  ///The reason passed to [cancel], if any.
  String? get reason => _reason;

  ///Cancels every capture currently using this signal. Calling it again, or
  ///after the capture completed, is a no-op.
  void cancel([String? reason]) {
    if (_cancelled) {
      return;
    }
    _cancelled = true;
    _reason = reason;
    final listeners = List<void Function(String? reason)>.of(_listeners);
    _listeners.clear();
    for (final listener in listeners) {
      listener(reason);
    }
  }

  ///Registers [listener] to run once when [cancel] is called. Returns a
  ///function that unregisters it. If the signal is already cancelled the
  ///listener is not called; check [isCancelled] first.
  void Function() addListener(void Function(String? reason) listener) {
    _listeners.add(listener);
    return () {
      _listeners.remove(listener);
    };
  }

  ///Runs [start] under this signal and applies the completion rule platform
  ///implementations share:
  ///- already cancelled: completes with `null` and never calls [start];
  ///- cancelled while [start]'s future is pending: completes with `null`
  ///  immediately, calls [onCancel] (where a platform can forward the cancel
  ///  natively) and discards the late result;
  ///- otherwise completes with [start]'s result or error.
  ///
  ///The listener is always detached on completion. [start] may return `null`
  ///when the controller's channel is gone; that completes with `null`.
  Future<T?> guard<T>(
    Future<T?>? Function() start, {
    void Function(String? reason)? onCancel,
  }) {
    if (_cancelled) {
      return Future<T?>.value(null);
    }

    final completer = Completer<T?>();
    void Function()? detach;

    void finish(T? value) {
      detach?.call();
      if (!completer.isCompleted) {
        completer.complete(value);
      }
    }

    detach = addListener((reason) {
      finish(null);
      onCancel?.call(reason);
    });

    final Future<T?>? pending;
    try {
      pending = start();
    } catch (error, stackTrace) {
      detach();
      return Future<T?>.error(error, stackTrace);
    }
    if (pending == null) {
      finish(null);
      return completer.future;
    }

    unawaited(
      pending.then(
        finish,
        onError: (Object error, StackTrace stackTrace) {
          detach?.call();
          if (!completer.isCompleted) {
            completer.completeError(error, stackTrace);
          }
        },
      ),
    );
    return completer.future;
  }
}
