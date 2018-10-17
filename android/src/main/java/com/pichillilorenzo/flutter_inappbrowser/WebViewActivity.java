package com.pichillilorenzo.flutter_inappbrowser;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Picture;
import android.graphics.drawable.ColorDrawable;
import android.os.Build;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.CookieManager;
import android.webkit.ValueCallback;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.ProgressBar;
import android.widget.SearchView;

import java.io.ByteArrayOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import okhttp3.Cache;
import okhttp3.OkHttpClient;

public class WebViewActivity extends AppCompatActivity {

  String uuid;
  WebView webView;
  ActionBar actionBar;
  Menu menu;
  InAppBrowserWebViewClient inAppBrowserWebViewClient;
  InAppBrowserWebChromeClient inAppBrowserWebChromeClient;
  SearchView searchView;
  InAppBrowserOptions options;
  Map<String, String> headers;
  ProgressBar progressBar;
  public boolean isLoading = false;
  public boolean isHidden = false;
  OkHttpClient httpClient;

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

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    setContentView(R.layout.activity_web_view);

    webView = findViewById(R.id.webView);

    Bundle b = getIntent().getExtras();
    uuid = b.getString("uuid");
    String url = b.getString("url");

    options = new InAppBrowserOptions();
    options.parse((HashMap<String, Object>) b.getSerializable("options"));

    headers = (HashMap<String, String>) b.getSerializable("headers");

    InAppBrowserFlutterPlugin.webViewActivities.put(uuid, this);

    actionBar = getSupportActionBar();

    prepareWebView();

    int cacheSize = 10 * 1024 * 1024; // 10MB
    httpClient = new OkHttpClient().newBuilder().cache(new Cache(getApplicationContext().getCacheDir(), cacheSize)).build();

