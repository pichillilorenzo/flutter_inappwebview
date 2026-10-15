package com.pichillilorenzo.flutter_inappwebview_android.webview.in_app_webview;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

public class PendingJavaScriptCallbacksTest {
  @Test
  public void cancelAllCompletesPendingCallbacksAndAllowsReentrantRequests() {
    PendingJavaScriptCallbacks callbacks = new PendingJavaScriptCallbacks();
    final int[] oldCallbackCount = {0};
    final int[] secondCallbackCount = {0};
    final String[] newCallbackValue = {null};

    callbacks.put("old", value -> {
      oldCallbackCount[0]++;
      assertEquals("null", value);
      // cancelAll must remove its snapshot before invoking callbacks. A callback may submit new work.
      assertEquals(0, callbacks.size());
      callbacks.put("new", received -> newCallbackValue[0] = received);
    });
    callbacks.put("also-old", value -> {
      secondCallbackCount[0]++;
      assertEquals("null", value);
    });

    callbacks.cancelAll("null");

    assertEquals(1, oldCallbackCount[0]);
    assertEquals(1, secondCallbackCount[0]);
    assertEquals(1, callbacks.size());
    callbacks.complete("old", "late result");
    assertEquals(1, oldCallbackCount[0]);
    callbacks.complete("new", "new document result");
    assertEquals("new document result", newCallbackValue[0]);
    assertEquals(0, callbacks.size());
  }

  @Test
  public void completeRemovesCallbackBeforeInvokingItAndIgnoresDuplicateResults() {
    PendingJavaScriptCallbacks callbacks = new PendingJavaScriptCallbacks();
    final int[] count = {0};

    callbacks.put("result", value -> {
      count[0]++;
      assertEquals("ok", value);
      assertEquals(0, callbacks.size());
      callbacks.put("new", ignored -> count[0] += 10);
    });

    callbacks.complete("result", "ok");
    assertEquals(1, callbacks.size());
    callbacks.complete("result", "duplicate old result");
    assertEquals(1, count[0]);
    callbacks.complete("new", "new work result");
    assertEquals(11, count[0]);
    callbacks.complete("result", "duplicate old result");
    assertEquals(11, count[0]);
  }

  @Test
  public void cancelBothDetachesBothRegistriesBeforeCallbacksCanSubmitNewWork() {
    PendingJavaScriptCallbacks asyncCallbacks = new PendingJavaScriptCallbacks();
    PendingJavaScriptCallbacks evaluateCallbacks = new PendingJavaScriptCallbacks();
    final int[] asyncCount = {0};
    final int[] oldEvaluateCount = {0};
    final String[] newEvaluateValue = {null};

    asyncCallbacks.put("async", value -> {
      asyncCount[0]++;
      assertEquals("{\"value\":null,\"error\":\"Document navigated\"}", value);
      assertEquals(0, asyncCallbacks.size());
      assertEquals(0, evaluateCallbacks.size());
      evaluateCallbacks.put("new-evaluate", received -> newEvaluateValue[0] = received);
    });
    evaluateCallbacks.put("old-evaluate", value -> {
      oldEvaluateCount[0]++;
      assertEquals("null", value);
    });

    PendingJavaScriptCallbacks.cancelBoth(
            asyncCallbacks, "{\"value\":null,\"error\":\"Document navigated\"}",
            evaluateCallbacks, "null");

    assertEquals(1, asyncCount[0]);
    assertEquals(1, oldEvaluateCount[0]);
    assertEquals(1, evaluateCallbacks.size());
    evaluateCallbacks.complete("new-evaluate", "new document result");
    assertEquals("new document result", newEvaluateValue[0]);
  }

  @Test
  public void documentGenerationAndPendingUuidGuardScheduledEvaluations() {
    DocumentJavaScriptGeneration generation = new DocumentJavaScriptGeneration();
    PendingJavaScriptCallbacks callbacks = new PendingJavaScriptCallbacks();
    final int[] executions = {0};
    callbacks.put("pending", ignored -> {});
    long capturedGeneration = generation.capture();

    assertEquals(true, generation.runIfCurrent(
            capturedGeneration, callbacks, "pending", () -> executions[0]++));
    assertEquals(1, executions[0]);

    generation.advance();
    assertEquals(false, generation.runIfCurrent(
            capturedGeneration, callbacks, null, () -> executions[0]++));
    assertEquals(1, executions[0]);

    callbacks.complete("pending", "cancelled");
    assertEquals(false, generation.runIfCurrent(
            generation.capture(), callbacks, "pending", () -> executions[0]++));
    assertEquals(1, executions[0]);
  }
}
