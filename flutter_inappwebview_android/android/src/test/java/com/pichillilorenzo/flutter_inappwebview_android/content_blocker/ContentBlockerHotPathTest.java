package com.pichillilorenzo.flutter_inappwebview_android.content_blocker;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNotSame;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertSame;
import static org.junit.Assert.assertThrows;
import static org.robolectric.Shadows.shadowOf;

import android.os.Looper;
import android.webkit.WebView;

import com.pichillilorenzo.flutter_inappwebview_android.types.WebResourceRequestExt;
import com.pichillilorenzo.flutter_inappwebview_android.webview.WebViewChannelDelegate;
import com.pichillilorenzo.flutter_inappwebview_android.webview.in_app_webview.InAppWebView;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.RuntimeEnvironment;
import org.robolectric.annotation.Config;
import org.robolectric.annotation.Implementation;
import org.robolectric.annotation.Implements;
import org.robolectric.annotation.LooperMode;
import org.robolectric.shadow.api.Shadow;
import org.robolectric.shadows.ShadowWebView;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

@RunWith(RobolectricTestRunner.class)
@Config(sdk = 28, shadows = ContentBlockerHotPathTest.UrlShadowWebView.class)
@LooperMode(LooperMode.Mode.PAUSED)
public class ContentBlockerHotPathTest {
  private InAppWebView webView;
  private UrlShadowWebView urlState;
  private ContentBlockerHandler handler;
  private final WebResourceRequestExt request =
      new WebResourceRequestExt("https://cdn.example/image.svg",
          Collections.emptyMap(), false, false, false, "GET");

  @Before
  public void setUp() {
    webView = new InAppWebView(RuntimeEnvironment.getApplication());
    urlState = Shadow.extract(webView);
    webView.customSettings.contentBlockers = new ArrayList<>();
    BinaryMessenger messenger = new BinaryMessenger() {
      @Override public void send(String channel, ByteBuffer message) {}
      @Override public void send(String channel, ByteBuffer message, BinaryReply callback) {}
      @Override public void setMessageHandler(String channel, BinaryMessageHandler callback) {}
    };
    webView.channelDelegate = new WebViewChannelDelegate(
        webView, new MethodChannel(messenger, "content-blocker"));
    handler = new ContentBlockerHandler();
  }

  @After
  public void tearDown() {
    if (webView != null) {
      webView.dispose();
      webView.destroy();
    }
    shadowOf(Looper.getMainLooper()).idle();
  }

  private ContentBlocker blocker(ContentBlockerTriggerResourceType type,
                                 List<String> ifDomain, List<String> unlessDomain) {
    ContentBlockerTrigger trigger = new ContentBlockerTrigger(
        "https://cdn\\.example/.*", true,
        new ArrayList<>(Collections.singletonList(type)),
        ifDomain, unlessDomain, null, null, null);
    ContentBlockerAction action =
        ContentBlockerAction.fromMap(Collections.singletonMap("type", "block"));
    return new ContentBlocker(trigger, action);
  }

  private ContentBlocker topUrlBlocker(List<String> loadType,
                                      List<String> ifTopUrl, List<String> unlessTopUrl) {
    return new ContentBlocker(new ContentBlockerTrigger(
        "https://cdn\\.example/.*", true,
        Collections.singletonList(ContentBlockerTriggerResourceType.IMAGE),
        null, null, loadType, ifTopUrl, unlessTopUrl),
        ContentBlockerAction.fromMap(Collections.singletonMap("type", "block")));
  }

  private List<ContentBlocker> unavailableTopUrlRules() {
    List<ContentBlocker> rules = new ArrayList<>();
    for (int i = 0; i < 20; ++i) {
      rules.add(topUrlBlocker(null, Collections.singletonList("https://otzaria.org"), null));
    }
    rules.add(blocker(ContentBlockerTriggerResourceType.IMAGE, null, null));
    return rules;
  }

  @Test
  public void laterBlockerRunsWhenEarlierResourceTypeDoesNotMatch() throws Exception {
    handler.setRuleList(Arrays.asList(
        blocker(ContentBlockerTriggerResourceType.FONT, null, null),
        blocker(ContentBlockerTriggerResourceType.IMAGE, null, null)));
    assertNotNull(handler.checkUrl(webView, request, ContentBlockerTriggerResourceType.IMAGE));
  }

