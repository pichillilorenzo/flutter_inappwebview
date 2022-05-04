package com.pichillilorenzo.flutter_inappwebview.in_app_webview;

import android.annotation.TargetApi;
import android.graphics.Bitmap;
import android.net.Uri;
import android.net.http.SslError;
import android.os.Build;
import android.os.Message;
import android.util.Log;
import android.view.KeyEvent;
import android.webkit.ClientCertRequest;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.HttpAuthHandler;
import android.webkit.RenderProcessGoneDetail;
import android.webkit.SafeBrowsingResponse;
import android.webkit.SslErrorHandler;
import android.webkit.ValueCallback;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.webkit.WebResourceRequestCompat;
import androidx.webkit.WebViewFeature;

import com.pichillilorenzo.flutter_inappwebview.Util;
import com.pichillilorenzo.flutter_inappwebview.credential_database.CredentialDatabase;
import com.pichillilorenzo.flutter_inappwebview.in_app_browser.InAppBrowserDelegate;
import com.pichillilorenzo.flutter_inappwebview.plugin_scripts_js.JavaScriptBridgeJS;
import com.pichillilorenzo.flutter_inappwebview.types.ClientCertChallenge;
import com.pichillilorenzo.flutter_inappwebview.types.ClientCertResponse;
import com.pichillilorenzo.flutter_inappwebview.types.CustomSchemeResponse;
import com.pichillilorenzo.flutter_inappwebview.types.HttpAuthResponse;
import com.pichillilorenzo.flutter_inappwebview.types.HttpAuthenticationChallenge;
import com.pichillilorenzo.flutter_inappwebview.types.NavigationAction;
import com.pichillilorenzo.flutter_inappwebview.types.NavigationActionPolicy;
import com.pichillilorenzo.flutter_inappwebview.types.ServerTrustAuthResponse;
import com.pichillilorenzo.flutter_inappwebview.types.ServerTrustChallenge;
import com.pichillilorenzo.flutter_inappwebview.types.URLCredential;
import com.pichillilorenzo.flutter_inappwebview.types.URLProtectionSpace;
import com.pichillilorenzo.flutter_inappwebview.types.URLRequest;
import com.pichillilorenzo.flutter_inappwebview.types.WebResourceErrorExt;
import com.pichillilorenzo.flutter_inappwebview.types.WebResourceRequestExt;
import com.pichillilorenzo.flutter_inappwebview.types.WebResourceResponseExt;

import java.io.ByteArrayInputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;

public class InAppWebViewClient extends WebViewClient {

  protected static final String LOG_TAG = "IAWebViewClient";
  private InAppBrowserDelegate inAppBrowserDelegate;
  private static int previousAuthRequestFailureCount = 0;
  private static List<URLCredential> credentialsProposed = null;

  public InAppWebViewClient(InAppBrowserDelegate inAppBrowserDelegate) {
    super();
    this.inAppBrowserDelegate = inAppBrowserDelegate;
  }

