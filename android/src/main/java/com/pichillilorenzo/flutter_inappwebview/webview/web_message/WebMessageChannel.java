package com.pichillilorenzo.flutter_inappwebview.webview.web_message;

import android.webkit.ValueCallback;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.webkit.WebMessageCompat;
import androidx.webkit.WebMessagePortCompat;
import androidx.webkit.WebViewCompat;
import androidx.webkit.WebViewFeature;

import com.pichillilorenzo.flutter_inappwebview.plugin_scripts_js.JavaScriptBridgeJS;
import com.pichillilorenzo.flutter_inappwebview.types.Disposable;
import com.pichillilorenzo.flutter_inappwebview.webview.InAppWebViewInterface;
import com.pichillilorenzo.flutter_inappwebview.types.WebMessagePort;
import com.pichillilorenzo.flutter_inappwebview.webview.in_app_webview.InAppWebView;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class WebMessageChannel implements Disposable {
  protected static final String LOG_TAG = "WebMessageChannel";
  public static final String METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_inappwebview_web_message_channel_";
  
  @NonNull
  public String id;
  @Nullable
  public WebMessageChannelChannelDelegate channelDelegate;
  public final List<WebMessagePortCompat> compatPorts;
  public final List<WebMessagePort> ports;
  @Nullable
  public InAppWebViewInterface webView;

  public WebMessageChannel(@NonNull String id, @NonNull InAppWebViewInterface webView) {
    this.id = id;
    final MethodChannel channel = new MethodChannel(webView.getPlugin().messenger, METHOD_CHANNEL_NAME_PREFIX + id);
    this.channelDelegate = new WebMessageChannelChannelDelegate(this, channel);
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
  
  public void setWebMessageCallbackForInAppWebView(final int index, @NonNull MethodChannel.Result result) {
    if (webView != null && compatPorts.size() > 0 &&
            WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK)) {
      final WebMessagePortCompat webMessagePort = compatPorts.get(index);
      final WebMessageChannel webMessageChannel = this;
      try {
        webMessagePort.setWebMessageCallback(new WebMessagePortCompat.WebMessageCallbackCompat() {
          @Override
          public void onMessage(@NonNull WebMessagePortCompat port, @Nullable WebMessageCompat message) {
            super.onMessage(port, message);
            webMessageChannel.onMessage(index, message != null ? message.getData() : null);
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

  public void postMessageForInAppWebView(final Integer index, Map<String, Object> message, @NonNull MethodChannel.Result result) {
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

  public void closeForInAppWebView(Integer index, @NonNull MethodChannel.Result result) {
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

  public void onMessage(int index, String message) {
    if (channelDelegate != null) {
      channelDelegate.onMessage(index, message);
    }
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
    if (channelDelegate != null) {
      channelDelegate.dispose();
      channelDelegate = null;
    }
    compatPorts.clear();
    webView = null;
  }
}
