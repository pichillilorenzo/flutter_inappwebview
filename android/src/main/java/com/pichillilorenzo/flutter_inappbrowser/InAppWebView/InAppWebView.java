package com.pichillilorenzo.flutter_inappbrowser.InAppWebView;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Picture;
import android.os.Build;
import android.util.AttributeSet;
import android.util.JsonReader;
import android.util.JsonToken;
import android.util.Log;
import android.webkit.CookieManager;
import android.webkit.ValueCallback;
import android.webkit.WebBackForwardList;
import android.webkit.WebHistoryItem;
import android.webkit.WebSettings;
import android.webkit.WebView;

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
import okhttp3.Cache;
import okhttp3.OkHttpClient;

public class InAppWebView extends WebView {

  static final String LOG_TAG = "InAppWebView";

  public PluginRegistry.Registrar registrar;
  public InAppBrowserActivity inAppBrowserActivity;
  public FlutterWebView flutterWebView;
  int id;
  InAppWebViewClient inAppWebViewClient;
  InAppWebChromeClient inAppWebChromeClient;
  public InAppWebViewOptions options;
  public boolean isLoading = false;
  OkHttpClient httpClient;
  int okHttpClientCacheSize = 10 * 1024 * 1024; // 10MB

  static final String consoleLogJS = "(function() {" +
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
          "})();";

  static final String platformReadyJS = "window.dispatchEvent(new Event('flutterInAppBrowserPlatformReady'));";

  public InAppWebView(Context context) {
    super(context);
  }

  public InAppWebView(Context context, AttributeSet attrs) {
    super(context, attrs);
  }

  public InAppWebView(Context context, AttributeSet attrs, int defaultStyle) {
    super(context, attrs, defaultStyle);
  }

  public InAppWebView(PluginRegistry.Registrar registrar, Object obj, int id, InAppWebViewOptions options) {
    super(registrar.activeContext());
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
    Log.d(LOG_TAG, "RELOAD");
  }

