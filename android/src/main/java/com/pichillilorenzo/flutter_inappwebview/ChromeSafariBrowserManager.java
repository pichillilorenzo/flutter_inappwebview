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
          String uuidFallback = (String) call.argument("uuidFallback");
          Map<String, String> headersFallback = (Map<String, String>) call.argument("headersFallback");
          HashMap<String, Object> optionsFallback = (HashMap<String, Object>) call.argument("optionsFallback");
          List<HashMap<String, Object>> menuItemList = (List<HashMap<String, Object>>) call.argument("menuItemList");
          open(activity, uuid, url, options, uuidFallback, headersFallback, optionsFallback, menuItemList, result);
        }
        break;
      default:
        result.notImplemented();
    }
  }

  public void open(Activity activity, String uuid, String url, HashMap<String, Object> options, String uuidFallback,
                   Map<String, String> headersFallback, HashMap<String, Object> optionsFallback, List<HashMap<String, Object>> menuItemList, MethodChannel.Result result) {

    Intent intent = null;
    Bundle extras = new Bundle();
    extras.putString("fromActivity", activity.getClass().getName());
    extras.putString("url", url);
    extras.putBoolean("isData", false);
    extras.putString("uuid", uuid);
    extras.putSerializable("options", options);
    extras.putSerializable("headers", (Serializable) headersFallback);
    extras.putSerializable("menuItemList", (Serializable) menuItemList);

    if (CustomTabActivityHelper.isAvailable(activity)) {
      intent = new Intent(activity, ChromeCustomTabsActivity.class);
    }
    // check for webview fallback
    else if (!CustomTabActivityHelper.isAvailable(activity) && !uuidFallback.isEmpty()) {
      Log.d(LOG_TAG, "WebView fallback declared.");
      // overwrite with extras fallback parameters
      extras.putString("uuid", uuidFallback);
      if (optionsFallback != null)
        extras.putSerializable("options", optionsFallback);
      else
        extras.putSerializable("options", (new InAppBrowserOptions()).getHashMap());
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
