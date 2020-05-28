package com.pichillilorenzo.flutter_inappwebview.InAppWebView;

import android.annotation.TargetApi;
import android.graphics.Bitmap;
import android.net.http.SslCertificate;
import android.net.http.SslError;
import android.os.Build;
import android.os.Bundle;
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
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import com.pichillilorenzo.flutter_inappwebview.CredentialDatabase.Credential;
import com.pichillilorenzo.flutter_inappwebview.CredentialDatabase.CredentialDatabase;
import com.pichillilorenzo.flutter_inappwebview.InAppBrowser.InAppBrowserActivity;
import com.pichillilorenzo.flutter_inappwebview.JavaScriptBridgeInterface;
import com.pichillilorenzo.flutter_inappwebview.Util;

import java.io.ByteArrayInputStream;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.security.cert.Certificate;
import java.security.cert.CertificateEncodingException;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;

import io.flutter.plugin.common.MethodChannel;

public class InAppWebViewClient extends WebViewClient {

  protected static final String LOG_TAG = "IAWebViewClient";
  private FlutterWebView flutterWebView;
  private InAppBrowserActivity inAppBrowserActivity;
  public MethodChannel channel;
  private static int previousAuthRequestFailureCount = 0;
  private static List<Credential> credentialsProposed = null;

  public InAppWebViewClient(Object obj) {
    super();
    if (obj instanceof InAppBrowserActivity)
      this.inAppBrowserActivity = (InAppBrowserActivity) obj;
    else if (obj instanceof FlutterWebView)
      this.flutterWebView = (FlutterWebView) obj;
    this.channel = (this.inAppBrowserActivity != null) ? this.inAppBrowserActivity.channel : this.flutterWebView.channel;
  }

