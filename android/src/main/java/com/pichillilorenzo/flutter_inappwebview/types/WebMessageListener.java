package com.pichillilorenzo.flutter_inappwebview.types;

import android.net.Uri;
import android.webkit.WebView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.webkit.JavaScriptReplyProxy;
import androidx.webkit.WebMessageCompat;
import androidx.webkit.WebViewCompat;
import androidx.webkit.WebViewFeature;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class WebMessageListener implements MethodChannel.MethodCallHandler {
  static final String LOG_TAG = "WebMessageListener";

  public String jsObjectName;
  public Set<String> allowedOriginRules;
  public WebViewCompat.WebMessageListener listener;
  public JavaScriptReplyProxy replyProxy;
  public MethodChannel channel;

  public WebMessageListener(@NonNull BinaryMessenger messenger, @NonNull String jsObjectName, @NonNull Set<String> allowedOriginRules) {
    this.jsObjectName = jsObjectName;
    this.allowedOriginRules = allowedOriginRules;
    this.channel = new MethodChannel(messenger, "com.pichillilorenzo/flutter_inappwebview_web_message_listener_" + this.jsObjectName);
    this.channel.setMethodCallHandler(this);
    this.listener = new WebViewCompat.WebMessageListener() {
      @Override
      public void onPostMessage(@NonNull WebView view, @NonNull WebMessageCompat message, @NonNull Uri sourceOrigin, boolean isMainFrame, @NonNull JavaScriptReplyProxy javaScriptReplyProxy) {
        replyProxy = javaScriptReplyProxy;
        Map<String, Object> obj = new HashMap<>();
        obj.put("message", message.getData());
        obj.put("sourceOrigin", sourceOrigin.toString().equals("null") ? null : sourceOrigin.toString());
        obj.put("isMainFrame", isMainFrame);
        channel.invokeMethod("onPostMessage", obj);
      }
    };
  }

  @Nullable
  public static WebMessageListener fromMap(@NonNull BinaryMessenger messenger, @Nullable Map<String, Object> map) {
    if (map == null) {
      return null;
    }
    String jsObjectName = (String) map.get("jsObjectName");
    assert jsObjectName != null;
    List<String> allowedOriginRuleList = (List<String>) map.get("allowedOriginRules");
    assert allowedOriginRuleList != null;
    Set<String> allowedOriginRules = new HashSet<>(allowedOriginRuleList);
    return new WebMessageListener(messenger, jsObjectName, allowedOriginRules);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    switch (call.method) {
      case "postMessage":
        if (replyProxy != null && WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_LISTENER)) {
          String message = (String) call.argument("message");
          replyProxy.postMessage(message);
        }
        result.success(true);
        break;
      default:
        result.notImplemented();
    }
  }

  public void dispose() {
    this.channel.setMethodCallHandler(null);
    this.listener = null;
    this.replyProxy = null;
  }
}
