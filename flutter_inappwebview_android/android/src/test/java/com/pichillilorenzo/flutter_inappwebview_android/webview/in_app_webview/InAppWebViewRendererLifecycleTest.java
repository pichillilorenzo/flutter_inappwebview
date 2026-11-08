package com.pichillilorenzo.flutter_inappwebview_android.webview.in_app_webview;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertSame;
import static org.junit.Assert.assertThrows;
import static org.junit.Assert.assertTrue;
import static org.robolectric.Shadows.shadowOf;

import android.os.Looper;
import android.view.ActionMode;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.View;
import android.webkit.RenderProcessGoneDetail;
import android.webkit.ValueCallback;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

import com.pichillilorenzo.flutter_inappwebview_android.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview_android.types.ContentWorld;
import com.pichillilorenzo.flutter_inappwebview_android.types.PluginScript;
import com.pichillilorenzo.flutter_inappwebview_android.types.UserContentController;
import com.pichillilorenzo.flutter_inappwebview_android.types.UserScriptInjectionTime;
import com.pichillilorenzo.flutter_inappwebview_android.webview.WebViewChannelDelegate;

import org.junit.After;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.RuntimeEnvironment;
import org.robolectric.annotation.Config;
import org.robolectric.annotation.Implementation;
import org.robolectric.annotation.Implements;
import org.robolectric.annotation.LooperMode;
import org.robolectric.fakes.RoboMenu;
import org.robolectric.shadow.api.Shadow;
import org.robolectric.shadows.ShadowWebView;
import org.robolectric.util.ReflectionHelpers;

import java.nio.ByteBuffer;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicReference;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMethodCodec;

@RunWith(RobolectricTestRunner.class)
@Config(sdk = 28, shadows = InAppWebViewRendererLifecycleTest.CountingShadowWebView.class)
@LooperMode(LooperMode.Mode.PAUSED)
public class InAppWebViewRendererLifecycleTest {
  private final List<InAppWebView> views = new ArrayList<>();
  private final RecordingMessenger messenger = new RecordingMessenger();
  private final RenderProcessGoneDetail rendererExit = new RenderProcessGoneDetail() {
    @Override public boolean didCrash() { return true; }
    @Override public int rendererPriorityAtExit() { return WebView.RENDERER_PRIORITY_BOUND; }
  };

  private InAppWebView newView() {
    InAppWebView view = new InAppWebView(RuntimeEnvironment.getApplication());
    view.plugin = new InAppWebViewFlutterPlugin();
    view.customSettings.useOnRenderProcessGone = true;
    view.channelDelegate = new WebViewChannelDelegate(
        view, new MethodChannel(messenger, "renderer-lifecycle-" + views.size()));
    views.add(view);
    return view;
  }

  private CountingShadowWebView shadow(InAppWebView view) {
    return Shadow.extract(view);
  }

  @After
  public void tearDown() {
    for (InAppWebView view : views) {
      view.dispose();
      view.destroy();
    }
    shadowOf(Looper.getMainLooper()).idle();
  }

  @Test
  public void platformClientDetachesAndDestroysHandledRendererOnce() {
    verifyClient(new InAppWebViewClient(null));
  }

  @Test
  public void disabledScrollSubscriptionStillHidesTheContextMenu() {
    InAppWebView view = newView();
    view.floatingContextMenu = new LinearLayout(view.getContext());
    setScrollSubscription(view, false);
    for (int i = 1; i <= 10000; i++) {
      view.onScrollChanged(i, i * 2, i - 1, (i - 1) * 2);
    }
    assertTrue(messenger.calls.isEmpty());
    assertEquals(View.GONE, view.floatingContextMenu.getVisibility());
    assertEquals(0.0f, view.floatingContextMenu.getAlpha(), 0.0f);
  }

