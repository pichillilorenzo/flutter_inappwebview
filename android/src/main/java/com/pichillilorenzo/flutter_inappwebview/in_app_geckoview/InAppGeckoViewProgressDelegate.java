package com.pichillilorenzo.flutter_inappwebview.in_app_geckoview;

import android.net.http.SslCertificate;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview.in_app_browser.InAppBrowserDelegate;
import com.pichillilorenzo.flutter_inappwebview.types.URLCredential;

import org.mozilla.geckoview.GeckoSession;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class InAppGeckoViewProgressDelegate implements GeckoSession.ProgressDelegate {

  protected static final String LOG_TAG = "IAGeckoViewProgressDelegate";
  private InAppBrowserDelegate inAppBrowserDelegate;
  private final MethodChannel channel;
  @Nullable
  private InAppGeckoView inAppGeckoView;

  public InAppGeckoViewProgressDelegate(@NonNull InAppGeckoView inAppGeckoView, MethodChannel channel, InAppBrowserDelegate inAppBrowserDelegate) {
    super();

    this.inAppGeckoView = inAppGeckoView;
    this.channel = channel;
    this.inAppBrowserDelegate = inAppBrowserDelegate;
  }

  @Override
  public void onPageStart(@NonNull GeckoSession session, @NonNull String url) {
    if (inAppGeckoView != null) {
      inAppGeckoView.lastSearchString = null;
      inAppGeckoView.isLoading = true;
      inAppGeckoView.currentUrl = url;
      inAppGeckoView.currentOriginalUrl = url;
      inAppGeckoView.lastTouchPoint = null;
      inAppGeckoView.disposeWebMessageChannels();
      inAppGeckoView.userContentController.resetContentWorlds();
    }

    if (inAppBrowserDelegate != null) {
      inAppBrowserDelegate.didStartNavigation(url);
    }
    
    Map<String, Object> obj = new HashMap<>();
    obj.put("url", url);
    channel.invokeMethod("onLoadStart", obj);
  }

  @Override
  public void onPageStop(@NonNull GeckoSession session, boolean success) {
    if (inAppGeckoView != null) {
      inAppGeckoView.isLoading = false;

      String url = inAppGeckoView.getUrl();

      if (inAppBrowserDelegate != null) {
        inAppBrowserDelegate.didFinishNavigation(url);
      }
      
      Map<String, Object> obj = new HashMap<>();
      obj.put("url", url);
      channel.invokeMethod("onLoadStop", obj);
    }
  }

  @Override
  public void onProgressChange(@NonNull GeckoSession session, int progress) {
    if (inAppBrowserDelegate != null) {
      inAppBrowserDelegate.didChangeProgress(progress);
    }

    if (inAppGeckoView != null) {
      inAppGeckoView.progress = progress;
    }

    Map<String, Object> obj = new HashMap<>();
    obj.put("progress", progress);
    channel.invokeMethod("onProgressChanged", obj);
  }

  @Override
  public void onSecurityChange(@NonNull GeckoSession session, @NonNull SecurityInformation securityInfo) {
    // TODO: implement onSecurityChange event on Flutter side
    if (inAppGeckoView != null) {
      inAppGeckoView.sslCertificate = securityInfo.certificate != null ? new SslCertificate(securityInfo.certificate) : null;
      inAppGeckoView.secureContext = securityInfo.isSecure; 
    }
  }

  @Override
  public void onSessionStateChange(@NonNull GeckoSession session, @NonNull GeckoSession.SessionState sessionState) {
    // TODO: use sessionState to get the History
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
