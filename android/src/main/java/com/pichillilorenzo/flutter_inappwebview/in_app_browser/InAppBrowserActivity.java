package com.pichillilorenzo.flutter_inappwebview.in_app_browser;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Build;
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

import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;

import com.pichillilorenzo.flutter_inappwebview.InAppWebViewMethodHandler;
import com.pichillilorenzo.flutter_inappwebview.R;
import com.pichillilorenzo.flutter_inappwebview.Util;
import com.pichillilorenzo.flutter_inappwebview.in_app_webview.InAppWebView;
import com.pichillilorenzo.flutter_inappwebview.in_app_webview.InAppWebViewChromeClient;
import com.pichillilorenzo.flutter_inappwebview.in_app_webview.InAppWebViewSettings;
import com.pichillilorenzo.flutter_inappwebview.pull_to_refresh.PullToRefreshLayout;
import com.pichillilorenzo.flutter_inappwebview.pull_to_refresh.PullToRefreshSettings;
import com.pichillilorenzo.flutter_inappwebview.types.URLRequest;
import com.pichillilorenzo.flutter_inappwebview.types.UserScript;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class InAppBrowserActivity extends AppCompatActivity implements InAppBrowserDelegate {

  static final String LOG_TAG = "InAppBrowserActivity";
  public MethodChannel channel;
  public Integer windowId;
  public String id;
  public InAppWebView webView;
  public PullToRefreshLayout pullToRefreshLayout;
  @Nullable
  public ActionBar actionBar;
  public Menu menu;
  public SearchView searchView;
  public InAppBrowserSettings customSettings = new InAppBrowserSettings();
  public ProgressBar progressBar;
  public boolean isHidden = false;
  public String fromActivity;
  private List<ActivityResultListener> activityResultListeners = new ArrayList<>();
  public InAppWebViewMethodHandler methodCallDelegate;
  public InAppBrowserManager manager;
  
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    Bundle b = getIntent().getExtras();
    if (b == null) return;
    
    id = b.getString("id");

    String managerId = b.getString("managerId");
    manager = InAppBrowserManager.shared.get(managerId);
    if (manager == null || manager.plugin == null|| manager.plugin.messenger == null) return;

    Map<String, Object> settingsMap = (Map<String, Object>) b.getSerializable("settings");
    customSettings.parse(settingsMap);

    windowId = b.getInt("windowId");

    channel = new MethodChannel(manager.plugin.messenger, "com.pichillilorenzo/flutter_inappbrowser_" + id);

    setContentView(R.layout.activity_web_view);

    Map<String, Object> pullToRefreshInitialSettings = (Map<String, Object>) b.getSerializable("pullToRefreshInitialSettings");
    MethodChannel pullToRefreshLayoutChannel = new MethodChannel(manager.plugin.messenger, "com.pichillilorenzo/flutter_inappwebview_pull_to_refresh_" + id);
    PullToRefreshSettings pullToRefreshSettings = new PullToRefreshSettings();
    pullToRefreshSettings.parse(pullToRefreshInitialSettings);
    pullToRefreshLayout = findViewById(R.id.pullToRefresh);
    pullToRefreshLayout.channel = pullToRefreshLayoutChannel;
    pullToRefreshLayout.options = pullToRefreshSettings;
    pullToRefreshLayout.prepare();

    webView = findViewById(R.id.webView);
    webView.windowId = windowId;
    webView.inAppBrowserDelegate = this;
    webView.channel = channel;
    webView.plugin = manager.plugin;

    methodCallDelegate = new InAppWebViewMethodHandler(webView);
    channel.setMethodCallHandler(methodCallDelegate);

    fromActivity = b.getString("fromActivity");

    Map<String, Object> contextMenu = (Map<String, Object>) b.getSerializable("contextMenu");
    List<Map<String, Object>> initialUserScripts = (List<Map<String, Object>>) b.getSerializable("initialUserScripts");

    InAppWebViewSettings webViewSettings = new InAppWebViewSettings();
    webViewSettings.parse(settingsMap);
    webView.customSettings = webViewSettings;
    webView.contextMenu = contextMenu;

    List<UserScript> userScripts = new ArrayList<>();
    if (initialUserScripts != null) {
      for (Map<String, Object> initialUserScript : initialUserScripts) {
        userScripts.add(UserScript.fromMap(initialUserScript));
      }
    }
    webView.userContentController.addUserOnlyScripts(userScripts);

    actionBar = getSupportActionBar();

    prepareView();

    if (windowId != -1) {
      Message resultMsg = InAppWebViewChromeClient.windowWebViewMessages.get(windowId);
      if (resultMsg != null) {
        ((WebView.WebViewTransport) resultMsg.obj).setWebView(webView);
        resultMsg.sendToTarget();
      }
    } else {
      String initialFile = b.getString("initialFile");
      Map<String, Object> initialUrlRequest = (Map<String, Object>) b.getSerializable("initialUrlRequest");
      String initialData = b.getString("initialData");
      if (initialFile != null) {
        try {
          webView.loadFile(initialFile);
        } catch (IOException e) {
          e.printStackTrace();
          Log.e(LOG_TAG, initialFile + " asset file cannot be found!", e);
          return;
        }
      }
      else if (initialData != null) {
        String mimeType = b.getString("initialMimeType");
        String encoding = b.getString("initialEncoding");
        String baseUrl = b.getString("initialBaseUrl");
        String historyUrl = b.getString("initialHistoryUrl");
        webView.loadDataWithBaseURL(baseUrl, initialData, mimeType, encoding, historyUrl);
      }
      else if (initialUrlRequest != null) {
        URLRequest urlRequest = URLRequest.fromMap(initialUrlRequest);
        webView.loadUrl(urlRequest);
      }
    }

    onBrowserCreated();
  }

  public void onBrowserCreated() {
    Map<String, Object> obj = new HashMap<>();
    channel.invokeMethod("onBrowserCreated", obj);
  }

  private void prepareView() {

    webView.prepare();

    if (customSettings.hidden)
      hide();
    else
      show();

    progressBar = findViewById(R.id.progressBar);

    if (customSettings.hideProgressBar)
      progressBar.setMax(0);
    else
      progressBar.setMax(100);

    if (actionBar != null) {
      actionBar.setDisplayShowTitleEnabled(!customSettings.hideTitleBar);

      if (customSettings.hideToolbarTop)
        actionBar.hide();

      if (customSettings.toolbarTopBackgroundColor != null && !customSettings.toolbarTopBackgroundColor.isEmpty())
        actionBar.setBackgroundDrawable(new ColorDrawable(Color.parseColor(customSettings.toolbarTopBackgroundColor)));

      if (customSettings.toolbarTopFixedTitle != null && !customSettings.toolbarTopFixedTitle.isEmpty())
        actionBar.setTitle(customSettings.toolbarTopFixedTitle);
    }
  }

  @Override
  public boolean onCreateOptionsMenu(Menu m) {
    menu = m;

    MenuInflater inflater = getMenuInflater();
    // Inflate menu to add items to action bar if it is present.
    inflater.inflate(R.menu.menu_main, menu);

    searchView = (SearchView) menu.findItem(R.id.menu_search).getActionView();
    searchView.setFocusable(true);

    if (customSettings.hideUrlBar)
      menu.findItem(R.id.menu_search).setVisible(false);

    searchView.setQuery(webView.getUrl(), false);

    if (actionBar != null && (customSettings.toolbarTopFixedTitle == null || customSettings.toolbarTopFixedTitle.isEmpty()))
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
    if (keyCode == KeyEvent.KEYCODE_BACK) {
      if (customSettings.shouldCloseOnBackButtonPressed) {
        close(null);
        return true;
      }
      if (customSettings.allowGoBackWithBackButton) {
        if (canGoBack())
          goBack();
        else if (customSettings.closeOnCannotGoBack)
          close(null);
        return true;
      }
      if (!customSettings.shouldCloseOnBackButtonPressed) {
        return true;
      }
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

  public void setSettings(InAppBrowserSettings newSettings, HashMap<String, Object> newSettingsMap) {

    InAppWebViewSettings newInAppWebViewSettings = new InAppWebViewSettings();
    newInAppWebViewSettings.parse(newSettingsMap);
    webView.setSettings(newInAppWebViewSettings, newSettingsMap);

    if (newSettingsMap.get("hidden") != null && customSettings.hidden != newSettings.hidden) {
      if (newSettings.hidden)
        hide();
      else
        show();
    }

    if (newSettingsMap.get("hideProgressBar") != null && customSettings.hideProgressBar != newSettings.hideProgressBar && progressBar != null) {
      if (newSettings.hideProgressBar)
        progressBar.setMax(0);
      else
        progressBar.setMax(100);
    }

    if (actionBar != null && newSettingsMap.get("hideTitleBar") != null && customSettings.hideTitleBar != newSettings.hideTitleBar)
      actionBar.setDisplayShowTitleEnabled(!newSettings.hideTitleBar);

    if (actionBar != null && newSettingsMap.get("hideToolbarTop") != null && customSettings.hideToolbarTop != newSettings.hideToolbarTop) {
      if (newSettings.hideToolbarTop)
        actionBar.hide();
      else
        actionBar.show();
    }

    if (actionBar != null && newSettingsMap.get("toolbarTopBackgroundColor") != null &&
            !Util.objEquals(customSettings.toolbarTopBackgroundColor, newSettings.toolbarTopBackgroundColor) &&
            !newSettings.toolbarTopBackgroundColor.isEmpty())
      actionBar.setBackgroundDrawable(new ColorDrawable(Color.parseColor(newSettings.toolbarTopBackgroundColor)));

    if (actionBar != null && newSettingsMap.get("toolbarTopFixedTitle") != null &&
            !Util.objEquals(customSettings.toolbarTopFixedTitle, newSettings.toolbarTopFixedTitle) &&
            !newSettings.toolbarTopFixedTitle.isEmpty())
      actionBar.setTitle(newSettings.toolbarTopFixedTitle);

    if (newSettingsMap.get("hideUrlBar") != null && customSettings.hideUrlBar != newSettings.hideUrlBar) {
      if (newSettings.hideUrlBar)
        menu.findItem(R.id.menu_search).setVisible(false);
      else
        menu.findItem(R.id.menu_search).setVisible(true);
    }

    customSettings = newSettings;
  }

  public Map<String, Object> getCustomSettings() {
    Map<String, Object> webViewSettingsMap = webView.getCustomSettings();
    if (customSettings == null || webViewSettingsMap == null)
      return null;

    Map<String, Object> settingsMap = customSettings.getRealSettings(this);
    settingsMap.putAll(webViewSettingsMap);
    return settingsMap;
  }

  @Override
  public Activity getActivity() {
    return this;
  }

  @Override
  public void didChangeTitle(String title) {
    if (actionBar != null && (customSettings.toolbarTopFixedTitle == null || customSettings.toolbarTopFixedTitle.isEmpty())) {
      actionBar.setTitle(title);
    }
  }

  @Override
  public void didStartNavigation(String url) {
    if (progressBar != null) {
      progressBar.setProgress(0);
    }
    if (searchView != null) {
      searchView.setQuery(url, false);
    }
  }

  @Override
  public void didUpdateVisitedHistory(String url) {
    if (searchView != null) {
      searchView.setQuery(url, false);
    }
  }

  @Override
  public void didFinishNavigation(String url) {
    if (searchView != null) {
      searchView.setQuery(url, false);
    }
    if (progressBar != null) {
      progressBar.setProgress(0);
    }
  }

  @Override
  public void didFailNavigation(String url, int errorCode, String description) {
    if (progressBar != null) {
      progressBar.setProgress(0);
    }
  }

  @Override
  public void didChangeProgress(int progress) {
    if (progressBar != null) {
      progressBar.setVisibility(View.VISIBLE);
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        progressBar.setProgress(progress, true);
      } else {
        progressBar.setProgress(progress);
      }
      if (progress == 100) {
        progressBar.setVisibility(View.GONE);
      }
    }
  }

  public List<ActivityResultListener> getActivityResultListeners() {
    return activityResultListeners;
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

  public void dispose() {
    channel.setMethodCallHandler(null);
    activityResultListeners.clear();
    if (methodCallDelegate != null) {
      methodCallDelegate.dispose();
      methodCallDelegate = null;
    }
    if (webView != null) {
      if (manager != null && manager.plugin != null && manager.plugin.activityPluginBinding != null) {
        manager.plugin.activityPluginBinding.removeActivityResultListener(webView.inAppWebViewChromeClient);
      }
      ViewGroup vg = (ViewGroup) (webView.getParent());
      if (vg != null) {
        vg.removeView(webView);
      }
      webView.setWebChromeClient(new WebChromeClient());
      webView.setWebViewClient(new WebViewClient() {
        public void onPageFinished(WebView view, String url) {
          webView.dispose();
          webView.destroy();
          webView = null;
          manager = null;
        }
      });
      webView.loadUrl("about:blank");
      finish();
    }
  }

  @Override
  public void onDestroy() {
    dispose();
    super.onDestroy();
  }
}
