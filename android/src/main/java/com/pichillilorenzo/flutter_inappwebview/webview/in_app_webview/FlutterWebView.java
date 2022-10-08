package com.pichillilorenzo.flutter_inappwebview.webview.in_app_webview;

import android.content.Context;
import android.hardware.display.DisplayManager;
import android.os.Build;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.webkit.WebViewCompat;
import androidx.webkit.WebViewFeature;

import com.pichillilorenzo.flutter_inappwebview.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview.find_interaction.FindInteractionController;
import com.pichillilorenzo.flutter_inappwebview.plugin_scripts_js.JavaScriptBridgeJS;
import com.pichillilorenzo.flutter_inappwebview.pull_to_refresh.PullToRefreshLayout;
import com.pichillilorenzo.flutter_inappwebview.pull_to_refresh.PullToRefreshSettings;
import com.pichillilorenzo.flutter_inappwebview.webview.PlatformWebView;
import com.pichillilorenzo.flutter_inappwebview.types.URLRequest;
import com.pichillilorenzo.flutter_inappwebview.types.UserScript;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class FlutterWebView implements PlatformWebView {

  static final String LOG_TAG = "IAWFlutterWebView";

  @Nullable
  public InAppWebView webView;
  @Nullable
  public PullToRefreshLayout pullToRefreshLayout;

  public FlutterWebView(final InAppWebViewFlutterPlugin plugin, final Context context, Object id,
                        HashMap<String, Object> params) {
    DisplayListenerProxy displayListenerProxy = new DisplayListenerProxy();
    DisplayManager displayManager = (DisplayManager) context.getSystemService(Context.DISPLAY_SERVICE);
    displayListenerProxy.onPreWebViewInitialization(displayManager);
    
    Map<String, Object> initialSettings = (Map<String, Object>) params.get("initialSettings");
    Map<String, Object> contextMenu = (Map<String, Object>) params.get("contextMenu");
    Integer windowId = (Integer) params.get("windowId");
    List<Map<String, Object>> initialUserScripts = (List<Map<String, Object>>) params.get("initialUserScripts");
    Map<String, Object> pullToRefreshInitialSettings = (Map<String, Object>) params.get("pullToRefreshSettings");

    InAppWebViewSettings customSettings = new InAppWebViewSettings();
    customSettings.parse(initialSettings);

    if (plugin == null || plugin.activity == null) {
      Log.e(LOG_TAG, "\n\n\nERROR: You need to upgrade your Flutter project to use the new Java Embedding API:\n\n" +
              "- Take a look at the \"IMPORTANT Note for Android\" section here: https://github.com/pichillilorenzo/flutter_inappwebview#important-note-for-android\n" +
              "- See the official wiki here: https://github.com/flutter/flutter/wiki/Upgrading-pre-1.12-Android-projects\n\n\n");
      return;
    }

    List<UserScript> userScripts = new ArrayList<>();
    if (initialUserScripts != null) {
      for (Map<String, Object> initialUserScript : initialUserScripts) {
        userScripts.add(UserScript.fromMap(initialUserScript));
      }
    }

    webView = new InAppWebView(context, plugin, id, windowId, customSettings, contextMenu, 
            customSettings.useHybridComposition ? null : plugin.flutterView, userScripts);
    displayListenerProxy.onPostWebViewInitialization(displayManager);

    if (customSettings.useHybridComposition) {
      // set MATCH_PARENT layout params to the WebView, otherwise it won't take all the available space!
      webView.setLayoutParams(new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
      PullToRefreshSettings pullToRefreshSettings = new PullToRefreshSettings();
      pullToRefreshSettings.parse(pullToRefreshInitialSettings);
      pullToRefreshLayout = new PullToRefreshLayout(context, plugin, id, pullToRefreshSettings);
      pullToRefreshLayout.addView(webView);
      pullToRefreshLayout.prepare();
    }

    FindInteractionController findInteractionController = new FindInteractionController(webView, plugin, id, null);
    webView.findInteractionController = findInteractionController;
    findInteractionController.prepare();

    webView.prepare();
  }

  @Override
  public View getView() {
    return pullToRefreshLayout != null ? pullToRefreshLayout : webView;
  }

  public void makeInitialLoad(HashMap<String, Object> params) {
    Integer windowId = (Integer) params.get("windowId");
    Map<String, Object> initialUrlRequest = (Map<String, Object>) params.get("initialUrlRequest");
    final String initialFile = (String) params.get("initialFile");
    final Map<String, String> initialData = (Map<String, String>) params.get("initialData");

    if (windowId != null) {
      Message resultMsg = InAppWebViewChromeClient.windowWebViewMessages.get(windowId);
      if (resultMsg != null) {
        ((WebView.WebViewTransport) resultMsg.obj).setWebView(webView);
        resultMsg.sendToTarget();
      }
    } else {
      if (initialFile != null) {
        try {
          webView.loadFile(initialFile);
        } catch (IOException e) {
          e.printStackTrace();
          Log.e(LOG_TAG, initialFile + " asset file cannot be found!", e);
        }
      }
      else if (initialData != null) {
        String data = initialData.get("data");
        String mimeType = initialData.get("mimeType");
        String encoding = initialData.get("encoding");
        String baseUrl = initialData.get("baseUrl");
        String historyUrl = initialData.get("historyUrl");
        webView.loadDataWithBaseURL(baseUrl, data, mimeType, encoding, historyUrl);
      }
      else if (initialUrlRequest != null) {
        URLRequest urlRequest = URLRequest.fromMap(initialUrlRequest);
        if (urlRequest != null) {
          webView.loadUrl(urlRequest);
        }
      }
    }
  }

  @Override
  public void dispose() {
    if (webView != null) {
      if (webView.channelDelegate != null) {
        webView.channelDelegate.dispose();
      }
      webView.removeJavascriptInterface(JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME);
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && WebViewFeature.isFeatureSupported(WebViewFeature.WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE)) {
        WebViewCompat.setWebViewRenderProcessClient(webView, null);
      }
      webView.setWebChromeClient(new WebChromeClient());
      webView.setWebViewClient(new WebViewClient() {
        @Override
        public void onPageFinished(WebView view, String url) {
          if (webView.inAppWebViewRenderProcessClient != null) {
            webView.inAppWebViewRenderProcessClient.dispose();
          }
          if (webView.inAppWebViewChromeClient != null) {
            webView.inAppWebViewChromeClient.dispose();
          }
          if (webView.inAppWebViewClient != null) {
            webView.inAppWebViewClient.dispose();
          }
          if (webView.javaScriptBridgeInterface != null) {
            webView.javaScriptBridgeInterface.dispose();
          }
          if (webView != null) {
            webView.dispose();
            webView.destroy();
            webView = null;
          }
          
          if (pullToRefreshLayout != null) {
            pullToRefreshLayout.dispose();
            pullToRefreshLayout = null;
          }
        }
      });
      WebSettings settings = webView.getSettings();
      settings.setJavaScriptEnabled(false);
      webView.loadUrl("about:blank");
    }
  }

  @Override
  public void onInputConnectionLocked() {
    if (webView != null && webView.inAppBrowserDelegate == null && !webView.customSettings.useHybridComposition)
      webView.lockInputConnection();
  }

  @Override
  public void onInputConnectionUnlocked() {
    if (webView != null && webView.inAppBrowserDelegate == null && !webView.customSettings.useHybridComposition)
      webView.unlockInputConnection();
  }

  @Override
  public void onFlutterViewAttached(@NonNull View flutterView) {
    if (webView != null && !webView.customSettings.useHybridComposition) {
      webView.setContainerView(flutterView);
    }
  }

  @Override
  public void onFlutterViewDetached() {
    if (webView != null && !webView.customSettings.useHybridComposition) {
      webView.setContainerView(null);
    }
  }
}