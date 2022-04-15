package com.pichillilorenzo.flutter_inappwebview.in_app_geckoview;

import android.net.Uri;
import android.util.Log;
import android.webkit.ConsoleMessage;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview.types.WebMessageChannel;
import com.pichillilorenzo.flutter_inappwebview.types.WebMessageListener;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.mozilla.geckoview.GeckoResult;
import org.mozilla.geckoview.WebExtension;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class JavascriptBridgeDelegate implements WebExtension.MessageDelegate, WebExtension.PortDelegate {

  static final String LOG_TAG = "JSBridgeDelegate";

  @Nullable
  private WebExtension.Port port;

  private InAppGeckoView inAppWebView;
  private final MethodChannel channel;

  public JavascriptBridgeDelegate(InAppGeckoView inAppWebView) {
    this.inAppWebView = inAppWebView;
    this.channel = this.inAppWebView.channel;
  }

  @Nullable
  @Override
  public GeckoResult<Object> onMessage(@NonNull String nativeApp, @NonNull Object message, @NonNull final WebExtension.MessageSender sender) {
    return null;
  }

  @Nullable
  @Override
  public void onConnect(@NonNull WebExtension.Port port) {
    this.port = port;
    this.port.setDelegate(this);
    
    JSONObject jsonObject = new JSONObject();
    JSONObject initialOptions = new JSONObject();
    try {
      initialOptions.put("useShouldInterceptAjaxRequest", this.inAppWebView.options.useShouldInterceptAjaxRequest);
      initialOptions.put("useShouldInterceptFetchRequest", this.inAppWebView.options.useShouldInterceptFetchRequest);
      jsonObject.put("initialOptions", initialOptions);
    } catch (JSONException e) {
      e.printStackTrace();
    }
    this.port.postMessage(jsonObject);
  }

  @Override
  public void onPortMessage(@NonNull Object message, @NonNull final WebExtension.Port webExtPort) {
    if (this.port == webExtPort && message instanceof JSONObject) {
      JSONObject jsonObject = (JSONObject) message;
      try {
        if (jsonObject.has("event")) {
          final String event = (String) jsonObject.get("event");
          final String consoleMessage = (String) jsonObject.get("message");
          final String consoleMessageLevel = (String) jsonObject.get("messageLevel");

          onConsoleMessage(new ConsoleMessage(consoleMessage, null, 0, ConsoleMessage.MessageLevel.valueOf(consoleMessageLevel)));
        }
        else if (jsonObject.has("handlerName")) {
          final String handlerName = (String) jsonObject.get("handlerName");
          final Integer _callHandlerID = (Integer) jsonObject.get("_callHandlerID");
          final String args = (String) jsonObject.get("args");

          switch (handlerName) {
            case "onLastImageTouched":
              inAppWebView.lastImageTouched = new JSONArray(args).getJSONObject(0);
              return;
            case "onLastAnchorOrImageTouched":
              inAppWebView.lastAnchorOrImageTouched = new JSONArray(args).getJSONObject(0);
              return;
            case "onWebMessagePortMessageReceived":
              {
                JSONObject body = new JSONArray(args).getJSONObject(0);
                String webMessageChannelId = body.getString("webMessageChannelId");
                Integer index = body.getInt("index");
                String webMessage = body.getString("message");
                WebMessageChannel webMessageChannel = inAppWebView.webMessageChannels.containsKey(webMessageChannelId) ? inAppWebView.webMessageChannels.get(webMessageChannelId) : null;
                if (webMessageChannel != null) {
                  webMessageChannel.onMessage(index, webMessage);
                }
              }
              return;
            case "onWebMessageListenerPostMessageReceived":
              {
                JSONObject body = new JSONArray(args).getJSONObject(0);
                String jsObjectName = body.getString("jsObjectName");
                String messageData = body.getString("message");
                for (WebMessageListener webMessageListener : inAppWebView.webMessageListeners) {
                  if (webMessageListener.jsObjectName.equals(jsObjectName)) {
                    boolean isMainFrame = webExtPort.sender.isTopLevel();
                    Uri url = Uri.parse(webExtPort.sender.url);
                    String scheme = url.getScheme();
                    String host = url.getHost();
                    int port = url.getPort();

                    if (!webMessageListener.isOriginAllowed(scheme, host, port)) {
                      return;
                    }

                    Uri sourceOrigin = null;
                    if (scheme != null && !scheme.isEmpty() && host != null && !host.isEmpty()) {
                      sourceOrigin = Uri.parse(scheme + "://" + host + (port != -1 && port != 0 ? ":" + port : ""));
                    }
                    webMessageListener.onPostMessage(messageData, sourceOrigin, isMainFrame);

                    break;
                  }
                }
              }
              return;
          }

          if (handlerName.equals("onPrint")) {
            inAppWebView.printCurrentPage();
          }

          final Map<String, Object> obj = new HashMap<>();
          obj.put("handlerName", handlerName);
          obj.put("args", args);

          // invoke flutter javascript handler and send back flutter data as a JSON Object to javascript
          channel.invokeMethod("onCallJsHandler", obj, new MethodChannel.Result() {
            @Override
            public void success(Object json) {
              if (inAppWebView == null || webExtPort == null) {
                // The webview has already been disposed, ignore.
                return;
              }
              JSONObject message = new JSONObject();
              try {
                message.put("_callHandlerID", _callHandlerID);
                message.put("json", json);
              } catch (JSONException e) {
                e.printStackTrace();
              }
              webExtPort.postMessage(message);
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
      } catch (JSONException e) {
        e.printStackTrace();
      }
    }
  }

  @NonNull
  @Override
  public void onDisconnect(@NonNull WebExtension.Port port) {
    if (this.port == port) {
      this.port = null;
    }
  }

  private boolean onConsoleMessage(ConsoleMessage consoleMessage) {
    Map<String, Object> obj = new HashMap<>();
    obj.put("message", consoleMessage.message());
    obj.put("messageLevel", consoleMessage.messageLevel().ordinal());
    channel.invokeMethod("onConsoleMessage", obj);
    return true;
  }

  public void dispose() {
    inAppWebView = null;
    if (port != null) {
      port.disconnect();
      port = null;
    }
  }
}
