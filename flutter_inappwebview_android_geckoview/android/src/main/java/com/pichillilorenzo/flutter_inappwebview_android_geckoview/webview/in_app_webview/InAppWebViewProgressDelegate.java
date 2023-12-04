package com.pichillilorenzo.flutter_inappwebview_android_geckoview.webview.in_app_webview;

import android.net.http.SslCertificate;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview_android_geckoview.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.types.Disposable;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.types.HitTestResult;

import org.mozilla.geckoview.GeckoSession;

public class InAppWebViewProgressDelegate implements GeckoSession.ProgressDelegate, Disposable {
  @Nullable
  public InAppWebViewFlutterPlugin plugin;
  @Nullable
  public InAppWebView webView;

  public int progress = 0;

  public boolean isLoading = false;

  @Nullable
  public String currentUrl;

  @Nullable
  public String currentOriginalUrl;

  @Nullable
  public SslCertificate certificate;

  public boolean secureContext = false;

  InAppWebViewProgressDelegate(@NonNull final InAppWebViewFlutterPlugin plugin, @NonNull InAppWebView webView) {
    this.plugin = plugin;
    this.webView = webView;
  }

  @Override
  public void onPageStart(@NonNull GeckoSession session, @NonNull String url) {
    isLoading = true;
    currentUrl = url;
    currentOriginalUrl = url;
    if (webView != null && webView.channelDelegate != null) {
      webView.channelDelegate.onLoadStart(url);
      if (webView.inAppBrowserDelegate != null) {
        webView.inAppBrowserDelegate.didStartNavigation(url);
      }
    }
  }

  @Override
  public void onPageStop(@NonNull GeckoSession session, boolean success) {
    isLoading = false;
    if (webView != null && webView.channelDelegate != null) {
      webView.channelDelegate.onLoadStop(currentUrl);
      if (webView.inAppBrowserDelegate != null) {
        webView.inAppBrowserDelegate.didFinishNavigation(currentUrl);
      }
    }
  }

  @Override
  public void onProgressChange(@NonNull GeckoSession session, int progress) {
    if (webView != null && webView.channelDelegate != null) {
      webView.channelDelegate.onProgressChanged(progress);
      if (webView.inAppBrowserDelegate != null) {
        webView.inAppBrowserDelegate.didChangeProgress(progress);
      }
    }
  }

  @Override
  public void onSecurityChange(@NonNull GeckoSession session, @NonNull SecurityInformation securityInfo) {
    certificate = securityInfo.certificate != null ? new SslCertificate(securityInfo.certificate) : null;
    secureContext = securityInfo.isSecure;
  }

  @Override
  public void onSessionStateChange(@NonNull GeckoSession session, @NonNull GeckoSession.SessionState sessionState) {
    GeckoSession.ProgressDelegate.super.onSessionStateChange(session, sessionState);
  }

  @Override
  public void dispose() {
    plugin = null;
    webView = null;
  }
}
