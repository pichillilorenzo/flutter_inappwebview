package com.pichillilorenzo.flutter_inappwebview_android_geckoview.webview.in_app_webview;

import android.content.Context;
import android.net.Uri;
import android.net.http.SslCertificate;
import android.os.Looper;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.webkit.ValueCallback;
import android.webkit.WebMessage;
import android.webkit.WebView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview_android_geckoview.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.Util;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.in_app_browser.InAppBrowserDelegate;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.print_job.PrintJobSettings;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.types.ContentWorld;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.types.HitTestResult;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.types.URLRequest;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.types.UserContentController;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.types.UserScript;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.webview.InAppWebViewManager;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.webview.WebViewChannelDelegate;

import org.mozilla.geckoview.GeckoSession;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

final public class InAppWebView extends InputAwareWebView {
  protected static final String LOG_TAG = "InAppWebView";
  public static final String METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_inappwebview_gecko_";

  @Nullable
  public InAppWebViewFlutterPlugin plugin;
  @Nullable
  public InAppBrowserDelegate inAppBrowserDelegate;
  public Object id;
  @Nullable
  public Integer windowId;
  @Nullable
  public WebViewChannelDelegate channelDelegate;
  public InAppWebViewSettings customSettings = new InAppWebViewSettings();
  @Nullable
  public Map<String, Object> contextMenu = null;

  public InAppWebView(Context context) {
    super(context);
  }

  public InAppWebView(Context context, AttributeSet attrs) {
    super(context, attrs);
  }