  @Test
  public void scrollSubscriptionUpdatesInPlaceAndKeepsFinalCoordinates() {
    InAppWebView view = newView();
    assertTrue(view.hasScrollChangedListener); // Legacy and InAppBrowser default.
    setScrollSubscription(view, false);
    view.onScrollChanged(1, 2, 0, 0);
    setScrollSubscription(view, true);
    view.onScrollChanged(37, 53, 1, 2);
    view.onScrollChanged(41, 59, 37, 53);
    assertEquals(2, messenger.calls.size());
    assertEquals("onScrollChanged", messenger.calls.get(1).method);
    assertEquals(Integer.valueOf(41), messenger.calls.get(1).argument("x"));
    assertEquals(Integer.valueOf(59), messenger.calls.get(1).argument("y"));
    setScrollSubscription(view, false);
    view.onScrollChanged(61, 67, 41, 59);
    assertEquals(2, messenger.calls.size());
  }

  private void setScrollSubscription(InAppWebView view, boolean enabled) {
    AtomicReference<Object> result = new AtomicReference<>();
    view.channelDelegate.onMethodCall(new MethodCall("setScrollChangedListener",
        Collections.singletonMap("hasListener", enabled)), new MethodChannel.Result() {
      @Override public void success(Object value) { result.set(value); }
      @Override public void error(String code, String message, Object details) {
        throw new AssertionError(code + ": " + message);
      }
      @Override public void notImplemented() { throw new AssertionError("missing scroll gate"); }
    });
    assertEquals(true, result.get());
    assertEquals(enabled, view.hasScrollChangedListener);
  }

  @Test
  public void compatClientDetachesAndDestroysHandledRendererOnce() {
    verifyClient(new InAppWebViewClientCompat(null));
  }

  private void verifyClient(WebViewClient client) {
    InAppWebView view = newView();
    FrameLayout parent = new FrameLayout(view.getContext());
    parent.addView(view);
    List<String> results = new ArrayList<>();
    view.evaluateJavascript("pending()", null, results::add);

    assertTrue(client.onRenderProcessGone(view, rendererExit));
    assertEquals(1, messenger.calls.size());
    MethodCall event = messenger.calls.get(0);
    assertEquals("onRenderProcessGone", event.method);
    assertEquals(true, event.argument("didCrash"));
    assertEquals(Integer.valueOf(WebView.RENDERER_PRIORITY_BOUND), event.argument("rendererPriorityAtExit"));
    assertNull(view.getParent());
    assertEquals(1, shadow(view).destroyCount);
    assertEquals(Collections.singletonList("null"), results);
    assertNull(shadow(view).getLastLoadedUrl());
    shadowOf(Looper.getMainLooper()).idle();
    assertEquals(0, shadow(view).scripts.size());
    view.dispose();
    view.destroy();
    assertEquals(1, shadow(view).destroyCount);
  }

  @Test
  public void ordinaryEvaluationCompletesOnceAndIgnoresLateNativeResult() {
    InAppWebView view = newView();
    List<String> results = new ArrayList<>();
    view.evaluateJavascript("pending()", null, results::add);
    shadowOf(Looper.getMainLooper()).idle();
    ValueCallback<String> nativeReply = shadow(view).getLastEvaluatedJavascriptCallback();
    assertNotNull(nativeReply);

    new InAppWebViewClient(null).onRenderProcessGone(view, rendererExit);
    assertEquals(Collections.singletonList("null"), results);
    nativeReply.onReceiveValue("42");
    assertEquals(Collections.singletonList("null"), results);
    assertEquals(0, view.evaluateJavaScriptContentWorldCallbacks.size());
  }

  @Test
  public void nativeOverloadAlsoCompletesPendingCallbacksAtDispose() {
    InAppWebView view = newView();
    List<String> results = new ArrayList<>();
    view.evaluateJavascript("pending()", results::add);
    ValueCallback<String> nativeReply = shadow(view).getLastEvaluatedJavascriptCallback();
    view.dispose();
    assertEquals(Collections.singletonList("null"), results);
    nativeReply.onReceiveValue("42");
    assertEquals(Collections.singletonList("null"), results);
  }

