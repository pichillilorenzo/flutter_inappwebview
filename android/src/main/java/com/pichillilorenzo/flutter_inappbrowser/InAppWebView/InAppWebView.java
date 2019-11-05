package com.pichillilorenzo.flutter_inappbrowser.InAppWebView;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.os.Build;
import android.util.AttributeSet;
import android.util.JsonReader;
import android.util.JsonToken;
import android.util.Log;
import android.view.View;
import android.webkit.CookieManager;
import android.webkit.DownloadListener;
import android.webkit.ValueCallback;
import android.webkit.WebBackForwardList;
import android.webkit.WebHistoryItem;
import android.webkit.WebSettings;

import com.pichillilorenzo.flutter_inappbrowser.ContentBlocker.ContentBlocker;
import com.pichillilorenzo.flutter_inappbrowser.ContentBlocker.ContentBlockerAction;
import com.pichillilorenzo.flutter_inappbrowser.ContentBlocker.ContentBlockerHandler;
import com.pichillilorenzo.flutter_inappbrowser.ContentBlocker.ContentBlockerTrigger;
import com.pichillilorenzo.flutter_inappbrowser.FlutterWebView;
import com.pichillilorenzo.flutter_inappbrowser.InAppBrowserActivity;
import com.pichillilorenzo.flutter_inappbrowser.InAppBrowserFlutterPlugin;
import com.pichillilorenzo.flutter_inappbrowser.JavaScriptBridgeInterface;
import com.pichillilorenzo.flutter_inappbrowser.Util;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import okhttp3.OkHttpClient;

import static com.pichillilorenzo.flutter_inappbrowser.InAppWebView.PreferredContentModeOptionType.*;

final public class InAppWebView extends InputAwareWebView {

  static final String LOG_TAG = "InAppWebView";

  public PluginRegistry.Registrar registrar;
  public InAppBrowserActivity inAppBrowserActivity;
  public FlutterWebView flutterWebView;
  public int id;
  public InAppWebViewClient inAppWebViewClient;
  public InAppWebChromeClient inAppWebChromeClient;
  public InAppWebViewOptions options;
  public boolean isLoading = false;
  public OkHttpClient httpClient;
  public float scale = getResources().getDisplayMetrics().density;
  int okHttpClientCacheSize = 10 * 1024 * 1024; // 10MB
  public ContentBlockerHandler contentBlockerHandler = new ContentBlockerHandler();

  static final String consoleLogJS = "(function(console) {" +
          "   var oldLogs = {" +
          "       'log': console.log," +
          "       'debug': console.debug," +
          "       'error': console.error," +
          "       'info': console.info," +
          "       'warn': console.warn" +
          "   };" +
          "   for (var k in oldLogs) {" +
          "       (function(oldLog) {" +
          "           console[oldLog] = function() {" +
          "               var message = '';" +
          "               for (var i in arguments) {" +
          "                   if (message == '') {" +
          "                       message += arguments[i];" +
          "                   }" +
          "                   else {" +
          "                       message += ' ' + arguments[i];" +
          "                   }" +
          "               }" +
          "               oldLogs[oldLog].call(console, message);" +
          "           }" +
          "       })(k);" +
          "   }" +
          "})(window.console);";

  static final String resourceObserverJS = "(function() {" +
          "   var observer = new PerformanceObserver(function(list) {" +
          "       list.getEntries().forEach(function(entry) {" +
          "         window." + JavaScriptBridgeInterface.name + ".callHandler('onLoadResource', entry);" +
          "       });" +
          "   });" +
          "   observer.observe({entryTypes: ['resource']});" +
          "})();";

  static final String platformReadyJS = "window.dispatchEvent(new Event('flutterInAppBrowserPlatformReady'));";