  public InAppWebView(Context context, @NonNull InAppWebViewFlutterPlugin plugin,
                      @NonNull Object id, @Nullable Integer windowId, InAppWebViewSettings customSettings,
                      @Nullable Map<String, Object> contextMenu, View containerView,
                      List<UserScript> userScripts) {
    super(context, containerView, customSettings.useHybridComposition);
    this.plugin = plugin;
    this.id = id;
    final MethodChannel channel = new MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME_PREFIX + id);
    this.channelDelegate = new WebViewChannelDelegate(this, channel);
    this.windowId = windowId;
    this.customSettings = customSettings;
    this.contextMenu = contextMenu;
    if (plugin != null && plugin.activity != null) {
      plugin.activity.registerForContextMenu(this);
    }
  }

  public void prepare() {
    if (InAppWebViewManager.geckoRuntime == null || plugin == null) {
      Log.d(LOG_TAG, "InAppWebViewManager.geckoRuntime is null or plugin is null");
      return;
    }

    GeckoSession session = new GeckoSession();

    session.setContentDelegate(new InAppWebViewContentDelegate(plugin, this));
    session.setNavigationDelegate(new InAppWebViewNavigationDelegate(plugin, this));
    session.setProgressDelegate(new InAppWebViewProgressDelegate(plugin, this));

    session.open(InAppWebViewManager.geckoRuntime);
    setSession(session);
  }

  @Nullable
  public String getUrl() {
    InAppWebViewProgressDelegate progressDelegate = getProgressDelegate();
    if (progressDelegate == null) {
      return null;
    }
    return progressDelegate.currentUrl;
  }

  @Nullable
  public String getTitle() {
    InAppWebViewContentDelegate contentDelegate = getContentDelegate();
    if (contentDelegate == null) {
      return null;
    }
    return contentDelegate.currentTitle;
  }

  public int getProgress() {
    return 0;
  }

  public void loadUrl(URLRequest urlRequest) {
    GeckoSession session = getSession();
    String url = urlRequest.getUrl();
    if (session == null || url == null) {
      return;
    }

    String method = urlRequest.getMethod();
    if (method != null && method.equals("POST")) {
      byte[] postData = urlRequest.getBody();
      postUrl(url, postData);
      return;
    }

    GeckoSession.Loader loader = new GeckoSession.Loader();
    loader.uri(url);
    Map<String, String> headers = urlRequest.getHeaders();
    if (headers != null) {
      loader.additionalHeaders(headers);
    }

    session.load(loader);
  }

  public void loadUrl(@NonNull String url) {
    GeckoSession session = getSession();
    if (session == null) {
      return;
    }

    GeckoSession.Loader loader = new GeckoSession.Loader().uri(url);
    session.load(loader);
  }

  public void postUrl(@NonNull String url, byte[] postData) {
    GeckoSession session = getSession();
    if (session == null) {
      return;
    }

    String data = new String(postData, StandardCharsets.UTF_8);
    String[] queryParameters = data.split("&");

    String source = "(function() { const postForm = document.createElement('FORM');" +
            "postForm.style = 'display: none;';" +
            "postForm.method = 'POST';" +
            "postForm.action = '" + url.replaceAll("'", "\\\\'") + "';";
    int count = 0;
    for (String queryParameter : queryParameters) {
      String[] queryParameterSplitted = queryParameter.split("=", 2);
      String name = queryParameterSplitted[0].replaceAll("'", "\\\\'");
      String value = queryParameterSplitted.length > 1 ? queryParameterSplitted[1].replaceAll("'", "\\\\'") : "";
      source += "const postFormInput" + count + " = document.createElement('INPUT');" +
              "postFormInput" + count + ".setAttribute('type', 'hidden');" +
              "postFormInput" + count + ".setAttribute('name', '" + name + "');" +
              "postFormInput" + count + ".setAttribute('value', '" + value + "');" +
              "postForm.appendChild(postFormInput" + count + ");";
      count++;
    }
    source += "document.body.appendChild(postForm);" +
            "postForm.submit();" +
            "document.body.removeChild(postForm);" +
            "})();";
    GeckoSession.Loader loader = new GeckoSession.Loader()
            .uri("javascript:" + source);
    session.load(loader);
  }

  public void loadDataWithBaseURL(String baseUrl, String data, String mimeType, String encoding, String historyUrl) {
    GeckoSession session = getSession();
    if (session == null) {
      return;
    }

    if (!baseUrl.isEmpty() && !baseUrl.equals("about:blank")) {
      data = data.replaceFirst("<head>", "<head><base href=\"" + baseUrl + "\">");
    }
    GeckoSession.Loader loader = new GeckoSession.Loader()
            .data(data, mimeType);
    session.load(loader);
  }

  public void loadFile(String assetFilePath) throws IOException {
    if (plugin == null) {
      return;
    }

    loadUrl(Util.getUrlAsset(plugin, assetFilePath));
  }

  public void evaluateJavascript(String source, ContentWorld contentWorld, ValueCallback<String> resultCallback) {

  }

  public void injectJavascriptFileFromUrl(String urlFile, Map<String, Object> scriptHtmlTagAttributes) {

  }

  public void injectCSSCode(String source) {

  }

  public void injectCSSFileFromUrl(String urlFile, Map<String, Object> cssLinkHtmlTagAttributes) {

  }

  public void reload() {
    GeckoSession session = getSession();
    if (session != null) {
      session.reload();
    }
  }

  public void goBack() {
    GeckoSession session = getSession();
    if (session != null) {
      session.goBack();
    }
  }

  public boolean canGoBack() {
    InAppWebViewNavigationDelegate navigationDelegate = getNavigationDelegate();
    if (navigationDelegate == null) {
      return false;
    }
    return navigationDelegate.canGoBack;
  }

  public void goForward() {
    GeckoSession session = getSession();
    if (session != null) {
      session.goForward();
    }
  }

  public boolean canGoForward() {
    InAppWebViewNavigationDelegate navigationDelegate = getNavigationDelegate();
    if (navigationDelegate == null) {
      return false;
    }
    return navigationDelegate.canGoForward;
  }

  public void goBackOrForward(int steps) {

  }

  public boolean canGoBackOrForward(int steps) {
    return false;
  }

  public void stopLoading() {

  }

  public boolean isLoading() {
    return false;
  }

  public void takeScreenshot(Map<String, Object> screenshotConfiguration, MethodChannel.Result result) {

  }

  public void setSettings(InAppWebViewSettings newCustomSettings, HashMap<String, Object> newSettingsMap) {

    customSettings = newCustomSettings;
  }

  public Map<String, Object> getCustomSettings() {
    return (customSettings != null) ? customSettings.getRealSettings(this) : null;
  }

  public HashMap<String, Object> getCopyBackForwardList() {
    return null;
  }

  public void clearAllCache() {

  }

  public void clearSslPreferences() {

  }

  public void findAllAsync(String find) {

  }

  public void findNext(boolean forward) {

  }

  public void clearMatches() {

  }

  public void scrollTo(Integer x, Integer y, Boolean animated) {

  }

  public void scrollBy(Integer x, Integer y, Boolean animated) {

  }

  public void onPause() {

  }

  public void onResume() {

  }

  public void pauseTimers() {

  }

  public void resumeTimers() {

  }

  @Nullable
  public String printCurrentPage(@Nullable PrintJobSettings settings) {
    return null;
  }

  public int getContentHeight() {
    return 0;
  }

  @Override
  protected void onWindowVisibilityChanged(int visibility) {
    if (customSettings.allowBackgroundAudioPlaying) {
      if (visibility != View.GONE) {
        super.onWindowVisibilityChanged(View.VISIBLE);
      }
      return;
    }
    super.onWindowVisibilityChanged(visibility);
  }

  @Nullable
  public Map<String, Object> getContextMenu() {
    return contextMenu;
  }

  public void setContextMenu(@Nullable Map<String, Object> contextMenu) {
    this.contextMenu = contextMenu;
  }

  @Nullable
  public InAppWebViewFlutterPlugin getPlugin() {
    return plugin;
  }

  public void setPlugin(@Nullable InAppWebViewFlutterPlugin plugin) {
    this.plugin = plugin;
  }

  @Nullable
  public InAppBrowserDelegate getInAppBrowserDelegate() {
    return inAppBrowserDelegate;
  }

  public void setInAppBrowserDelegate(@Nullable InAppBrowserDelegate inAppBrowserDelegate) {
    this.inAppBrowserDelegate = inAppBrowserDelegate;
  }

  public UserContentController getUserContentController() {
    return null;
  }

  public void setUserContentController(UserContentController userContentController) {

  }

  public Looper getWebViewLooper() {
    return null;
  }

  public boolean isInFullscreen() {
    return false;
  }

  public void setInFullscreen(boolean inFullscreen) {

  }

  public void getContentHeight(ValueCallback<Integer> callback) {
    callback.onReceiveValue(getContentHeight());
  }

  public void getContentWidth(ValueCallback<Integer> callback) {

  }

  public void zoomBy(float zoomFactor) {

  }

  public String getOriginalUrl() {
    InAppWebViewProgressDelegate progressDelegate = getProgressDelegate();
    if (progressDelegate == null) {
      return null;
    }
    return progressDelegate.currentOriginalUrl;
  }

  public void getSelectedText(ValueCallback<String> callback) {

  }

  public WebView.HitTestResult getHitTestResult() {
    return null;
  }

  public void getHitTestResult(ValueCallback<HitTestResult> callback) {

  }

  public boolean pageDown(boolean bottom) {
    return false;
  }

  public boolean pageUp(boolean top) {
    return false;
  }

  public void saveWebArchive(String basename, boolean autoname, ValueCallback<String> callback) {

  }

  public boolean zoomIn() {
    return false;
  }

  public boolean zoomOut() {
    return false;
  }

  public Map<String, Object> requestFocusNodeHref() {
    return null;
  }

  public Map<String, Object> requestImageRef() {
    return null;
  }

  public SslCertificate getCertificate() {
    InAppWebViewProgressDelegate progressDelegate = getProgressDelegate();
    if (progressDelegate == null) {
      return null;
    }
    return progressDelegate.certificate;
  }

  public void clearHistory() {

  }

  public void callAsyncJavaScript(String functionBody, Map<String, Object> arguments, ContentWorld contentWorld, ValueCallback<String> resultCallback) {

  }

  public boolean isSecureContext() {
    InAppWebViewProgressDelegate progressDelegate = getProgressDelegate();
    if (progressDelegate == null) {
      return false;
    }
    return progressDelegate.secureContext;
  }

  public void postWebMessage(WebMessage message, Uri targetOrigin) {

  }

  public boolean canScrollVertically() {
    return false;
  }

  public boolean canScrollHorizontally() {
    return false;
  }

  public float getZoomScale() {
    return 0;
  }

  public void getZoomScale(ValueCallback<Float> callback) {

  }

  @Nullable
  public WebViewChannelDelegate getChannelDelegate() {
    return channelDelegate;
  }

  public void setChannelDelegate(@Nullable WebViewChannelDelegate channelDelegate) {
    this.channelDelegate = channelDelegate;
  }

  @Nullable
  public InAppWebViewContentDelegate getContentDelegate() {
    GeckoSession session = getSession();
    if (session == null) {
      return null;
    }
    return (InAppWebViewContentDelegate) session.getContentDelegate();
  }

  @Nullable
  public InAppWebViewNavigationDelegate getNavigationDelegate() {
    GeckoSession session = getSession();
    if (session == null) {
      return null;
    }
    return (InAppWebViewNavigationDelegate) session.getNavigationDelegate();
  }

  @Nullable
  public InAppWebViewProgressDelegate getProgressDelegate() {
    GeckoSession session = getSession();
    if (session == null) {
      return null;
    }
    return (InAppWebViewProgressDelegate) session.getProgressDelegate();
  }

  @Override
  public void dispose() {
    if (channelDelegate != null) {
      channelDelegate.dispose();
      channelDelegate = null;
    }
    super.dispose();
    InAppWebViewContentDelegate contentDelegate = getContentDelegate();
    if (contentDelegate != null) {
      contentDelegate.dispose();
    }
    InAppWebViewNavigationDelegate navigationDelegate = getNavigationDelegate();
    if (navigationDelegate != null) {
      navigationDelegate.dispose();
    }
    InAppWebViewProgressDelegate progressDelegate = getProgressDelegate();
    if (progressDelegate != null) {
      progressDelegate.dispose();
    }
    GeckoSession session = getSession();
    if (session != null) {
      session.setContentDelegate(null);
      session.setNavigationDelegate(null);
      session.setProgressDelegate(null);
      session.close();
    }
    if (windowId != null && plugin != null && plugin.inAppWebViewManager != null) {
      plugin.inAppWebViewManager.windowWebViewMessages.remove(windowId);
    }
    removeAllViews();
    inAppBrowserDelegate = null;
    plugin = null;
  }
}
