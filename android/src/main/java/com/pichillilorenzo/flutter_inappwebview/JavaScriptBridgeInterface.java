package com.pichillilorenzo.flutter_inappwebview;

import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.webkit.JavascriptInterface;
import android.webkit.ValueCallback;

import com.pichillilorenzo.flutter_inappwebview.in_app_webview.InAppWebView;
import com.pichillilorenzo.flutter_inappwebview.plugin_scripts_js.JavaScriptBridgeJS;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class JavaScriptBridgeInterface {
  private static final String LOG_TAG = "JSBridgeInterface";
  private InAppWebView inAppWebView;
  private final MethodChannel channel;
  
  public JavaScriptBridgeInterface(InAppWebView inAppWebView) {
    this.inAppWebView = inAppWebView;
    this.channel = this.inAppWebView.channel;
  }

  @JavascriptInterface
  public void _hideContextMenu() {
    if (inAppWebView == null) {
      return;
    }

    final Handler handler = new Handler(inAppWebView.getWebViewLooper());
    handler.post(new Runnable() {
      @Override
      public void run() {
        if (inAppWebView != null && inAppWebView.floatingContextMenu != null) {
          inAppWebView.hideContextMenu();
        }
      }
    });
  }

  @JavascriptInterface
  public void _callHandler(final String handlerName, final String _callHandlerID, final String args) {
    if (inAppWebView == null) {
      return;
    }

    final Map<String, Object> obj = new HashMap<>();
    obj.put("handlerName", handlerName);
    obj.put("args", args);

    // java.lang.RuntimeException: Methods marked with @UiThread must be executed on the main thread.
    // https://github.com/pichillilorenzo/flutter_inappwebview/issues/98
    final Handler handler = new Handler(inAppWebView.getWebViewLooper());
    handler.post(new Runnable() {
      @Override
      public void run() {
        if (inAppWebView == null) {
          // The webview has already been disposed, ignore.
          return;
        }

        if (handlerName.equals("onPrint") && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          inAppWebView.printCurrentPage();
        } else if (handlerName.equals("callAsyncJavaScript")) {
          try {
            JSONArray arguments = new JSONArray(args);
            JSONObject jsonObject = arguments.getJSONObject(0);
            String resultUuid = jsonObject.getString("resultUuid");
            ValueCallback<String> callAsyncJavaScriptCallback = inAppWebView.callAsyncJavaScriptCallbacks.get(resultUuid);
            if (callAsyncJavaScriptCallback != null) {
              callAsyncJavaScriptCallback.onReceiveValue(jsonObject.toString());
              inAppWebView.callAsyncJavaScriptCallbacks.remove(resultUuid);
            }
          } catch (JSONException e) {
            e.printStackTrace();
          }
          return;
        } else if (handlerName.equals("evaluateJavaScriptWithContentWorld")) {
          try {
            JSONArray arguments = new JSONArray(args);
            JSONObject jsonObject = arguments.getJSONObject(0);
            String resultUuid = jsonObject.getString("resultUuid");
            ValueCallback<String> evaluateJavaScriptCallback = inAppWebView.evaluateJavaScriptContentWorldCallbacks.get(resultUuid);
            if (evaluateJavaScriptCallback != null) {
              evaluateJavaScriptCallback.onReceiveValue(jsonObject.has("value") ? jsonObject.get("value").toString() : "null");
              inAppWebView.evaluateJavaScriptContentWorldCallbacks.remove(resultUuid);
            }
          } catch (JSONException e) {
            e.printStackTrace();
          }
          return;
        }

        // invoke flutter javascript handler and send back flutter data as a JSON Object to javascript
        channel.invokeMethod("onCallJsHandler", obj, new MethodChannel.Result() {
          @Override
          public void success(Object json) {
            if (inAppWebView == null) {
              // The webview has already been disposed, ignore.
              return;
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
              inAppWebView.evaluateJavascript("if(window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + "[" + _callHandlerID + "] != null) {window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + "[" + _callHandlerID + "](" + json + "); delete window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + "[" + _callHandlerID + "];}", (ValueCallback<String>) null);
            }
            else {
              inAppWebView.loadUrl("javascript:if(window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + "[" + _callHandlerID + "] != null) {window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + "[" + _callHandlerID + "](" + json + "); delete window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + "[" + _callHandlerID + "];}");
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
    });
  }

  public void dispose() {
    inAppWebView = null;
  }
}
