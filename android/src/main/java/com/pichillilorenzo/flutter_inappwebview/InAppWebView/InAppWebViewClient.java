package com.pichillilorenzo.flutter_inappwebview.InAppWebView;

import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.net.http.SslCertificate;
import android.net.http.SslError;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.webkit.ClientCertRequest;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.HttpAuthHandler;
import android.webkit.SafeBrowsingResponse;
import android.webkit.SslErrorHandler;
import android.webkit.ValueCallback;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.annotation.RequiresApi;

import com.pichillilorenzo.flutter_inappwebview.CredentialDatabase.Credential;
import com.pichillilorenzo.flutter_inappwebview.CredentialDatabase.CredentialDatabase;
import com.pichillilorenzo.flutter_inappwebview.FlutterWebView;
import com.pichillilorenzo.flutter_inappwebview.InAppBrowserActivity;
import com.pichillilorenzo.flutter_inappwebview.InAppWebViewFlutterPlugin;
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

import io.flutter.plugin.common.MethodChannel;

public class InAppWebViewClient extends WebViewClient {

  protected static final String LOG_TAG = "IABWebViewClient";
  private FlutterWebView flutterWebView;
  private InAppBrowserActivity inAppBrowserActivity;
  Map<Integer, String> statusCodeMapping = new HashMap<Integer, String>();
  private static int previousAuthRequestFailureCount = 0;
  private static List<Credential> credentialsProposed = null;
  private String onPageStartedURL = "";

  public InAppWebViewClient(Object obj) {
    super();
    if (obj instanceof InAppBrowserActivity)
      this.inAppBrowserActivity = (InAppBrowserActivity) obj;
    else if (obj instanceof FlutterWebView)
      this.flutterWebView = (FlutterWebView) obj;
  }
  @Override
  public boolean shouldOverrideUrlLoading(WebView webView, String url) {

    if (((inAppBrowserActivity != null) ? inAppBrowserActivity.webView : flutterWebView.webView).options.useShouldOverrideUrlLoading) {
      Map<String, Object> obj = new HashMap<>();
      if (inAppBrowserActivity != null)
        obj.put("uuid", inAppBrowserActivity.uuid);
      obj.put("url", url);
      getChannel().invokeMethod("shouldOverrideUrlLoading", obj);
      return true;
    }

    if (url != null) {
      if (url.startsWith(WebView.SCHEME_TEL)) {
        try {
          Intent intent = new Intent(Intent.ACTION_DIAL);
          intent.setData(Uri.parse(url));
          ((inAppBrowserActivity != null) ? inAppBrowserActivity : flutterWebView.activity).startActivity(intent);
          return true;
        } catch (android.content.ActivityNotFoundException e) {
          Log.e(LOG_TAG, "Error dialing " + url + ": " + e.toString());
        }
      } else if (url.startsWith("geo:") || url.startsWith(WebView.SCHEME_MAILTO) || url.startsWith("market:") || url.startsWith("intent:")) {
        try {
          Intent intent = new Intent(Intent.ACTION_VIEW);
          intent.setData(Uri.parse(url));
          ((inAppBrowserActivity != null) ? inAppBrowserActivity : flutterWebView.activity).startActivity(intent);
          return true;
        } catch (android.content.ActivityNotFoundException e) {
          Log.e(LOG_TAG, "Error with " + url + ": " + e.toString());
        }
      }
      // If sms:5551212?body=This is the message
      else if (url.startsWith("sms:")) {
        try {
          Intent intent = new Intent(Intent.ACTION_VIEW);

          // Get address
          String address;
          int parmIndex = url.indexOf('?');
          if (parmIndex == -1) {
            address = url.substring(4);
          } else {
            address = url.substring(4, parmIndex);

            // If body, then set sms body
            Uri uri = Uri.parse(url);
            String query = uri.getQuery();
            if (query != null) {
              if (query.startsWith("body=")) {
                intent.putExtra("sms_body", query.substring(5));
              }
            }
          }
          intent.setData(Uri.parse("sms:" + address));
          intent.putExtra("address", address);
          intent.setType("vnd.android-dir/mms-sms");
          ((inAppBrowserActivity != null) ? inAppBrowserActivity : flutterWebView.activity).startActivity(intent);
          return true;
        } catch (android.content.ActivityNotFoundException e) {
          Log.e(LOG_TAG, "Error sending sms " + url + ":" + e.toString());
        }
      }
    }

    return super.shouldOverrideUrlLoading(webView, url);
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

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      webView.evaluateJavascript(js, (ValueCallback<String>) null);
    } else {
      webView.loadUrl("javascript:" + js);
    }

