package com.pichillilorenzo.flutter_inappwebview.chrome_custom_tabs;

import android.content.Intent;

import androidx.annotation.Nullable;
import androidx.browser.customtabs.CustomTabsIntent;

import com.pichillilorenzo.flutter_inappwebview.Options;

import java.util.HashMap;
import java.util.Map;

public class ChromeCustomTabsOptions implements Options<ChromeCustomTabsActivity> {

  final static String LOG_TAG = "ChromeCustomTabsOptions";

  @Deprecated
  public Boolean addDefaultShareMenuItem;
  public Integer shareState = CustomTabsIntent.SHARE_STATE_DEFAULT;
  public Boolean showTitle = true;
  @Nullable
  public String toolbarBackgroundColor;
  public Boolean enableUrlBarHiding = false;
  public Boolean instantAppsEnabled = false;
  public String packageName;
  public Boolean keepAliveEnabled = false;
  public Boolean singleInstance = false;
  public Boolean noHistory = false;

  @Override
  public ChromeCustomTabsOptions parse(Map<String, Object> options) {
    for (Map.Entry<String, Object> pair : options.entrySet()) {
      String key = pair.getKey();
      Object value = pair.getValue();
      if (value == null) {
        continue;
      }

      switch (key) {
        case "addDefaultShareMenuItem":
          addDefaultShareMenuItem = (Boolean) value;
          break;
        case "shareState":
          shareState = (Integer) value;
          break;
        case "showTitle":
          showTitle = (Boolean) value;
          break;
        case "toolbarBackgroundColor":
          toolbarBackgroundColor = (String) value;
          break;
        case "enableUrlBarHiding":
          enableUrlBarHiding = (Boolean) value;
          break;
        case "instantAppsEnabled":
          instantAppsEnabled = (Boolean) value;
          break;
        case "packageName":
          packageName = (String) value;
          break;
        case "keepAliveEnabled":
          keepAliveEnabled = (Boolean) value;
          break;
        case "singleInstance":
          singleInstance = (Boolean) value;
          break;
        case "noHistory":
          noHistory = (Boolean) value;
          break;
      }
    }

    return this;
  }

  @Override
  public Map<String, Object> toMap() {
    Map<String, Object> options = new HashMap<>();
    options.put("addDefaultShareMenuItem", addDefaultShareMenuItem);
    options.put("showTitle", showTitle);
    options.put("toolbarBackgroundColor", toolbarBackgroundColor);
    options.put("enableUrlBarHiding", enableUrlBarHiding);
    options.put("instantAppsEnabled", instantAppsEnabled);
    options.put("packageName", packageName);
    options.put("keepAliveEnabled", keepAliveEnabled);
    options.put("singleInstance", singleInstance);
    options.put("noHistory", noHistory);
    return options;
  }

  @Override
  public Map<String, Object> getRealOptions(ChromeCustomTabsActivity chromeCustomTabsActivity) {
    Map<String, Object> realOptions = toMap();
    if (chromeCustomTabsActivity != null) {
      Intent intent = chromeCustomTabsActivity.getIntent();
      if (intent != null) {
        realOptions.put("packageName", intent.getPackage());
        realOptions.put("keepAliveEnabled", intent.hasExtra(CustomTabsHelper.EXTRA_CUSTOM_TABS_KEEP_ALIVE));
      }
    }
    return realOptions;
  }
}
