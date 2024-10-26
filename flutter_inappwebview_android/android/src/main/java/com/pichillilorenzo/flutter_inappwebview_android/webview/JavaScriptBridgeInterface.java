package com.pichillilorenzo.flutter_inappwebview_android.webview;

import android.os.Build;
import android.os.Handler;
import android.util.Log;
import android.webkit.JavascriptInterface;
import android.webkit.ValueCallback;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview_android.plugin_scripts_js.JavaScriptBridgeJS;
import com.pichillilorenzo.flutter_inappwebview_android.print_job.PrintJobController;
import com.pichillilorenzo.flutter_inappwebview_android.print_job.PrintJobSettings;
import com.pichillilorenzo.flutter_inappwebview_android.types.JavaScriptHandlerFunctionData;
import com.pichillilorenzo.flutter_inappwebview_android.webview.in_app_webview.InAppWebView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.regex.Pattern;

public class JavaScriptBridgeInterface {
  private static final String LOG_TAG = "JSBridgeInterface";
  private InAppWebView inAppWebView;
  @NonNull
  private final String expectedBridgeSecret;

  public JavaScriptBridgeInterface(InAppWebView inAppWebView, @NonNull String expectedBridgeSecret) {
    this.inAppWebView = inAppWebView;
    this.expectedBridgeSecret = expectedBridgeSecret;
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
  public void _callHandler(final String handlerName, final String _callHandlerID,
                           final String bridgeSecret, final String origin, final boolean isMainFrame,
                           final String args) {
    if (inAppWebView == null) {
      return;
    }

    if (handlerName == null || handlerName.isEmpty()) {
      Log.d(LOG_TAG, "handlerName is null or empty");
      return;
    }

    if (!expectedBridgeSecret.equals(bridgeSecret)) {
      Log.e(LOG_TAG, "Bridge access attempt with wrong secret token, possibly from malicious code!");
      return;
    }

    boolean isOriginAllowed = false;
    if (inAppWebView.customSettings.javaScriptHandlerOriginAllowList != null) {
      for (Pattern allowedOrigin : inAppWebView.customSettings.javaScriptHandlerOriginAllowList) {
        if (allowedOrigin.matcher(origin).matches()) {
          isOriginAllowed = true;
          break;
        }
      }
    } else {
      // origin is by default allowed if the allow list is null
      isOriginAllowed = true;
    }
    if (!isOriginAllowed) {
      Log.e(LOG_TAG, "Bridge access attempt from an origin not allowed: " + origin);
      return;
    }

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

        if (handlerName.equals("onPrintRequest") && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          PrintJobSettings settings = new PrintJobSettings();
          settings.handledByClient = true;
          final String printJobId = inAppWebView.printCurrentPage(settings);
          if (inAppWebView != null && inAppWebView.channelDelegate != null) {
            inAppWebView.channelDelegate.onPrintRequest(inAppWebView.getUrl(), printJobId, new WebViewChannelDelegate.PrintRequestCallback() {
              @Override
              public boolean nonNullSuccess(@NonNull Boolean handledByClient) {
                return !handledByClient;
              }

              @Override
              public void defaultBehaviour(@Nullable Boolean handledByClient) {
                if (inAppWebView != null && inAppWebView.plugin != null && inAppWebView.plugin.printJobManager != null) {
                  PrintJobController printJobController = inAppWebView.plugin.printJobManager.jobs.get(printJobId);
                  if (printJobController != null) {
                    printJobController.disposeNoCancel();
                  }
                }
              }

              @Override
              public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
                Log.e(LOG_TAG, errorCode + ", " + ((errorMessage != null) ? errorMessage : ""));
                defaultBehaviour(null);
              }
            });
          }
          return;
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
            Log.e(LOG_TAG, "", e);
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
            Log.e(LOG_TAG, "", e);
          }
          return;
        }

        if (inAppWebView.channelDelegate != null) {
          JavaScriptHandlerFunctionData data = new JavaScriptHandlerFunctionData(origin, isMainFrame, args);
          // invoke flutter javascript handler and send back flutter data as a JSON Object to javascript
          inAppWebView.channelDelegate.onCallJsHandler(handlerName, data, new WebViewChannelDelegate.CallJsHandlerCallback() {
            @Override
            public void defaultBehaviour(@Nullable Object json) {
              if (inAppWebView == null) {
                // The webview has already been disposed, ignore.
                return;
              }
              String sourceCode = "if (window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME() + "[" + _callHandlerID + "] != null) { " +
                      "window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME() + "[" + _callHandlerID + "].resolve(" + json + "); " +
                      "delete window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME() + "[" + _callHandlerID + "]; " +
                      "}";
              if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                inAppWebView.evaluateJavascript(sourceCode, (ValueCallback<String>) null);
              } else {
                inAppWebView.loadUrl("javascript:" + sourceCode);
              }
            }

            @Override
            public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
              String message = errorCode + ((errorMessage != null) ? ", " + errorMessage : "");
              Log.e(LOG_TAG, message);

              if (inAppWebView == null) {
                // The webview has already been disposed, ignore.
                return;
              }

              String sourceCode = "if (window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME() + "[" + _callHandlerID + "] != null) { " +
                      "window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME() + "[" + _callHandlerID + "].reject(new Error(" + JSONObject.quote(message) + ")); " +
                      "delete window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME() + "[" + _callHandlerID + "]; " +
                      "}";
              if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                inAppWebView.evaluateJavascript(sourceCode, (ValueCallback<String>) null);
              } else {
                inAppWebView.loadUrl("javascript:" + sourceCode);
              }
            }
          });
        }
      }
    });
  }

  public void dispose() {
    inAppWebView = null;
  }
}