  @TargetApi(Build.VERSION_CODES.LOLLIPOP)
  @Override
  public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
    InAppWebView webView = (InAppWebView) view;
    if (webView.customSettings.useShouldOverrideUrlLoading) {
      boolean isRedirect = false;
      if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_RESOURCE_REQUEST_IS_REDIRECT)) {
        isRedirect = WebResourceRequestCompat.isRedirect(request);
      } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        isRedirect = request.isRedirect();
      }
      onShouldOverrideUrlLoading(
              webView,
              request.getUrl().toString(),
              request.getMethod(),
              request.getRequestHeaders(),
              request.isForMainFrame(),
              request.hasGesture(),
              isRedirect);
      if (webView.regexToCancelSubFramesLoadingCompiled != null) {
        if (request.isForMainFrame())
          return true;
        else {
          Matcher m = webView.regexToCancelSubFramesLoadingCompiled.matcher(request.getUrl().toString());
          return m.matches();
        }
      } else {
        // There isn't any way to load an URL for a frame that is not the main frame,
        // so if the request is not for the main frame, the navigation is allowed.
        return request.isForMainFrame();
      }
    }
    return false;
  }

  @Override
  public boolean shouldOverrideUrlLoading(WebView webView, String url) {
    InAppWebView inAppWebView = (InAppWebView) webView;
    if (inAppWebView.customSettings.useShouldOverrideUrlLoading) {
      onShouldOverrideUrlLoading(inAppWebView, url, "GET", null,true, false, false);
      return true;
    }
    return false;
  }

  private void allowShouldOverrideUrlLoading(WebView webView, String url, Map<String, String> headers, boolean isForMainFrame) {
    if (isForMainFrame) {
      // There isn't any way to load an URL for a frame that is not the main frame,
      // so call this only on main frame.
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
        webView.loadUrl(url, headers);
      else
        webView.loadUrl(url);
    }
  }
  public void onShouldOverrideUrlLoading(final InAppWebView webView, final String url, final String method, final Map<String, String> headers,
                                         final boolean isForMainFrame, boolean hasGesture, boolean isRedirect) {
    URLRequest request = new URLRequest(url, method, null, headers);
    NavigationAction navigationAction = new NavigationAction(
            request,
            isForMainFrame,
            hasGesture,
            isRedirect
    );

    final EventChannelDelegate.ShouldOverrideUrlLoadingCallback callback = new EventChannelDelegate.ShouldOverrideUrlLoadingCallback() {
      @Override
      public boolean nonNullSuccess(@NonNull NavigationActionPolicy result) {
        switch (result) {
          case ALLOW:
            allowShouldOverrideUrlLoading(webView, url, headers, isForMainFrame);
            break;
          case CANCEL:
          default:
            break;
        }
        return false;
      }

      @Override
      public void defaultBehaviour(@Nullable NavigationActionPolicy result) {
        allowShouldOverrideUrlLoading(webView, url, headers, isForMainFrame);
      }

      @Override
      public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
        Log.e(LOG_TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
        defaultBehaviour(null);
      }
    };
    
    if (webView.eventChannelDelegate != null) {
      webView.eventChannelDelegate.shouldOverrideUrlLoading(navigationAction, callback);
    } else {
      callback.defaultBehaviour(null);
    }
  }

  public void loadCustomJavaScriptOnPageStarted(WebView view) {
    InAppWebView webView = (InAppWebView) view;

    String source = webView.userContentController.generateWrappedCodeForDocumentStart();

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      webView.evaluateJavascript(source, (ValueCallback<String>) null);
    } else {
      webView.loadUrl("javascript:" + source.replaceAll("[\r\n]+", ""));
    }
  }

  public void loadCustomJavaScriptOnPageFinished(WebView view) {
    InAppWebView webView = (InAppWebView) view;

    String source = webView.userContentController.generateWrappedCodeForDocumentEnd();

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      webView.evaluateJavascript(source, (ValueCallback<String>) null);
    } else {
      webView.loadUrl("javascript:" + source.replaceAll("[\r\n]+", ""));
    }
  }

  @Override
  public void onPageStarted(WebView view, String url, Bitmap favicon) {
    final InAppWebView webView = (InAppWebView) view;
    webView.isLoading = true;
    webView.disposeWebMessageChannels();
    webView.userContentController.resetContentWorlds();
    loadCustomJavaScriptOnPageStarted(webView);

    super.onPageStarted(view, url, favicon);

    if (inAppBrowserDelegate != null) {
      inAppBrowserDelegate.didStartNavigation(url);
    }

    if (webView.eventChannelDelegate != null) {
      webView.eventChannelDelegate.onLoadStart(url);
    }
  }


  public void onPageFinished(WebView view, String url) {
    final InAppWebView webView = (InAppWebView) view;
    webView.isLoading = false;
    loadCustomJavaScriptOnPageFinished(webView);
    previousAuthRequestFailureCount = 0;
    credentialsProposed = null;

    super.onPageFinished(view, url);

    if (inAppBrowserDelegate != null) {
      inAppBrowserDelegate.didFinishNavigation(url);
    }

    // WebView not storing cookies reliable to local device storage
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      CookieManager.getInstance().flush();
    } else {
      CookieSyncManager.getInstance().sync();
    }

    String js = JavaScriptBridgeJS.PLATFORM_READY_JS_SOURCE;

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      webView.evaluateJavascript(js, (ValueCallback<String>) null);
    } else {
      webView.loadUrl("javascript:" + js.replaceAll("[\r\n]+", ""));
    }

    if (webView.eventChannelDelegate != null) {
      webView.eventChannelDelegate.onLoadStop(url);
    }
  }

  @Override
  public void doUpdateVisitedHistory(WebView view, String url, boolean isReload) {
    super.doUpdateVisitedHistory(view, url, isReload);

    // url argument sometimes doesn't contain the new changed URL, so we get it again from the webview.
    url = view.getUrl();

    if (inAppBrowserDelegate != null) {
      inAppBrowserDelegate.didUpdateVisitedHistory(url);
    }
    
    final InAppWebView webView = (InAppWebView) view;
    if (webView.eventChannelDelegate != null) {
      webView.eventChannelDelegate.onUpdateVisitedHistory(url, isReload);
    }
  }
  
  @RequiresApi(api = Build.VERSION_CODES.M)
  @Override
  public void onReceivedError(WebView view, @NonNull WebResourceRequest request, @NonNull WebResourceError error) {
    final InAppWebView webView = (InAppWebView) view;

    if (request.isForMainFrame()) {
      if (webView.customSettings.disableDefaultErrorPage) {
        webView.stopLoading();
        webView.loadUrl("about:blank");
      }

      webView.isLoading = false;
      previousAuthRequestFailureCount = 0;
      credentialsProposed = null;

      if (inAppBrowserDelegate != null) {
        inAppBrowserDelegate.didFailNavigation(request.getUrl().toString(), error.getErrorCode(), error.getDescription().toString());
      }
    }

    if (webView.eventChannelDelegate != null) {
      webView.eventChannelDelegate.onReceivedError(
              WebResourceRequestExt.fromWebResourceRequest(request),
              WebResourceErrorExt.fromWebResourceError(error));
    }
  }

  @Override
  public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
    final InAppWebView webView = (InAppWebView) view;

    if (webView.customSettings.disableDefaultErrorPage) {
      webView.stopLoading();
      webView.loadUrl("about:blank");
    }

    webView.isLoading = false;
    previousAuthRequestFailureCount = 0;
    credentialsProposed = null;

    if (inAppBrowserDelegate != null) {
      inAppBrowserDelegate.didFailNavigation(failingUrl, errorCode, description);
    }

    WebResourceRequestExt request = new WebResourceRequestExt(
            Uri.parse(failingUrl),
            null,
            false,
            false,
            true,
            "GET");

    WebResourceErrorExt error = new WebResourceErrorExt(
            errorCode,
            description
    );

    if (webView.eventChannelDelegate != null) {
      webView.eventChannelDelegate.onReceivedError(
              request,
              error);
    }

    super.onReceivedError(view, errorCode, description, failingUrl);
  }

  @RequiresApi(api = Build.VERSION_CODES.M)
  @Override
  public void onReceivedHttpError(WebView view, WebResourceRequest request, WebResourceResponse errorResponse) {
    super.onReceivedHttpError(view, request, errorResponse);

    final InAppWebView webView = (InAppWebView) view;
    if (webView.eventChannelDelegate != null) {
      webView.eventChannelDelegate.onReceivedHttpError(
              WebResourceRequestExt.fromWebResourceRequest(request),
              WebResourceResponseExt.fromWebResourceResponse(errorResponse));
    }
  }

  @Override
  public void onReceivedHttpAuthRequest(final WebView view, final HttpAuthHandler handler, final String host, final String realm) {
    URI uri;
    try {
      uri = new URI(view.getUrl());
    } catch (URISyntaxException e) {
      e.printStackTrace();

      credentialsProposed = null;
      previousAuthRequestFailureCount = 0;

      handler.cancel();
      return;
    }

    final String protocol = uri.getScheme();
    final int port = uri.getPort();

    previousAuthRequestFailureCount++;

    if (credentialsProposed == null)
      credentialsProposed = CredentialDatabase.getInstance(view.getContext()).getHttpAuthCredentials(host, protocol, realm, port);

    URLCredential credentialProposed = null;
    if (credentialsProposed != null && credentialsProposed.size() > 0) {
      credentialProposed = credentialsProposed.get(0);
    }

    URLProtectionSpace protectionSpace = new URLProtectionSpace(host, protocol, realm, port, view.getCertificate(), null);
    HttpAuthenticationChallenge challenge = new HttpAuthenticationChallenge(protectionSpace, previousAuthRequestFailureCount, credentialProposed);

    final InAppWebView webView = (InAppWebView) view;
    final EventChannelDelegate.ReceivedHttpAuthRequestCallback callback = new EventChannelDelegate.ReceivedHttpAuthRequestCallback() {
      @Override
      public boolean nonNullSuccess(@NonNull HttpAuthResponse response) {
        Integer action = response.getAction();
        if (action != null) {
          switch (action) {
            case 1:
              String username = response.getUsername();
              String password = response.getPassword();
              boolean permanentPersistence = response.isPermanentPersistence();
              if (permanentPersistence) {
                CredentialDatabase.getInstance(view.getContext())
                        .setHttpAuthCredential(host, protocol, realm, port, username, password);
              }
              handler.proceed(username, password);
              break;
            case 2:
              if (credentialsProposed.size() > 0) {
                URLCredential credential = credentialsProposed.remove(0);
                handler.proceed(credential.getUsername(), credential.getPassword());
              } else {
                handler.cancel();
              }
              // used custom CredentialDatabase!
              // handler.useHttpAuthUsernamePassword();
              break;
            case 0:
            default:
              credentialsProposed = null;
              previousAuthRequestFailureCount = 0;
              handler.cancel();
          }

          return false;
        }

        return true;
      }

      @Override
      public void defaultBehaviour(@Nullable HttpAuthResponse result) {
        InAppWebViewClient.super.onReceivedHttpAuthRequest(view, handler, host, realm);
      }

      @Override
      public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
        Log.e(LOG_TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
        defaultBehaviour(null);
      }
    };
    
    if (webView.eventChannelDelegate != null) {
      webView.eventChannelDelegate.onReceivedHttpAuthRequest(challenge, callback);
    } else {
      callback.defaultBehaviour(null);
    }
  }

  @Override
  public void onReceivedSslError(final WebView view, final SslErrorHandler handler, final SslError sslError) {
    URI uri;
    try {
      uri = new URI(sslError.getUrl());
    } catch (URISyntaxException e) {
      e.printStackTrace();
      handler.cancel();
      return;
    }

    final String host = uri.getHost();
    final String protocol = uri.getScheme();
    final String realm = null;
    final int port = uri.getPort();

    URLProtectionSpace protectionSpace = new URLProtectionSpace(host, protocol, realm, port, sslError.getCertificate(), sslError);
    ServerTrustChallenge challenge = new ServerTrustChallenge(protectionSpace);

    final InAppWebView webView = (InAppWebView) view;
    final EventChannelDelegate.ReceivedServerTrustAuthRequestCallback callback = new EventChannelDelegate.ReceivedServerTrustAuthRequestCallback() {
      @Override
      public boolean nonNullSuccess(@NonNull ServerTrustAuthResponse response) {
        Integer action = response.getAction();
        if (action != null) {
          switch (action) {
            case 1:
              handler.proceed();
              break;
            case 0:
            default:
              handler.cancel();
          }

          return false;
        }

        return true;
      }

      @Override
      public void defaultBehaviour(@Nullable ServerTrustAuthResponse result) {
        InAppWebViewClient.super.onReceivedSslError(view, handler, sslError);
      }

      @Override
      public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
        Log.e(LOG_TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
        defaultBehaviour(null);
      }
    };
    
    if (webView.eventChannelDelegate != null) {
      webView.eventChannelDelegate.onReceivedServerTrustAuthRequest(challenge, callback);
    } else {
      callback.defaultBehaviour(null);
    }
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  @Override
  public void onReceivedClientCertRequest(final WebView view, final ClientCertRequest request) {
    URI uri;
    try {
      uri = new URI(view.getUrl());
    } catch (URISyntaxException e) {
      e.printStackTrace();
      request.cancel();
      return;
    }

    final String host = request.getHost();
    final String protocol = uri.getScheme();
    final String realm = null;
    final int port = request.getPort();

    URLProtectionSpace protectionSpace = new URLProtectionSpace(host, protocol, realm, port, view.getCertificate(), null);
    ClientCertChallenge challenge = new ClientCertChallenge(protectionSpace, request.getPrincipals(), request.getKeyTypes());

    final InAppWebView webView = (InAppWebView) view;
    final EventChannelDelegate.ReceivedClientCertRequestCallback callback = new EventChannelDelegate.ReceivedClientCertRequestCallback() {
      @Override
      public boolean nonNullSuccess(@NonNull ClientCertResponse response) {
        Integer action = response.getAction();
        if (action != null && webView.plugin != null) {
          switch (action) {
            case 1:
              {
                String certificatePath = (String) response.getCertificatePath();
                String certificatePassword = (String) response.getCertificatePassword();
                String keyStoreType = (String) response.getKeyStoreType();
                Util.PrivateKeyAndCertificates privateKeyAndCertificates = 
                        Util.loadPrivateKeyAndCertificate(webView.plugin, certificatePath, certificatePassword, keyStoreType);
                if (privateKeyAndCertificates != null) {
                  request.proceed(privateKeyAndCertificates.privateKey, privateKeyAndCertificates.certificates);
                } else {
                  request.cancel();
                }
              }
              break;
            case 2:
              request.ignore();
              break;
            case 0:
            default:
              request.cancel();
          }

          return false;
        }

        return true;
      }

      @Override
      public void defaultBehaviour(@Nullable ClientCertResponse result) {
        InAppWebViewClient.super.onReceivedClientCertRequest(view, request);
      }

      @Override
      public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
        Log.e(LOG_TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
        defaultBehaviour(null);
      }
    };

    if (webView.eventChannelDelegate != null) {
      webView.eventChannelDelegate.onReceivedClientCertRequest(challenge, callback);
    } else {
      callback.defaultBehaviour(null);
    }
  }

  @Override
  public void onScaleChanged(WebView view, float oldScale, float newScale) {
    super.onScaleChanged(view, oldScale, newScale);
    final InAppWebView webView = (InAppWebView) view;
    webView.zoomScale = newScale / Util.getPixelDensity(webView.getContext());

    if (webView.eventChannelDelegate != null) {
      webView.eventChannelDelegate.onZoomScaleChanged(oldScale, newScale);
    }
  }

  @RequiresApi(api = Build.VERSION_CODES.O_MR1)
  @Override
  public void onSafeBrowsingHit(final WebView view, final WebResourceRequest request, final int threatType, final SafeBrowsingResponse callback) {
    final InAppWebView webView = (InAppWebView) view;
    final EventChannelDelegate.SafeBrowsingHitCallback resultCallback = new EventChannelDelegate.SafeBrowsingHitCallback() {
      @Override
      public boolean nonNullSuccess(@NonNull com.pichillilorenzo.flutter_inappwebview.types.SafeBrowsingResponse response) {
        Integer action = response.getAction();
        if (action != null) {
          boolean report = response.isReport();
          switch (action) {
            case 0:
              callback.backToSafety(report);
              break;
            case 1:
              callback.proceed(report);
              break;
            case 2:
            default:
              callback.showInterstitial(report);
          }

          return false;
        }

        return true;
      }

      @Override
      public void defaultBehaviour(@Nullable com.pichillilorenzo.flutter_inappwebview.types.SafeBrowsingResponse result) {
        InAppWebViewClient.super.onSafeBrowsingHit(view, request, threatType, callback);
      }

      @Override
      public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
        Log.e(LOG_TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
        defaultBehaviour(null);
      }
    };

    if (webView.eventChannelDelegate != null) {
      webView.eventChannelDelegate.onSafeBrowsingHit(request.getUrl().toString(), threatType, resultCallback);
    } else {
      resultCallback.defaultBehaviour(null);
    }
  }

  @Override
  public WebResourceResponse shouldInterceptRequest(WebView view, final String url) {
    final InAppWebView webView = (InAppWebView) view;

    if (webView.customSettings.useShouldInterceptRequest) {
      return onShouldInterceptRequest(view, url);
    }

    URI uri;
    try {
      uri = new URI(url);
    } catch (URISyntaxException uriExpection) {
      String[] urlSplitted = url.split(":");
      String scheme = urlSplitted[0];
      try {
        URL tempUrl = new URL(url.replace(scheme, "https"));
        uri = new URI(scheme, tempUrl.getUserInfo(), tempUrl.getHost(), tempUrl.getPort(), tempUrl.getPath(), tempUrl.getQuery(), tempUrl.getRef());
      } catch (Exception e) {
        e.printStackTrace();
        return null;
      }
    }

    String scheme = uri.getScheme();

    if (webView.customSettings.resourceCustomSchemes != null && webView.customSettings.resourceCustomSchemes.contains(scheme)) {
      CustomSchemeResponse customSchemeResponse = null;
      if (webView.eventChannelDelegate != null) {
        try {
          customSchemeResponse = webView.eventChannelDelegate.onLoadResourceCustomScheme(url);
        } catch (InterruptedException e) {
          e.printStackTrace();
          return null;
        }
      }

      if (customSchemeResponse != null) {
        WebResourceResponse response = null;
        try {
          response = webView.contentBlockerHandler.checkUrl(webView, url, customSchemeResponse.getContentType());
        } catch (Exception e) {
          e.printStackTrace();
        }
        if (response != null)
          return response;
        return new WebResourceResponse(customSchemeResponse.getContentType(), 
                customSchemeResponse.getContentType(), 
                new ByteArrayInputStream(customSchemeResponse.getData()));
      }
    }

    WebResourceResponse response = null;
    if (webView.contentBlockerHandler.getRuleList().size() > 0) {
      try {
        response = webView.contentBlockerHandler.checkUrl(webView, url);
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
    return response;
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  @Override
  public WebResourceResponse shouldInterceptRequest(WebView view, WebResourceRequest request) {
    final InAppWebView webView = (InAppWebView) view;

    String url = request.getUrl().toString();

    if (webView.customSettings.useShouldInterceptRequest) {
      return onShouldInterceptRequest(view, request);
    }

    return shouldInterceptRequest(view, url);
  }

  public WebResourceResponse onShouldInterceptRequest(WebView view, Object request) {
    final InAppWebView webView = (InAppWebView) view;
    
    WebResourceRequestExt requestExt;
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && request instanceof WebResourceRequest) {
      WebResourceRequest webResourceRequest = (WebResourceRequest) request;
      requestExt = WebResourceRequestExt.fromWebResourceRequest(webResourceRequest);
    } else {
      requestExt = new WebResourceRequestExt(
              Uri.parse((String) request), null, false,
              false, true, "GET"
      );
    }

    WebResourceResponseExt response = null;
    if (webView.eventChannelDelegate != null) {
      try {
        response = webView.eventChannelDelegate.shouldInterceptRequest(requestExt);
      } catch (InterruptedException e) {
        e.printStackTrace();
        return null;
      }
    }

    if (response != null) {
      String contentType = response.getContentType();
      String contentEncoding = response.getContentEncoding();
      byte[] data = response.getData();
      Map<String, String> responseHeaders = response.getHeaders();
      Integer statusCode = response.getStatusCode();
      String reasonPhrase = response.getReasonPhrase();

      ByteArrayInputStream inputStream = (data != null) ? new ByteArrayInputStream(data) : null;
      
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && statusCode != null && reasonPhrase != null) {
        return new WebResourceResponse(contentType, contentEncoding, statusCode, reasonPhrase, responseHeaders, inputStream);
      } else {
        return new WebResourceResponse(contentType, contentEncoding, inputStream);
      }
    }

    return null;
  }

  @Override
  public void onFormResubmission(final WebView view, final Message dontResend, final Message resend) {
    final InAppWebView webView = (InAppWebView) view;
    final EventChannelDelegate.FormResubmissionCallback callback = new EventChannelDelegate.FormResubmissionCallback() {
      @Override
      public boolean nonNullSuccess(@NonNull Integer action) {
        switch (action) {
          case 0:
            resend.sendToTarget();
            break;
          case 1:
          default:
            dontResend.sendToTarget();
        }
        return false;
      }

      @Override
      public void defaultBehaviour(@Nullable Integer result) {
        InAppWebViewClient.super.onFormResubmission(view, dontResend, resend);
      }

      @Override
      public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
        Log.e(LOG_TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
        defaultBehaviour(null);
      }
    };

    if (webView.eventChannelDelegate != null) {
      webView.eventChannelDelegate.onFormResubmission(webView.getUrl(), callback);
    } else {
      callback.defaultBehaviour(null);
    }
  }

  @Override
  public void onPageCommitVisible(WebView view, String url) {
    super.onPageCommitVisible(view, url);

    final InAppWebView webView = (InAppWebView) view;
    if (webView.eventChannelDelegate != null) {
      webView.eventChannelDelegate.onPageCommitVisible(url);
    }
  }

  @RequiresApi(api = Build.VERSION_CODES.O)
  @Override
  public boolean onRenderProcessGone(WebView view, RenderProcessGoneDetail detail) {
    final InAppWebView webView = (InAppWebView) view;

    if (webView.customSettings.useOnRenderProcessGone && webView.eventChannelDelegate != null) {
      boolean didCrash = detail.didCrash();
      int rendererPriorityAtExit = detail.rendererPriorityAtExit();
      webView.eventChannelDelegate.onRenderProcessGone(didCrash, rendererPriorityAtExit);
      return true;
    }

    return super.onRenderProcessGone(view, detail);
  }

  @Override
  public void onReceivedLoginRequest(WebView view, String realm, String account, String args) {
    final InAppWebView webView = (InAppWebView) view;
    if (webView.eventChannelDelegate != null) {
      webView.eventChannelDelegate.onReceivedLoginRequest(realm, account, args);
    }
  }

  @Override
  public void onUnhandledKeyEvent(WebView view, KeyEvent event) {}

  public void dispose() {
    if (inAppBrowserDelegate != null) {
      inAppBrowserDelegate = null;
    }
  }
}
