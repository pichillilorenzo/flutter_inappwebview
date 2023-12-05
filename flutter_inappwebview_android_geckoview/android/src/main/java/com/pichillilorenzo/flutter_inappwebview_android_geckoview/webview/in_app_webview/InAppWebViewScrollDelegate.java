package com.pichillilorenzo.flutter_inappwebview_android_geckoview.webview.in_app_webview;

import android.util.Log;
import android.view.View;
import android.view.ViewParent;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview_android_geckoview.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.pull_to_refresh.PullToRefreshLayout;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.types.Disposable;

import org.mozilla.geckoview.GeckoSession;
import org.mozilla.geckoview.PanZoomController;

public class InAppWebViewScrollDelegate implements GeckoSession.ScrollDelegate, Disposable {
  private static final String LOG_TAG = "InAppWebViewScrollDeleg";
  @Nullable
  public InAppWebViewFlutterPlugin plugin;
  @Nullable
  public InAppWebView webView;

  public int scrollX = 0;
  public int scrollY = 0;

  InAppWebViewScrollDelegate(@NonNull final InAppWebViewFlutterPlugin plugin, @NonNull InAppWebView webView) {
    this.plugin = plugin;
    this.webView = webView;
  }

  @Override
  public void onScrollChanged(@NonNull GeckoSession session, int scrollX, int scrollY) {
    this.scrollX = scrollX;
    this.scrollY = scrollY;

    if (webView != null && webView.channelDelegate != null) {
      webView.channelDelegate.onScrollChanged(scrollX, scrollY);

      ViewParent parent = webView.getParent();
      if (parent instanceof PullToRefreshLayout) {
        PullToRefreshLayout pullToRefreshLayout = (PullToRefreshLayout) parent;
        if (scrollY < 1) {
          // change over scroll mode to OVER_SCROLL_NEVER in order to disable temporarily the glow effect
          webView.setOverScrollMode(View.OVER_SCROLL_NEVER);
          pullToRefreshLayout.setEnabled(pullToRefreshLayout.settings.enabled);
          // reset over scroll mode
          webView.setOverScrollMode(webView.customSettings.overScrollMode);
        } else {
          pullToRefreshLayout.setEnabled(false);
        }
      }

//      webView.channelDelegate.onOverScrolled(scrollX, scrollY, false, false);
    }
  }

  @Override
  public void dispose() {
    plugin = null;
    webView = null;
  }
}
