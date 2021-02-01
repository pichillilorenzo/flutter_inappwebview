package com.pichillilorenzo.flutter_inappwebview.InAppBrowser;

import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Message;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ProgressBar;
import android.widget.SearchView;

import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;

import com.pichillilorenzo.flutter_inappwebview.InAppWebView.InAppWebView;
import com.pichillilorenzo.flutter_inappwebview.InAppWebView.InAppWebViewChromeClient;
import com.pichillilorenzo.flutter_inappwebview.InAppWebView.InAppWebViewOptions;
import com.pichillilorenzo.flutter_inappwebview.InAppWebViewMethodHandler;
import com.pichillilorenzo.flutter_inappwebview.R;
import com.pichillilorenzo.flutter_inappwebview.Shared;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class InAppBrowserActivity extends AppCompatActivity {

  static final String LOG_TAG = "InAppBrowserActivity";
  public MethodChannel channel;
  public Integer windowId;
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
  public List<ActivityResultListener> activityResultListeners = new ArrayList<>();
  public InAppWebViewMethodHandler methodCallDelegate;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    if (savedInstanceState != null) {
      return;
    }

    Bundle b = getIntent().getExtras();
    uuid = b.getString("uuid");
    windowId = b.getInt("windowId");

    channel = new MethodChannel(Shared.messenger, "com.pichillilorenzo/flutter_inappbrowser_" + uuid);

    setContentView(R.layout.activity_web_view);

    webView = findViewById(R.id.webView);
    webView.windowId = windowId;
    webView.inAppBrowserActivity = this;
    webView.channel = channel;

    methodCallDelegate = new InAppWebViewMethodHandler(webView);
    channel.setMethodCallHandler(methodCallDelegate);

    fromActivity = b.getString("fromActivity");

    HashMap<String, Object> optionsMap = (HashMap<String, Object>) b.getSerializable("options");
    HashMap<String, Object> contextMenu = (HashMap<String, Object>) b.getSerializable("contextMenu");
    List<Map<String, Object>> initialUserScripts = (List<Map<String, Object>>) b.getSerializable("initialUserScripts");

    options = new InAppBrowserOptions();
    options.parse(optionsMap);

    InAppWebViewOptions webViewOptions = new InAppWebViewOptions();
    webViewOptions.parse(optionsMap);
    webView.options = webViewOptions;
    webView.contextMenu = contextMenu;
    webView.userScripts = initialUserScripts;

    actionBar = getSupportActionBar();

    prepareView();

    if (windowId != -1) {
      Message resultMsg = InAppWebViewChromeClient.windowWebViewMessages.get(windowId);
      if (resultMsg != null) {
        ((WebView.WebViewTransport) resultMsg.obj).setWebView(webView);
        resultMsg.sendToTarget();
      }
    } else {
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
    }

    Map<String, Object> obj = new HashMap<>();
    channel.invokeMethod("onBrowserCreated", obj);
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

  public boolean onKeyDown(int keyCode, KeyEvent event) {
    if ((keyCode == KeyEvent.KEYCODE_BACK)) {
      if (canGoBack())
        goBack();
      else if (options.closeOnCannotGoBack)
        close(null);
      return true;
    }
    return super.onKeyDown(keyCode, event);
  }

  public void close(final MethodChannel.Result result) {
    Map<String, Object> obj = new HashMap<>();
    channel.invokeMethod("onExit", obj);

    dispose();

    if (result != null) {
      result.success(true);
    }
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
    close(null);
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

  public Map<String, Object> getOptions() {
    Map<String, Object> webViewOptionsMap = webView.getOptions();
    if (options == null || webViewOptionsMap == null)
      return null;

    Map<String, Object> optionsMap = options.getRealOptions(this);
    optionsMap.putAll(webViewOptionsMap);
    return optionsMap;
  }

  public void dispose() {
    channel.setMethodCallHandler(null);
    activityResultListeners.clear();
    if (methodCallDelegate != null) {
      methodCallDelegate.dispose();
      methodCallDelegate = null;
    }
    if (webView != null) {
      if (Shared.activityPluginBinding != null) {
        Shared.activityPluginBinding.removeActivityResultListener(webView.inAppWebViewChromeClient);
      }
      ViewGroup vg = (ViewGroup) (webView.getParent());
      vg.removeView(webView);
      webView.setWebChromeClient(new WebChromeClient());
      webView.setWebViewClient(new WebViewClient() {
        public void onPageFinished(WebView view, String url) {
          webView.dispose();
          webView.destroy();
          webView = null;
        }
      });
      webView.loadUrl("about:blank");
      finish();
    }
  }

  @Override
  protected void onActivityResult (int requestCode,
                                   int resultCode,
                                   Intent data) {
    for (ActivityResultListener listener : activityResultListeners) {
      if (listener.onActivityResult(requestCode, resultCode, data)) {
        return;
      }
    }
    super.onActivityResult(requestCode, resultCode, data);
  }

  @Override
  public void onDestroy() {
    dispose();
    super.onDestroy();
  }

  public interface ActivityResultListener {
    /** @return true if the result has been handled. */
    boolean onActivityResult(int requestCode, int resultCode, Intent data);
  }
}
