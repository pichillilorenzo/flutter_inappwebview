package com.pichillilorenzo.flutter_inappwebview.chrome_custom_tabs;

import android.content.Intent;

import androidx.annotation.Nullable;
import androidx.browser.customtabs.CustomTabsIntent;
import androidx.browser.trusted.ScreenOrientation;
import androidx.browser.trusted.TrustedWebActivityDisplayMode;

import com.pichillilorenzo.flutter_inappwebview.Options;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
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
  public Boolean isSingleInstance = false;
  public Boolean noHistory = false;
  public Boolean isTrustedWebActivity = false;
  public List<String> additionalTrustedOrigins = new ArrayList<>();
  public TrustedWebActivityDisplayMode displayMode = null;
  public Integer screenOrientation = ScreenOrientation.DEFAULT;

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
        case "isSingleInstance":
          isSingleInstance = (Boolean) value;
          break;
        case "noHistory":
          noHistory = (Boolean) value;
          break;
        case "isTrustedWebActivity":
          isTrustedWebActivity = (Boolean) value;
          break;
        case "additionalTrustedOrigins":
          additionalTrustedOrigins = (List<String>) value;
          break;
        case "displayMode":
          Map<String, Object> displayModeMap = (Map<String, Object>) value;
          String displayModeType = (String) displayModeMap.get("type");
          if (displayModeType != null) {
            switch (displayModeType) {
              case "IMMERSIVE_MODE":
                boolean isSticky = (boolean) displayModeMap.get("isSticky");
                int layoutInDisplayCutoutMode = (int) displayModeMap.get("layoutInDisplayCutoutMode");
                displayMode = new TrustedWebActivityDisplayMode.ImmersiveMode(isSticky, layoutInDisplayCutoutMode);
                break;
              case "DEFAULT_MODE":
                displayMode = new TrustedWebActivityDisplayMode.DefaultMode();
                break;
            }
          }
          break;
        case "screenOrientation":
          screenOrientation = (Integer) value;
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
    options.put("isSingleInstance", isSingleInstance);
    options.put("noHistory", noHistory);
    options.put("isTrustedWebActivity", isTrustedWebActivity);
    options.put("additionalTrustedOrigins", additionalTrustedOrigins);
    options.put("screenOrientation", screenOrientation);
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
