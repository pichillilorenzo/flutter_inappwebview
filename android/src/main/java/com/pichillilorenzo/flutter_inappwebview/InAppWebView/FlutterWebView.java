package com.pichillilorenzo.flutter_inappwebview.InAppWebView;

import android.content.Context;
import android.hardware.display.DisplayManager;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.webkit.WebViewCompat;
import androidx.webkit.WebViewFeature;

import com.pichillilorenzo.flutter_inappwebview.Shared;
import com.pichillilorenzo.flutter_inappwebview.Util;

import java.io.IOException;
import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.FlutterView;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

import static io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import static io.flutter.plugin.common.MethodChannel.Result;

public class FlutterWebView implements PlatformView, MethodCallHandler  {

  static final String LOG_TAG = "IAWFlutterWebView";

  public InAppWebView webView;
  public final MethodChannel channel;

  public FlutterWebView(BinaryMessenger messenger, final Context context, Object id, HashMap<String, Object> params, View containerView) {
    channel = new MethodChannel(messenger, "com.pichillilorenzo/flutter_inappwebview_" + id);
    channel.setMethodCallHandler(this);

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

    InAppWebViewOptions options = new InAppWebViewOptions();
    options.parse(initialOptions);

    if (Shared.activity == null) {
      Log.e(LOG_TAG, "\n\n\nERROR: Shared.activity is null!!!\n\n" +
              "You need to upgrade your Flutter project to use the new Java Embedding API:\n\n" +
              "- Take a look at the \"IMPORTANT Note for Android\" section here: https://github.com/pichillilorenzo/flutter_inappwebview#important-note-for-android\n" +
              "- See the official wiki here: https://github.com/flutter/flutter/wiki/Upgrading-pre-1.12-Android-projects\n\n\n");
    }

    // MutableContextWrapper mMutableContext = new MutableContextWrapper(Shared.activity);
    // webView = new InAppWebView(mMutableContext, this, id, options, contextMenu, containerView);
    // displayListenerProxy.onPostWebViewInitialization(displayManager);
    // mMutableContext.setBaseContext(context);

    webView = new InAppWebView(Shared.activity, this, id, windowId, options, contextMenu, containerView);
    displayListenerProxy.onPostWebViewInitialization(displayManager);

    // fix https://github.com/pichillilorenzo/flutter_inappwebview/issues/182
    try {
      Class superClass =  webView.getClass().getSuperclass();
      while(!superClass.getName().equals("android.view.View")) {
        superClass = superClass.getSuperclass();
      }
      Field mContext = superClass.getDeclaredField("mContext");
      mContext.setAccessible(true);
      mContext.set(webView, context);
    } catch (Exception e) {
      e.printStackTrace();
      Log.e(LOG_TAG, "Cannot find mContext for this WebView");
    }

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
  public void onMethodCall(MethodCall call, final Result result) {
    switch (call.method) {
      case "getUrl":
        result.success((webView != null) ? webView.getUrl() : null);
        break;
      case "getTitle":
        result.success((webView != null) ? webView.getTitle() : null);
        break;
      case "getProgress":
        result.success((webView != null) ? webView.getProgress() : null);
        break;
      case "loadUrl":
        if (webView != null)
          webView.loadUrl((String) call.argument("url"), (Map<String, String>) call.argument("headers"), result);
        else
          result.success(false);
        break;
      case "postUrl":
        if (webView != null)
          webView.postUrl((String) call.argument("url"), (byte[]) call.argument("postData"), result);
        else
          result.success(false);
        break;
      case "loadData":
        {
          String data = (String) call.argument("data");
          String mimeType = (String) call.argument("mimeType");
          String encoding = (String) call.argument("encoding");
          String baseUrl = (String) call.argument("baseUrl");
          String historyUrl = (String) call.argument("historyUrl");

          if (webView != null)
            webView.loadData(data, mimeType, encoding, baseUrl, historyUrl, result);
          else
            result.success(false);
        }
        break;
      case "loadFile":
        if (webView != null)
          webView.loadFile((String) call.argument("url"), (Map<String, String>) call.argument("headers"), result);
        else
          result.success(false);
        break;
      case "evaluateJavascript":
        if (webView != null) {
          String source = (String) call.argument("source");
          webView.evaluateJavascript(source, result);
        }
        else {
          result.success("");
        }
        break;
      case "injectJavascriptFileFromUrl":
        if (webView != null) {
          String urlFile = (String) call.argument("urlFile");
          webView.injectJavascriptFileFromUrl(urlFile);
        }
        result.success(true);
        break;
      case "injectCSSCode":
        if (webView != null) {
          String source = (String) call.argument("source");
          webView.injectCSSCode(source);
        }
        result.success(true);
        break;
      case "injectCSSFileFromUrl":
        if (webView != null) {
          String urlFile = (String) call.argument("urlFile");
          webView.injectCSSFileFromUrl(urlFile);
        }
        result.success(true);
        break;
      case "reload":
        if (webView != null)
          webView.reload();
        result.success(true);
        break;
      case "goBack":
        if (webView != null)
          webView.goBack();
        result.success(true);
        break;
      case "canGoBack":
        result.success((webView != null) && webView.canGoBack());
        break;
      case "goForward":
        if (webView != null)
          webView.goForward();
        result.success(true);
        break;
      case "canGoForward":
        result.success((webView != null) && webView.canGoForward());
        break;
      case "goBackOrForward":
        if (webView != null)
          webView.goBackOrForward((Integer) call.argument("steps"));
        result.success(true);
        break;
      case "canGoBackOrForward":
        result.success((webView != null) && webView.canGoBackOrForward((Integer) call.argument("steps")));
        break;
      case "stopLoading":
        if (webView != null)
          webView.stopLoading();
        result.success(true);
        break;
      case "isLoading":
        result.success((webView != null) && webView.isLoading());
        break;
      case "takeScreenshot":
        if (webView != null)
          webView.takeScreenshot(result);
        else
          result.success(null);
        break;
      case "setOptions":
        if (webView != null) {
          InAppWebViewOptions inAppWebViewOptions = new InAppWebViewOptions();
          HashMap<String, Object> inAppWebViewOptionsMap = (HashMap<String, Object>) call.argument("options");
          inAppWebViewOptions.parse(inAppWebViewOptionsMap);
          webView.setOptions(inAppWebViewOptions, inAppWebViewOptionsMap);
        }
        result.success(true);
        break;
      case "getOptions":
        result.success((webView != null) ? webView.getOptions() : null);
        break;
      case "getCopyBackForwardList":
        result.success((webView != null) ? webView.getCopyBackForwardList() : null);
        break;
      case "startSafeBrowsing":
        if (webView != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1 &&
                WebViewFeature.isFeatureSupported(WebViewFeature.START_SAFE_BROWSING)) {
          WebViewCompat.startSafeBrowsing(webView.getContext(), new ValueCallback<Boolean>() {
            @Override
            public void onReceiveValue(Boolean success) {
              result.success(success);
            }
          });
        }
        else {
          result.success(false);
        }
        break;
      case "clearCache":
        if (webView != null)
          webView.clearAllCache();
        result.success(true);
        break;
      case "clearSslPreferences":
        if (webView != null)
          webView.clearSslPreferences();
        result.success(true);
        break;
      case "findAllAsync":
        if (webView != null) {
          String find = (String) call.argument("find");
          webView.findAllAsync(find);
        }
        result.success(true);
        break;
      case "findNext":
        if (webView != null) {
          Boolean forward = (Boolean) call.argument("forward");
          webView.findNext(forward);
          result.success(true);
        } else {
          result.success(false);
        }
        break;
      case "clearMatches":
        if (webView != null) {
          webView.clearMatches();
          result.success(true);
        } else {
          result.success(false);
        }
        break;
      case "scrollTo":
        if (webView != null) {
          Integer x = (Integer) call.argument("x");
          Integer y = (Integer) call.argument("y");
          Boolean animated = (Boolean) call.argument("animated");
          webView.scrollTo(x, y, animated);
        }
        result.success(true);
        break;
      case "scrollBy":
        if (webView != null) {
          Integer x = (Integer) call.argument("x");
          Integer y = (Integer) call.argument("y");
          Boolean animated = (Boolean) call.argument("animated");
          webView.scrollBy(x, y, animated);
        }
        result.success(true);
        break;
      case "pause":
        if (webView != null) {
          webView.onPause();
          result.success(true);
        } else {
          result.success(false);
        }
        break;
      case "resume":
        if (webView != null) {
          webView.onResume();
          result.success(true);
        } else {
          result.success(false);
        }
        break;
      case "pauseTimers":
        if (webView != null) {
          webView.pauseTimers();
          result.success(true);
        } else {
          result.success(false);
        }
        break;
      case "resumeTimers":
        if (webView != null) {
          webView.resumeTimers();
          result.success(true);
        } else {
          result.success(false);
        }
        break;
      case "printCurrentPage":
        if (webView != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          webView.printCurrentPage();
          result.success(true);
        } else {
          result.success(false);
        }
        break;
      case "getContentHeight":
        result.success((webView != null) ? webView.getContentHeight() : null);
        break;
      case "zoomBy":
        if (webView != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          double zoomFactor = (double) call.argument("zoomFactor");
          webView.zoomBy((float) zoomFactor);
          result.success(true);
        } else {
          result.success(false);
        }
        break;
      case "getOriginalUrl":
        result.success((webView != null) ? webView.getOriginalUrl() : null);
        break;
      case "getScale":
        result.success((webView != null) ? webView.getUpdatedScale() : null);
        break;
      case "getSelectedText":
        if (webView != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
          webView.getSelectedText(result);
        } else {
          result.success(null);
        }
        break;
      case "getHitTestResult":
        if (webView != null) {
          WebView.HitTestResult hitTestResult = webView.getHitTestResult();
          Map<String, Object> obj = new HashMap<>();
          obj.put("type", hitTestResult.getType());
          obj.put("extra", hitTestResult.getExtra());
          result.success(obj);
        } else {
          result.success(null);
        }
        break;
      case "pageDown":
        if (webView != null) {
          boolean bottom = (boolean) call.argument("bottom");
          result.success(webView.pageDown(bottom));
        } else {
          result.success(false);
        }
        break;
      case "pageUp":
        if (webView != null) {
          boolean top = (boolean) call.argument("top");
          result.success(webView.pageUp(top));
        } else {
          result.success(false);
        }
        break;
      case "saveWebArchive":
        if (webView != null) {
          String basename = (String) call.argument("basename");
          boolean autoname = (boolean) call.argument("autoname");
          webView.saveWebArchive(basename, autoname, new ValueCallback<String>() {
            @Override
            public void onReceiveValue(String value) {
              result.success(value);
            }
          });
        } else {
          result.success(null);
        }
        break;
      case "zoomIn":
        if (webView != null) {
          result.success(webView.zoomIn());
        } else {
          result.success(false);
        }
        break;
      case "zoomOut":
        if (webView != null) {
          result.success(webView.zoomOut());
        } else {
          result.success(false);
        }
        break;
      case "clearFocus":
        if (webView != null) {
          webView.clearFocus();
          result.success(true);
        } else {
          result.success(false);
        }
        break;
      case "setContextMenu":
        if (webView != null) {
          Map<String, Object> contextMenu = (Map<String, Object>) call.argument("contextMenu");
          webView.contextMenu = contextMenu;
          result.success(true);
        } else {
          result.success(false);
        }
        break;
      case "requestFocusNodeHref":
        if (webView != null) {
          result.success(webView.requestFocusNodeHref());
        } else {
          result.success(null);
        }
        break;
      case "requestImageRef":
        if (webView != null) {
          result.success(webView.requestImageRef());
        } else {
          result.success(null);
        }
        break;
      case "getScrollX":
        if (webView != null) {
          result.success(webView.getScrollX());
        } else {
          result.success(null);
        }
        break;
      case "getScrollY":
        if (webView != null) {
          result.success(webView.getScrollY());
        } else {
          result.success(null);
        }
        break;
      case "getCertificate":
        if (webView != null) {
          result.success(webView.getCertificateMap());
        } else {
          result.success(null);
        }
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void dispose() {
    channel.setMethodCallHandler(null);
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