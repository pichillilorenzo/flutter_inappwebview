package com.pichillilorenzo.flutter_inappwebview.in_app_geckoview;

import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.mozilla.geckoview.GeckoResult;
import org.mozilla.geckoview.WebExtension;

import java.util.Arrays;
import java.util.Collections;

public class BackgroundMessageDelegate implements WebExtension.MessageDelegate, WebExtension.PortDelegate {
  static final String LOG_TAG = "BackgroundMSGDelegate";
  
  @Nullable
  private WebExtension.Port port;

  public BackgroundMessageDelegate() {

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
  public void onPortMessage(@NonNull Object obj, @NonNull WebExtension.Port port) {
    Log.d(LOG_TAG, "\n\n\nonPortMessage\n\n\n");

    JSONObject message = new JSONObject();
    JSONObject contentScript = new JSONObject();
    try {
      JSONObject code = new JSONObject();
      code.put("code", "console.log('hello');");
      contentScript.put("matches", new JSONArray(Collections.singletonList("<all_urls>")));
      contentScript.put("js", new JSONArray(Collections.singletonList(code)));
      contentScript.put("runAt", "document_start");
      message.put("action", "registerContentScript");
      message.put("contentScript", contentScript);
    } catch (JSONException e) {
      e.printStackTrace();
    }
    port.postMessage(message);
  }

  @NonNull
  @Override
  public void onDisconnect(@NonNull WebExtension.Port port) {
    if (this.port == port) {
      this.port = null;
    }
  }

  public void registerContentScript(JSONObject contentScript) {
    
  }
}