  @Test
  public void bridgeCallbacksAreDrainedWithoutTouchingReplacementView() {
    InAppWebView oldView = newView();
    InAppWebView replacement = newView();
    List<String> asyncResults = new ArrayList<>();
    List<String> worldResults = new ArrayList<>();
    List<String> replacementResults = new ArrayList<>();
    oldView.callAsyncJavaScript("return await never();", Collections.emptyMap(), null, asyncResults::add);
    oldView.evaluateJavascript("pending()", ContentWorld.world("isolated"), worldResults::add);
    replacement.evaluateJavascript("replacement()", null, replacementResults::add);
    String asyncId = callbackId(oldView.callAsyncJavaScriptCallbacks);
    String worldId = callbackId(oldView.evaluateJavaScriptContentWorldCallbacks);

    new InAppWebViewClient(null).onRenderProcessGone(oldView, rendererExit);
    assertEquals(Collections.singletonList("{\"value\":null,\"error\":\"WebView renderer exited\"}"), asyncResults);
    assertEquals(Collections.singletonList("null"), worldResults);
    oldView.callAsyncJavaScriptCallbacks.complete(asyncId, "late async result");
    oldView.evaluateJavaScriptContentWorldCallbacks.complete(worldId, "late world result");
    assertEquals(1, asyncResults.size());
    assertEquals(1, worldResults.size());
    shadowOf(Looper.getMainLooper()).idle();
    assertTrue(replacementResults.isEmpty());
    assertEquals(0, shadow(replacement).destroyCount);
    shadow(replacement).getLastEvaluatedJavascriptCallback().onReceiveValue("7");
    assertEquals(Collections.singletonList("7"), replacementResults);
  }

  @Test
  public void healthyDisposePreservesAnotherViewsQueuedEvaluation() {
    InAppWebView closing = newView();
    InAppWebView surviving = newView();
    List<String> closingResults = new ArrayList<>();
    List<String> survivingResults = new ArrayList<>();
    closing.evaluateJavascript("closingDocument()", null, closingResults::add);
    surviving.evaluateJavascript("survivingDocument()", null, survivingResults::add);

    closing.dispose();
    closing.getWebViewClient().onPageFinished(closing, "about:blank");
    shadowOf(Looper.getMainLooper()).idle();

    assertEquals(Collections.singletonList("null"), closingResults);
    assertTrue(shadow(closing).scripts.isEmpty());
    assertEquals(1, shadow(closing).destroyCount);
    assertEquals(Collections.singletonList("survivingDocument()"), shadow(surviving).scripts);
    assertEquals(0, shadow(surviving).destroyCount);
    assertEquals(1, surviving.evaluateJavaScriptContentWorldCallbacks.size());
    assertTrue(survivingResults.isEmpty());
    shadow(surviving).getLastEvaluatedJavascriptCallback().onReceiveValue("41");
    assertEquals(Collections.singletonList("41"), survivingResults);
    assertEquals(0, surviving.evaluateJavaScriptContentWorldCallbacks.size());
  }

