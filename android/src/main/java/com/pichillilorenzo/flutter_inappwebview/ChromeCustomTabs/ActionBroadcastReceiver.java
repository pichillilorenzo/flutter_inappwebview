package com.pichillilorenzo.flutter_inappwebview.ChromeCustomTabs;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.pichillilorenzo.flutter_inappwebview.Shared;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class ActionBroadcastReceiver extends BroadcastReceiver {
  protected static final String LOG_TAG = "ActionBroadcastReceiver";
  public static final String KEY_ACTION_ID = "com.pichillilorenzo.flutter_inappwebview.ChromeCustomTabs.ACTION_ID";
  public static final String KEY_ACTION_UUID = "com.pichillilorenzo.flutter_inappwebview.ChromeCustomTabs.ACTION_UUID";
  public static final String KEY_URL_TITLE = "android.intent.extra.SUBJECT";

  @Override
  public void onReceive(Context context, Intent intent) {
    String url = intent.getDataString();
    if (url != null) {
      Bundle b = intent.getExtras();
      String uuid = b.getString(KEY_ACTION_UUID);
      int id = b.getInt(KEY_ACTION_ID);
      String title = b.getString(KEY_URL_TITLE);

      MethodChannel channel = new MethodChannel(Shared.messenger, "com.pichillilorenzo/flutter_chromesafaribrowser_" + uuid);
      Map<String, Object> obj = new HashMap<>();
      obj.put("url", url);
      obj.put("title", title);
      obj.put("id", id);
      channel.invokeMethod("onChromeSafariBrowserMenuItemActionPerform", obj);
    }
  }
}