    onPageStartedURL = url;
    super.onPageStarted(view, url, favicon);

    webView.isLoading = true;
    if (inAppBrowserActivity != null && inAppBrowserActivity.searchView != null && !url.equals(inAppBrowserActivity.searchView.getQuery().toString())) {
      inAppBrowserActivity.searchView.setQuery(url, false);
    }

    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("url", url);
    getChannel().invokeMethod("onLoadStart", obj);
  }


  public void onPageFinished(WebView view, String url) {
    final InAppWebView webView = (InAppWebView) view;

    super.onPageFinished(view, url);

    webView.isLoading = false;
    previousAuthRequestFailureCount = 0;
    credentialsProposed = null;

    // CB-10395 InAppBrowser's WebView not storing cookies reliable to local device storage
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
    getChannel().invokeMethod("onLoadStop", obj);
  }

  @Override
  public void doUpdateVisitedHistory (WebView view, String url, boolean isReload) {
    super.doUpdateVisitedHistory(view, url, isReload);

    if (!isReload && !url.equals(onPageStartedURL)) {
      onPageStartedURL = "";
      Map<String, Object> obj = new HashMap<>();
      if (inAppBrowserActivity != null)
        obj.put("uuid", inAppBrowserActivity.uuid);
      obj.put("url", url);
      getChannel().invokeMethod("onNavigationStateChange", obj);
    }
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
    getChannel().invokeMethod("onLoadError", obj);
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
      getChannel().invokeMethod("onLoadHttpError", obj);
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

    getChannel().invokeMethod("onReceivedHttpAuthRequest", obj, new MethodChannel.Result() {
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

        handler.cancel();
      }

      @Override
      public void error(String s, String s1, Object o) {
        Log.e(LOG_TAG, s + ", " + s1);
      }

      @Override
      public void notImplemented() {
        handler.cancel();
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

    getChannel().invokeMethod("onReceivedServerTrustAuthRequest", obj, new MethodChannel.Result() {
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

        handler.cancel();
      }

      @Override
      public void error(String s, String s1, Object o) {
        Log.e(LOG_TAG, s + ", " + s1);
      }

      @Override
      public void notImplemented() {
        handler.cancel();
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

    getChannel().invokeMethod("onReceivedClientCertRequest", obj, new MethodChannel.Result() {
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
                  Util.PrivateKeyAndCertificates privateKeyAndCertificates = Util.loadPrivateKeyAndCertificate(webView.registrar, certificatePath, certificatePassword, androidKeyStoreType);
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

        request.cancel();
      }

      @Override
      public void error(String s, String s1, Object o) {
        Log.e(LOG_TAG, s + ", " + s1);
      }

      @Override
      public void notImplemented() {
        request.cancel();
      }
    });
  }

  @Override
  public void onScaleChanged(WebView view, float oldScale, float newScale) {
    final InAppWebView webView = (InAppWebView) view;
    webView.scale = newScale;
  }

  @RequiresApi(api = Build.VERSION_CODES.O_MR1)
  @Override
  public void onSafeBrowsingHit(final WebView view, WebResourceRequest request, int threatType, final SafeBrowsingResponse callback) {
    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("url", request.getUrl().toString());
    obj.put("threatType", threatType);

    getChannel().invokeMethod("onSafeBrowsingHit", obj, new MethodChannel.Result() {
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

        callback.showInterstitial(true);
      }

      @Override
      public void error(String s, String s1, Object o) {
        Log.e(LOG_TAG, s + ", " + s1);
      }

      @Override
      public void notImplemented() {
        callback.showInterstitial(true);
      }
    });
  }

  @Override
  public WebResourceResponse shouldInterceptRequest(WebView view, final String url) {

    final InAppWebView webView = (InAppWebView) view;

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
        flutterResult = Util.invokeMethodAndWait(getChannel(), "onLoadResourceCustomScheme", obj);
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
    String url = request.getUrl().toString();
    return shouldInterceptRequest(view, url);
  }

  private MethodChannel getChannel() {
    return (inAppBrowserActivity != null) ? InAppWebViewFlutterPlugin.inAppBrowser.channel : flutterWebView.channel;
  }

}