  @Test
  public void healthyDisposeIgnoresLateRepliesWithoutCancellingPeerBridgeWork() {
    InAppWebView closing = newView();
    InAppWebView surviving = newView();
    List<String> closingResults = new ArrayList<>();
    List<String> survivingResults = new ArrayList<>();
    List<String> survivingAsyncResults = new ArrayList<>();
    closing.evaluateJavascript("closing()", closingResults::add);
    ValueCallback<String> closingReply = shadow(closing).getLastEvaluatedJavascriptCallback();
    surviving.evaluateJavascript("surviving()", survivingResults::add);
    ValueCallback<String> survivingReply = shadow(surviving).getLastEvaluatedJavascriptCallback();
    surviving.callAsyncJavaScript("return await pending();", Collections.emptyMap(), null,
        survivingAsyncResults::add);
    String asyncId = callbackId(surviving.callAsyncJavaScriptCallbacks);

    closing.dispose();
    closing.dispose();
    closingReply.onReceiveValue("late closing reply");
    shadowOf(Looper.getMainLooper()).idle();
    assertEquals(Collections.singletonList("null"), closingResults);
    assertTrue(survivingResults.isEmpty());
    assertTrue(survivingAsyncResults.isEmpty());
    assertEquals(1, surviving.callAsyncJavaScriptCallbacks.size());
    survivingReply.onReceiveValue("42");
    surviving.callAsyncJavaScriptCallbacks.complete(asyncId, "{\"value\":43}");
    assertEquals(Collections.singletonList("42"), survivingResults);
    assertEquals(Collections.singletonList("{\"value\":43}"), survivingAsyncResults);
    assertEquals(0, surviving.callAsyncJavaScriptCallbacks.size());
    assertEquals(0, surviving.evaluateJavaScriptContentWorldCallbacks.size());
    assertEquals(0, shadow(surviving).destroyCount);
  }

  @Test
  public void pauseAndResumeChannelCallsTargetOnlyTheirOwnView() {
    InAppWebView first = newView();
    InAppWebView second = newView();
    callLifecycle(first, "pause");
    assertEquals(1, shadow(first).pauseCount);
    assertEquals(0, shadow(second).pauseCount);
    callLifecycle(first, "resume");
    assertEquals(1, shadow(first).resumeCount);
    assertEquals(0, shadow(second).resumeCount);

    first.dispose();
    callLifecycle(second, "pause");
    callLifecycle(second, "resume");
    assertEquals(1, shadow(first).pauseCount);
    assertEquals(1, shadow(first).resumeCount);
    assertEquals(1, shadow(second).pauseCount);
    assertEquals(1, shadow(second).resumeCount);
    assertEquals(0, shadow(second).destroyCount);
    // pauseTimers/resumeTimers intentionally have process-wide Android semantics.
    // This checks per-view onPause/onResume routing, not native JS timer progress.
  }

  @Test
  public void repeatedPeerCloseCyclesRetainTheSurvivorsPendingReply() {
    InAppWebView surviving = newView();
    List<String> survivingResults = new ArrayList<>();
    surviving.evaluateJavascript("sameDocument()", survivingResults::add);
    ValueCallback<String> survivingReply = shadow(surviving).getLastEvaluatedJavascriptCallback();
    for (int cycle = 0; cycle < 25; cycle++) {
      InAppWebView closing = newView();
      List<String> closingResults = new ArrayList<>();
      closing.evaluateJavascript("pending()", null, closingResults::add);
      closing.dispose();
      closing.getWebViewClient().onPageFinished(closing, "about:blank");
      closing.dispose();
      closing.destroy();
      shadowOf(Looper.getMainLooper()).idle();
      assertEquals(Collections.singletonList("null"), closingResults);
      assertEquals(0, closing.evaluateJavaScriptContentWorldCallbacks.size());
      assertEquals(0, closing.callAsyncJavaScriptCallbacks.size());
      assertEquals(1, shadow(closing).destroyCount);
      assertEquals(1, surviving.evaluateJavaScriptContentWorldCallbacks.size());
      assertTrue(survivingResults.isEmpty());
      assertEquals(0, shadow(surviving).destroyCount);
      assertEquals(Collections.singletonList("sameDocument()"), shadow(surviving).scripts);
    }
    survivingReply.onReceiveValue("44");
    assertEquals(Collections.singletonList("44"), survivingResults);
    assertEquals(0, surviving.evaluateJavaScriptContentWorldCallbacks.size());
  }