  static final String interceptAjaxRequestsJS = "(function(ajax) {" +
          "  var send = ajax.prototype.send;" +
          "  var open = ajax.prototype.open;" +
          "  var setRequestHeader = ajax.prototype.setRequestHeader;" +
          "  ajax.prototype._flutter_inappbrowser_url = null;" +
          "  ajax.prototype._flutter_inappbrowser_method = null;" +
          "  ajax.prototype._flutter_inappbrowser_isAsync = null;" +
          "  ajax.prototype._flutter_inappbrowser_user = null;" +
          "  ajax.prototype._flutter_inappbrowser_password = null;" +
          "  ajax.prototype._flutter_inappbrowser_password = null;" +
          "  ajax.prototype._flutter_inappbrowser_request_headers = {};" +
          "  ajax.prototype.open = function(method, url, isAsync, user, password) {" +
          "    isAsync = (isAsync != null) ? isAsync : true;" +
          "    this._flutter_inappbrowser_url = url;" +
          "    this._flutter_inappbrowser_method = method;" +
          "    this._flutter_inappbrowser_isAsync = isAsync;" +
          "    this._flutter_inappbrowser_user = user;" +
          "    this._flutter_inappbrowser_password = password;" +
          "    open.call(this, method, url, isAsync, user, password);" +
          "  };" +
          "  ajax.prototype.setRequestHeader = function(header, value) {" +
          "    this._flutter_inappbrowser_request_headers[header] = value;" +
          "    setRequestHeader.call(this, header, value);" +
          "  };" +
          "  function handleEvent(e) {" +
          "    var self = this;" +
          "    var headers = this.getAllResponseHeaders();" +
          "    var responseHeaders = {};" +
          "    if (headers != null) {" +
          "      var arr = headers.trim().split(/[\\r\\n]+/);" +
          "      arr.forEach(function (line) {" +
          "        var parts = line.split(': ');" +
          "        var header = parts.shift();" +
          "        var value = parts.join(': ');" +
          "        responseHeaders[header] = value;" +
          "      });" +
          "    }" +
          "    var ajaxRequest = {" +
          "      method: this._flutter_inappbrowser_method," +
          "      url: this._flutter_inappbrowser_url," +
          "      isAsync: this._flutter_inappbrowser_isAsync," +
          "      user: this._flutter_inappbrowser_user," +
          "      password: this._flutter_inappbrowser_password," +
          "      withCredentials: this.withCredentials," +
          "      headers: this._flutter_inappbrowser_request_headers," +
          "      readyState: this.readyState," +
          "      status: this.status," +
          "      responseURL: this.responseURL," +
          "      responseType: this.responseType," +
          "      responseText: this.responseText," +
          "      statusText: this.statusText," +
          "      responseHeaders, responseHeaders," +
          "      event: {" +
          "        type: e.type," +
          "        loaded: e.loaded," +
          "        lengthComputable: e.lengthComputable" +
          "      }" +
          "    };" +
          "    window." + JavaScriptBridgeInterface.name + ".callHandler('onAjaxProgress', ajaxRequest).then(function(result) {" +
          "      if (result != null) {" +
          "        switch (result) {" +
          "          case 0:" +
          "            self.abort();" +
          "            return;" +
          "        };" +
          "      }" +
          "    });" +
          "  };" +
          "  ajax.prototype.send = function(data) {" +
          "    var self = this;" +
          "    var onreadystatechange = this.onreadystatechange;" +
          "    this.onreadystatechange = function() {" +
          "      var headers = this.getAllResponseHeaders();" +
          "      var responseHeaders = {};" +
          "      if (headers != null) {" +
          "        var arr = headers.trim().split(/[\\r\\n]+/);" +
          "        arr.forEach(function (line) {" +
          "          var parts = line.split(': ');" +
          "          var header = parts.shift();" +
          "          var value = parts.join(': ');" +
          "          responseHeaders[header] = value;" +
          "        });" +
          "      }" +
          "      var ajaxRequest = {" +
          "        method: this._flutter_inappbrowser_method," +
          "        url: this._flutter_inappbrowser_url," +
          "        isAsync: this._flutter_inappbrowser_isAsync," +
          "        user: this._flutter_inappbrowser_user," +
          "        password: this._flutter_inappbrowser_password," +
          "        withCredentials: this.withCredentials," +
          "        headers: this._flutter_inappbrowser_request_headers," +
          "        readyState: this.readyState," +
          "        status: this.status," +
          "        responseURL: this.responseURL," +
          "        responseType: this.responseType," +
          "        responseText: this.responseText," +
          "        statusText: this.statusText," +
          "        responseHeaders: responseHeaders" +
          "      };" +
          "      window." + JavaScriptBridgeInterface.name + ".callHandler('onAjaxReadyStateChange', ajaxRequest).then(function(result) {" +
          "        if (result != null) {" +
          "          switch (result) {" +
          "            case 0:" +
          "              self.abort();" +
          "              return;" +
          "          };" +
          "        }" +
          "        if (onreadystatechange != null) {" +
          "          onreadystatechange();" +
          "        }" +
          "      });" +
          "    };" +
          "    this.addEventListener('loadstart', handleEvent);" +
          "    this.addEventListener('load', handleEvent);" +
          "    this.addEventListener('loadend', handleEvent);" +
          "    this.addEventListener('progress', handleEvent);" +
          "    this.addEventListener('error', handleEvent);" +
          "    this.addEventListener('abort', handleEvent);" +
          "    var ajaxRequest = {" +
          "      data: data," +
          "      method: this._flutter_inappbrowser_method," +
          "      url: this._flutter_inappbrowser_url," +
          "      isAsync: this._flutter_inappbrowser_isAsync," +
          "      user: this._flutter_inappbrowser_user," +
          "      password: this._flutter_inappbrowser_password," +
          "      withCredentials: this.withCredentials," +
          "      headers: this._flutter_inappbrowser_request_headers" +
          "    };" +
          "    window." + JavaScriptBridgeInterface.name + ".callHandler('shouldInterceptAjaxRequest', ajaxRequest).then(function(result) {" +
          "      if (result != null) {" +
          "        switch (result.action) {" +
          "          case 0:" +
          "            self.abort();" +
          "            return;" +
          "        };" +
          "        data = result.data;" +
          "        self.withCredentials = result.withCredentials;" +
          "        for (var header in result.headers) {" +
          "          var value = result.headers[header];" +
          "          self.setRequestHeader(header, value);" +
          "        };" +
          "        if ((self._flutter_inappbrowser_method != result.method && result.method != null) || (self._flutter_inappbrowser_url != result.url && result.url != null)) {" +
          "          self.abort();" +
          "          self.open(result.method, result.url, result.isAsync, result.user, result.password);" +
          "          return;" +
          "        }" +
          "      }" +
          "      send.call(self, data);" +
          "    });" +
          "  };" +
          "})(window.XMLHttpRequest);";

