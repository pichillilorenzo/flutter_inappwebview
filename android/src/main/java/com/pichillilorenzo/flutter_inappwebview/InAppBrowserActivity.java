package com.pichillilorenzo.flutter_inappwebview;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Picture;
import android.graphics.drawable.ColorDrawable;

import androidx.annotation.RequiresApi;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;

import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ProgressBar;
import android.widget.SearchView;

import com.pichillilorenzo.flutter_inappwebview.InAppWebView.InAppWebView;
import com.pichillilorenzo.flutter_inappwebview.InAppWebView.InAppWebViewOptions;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class InAppBrowserActivity extends AppCompatActivity {

  static final String LOG_TAG = "InAppBrowserActivity";
  public String uuid;
  public InAppWebView webView;
  public ActionBar actionBar;
  public Menu menu;
  public SearchView searchView;
  public InAppBrowserOptions options;
  public Map<String, String> headers;
  public ProgressBar progressBar;
  public boolean isHidden = false;
  public String fromActivity;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    setContentView(R.layout.activity_web_view);

    webView = findViewById(R.id.webView);
    webView.inAppBrowserActivity = this;

    Bundle b = getIntent().getExtras();
    uuid = b.getString("uuid");
    fromActivity = b.getString("fromActivity");

    HashMap<String, Object> optionsMap = (HashMap<String, Object>) b.getSerializable("options");

    options = new InAppBrowserOptions();
    options.parse(optionsMap);

    InAppWebViewOptions webViewOptions = new InAppWebViewOptions();
    webViewOptions.parse(optionsMap);
    webView.options = webViewOptions;

    InAppWebViewFlutterPlugin.inAppBrowser.webViewActivities.put(uuid, this);

    actionBar = getSupportActionBar();

    prepareView();

    Boolean isData = b.getBoolean("isData");
    if (!isData) {
      headers = (HashMap<String, String>) b.getSerializable("headers");
      String url = b.getString("url");
      webView.loadUrl(url, headers);
    }
    else {
      String data = b.getString("data");
      String mimeType = b.getString("mimeType");
      String encoding = b.getString("encoding");
      String baseUrl = b.getString("baseUrl");
      String historyUrl = b.getString("historyUrl");
      webView.loadDataWithBaseURL(baseUrl, data, mimeType, encoding, historyUrl);
    }

    Map<String, Object> obj = new HashMap<>();
    obj.put("uuid", uuid);
    InAppWebViewFlutterPlugin.inAppBrowser.channel.invokeMethod("onBrowserCreated", obj);

  }

  private void prepareView() {

    webView.prepare();

    if (options.hidden)
      hide();
    else
      show();

    progressBar = findViewById(R.id.progressBar);

    if (!options.progressBar)
      progressBar.setMax(0);
    else
      progressBar.setMax(100);

    actionBar.setDisplayShowTitleEnabled(!options.hideTitleBar);

    if (!options.toolbarTop)
      actionBar.hide();

    if (options.toolbarTopBackgroundColor != null && !options.toolbarTopBackgroundColor.isEmpty())
      actionBar.setBackgroundDrawable(new ColorDrawable(Color.parseColor(options.toolbarTopBackgroundColor)));

    if (options.toolbarTopFixedTitle != null && !options.toolbarTopFixedTitle.isEmpty())
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

  public String getUrl() {
    if (webView != null)
      return webView.getUrl();
    return null;
  }

  public String getWebViewTitle() {
    if (webView != null)
      return webView.getTitle();
    return null;
  }

  public Integer getProgress() {
    if (webView != null)
      return webView.getProgress();
    return null;
  }

  public void loadUrl(String url, MethodChannel.Result result) {
    if (webView != null) {
      webView.loadUrl(url, result);
    } else {
      result.error(LOG_TAG, "webView is null", null);
    }
  }

  public void loadUrl(String url, Map<String, String> headers, MethodChannel.Result result) {
    if (webView != null) {
      webView.loadUrl(url, headers, result);
    } else {
      result.error(LOG_TAG, "webView is null", null);
    }
  }

  public void postUrl(String url, byte[] postData, MethodChannel.Result result) {
    if (webView != null) {
      webView.postUrl(url, postData, result);
    } else {
      result.error(LOG_TAG, "webView is null", null);
    }
  }

  public void loadData(String data, String mimeType, String encoding, String baseUrl, String historyUrl, MethodChannel.Result result) {
    if (webView != null) {
      webView.loadData(data, mimeType, encoding, baseUrl, historyUrl, result);
    } else {
      result.error(LOG_TAG, "webView is null", null);
    }
  }

  public void loadFile(String url, MethodChannel.Result result) {
    if (webView != null) {
      webView.loadFile(url, result);
    } else {
      result.error(LOG_TAG, "webView is null", null);
    }
  }

  public void loadFile(String url, Map<String, String> headers, MethodChannel.Result result) {
    if (webView != null) {
      webView.loadFile(url, headers, result);
    } else {
      result.error(LOG_TAG, "webView is null", null);
    }
  }

  public boolean onKeyDown(int keyCode, KeyEvent event) {
    if ((keyCode == KeyEvent.KEYCODE_BACK)) {
      if (canGoBack())
        goBack();
      else if (options.closeOnCannotGoBack)
        InAppWebViewFlutterPlugin.inAppBrowser.close(this, uuid, null);
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

  public boolean canGoBack() {
    if (webView != null)
      return webView.canGoBack();
    return false;
  }

  public void goForward() {
    if (webView != null && canGoForward())
      webView.goForward();
  }

  public boolean canGoForward() {
    if (webView != null)
      return webView.canGoForward();
    return false;
  }

  public void goBackOrForward(int steps) {
    if (webView != null && canGoBackOrForward(steps))
      webView.goBackOrForward(steps);
  }

  public boolean canGoBackOrForward(int steps) {
    if (webView != null)
      return webView.canGoBackOrForward(steps);
    return false;
  }

  public void hide() {
    try {
      isHidden = true;
      Intent openActivity = new Intent(this, Class.forName(fromActivity));
      openActivity.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
      startActivityIfNeeded(openActivity, 0);
    } catch (ClassNotFoundException e) {
      e.printStackTrace();
      Log.d(LOG_TAG, e.getMessage());
    }
  }

  public void show() {
    isHidden = false;
    Intent openActivity = new Intent(this, InAppBrowserActivity.class);
    openActivity.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
    startActivityIfNeeded(openActivity, 0);
  }

  public void stopLoading() {
    if (webView != null)
      webView.stopLoading();
  }

  public boolean isLoading() {
    if (webView != null)
      return webView.isLoading;
    return false;
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
    InAppWebViewFlutterPlugin.inAppBrowser.close(this, uuid, null);
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

    InAppWebViewOptions newInAppWebViewOptions = new InAppWebViewOptions();
    newInAppWebViewOptions.parse(newOptionsMap);
    webView.setOptions(newInAppWebViewOptions, newOptionsMap);

    if (newOptionsMap.get("hidden") != null && options.hidden != newOptions.hidden) {
      if (newOptions.hidden)
        hide();
      else
        show();
    }

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
    HashMap<String, Object> webViewOptionsMap = webView.getOptions();
    if (options == null || webViewOptionsMap == null)
      return null;

    HashMap<String, Object> optionsMap = options.getHashMap();
    optionsMap.putAll(webViewOptionsMap);
    return optionsMap;
  }

  public void evaluateJavascript(String source, MethodChannel.Result result) {
    if (webView != null)
      webView.evaluateJavascript(source, result);
    else
      result.success("");
  }

  public void injectJavascriptFileFromUrl(String urlFile) {
    if (webView != null)
      webView.injectJavascriptFileFromUrl(urlFile);
  }

  public void injectCSSCode(String source) {
    if (webView != null)
      webView.injectCSSCode(source);
  }

  public void injectCSSFileFromUrl(String urlFile) {
    if (webView != null)
      webView.injectCSSFileFromUrl(urlFile);
  }

  public HashMap<String, Object> getCopyBackForwardList() {
    if (webView != null)
      return webView.getCopyBackForwardList();
    return null;
  }

  public void startSafeBrowsing(MethodChannel.Result result) {
    if (webView != null)
      webView.startSafeBrowsing(result);
    else
      result.success(false);
  }

  public void setSafeBrowsingWhitelist(List<String> hosts, MethodChannel.Result result) {
    if (webView != null)
      webView.setSafeBrowsingWhitelist(hosts, result);
    else
      result.success(false);
  }

  public void clearCache() {
    if (webView != null)
      webView.clearAllCache();
  }

  public void clearSslPreferences() {
    if (webView != null)
      webView.clearSslPreferences();
  }

  public void clearClientCertPreferences(final MethodChannel.Result result) {
    if (webView != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      webView.clearClientCertPreferences(new Runnable() {
        @Override
        public void run() {
          result.success(true);
        }
      });
    }
    else
      result.success(false);
  }

  public void findAllAsync(String find) {
    if (webView != null)
      webView.findAllAsync(find);
  }

  public void findNext(Boolean forward, MethodChannel.Result result) {
    if (webView != null) {
      webView.findNext(forward);
      result.success(true);
    }
    else
      result.success(false);
  }

  public void clearMatches(MethodChannel.Result result) {
    if (webView != null) {
      webView.clearMatches();
      result.success(true);
    }
    else
      result.success(false);
  }

  public void dispose() {
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

  public void scrollTo(Integer x, Integer y) {
    if (webView != null)
      webView.scrollTo(x, y);
  }

  public void scrollBy(Integer x, Integer y) {
    if (webView != null)
      webView.scrollBy(x, y);
  }

  public void onPauseWebView() {
    if (webView != null)
      webView.onPause();
  }

  public void onResumeWebView() {
    if (webView != null)
      webView.onResume();
  }

  public void pauseTimers() {
    if (webView != null)
      webView.pauseTimers();
  }

  public void resumeTimers() {
    if (webView != null)
      webView.resumeTimers();
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  public void printCurrentPage() {
    if (webView != null)
      webView.printCurrentPage();
  }

  public Integer getContentHeight() {
    if (webView != null)
      return webView.getContentHeight();
    return null;
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  public void zoomBy(Float zoomFactor) {
    if (webView != null)
      webView.zoomBy(zoomFactor);
  }

  public String getOriginalUrl() {
    if (webView != null)
      return webView.getOriginalUrl();
    return null;
  }

  public Float getScale() {
    if (webView != null)
      return webView.getUpdatedScale();
    return null;
  }
}
