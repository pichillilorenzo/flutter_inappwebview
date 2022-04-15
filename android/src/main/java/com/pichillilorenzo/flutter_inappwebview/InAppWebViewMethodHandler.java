package com.pichillilorenzo.flutter_inappwebview;

import android.net.Uri;
import android.os.Build;
import android.webkit.ValueCallback;
import android.webkit.WebView;

import androidx.annotation.NonNull;
import androidx.webkit.WebMessageCompat;
import androidx.webkit.WebMessagePortCompat;
import androidx.webkit.WebViewCompat;
import androidx.webkit.WebViewFeature;

import com.pichillilorenzo.flutter_inappwebview.in_app_browser.InAppBrowserActivity;
import com.pichillilorenzo.flutter_inappwebview.in_app_browser.InAppBrowserOptions;
import com.pichillilorenzo.flutter_inappwebview.in_app_webview.InAppWebView;
import com.pichillilorenzo.flutter_inappwebview.in_app_webview.InAppWebViewOptions;
import com.pichillilorenzo.flutter_inappwebview.types.ContentWorld;
import com.pichillilorenzo.flutter_inappwebview.types.HitTestResult;
import com.pichillilorenzo.flutter_inappwebview.types.InAppWebViewInterface;
import com.pichillilorenzo.flutter_inappwebview.types.SslCertificateExt;
import com.pichillilorenzo.flutter_inappwebview.types.URLRequest;
import com.pichillilorenzo.flutter_inappwebview.types.UserScript;
import com.pichillilorenzo.flutter_inappwebview.types.WebMessage;
import com.pichillilorenzo.flutter_inappwebview.types.WebMessageChannel;
import com.pichillilorenzo.flutter_inappwebview.types.WebMessageListener;
import com.pichillilorenzo.flutter_inappwebview.types.WebMessagePort;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class InAppWebViewMethodHandler implements MethodChannel.MethodCallHandler {
  static final String LOG_TAG = "IAWMethodHandler";

  public InAppWebViewInterface webView;

  public InAppWebViewMethodHandler(InAppWebViewInterface webView) {
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
        if (webView != null) {
          Map<String, Object> urlRequest = (Map<String, Object>) call.argument("urlRequest");
          webView.loadUrl(URLRequest.fromMap(urlRequest));
        }
        result.success(true);
        break;
      case "postUrl":
        if (webView != null) {
          String url = (String) call.argument("url");
          byte[] postData = (byte[]) call.argument("postData");
          webView.postUrl(url, postData);
        }
        result.success(true);
        break;
      case "loadData":
        if (webView != null) {
          String data = (String) call.argument("data");
          String mimeType = (String) call.argument("mimeType");
          String encoding = (String) call.argument("encoding");
          String baseUrl = (String) call.argument("baseUrl");
          String historyUrl = (String) call.argument("historyUrl");
          webView.loadDataWithBaseURL(baseUrl, data, mimeType, encoding, historyUrl);
        }
        result.success(true);
      break;
      case "loadFile":
        if (webView != null) {
          String assetFilePath = (String) call.argument("assetFilePath");
          try {
            webView.loadFile(assetFilePath);
          } catch (IOException e) {
            e.printStackTrace();
            result.error(LOG_TAG, e.getMessage(), null);
            return;
          }
        }
        result.success(true);
        break;
      case "evaluateJavascript":
        if (webView != null) {
          String source = (String) call.argument("source");
          Map<String, Object> contentWorldMap = (Map<String, Object>) call.argument("contentWorld");
          ContentWorld contentWorld = ContentWorld.fromMap(contentWorldMap);
          webView.evaluateJavascript(source, contentWorld, new ValueCallback<String>() {
            @Override
            public void onReceiveValue(String value) {
              result.success(value);
            }
          });
        }
        else {
          result.success(null);
        }
        break;
      case "injectJavascriptFileFromUrl":
        if (webView != null) {
          String urlFile = (String) call.argument("urlFile");
          Map<String, Object> scriptHtmlTagAttributes = (Map<String, Object>) call.argument("scriptHtmlTagAttributes");
          webView.injectJavascriptFileFromUrl(urlFile, scriptHtmlTagAttributes);
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
          Map<String, Object> cssLinkHtmlTagAttributes = (Map<String, Object>) call.argument("cssLinkHtmlTagAttributes");
          webView.injectCSSFileFromUrl(urlFile, cssLinkHtmlTagAttributes);
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
        if (webView != null && webView.getInAppBrowserDelegate() != null && webView.getInAppBrowserDelegate() instanceof InAppBrowserActivity) {
          InAppBrowserActivity inAppBrowserActivity = (InAppBrowserActivity) webView.getInAppBrowserDelegate();
          InAppBrowserOptions inAppBrowserOptions = new InAppBrowserOptions();
          HashMap<String, Object> inAppBrowserOptionsMap = (HashMap<String, Object>) call.argument("options");
          inAppBrowserOptions.parse(inAppBrowserOptionsMap);
          inAppBrowserActivity.setOptions(inAppBrowserOptions, inAppBrowserOptionsMap);
        } else if (webView != null) {
          InAppWebViewOptions inAppWebViewOptions = new InAppWebViewOptions();
          HashMap<String, Object> inAppWebViewOptionsMap = (HashMap<String, Object>) call.argument("options");
          inAppWebViewOptions.parse(inAppWebViewOptionsMap);
          webView.setOptions(inAppWebViewOptions, inAppWebViewOptionsMap);
        }
        result.success(true);
        break;
      case "getOptions":
        if (webView != null && webView.getInAppBrowserDelegate() != null && webView.getInAppBrowserDelegate() instanceof InAppBrowserActivity) {
          InAppBrowserActivity inAppBrowserActivity = (InAppBrowserActivity) webView.getInAppBrowserDelegate();
          result.success(inAppBrowserActivity.getOptions());
        } else {
          result.success((webView != null) ? webView.getOptions() : null);
        }
        break;
      case "close":
        if (webView != null && webView.getInAppBrowserDelegate() != null && webView.getInAppBrowserDelegate() instanceof InAppBrowserActivity) {
          InAppBrowserActivity inAppBrowserActivity = (InAppBrowserActivity) webView.getInAppBrowserDelegate();
          inAppBrowserActivity.close(result);
        } else {
          result.notImplemented();
        }
        break;
      case "show":
        if (webView != null && webView.getInAppBrowserDelegate() != null && webView.getInAppBrowserDelegate() instanceof InAppBrowserActivity) {
          InAppBrowserActivity inAppBrowserActivity = (InAppBrowserActivity) webView.getInAppBrowserDelegate();
          inAppBrowserActivity.show();
          result.success(true);
        } else {
          result.notImplemented();
        }
        break;
      case "hide":
        if (webView != null && webView.getInAppBrowserDelegate() != null && webView.getInAppBrowserDelegate() instanceof InAppBrowserActivity) {
          InAppBrowserActivity inAppBrowserActivity = (InAppBrowserActivity) webView.getInAppBrowserDelegate();
          inAppBrowserActivity.hide();
          result.success(true);
        } else {
          result.notImplemented();
        }
        break;
      case "getCopyBackForwardList":
        result.success((webView != null) ? webView.getCopyBackForwardList() : null);
        break;
      case "startSafeBrowsing":
        if (webView != null && WebViewFeature.isFeatureSupported(WebViewFeature.START_SAFE_BROWSING)) {
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
        if (webView instanceof InAppWebView) {
          result.success(webView.getContentHeight());
        } else {
          result.success(null);
        }
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
      case "getZoomScale":
        if (webView instanceof InAppWebView) {
          result.success(webView.getZoomScale());
        } else {
          result.success(null);
        }
        break;
      case "getSelectedText":
        if ((webView instanceof InAppWebView && Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT)) {
          webView.getSelectedText(new ValueCallback<String>() {
            @Override
            public void onReceiveValue(String value) {
              result.success(value);
            }
          });
        } else {
          result.success(null);
        }
        break;
      case "getHitTestResult":
        if (webView instanceof InAppWebView) {
          result.success(HitTestResult.fromWebViewHitTestResult(webView.getHitTestResult()).toMap());
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
          webView.setContextMenu(contextMenu);
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
          result.success(SslCertificateExt.toMap(webView.getCertificate()));
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
        if (webView != null && webView.getUserContentController() != null) {
          Map<String, Object> userScriptMap = (Map<String, Object>) call.argument("userScript");
          UserScript userScript = UserScript.fromMap(userScriptMap);
          result.success(webView.getUserContentController().addUserOnlyScript(userScript));
        } else {
          result.success(false);
        }
        break;
      case "removeUserScript":
        if (webView != null && webView.getUserContentController() != null) {
          Integer index = (Integer) call.argument("index");
          Map<String, Object> userScriptMap = (Map<String, Object>) call.argument("userScript");
          UserScript userScript = UserScript.fromMap(userScriptMap);
          result.success(webView.getUserContentController().removeUserOnlyScriptAt(index, userScript.getInjectionTime()));
        } else {
          result.success(false);
        }
        break;
      case "removeUserScriptsByGroupName":
        if (webView != null && webView.getUserContentController() != null) {
          String groupName = (String) call.argument("groupName");
          webView.getUserContentController().removeUserOnlyScriptsByGroupName(groupName);
        }
        result.success(true);
        break;
      case "removeAllUserScripts":
        if (webView != null && webView.getUserContentController() != null) {
          webView.getUserContentController().removeAllUserOnlyScripts();
        }
        result.success(true);
        break;
      case "callAsyncJavaScript":
        if (webView != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          String functionBody = (String) call.argument("functionBody");
          Map<String, Object> functionArguments = (Map<String, Object>) call.argument("arguments");
          Map<String, Object> contentWorldMap = (Map<String, Object>) call.argument("contentWorld");
          ContentWorld contentWorld = ContentWorld.fromMap(contentWorldMap);
          webView.callAsyncJavaScript(functionBody, functionArguments, contentWorld, new ValueCallback<String>() {
            @Override
            public void onReceiveValue(String value) {
              result.success(value);
            }
          });
        }
        else {
          result.success(null);
        }
        break;
      case "isSecureContext":
        if (webView != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          webView.isSecureContext(new ValueCallback<Boolean>() {
            @Override
            public void onReceiveValue(Boolean value) {
              result.success(value);
            }
          });
        } else {
          result.success(false);
        }
        break;
      case "createWebMessageChannel":
        if (webView != null) {
          if (webView instanceof InAppWebView && WebViewFeature.isFeatureSupported(WebViewFeature.CREATE_WEB_MESSAGE_CHANNEL)) {
            result.success(webView.createCompatWebMessageChannel().toMap());
          } else {
            result.success(null);
          }
        } else {
          result.success(null);
        }
        break;
      case "postWebMessage":
        if (webView != null && WebViewFeature.isFeatureSupported(WebViewFeature.POST_WEB_MESSAGE)) {
          Map<String, Object> message = (Map<String, Object>) call.argument("message");
          String targetOrigin = (String) call.argument("targetOrigin");
          List<WebMessagePortCompat> compatPorts = new ArrayList<>();
          List<WebMessagePort> ports = new ArrayList<>();
          List<Map<String, Object>> portsMap = (List<Map<String, Object>>) message.get("ports");
          if (portsMap != null) {
            for (Map<String, Object> portMap : portsMap) {
              String webMessageChannelId = (String) portMap.get("webMessageChannelId");
              Integer index = (Integer) portMap.get("index");
              WebMessageChannel webMessageChannel = webView.getWebMessageChannels().get(webMessageChannelId);
              if (webMessageChannel != null) {
                if (webView instanceof InAppWebView) {
                  compatPorts.add(webMessageChannel.compatPorts.get(index));
                }
              }
            }
          }
          if (webView instanceof InAppWebView) {
            WebMessageCompat webMessage = new WebMessageCompat((String) message.get("data"), compatPorts.toArray(new WebMessagePortCompat[0]));
            try {
              WebViewCompat.postWebMessage((WebView) webView, webMessage, Uri.parse(targetOrigin));
              result.success(true);
            } catch (Exception e) {
              result.error(LOG_TAG, e.getMessage(), null);
            }
          }
        } else {
          result.success(true);
        }
        break;
      case "addWebMessageListener":
        if (webView != null) {
          Map<String, Object> webMessageListenerMap = (Map<String, Object>) call.argument("webMessageListener");
          WebMessageListener webMessageListener = WebMessageListener.fromMap(webView, webView.getPlugin().messenger, webMessageListenerMap);
          if (webView instanceof InAppWebView && WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_LISTENER)) {
            try {
              webView.addWebMessageListener(webMessageListener);
              result.success(true);
            } catch (Exception e) {
              result.error(LOG_TAG, e.getMessage(), null);
            }
          } else {
            result.success(true);
          }
        } else {
          result.success(true);
        }
        break;
      case "canScrollVertically":
        if (webView != null) {
          result.success(webView.canScrollVertically());
        } else {
          result.success(false);
        }
        break;
      case "canScrollHorizontally":
        if (webView != null) {
          result.success(webView.canScrollHorizontally());
        } else {
          result.success(false);
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