  private void callLifecycle(InAppWebView view, String method) {
    AtomicReference<Object> result = new AtomicReference<>();
    view.channelDelegate.onMethodCall(new MethodCall(method, null), new MethodChannel.Result() {
      @Override public void success(Object value) { result.set(value); }
      @Override public void error(String code, String message, Object details) {
        throw new AssertionError(code + ": " + message);
      }
      @Override public void notImplemented() { throw new AssertionError("missing " + method); }
    });
    assertEquals(true, result.get());
  }

  @Test
  public void navigationCancelsScheduledEvaluationButAllowsNewDocumentWork() {
    InAppWebView view = newView();
    List<String> oldResults = new ArrayList<>();
    List<String> newResults = new ArrayList<>();
    view.evaluateJavascript("oldDocument()", null, oldResults::add);
    view.cancelPendingJavaScriptCallbacks("Document navigated");
    view.evaluateJavascript("newDocument()", null, newResults::add);
    shadowOf(Looper.getMainLooper()).idle();

    assertEquals(Collections.singletonList("null"), oldResults);
    assertEquals(Collections.singletonList("newDocument()"), shadow(view).scripts);
    shadow(view).getLastEvaluatedJavascriptCallback().onReceiveValue("8");
    assertEquals(Collections.singletonList("8"), newResults);
  }

  @Test
  public void healthyDisposeWaitsForBlankButRendererExitDuringWaitDestroys() {
    InAppWebView healthy = newView();
    healthy.dispose();
    assertEquals("about:blank", shadow(healthy).getLastLoadedUrl());
    assertEquals(0, shadow(healthy).destroyCount);
    healthy.getWebViewClient().onPageFinished(healthy, "about:blank");
    assertEquals(1, shadow(healthy).destroyCount);

    InAppWebView interrupted = newView();
    interrupted.customSettings.useOnRenderProcessGone = false;
    interrupted.dispose();
    WebViewClient disposalClient = interrupted.getWebViewClient();
    assertEquals(0, shadow(interrupted).destroyCount);
    assertTrue(disposalClient.onRenderProcessGone(interrupted, rendererExit));
    assertEquals(1, shadow(interrupted).destroyCount);
    disposalClient.onPageFinished(interrupted, "about:blank");
    assertEquals(1, shadow(interrupted).destroyCount);
  }

  @Test
  public void terminalViewRejectsNewJavaScriptWithoutCallingRenderer() {
    InAppWebView view = newView();
    new InAppWebViewClient(null).onRenderProcessGone(view, rendererExit);
    List<String> ordinary = new ArrayList<>();
    List<String> async = new ArrayList<>();
    view.evaluateJavascript("deferred()", null, ordinary::add);
    view.evaluateJavascript("direct()", ordinary::add);
    view.evaluateJavascript("fireAndForget()", (ValueCallback<String>) null);
    view.callAsyncJavaScript("return 1", Collections.emptyMap(), null, async::add);
    shadowOf(Looper.getMainLooper()).idle();

    assertEquals(2, ordinary.size());
    assertEquals("null", ordinary.get(0));
    assertEquals("null", ordinary.get(1));
    assertEquals(Collections.singletonList("{\"value\":null,\"error\":\"WebView is no longer available\"}"), async);
    assertEquals(0, shadow(view).scripts.size());
    assertEquals(0, view.evaluateJavaScriptContentWorldCallbacks.size());
    assertEquals(0, view.callAsyncJavaScriptCallbacks.size());
  }

  @Test
  public void cancellingRuntimeScriptProbeDoesNotRegisterScriptOnDeadRenderer() {
    InAppWebView view = newView();
    RecordingUserContentController controller = new RecordingUserContentController(view);
    view.userContentController = controller;
    PluginScript script = new PluginScript("probe", "window.probe = true;",
        UserScriptInjectionTime.AT_DOCUMENT_START, ContentWorld.PAGE, false, null, true);
    view.enablePluginScriptAtRuntime("probe", true, script);
    shadowOf(Looper.getMainLooper()).idle();
    ValueCallback<String> nativeReply = shadow(view).getLastEvaluatedJavascriptCallback();

    new InAppWebViewClient(null).onRenderProcessGone(view, rendererExit);
    nativeReply.onReceiveValue("null");
    assertEquals(0, controller.addedPluginScripts);
    assertEquals(1, shadow(view).scripts.size());
  }