    webView.loadUrl(url, headers);
    //webView.loadData("<!DOCTYPE assets> <assets lang=\"en\"> <head> <meta charset=\"UTF-8\"> <title>Document</title> </head> <body> ciao <img src=\"https://via.placeholder.com/350x150\" /> <img src=\"./images/test\" alt=\"not found\" /></body> </assets>", "text/assets", "utf8");

  }

  private void prepareWebView() {

    webView.addJavascriptInterface(new JavaScriptBridgeInterface(this), JavaScriptBridgeInterface.name);

    inAppBrowserWebChromeClient = new InAppBrowserWebChromeClient(this);
    webView.setWebChromeClient(inAppBrowserWebChromeClient);

    inAppBrowserWebViewClient = new InAppBrowserWebViewClient(this);
    webView.setWebViewClient(inAppBrowserWebViewClient);

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

    WebSettings settings = webView.getSettings();

    if (options.hidden)
      hide();
    else
      show();

    settings.setJavaScriptEnabled(options.javaScriptEnabled);
    settings.setJavaScriptCanOpenWindowsAutomatically(options.javaScriptCanOpenWindowsAutomatically);
    settings.setBuiltInZoomControls(options.builtInZoomControls);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
      settings.setSafeBrowsingEnabled(options.safeBrowsingEnabled);

    settings.setMediaPlaybackRequiresUserGesture(options.mediaPlaybackRequiresUserGesture);

    settings.setDatabaseEnabled(options.databaseEnabled);
    settings.setDomStorageEnabled(options.domStorageEnabled);

    if (!options.userAgent.isEmpty())
      settings.setUserAgentString(options.userAgent);

    if (options.clearCache)
      clearCache();
    else if (options.clearSessionCache)
      CookieManager.getInstance().removeSessionCookie();

    // Enable Thirdparty Cookies on >=Android 5.0 device
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
      CookieManager.getInstance().setAcceptThirdPartyCookies(webView, true);

    settings.setLoadWithOverviewMode(true);
    settings.setUseWideViewPort(options.useWideViewPort);
    settings.setSupportZoom(options.supportZoom);

    // fix webview scaling
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT)
      settings.setLayoutAlgorithm(WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING);
    else
      settings.setTextZoom(100);

    progressBar = findViewById(R.id.progressBar);

    if (!options.progressBar)
      progressBar.setMax(0);
    else
      progressBar.setMax(100);

    actionBar.setDisplayShowTitleEnabled(!options.hideTitleBar);

    if (!options.toolbarTop)
      actionBar.hide();

    if (!options.toolbarTopBackgroundColor.isEmpty())
      actionBar.setBackgroundDrawable(new ColorDrawable(Color.parseColor(options.toolbarTopBackgroundColor)));

    if (!options.toolbarTopFixedTitle.isEmpty())
      actionBar.setTitle(options.toolbarTopFixedTitle);

  }

  @Override
  public boolean onCreateOptionsMenu(Menu m) {
    menu = m;

    MenuInflater inflater = getMenuInflater();
    // Inflate menu to add items to action bar if it is present.
    inflater.inflate(R.menu.menu_main, menu);

    searchView = (SearchView) menu.findItem(R.id.menu_search).getActionView();
    searchView.setFocusable(true);

    if (options.hideUrlBar)
      menu.findItem(R.id.menu_search).setVisible(false);

    searchView.setQuery(webView.getUrl(), false);

    if (options.toolbarTopFixedTitle.isEmpty())
      actionBar.setTitle(webView.getTitle());

    searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
      @Override
      public boolean onQueryTextSubmit(String query) {
        if (!query.isEmpty()) {
          webView.loadUrl(query);
          searchView.setQuery("", false);
          searchView.setIconified(true);
          return true;
        }
        return false;
      }

      @Override
      public boolean onQueryTextChange(String newText) {
        return false;
      }

    });

    searchView.setOnCloseListener(new SearchView.OnCloseListener() {
      @Override
      public boolean onClose() {
        if (searchView.getQuery().toString().isEmpty())
          searchView.setQuery(webView.getUrl(), false);
        return false;
      }
    });

    searchView.setOnQueryTextFocusChangeListener(new View.OnFocusChangeListener() {
      @Override
      public void onFocusChange(View view, boolean b) {
        if (!b) {
          searchView.setQuery("", false);
          searchView.setIconified(true);
        }
      }
    });

    return true;
  }

  public void loadUrl(String url, MethodChannel.Result result) {
    if (webView != null && !url.isEmpty()) {
      webView.loadUrl(url);
    } else {
      result.error("Cannot load url", "", null);
    }
  }

  public void loadUrl(String url, Map<String, String> headers, MethodChannel.Result result) {
    if (webView != null && !url.isEmpty()) {
      webView.loadUrl(url, headers);
    } else {
      result.error("Cannot load url", "", null);
    }
  }

  public void loadFile(String url, MethodChannel.Result result) {
    if (webView != null && !url.isEmpty()) {
      webView.loadUrl(url);
    } else {
      result.error("Cannot load url", "", null);
    }
  }

  public void loadFile(String url, Map<String, String> headers, MethodChannel.Result result) {
    if (webView != null && !url.isEmpty()) {
      webView.loadUrl(url, headers);
    } else {
      result.error("Cannot load url", "", null);
    }
  }

  public boolean onKeyDown(int keyCode, KeyEvent event) {
    if ((keyCode == KeyEvent.KEYCODE_BACK)) {
      if (canGoBack())
        goBack();
      else if (options.closeOnCannotGoBack)
        InAppBrowserFlutterPlugin.close(uuid, null);
      return true;
    }
    return super.onKeyDown(keyCode, event);
  }

  public void close() {
    hide();
    finish();
  }

  public void reload() {
    if (webView != null)
      webView.reload();
  }

  public void goBack() {
    if (webView != null && canGoBack())
      webView.goBack();
  }

  public void goForward() {
    if (webView != null && canGoForward())
      webView.goForward();
  }

  public boolean canGoBack() {
    return webView.canGoBack();
  }

  public boolean canGoForward() {
    return webView.canGoForward();
  }

  public void hide() {
    isHidden = true;
    Intent openActivity = new Intent(this, InAppBrowserFlutterPlugin.registrar.activity().getClass());
    openActivity.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
    startActivityIfNeeded(openActivity, 0);
  }

  public void show() {
    isHidden = false;
    Intent openActivity = new Intent(InAppBrowserFlutterPlugin.registrar.activity(), WebViewActivity.class);
    openActivity.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
    startActivityIfNeeded(openActivity, 0);
  }

  public void stopLoading() {
    if (webView != null)
      webView.stopLoading();
  }

  public boolean isLoading() {
    if (webView != null)
      return isLoading;
    return false;
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

  private void clearCache() {
    if (webView != null) {
      webView.clearCache(true);
      clearCookies();
      webView.clearFormData();
    }
  }

  public void goBackButtonClicked(MenuItem item) {
    goBack();
  }

  public void goForwardButtonClicked(MenuItem item) {
    goForward();
  }

  public void shareButtonClicked(MenuItem item) {
    Intent share = new Intent(Intent.ACTION_SEND);
    share.setType("text/plain");
    share.putExtra(Intent.EXTRA_TEXT, webView.getUrl());
    startActivity(Intent.createChooser(share, "Share"));
  }

  public void reloadButtonClicked(MenuItem item) {
    reload();
  }

  public void closeButtonClicked(MenuItem item) {
    InAppBrowserFlutterPlugin.close(uuid, null);
  }

  public byte[] takeScreenshot() {
    if (webView != null) {
      Picture picture = webView.capturePicture();
      Bitmap b = Bitmap.createBitmap( webView.getWidth(),
              webView.getHeight(), Bitmap.Config.ARGB_8888);
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
    return null;
  }

  public void setOptions(InAppBrowserOptions newOptions, HashMap<String, Object> newOptionsMap) {

    WebSettings settings = webView.getSettings();

    if (newOptionsMap.get("hidden") != null && options.hidden != newOptions.hidden) {
      if (newOptions.hidden)
        hide();
      else
        show();
    }

    if (newOptionsMap.get("javaScriptEnabled") != null && options.javaScriptEnabled != newOptions.javaScriptEnabled)
      settings.setJavaScriptEnabled(newOptions.javaScriptEnabled);

    if (newOptionsMap.get("javaScriptCanOpenWindowsAutomatically") != null && options.javaScriptCanOpenWindowsAutomatically != newOptions.javaScriptCanOpenWindowsAutomatically)
      settings.setJavaScriptCanOpenWindowsAutomatically(newOptions.javaScriptCanOpenWindowsAutomatically);

    if (newOptionsMap.get("builtInZoomControls") != null && options.builtInZoomControls != newOptions.builtInZoomControls)
      settings.setBuiltInZoomControls(newOptions.builtInZoomControls);

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
      clearCache();
    else if (newOptionsMap.get("clearSessionCache") != null && newOptions.clearSessionCache)
      CookieManager.getInstance().removeSessionCookie();

    if (newOptionsMap.get("useWideViewPort") != null && options.useWideViewPort != newOptions.useWideViewPort)
      settings.setUseWideViewPort(newOptions.useWideViewPort);

    if (newOptionsMap.get("supportZoom") != null && options.supportZoom != newOptions.supportZoom)
      settings.setSupportZoom(newOptions.supportZoom);

    if (newOptionsMap.get("progressBar") != null && options.progressBar != newOptions.progressBar && progressBar != null) {
      if (newOptions.progressBar)
        progressBar.setMax(0);
      else
        progressBar.setMax(100);
    }

    if (newOptionsMap.get("hideTitleBar") != null && options.hideTitleBar != newOptions.hideTitleBar)
      actionBar.setDisplayShowTitleEnabled(!newOptions.hideTitleBar);

    if (newOptionsMap.get("toolbarTop") != null && options.toolbarTop != newOptions.toolbarTop) {
      if (!newOptions.toolbarTop)
        actionBar.hide();
      else
        actionBar.show();
    }

    if (newOptionsMap.get("toolbarTopBackgroundColor") != null && options.toolbarTopBackgroundColor != newOptions.toolbarTopBackgroundColor && !newOptions.toolbarTopBackgroundColor.isEmpty())
      actionBar.setBackgroundDrawable(new ColorDrawable(Color.parseColor(newOptions.toolbarTopBackgroundColor)));

    if (newOptionsMap.get("toolbarTopFixedTitle") != null && options.toolbarTopFixedTitle != newOptions.toolbarTopFixedTitle && !newOptions.toolbarTopFixedTitle.isEmpty())
      actionBar.setTitle(newOptions.toolbarTopFixedTitle);

    if (newOptionsMap.get("hideUrlBar") != null && options.hideUrlBar != newOptions.hideUrlBar) {
      if (newOptions.hideUrlBar)
        menu.findItem(R.id.menu_search).setVisible(false);
      else
        menu.findItem(R.id.menu_search).setVisible(true);
    }

    options = newOptions;
  }

  public HashMap<String, Object> getOptions() {
    return (options != null) ? options.getHashMap() : null;
  }

}
