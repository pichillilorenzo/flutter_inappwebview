package com.pichillilorenzo.flutter_inappbrowser.InAppWebView;

import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.net.http.SslError;
import android.os.Build;
import androidx.annotation.RequiresApi;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.HttpAuthHandler;
import android.webkit.SslErrorHandler;
import android.webkit.ValueCallback;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.pichillilorenzo.flutter_inappbrowser.FlutterWebView;
import com.pichillilorenzo.flutter_inappbrowser.InAppBrowserActivity;
import com.pichillilorenzo.flutter_inappbrowser.InAppBrowserFlutterPlugin;
import com.pichillilorenzo.flutter_inappbrowser.JavaScriptBridgeInterface;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import okhttp3.Request;
import okhttp3.Response;

public class InAppWebViewClient extends WebViewClient {

  protected static final String LOG_TAG = "IABWebViewClient";
  private FlutterWebView flutterWebView;
  private InAppBrowserActivity inAppBrowserActivity;
  Map<Integer, String> statusCodeMapping = new HashMap<Integer, String>();
  long startPageTime = 0;

  public InAppWebViewClient(Object obj) {
    super();
    if (obj instanceof InAppBrowserActivity)
      this.inAppBrowserActivity = (InAppBrowserActivity) obj;
    else if (obj instanceof FlutterWebView)
      this.flutterWebView = (FlutterWebView) obj;
    prepareStatusCodeMapping();
  }

  private void prepareStatusCodeMapping () {
    statusCodeMapping.put(100, "Continue");
    statusCodeMapping.put(101, "Switching Protocols");
    statusCodeMapping.put(200, "OK");
    statusCodeMapping.put(201, "Created");
    statusCodeMapping.put(202, "Accepted");
    statusCodeMapping.put(203, "Non-Authoritative Information");
    statusCodeMapping.put(204, "No Content");
    statusCodeMapping.put(205, "Reset Content");
    statusCodeMapping.put(206, "Partial Content");
    statusCodeMapping.put(300, "Multiple Choices");
    statusCodeMapping.put(301, "Moved Permanently");
    statusCodeMapping.put(302, "Found");
    statusCodeMapping.put(303, "See Other");
    statusCodeMapping.put(304, "Not Modified");
    statusCodeMapping.put(307, "Temporary Redirect");
    statusCodeMapping.put(308, "Permanent Redirect");
    statusCodeMapping.put(400, "Bad Request");
    statusCodeMapping.put(401, "Unauthorized");
    statusCodeMapping.put(403, "Forbidden");
    statusCodeMapping.put(404, "Not Found");
    statusCodeMapping.put(405, "Method Not Allowed");
    statusCodeMapping.put(406, "Not Acceptable");
    statusCodeMapping.put(407, "Proxy Authentication Required");
    statusCodeMapping.put(408, "Request Timeout");
    statusCodeMapping.put(409, "Conflict");
    statusCodeMapping.put(410, "Gone");
    statusCodeMapping.put(411, "Length Required");
    statusCodeMapping.put(412, "Precondition Failed");
    statusCodeMapping.put(413, "Payload Too Large");
    statusCodeMapping.put(414, "URI Too Long");
    statusCodeMapping.put(415, "Unsupported Media Type");
    statusCodeMapping.put(416, "Range Not Satisfiable");
    statusCodeMapping.put(417, "Expectation Failed");
    statusCodeMapping.put(418, "I'm a teapot");
    statusCodeMapping.put(422, "Unprocessable Entity");
    statusCodeMapping.put(425, "Too Early");
    statusCodeMapping.put(426, "Upgrade Required");
    statusCodeMapping.put(428, "Precondition Required");
    statusCodeMapping.put(429, "Too Many Requests");
    statusCodeMapping.put(431, "Request Header Fields Too Large");
    statusCodeMapping.put(451, "Unavailable For Legal Reasons");
    statusCodeMapping.put(500, "Internal Server Error");
    statusCodeMapping.put(501, "Not Implemented");
    statusCodeMapping.put(502, "Bad Gateway");
    statusCodeMapping.put(503, "Service Unavailable");
    statusCodeMapping.put(504, "Gateway Timeout");
    statusCodeMapping.put(505, "HTTP Version Not Supported");
    statusCodeMapping.put(511, "Network Authentication Required");
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

    return super.shouldOverrideUrlLoading(webView, url);

  }


  /*
   * onPageStarted fires the LOAD_START_EVENT
   *
   * @param view
   * @param url
   * @param favicon
   */
  @Override
  public void onPageStarted(WebView view, String url, Bitmap favicon) {
    super.onPageStarted(view, url, favicon);

    startPageTime = System.currentTimeMillis();

    ((inAppBrowserActivity != null) ? inAppBrowserActivity.webView : flutterWebView.webView).isLoading = true;

    if (inAppBrowserActivity != null && inAppBrowserActivity.searchView != null && !url.equals(inAppBrowserActivity.searchView.getQuery().toString())) {
      inAppBrowserActivity.searchView.setQuery(url, false);
    }

    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("url", url);
    getChannel().invokeMethod("onLoadStart", obj);
  }


  public void onPageFinished(final WebView view, String url) {
    super.onPageFinished(view, url);

    ((inAppBrowserActivity != null) ? inAppBrowserActivity.webView : flutterWebView.webView).isLoading = false;

    // CB-10395 InAppBrowserFlutterPlugin's WebView not storing cookies reliable to local device storage
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      CookieManager.getInstance().flush();
    } else {
      CookieSyncManager.getInstance().sync();
    }

