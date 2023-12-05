package com.pichillilorenzo.flutter_inappwebview_android_geckoview.webview.in_app_webview;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview_android_geckoview.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.types.Disposable;

import org.mozilla.geckoview.GeckoResult;
import org.mozilla.geckoview.GeckoSession;

public class InAppWebViewHistoryDelegate implements GeckoSession.HistoryDelegate, Disposable {
  private static final String LOG_TAG = "InAppWebViewHistoryDelegate";
  @Nullable
  public InAppWebViewFlutterPlugin plugin;
  @Nullable
  public InAppWebView webView;
  @Nullable
  public HistoryList historyList;

  InAppWebViewHistoryDelegate(@NonNull final InAppWebViewFlutterPlugin plugin, @NonNull InAppWebView webView) {
    this.plugin = plugin;
    this.webView = webView;
  }

  @Nullable
  @Override
  public GeckoResult<Boolean> onVisited(@NonNull GeckoSession session, @NonNull String url, @Nullable String lastVisitedURL, int flags) {
    return GeckoSession.HistoryDelegate.super.onVisited(session, url, lastVisitedURL, flags);
  }

  @Nullable
  @Override
  public GeckoResult<boolean[]> getVisited(@NonNull GeckoSession session, @NonNull String[] urls) {
    return GeckoSession.HistoryDelegate.super.getVisited(session, urls);
  }

  @Override
  public void onHistoryStateChange(@NonNull GeckoSession session, @NonNull HistoryList historyList) {
    this.historyList = historyList;
  }

  @Override
  public void dispose() {
    plugin = null;
    webView = null;
    historyList = null;
  }
}