  @Test
  public void cancellingContextMenuPollDoesNotRescheduleOnDisposedView() {
    InAppWebView view = newView();
    view.customSettings.useHybridComposition = false;
    view.prepare();
    view.floatingContextMenu = new LinearLayout(view.getContext());
    view.addView(view.floatingContextMenu);
    assertNotNull(view.checkContextMenuShouldBeClosedTask);
    view.checkContextMenuShouldBeClosedTask.run();
    int evaluations = shadow(view).scripts.size();
    ValueCallback<String> nativeReply = shadow(view).getLastEvaluatedJavascriptCallback();

    view.dispose();
    assertNull(view.floatingContextMenu);
    nativeReply.onReceiveValue("false");
    shadowOf(Looper.getMainLooper()).idleFor(Duration.ofSeconds(1));
    assertEquals(evaluations, shadow(view).scripts.size());
  }

  @Test
  public void cancellingMenuPositionAfterRemovingChildrenFinishesDisposal() {
    InAppWebView view = newView();
    view.floatingContextMenu = new LinearLayout(view.getContext());
    view.addView(view.floatingContextMenu);
    view.adjustFloatingContextMenuPosition();
    ValueCallback<String> nativeReply = shadow(view).getLastEvaluatedJavascriptCallback();

    view.dispose();
    assertNull(view.floatingContextMenu);
    assertEquals(0, view.getChildCount());
    assertEquals("about:blank", shadow(view).getLastLoadedUrl());
    nativeReply.onReceiveValue("null");
    view.getWebViewClient().onPageFinished(view, "about:blank");
    assertEquals(1, shadow(view).destroyCount);
  }

  @Test
  public void contextMenuLayoutDuringRendererNotificationDoesNotCallDeadRenderer() {
    InAppWebView view = newView();
    view.rebuildActionMode(new EmptyActionMode(), null);
    assertNotNull(view.floatingContextMenu);
    int settingsReads = shadow(view).settingsReads;
    messenger.onSend = () -> {
      assertNotNull(view.floatingContextMenu);
      view.floatingContextMenu.getViewTreeObserver().dispatchOnGlobalLayout();
    };

    assertTrue(new InAppWebViewClient(null).onRenderProcessGone(view, rendererExit));
    assertEquals(settingsReads, shadow(view).settingsReads);
    assertTrue(shadow(view).scripts.isEmpty());
    assertEquals(1, shadow(view).destroyCount);
  }

  @Test
  public void throwingHostCallbackDoesNotPreventOtherCompletionsOrDestruction() {
    InAppWebView view = newView();
    RuntimeException failure = new IllegalStateException("host callback failed");
    List<String> results = new ArrayList<>();
    view.callAsyncJavaScript("return 1;", Collections.emptyMap(), null, value -> { throw failure; });
    view.evaluateJavascript("pending()", null, results::add);

    assertSame(failure, assertThrows(RuntimeException.class, view::dispose));
    assertEquals(Collections.singletonList("null"), results);
    assertEquals(1, shadow(view).destroyCount);
    assertEquals(0, view.callAsyncJavaScriptCallbacks.size());
    assertEquals(0, view.evaluateJavaScriptContentWorldCallbacks.size());
  }

  @Test
  public void disposalFromWorkerThreadRunsOnStoredWebViewLooper() throws Exception {
    InAppWebView view = newView();
    AtomicReference<Throwable> failure = new AtomicReference<>();
    Thread worker = new Thread(() -> {
      try { view.dispose(); } catch (Throwable error) { failure.set(error); }
    });
    worker.start();
    worker.join();
    assertNull(failure.get());
    assertNull(shadow(view).getLastLoadedUrl());
    shadowOf(Looper.getMainLooper()).idle();
    assertEquals("about:blank", shadow(view).getLastLoadedUrl());
    view.getWebViewClient().onPageFinished(view, "about:blank");
    assertSame(Looper.getMainLooper(), shadow(view).destroyLooper);
  }

