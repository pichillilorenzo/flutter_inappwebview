package com.pichillilorenzo.flutter_inappwebview.InAppWebView;

import android.content.Context;
import android.hardware.display.DisplayManager;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.pichillilorenzo.flutter_inappwebview.InAppWebViewMethodHandler;
import com.pichillilorenzo.flutter_inappwebview.Shared;
import com.pichillilorenzo.flutter_inappwebview.Util;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class FlutterWebView implements PlatformView {

  static final String LOG_TAG = "IAWFlutterWebView";

  public InAppWebView webView;
  public final MethodChannel channel;
  public InAppWebViewMethodHandler methodCallDelegate;

  public FlutterWebView(BinaryMessenger messenger, final Context context, Object id, HashMap<String, Object> params, View containerView) {
    channel = new MethodChannel(messenger, "com.pichillilorenzo/flutter_inappwebview_" + id);

    DisplayListenerProxy displayListenerProxy = new DisplayListenerProxy();
    DisplayManager displayManager = (DisplayManager) context.getSystemService(Context.DISPLAY_SERVICE);
    displayListenerProxy.onPreWebViewInitialization(displayManager);

    String initialUrl = (String) params.get("initialUrl");
    final String initialFile = (String) params.get("initialFile");
    final Map<String, String> initialData = (Map<String, String>) params.get("initialData");
    final Map<String, String> initialHeaders = (Map<String, String>) params.get("initialHeaders");
    Map<String, Object> initialOptions = (Map<String, Object>) params.get("initialOptions");
    Map<String, Object> contextMenu = (Map<String, Object>) params.get("contextMenu");
    Integer windowId = (Integer) params.get("windowId");
    List<Map<String, Object>> initialUserScripts = (List<Map<String, Object>>) params.get("initialUserScripts");

    InAppWebViewOptions options = new InAppWebViewOptions();
    options.parse(initialOptions);

    if (Shared.activity == null) {
      Log.e(LOG_TAG, "\n\n\nERROR: Shared.activity is null!!!\n\n" +
              "You need to upgrade your Flutter project to use the new Java Embedding API:\n\n" +
              "- Take a look at the \"IMPORTANT Note for Android\" section here: https://github.com/pichillilorenzo/flutter_inappwebview#important-note-for-android\n" +
              "- See the official wiki here: https://github.com/flutter/flutter/wiki/Upgrading-pre-1.12-Android-projects\n\n\n");
    }

    webView = new InAppWebView(context, this, id, windowId, options, contextMenu, containerView, initialUserScripts);
    displayListenerProxy.onPostWebViewInitialization(displayManager);

    methodCallDelegate = new InAppWebViewMethodHandler(webView);
    channel.setMethodCallHandler(methodCallDelegate);

    webView.prepare();

    if (windowId != null) {
      Message resultMsg = InAppWebViewChromeClient.windowWebViewMessages.get(windowId);
      if (resultMsg != null) {
        ((WebView.WebViewTransport) resultMsg.obj).setWebView(webView);
        resultMsg.sendToTarget();
      }
    } else {
      if (initialFile != null) {
        try {
          initialUrl = Util.getUrlAsset(initialFile);
        } catch (IOException e) {
          e.printStackTrace();
          Log.e(LOG_TAG, initialFile + " asset file cannot be found!", e);
          return;
        }
      }

      if (initialData != null) {
        String data = initialData.get("data");
        String mimeType = initialData.get("mimeType");
        String encoding = initialData.get("encoding");
        String baseUrl = initialData.get("baseUrl");
        String historyUrl = initialData.get("historyUrl");
        webView.loadDataWithBaseURL(baseUrl, data, mimeType, encoding, historyUrl);
      }
      else {
        webView.loadUrl(initialUrl, initialHeaders);
      }
    }

    if (containerView == null && id instanceof String) {
      Map<String, Object> obj = new HashMap<>();
      obj.put("uuid", id);
      channel.invokeMethod("onHeadlessWebViewCreated", obj);
    }
  }

  @Override
  public View getView() {
    return webView;
  }

  @Override
  public void dispose() {
    channel.setMethodCallHandler(null);
    if (methodCallDelegate != null) {
      methodCallDelegate.dispose();
      methodCallDelegate = null;
    }
    if (webView != null) {
      webView.inAppWebViewChromeClient.dispose();
      webView.inAppWebViewClient.dispose();
      webView.javaScriptBridgeInterface.dispose();
      webView.setWebChromeClient(new WebChromeClient());
      webView.setWebViewClient(new WebViewClient() {
        @Override
        public void onPageFinished(WebView view, String url) {
          webView.dispose();
          webView.destroy();
          webView = null;
        }
      });
      WebSettings settings = webView.getSettings();
      settings.setJavaScriptEnabled(false);
      webView.loadUrl("about:blank");
    }
  }

  @Override
  public void onInputConnectionLocked() {
    if (webView != null && webView.inAppBrowserActivity == null)
      webView.lockInputConnection();
  }

  @Override
  public void onInputConnectionUnlocked() {
    if (webView != null && webView.inAppBrowserActivity == null)
      webView.unlockInputConnection();
  }

  @Override
  public void onFlutterViewAttached(View flutterView) {
    if (webView != null) {
      webView.setContainerView(flutterView);
    }
  }

  @Override
  public void onFlutterViewDetached() {
    if (webView != null) {
      webView.setContainerView(null);
    }
  }
}