package com.pichillilorenzo.flutter_inappwebview_android.webview.in_app_webview;

/** Guards main-thread JavaScript work against navigation between scheduling and execution. */
final class DocumentJavaScriptGeneration {
  private long generation;

  synchronized long capture() {
    return generation;
  }

  synchronized void advance() {
    generation++;
  }

  boolean runIfCurrent(
      long capturedGeneration,
      PendingJavaScriptCallbacks callbacks,
      String callbackId,
      Runnable action) {
    synchronized (this) {
      if (capturedGeneration != generation) {
        return false;
      }
    }
    if (callbackId != null && !callbacks.contains(callbackId)) {
      return false;
    }
    action.run();
    return true;
  }
}