  public void prepare() {

    boolean isFromInAppBrowserActivity = inAppBrowserActivity != null;

    httpClient = new OkHttpClient().newBuilder().cache(new Cache(getContext().getCacheDir(), okHttpClientCacheSize)).build();

    addJavascriptInterface(new JavaScriptBridgeInterface((isFromInAppBrowserActivity) ? inAppBrowserActivity : flutterWebView), JavaScriptBridgeInterface.name);

    inAppWebChromeClient = new InAppWebChromeClient((isFromInAppBrowserActivity) ? inAppBrowserActivity : flutterWebView, this.registrar);
    setWebChromeClient(inAppWebChromeClient);

    inAppWebViewClient = new InAppWebViewClient((isFromInAppBrowserActivity) ? inAppBrowserActivity : flutterWebView);
    setWebViewClient(inAppWebViewClient);

//        final Activity activity = this;
//
//        webView.setDownloadListener(new DownloadListener() {
//            @Override
//            public void onDownloadStart(final String url, final String userAgent,
//                                        final String contentDisposition, final String mimetype,
//                                        final long contentLength) {
//
//                RequestPermissionHandler.checkAndRun(activity, Manifest.permission.WRITE_EXTERNAL_STORAGE, RequestPermissionHandler.REQUEST_CODE_WRITE_EXTERNAL_STORAGE, new Runnable(){
//                    @Override
//                    public void run(){
//                        DownloadManager.Request request = new DownloadManager.Request(
//                                Uri.parse(url));
//
//                        final String filename = URLUtil.guessFileName(url, contentDisposition, mimetype);
//                        request.allowScanningByMediaScanner();
//                        request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED); //Notify client once download is completed!
//                        request.setVisibleInDownloadsUi(true);
//                        request.setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, filename);
//                        DownloadManager dm = (DownloadManager) getSystemService(DOWNLOAD_SERVICE);
//                        if (dm != null) {
//                            dm.enqueue(request);
//                            Toast.makeText(getApplicationContext(), "Downloading File: " + filename, //To notify the Client that the file is being downloaded
//                                    Toast.LENGTH_LONG).show();
//                        }
//                        else {
//                            Toast.makeText(getApplicationContext(), "Cannot Download File: " + filename, //To notify the Client that the file cannot be downloaded
//                                    Toast.LENGTH_LONG).show();
//                        }
//                    }
//                });
//            }
//        });

    WebSettings settings = getSettings();

    settings.setJavaScriptEnabled(options.javaScriptEnabled);
    settings.setJavaScriptCanOpenWindowsAutomatically(options.javaScriptCanOpenWindowsAutomatically);
    settings.setBuiltInZoomControls(options.builtInZoomControls);
    settings.setDisplayZoomControls(options.displayZoomControls);

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

    if (options.transparentBackground) {
      setBackgroundColor(Color.TRANSPARENT);
    }

    if (!options.mixedContentMode.isEmpty()) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
        if (options.mixedContentMode.equals("MIXED_CONTENT_COMPATIBILITY_MODE")) {
          settings.setMixedContentMode(WebSettings.MIXED_CONTENT_COMPATIBILITY_MODE);
        } else if (options.mixedContentMode.equals("MIXED_CONTENT_ALWAYS_ALLOW")) {
          settings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);
        } else if (options.mixedContentMode.equals("MIXED_CONTENT_NEVER_ALLOW")) {
          settings.setMixedContentMode(WebSettings.MIXED_CONTENT_NEVER_ALLOW);
        }
      }
    }
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

  public byte[] takeScreenshot() {
    Picture picture = capturePicture();
    Bitmap b = Bitmap.createBitmap( getWidth(),
            getHeight(), Bitmap.Config.ARGB_8888);
    Canvas c = new Canvas(b);

    picture.draw(c);
    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
    b.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
    try {
      byteArrayOutputStream.close();
    } catch (IOException e) {
      e.printStackTrace();
    }
    return byteArrayOutputStream.toByteArray();
  }

  public void setOptions(InAppWebViewOptions newOptions, HashMap<String, Object> newOptionsMap) {

    WebSettings settings = getSettings();

    if (newOptionsMap.get("javaScriptEnabled") != null && options.javaScriptEnabled != newOptions.javaScriptEnabled)
      settings.setJavaScriptEnabled(newOptions.javaScriptEnabled);

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

    if (newOptionsMap.get("userAgent") != null && options.userAgent != newOptions.userAgent && !newOptions.userAgent.isEmpty())
      settings.setUserAgentString(newOptions.userAgent);

    if (newOptionsMap.get("clearCache") != null && newOptions.clearCache)
      clearAllCache();
    else if (newOptionsMap.get("clearSessionCache") != null && newOptions.clearSessionCache)
      CookieManager.getInstance().removeSessionCookie();

    if (newOptionsMap.get("useWideViewPort") != null && options.useWideViewPort != newOptions.useWideViewPort)
      settings.setUseWideViewPort(newOptions.useWideViewPort);

    if (newOptionsMap.get("supportZoom") != null && options.supportZoom != newOptions.supportZoom)
      settings.setSupportZoom(newOptions.supportZoom);

    if (newOptionsMap.get("textZoom") != null && options.textZoom != newOptions.textZoom)
      settings.setTextZoom(newOptions.textZoom);

    if (newOptionsMap.get("transparentBackground") != null && options.transparentBackground != newOptions.transparentBackground) {
      if (newOptions.transparentBackground) {
        setBackgroundColor(Color.TRANSPARENT);
      } else {
        setBackgroundColor(Color.parseColor("#FFFFFF"));
      }
    }

    if (newOptionsMap.get("mixedContentMode") != null && options.mixedContentMode != newOptions.mixedContentMode) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
        if (newOptions.mixedContentMode.equals("MIXED_CONTENT_COMPATIBILITY_MODE")) {
          settings.setMixedContentMode(WebSettings.MIXED_CONTENT_COMPATIBILITY_MODE);
        } else if (newOptions.mixedContentMode.equals("MIXED_CONTENT_ALWAYS_ALLOW")) {
          settings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);
        } else if (newOptions.mixedContentMode.equals("MIXED_CONTENT_NEVER_ALLOW")) {
          settings.setMixedContentMode(WebSettings.MIXED_CONTENT_NEVER_ALLOW);
        }
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

  public void injectScriptCode(String source, MethodChannel.Result result) {
    String jsWrapper = "(function(){return JSON.stringify(eval(%s));})();";
    injectDeferredObject(source, jsWrapper, result);
  }

  public void injectScriptFile(String urlFile) {
    String jsWrapper = "(function(d) { var c = d.createElement('script'); c.src = %s; d.body.appendChild(c); })(document);";
    injectDeferredObject(urlFile, jsWrapper, null);
  }

  public void injectStyleCode(String source) {
    String jsWrapper = "(function(d) { var c = d.createElement('style'); c.innerHTML = %s; d.body.appendChild(c); })(document);";
    injectDeferredObject(source, jsWrapper, null);
  }

  public void injectStyleFile(String urlFile) {
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

    float scale = getResources().getDisplayMetrics().density;
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
    return (inAppBrowserActivity != null) ? InAppBrowserFlutterPlugin.channel : flutterWebView.channel;
  }
}
