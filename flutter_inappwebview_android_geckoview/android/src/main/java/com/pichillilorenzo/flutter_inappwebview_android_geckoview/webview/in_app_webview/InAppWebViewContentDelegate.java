package com.pichillilorenzo.flutter_inappwebview_android_geckoview.webview.in_app_webview;

import android.view.PointerIcon;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview_android_geckoview.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.types.Disposable;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.types.HitTestResult;

import org.json.JSONObject;
import org.mozilla.geckoview.GeckoResult;
import org.mozilla.geckoview.GeckoSession;
import org.mozilla.geckoview.SlowScriptResponse;
import org.mozilla.geckoview.WebResponse;

public class InAppWebViewContentDelegate implements GeckoSession.ContentDelegate, Disposable {
  @Nullable
  public InAppWebViewFlutterPlugin plugin;
  @Nullable
  public InAppWebView webView;

  @Nullable
  public String currentTitle;

  @Nullable
  public ContextElement lastContextElement;

  InAppWebViewContentDelegate(@NonNull final InAppWebViewFlutterPlugin plugin, @NonNull InAppWebView webView) {
    this.plugin = plugin;
    this.webView = webView;
  }

  @Override
  public void onTitleChange(@NonNull GeckoSession session, @Nullable String title) {
    currentTitle = title;
    if (webView != null && webView.inAppBrowserDelegate != null) {
      webView.inAppBrowserDelegate.didChangeTitle(title);
    }
  }

  @Override
  public void onPreviewImage(@NonNull GeckoSession session, @NonNull String previewImageUrl) {
    GeckoSession.ContentDelegate.super.onPreviewImage(session, previewImageUrl);
  }

  @Override
  public void onFocusRequest(@NonNull GeckoSession session) {
    if (webView != null && webView.channelDelegate != null) {
      webView.channelDelegate.onRequestFocus();
    }
  }

  @Override
  public void onCloseRequest(@NonNull GeckoSession session) {
    if (webView != null && webView.channelDelegate != null) {
      webView.channelDelegate.onCloseWindow();
    }
  }

  @Override
  public void onFullScreen(@NonNull GeckoSession session, boolean fullScreen) {
    if (webView != null && webView.channelDelegate != null) {
      if (fullScreen) {
        webView.channelDelegate.onEnterFullscreen();
      } else {
        webView.channelDelegate.onExitFullscreen();
      }
    }
  }

  @Override
  public void onMetaViewportFitChange(@NonNull GeckoSession session, @NonNull String viewportFit) {
    GeckoSession.ContentDelegate.super.onMetaViewportFitChange(session, viewportFit);
  }

  @Override
  public void onProductUrl(@NonNull GeckoSession session) {
    GeckoSession.ContentDelegate.super.onProductUrl(session);
  }

  @Override
  public void onContextMenu(@NonNull GeckoSession session, int screenX, int screenY, @NonNull ContextElement element) {
    lastContextElement = element;
    if (webView != null && webView.channelDelegate != null) {
      webView.channelDelegate.onCreateContextMenu(HitTestResult.fromContextElement(element));
    }
  }

  @Override
  public void onExternalResponse(@NonNull GeckoSession session, @NonNull WebResponse response) {
    GeckoSession.ContentDelegate.super.onExternalResponse(session, response);
  }

  @Override
  public void onCrash(@NonNull GeckoSession session) {
    GeckoSession.ContentDelegate.super.onCrash(session);
  }

  @Override
  public void onKill(@NonNull GeckoSession session) {
    GeckoSession.ContentDelegate.super.onKill(session);
  }

  @Override
  public void onFirstComposite(@NonNull GeckoSession session) {
    GeckoSession.ContentDelegate.super.onFirstComposite(session);
  }

  @Override
  public void onFirstContentfulPaint(@NonNull GeckoSession session) {
    GeckoSession.ContentDelegate.super.onFirstContentfulPaint(session);
  }

  @Override
  public void onPaintStatusReset(@NonNull GeckoSession session) {
    GeckoSession.ContentDelegate.super.onPaintStatusReset(session);
  }

  @Override
  public void onPointerIconChange(@NonNull GeckoSession session, @NonNull PointerIcon icon) {
    GeckoSession.ContentDelegate.super.onPointerIconChange(session, icon);
  }

  @Override
  public void onWebAppManifest(@NonNull GeckoSession session, @NonNull JSONObject manifest) {
    GeckoSession.ContentDelegate.super.onWebAppManifest(session, manifest);
  }

  @Nullable
  @Override
  public GeckoResult<SlowScriptResponse> onSlowScript(@NonNull GeckoSession geckoSession, @NonNull String scriptFileName) {
    return GeckoSession.ContentDelegate.super.onSlowScript(geckoSession, scriptFileName);
  }

  @Override
  public void onShowDynamicToolbar(@NonNull GeckoSession geckoSession) {
    GeckoSession.ContentDelegate.super.onShowDynamicToolbar(geckoSession);
  }

  @Override
  public void onCookieBannerDetected(@NonNull GeckoSession session) {
    GeckoSession.ContentDelegate.super.onCookieBannerDetected(session);
  }

  @Override
  public void onCookieBannerHandled(@NonNull GeckoSession session) {
    GeckoSession.ContentDelegate.super.onCookieBannerHandled(session);
  }

  @Override
  public void dispose() {
    plugin = null;
    webView = null;
    lastContextElement = null;
  }
}
