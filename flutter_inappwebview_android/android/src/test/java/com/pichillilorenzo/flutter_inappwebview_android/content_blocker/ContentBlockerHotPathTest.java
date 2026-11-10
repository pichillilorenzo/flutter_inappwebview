package com.pichillilorenzo.flutter_inappwebview_android.content_blocker;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNotSame;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertSame;
import static org.robolectric.Shadows.shadowOf;

import android.os.Looper;

import com.pichillilorenzo.flutter_inappwebview_android.types.WebResourceRequestExt;
import com.pichillilorenzo.flutter_inappwebview_android.webview.in_app_webview.InAppWebView;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.RuntimeEnvironment;
import org.robolectric.annotation.Config;
import org.robolectric.annotation.LooperMode;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

@RunWith(RobolectricTestRunner.class)
@Config(sdk = 28)
@LooperMode(LooperMode.Mode.PAUSED)
public class ContentBlockerHotPathTest {
  private InAppWebView webView;
  private ContentBlockerHandler handler;
  private final WebResourceRequestExt request =
      new WebResourceRequestExt("https://cdn.example/image.svg",
          Collections.emptyMap(), false, false, false, "GET");

  @Before
  public void setUp() {
    webView = new InAppWebView(RuntimeEnvironment.getApplication());
    webView.customSettings.contentBlockers = new ArrayList<>();
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
  }
}
