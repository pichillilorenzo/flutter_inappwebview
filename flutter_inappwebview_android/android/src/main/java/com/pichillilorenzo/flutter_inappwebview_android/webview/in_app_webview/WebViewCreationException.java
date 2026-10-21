package com.pichillilorenzo.flutter_inappwebview_android.webview.in_app_webview;

/** Adds creation-stage context while retaining the original WebView failure. */
public final class WebViewCreationException extends IllegalStateException {
  public static final String STAGE_IN_APP_WEB_VIEW_CONSTRUCTOR = "InAppWebView.<init>";

  public final String stage;

  public WebViewCreationException(String stage, RuntimeException cause) {
    super("WebView creation failed at " + stage + ": " + cause.getMessage(), cause);
    this.stage = stage;
  }
}
