package com.pichillilorenzo.flutter_inappwebview.in_app_geckoview;

import android.util.Log;
import android.view.PointerIcon;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview.in_app_browser.InAppBrowserDelegate;

import org.json.JSONObject;
import org.mozilla.geckoview.GeckoResult;
import org.mozilla.geckoview.GeckoSession;
import org.mozilla.geckoview.SlowScriptResponse;
import org.mozilla.geckoview.WebResponse;

import io.flutter.plugin.common.MethodChannel;

public class InAppGeckoViewContentDelegate implements GeckoSession.ContentDelegate {

  protected static final String LOG_TAG = "IAGeckoViewContDelegate";
  private InAppBrowserDelegate inAppBrowserDelegate;
  private final MethodChannel channel;
  @Nullable
  private InAppGeckoView inAppGeckoView;

  public InAppGeckoViewContentDelegate(@NonNull InAppGeckoView inAppGeckoView, MethodChannel channel, InAppBrowserDelegate inAppBrowserDelegate) {
    super();

    this.inAppGeckoView = inAppGeckoView;
    this.channel = channel;
    this.inAppBrowserDelegate = inAppBrowserDelegate;
  }

  @Override
  public void onTitleChange(@NonNull GeckoSession session, @Nullable String title) {
    // TODO: implement
    if (inAppGeckoView != null) {
      inAppGeckoView.currentTitle = title;
    }
  }

  @Override
  public void onFocusRequest(@NonNull GeckoSession session) {
    // TODO: implement
  }

  @Override
  public void onCloseRequest(@NonNull GeckoSession session) {
    // TODO: implement
  }

  @Override
  public void onFullScreen(@NonNull GeckoSession session, boolean fullScreen) {
    // TODO: implement
  }

  @Override
  public void onMetaViewportFitChange(@NonNull GeckoSession session, @NonNull String viewportFit) {
    // TODO: implement
  }

  @Override
  public void onContextMenu(@NonNull GeckoSession session, int screenX, int screenY, @NonNull ContextElement element) {
    // TODO: implement
  }

  @Override
  public void onExternalResponse(@NonNull GeckoSession session, @NonNull WebResponse response) {
    // TODO: implement
  }

  @Override
  public void onCrash(@NonNull GeckoSession session) {
    // TODO: implement
  }

  @Override
  public void onKill(@NonNull GeckoSession session) {
    // TODO: implement
  }

  @Override
  public void onFirstComposite(@NonNull GeckoSession session) {
    // TODO: implement
  }

  @Override
  public void onFirstContentfulPaint(@NonNull GeckoSession session) {
    // TODO: implement
  }

  @Override
  public void onPaintStatusReset(@NonNull GeckoSession session) {
    // TODO: implement
  }

  @Override
  public void onWebAppManifest(@NonNull GeckoSession session, @NonNull JSONObject manifest) {
    // TODO: implement
  }

  @Nullable
  @Override
  public GeckoResult<SlowScriptResponse> onSlowScript(@NonNull GeckoSession geckoSession, @NonNull String scriptFileName) {
    // TODO: implement
    return null;
  }

  @Override
  public void onPreviewImage(@NonNull GeckoSession session, @NonNull String previewImageUrl) {
    // TODO: implement
  }

  @Override
  public void onPointerIconChange(@NonNull GeckoSession session, @NonNull PointerIcon icon) {
    // TODO: implement
  }

  @Override
  public void onShowDynamicToolbar(@NonNull GeckoSession geckoSession) {
    // TODO: implement
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
