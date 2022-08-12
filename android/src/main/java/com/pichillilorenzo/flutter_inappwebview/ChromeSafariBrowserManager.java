package com.pichillilorenzo.flutter_inappwebview;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.pichillilorenzo.flutter_inappwebview.ChromeCustomTabs.ChromeCustomTabsActivity;
import com.pichillilorenzo.flutter_inappwebview.ChromeCustomTabs.CustomTabActivityHelper;
import com.pichillilorenzo.flutter_inappwebview.InAppBrowser.InAppBrowserActivity;
import com.pichillilorenzo.flutter_inappwebview.InAppBrowser.InAppBrowserOptions;

import java.io.Serializable;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ChromeSafariBrowserManager implements MethodChannel.MethodCallHandler {

  public MethodChannel channel;

  protected static final String LOG_TAG = "ChromeBrowserManager";

  public ChromeSafariBrowserManager(BinaryMessenger messenger) {
    channel = new MethodChannel(messenger, "com.pichillilorenzo/flutter_chromesafaribrowser");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(final MethodCall call, final MethodChannel.Result result) {
    final Activity activity = Shared.activity;
    final String uuid = (String) call.argument("uuid");

    switch (call.method) {
      case "open":
        {
          String url = (String) call.argument("url");
          HashMap<String, Object> options = (HashMap<String, Object>) call.argument("options");
          List<HashMap<String, Object>> menuItemList = (List<HashMap<String, Object>>) call.argument("menuItemList");
          String uuidFallback = (String) call.argument("uuidFallback");
          Map<String, String> headersFallback = (Map<String, String>) call.argument("headersFallback");
          HashMap<String, Object> optionsFallback = (HashMap<String, Object>) call.argument("optionsFallback");
          HashMap<String, Object> contextMenuFallback = (HashMap<String, Object>) call.argument("contextMenuFallback");
          Integer windowIdFallback = (Integer) call.argument("windowIdFallback");
          open(activity, uuid, url, options, menuItemList, uuidFallback, headersFallback, optionsFallback, contextMenuFallback, windowIdFallback, result);
        }
        break;
      case "isAvailable":
        result.success(CustomTabActivityHelper.isAvailable(activity));
        break;
      default:
        result.notImplemented();
    }
  }

  public void open(Activity activity, String uuid, String url, HashMap<String, Object> options, List<HashMap<String, Object>> menuItemList, String uuidFallback,
                   Map<String, String> headersFallback, HashMap<String, Object> optionsFallback, HashMap<String, Object> contextMenuFallback, Integer windowIdFallback,
                   MethodChannel.Result result) {

    Intent intent = null;
    Bundle extras = new Bundle();
    extras.putString("fromActivity", activity.getClass().getName());
    extras.putString("url", url);
    extras.putBoolean("isData", false);
    extras.putString("uuid", uuid);
    extras.putSerializable("options", options);
    extras.putSerializable("menuItemList", (Serializable) menuItemList);

    extras.putSerializable("headers", (Serializable) headersFallback);
    extras.putSerializable("contextMenu", (Serializable) contextMenuFallback);

    extras.putInt("windowId", windowIdFallback != null ? windowIdFallback : -1);

    if (CustomTabActivityHelper.isAvailable(activity)) {
      intent = new Intent(activity, ChromeCustomTabsActivity.class);
    }
    // check for webview fallback
    else if (!CustomTabActivityHelper.isAvailable(activity) && uuidFallback != null) {
      Log.d(LOG_TAG, "WebView fallback declared.");
      // overwrite with extras fallback parameters
      extras.putString("uuid", uuidFallback);
      if (optionsFallback != null)
        extras.putSerializable("options", optionsFallback);
      else
        extras.putSerializable("options", (Serializable) (new InAppBrowserOptions()).toMap());
      intent = new Intent(activity, InAppBrowserActivity.class);
    }

    if (intent != null) {
      intent.putExtras(extras);
      activity.startActivity(intent);
      result.success(true);
      return;
    }

    result.error(LOG_TAG, "No WebView fallback declared.", null);
  }

  public void dispose() {
    channel.setMethodCallHandler(null);
  }
}
