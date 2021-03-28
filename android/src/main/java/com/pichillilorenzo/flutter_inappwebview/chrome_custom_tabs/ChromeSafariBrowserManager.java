package com.pichillilorenzo.flutter_inappwebview.chrome_custom_tabs;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview.InAppWebViewFlutterPlugin;

import java.io.Serializable;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ChromeSafariBrowserManager implements MethodChannel.MethodCallHandler {

  protected static final String LOG_TAG = "ChromeBrowserManager";
  public MethodChannel channel;
  @Nullable
  public InAppWebViewFlutterPlugin plugin;
  public String id;
  public static final Map<String, ChromeSafariBrowserManager> shared = new HashMap<>();

  public ChromeSafariBrowserManager(final InAppWebViewFlutterPlugin plugin) {
    this.id = UUID.randomUUID().toString();
    this.plugin = plugin;
    channel = new MethodChannel(plugin.messenger, "com.pichillilorenzo/flutter_chromesafaribrowser");
    channel.setMethodCallHandler(this);
    shared.put(this.id, this);
  }

  @Override
  public void onMethodCall(final MethodCall call, final MethodChannel.Result result) {
    final String id = (String) call.argument("id");

    switch (call.method) {
      case "open":
        {
          String url = (String) call.argument("url");
          HashMap<String, Object> options = (HashMap<String, Object>) call.argument("options");
          List<HashMap<String, Object>> menuItemList = (List<HashMap<String, Object>>) call.argument("menuItemList");
          open(plugin.activity, id, url, options, menuItemList, result);
        }
        break;
      case "isAvailable":
        result.success(CustomTabActivityHelper.isAvailable(plugin.activity));
        break;
      default:
        result.notImplemented();
    }
  }

  public void open(Activity activity, String id, String url, HashMap<String, Object> options,
                   List<HashMap<String, Object>> menuItemList, MethodChannel.Result result) {

    Intent intent = null;
    Bundle extras = new Bundle();
    extras.putString("url", url);
    extras.putBoolean("isData", false);
    extras.putString("id", id);
    extras.putString("managerId", this.id);
    extras.putSerializable("options", options);
    extras.putSerializable("menuItemList", (Serializable) menuItemList);

    if (CustomTabActivityHelper.isAvailable(activity)) {
      intent = new Intent(activity, ChromeCustomTabsActivity.class);
      intent.putExtras(extras);
      activity.startActivity(intent);
      result.success(true);
      return;
    }

    result.error(LOG_TAG, "ChromeCustomTabs is not available!", null);
  }

  public void dispose() {
    channel.setMethodCallHandler(null);
    shared.remove(this.id);
    plugin = null;
  }
}
