package com.pichillilorenzo.flutter_inappwebview.in_app_webview;

import android.util.Log;
import android.webkit.WebView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.webkit.WebViewFeature;
import androidx.webkit.WebViewRenderProcess;
import androidx.webkit.WebViewRenderProcessClient;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class InAppWebViewRenderProcessClient extends WebViewRenderProcessClient {

  protected static final String LOG_TAG = "IAWRenderProcessClient";
  private final MethodChannel channel;

  public InAppWebViewRenderProcessClient(MethodChannel channel) {
    super();

    this.channel = channel;
  }

  @Override
  public void onRenderProcessUnresponsive(@NonNull WebView view, @Nullable final WebViewRenderProcess renderer) {
    Map<String, Object> obj = new HashMap<>();
    obj.put("url", view.getUrl());
    channel.invokeMethod("onRenderProcessUnresponsive", obj, new MethodChannel.Result() {

      @Override
      public void success(@Nullable Object response) {
        if (response != null) {
          Map<String, Object> responseMap = (Map<String, Object>) response;
          Integer action = (Integer) responseMap.get("action");
          if (action != null && renderer != null) {
            switch (action) {
              case 0:
                if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_VIEW_RENDERER_TERMINATE))
                  renderer.terminate();
                break;
            }
          }
        }
      }

      @Override
      public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
        Log.e(LOG_TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
      }

      @Override
      public void notImplemented() {

      }
    });
  }

  @Override
  public void onRenderProcessResponsive(@NonNull WebView view, @Nullable final WebViewRenderProcess renderer) {
    Map<String, Object> obj = new HashMap<>();
    obj.put("url", view.getUrl());
    channel.invokeMethod("onRenderProcessResponsive", obj, new MethodChannel.Result() {

      @Override
      public void success(@Nullable Object response) {
        if (response != null) {
          Map<String, Object> responseMap = (Map<String, Object>) response;
          Integer action = (Integer) responseMap.get("action");
          if (action != null && renderer != null) {
            switch (action) {
              case 0:
                if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_VIEW_RENDERER_TERMINATE))
                  renderer.terminate();
                break;
            }
          }
        }
      }

      @Override
      public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
        Log.e(LOG_TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
      }

      @Override
      public void notImplemented() {

      }
    });
  }

  void dispose() {

  }
}
