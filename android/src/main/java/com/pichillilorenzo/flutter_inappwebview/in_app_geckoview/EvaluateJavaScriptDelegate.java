package com.pichillilorenzo.flutter_inappwebview.in_app_geckoview;

import android.util.Log;
import android.webkit.ValueCallback;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview.types.ContentWorld;

import org.json.JSONException;
import org.json.JSONObject;
import org.mozilla.geckoview.GeckoResult;
import org.mozilla.geckoview.WebExtension;

import java.util.HashMap;
import java.util.Map;

public class EvaluateJavaScriptDelegate implements WebExtension.MessageDelegate, WebExtension.PortDelegate {

  static final String LOG_TAG = "EvaluateJSDelegate";

  @Nullable
  private WebExtension.Port port;
  private int callbackIdCounter = 0;
  private Map<Integer, ValueCallback<String>> callbackMap = new HashMap<>();
  
  public EvaluateJavaScriptDelegate() {
    
  }

  @Nullable
  @Override
  public GeckoResult<Object> onMessage(@NonNull String nativeApp, @NonNull Object message, @NonNull WebExtension.MessageSender sender) {
    return null;
  }

  @Nullable
  @Override
  public void onConnect(@NonNull WebExtension.Port port) {
    this.port = port;
    this.port.setDelegate(this);
  }

  @Override
  public void onPortMessage(@NonNull Object message, @NonNull WebExtension.Port port) {
    if (message instanceof JSONObject) {
      JSONObject jsonObject = (JSONObject) message;
      try {
        Integer callbackId = (Integer) jsonObject.get("id");
        Object result = jsonObject.get("result");
        ValueCallback<String> resultCallback = callbackMap.get(callbackId);
        if (resultCallback != null) {
          resultCallback.onReceiveValue(result != null ? result.toString() : null);
          callbackMap.remove(callbackId);
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

  public void evaluate(String source, @Nullable ContentWorld contentWorld, @Nullable ValueCallback<String> resultCallback) {
    WebExtension.Port port = this.port;
    if (port != null) {
      if (resultCallback != null) {
        callbackIdCounter++;
        callbackMap.put(callbackIdCounter, resultCallback);
      }

      JSONObject jsonObject = new JSONObject();
      try {
        jsonObject.put("id", callbackIdCounter);
        jsonObject.put("source", source);
        jsonObject.put("result", null);
      } catch (JSONException e) {
        e.printStackTrace();
      }
      port.postMessage(jsonObject);
    }
  }

  public void dispose() {
    callbackMap.clear();
    if (port != null) {
      port.disconnect();
      port = null;
    }
  }
}