  @Test
  public void laterBlockerRunsWhenEarlierDomainDoesNotMatch() throws Exception {
    handler.setRuleList(Arrays.asList(
        blocker(ContentBlockerTriggerResourceType.IMAGE,
                Collections.singletonList("different.example"), null),
        blocker(ContentBlockerTriggerResourceType.IMAGE, null, null)));
    assertNotNull(handler.checkUrl(webView, request, ContentBlockerTriggerResourceType.IMAGE));
  }

  @Test
  public void excludedDomainOnlySkipsItsOwnRule() throws Exception {
    handler.setRuleList(Arrays.asList(
        blocker(ContentBlockerTriggerResourceType.IMAGE,
                null, Collections.singletonList("cdn.example")),
        blocker(ContentBlockerTriggerResourceType.IMAGE, null, null)));
    assertNotNull(handler.checkUrl(webView, request, ContentBlockerTriggerResourceType.IMAGE));
  }

  @Test
  public void imageRuleCoversSvgWithoutMutatingSharedTriggerList() throws Exception {
    ContentBlocker rule = blocker(ContentBlockerTriggerResourceType.IMAGE, null, null);
    handler.setRuleList(Collections.singletonList(rule));
    assertNotNull(handler.checkUrl(webView, request,
        ContentBlockerTriggerResourceType.SVG_DOCUMENT));
    assertEquals(Collections.singletonList(ContentBlockerTriggerResourceType.IMAGE),
        rule.getTrigger().getResourceType());
  }

  @Test
  public void pendingNavigationKeepsCurrentDocumentConditions() throws Exception {
    urlState.currentUrl = "https://cdn.example/current";
    // Android permits onPageStarted(B) while getUrl() still describes A.
    webView.channelDelegate.onLoadStart("https://pending.example/new");

    handler.setRuleList(Collections.singletonList(
        topUrlBlocker(null, Collections.singletonList("https://cdn.example"), null)));
    assertNotNull(handler.checkUrl(webView, request, ContentBlockerTriggerResourceType.IMAGE));
    handler.setRuleList(Collections.singletonList(
        topUrlBlocker(null, null, Collections.singletonList("https://cdn.example"))));
    assertNull(handler.checkUrl(webView, request, ContentBlockerTriggerResourceType.IMAGE));
    handler.setRuleList(Collections.singletonList(
        topUrlBlocker(Collections.singletonList("first-party"), null, null)));
    assertNotNull(handler.checkUrl(webView, request, ContentBlockerTriggerResourceType.IMAGE));
    handler.setRuleList(Collections.singletonList(
        topUrlBlocker(Collections.singletonList("third-party"), null, null)));
    assertNull(handler.checkUrl(webView, request, ContentBlockerTriggerResourceType.IMAGE));
  }

  @Test
  public void topUrlIsReadOncePerRequestAndRefreshedForTheNextRequest() throws Exception {
    handler.setRuleList(Arrays.asList(
        topUrlBlocker(null, Collections.singletonList("https://different.example"), null),
        topUrlBlocker(null, Collections.singletonList("https://otzaria.org"), null)));
    urlState.currentUrl = "https://otzaria.org/plugins";
    urlState.urlReads = 0;

    // The owner looper is paused: posting and waiting here would self-deadlock.
    assertNotNull(handler.checkUrl(webView, request, ContentBlockerTriggerResourceType.IMAGE));
    assertEquals(1, urlState.urlReads);
    urlState.currentUrl = "https://unrelated.example/current";
    // Late lifecycle callbacks must not overwrite the current document URL.
    webView.channelDelegate.onLoadStop("https://otzaria.org/previous");
    webView.channelDelegate.onPageCommitVisible("https://otzaria.org/previous");
    assertNull(handler.checkUrl(webView, request, ContentBlockerTriggerResourceType.IMAGE));
    assertEquals(2, urlState.urlReads);
  }

  @Test
  public void completedNullLookupIsNotRepeatedForLaterRules() throws Exception {
    handler.setRuleList(unavailableTopUrlRules());
    urlState.currentUrl = null;
    urlState.urlReads = 0;
    assertNotNull(handler.checkUrl(webView, request, ContentBlockerTriggerResourceType.IMAGE));
    assertEquals(1, urlState.urlReads);
  }