  static final String interceptFetchRequestsJS = "(function(fetch) {" +
          "  if (fetch == null) {" +
          "    return;" +
          "  }" +
          "  window.fetch = function(resource, init) {" +
          "    var fetchRequest = {" +
          "      url: null," +
          "      method: null," +
          "      headers: null," +
          "      body: null," +
          "      mode: null," +
          "      credentials: null," +
          "      cache: null," +
          "      redirect: null," +
          "      referrer: null," +
          "      referrerPolicy: null," +
          "      integrity: null," +
          "      keepalive: null" +
          "    };" +
          "    if (resource instanceof Request) {" +
          "      fetchRequest.url = resource.url;" +
          "      fetchRequest.method = resource.method;" +
          "      fetchRequest.headers = resource.headers;" +
          "      fetchRequest.body = resource.body;" +
          "      fetchRequest.mode = resource.mode;" +
          "      fetchRequest.credentials = resource.credentials;" +
          "      fetchRequest.cache = resource.cache;" +
          "      fetchRequest.redirect = resource.redirect;" +
          "      fetchRequest.referrer = resource.referrer;" +
          "      fetchRequest.referrerPolicy = resource.referrerPolicy;" +
          "      fetchRequest.integrity = resource.integrity;" +
          "      fetchRequest.keepalive = resource.keepalive;" +
          "    } else {" +
          "      fetchRequest.url = resource;" +
          "      if (init != null) {" +
          "        fetchRequest.method = init.method;" +
          "        fetchRequest.headers = init.headers;" +
          "        fetchRequest.body = init.body;" +
          "        fetchRequest.mode = init.mode;" +
          "        fetchRequest.credentials = init.credentials;" +
          "        fetchRequest.cache = init.cache;" +
          "        fetchRequest.redirect = init.redirect;" +
          "        fetchRequest.referrer = init.referrer;" +
          "        fetchRequest.referrerPolicy = init.referrerPolicy;" +
          "        fetchRequest.integrity = init.integrity;" +
          "        fetchRequest.keepalive = init.keepalive;" +
          "      }" +
          "    }" +
          "    return window." + JavaScriptBridgeInterface.name + ".callHandler('shouldInterceptFetchRequest', fetchRequest).then(function(result) {" +
          "      if (result != null) {" +
          "        switch (result.action) {" +
          "          case 0:" +
          "            var controller = new AbortController();" +
          "            if (init != null) {" +
          "              init.signal = controller.signal;" +
          "            } else {" +
          "              init = {" +
          "                signal: controller.signal" +
          "              };" +
          "            }" +
          "            controller.abort();" +
          "            break;" +
          "        }" +
          "      }" +
          "      return fetch(resource, init);" +
          "    });" +
          "  };" +
          "})(window.fetch);";


  public InAppWebView(Context context) {
    super(context);
  }

  public InAppWebView(Context context, AttributeSet attrs) {
    super(context, attrs);
  }

  public InAppWebView(Context context, AttributeSet attrs, int defaultStyle) {
    super(context, attrs, defaultStyle);
  }

  public InAppWebView(PluginRegistry.Registrar registrar, Object obj, int id, InAppWebViewOptions options, View containerView) {
    super(registrar.activeContext(), containerView);
    this.registrar = registrar;
    if (obj instanceof InAppBrowserActivity)
      this.inAppBrowserActivity = (InAppBrowserActivity) obj;
    else if (obj instanceof FlutterWebView)
      this.flutterWebView = (FlutterWebView) obj;
    this.id = id;
    this.options = options;
  }

  @Override
  public void reload() {
    super.reload();
  }

  public void prepare() {

    final Activity activity = (inAppBrowserActivity != null) ? inAppBrowserActivity : registrar.activity();

    boolean isFromInAppBrowserActivity = inAppBrowserActivity != null;

    //httpClient = new OkHttpClient().newBuilder().cache(new Cache(getContext().getCacheDir(), okHttpClientCacheSize)).build();
    httpClient = new OkHttpClient().newBuilder().build();

    addJavascriptInterface(new JavaScriptBridgeInterface((isFromInAppBrowserActivity) ? inAppBrowserActivity : flutterWebView), JavaScriptBridgeInterface.name);

    inAppWebChromeClient = new InAppWebChromeClient((isFromInAppBrowserActivity) ? inAppBrowserActivity : flutterWebView, this.registrar);
    setWebChromeClient(inAppWebChromeClient);

    inAppWebViewClient = new InAppWebViewClient((isFromInAppBrowserActivity) ? inAppBrowserActivity : flutterWebView);
    setWebViewClient(inAppWebViewClient);

    if (options.useOnDownloadStart)
      setDownloadListener(new DownloadStartListener());

    WebSettings settings = getSettings();

    settings.setJavaScriptEnabled(options.javaScriptEnabled);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      setWebContentsDebuggingEnabled(options.debuggingEnabled);
    }
    settings.setJavaScriptCanOpenWindowsAutomatically(options.javaScriptCanOpenWindowsAutomatically);
    settings.setBuiltInZoomControls(options.builtInZoomControls);
    settings.setDisplayZoomControls(options.displayZoomControls);
    settings.setSupportMultipleWindows(options.useOnTargetBlank);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
      settings.setSafeBrowsingEnabled(options.safeBrowsingEnabled);

