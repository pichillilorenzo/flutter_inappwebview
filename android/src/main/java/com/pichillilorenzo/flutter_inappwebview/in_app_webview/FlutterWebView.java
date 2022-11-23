package com.pichillilorenzo.flutter_inappwebview.in_app_webview;

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
import androidx.webkit.WebViewCompat;
import androidx.webkit.WebViewFeature;

import com.pichillilorenzo.flutter_inappwebview.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview.InAppWebViewMethodHandler;
import com.pichillilorenzo.flutter_inappwebview.plugin_scripts_js.JavaScriptBridgeJS;
import com.pichillilorenzo.flutter_inappwebview.pull_to_refresh.PullToRefreshLayout;
import com.pichillilorenzo.flutter_inappwebview.pull_to_refresh.PullToRefreshOptions;
import com.pichillilorenzo.flutter_inappwebview.types.PlatformWebView;
import com.pichillilorenzo.flutter_inappwebview.types.URLRequest;
import com.pichillilorenzo.flutter_inappwebview.types.UserScript;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class FlutterWebView implements PlatformWebView {

  static final String LOG_TAG = "IAWFlutterWebView";

  public InAppWebView webView;
  public final MethodChannel channel;
  public InAppWebViewMethodHandler methodCallDelegate;
  public PullToRefreshLayout pullToRefreshLayout;

  public FlutterWebView(final InAppWebViewFlutterPlugin plugin, final Context context, Object id,
                        HashMap<String, Object> params) {
    channel = new MethodChannel(plugin.messenger, "com.pichillilorenzo/flutter_inappwebview_" + id);

    DisplayListenerProxy displayListenerProxy = new DisplayListenerProxy();
    DisplayManager displayManager = (DisplayManager) context.getSystemService(Context.DISPLAY_SERVICE);
    displayListenerProxy.onPreWebViewInitialization(displayManager);
    
    Map<String, Object> initialOptions = (Map<String, Object>) params.get("initialOptions");
    Map<String, Object> contextMenu = (Map<String, Object>) params.get("contextMenu");
    Integer windowId = (Integer) params.get("windowId");
    List<Map<String, Object>> initialUserScripts = (List<Map<String, Object>>) params.get("initialUserScripts");
    Map<String, Object> pullToRefreshInitialOptions = (Map<String, Object>) params.get("pullToRefreshOptions");

    InAppWebViewOptions options = new InAppWebViewOptions();
    options.parse(initialOptions);

    List<UserScript> userScripts = new ArrayList<>();
    if (initialUserScripts != null) {
      for (Map<String, Object> initialUserScript : initialUserScripts) {
        userScripts.add(UserScript.fromMap(initialUserScript));
      }
    }

    webView = new InAppWebView(context, plugin, channel, id, windowId, options, contextMenu, options.useHybridComposition ? null : plugin.flutterView, userScripts);
    displayListenerProxy.onPostWebViewInitialization(displayManager);

    // set MATCH_PARENT layout params to the WebView, otherwise it won't take all the available space!
    webView.setLayoutParams(new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
    MethodChannel pullToRefreshLayoutChannel = new MethodChannel(plugin.messenger, "com.pichillilorenzo/flutter_inappwebview_pull_to_refresh_" + id);
    PullToRefreshOptions pullToRefreshOptions = new PullToRefreshOptions();
    pullToRefreshOptions.parse(pullToRefreshInitialOptions);
    pullToRefreshLayout = new PullToRefreshLayout(context, pullToRefreshLayoutChannel, pullToRefreshOptions);
    pullToRefreshLayout.addView(webView);
    pullToRefreshLayout.prepare();

    methodCallDelegate = new InAppWebViewMethodHandler(webView);
    channel.setMethodCallHandler(methodCallDelegate);

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
        webView.loadUrl(urlRequest);
      }
    }
  }

  @Override
  public void dispose() {
    channel.setMethodCallHandler(null);
    if (methodCallDelegate != null) {
      methodCallDelegate.dispose();
      methodCallDelegate = null;
    }
    if (webView != null) {
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
          webView.inAppWebViewChromeClient.dispose();
          webView.inAppWebViewClient.dispose();
          webView.javaScriptBridgeInterface.dispose();
          webView.dispose();
          webView.destroy();
          webView = null;
          
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
    if (webView != null && webView.inAppBrowserDelegate == null && !webView.options.useHybridComposition)
      webView.lockInputConnection();
  }

  @Override
  public void onInputConnectionUnlocked() {
    if (webView != null && webView.inAppBrowserDelegate == null && !webView.options.useHybridComposition)
      webView.unlockInputConnection();
  }

  @Override
  public void onFlutterViewAttached(@NonNull View flutterView) {
    if (webView != null && !webView.options.useHybridComposition) {
      webView.setContainerView(flutterView);
    }
  }

  @Override
  public void onFlutterViewDetached() {
    if (webView != null && !webView.options.useHybridComposition) {
      webView.setContainerView(null);
    }
  }
}