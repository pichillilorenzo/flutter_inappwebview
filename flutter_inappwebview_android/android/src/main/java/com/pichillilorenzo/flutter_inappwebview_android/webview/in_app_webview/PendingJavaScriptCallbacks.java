package com.pichillilorenzo.flutter_inappwebview_android.webview.in_app_webview;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Tracks JavaScript results that are delivered asynchronously by the page bridge. */
public final class PendingJavaScriptCallbacks {
  public interface Callback {
    void onComplete(String value);
  }

  private final Map<String, Callback> callbacks = new LinkedHashMap<>();

  public synchronized void put(String id, Callback callback) {
    callbacks.put(id, callback);
  }

  public void complete(String id, String value) {
    Callback callback;
    synchronized (this) {
      callback = callbacks.remove(id);
    }
    if (callback != null) {
      callback.onComplete(value);
    }
  }

  public void cancelAll(String value) {
    rethrow(completeAll(removeAll(), value, null));
  }

  /** Detach both sets before invoking a callback from either set. */
  public static void cancelBoth(
      PendingJavaScriptCallbacks first, String firstValue,
      PendingJavaScriptCallbacks second, String secondValue) {
    List<Callback> firstPending = first.removeAll();
    List<Callback> secondPending = second.removeAll();
    Throwable failure = completeAll(firstPending, firstValue, null);
    rethrow(completeAll(secondPending, secondValue, failure));
  }

  private synchronized List<Callback> removeAll() {
    List<Callback> pending = new ArrayList<>(callbacks.values());
    callbacks.clear();
    return pending;
  }

  private static Throwable completeAll(List<Callback> pending, String value, Throwable failure) {
    for (Callback callback : pending) {
      try {
        callback.onComplete(value);
      } catch (RuntimeException | Error error) {
        if (failure == null) failure = error;
        else if (failure != error) failure.addSuppressed(error);
      }
    }
    return failure;
  }

  private static void rethrow(Throwable failure) {
    if (failure instanceof RuntimeException) throw (RuntimeException) failure;
    if (failure instanceof Error) throw (Error) failure;
  }

  public synchronized boolean contains(String id) {
    return callbacks.containsKey(id);
  }

  synchronized int size() {
    return callbacks.size();
  }

}