  @Test
  public void optedOutRendererCallbackRemainsUnhandledAndCompletesPendingWork() {
    InAppWebView view = newView();
    view.customSettings.useOnRenderProcessGone = false;
    List<String> results = new ArrayList<>();
    view.evaluateJavascript("pending()", null, results::add);

    assertFalse(new InAppWebViewClient(null).onRenderProcessGone(view, rendererExit));
    assertTrue(messenger.calls.isEmpty());
    assertEquals(0, shadow(view).destroyCount);
    assertEquals(Collections.singletonList("null"), results);
    shadowOf(Looper.getMainLooper()).idle();
    assertEquals(0, shadow(view).scripts.size());
  }

  private String callbackId(PendingJavaScriptCallbacks callbacks) {
    Map<String, ?> pending = ReflectionHelpers.getField(callbacks, "callbacks");
    assertEquals(1, pending.size());
    return pending.keySet().iterator().next();
  }

  private static final class RecordingUserContentController extends UserContentController {
    int addedPluginScripts;
    RecordingUserContentController(WebView view) { super(view); }
    @Override public boolean addPluginScript(PluginScript script) {
      addedPluginScripts++;
      return super.addPluginScript(script);
    }
  }

  private static final class RecordingMessenger implements BinaryMessenger {
    final List<MethodCall> calls = new ArrayList<>();
    Runnable onSend;
    @Override public void send(String channel, ByteBuffer message) { send(channel, message, null); }
    @Override public void send(String channel, ByteBuffer message, BinaryReply reply) {
      ByteBuffer encoded = message.duplicate();
      encoded.flip();
      calls.add(StandardMethodCodec.INSTANCE.decodeMethodCall(encoded));
      if (onSend != null) onSend.run();
      if (reply != null) reply.reply(null);
    }
    @Override public void setMessageHandler(String channel, BinaryMessageHandler handler) {}
  }

  private static final class EmptyActionMode extends ActionMode {
    private final Menu menu = new RoboMenu();
    @Override public Menu getMenu() { return menu; }
    @Override public void finish() {}
    @Override public void invalidate() {}
    @Override public void hide(long duration) {}
    @Override public void setTitle(CharSequence title) {}
    @Override public void setTitle(int title) {}
    @Override public void setSubtitle(CharSequence subtitle) {}
    @Override public void setSubtitle(int subtitle) {}
    @Override public void setCustomView(View view) {}
    @Override public CharSequence getTitle() { return null; }
    @Override public CharSequence getSubtitle() { return null; }
    @Override public View getCustomView() { return null; }
    @Override public MenuInflater getMenuInflater() { return null; }
  }

  @Implements(WebView.class)
  public static class CountingShadowWebView extends ShadowWebView {
    final List<String> scripts = new ArrayList<>();
    int destroyCount;
    int pauseCount;
    int resumeCount;
    int settingsReads;
    Looper destroyLooper;
    @Implementation(minSdk = 28)
    public Looper getWebViewLooper() { return Looper.getMainLooper(); }
    @Implementation
    protected void onPause() { pauseCount++; }
    @Implementation
    protected void onResume() { resumeCount++; }
    @Implementation
    @Override protected WebSettings getSettings() {
      settingsReads++;
      return super.getSettings();
    }
    @Implementation
    @Override protected void evaluateJavascript(String source, ValueCallback<String> callback) {
      scripts.add(source);
      super.evaluateJavascript(source, callback);
    }
    @Implementation
    @Override protected void destroy() {
      destroyCount++;
      destroyLooper = Looper.myLooper();
      super.destroy();
    }
  }
}
