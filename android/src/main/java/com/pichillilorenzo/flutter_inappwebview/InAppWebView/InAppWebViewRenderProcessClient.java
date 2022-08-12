package com.pichillilorenzo.flutter_inappwebview.InAppWebView;

import android.util.Log;
import android.webkit.WebView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.webkit.WebViewFeature;
import androidx.webkit.WebViewRenderProcess;
import androidx.webkit.WebViewRenderProcessClient;

import com.pichillilorenzo.flutter_inappwebview.InAppBrowser.InAppBrowserActivity;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class InAppWebViewRenderProcessClient extends WebViewRenderProcessClient {

  protected static final String LOG_TAG = "IAWRenderProcessClient";
  private FlutterWebView flutterWebView;
  private InAppBrowserActivity inAppBrowserActivity;
  public MethodChannel channel;

  public InAppWebViewRenderProcessClient(Object obj) {
    super();
    if (obj instanceof InAppBrowserActivity)
      this.inAppBrowserActivity = (InAppBrowserActivity) obj;
    else if (obj instanceof FlutterWebView)
      this.flutterWebView = (FlutterWebView) obj;
    this.channel = (this.inAppBrowserActivity != null) ? this.inAppBrowserActivity.channel : this.flutterWebView.channel;
  }

  @Override
  public void onRenderProcessUnresponsive(@NonNull WebView view, @Nullable final WebViewRenderProcess renderer) {
    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("url", view.getUrl());
    channel.invokeMethod("onRenderProcessUnresponsive", obj, new MethodChannel.Result() {

      @Override
      public void success(@Nullable Object response) {
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

      @Override
      public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
        Log.d(LOG_TAG, "ERROR: " + errorCode + " " + errorMessage);
      }

      @Override
      public void notImplemented() {

      }
    });
  }

  @Override
  public void onRenderProcessResponsive(@NonNull WebView view, @Nullable final WebViewRenderProcess renderer) {
    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("url", view.getUrl());
    channel.invokeMethod("onRenderProcessResponsive", obj, new MethodChannel.Result() {

      @Override
      public void success(@Nullable Object response) {
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

      @Override
      public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
        Log.d(LOG_TAG, "ERROR: " + errorCode + " " + errorMessage);
      }

      @Override
      public void notImplemented() {

      }
    });
  }
}
