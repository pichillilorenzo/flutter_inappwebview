package com.pichillilorenzo.flutter_inappwebview_android.webview_environment;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertSame;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class PendingWebViewPrewarmTest {
  @Test
  public void concurrentCallsShareCompletionAndLaterCallsReuseIt() {
    PendingWebViewPrewarm operation = new PendingWebViewPrewarm();
    List<Map<String, Object>> replies = new ArrayList<>();
    operation.add(replies::add);
    operation.add(replies::add);
    assertTrue(replies.isEmpty());
    assertTrue(operation.complete("ok"));
    operation.add(replies::add);
    assertEquals(3, replies.size());
    assertSame(replies.get(0), replies.get(1));
    assertSame(replies.get(0), replies.get(2));
    assertEquals("ok", replies.get(0).get("status"));
    assertTrue(((Long) replies.get(0).get("durationMs")) >= 0);
  }

  @Test
  public void timeoutAndDetachPreventLateStartupResultsFromReplyingAgain() {
    for (String status : new String[]{"timeout", "unavailable", "create_failed", "thread_failed"}) {
      PendingWebViewPrewarm operation = new PendingWebViewPrewarm();
      List<Map<String, Object>> replies = new ArrayList<>();
      operation.add(replies::add);
      assertTrue(operation.complete(status));
      assertFalse(operation.complete("ok"));
      assertFalse(operation.complete("timeout"));
      operation.add(replies::add);
      assertEquals(2, replies.size());
      assertEquals(status, replies.get(0).get("status"));
      assertSame(replies.get(0), replies.get(1));
    }
  }

  @Test
  public void replyCanReenterWithoutStartingOrCompletingAnotherOperation() {
    PendingWebViewPrewarm operation = new PendingWebViewPrewarm();
    List<Map<String, Object>> replies = new ArrayList<>();
    operation.add(value -> {
      replies.add(value);
      operation.add(replies::add);
      assertFalse(operation.complete("timeout"));
    });
    operation.complete("ok");
    assertEquals(2, replies.size());
    assertSame(replies.get(0), replies.get(1));
  }
}