    settings.setMediaPlaybackRequiresUserGesture(options.mediaPlaybackRequiresUserGesture);

    settings.setDatabaseEnabled(options.databaseEnabled);
    settings.setDomStorageEnabled(options.domStorageEnabled);

    if (!options.userAgent.isEmpty())
      settings.setUserAgentString(options.userAgent);

    if (options.clearCache)
      clearAllCache();
    else if (options.clearSessionCache)
      CookieManager.getInstance().removeSessionCookie();

    // Enable Thirdparty Cookies on >=Android 5.0 device
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
      CookieManager.getInstance().setAcceptThirdPartyCookies(this, true);

    settings.setLoadWithOverviewMode(true);
    settings.setUseWideViewPort(options.useWideViewPort);
    settings.setSupportZoom(options.supportZoom);
    settings.setTextZoom(options.textZoom);
    setVerticalScrollBarEnabled(options.verticalScrollBarEnabled);
    setHorizontalScrollBarEnabled(options.horizontalScrollBarEnabled);

    if (options.transparentBackground)
      setBackgroundColor(Color.TRANSPARENT);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && options.mixedContentMode != null)
      settings.setMixedContentMode(options.mixedContentMode);

    settings.setAllowContentAccess(options.allowContentAccess);
    settings.setAllowFileAccess(options.allowFileAccess);
    settings.setAllowFileAccessFromFileURLs(options.allowFileAccessFromFileURLs);
    settings.setAllowUniversalAccessFromFileURLs(options.allowUniversalAccessFromFileURLs);
    settings.setAppCacheEnabled(options.appCacheEnabled);
    if (options.appCachePath != null && !options.appCachePath.isEmpty() && options.appCacheEnabled)
      settings.setAppCachePath(options.appCachePath);
    settings.setBlockNetworkImage(options.blockNetworkImage);
    settings.setBlockNetworkLoads(options.blockNetworkLoads);
    if (options.cacheMode != null)
      settings.setCacheMode(options.cacheMode);
    settings.setCursiveFontFamily(options.cursiveFontFamily);
    settings.setDefaultFixedFontSize(options.defaultFixedFontSize);
    settings.setDefaultFontSize(options.defaultFontSize);
    settings.setDefaultTextEncodingName(options.defaultTextEncodingName);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && options.disabledActionModeMenuItems != null)
      settings.setDisabledActionModeMenuItems(options.disabledActionModeMenuItems);
    settings.setFantasyFontFamily(options.fantasyFontFamily);
    settings.setFixedFontFamily(options.fixedFontFamily);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && options.forceDark != null)
      settings.setForceDark(options.forceDark);
    settings.setGeolocationEnabled(options.geolocationEnabled);
    if (options.layoutAlgorithm != null)
      settings.setLayoutAlgorithm(options.layoutAlgorithm);
    settings.setLoadWithOverviewMode(options.loadWithOverviewMode);
    settings.setLoadsImagesAutomatically(options.loadsImagesAutomatically);
    settings.setMinimumFontSize(options.minimumFontSize);
    settings.setMinimumLogicalFontSize(options.minimumLogicalFontSize);
    settings.setNeedInitialFocus(options.needInitialFocus);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
      settings.setOffscreenPreRaster(options.offscreenPreRaster);
    settings.setSansSerifFontFamily(options.sansSerifFontFamily);
    settings.setSerifFontFamily(options.serifFontFamily);
    settings.setStandardFontFamily(options.standardFontFamily);
    if (options.preferredContentMode != null) {
      switch (fromValue(options.preferredContentMode)) {
        case DESKTOP:
          setDesktopMode(true);
          break;
        case MOBILE:
          setDesktopMode(false);
          break;
        case RECOMMENDED:
          break;
      }
    }

    contentBlockerHandler.getRuleList().clear();
    for (Map<String, Map<String, Object>> contentBlocker : options.contentBlockers) {
      // compile ContentBlockerTrigger urlFilter
      ContentBlockerTrigger trigger = ContentBlockerTrigger.fromMap(contentBlocker.get("trigger"));
      ContentBlockerAction action = ContentBlockerAction.fromMap(contentBlocker.get("action"));
      contentBlockerHandler.getRuleList().add(new ContentBlocker(trigger, action));
    }

    setFindListener(new FindListener() {
      @Override
      public void onFindResultReceived(int activeMatchOrdinal, int numberOfMatches, boolean isDoneCounting) {
        Map<String, Object> obj = new HashMap<>();
        if (inAppBrowserActivity != null)
          obj.put("uuid", inAppBrowserActivity.uuid);
        obj.put("activeMatchOrdinal", activeMatchOrdinal);
        obj.put("numberOfMatches", numberOfMatches);
        obj.put("isDoneCounting", isDoneCounting);
        getChannel().invokeMethod("onFindResultReceived", obj);
      }
    });
  }

  public void loadUrl(String url, MethodChannel.Result result) {
    if (!url.isEmpty()) {
      loadUrl(url);
    } else {
      result.error(LOG_TAG, "url is empty", null);
      return;
    }
    result.success(true);
  }

  public void loadUrl(String url, Map<String, String> headers, MethodChannel.Result result) {
    if (!url.isEmpty()) {
      loadUrl(url, headers);
    } else {
      result.error(LOG_TAG, "url is empty", null);
      return;
    }
    result.success(true);
  }

  public void postUrl(String url, byte[] postData, MethodChannel.Result result) {
    if (!url.isEmpty()) {
      postUrl(url, postData);
    } else {
      result.error(LOG_TAG, "url is empty", null);
      return;
    }
    result.success(true);
  }

  public void loadData(String data, String mimeType, String encoding, String baseUrl, MethodChannel.Result result) {
    loadDataWithBaseURL(baseUrl, data, mimeType, encoding, null);
    result.success(true);
  }

  public void loadFile(String url, MethodChannel.Result result) {
    try {
      url = Util.getUrlAsset(registrar, url);
    } catch (IOException e) {
      result.error(LOG_TAG, url + " asset file cannot be found!", e);
      return;
    }

    if (!url.isEmpty()) {
      loadUrl(url);
    } else {
      result.error(LOG_TAG, "url is empty", null);
      return;
    }
    result.success(true);
  }

  public void loadFile(String url, Map<String, String> headers, MethodChannel.Result result) {
    try {
      url = Util.getUrlAsset(registrar, url);
    } catch (IOException e) {
      result.error(LOG_TAG, url + " asset file cannot be found!", e);
      return;
    }

    if (!url.isEmpty()) {
      loadUrl(url, headers);
    } else {
      result.error(LOG_TAG, "url is empty", null);
      return;
    }
    result.success(true);
  }

  public boolean isLoading() {
    return isLoading;
  }

  private void clearCookies() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      CookieManager.getInstance().removeAllCookies(new ValueCallback<Boolean>() {
        @Override
        public void onReceiveValue(Boolean aBoolean) {

        }
      });
    } else {
      CookieManager.getInstance().removeAllCookie();
    }
  }

  public void clearAllCache() {
    clearCache(true);
    clearCookies();
    clearFormData();
  }

  public void takeScreenshot(final MethodChannel.Result result) {
    post(new Runnable() {
      @Override
      public void run() {
        int height = (int) (getContentHeight() * scale + 0.5);

        Bitmap b = Bitmap.createBitmap( getWidth(),
                height, Bitmap.Config.ARGB_8888);
        Canvas c = new Canvas(b);

        draw(c);
        int scrollOffset = (getScrollY() + getMeasuredHeight() > b.getHeight())
                ? b.getHeight() : getScrollY();
        Bitmap resized = Bitmap.createBitmap(
                b, 0, scrollOffset, b.getWidth(), getMeasuredHeight());

        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();

        resized.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
        try {
          byteArrayOutputStream.close();
        } catch (IOException e) {
          e.printStackTrace();
          Log.e(LOG_TAG, e.getMessage());
        }
        resized.recycle();
        result.success(byteArrayOutputStream.toByteArray());
      }
    });
  }

  public void setOptions(InAppWebViewOptions newOptions, HashMap<String, Object> newOptionsMap) {

    WebSettings settings = getSettings();

    if (newOptionsMap.get("javaScriptEnabled") != null && options.javaScriptEnabled != newOptions.javaScriptEnabled)
      settings.setJavaScriptEnabled(newOptions.javaScriptEnabled);

    if (newOptionsMap.get("debuggingEnabled") != null && options.debuggingEnabled != newOptions.debuggingEnabled && Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT)
      setWebContentsDebuggingEnabled(newOptions.debuggingEnabled);

    if (newOptionsMap.get("javaScriptCanOpenWindowsAutomatically") != null && options.javaScriptCanOpenWindowsAutomatically != newOptions.javaScriptCanOpenWindowsAutomatically)
      settings.setJavaScriptCanOpenWindowsAutomatically(newOptions.javaScriptCanOpenWindowsAutomatically);

    if (newOptionsMap.get("builtInZoomControls") != null && options.builtInZoomControls != newOptions.builtInZoomControls)
      settings.setBuiltInZoomControls(newOptions.builtInZoomControls);

    if (newOptionsMap.get("displayZoomControls") != null && options.displayZoomControls != newOptions.displayZoomControls)
      settings.setDisplayZoomControls(newOptions.displayZoomControls);

    if (newOptionsMap.get("safeBrowsingEnabled") != null && options.safeBrowsingEnabled != newOptions.safeBrowsingEnabled && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
      settings.setSafeBrowsingEnabled(newOptions.safeBrowsingEnabled);

    if (newOptionsMap.get("mediaPlaybackRequiresUserGesture") != null && options.mediaPlaybackRequiresUserGesture != newOptions.mediaPlaybackRequiresUserGesture)
      settings.setMediaPlaybackRequiresUserGesture(newOptions.mediaPlaybackRequiresUserGesture);

    if (newOptionsMap.get("databaseEnabled") != null && options.databaseEnabled != newOptions.databaseEnabled)
      settings.setDatabaseEnabled(newOptions.databaseEnabled);

    if (newOptionsMap.get("domStorageEnabled") != null && options.domStorageEnabled != newOptions.domStorageEnabled)
      settings.setDomStorageEnabled(newOptions.domStorageEnabled);

    if (newOptionsMap.get("userAgent") != null && !options.userAgent.equals(newOptions.userAgent) && !newOptions.userAgent.isEmpty())
      settings.setUserAgentString(newOptions.userAgent);

    if (newOptionsMap.get("clearCache") != null && newOptions.clearCache)
      clearAllCache();
    else if (newOptionsMap.get("clearSessionCache") != null && newOptions.clearSessionCache)
      CookieManager.getInstance().removeSessionCookie();

    if (newOptionsMap.get("useWideViewPort") != null && options.useWideViewPort != newOptions.useWideViewPort)
      settings.setUseWideViewPort(newOptions.useWideViewPort);

    if (newOptionsMap.get("supportZoom") != null && options.supportZoom != newOptions.supportZoom)
      settings.setSupportZoom(newOptions.supportZoom);

    if (newOptionsMap.get("textZoom") != null && !options.textZoom.equals(newOptions.textZoom))
      settings.setTextZoom(newOptions.textZoom);

    if (newOptionsMap.get("verticalScrollBarEnabled") != null && options.verticalScrollBarEnabled != newOptions.verticalScrollBarEnabled)
      setVerticalScrollBarEnabled(newOptions.verticalScrollBarEnabled);

    if (newOptionsMap.get("horizontalScrollBarEnabled") != null && options.horizontalScrollBarEnabled != newOptions.horizontalScrollBarEnabled)
      setHorizontalScrollBarEnabled(newOptions.horizontalScrollBarEnabled);

    if (newOptionsMap.get("transparentBackground") != null && options.transparentBackground != newOptions.transparentBackground) {
      if (newOptions.transparentBackground) {
        setBackgroundColor(Color.TRANSPARENT);
      } else {
        setBackgroundColor(Color.parseColor("#FFFFFF"));
      }
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
      if (newOptionsMap.get("mixedContentMode") != null && !options.mixedContentMode.equals(newOptions.mixedContentMode))
        settings.setMixedContentMode(newOptions.mixedContentMode);

    if (newOptionsMap.get("useOnTargetBlank") != null && options.useOnTargetBlank != newOptions.useOnTargetBlank)
      settings.setSupportMultipleWindows(newOptions.useOnTargetBlank);

    if (newOptionsMap.get("useOnDownloadStart") != null && options.useOnDownloadStart != newOptions.useOnDownloadStart) {
      if (newOptions.useOnDownloadStart) {
        setDownloadListener(new DownloadStartListener());
      } else {
        setDownloadListener(null);
      }
    }

    if (newOptionsMap.get("allowContentAccess") != null && options.allowContentAccess != newOptions.allowContentAccess)
      settings.setAllowContentAccess(newOptions.allowContentAccess);

    if (newOptionsMap.get("allowFileAccess") != null && options.allowFileAccess != newOptions.allowFileAccess)
      settings.setAllowFileAccess(newOptions.allowFileAccess);

    if (newOptionsMap.get("allowFileAccessFromFileURLs") != null && options.allowFileAccessFromFileURLs != newOptions.allowFileAccessFromFileURLs)
      settings.setAllowFileAccessFromFileURLs(newOptions.allowFileAccessFromFileURLs);

    if (newOptionsMap.get("allowUniversalAccessFromFileURLs") != null && options.allowUniversalAccessFromFileURLs != newOptions.allowUniversalAccessFromFileURLs)
      settings.setAllowUniversalAccessFromFileURLs(newOptions.allowUniversalAccessFromFileURLs);

    if (newOptionsMap.get("appCacheEnabled") != null && options.appCacheEnabled != newOptions.appCacheEnabled)
      settings.setAppCacheEnabled(newOptions.appCacheEnabled);

    if (newOptionsMap.get("appCachePath") != null && !options.appCachePath.equals(newOptions.appCachePath))
      if (newOptions.appCacheEnabled)
        settings.setAppCachePath(newOptions.appCachePath);

    if (newOptionsMap.get("blockNetworkImage") != null && options.blockNetworkImage != newOptions.blockNetworkImage)
      settings.setBlockNetworkImage(newOptions.blockNetworkImage);

    if (newOptionsMap.get("blockNetworkLoads") != null && options.blockNetworkLoads != newOptions.blockNetworkLoads)
      settings.setBlockNetworkLoads(newOptions.blockNetworkLoads);

    if (newOptionsMap.get("cacheMode") != null && !options.cacheMode.equals(newOptions.cacheMode))
      settings.setCacheMode(newOptions.cacheMode);

    if (newOptionsMap.get("cursiveFontFamily") != null && !options.cursiveFontFamily.equals(newOptions.cursiveFontFamily))
      settings.setCursiveFontFamily(newOptions.cursiveFontFamily);

    if (newOptionsMap.get("defaultFixedFontSize") != null && !options.defaultFixedFontSize.equals(newOptions.defaultFixedFontSize))
      settings.setDefaultFixedFontSize(newOptions.defaultFixedFontSize);

    if (newOptionsMap.get("defaultFontSize") != null && !options.defaultFontSize.equals(newOptions.defaultFontSize))
      settings.setDefaultFontSize(newOptions.defaultFontSize);

    if (newOptionsMap.get("defaultTextEncodingName") != null && !options.defaultTextEncodingName.equals(newOptions.defaultTextEncodingName))
      settings.setDefaultTextEncodingName(newOptions.defaultTextEncodingName);

    if (newOptionsMap.get("disabledActionModeMenuItems") != null && !options.disabledActionModeMenuItems.equals(newOptions.disabledActionModeMenuItems))
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N)
        settings.setDisabledActionModeMenuItems(newOptions.disabledActionModeMenuItems);

    if (newOptionsMap.get("fantasyFontFamily") != null && !options.fantasyFontFamily.equals(newOptions.fantasyFontFamily))
      settings.setFantasyFontFamily(newOptions.fantasyFontFamily);

    if (newOptionsMap.get("fixedFontFamily") != null && !options.fixedFontFamily.equals(newOptions.fixedFontFamily))
      settings.setFixedFontFamily(newOptions.fixedFontFamily);

    if (newOptionsMap.get("forceDark") != null && !options.forceDark.equals(newOptions.forceDark))
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
        settings.setForceDark(newOptions.forceDark);

    if (newOptionsMap.get("geolocationEnabled") != null && options.geolocationEnabled != newOptions.geolocationEnabled)
      settings.setGeolocationEnabled(newOptions.geolocationEnabled);

    if (newOptionsMap.get("layoutAlgorithm") != null && options.layoutAlgorithm != newOptions.layoutAlgorithm)
      settings.setLayoutAlgorithm(newOptions.layoutAlgorithm);

    if (newOptionsMap.get("loadWithOverviewMode") != null && options.loadWithOverviewMode != newOptions.loadWithOverviewMode)
      settings.setLoadWithOverviewMode(newOptions.loadWithOverviewMode);

    if (newOptionsMap.get("loadsImagesAutomatically") != null && options.loadsImagesAutomatically != newOptions.loadsImagesAutomatically)
      settings.setLoadsImagesAutomatically(newOptions.loadsImagesAutomatically);

    if (newOptionsMap.get("minimumFontSize") != null && !options.minimumFontSize.equals(newOptions.minimumFontSize))
      settings.setMinimumFontSize(newOptions.minimumFontSize);

    if (newOptionsMap.get("minimumLogicalFontSize") != null && !options.minimumLogicalFontSize.equals(newOptions.minimumLogicalFontSize))
      settings.setMinimumLogicalFontSize(newOptions.minimumLogicalFontSize);

    if (newOptionsMap.get("needInitialFocus") != null && options.needInitialFocus != newOptions.needInitialFocus)
      settings.setNeedInitialFocus(newOptions.needInitialFocus);

    if (newOptionsMap.get("offscreenPreRaster") != null && options.offscreenPreRaster != newOptions.offscreenPreRaster)
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
        settings.setOffscreenPreRaster(newOptions.offscreenPreRaster);

    if (newOptionsMap.get("sansSerifFontFamily") != null && !options.sansSerifFontFamily.equals(newOptions.sansSerifFontFamily))
      settings.setSansSerifFontFamily(newOptions.sansSerifFontFamily);

    if (newOptionsMap.get("serifFontFamily") != null && !options.serifFontFamily.equals(newOptions.serifFontFamily))
      settings.setSerifFontFamily(newOptions.serifFontFamily);

    if (newOptionsMap.get("standardFontFamily") != null && !options.standardFontFamily.equals(newOptions.standardFontFamily))
      settings.setStandardFontFamily(newOptions.standardFontFamily);

    if (newOptions.contentBlockers != null) {
      contentBlockerHandler.getRuleList().clear();
      for (Map<String, Map<String, Object>> contentBlocker : newOptions.contentBlockers) {
        // compile ContentBlockerTrigger urlFilter
        ContentBlockerTrigger trigger = ContentBlockerTrigger.fromMap(contentBlocker.get("trigger"));
        ContentBlockerAction action = ContentBlockerAction.fromMap(contentBlocker.get("action"));
        contentBlockerHandler.getRuleList().add(new ContentBlocker(trigger, action));
      }
    }

    options = newOptions;
  }

  public HashMap<String, Object> getOptions() {
    return (options != null) ? options.getHashMap() : null;
  }

  public void injectDeferredObject(String source, String jsWrapper, final MethodChannel.Result result) {
    String scriptToInject;
    if (jsWrapper != null) {
      org.json.JSONArray jsonEsc = new org.json.JSONArray();
      jsonEsc.put(source);
      String jsonRepr = jsonEsc.toString();
      String jsonSourceString = jsonRepr.substring(1, jsonRepr.length() - 1);
      scriptToInject = String.format(jsWrapper, jsonSourceString);
    } else {
      scriptToInject = source;
    }
    final String finalScriptToInject = scriptToInject;
    ( (inAppBrowserActivity != null) ? inAppBrowserActivity : flutterWebView.activity ).runOnUiThread(new Runnable() {
      @Override
      public void run() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
          // This action will have the side-effect of blurring the currently focused element
          loadUrl("javascript:" + finalScriptToInject);
        } else {
          evaluateJavascript(finalScriptToInject, new ValueCallback<String>() {
            @Override
            public void onReceiveValue(String s) {
              if (result == null)
                return;

              JsonReader reader = new JsonReader(new StringReader(s));

              // Must set lenient to parse single values
              reader.setLenient(true);

              try {
                String msg;
                if (reader.peek() == JsonToken.STRING) {
                  msg = reader.nextString();

                  JsonReader reader2 = new JsonReader(new StringReader(msg));
                  reader2.setLenient(true);

                  if (reader2.peek() == JsonToken.STRING)
                    msg = reader2.nextString();

                  result.success(msg);
                } else {
                  result.success("");
                }

              } catch (IOException e) {
                Log.e(LOG_TAG, "IOException", e);
              } finally {
                try {
                  reader.close();
                } catch (IOException e) {
                  // NOOP
                }
              }
            }
          });
        }
      }
    });
  }

  public void evaluateJavascript(String source, MethodChannel.Result result) {
    String jsWrapper = "(function(){return JSON.stringify(eval(%s));})();";
    injectDeferredObject(source, jsWrapper, result);
  }

  public void injectJavascriptFileFromUrl(String urlFile) {
    String jsWrapper = "(function(d) { var c = d.createElement('script'); c.src = %s; d.body.appendChild(c); })(document);";
    injectDeferredObject(urlFile, jsWrapper, null);
  }

  public void injectCSSCode(String source) {
    String jsWrapper = "(function(d) { var c = d.createElement('style'); c.innerHTML = %s; d.body.appendChild(c); })(document);";
    injectDeferredObject(source, jsWrapper, null);
  }

  public void injectCSSFileFromUrl(String urlFile) {
    String jsWrapper = "(function(d) { var c = d.createElement('link'); c.rel='stylesheet'; c.type='text/css'; c.href = %s; d.head.appendChild(c); })(document);";
    injectDeferredObject(urlFile, jsWrapper, null);
  }

  public HashMap<String, Object> getCopyBackForwardList() {
    WebBackForwardList currentList = copyBackForwardList();
    int currentSize = currentList.getSize();
    int currentIndex = currentList.getCurrentIndex();

    List<HashMap<String, String>> history = new ArrayList<HashMap<String, String>>();

    for(int i = 0; i < currentSize; i++) {
      WebHistoryItem historyItem = currentList.getItemAtIndex(i);
      HashMap<String, String> historyItemMap = new HashMap<>();

      historyItemMap.put("originalUrl", historyItem.getOriginalUrl());
      historyItemMap.put("title", historyItem.getTitle());
      historyItemMap.put("url", historyItem.getUrl());

      history.add(historyItemMap);
    }

    HashMap<String, Object> result = new HashMap<>();

    result.put("history", history);
    result.put("currentIndex", currentIndex);

    return result;
  }

  @Override
  protected void onScrollChanged (int l,
                                  int t,
                                  int oldl,
                                  int oldt) {
    super.onScrollChanged(l, t, oldl, oldt);

    int x = (int) (l/scale);
    int y = (int) (t/scale);

    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("x", x);
    obj.put("y", y);
    getChannel().invokeMethod("onScrollChanged", obj);
  }

  private MethodChannel getChannel() {
    return (inAppBrowserActivity != null) ? InAppBrowserFlutterPlugin.inAppBrowser.channel : flutterWebView.channel;
  }

  public void startSafeBrowsing(final MethodChannel.Result result) {
    Activity activity = (inAppBrowserActivity != null) ? inAppBrowserActivity : registrar.activity();
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
      startSafeBrowsing(activity.getApplicationContext(), new ValueCallback<Boolean>() {
        @Override
        public void onReceiveValue(Boolean value) {
          result.success(value);
        }
      });
    } else {
      result.success(false);
    }
  }

  public void setSafeBrowsingWhitelist(List<String> hosts, final MethodChannel.Result result) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
      setSafeBrowsingWhitelist(hosts, new ValueCallback<Boolean>() {
        @Override
        public void onReceiveValue(Boolean value) {
          result.success(value);
        }
      });
    } else {
      result.success(false);
    }
  }

  class DownloadStartListener implements DownloadListener {
    @Override
    public void onDownloadStart(String url, String userAgent, String contentDisposition, String mimetype, long contentLength) {
      Map<String, Object> obj = new HashMap<>();
      if (inAppBrowserActivity != null)
        obj.put("uuid", inAppBrowserActivity.uuid);
      obj.put("url", url);
      getChannel().invokeMethod("onDownloadStart", obj);
    }
  }

  public void setDesktopMode(final boolean enabled) {
    final WebSettings webSettings = getSettings();

    final String newUserAgent;
    if (enabled) {
      newUserAgent = webSettings.getUserAgentString().replace("Mobile", "eliboM").replace("Android", "diordnA");
    }
    else {
      newUserAgent = webSettings.getUserAgentString().replace("eliboM", "Mobile").replace("diordnA", "Android");
    }

    webSettings.setUserAgentString(newUserAgent);
    webSettings.setUseWideViewPort(enabled);
    webSettings.setLoadWithOverviewMode(enabled);
    webSettings.setSupportZoom(enabled);
    webSettings.setBuiltInZoomControls(enabled);
  }

  @Override
  public void dispose() {
    super.dispose();
  }

  @Override
  public void destroy() {
    super.destroy();
  }
}
