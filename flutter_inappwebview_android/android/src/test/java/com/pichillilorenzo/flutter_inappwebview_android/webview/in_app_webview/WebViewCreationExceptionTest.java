package com.pichillilorenzo.flutter_inappwebview_android.webview.in_app_webview;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertSame;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

public class WebViewCreationExceptionTest {
  @Test
  public void retainsCreationStageAndOriginalRuntimeFailure() {
    RuntimeException nativeFailure = new RuntimeException("WebView provider unavailable");

    WebViewCreationException failure = new WebViewCreationException(
        WebViewCreationException.STAGE_IN_APP_WEB_VIEW_CONSTRUCTOR, nativeFailure);

    assertTrue(failure instanceof IllegalStateException);
    assertEquals("InAppWebView.<init>", failure.stage);
    assertTrue(failure.getMessage().contains("WebView provider unavailable"));
    assertSame(nativeFailure, failure.getCause());
  }
}