  @TargetApi(Build.VERSION_CODES.LOLLIPOP)
  @Override
  public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
    InAppWebView webView = (InAppWebView) view;
    if (webView.options.useShouldOverrideUrlLoading) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        onShouldOverrideUrlLoading(
                request.getUrl().toString(),
                request.getMethod(),
                request.getRequestHeaders(),
                request.isForMainFrame(),
                request.hasGesture(),
                request.isRedirect());
      } else {
        onShouldOverrideUrlLoading(
                request.getUrl().toString(),
                request.getMethod(),
                request.getRequestHeaders(),
                request.isForMainFrame(),
                request.hasGesture(),
                false);
      }
      if (webView.regexToCancelSubFramesLoadingCompiled != null) {
        if (request.isForMainFrame())
          return true;
        else {
          Matcher m = webView.regexToCancelSubFramesLoadingCompiled.matcher(request.getUrl().toString());
          if (m.matches())
            return true;
          else
            return false;
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
    if (((inAppBrowserActivity != null) ? inAppBrowserActivity.webView : flutterWebView.webView).options.useShouldOverrideUrlLoading) {
      onShouldOverrideUrlLoading(url, "GET", null,true, false, false);
      return true;
    }
    return false;
  }

  public void onShouldOverrideUrlLoading(final String url, final String method, final Map<String, String> headers, final boolean isForMainFrame, boolean hasGesture, boolean isRedirect) {
    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("url", url);
    obj.put("method", method);
    obj.put("headers", headers);
    obj.put("isForMainFrame", isForMainFrame);
    obj.put("androidHasGesture", hasGesture);
    obj.put("androidIsRedirect", isRedirect);
    obj.put("iosWKNavigationType", null);
    channel.invokeMethod("shouldOverrideUrlLoading", obj, new MethodChannel.Result() {
      @Override
      public void success(Object response) {
        if (response != null) {
          Map<String, Object> responseMap = (Map<String, Object>) response;
          Integer action = (Integer) responseMap.get("action");
          if (action != null) {
            switch (action) {
              case 1:
                if (isForMainFrame) {
                  // There isn't any way to load an URL for a frame that is not the main frame,
                  // so call this only on main frame.
                  InAppWebView webView = ((inAppBrowserActivity != null) ? inAppBrowserActivity.webView : flutterWebView.webView);
                  if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
                    webView.loadUrl(url, headers);
                  else
                    webView.loadUrl(url);
                }
                return;
              case 0:
              default:
                return;
            }
          }
        }
      }

      @Override
      public void error(String s, String s1, Object o) {
        Log.d(LOG_TAG, "ERROR: " + s + " " + s1);
      }

      @Override
      public void notImplemented() {

      }
    });
  }

  @Override
  public void onPageStarted(WebView view, String url, Bitmap favicon) {

    InAppWebView webView = (InAppWebView) view;

    String js = InAppWebView.consoleLogJS.replaceAll("[\r\n]+", "");
    js += JavaScriptBridgeInterface.flutterInAppBroserJSClass.replaceAll("[\r\n]+", "");
    if (webView.options.useShouldInterceptAjaxRequest) {
      js += InAppWebView.interceptAjaxRequestsJS.replaceAll("[\r\n]+", "");
    }
    if (webView.options.useShouldInterceptFetchRequest) {
      js += InAppWebView.interceptFetchRequestsJS.replaceAll("[\r\n]+", "");
    }
    if (webView.options.useOnLoadResource) {
      js += InAppWebView.resourceObserverJS.replaceAll("[\r\n]+", "");
    }
    js += InAppWebView.checkGlobalKeyDownEventToHideContextMenuJS.replaceAll("[\r\n]+", "");
    if (flutterWebView != null) {
      js += InAppWebView.androidKeyboardWorkaroundFocusoutEventJS.replaceAll("[\r\n]+", "");
    }
    js += InAppWebView.printJS.replaceAll("[\r\n]+", "");

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      webView.evaluateJavascript(js, (ValueCallback<String>) null);
    } else {
      webView.loadUrl("javascript:" + js);
    }

    super.onPageStarted(view, url, favicon);

    webView.isLoading = true;
    if (inAppBrowserActivity != null && inAppBrowserActivity.searchView != null && !url.equals(inAppBrowserActivity.searchView.getQuery().toString())) {
      inAppBrowserActivity.searchView.setQuery(url, false);
    }

    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("url", url);
    channel.invokeMethod("onLoadStart", obj);
  }


  public void onPageFinished(WebView view, String url) {
    final InAppWebView webView = (InAppWebView) view;

    super.onPageFinished(view, url);

    webView.isLoading = false;
    previousAuthRequestFailureCount = 0;
    credentialsProposed = null;

    // CB-10395 InAppBrowserManager's WebView not storing cookies reliable to local device storage
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      CookieManager.getInstance().flush();
    } else {
      CookieSyncManager.getInstance().sync();
    }

    // https://issues.apache.org/jira/browse/CB-11248
    view.clearFocus();
    view.requestFocus();

    String js = InAppWebView.platformReadyJS.replaceAll("[\r\n]+", "");

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      webView.evaluateJavascript(js, (ValueCallback<String>) null);
    } else {
      webView.loadUrl("javascript:" + js);
    }

    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("url", url);
    channel.invokeMethod("onLoadStop", obj);
  }

  @Override
  public void doUpdateVisitedHistory (WebView view, String url, boolean isReload) {
    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("url", url);
    obj.put("androidIsReload", isReload);
    channel.invokeMethod("onUpdateVisitedHistory", obj);

    super.doUpdateVisitedHistory(view, url, isReload);
  }

  @Override
  public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
    super.onReceivedError(view, errorCode, description, failingUrl);

    ((inAppBrowserActivity != null) ? inAppBrowserActivity.webView : flutterWebView.webView).isLoading = false;
    previousAuthRequestFailureCount = 0;
    credentialsProposed = null;

    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("url", failingUrl);
    obj.put("code", errorCode);
    obj.put("message", description);
    channel.invokeMethod("onLoadError", obj);
  }

  @RequiresApi(api = Build.VERSION_CODES.M)
  @Override
  public void onReceivedHttpError (WebView view, WebResourceRequest request, WebResourceResponse errorResponse) {
    super.onReceivedHttpError(view, request, errorResponse);
    if(request.isForMainFrame()) {
      Map<String, Object> obj = new HashMap<>();
      if (inAppBrowserActivity != null)
        obj.put("uuid", inAppBrowserActivity.uuid);
      obj.put("url", request.getUrl().toString());
      obj.put("statusCode", errorResponse.getStatusCode());
      obj.put("description", errorResponse.getReasonPhrase());
      channel.invokeMethod("onLoadHttpError", obj);
    }
  }

  /**
   * On received http auth request.
   */
  @Override
  public void onReceivedHttpAuthRequest(final WebView view, final HttpAuthHandler handler, final String host, final String realm) {

    URL url;
    try {
      url = new URL(view.getUrl());
    } catch (MalformedURLException e) {
      e.printStackTrace();
      Log.e(LOG_TAG, e.getMessage());

      credentialsProposed = null;
      previousAuthRequestFailureCount = 0;

      handler.cancel();
      return;
    }

    final String protocol = url.getProtocol();
    final int port = url.getPort();

    previousAuthRequestFailureCount++;

    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("host", host);
    obj.put("protocol", protocol);
    obj.put("realm", realm);
    obj.put("port", port);
    obj.put("previousFailureCount", previousAuthRequestFailureCount);

    channel.invokeMethod("onReceivedHttpAuthRequest", obj, new MethodChannel.Result() {
      @Override
      public void success(Object response) {
        if (response != null) {
          Map<String, Object> responseMap = (Map<String, Object>) response;
          Integer action = (Integer) responseMap.get("action");
          if (action != null) {
            switch (action) {
              case 1:
                String username = (String) responseMap.get("username");
                String password = (String) responseMap.get("password");
                Boolean permanentPersistence = (Boolean) responseMap.get("permanentPersistence");
                if (permanentPersistence != null && permanentPersistence && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                  CredentialDatabase.getInstance(view.getContext()).setHttpAuthCredential(host, protocol, realm, port, username, password);
                }
                handler.proceed(username, password);
                return;
              case 2:
                if (credentialsProposed == null)
                  credentialsProposed = CredentialDatabase.getInstance(view.getContext()).getHttpAuthCredentials(host, protocol, realm, port);
                if (credentialsProposed.size() > 0) {
                  Credential credential = credentialsProposed.remove(0);
                  handler.proceed(credential.username, credential.password);
                } else {
                  handler.cancel();
                }
                // used custom CredentialDatabase!
                // handler.useHttpAuthUsernamePassword();
                return;
              case 0:
              default:
                credentialsProposed = null;
                previousAuthRequestFailureCount = 0;
                handler.cancel();
                return;
            }
          }
        }

        InAppWebViewClient.super.onReceivedHttpAuthRequest(view, handler, host, realm);
      }

      @Override
      public void error(String s, String s1, Object o) {
        Log.e(LOG_TAG, s + ", " + s1);
      }

      @Override
      public void notImplemented() {
        InAppWebViewClient.super.onReceivedHttpAuthRequest(view, handler, host, realm);
      }
    });
  }

  /**
   * SslCertificate class does not has a public getter for the underlying
   * X509Certificate, we can only do this by hack. This only works for andorid 4.0+
   * https://groups.google.com/forum/#!topic/android-developers/eAPJ6b7mrmg
   */
  public static X509Certificate getX509CertFromSslCertHack(SslCertificate sslCert) {
    X509Certificate x509Certificate = null;

    Bundle bundle = SslCertificate.saveState(sslCert);
    byte[] bytes = bundle.getByteArray("x509-certificate");

    if (bytes == null) {
      x509Certificate = null;
    } else {
      try {
        CertificateFactory certFactory = CertificateFactory.getInstance("X.509");
        Certificate cert = certFactory.generateCertificate(new ByteArrayInputStream(bytes));
        x509Certificate = (X509Certificate) cert;
      } catch (CertificateException e) {
        x509Certificate = null;
      }
    }

    return x509Certificate;
  }

  @Override
  public void onReceivedSslError(final WebView view, final SslErrorHandler handler, final SslError error) {
    URL url;
    try {
      url = new URL(error.getUrl());
    } catch (MalformedURLException e) {
      e.printStackTrace();
      Log.e(LOG_TAG, e.getMessage());
      handler.cancel();
      return;
    }

    final String host = url.getHost();
    final String protocol = url.getProtocol();
    final String realm = null;
    final int port = url.getPort();

    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("host", host);
    obj.put("protocol", protocol);
    obj.put("realm", realm);
    obj.put("port", port);
    obj.put("error", error.getPrimaryError());
    obj.put("serverCertificate", null);
    try {
      X509Certificate certificate;
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        certificate = error.getCertificate().getX509Certificate();
      } else {
        certificate = getX509CertFromSslCertHack(error.getCertificate());
      }
      obj.put("serverCertificate", certificate.getEncoded());
    } catch (CertificateEncodingException e) {
      e.printStackTrace();
      Log.e(LOG_TAG,e.getLocalizedMessage());
    }

    String message;
    switch (error.getPrimaryError()) {
      case SslError.SSL_DATE_INVALID:
        message = "The date of the certificate is invalid";
        break;
      case SslError.SSL_EXPIRED:
        message = "The certificate has expired";
        break;
      case SslError.SSL_IDMISMATCH:
        message = "Hostname mismatch";
        break;
      default:
      case SslError.SSL_INVALID:
        message = "A generic error occurred";
        break;
      case SslError.SSL_NOTYETVALID:
        message = "The certificate is not yet valid";
        break;
      case SslError.SSL_UNTRUSTED:
        message = "The certificate authority is not trusted";
        break;
    }
    obj.put("message", message);

    Log.d(LOG_TAG, obj.toString());

    channel.invokeMethod("onReceivedServerTrustAuthRequest", obj, new MethodChannel.Result() {
      @Override
      public void success(Object response) {
        if (response != null) {
          Map<String, Object> responseMap = (Map<String, Object>) response;
          Integer action = (Integer) responseMap.get("action");
          if (action != null) {
            switch (action) {
              case 1:
                handler.proceed();
                return;
              case 0:
              default:
                handler.cancel();
                return;
            }
          }
        }

        InAppWebViewClient.super.onReceivedSslError(view, handler, error);
      }

      @Override
      public void error(String s, String s1, Object o) {
        Log.e(LOG_TAG, s + ", " + s1);
      }

      @Override
      public void notImplemented() {
        InAppWebViewClient.super.onReceivedSslError(view, handler, error);
      }
    });
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  @Override
  public void onReceivedClientCertRequest(final WebView view, final ClientCertRequest request) {

    URL url;
    try {
      url = new URL(view.getUrl());
    } catch (MalformedURLException e) {
      e.printStackTrace();
      Log.e(LOG_TAG, e.getMessage());
      request.cancel();
      return;
    }

    final String protocol = url.getProtocol();
    final String realm = null;

    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("host", request.getHost());
    obj.put("protocol", protocol);
    obj.put("realm", realm);
    obj.put("port", request.getPort());

    channel.invokeMethod("onReceivedClientCertRequest", obj, new MethodChannel.Result() {
      @Override
      public void success(Object response) {
        if (response != null) {
          Map<String, Object> responseMap = (Map<String, Object>) response;
          Integer action = (Integer) responseMap.get("action");
          if (action != null) {
            switch (action) {
              case 1:
                {
                  InAppWebView webView = (InAppWebView) view;
                  String certificatePath = (String) responseMap.get("certificatePath");
                  String certificatePassword = (String) responseMap.get("certificatePassword");
                  String androidKeyStoreType = (String) responseMap.get("androidKeyStoreType");
                  Util.PrivateKeyAndCertificates privateKeyAndCertificates = Util.loadPrivateKeyAndCertificate(certificatePath, certificatePassword, androidKeyStoreType);
                  request.proceed(privateKeyAndCertificates.privateKey, privateKeyAndCertificates.certificates);
                }
                return;
              case 2:
                request.ignore();
                return;
              case 0:
              default:
                request.cancel();
                return;
            }
          }
        }

        InAppWebViewClient.super.onReceivedClientCertRequest(view, request);
      }

      @Override
      public void error(String s, String s1, Object o) {
        Log.e(LOG_TAG, s + ", " + s1);
      }

      @Override
      public void notImplemented() {
        InAppWebViewClient.super.onReceivedClientCertRequest(view, request);
      }
    });
  }

  @Override
  public void onScaleChanged(WebView view, float oldScale, float newScale) {
    super.onScaleChanged(view, oldScale, newScale);
    final InAppWebView webView = (InAppWebView) view;
    webView.scale = newScale;

    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("oldScale", oldScale);
    obj.put("newScale", newScale);
    channel.invokeMethod("onScaleChanged", obj);
  }

  @RequiresApi(api = Build.VERSION_CODES.O_MR1)
  @Override
  public void onSafeBrowsingHit(final WebView view, final WebResourceRequest request, final int threatType, final SafeBrowsingResponse callback) {
    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("url", request.getUrl().toString());
    obj.put("threatType", threatType);

    channel.invokeMethod("onSafeBrowsingHit", obj, new MethodChannel.Result() {
      @Override
      public void success(Object response) {
        if (response != null) {
          Map<String, Object> responseMap = (Map<String, Object>) response;
          Boolean report = (Boolean) responseMap.get("report");
          Integer action = (Integer) responseMap.get("action");

          report = report != null ? report : true;

          if (action != null) {
            switch (action) {
              case 0:
                callback.backToSafety(report);
                return;
              case 1:
                callback.proceed(report);
                return;
              case 2:
              default:
                callback.showInterstitial(report);
                return;
            }
          }
        }

        InAppWebViewClient.super.onSafeBrowsingHit(view, request, threatType, callback);
      }

      @Override
      public void error(String s, String s1, Object o) {
        Log.e(LOG_TAG, s + ", " + s1);
      }

      @Override
      public void notImplemented() {
        InAppWebViewClient.super.onSafeBrowsingHit(view, request, threatType, callback);
      }
    });
  }

  @Override
  public WebResourceResponse shouldInterceptRequest(WebView view, final String url) {

    final InAppWebView webView = (InAppWebView) view;

    if (webView.options.useShouldInterceptRequest) {
      WebResourceResponse onShouldInterceptResponse = onShouldInterceptRequest(url);
      if (onShouldInterceptResponse != null) {
        return onShouldInterceptResponse;
      }
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
        Log.d(LOG_TAG, e.getMessage());
        return null;
      }
    }

    String scheme = uri.getScheme();

    if (webView.options.resourceCustomSchemes != null && webView.options.resourceCustomSchemes.contains(scheme)) {
      final Map<String, Object> obj = new HashMap<>();
      if (inAppBrowserActivity != null)
        obj.put("uuid", inAppBrowserActivity.uuid);
      obj.put("url", url);
      obj.put("scheme", scheme);

      Util.WaitFlutterResult flutterResult;
      try {
        flutterResult = Util.invokeMethodAndWait(channel, "onLoadResourceCustomScheme", obj);
      } catch (InterruptedException e) {
        e.printStackTrace();
        Log.e(LOG_TAG, e.getMessage());
        return null;
      }

      if (flutterResult.error != null) {
        Log.e(LOG_TAG, flutterResult.error);
      }
      else if (flutterResult.result != null) {
        Map<String, Object> res = (Map<String, Object>) flutterResult.result;
        WebResourceResponse response = null;
        try {
          response = webView.contentBlockerHandler.checkUrl(webView, url, res.get("content-type").toString());
        } catch (Exception e) {
          e.printStackTrace();
          Log.e(LOG_TAG, e.getMessage());
        }
        if (response != null)
          return response;
        byte[] data = (byte[]) res.get("data");
        return new WebResourceResponse(res.get("content-type").toString(), res.get("content-encoding").toString(), new ByteArrayInputStream(data));
      }
    }

    WebResourceResponse response = null;
    if (webView.contentBlockerHandler.getRuleList().size() > 0) {
      try {
        response = webView.contentBlockerHandler.checkUrl(webView, url);
      } catch (Exception e) {
        e.printStackTrace();
        Log.e(LOG_TAG, e.getMessage());
      }
    }
    return response;
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  @Override
  public WebResourceResponse shouldInterceptRequest(WebView view, WebResourceRequest request) {
    final InAppWebView webView = (InAppWebView) view;

    String url = request.getUrl().toString();

    if (webView.options.useShouldInterceptRequest) {
      WebResourceResponse onShouldInterceptResponse = onShouldInterceptRequest(request);
      if (onShouldInterceptResponse != null) {
        return onShouldInterceptResponse;
      }
    }

    return shouldInterceptRequest(view, url);
  }

  public WebResourceResponse onShouldInterceptRequest(Object request) {
    String url = request instanceof String ? (String) request : null;
    String method = "GET";
    Map<String, String> headers = null;
    Boolean hasGesture = false;
    Boolean isForMainFrame = true;
    Boolean isRedirect = false;

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && request instanceof WebResourceRequest) {
      WebResourceRequest webResourceRequest = (WebResourceRequest) request;
      url = webResourceRequest.getUrl().toString();
      headers = webResourceRequest.getRequestHeaders();
      hasGesture = webResourceRequest.hasGesture();
      isForMainFrame = webResourceRequest.isForMainFrame();
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        isRedirect = webResourceRequest.isRedirect();
      }
    }

    final Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("url", url);
    obj.put("method", method);
    obj.put("headers", headers);
    obj.put("isForMainFrame", isForMainFrame);
    obj.put("hasGesture", hasGesture);
    obj.put("isRedirect", isRedirect);

    Util.WaitFlutterResult flutterResult;
    try {
      flutterResult = Util.invokeMethodAndWait(channel, "shouldInterceptRequest", obj);
    } catch (InterruptedException e) {
      e.printStackTrace();
      Log.e(LOG_TAG, e.getMessage());
      return null;
    }

    if (flutterResult.error != null) {
      Log.e(LOG_TAG, flutterResult.error);
    }
    else if (flutterResult.result != null) {
      Map<String, Object> res = (Map<String, Object>) flutterResult.result;
      String contentType = (String) res.get("contentType");
      String contentEncoding = (String) res.get("contentEncoding");
      byte[] data = (byte[]) res.get("data");
      Map<String, String> responseHeaders = (Map<String, String>) res.get("headers");
      Integer statusCode = (Integer) res.get("statusCode");
      String reasonPhrase = (String) res.get("reasonPhrase");

      ByteArrayInputStream inputStream = (data != null) ? new ByteArrayInputStream(data) : null;

      if ((responseHeaders == null && statusCode == null && reasonPhrase == null) || Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
        return new WebResourceResponse(contentType, contentEncoding, inputStream);
      } else {
        return new WebResourceResponse(contentType, contentEncoding, statusCode, reasonPhrase, responseHeaders, inputStream);
      }
    }

    return null;
  }

  @Override
  public void onFormResubmission (final WebView view, final Message dontResend, final Message resend) {
    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("url", view.getUrl());

    channel.invokeMethod("onFormResubmission", obj, new MethodChannel.Result() {

      @Override
      public void success(@Nullable Object response) {
        if (response != null) {
          Map<String, Object> responseMap = (Map<String, Object>) response;
          Integer action = (Integer) responseMap.get("action");
          if (action != null) {
            switch (action) {
              case 0:
                resend.sendToTarget();
                return;
              case 1:
              default:
                dontResend.sendToTarget();
                return;
            }
          }
        }

        InAppWebViewClient.super.onFormResubmission(view, dontResend, resend);
      }

      @Override
      public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
        Log.d(LOG_TAG, "ERROR: " + errorCode + " " + errorMessage);
      }

      @Override
      public void notImplemented() {
        InAppWebViewClient.super.onFormResubmission(view, dontResend, resend);
      }
    });
  }

  @Override
  public void onPageCommitVisible(WebView view, String url) {
    super.onPageCommitVisible(view, url);
    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("url", url);
    channel.invokeMethod("onPageCommitVisible", obj);
  }

  @RequiresApi(api = Build.VERSION_CODES.O)
  @Override
  public boolean onRenderProcessGone(WebView view, RenderProcessGoneDetail detail) {
    final InAppWebView webView = (InAppWebView) view;

    if (webView.options.useOnRenderProcessGone) {
      Boolean didCrash = detail.didCrash();
      Integer rendererPriorityAtExit = detail.rendererPriorityAtExit();

      Map<String, Object> obj = new HashMap<>();
      if (inAppBrowserActivity != null)
        obj.put("uuid", inAppBrowserActivity.uuid);
      obj.put("didCrash", didCrash);
      obj.put("rendererPriorityAtExit", rendererPriorityAtExit);

      channel.invokeMethod("onRenderProcessGone", obj);

      return true;
    }

    return super.onRenderProcessGone(view, detail);
  }

  @Override
  public void onUnhandledKeyEvent(WebView view, KeyEvent event) {

  }
}
