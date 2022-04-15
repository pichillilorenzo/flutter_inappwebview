package com.pichillilorenzo.flutter_inappwebview.in_app_geckoview;

import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview.in_app_browser.InAppBrowserDelegate;

import org.mozilla.geckoview.AllowOrDeny;
import org.mozilla.geckoview.GeckoResult;
import org.mozilla.geckoview.GeckoSession;
import org.mozilla.geckoview.WebRequestError;

import java.util.List;

import io.flutter.plugin.common.MethodChannel;

public class InAppGeckoViewNavigationDelegate implements GeckoSession.NavigationDelegate {

  protected static final String LOG_TAG = "IAGeckoViewNavDelegate";
  private InAppBrowserDelegate inAppBrowserDelegate;
  private final MethodChannel channel;
  @Nullable
  private InAppGeckoView inAppGeckoView;
  
  public InAppGeckoViewNavigationDelegate(@NonNull InAppGeckoView inAppGeckoView, MethodChannel channel, InAppBrowserDelegate inAppBrowserDelegate) {
    super();
    
    this.inAppGeckoView = inAppGeckoView;
    this.channel = channel;
    this.inAppBrowserDelegate = inAppBrowserDelegate;
  }

  @Override
  public void onLocationChange(@NonNull GeckoSession session, @Nullable String url, @NonNull List<GeckoSession.PermissionDelegate.ContentPermission> perms) {
    // TODO: implement
    if (inAppGeckoView != null) {
      inAppGeckoView.currentUrl = url;
    }
  }

  @Override
  public void onCanGoBack(@NonNull GeckoSession session, boolean canGoBack) {
    if (inAppGeckoView != null) {
      inAppGeckoView.canGoBack = canGoBack;
    }
  }

  @Override
  public void onCanGoForward(@NonNull GeckoSession session, boolean canGoForward) {
    if (inAppGeckoView != null) {
      inAppGeckoView.canGoForward = canGoForward;
    }
  }

  @Nullable
  @Override
  public GeckoResult<AllowOrDeny> onLoadRequest(@NonNull GeckoSession session, @NonNull LoadRequest request) {
    // TODO: implement
    return null;
  }

  @Nullable
  @Override
  public GeckoResult<AllowOrDeny> onSubframeLoadRequest(@NonNull GeckoSession session, @NonNull LoadRequest request) {
    // TODO: implement
    return null;
  }

  @Nullable
  @Override
  public GeckoResult<GeckoSession> onNewSession(@NonNull GeckoSession session, @NonNull String uri) {
    // TODO: implement
    return null;
  }

  @Nullable
  @Override
  public GeckoResult<String> onLoadError(@NonNull GeckoSession session, @Nullable String uri, @NonNull WebRequestError error) {
    // TODO: implement
    return null;
  }

  public void dispose() {
    if (inAppGeckoView != null) {
      inAppGeckoView = null;
    }
    if (inAppBrowserDelegate != null) {
      inAppBrowserDelegate = null;
    }
  }
}
