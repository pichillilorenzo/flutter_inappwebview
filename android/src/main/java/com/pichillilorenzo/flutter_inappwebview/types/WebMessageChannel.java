package com.pichillilorenzo.flutter_inappwebview.types;

import android.webkit.ValueCallback;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.webkit.WebMessageCompat;
import androidx.webkit.WebMessagePortCompat;
import androidx.webkit.WebViewCompat;
import androidx.webkit.WebViewFeature;

import com.pichillilorenzo.flutter_inappwebview.in_app_webview.InAppWebView;
import com.pichillilorenzo.flutter_inappwebview.plugin_scripts_js.JavaScriptBridgeJS;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class WebMessageChannel implements MethodChannel.MethodCallHandler {
  static final String LOG_TAG = "WebMessageChannel";

  public String id;
  public MethodChannel channel;
  public final List<WebMessagePortCompat> compatPorts;
  public final List<WebMessagePort> ports;
  public InAppWebViewInterface webView;

  public WebMessageChannel(@NonNull String id, @NonNull InAppWebViewInterface webView) {
    this.id = id;
    this.channel = new MethodChannel(webView.getPlugin().messenger, "com.pichillilorenzo/flutter_inappwebview_web_message_channel_" + id);
    this.channel.setMethodCallHandler(this);
    if (webView instanceof InAppWebView) {
      this.compatPorts = new ArrayList<>(Arrays.asList(WebViewCompat.createWebMessageChannel((InAppWebView) webView)));
      this.ports = new ArrayList<>();
    } else {
      this.ports = Arrays.asList(new WebMessagePort("port1", this), new WebMessagePort("port2", this));
      this.compatPorts = new ArrayList<>();
    }
    this.webView = webView;
  }

  public void initJsInstance(InAppWebViewInterface webView, final ValueCallback<WebMessageChannel> callback) {
    if (webView != null) {
      final WebMessageChannel webMessageChannel = this;
      webView.evaluateJavascript("(function() {" +
              JavaScriptBridgeJS.WEB_MESSAGE_CHANNELS_VARIABLE_NAME + "['" + webMessageChannel.id + "'] = new MessageChannel();" +
              "})();", null, new ValueCallback<String>() {
        @Override
        public void onReceiveValue(String value) {
          callback.onReceiveValue(webMessageChannel);
        }
      });
    } else {
      callback.onReceiveValue(this);
    }
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    switch (call.method) {
      case "setWebMessageCallback":
        if (webView instanceof InAppWebView) {
          final Integer index = (Integer) call.argument("index");
          setWebMessageCallbackForInAppWebView(index, result);
        } else {
          result.success(true);
        }
        break;
      case "postMessage":
        if (webView instanceof InAppWebView) {
          final Integer index = (Integer) call.argument("index");
          Map<String, Object> message = (Map<String, Object>) call.argument("message");
          postMessageForInAppWebView(index, message, result);
        } else {
          result.success(true);
        }
        break;
      case "close":
        if (webView instanceof InAppWebView) {
          Integer index = (Integer) call.argument("index");
          closeForInAppWebView(index, result);
        } else {
          result.success(true);
        }
        break;
      default:
        result.notImplemented();
    }
  }
  
  private void setWebMessageCallbackForInAppWebView(final Integer index, @NonNull MethodChannel.Result result) {
    if (webView != null && compatPorts.size() > 0 &&
            WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK)) {
      final WebMessagePortCompat webMessagePort = compatPorts.get(index);
      try {
        webMessagePort.setWebMessageCallback(new WebMessagePortCompat.WebMessageCallbackCompat() {
          @Override
          public void onMessage(@NonNull WebMessagePortCompat port, @Nullable WebMessageCompat message) {
            super.onMessage(port, message);

            Map<String, Object> obj = new HashMap<>();
            obj.put("index", index);
            obj.put("message", message != null ? message.getData() : null);
            channel.invokeMethod("onMessage", obj);
          }
        });
        result.success(true);
      } catch (Exception e) {
        result.error(LOG_TAG, e.getMessage(), null);
      }
    } else {
      result.success(true);
    }
  }

  private void postMessageForInAppWebView(final Integer index, Map<String, Object> message, @NonNull MethodChannel.Result result) {
    if (webView != null && compatPorts.size() > 0 &&
            WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_PORT_POST_MESSAGE)) {
      WebMessagePortCompat port = compatPorts.get(index);
      List<WebMessagePortCompat> webMessagePorts = new ArrayList<>();
      List<Map<String, Object>> portsMap = (List<Map<String, Object>>) message.get("ports");
      if (portsMap != null) {
        for (Map<String, Object> portMap : portsMap) {
          String webMessageChannelId = (String) portMap.get("webMessageChannelId");
          Integer portIndex = (Integer) portMap.get("index");
          WebMessageChannel webMessageChannel = webView.getWebMessageChannels().get(webMessageChannelId);
          if (webMessageChannel != null) {
            webMessagePorts.add(webMessageChannel.compatPorts.get(portIndex));
          }
        }
      }
      WebMessageCompat webMessage = new WebMessageCompat((String) message.get("data"), webMessagePorts.toArray(new WebMessagePortCompat[0]));
      try {
        port.postMessage(webMessage);
        result.success(true);
      } catch (Exception e) {
        result.error(LOG_TAG, e.getMessage(), null);
      }
    } else {
      result.success(true);
    }
  }

  private void closeForInAppWebView(Integer index, @NonNull MethodChannel.Result result) {
    if (webView != null && compatPorts.size() > 0 &&
            WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_PORT_CLOSE)) {
      WebMessagePortCompat port = compatPorts.get(index);
      try {
        port.close();
        result.success(true);
      } catch (Exception e) {
        result.error(LOG_TAG, e.getMessage(), null);
      }
    } else {
      result.success(true);
    }
  }

  public void onMessage(Integer index, String message) {
    Map<String, Object> obj = new HashMap<>();
    obj.put("index", index);
    obj.put("message", message );
    channel.invokeMethod("onMessage", obj);
  }

  public Map<String, Object> toMap() {
    Map<String, Object> webMessageChannelMap = new HashMap<>();
    webMessageChannelMap.put("id", id);
    return webMessageChannelMap;
  }

  public void dispose() {
    if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_PORT_CLOSE)) {
      for (WebMessagePortCompat port : compatPorts) {
        try {
          port.close();
        } catch (Exception ignored) {}
      }
    }
    this.channel.setMethodCallHandler(null);
    this.compatPorts.clear();
    this.webView = null;
  }
}
