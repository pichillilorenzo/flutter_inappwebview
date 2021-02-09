package com.pichillilorenzo.flutter_inappwebview;

import android.os.Build;
import android.webkit.ValueCallback;
import android.webkit.WebView;

import androidx.annotation.NonNull;
import androidx.webkit.WebViewCompat;
import androidx.webkit.WebViewFeature;

import com.pichillilorenzo.flutter_inappwebview.InAppBrowser.InAppBrowserOptions;
import com.pichillilorenzo.flutter_inappwebview.InAppWebView.InAppWebView;
import com.pichillilorenzo.flutter_inappwebview.InAppWebView.InAppWebViewOptions;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class InAppWebViewMethodHandler implements MethodChannel.MethodCallHandler {
  static final String LOG_TAG = "IAWMethodHandler";

  public InAppWebView webView;

  public InAppWebViewMethodHandler(InAppWebView webView) {
    this.webView = webView;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final MethodChannel.Result result) {
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
          String contentWorldName = (String) call.argument("contentWorld");
          webView.evaluateJavascript(source, contentWorldName, result);
        }
        else {
          result.success(null);
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
        if (webView != null) {
          Map<String, Object> screenshotConfiguration = (Map<String, Object>) call.argument("screenshotConfiguration");
          webView.takeScreenshot(screenshotConfiguration, result);
        }
        else
          result.success(null);
        break;
      case "setOptions":
        if (webView != null && webView.inAppBrowserActivity != null) {
          InAppBrowserOptions inAppBrowserOptions = new InAppBrowserOptions();
          HashMap<String, Object> inAppBrowserOptionsMap = (HashMap<String, Object>) call.argument("options");
          inAppBrowserOptions.parse(inAppBrowserOptionsMap);
          webView.inAppBrowserActivity.setOptions(inAppBrowserOptions, inAppBrowserOptionsMap);
        } else if (webView != null) {
          InAppWebViewOptions inAppWebViewOptions = new InAppWebViewOptions();
          HashMap<String, Object> inAppWebViewOptionsMap = (HashMap<String, Object>) call.argument("options");
          inAppWebViewOptions.parse(inAppWebViewOptionsMap);
          webView.setOptions(inAppWebViewOptions, inAppWebViewOptionsMap);
        }
        result.success(true);
        break;
      case "getOptions":
        if (webView != null && webView.inAppBrowserActivity != null) {
          result.success(webView.inAppBrowserActivity.getOptions());
        } else {
          result.success((webView != null) ? webView.getOptions() : null);
        }
        break;
      case "close":
        if (webView != null && webView.inAppBrowserActivity != null) {
          webView.inAppBrowserActivity.close(result);
        } else {
          result.notImplemented();
        }
        break;
      case "show":
        if (webView != null && webView.inAppBrowserActivity != null) {
          webView.inAppBrowserActivity.show();
          result.success(true);
        } else {
          result.notImplemented();
        }
        break;
      case "hide":
        if (webView != null && webView.inAppBrowserActivity != null) {
          webView.inAppBrowserActivity.hide();
          result.success(true);
        } else {
          result.notImplemented();
        }
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
        }
        result.success(true);
        break;
      case "clearMatches":
        if (webView != null) {
          webView.clearMatches();
        }
        result.success(true);
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
        }
        result.success(true);
        break;
      case "resume":
        if (webView != null) {
          webView.onResume();
        }
        result.success(true);
        break;
      case "pauseTimers":
        if (webView != null) {
          webView.pauseTimers();
        }
        result.success(true);
        break;
      case "resumeTimers":
        if (webView != null) {
          webView.resumeTimers();
        }
        result.success(true);
        break;
      case "printCurrentPage":
        if (webView != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          webView.printCurrentPage();
        }
        result.success(true);
        break;
      case "getContentHeight":
        result.success((webView != null) ? webView.getContentHeight() : null);
        break;
      case "zoomBy":
        if (webView != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          double zoomFactor = (double) call.argument("zoomFactor");
          webView.zoomBy((float) zoomFactor);
        }
        result.success(true);
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
          String filePath = (String) call.argument("filePath");
          boolean autoname = (boolean) call.argument("autoname");
          webView.saveWebArchive(filePath, autoname, new ValueCallback<String>() {
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
        }
        result.success(true);
        break;
      case "setContextMenu":
        if (webView != null) {
          Map<String, Object> contextMenu = (Map<String, Object>) call.argument("contextMenu");
          webView.contextMenu = contextMenu;
        }
        result.success(true);
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
      case "clearHistory":
        if (webView != null) {
          webView.clearHistory();
        }
        result.success(true);
        break;
      case "addUserScript":
        if (webView != null) {
          Map<String, Object> userScript = (Map<String, Object>) call.argument("userScript");
          result.success(webView.addUserScript(userScript));
        } else {
          result.success(false);
        }
        break;
      case "removeUserScript":
        if (webView != null) {
          Integer index = (Integer) call.argument("index");
          result.success(webView.removeUserScript(index));
        } else {
          result.success(false);
        }
        break;
      case "removeAllUserScripts":
        if (webView != null) {
          webView.removeAllUserScripts();
        }
        result.success(true);
        break;
      case "callAsyncJavaScript":
        if (webView != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          String functionBody = (String) call.argument("functionBody");
          Map<String, Object> functionArguments = (Map<String, Object>) call.argument("arguments");
          String contentWorldName = (String) call.argument("contentWorld");
          webView.callAsyncJavaScript(functionBody, functionArguments, contentWorldName, result);
        }
        else {
          result.success(null);
        }
        break;
      default:
        result.notImplemented();
    }
  }

  public void dispose() {
    webView = null;
  }
}
