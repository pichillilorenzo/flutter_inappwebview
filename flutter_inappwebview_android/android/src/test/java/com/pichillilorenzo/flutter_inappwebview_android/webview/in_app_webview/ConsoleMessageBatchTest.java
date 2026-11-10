package com.pichillilorenzo.flutter_inappwebview_android.webview.in_app_webview;

import static org.junit.Assert.*;
import static org.robolectric.Shadows.shadowOf;

import android.os.Looper;
import com.pichillilorenzo.flutter_inappwebview_android.webview.WebViewChannelDelegate;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.RuntimeEnvironment;
import org.robolectric.annotation.Config;
import org.robolectric.annotation.LooperMode;
import java.nio.ByteBuffer;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMethodCodec;

@RunWith(RobolectricTestRunner.class)
@Config(sdk = 28)
@LooperMode(LooperMode.Mode.PAUSED)
public class ConsoleMessageBatchTest {
  private InAppWebView view;
  private WebViewChannelDelegate delegate;
  private final List<MethodCall> calls = new ArrayList<>();
  private int encodedBytes;

  @Before public void setUp() {
    view = new InAppWebView(RuntimeEnvironment.getApplication());
    BinaryMessenger messenger = new BinaryMessenger() {
      @Override public void send(String channel, ByteBuffer message) { send(channel, message, null); }
      @Override public void send(String channel, ByteBuffer message, BinaryReply reply) {
        ByteBuffer encoded = message.duplicate();
        encoded.flip();
        encodedBytes += encoded.remaining();
        calls.add(StandardMethodCodec.INSTANCE.decodeMethodCall(encoded));
        if (reply != null) reply.reply(null);
      }
      @Override public void setMessageHandler(String channel, BinaryMessageHandler handler) {}
    };
    delegate = new WebViewChannelDelegate(view, new MethodChannel(messenger, "console"));
    view.channelDelegate = delegate;
  }

  @After public void tearDown() {
    delegate.dispose();
    view.channelDelegate = null;
    view.destroy();
    shadowOf(Looper.getMainLooper()).idle();
  }

  private List<String> messages() {
    List<String> messages = new ArrayList<>();
    for (MethodCall call : calls) {
      if (!call.method.equals("onConsoleMessageBatch")) continue;
      List<Map<String, Object>> entries = call.argument("messages");
      assertTrue(entries.size() <= 64);
      long characters = 0;
      for (Map<String, Object> entry : entries) {
        String message = (String) entry.get("message");
        characters += message.length() + 48L;
        messages.add(message);
      }
      assertTrue(characters <= 65536 || entries.size() == 1);
    }
    return messages;
  }

  @Test public void floodStaysOrderedAndUsesBoundedNativeBatches() {
    for (int i = 0; i < 10000; i++) delegate.onConsoleMessage("log-" + i, 1);
    shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(25));
    List<String> forwarded = messages();
    assertEquals(10000, forwarded.size());
    for (int i = 0; i < 10000; i++) assertEquals("log-" + i, forwarded.get(i));
    assertEquals(157, calls.size());
    System.out.println("Android native->Dart: 10000 records, " + calls.size() + " invokes, " + encodedBytes + " StandardMethodCodec bytes");
  }

  @Test public void warningErrorAndNavigationFlushEarlierRecords() {
    delegate.onConsoleMessage("before warning", 1);
    delegate.onConsoleMessage("warning", 2);
    assertEquals(Arrays.asList("before warning", "warning"), messages());
    delegate.onConsoleMessage("before error", 1);
    delegate.onConsoleMessage("error", 3);
    delegate.onConsoleMessage("before navigation", 1);
    delegate.onLoadStart("https://example.com");
    assertEquals("onConsoleMessageBatch", calls.get(calls.size() - 2).method);
    assertEquals("onLoadStart", calls.get(calls.size() - 1).method);
    int count = calls.size();
    shadowOf(Looper.getMainLooper()).idleFor(Duration.ofSeconds(1));
    assertEquals(count, calls.size());
  }

  @Test public void policyFiltersAllFiveLevelsBeforeIpcAndCanBeRelaxed() {
    view.customSettings.consoleMessageLevels = Arrays.asList(2, 3);
    for (int i = 0; i < 10000; i++) {
      delegate.onConsoleMessage("tip", 0);
      delegate.onConsoleMessage("log", 1);
      delegate.onConsoleMessage("debug", 4);
    }
    shadowOf(Looper.getMainLooper()).idleFor(Duration.ofSeconds(1));
    assertTrue(calls.isEmpty());
    assertEquals(0, encodedBytes);
    delegate.onConsoleMessage("warning", 2);
    delegate.onConsoleMessage("error", 3);
    assertEquals(Arrays.asList("warning", "error"), messages());
    view.customSettings.consoleMessageLevels = null;
    delegate.onConsoleMessage("diagnostic", 4);
    shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(25));
    assertEquals("diagnostic", messages().get(2));
    view.customSettings.consoleMessageLevels = Collections.emptyList();
    delegate.onConsoleMessage("disabled error", 3);
    assertEquals(3, messages().size());
  }

  @Test public void policyChangeDetachAndDisposeCancelQueuedOutput() {
    delegate.onConsoleMessage("old policy", 1);
    view.customSettings.consoleMessageLevels = Arrays.asList(2, 3);
    shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(25));
    assertTrue(calls.isEmpty());
    view.customSettings.consoleMessageLevels = null;
    delegate.onConsoleMessage("pending detach", 1);
    view.setConsoleMessageListener(false);
    shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(25));
    delegate.onConsoleMessage("detached error", 3);
    assertTrue(calls.isEmpty());
    view.setConsoleMessageListener(true);
    delegate.onConsoleMessage("pending dispose", 1);
    delegate.dispose();
    shadowOf(Looper.getMainLooper()).idleFor(Duration.ofSeconds(1));
    delegate.onConsoleMessage("closed", 3);
    assertTrue(calls.isEmpty());
  }

  @Test public void bytePressurePreservesLargeMessagesIntact() {
    String large = String.join("", Collections.nCopies(40000, "x"));
    String oversized = large + large;
    delegate.onConsoleMessage(large, 1);
    delegate.onConsoleMessage(large, 1);
    delegate.onConsoleMessage(oversized, 1);
    delegate.onConsoleMessage("tail", 1);
    shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(25));
    assertEquals(Arrays.asList(large, large, oversized, "tail"), messages());
    assertEquals(4, calls.size());
  }
}
