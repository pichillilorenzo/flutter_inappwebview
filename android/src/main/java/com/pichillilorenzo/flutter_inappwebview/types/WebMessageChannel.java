package com.pichillilorenzo.flutter_inappwebview.types;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.webkit.WebMessageCompat;
import androidx.webkit.WebMessagePortCompat;
import androidx.webkit.WebViewCompat;
import androidx.webkit.WebViewFeature;

import com.pichillilorenzo.flutter_inappwebview.in_app_webview.InAppWebView;

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
  public final List<WebMessagePortCompat> ports;
  private InAppWebView webView;

  public WebMessageChannel(@NonNull String id, @NonNull InAppWebView webView) {
    this.id = id;
    this.channel = new MethodChannel(webView.plugin.messenger, "com.pichillilorenzo/flutter_inappwebview_web_message_channel_" + id);
    this.channel.setMethodCallHandler(this);
    this.ports = new ArrayList<>(Arrays.asList(WebViewCompat.createWebMessageChannel(webView)));
    this.webView = webView;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    switch (call.method) {
      case "setWebMessageCallback":
        if (webView != null && ports.size() > 0 &&
                WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK)) {
          final Integer index = (Integer) call.argument("index");
          final WebMessagePortCompat webMessagePort = ports.get(index);
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
        break;
      case "postMessage":
        if (webView != null && ports.size() > 0 &&
                WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_PORT_POST_MESSAGE)) {
          final Integer index = (Integer) call.argument("index");
          WebMessagePortCompat port = ports.get(index);
          Map<String, Object> message = (Map<String, Object>) call.argument("message");
          List<WebMessagePortCompat> webMessagePorts = new ArrayList<>();
          List<Map<String, Object>> portsMap = (List<Map<String, Object>>) message.get("ports");
          if (portsMap != null) {
            for (Map<String, Object> portMap : portsMap) {
              String webMessageChannelId = (String) portMap.get("webMessageChannelId");
              Integer portIndex = (Integer) portMap.get("index");
              WebMessageChannel webMessageChannel = webView.webMessageChannels.get(webMessageChannelId);
              if (webMessageChannel != null) {
                webMessagePorts.add(webMessageChannel.ports.get(portIndex));
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
        break;
      case "close":
        if (webView != null && ports.size() > 0 &&
                WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_PORT_CLOSE)) {
          Integer index = (Integer) call.argument("index");
          WebMessagePortCompat port = ports.get(index);
          try {
            port.close();
            result.success(true);
          } catch (Exception e) {
            result.error(LOG_TAG, e.getMessage(), null);
          }
        } else {
          result.success(true);
        }
        break;
      default:
        result.notImplemented();
    }
  }

  public Map<String, Object> toMap() {
    Map<String, Object> webMessageChannelMap = new HashMap<>();
    webMessageChannelMap.put("id", id);
    return webMessageChannelMap;
  }

  public void dispose() {
    if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_PORT_CLOSE)) {
      for (WebMessagePortCompat port : ports) {
        try {
          port.close();
        } catch (Exception ignored) {}
      }
    }
    this.channel.setMethodCallHandler(null);
    this.ports.clear();
    this.webView = null;
  }
}
