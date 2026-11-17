package com.pichillilorenzo.flutter_inappwebview_android.webview_environment;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/** Main-thread-owned completion state shared by concurrent prewarm calls. */
final class PendingWebViewPrewarm {
  interface Listener {
    void complete(Map<String, Object> outcome);
  }

  private final long startedAt = System.nanoTime();
  private final List<Listener> listeners = new ArrayList<>();
  private Map<String, Object> outcome;

  void add(Listener listener) {
    if (outcome != null) {
      listener.complete(outcome);
    } else {
      listeners.add(listener);
    }
  }

  boolean complete(String status) {
    if (outcome != null) {
      return false;
    }
    Map<String, Object> values = new HashMap<>();
    values.put("status", status);
    values.put("durationMs", TimeUnit.NANOSECONDS.toMillis(System.nanoTime() - startedAt));
    outcome = Collections.unmodifiableMap(values);
    // Detach the pending list before replies can reenter the manager.
    List<Listener> pending = new ArrayList<>(listeners);
    listeners.clear();
    for (Listener listener : pending) {
      listener.complete(outcome);
    }
    return true;
  }
}
