package com.pichillilorenzo.flutter_inappbrowser;

import android.app.Activity;
import android.content.Context;
import android.hardware.display.DisplayManager;
import android.os.Build;
import android.util.Log;
import android.view.View;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.pichillilorenzo.flutter_inappbrowser.InAppWebView.DisplayListenerProxy;
import com.pichillilorenzo.flutter_inappbrowser.InAppWebView.InAppWebView;
import com.pichillilorenzo.flutter_inappbrowser.InAppWebView.InAppWebViewOptions;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.platform.PlatformView;

import static io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import static io.flutter.plugin.common.MethodChannel.Result;

public class FlutterWebView implements PlatformView, MethodCallHandler  {

  static final String LOG_TAG = "FlutterWebView";

  public final Activity activity;
  public InAppWebView webView;
  public final MethodChannel channel;
  public final Registrar registrar;

  public FlutterWebView(Registrar registrar, final Context context, int id, HashMap<String, Object> params, View containerView) {
    this.registrar = registrar;
    this.activity = registrar.activity();

    DisplayListenerProxy displayListenerProxy = new DisplayListenerProxy();
    DisplayManager displayManager = (DisplayManager) context.getSystemService(Context.DISPLAY_SERVICE);
    displayListenerProxy.onPreWebViewInitialization(displayManager);

    String initialUrl = (String) params.get("initialUrl");
    String initialFile = (String) params.get("initialFile");
    Map<String, String> initialData = (Map<String, String>) params.get("initialData");
    Map<String, String> initialHeaders = (Map<String, String>) params.get("initialHeaders");
    HashMap<String, Object> initialOptions = (HashMap<String, Object>) params.get("initialOptions");

    InAppWebViewOptions options = new InAppWebViewOptions();
    options.parse(initialOptions);

    webView = new InAppWebView(registrar, context, this, id, options, containerView);
    displayListenerProxy.onPostWebViewInitialization(displayManager);

    webView.prepare();

    channel = new MethodChannel(registrar.messenger(), "com.pichillilorenzo/flutter_inappwebview_" + id);
    channel.setMethodCallHandler(this);

    if (initialFile != null) {
      try {
        initialUrl = Util.getUrlAsset(registrar, initialFile);
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
      webView.loadDataWithBaseURL(baseUrl, data, mimeType, encoding, null);
    }
    else
      webView.loadUrl(initialUrl, initialHeaders);
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

          if (webView != null)
            webView.loadData(data, mimeType, encoding, baseUrl, result);
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
        if (webView != null)
          webView.startSafeBrowsing(result);
        else
          result.success(false);
        break;
      case "setSafeBrowsingWhitelist":
        if (webView != null) {
          List<String> hosts = (List<String>) call.argument("hosts");
          webView.setSafeBrowsingWhitelist(hosts, result);
        }
        else
          result.success(false);
        break;
      case "getSafeBrowsingPrivacyPolicyUrl":
        if (webView != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
          result.success(webView.getSafeBrowsingPrivacyPolicyUrl().toString());
        } else
          result.success(null);
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
      case "clearClientCertPreferences":
        if (webView != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          webView.clearClientCertPreferences(new Runnable() {
            @Override
            public void run() {
              result.success(true);
            }
          });
        } else {
          result.success(false);
        }
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
          webView.scrollTo(x, y);
        }
        result.success(true);
        break;
      case "scrollBy":
        if (webView != null) {
          Integer x = (Integer) call.argument("x");
          Integer y = (Integer) call.argument("y");
          webView.scrollBy(x, y);
        }
        result.success(true);
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void dispose() {
    channel.setMethodCallHandler(null);
    if (webView != null) {
      webView.setWebChromeClient(new WebChromeClient());
      webView.setWebViewClient(new WebViewClient() {
        public void onPageFinished(WebView view, String url) {
          webView.dispose();
          webView.destroy();
          webView = null;
        }
      });
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

  public void onFlutterViewAttached(View flutterView) {
    webView.setContainerView(flutterView);
  }

  public void onFlutterViewDetached() {
    webView.setContainerView(null);
  }

}