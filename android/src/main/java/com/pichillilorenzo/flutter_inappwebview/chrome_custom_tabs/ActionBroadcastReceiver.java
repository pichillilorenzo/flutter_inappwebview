package com.pichillilorenzo.flutter_inappwebview.chrome_custom_tabs;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class ActionBroadcastReceiver extends BroadcastReceiver {
  protected static final String LOG_TAG = "ActionBroadcastReceiver";
  public static final String KEY_ACTION_ID = "com.pichillilorenzo.flutter_inappwebview.ChromeCustomTabs.ACTION_ID";
  public static final String KEY_ACTION_VIEW_ID = "com.pichillilorenzo.flutter_inappwebview.ChromeCustomTabs.ACTION_VIEW_ID";
  public static final String CHROME_MANAGER_ID = "com.pichillilorenzo.flutter_inappwebview.ChromeCustomTabs.CHROME_MANAGER_ID";
  public static final String KEY_URL_TITLE = "android.intent.extra.SUBJECT";

  @Override
  public void onReceive(Context context, Intent intent) {
    String url = intent.getDataString();
    if (url != null) {
      Bundle b = intent.getExtras();
      String viewId = b.getString(KEY_ACTION_VIEW_ID);
      int id = b.getInt(KEY_ACTION_ID);
      String title = b.getString(KEY_URL_TITLE);

      String managerId = b.getString(CHROME_MANAGER_ID);
      ChromeSafariBrowserManager manager = (ChromeSafariBrowserManager) ChromeSafariBrowserManager.shared.get(managerId);

      MethodChannel channel = new MethodChannel(manager.plugin.messenger, "com.pichillilorenzo/flutter_chromesafaribrowser_" + viewId);
      Map<String, Object> obj = new HashMap<>();
      obj.put("url", url);
      obj.put("title", title);
      obj.put("id", id);
      channel.invokeMethod("onChromeSafariBrowserItemActionPerform", obj);
    }
  }
}