  @Test
  public void disposedWebViewDoesNotReadTheNativeUrl() throws Exception {
    handler.setRuleList(Collections.singletonList(
        topUrlBlocker(null, Collections.singletonList("https://otzaria.org"), null)));
    webView.dispose();
    urlState.currentUrl = "https://otzaria.org/plugins";
    urlState.urlReads = 0;
    assertNull(handler.checkUrl(webView, request, ContentBlockerTriggerResourceType.IMAGE));
    assertEquals(0, urlState.urlReads);
  }

  @Test
  public void backgroundRequestHasOneTimeoutForAllRulesAndCancelsItsLookup() throws Exception {
    handler.setRuleList(unavailableTopUrlRules());
    urlState.currentUrl = "https://otzaria.org/plugins";
    urlState.urlReads = 0;
    ExecutorService worker = Executors.newSingleThreadExecutor();
    try {
      Future<?> result = worker.submit(() -> {
        try {
          // The Robolectric main looper stays paused while this runs.
          return handler.checkUrl(webView, request, ContentBlockerTriggerResourceType.IMAGE);
        } catch (Exception e) {
          throw new RuntimeException(e);
        }
      });
      // Twenty separate 200 ms waits would take four seconds. The independent
      // final rule must run after one bounded wait, with ample CI scheduling margin.
      assertNotNull(result.get(2, TimeUnit.SECONDS));
      assertEquals(0, urlState.urlReads);
      shadowOf(Looper.getMainLooper()).idle();
      assertEquals(0, urlState.urlReads); // Timed-out callback was removed.
    } finally {
      worker.shutdownNow();
    }
  }

  @Test
  public void interruptedBackgroundRequestCancelsItsLookup() throws Exception {
    handler.setRuleList(Collections.singletonList(
        topUrlBlocker(null, Collections.singletonList("https://otzaria.org"), null)));
    urlState.currentUrl = "https://otzaria.org/plugins";
    urlState.urlReads = 0;
    ExecutorService worker = Executors.newSingleThreadExecutor();
    try {
      Future<?> result = worker.submit(() -> {
        Thread.currentThread().interrupt();
        try {
          assertThrows(InterruptedException.class, () ->
              handler.checkUrl(webView, request, ContentBlockerTriggerResourceType.IMAGE));
        } finally {
          Thread.interrupted();
        }
      });
      result.get(2, TimeUnit.SECONDS);
      shadowOf(Looper.getMainLooper()).idle();
      assertEquals(0, urlState.urlReads);
    } finally {
      worker.shutdownNow();
    }
  }

  @Test
  public void ruleSnapshotsArePublishedAtomicallyAndReused() throws Exception {
    List<ContentBlocker> first = Collections.singletonList(
        blocker(ContentBlockerTriggerResourceType.FONT, null, null));
    handler.setRuleList(first);
    List<ContentBlocker> firstSnapshot = handler.getRuleList();
    assertNotSame(first, firstSnapshot);
    assertNull(handler.checkUrl(webView, request, ContentBlockerTriggerResourceType.IMAGE));

    List<ContentBlocker> second = Collections.singletonList(
        blocker(ContentBlockerTriggerResourceType.IMAGE, null, null));
    handler.setRuleList(second);
    assertNotSame(firstSnapshot, handler.getRuleList());
    assertEquals(1, firstSnapshot.size()); // Prior request readers retain their version.
    List<ContentBlocker> published = handler.getRuleList();
    for (int i = 0; i < 50; ++i) {
      assertNotNull(handler.checkUrl(webView, request, ContentBlockerTriggerResourceType.IMAGE));
      assertSame(published, handler.getRuleList());
    }
    assertEquals(0, urlState.urlReads); // Unconstrained rules require no URL lookup.
  }

  @Implements(WebView.class)
  public static class UrlShadowWebView extends ShadowWebView {
    String currentUrl;
    int urlReads;

    @Implementation(minSdk = 28)
    public Looper getWebViewLooper() {
      return Looper.getMainLooper();
    }

    @Implementation
    @Override
    protected String getUrl() {
      assertSame(Looper.getMainLooper(), Looper.myLooper());
      ++urlReads;
      return currentUrl;
    }
  }
}