    // https://issues.apache.org/jira/browse/CB-11248
    view.clearFocus();
    view.requestFocus();

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      view.evaluateJavascript(InAppWebView.consoleLogJS, null);
      view.evaluateJavascript(JavaScriptBridgeInterface.flutterInAppBroserJSClass, new ValueCallback<String>() {
        @Override
        public void onReceiveValue(String value) {
          view.evaluateJavascript(InAppWebView.platformReadyJS, null);
        }
      });

    }
    else {
      view.loadUrl("javascript:"+InAppWebView.consoleLogJS);
      view.loadUrl("javascript:"+JavaScriptBridgeInterface.flutterInAppBroserJSClass);
      view.loadUrl("javascript:"+InAppWebView.platformReadyJS);
    }

    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("url", url);
    getChannel().invokeMethod("onLoadStop", obj);
  }

  public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
    super.onReceivedError(view, errorCode, description, failingUrl);

    ((inAppBrowserActivity != null) ? inAppBrowserActivity.webView : flutterWebView.webView).isLoading = false;

    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("url", failingUrl);
    obj.put("code", errorCode);
    obj.put("message", description);
    getChannel().invokeMethod("onLoadError", obj);
  }

  public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) {
    super.onReceivedSslError(view, handler, error);

    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("url", error.getUrl());
    obj.put("code", error.getPrimaryError());
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
    obj.put("message", "SslError: " + message);
    getChannel().invokeMethod("onLoadError", obj);

    handler.cancel();
  }

  /**
   * On received http auth request.
   */
  @Override
  public void onReceivedHttpAuthRequest(WebView view, HttpAuthHandler handler, String host, String realm) {
    // By default handle 401 like we'd normally do!
    super.onReceivedHttpAuthRequest(view, handler, host, realm);
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  @Override
  public WebResourceResponse shouldInterceptRequest(WebView view, WebResourceRequest request) {
    if (!request.getMethod().toLowerCase().equals("get") ||
            !(((inAppBrowserActivity != null) ? inAppBrowserActivity.webView : flutterWebView.webView).options.useOnLoadResource)) {
      return null;
    }

    final String url = request.getUrl().toString();

    try {
      Request mRequest = new Request.Builder().url(url).build();

      long startResourceTime = System.currentTimeMillis();
      Response response = ((inAppBrowserActivity != null) ? inAppBrowserActivity.webView : flutterWebView.webView).httpClient.newCall(mRequest).execute();
      long startTime = startResourceTime - startPageTime;
      startTime = (startTime < 0) ? 0 : startTime;
      long duration = System.currentTimeMillis() - startResourceTime;

      if (response.cacheResponse() != null) {
        duration = 0;
      }

      String reasonPhrase = response.message();
      if (reasonPhrase.equals("")) {
        reasonPhrase = statusCodeMapping.get(response.code());
      }
      reasonPhrase = (reasonPhrase.equals("") || reasonPhrase == null) ? "OK" : reasonPhrase;

      Map<String, String> headersResponse = new HashMap<String, String>();
      for (Map.Entry<String, List<String>> entry : response.headers().toMultimap().entrySet()) {
        StringBuilder value = new StringBuilder();
        for (String val : entry.getValue()) {
          value.append((value.toString().isEmpty()) ? val : "; " + val);
        }
        headersResponse.put(entry.getKey().toLowerCase(), value.toString());
      }

      Map<String, String> headersRequest = new HashMap<String, String>();
      for (Map.Entry<String, List<String>> entry : mRequest.headers().toMultimap().entrySet()) {
        StringBuilder value = new StringBuilder();
        for (String val : entry.getValue()) {
          value.append((value.toString().isEmpty()) ? val : "; " + val);
        }
        headersRequest.put(entry.getKey().toLowerCase(), value.toString());
      }

      final Map<String, Object> obj = new HashMap<>();
      Map<String, Object> res = new HashMap<>();
      Map<String, Object> req = new HashMap<>();

      if (inAppBrowserActivity != null)
        obj.put("uuid", inAppBrowserActivity.uuid);

      byte[] dataBytes = response.body().bytes();
      InputStream dataStream = new ByteArrayInputStream(dataBytes);

      res.put("url", url);
      res.put("statusCode", response.code());
      res.put("headers", headersResponse);
      res.put("startTime", startTime);
      res.put("duration", duration);
      res.put("data", dataBytes);

      req.put("url", url);
      req.put("headers", headersRequest);
      req.put("method", mRequest.method());

      obj.put("response", res);
      obj.put("request", req);

      // java.lang.RuntimeException: Methods marked with @UiThread must be executed on the main thread.
      // https://github.com/pichillilorenzo/flutter_inappbrowser/issues/98
      final Handler handler = new Handler(Looper.getMainLooper());
      handler.post(new Runnable() {
         @Override
         public void run() {
           getChannel().invokeMethod("onLoadResource", obj);
         }
       });

      // this return is not working (it blocks some resources), so return null
//      return new WebResourceResponse(
//              response.header("content-type", "text/plain").split(";")[0].trim(),
//              response.header("content-encoding", "utf-8"),
//              response.code(),
//              reasonPhrase,
//              headersResponse,
//              dataStream
//      );
    } catch (IOException e) {
      e.printStackTrace();
      Log.d(LOG_TAG, e.getMessage());
    } catch (Exception e) {
      e.printStackTrace();
      Log.d(LOG_TAG, e.getMessage());
    }

    return null;
  }

  private MethodChannel getChannel() {
    return (inAppBrowserActivity != null) ? InAppBrowserFlutterPlugin.channel : flutterWebView.channel;
  }

}
