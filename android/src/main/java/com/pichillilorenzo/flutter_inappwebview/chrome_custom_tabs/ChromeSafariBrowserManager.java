package com.pichillilorenzo.flutter_inappwebview.chrome_custom_tabs;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview.Util;
import com.pichillilorenzo.flutter_inappwebview.headless_in_app_webview.HeadlessInAppWebView;
import com.pichillilorenzo.flutter_inappwebview.types.ChannelDelegateImpl;

import java.io.Serializable;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ChromeSafariBrowserManager extends ChannelDelegateImpl {
  protected static final String LOG_TAG = "ChromeBrowserManager";
  public static final String METHOD_CHANNEL_NAME = "com.pichillilorenzo/flutter_chromesafaribrowser";
  
  @Nullable
  public InAppWebViewFlutterPlugin plugin;
  public String id;
  public static final Map<String, ChromeSafariBrowserManager> shared = new HashMap<>();
  public static final Map<String, ChromeCustomTabsActivity> browsers = new HashMap<>();

  public ChromeSafariBrowserManager(final InAppWebViewFlutterPlugin plugin) {
    super(new MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME));
    this.id = UUID.randomUUID().toString();
    this.plugin = plugin;
    shared.put(this.id, this);
  }

  @Override
  public void onMethodCall(final MethodCall call, final MethodChannel.Result result) {
    final String viewId = (String) call.argument("id");

    switch (call.method) {
      case "open":
        if (plugin != null && plugin.activity != null) {
          String url = (String) call.argument("url");
          HashMap<String, Object> settings = (HashMap<String, Object>) call.argument("settings");
          HashMap<String, Object> actionButton = (HashMap<String, Object>) call.argument("actionButton");
          List<HashMap<String, Object>> menuItemList = (List<HashMap<String, Object>>) call.argument("menuItemList");
          open(plugin.activity, viewId, url, settings, actionButton, menuItemList, result);
        } else {
          result.success(false);
        }
        break;
      case "isAvailable":
        if (plugin != null && plugin.activity != null) {
          result.success(CustomTabActivityHelper.isAvailable(plugin.activity));
        } else {
          result.success(false);
        }
        break;
      default:
        result.notImplemented();
    }
  }

  public void open(Activity activity, String viewId, String url, HashMap<String, Object> settings,
                   HashMap<String, Object> actionButton,
                   List<HashMap<String, Object>> menuItemList, MethodChannel.Result result) {

    Intent intent = null;
    Bundle extras = new Bundle();
    extras.putString("url", url);
    extras.putBoolean("isData", false);
    extras.putString("id", viewId);
    extras.putString("managerId", this.id);
    extras.putSerializable("settings", settings);
    extras.putSerializable("actionButton", (Serializable) actionButton);
    extras.putSerializable("menuItemList", (Serializable) menuItemList);

    Boolean isSingleInstance = Util.<Boolean>getOrDefault(settings, "isSingleInstance", false);
    Boolean isTrustedWebActivity = Util.<Boolean>getOrDefault(settings, "isTrustedWebActivity", false);
    if (CustomTabActivityHelper.isAvailable(activity)) {
      intent = new Intent(activity, !isSingleInstance ? 
              (!isTrustedWebActivity ? ChromeCustomTabsActivity.class : TrustedWebActivity.class) :
              (!isTrustedWebActivity ? ChromeCustomTabsActivitySingleInstance.class : TrustedWebActivitySingleInstance.class));
      intent.putExtras(extras);
      Boolean noHistory = Util.<Boolean>getOrDefault(settings, "noHistory", false);
      if (noHistory) {
        intent.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY);
      }
      activity.startActivity(intent);
      result.success(true);
      return;
    }

    result.error(LOG_TAG, "ChromeCustomTabs is not available!", null);
  }

  @Override
  public void dispose() {
    super.dispose();
    Collection<ChromeCustomTabsActivity> browserList = browsers.values();
    for (ChromeCustomTabsActivity browser : browserList) {
      if (browser != null) {
        browser.close();
        browser.dispose();
      }
    }
    browsers.clear();
    shared.remove(this.id);
    plugin = null;
  }
}
