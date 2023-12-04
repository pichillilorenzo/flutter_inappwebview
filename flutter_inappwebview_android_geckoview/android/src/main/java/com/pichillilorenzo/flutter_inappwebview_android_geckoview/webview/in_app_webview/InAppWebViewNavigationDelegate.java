package com.pichillilorenzo.flutter_inappwebview_android_geckoview.webview.in_app_webview;

import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview_android_geckoview.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.types.Disposable;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.types.NavigationAction;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.types.NavigationActionPolicy;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.types.URLRequest;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.webview.WebViewChannelDelegate;

import org.mozilla.geckoview.AllowOrDeny;
import org.mozilla.geckoview.GeckoResult;
import org.mozilla.geckoview.GeckoSession;
import org.mozilla.geckoview.WebRequestError;

import java.util.List;

public class InAppWebViewNavigationDelegate implements GeckoSession.NavigationDelegate, Disposable {
  private static String LOG_TAG = "InAppWebViewNavigationDelegate";
  @Nullable
  public InAppWebViewFlutterPlugin plugin;
  @Nullable
  public InAppWebView webView;

  public boolean canGoBack = false;
  public boolean canGoForward = false;

  InAppWebViewNavigationDelegate(@NonNull final InAppWebViewFlutterPlugin plugin, @NonNull InAppWebView webView) {
    this.plugin = plugin;
    this.webView = webView;
  }

  @Override
  public void onLocationChange(@NonNull GeckoSession session, @Nullable String url, @NonNull List<GeckoSession.PermissionDelegate.ContentPermission> perms) {
    if (webView != null && webView.channelDelegate != null) {
      webView.channelDelegate.onUpdateVisitedHistory(url, false);
      if (webView.inAppBrowserDelegate != null) {
        webView.inAppBrowserDelegate.didUpdateVisitedHistory(url);
      }
    }
  }

  @Override
  public void onCanGoBack(@NonNull GeckoSession session, boolean canGoBack) {
    this.canGoBack = canGoBack;
  }

  @Override
  public void onCanGoForward(@NonNull GeckoSession session, boolean canGoForward) {
    this.canGoBack = canGoForward;
  }

  @Nullable
  @Override
  public GeckoResult<AllowOrDeny> onLoadRequest(@NonNull GeckoSession session, @NonNull LoadRequest request) {
    return shouldOverrideUrlLoadingCallback(session, request, true);
  }

  @Nullable
  @Override
  public GeckoResult<AllowOrDeny> onSubframeLoadRequest(@NonNull GeckoSession session, @NonNull LoadRequest request) {
    return shouldOverrideUrlLoadingCallback(session, request, false);
  }

  private GeckoResult<AllowOrDeny> shouldOverrideUrlLoadingCallback(@NonNull GeckoSession session, @NonNull LoadRequest loadRequest, boolean isForMainFrame) {
    final GeckoResult<AllowOrDeny> geckoResult = new GeckoResult<>();

    URLRequest request = new URLRequest(loadRequest.uri, "GET", null, null);
    NavigationAction navigationAction = new NavigationAction(
            request,
            isForMainFrame,
            loadRequest.hasUserGesture,
            loadRequest.isRedirect
    );

    final WebViewChannelDelegate.ShouldOverrideUrlLoadingCallback callback = new WebViewChannelDelegate.ShouldOverrideUrlLoadingCallback() {
      @Override
      public boolean nonNullSuccess(@NonNull NavigationActionPolicy result) {
        switch (result) {
          case CANCEL:
            geckoResult.complete(AllowOrDeny.DENY);
            break;
          default:
            geckoResult.complete(AllowOrDeny.ALLOW);
            break;
        }
        return false;
      }

      @Override
      public void defaultBehaviour(@Nullable NavigationActionPolicy result) {
        geckoResult.complete(AllowOrDeny.ALLOW);
      }

      @Override
      public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
        Log.e(LOG_TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
        defaultBehaviour(null);
      }
    };

    if (webView != null && webView.channelDelegate != null && webView.customSettings.useShouldOverrideUrlLoading) {
      webView.channelDelegate.shouldOverrideUrlLoading(navigationAction, callback);
    } else {
      callback.defaultBehaviour(null);
    }

    return geckoResult;
  }

  @Nullable
  @Override
  public GeckoResult<GeckoSession> onNewSession(@NonNull GeckoSession session, @NonNull String uri) {
    return GeckoSession.NavigationDelegate.super.onNewSession(session, uri);
  }

  @Nullable
  @Override
  public GeckoResult<String> onLoadError(@NonNull GeckoSession session, @Nullable String uri, @NonNull WebRequestError error) {
    return GeckoSession.NavigationDelegate.super.onLoadError(session, uri, error);
  }

  @Override
  public void dispose() {
    plugin = null;
    webView = null;
  }
}
