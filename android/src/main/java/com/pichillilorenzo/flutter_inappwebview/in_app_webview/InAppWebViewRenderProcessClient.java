package com.pichillilorenzo.flutter_inappwebview.in_app_webview;

import android.util.Log;
import android.webkit.WebView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.webkit.WebViewFeature;
import androidx.webkit.WebViewRenderProcess;
import androidx.webkit.WebViewRenderProcessClient;

public class InAppWebViewRenderProcessClient extends WebViewRenderProcessClient {

  protected static final String LOG_TAG = "IAWRenderProcessClient";

  public InAppWebViewRenderProcessClient() {
    super();
  }

  @Override
  public void onRenderProcessUnresponsive(@NonNull WebView view, @Nullable final WebViewRenderProcess renderer) {
    final InAppWebView webView = (InAppWebView) view;
    final EventChannelDelegate.RenderProcessUnresponsiveCallback callback = new EventChannelDelegate.RenderProcessUnresponsiveCallback() {
      @Override
      public boolean nonNullSuccess(@NonNull Integer action) {
        if (renderer != null) {
          switch (action) {
            case 0:
              if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_VIEW_RENDERER_TERMINATE))
                renderer.terminate();
              break;
          }
          return false;
        }
        return true;
      }

      @Override
      public void defaultBehaviour(@Nullable Integer result) {
        
      }

      @Override
      public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
        Log.e(LOG_TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
        defaultBehaviour(null);
      }
    };

    if (webView.eventChannelDelegate != null) {
      webView.eventChannelDelegate.onRenderProcessUnresponsive(webView.getUrl(), callback);
    } else {
      callback.defaultBehaviour(null);
    }
  }

  @Override
  public void onRenderProcessResponsive(@NonNull WebView view, @Nullable final WebViewRenderProcess renderer) {
    final InAppWebView webView = (InAppWebView) view;
    final EventChannelDelegate.RenderProcessResponsiveCallback callback = new EventChannelDelegate.RenderProcessResponsiveCallback() {
      @Override
      public boolean nonNullSuccess(@NonNull Integer action) {
        if (renderer != null) {
          switch (action) {
            case 0:
              if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_VIEW_RENDERER_TERMINATE))
                renderer.terminate();
              break;
          }
          return false;
        }
        return true;
      }

      @Override
      public void defaultBehaviour(@Nullable Integer result) {

      }

      @Override
      public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
        Log.e(LOG_TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
        defaultBehaviour(null);
      }
    };

    if (webView.eventChannelDelegate != null) {
      webView.eventChannelDelegate.onRenderProcessResponsive(webView.getUrl(), callback);
    } else {
      callback.defaultBehaviour(null);
    }
  }

  void dispose() {

  }
}
