package com.pichillilorenzo.flutter_inappwebview.InAppBrowser;

import com.pichillilorenzo.flutter_inappwebview.Options;

import java.util.HashMap;
import java.util.Map;

public class InAppBrowserOptions implements Options<InAppBrowserActivity> {

  public static final String LOG_TAG = "InAppBrowserOptions";

  public Boolean hidden = false;
  public Boolean toolbarTop = true;
  public String toolbarTopBackgroundColor = "";
  public String toolbarTopFixedTitle = "";
  public Boolean hideUrlBar = false;

  public Boolean hideTitleBar = false;
  public Boolean closeOnCannotGoBack = true;
  public Boolean progressBar = true;

  @Override
  public InAppBrowserOptions parse(Map<String, Object> options) {
    for (Map.Entry<String, Object> pair : options.entrySet()) {
      String key = pair.getKey();
      Object value = pair.getValue();
      if (value == null) {
        continue;
      }

      switch (key) {
        case "hidden":
          hidden = (Boolean) value;
          break;
        case "toolbarTop":
          toolbarTop = (Boolean) value;
          break;
        case "toolbarTopBackgroundColor":
          toolbarTopBackgroundColor = (String) value;
          break;
        case "toolbarTopFixedTitle":
          toolbarTopFixedTitle = (String) value;
          break;
        case "hideUrlBar":
          hideUrlBar = (Boolean) value;
          break;
        case "hideTitleBar":
          hideTitleBar = (Boolean) value;
          break;
        case "closeOnCannotGoBack":
          closeOnCannotGoBack = (Boolean) value;
          break;
        case "progressBar":
          progressBar = (Boolean) value;
          break;
      }
    }

    return this;
  }

  @Override
  public Map<String, Object> toMap() {
    Map<String, Object> options = new HashMap<>();
    options.put("hidden", hidden);
    options.put("toolbarTop", toolbarTop);
    options.put("toolbarTopBackgroundColor", toolbarTopBackgroundColor);
    options.put("toolbarTopFixedTitle", toolbarTopFixedTitle);
    options.put("hideUrlBar", hideUrlBar);
    options.put("hideTitleBar", hideTitleBar);
    options.put("closeOnCannotGoBack", closeOnCannotGoBack);
    options.put("progressBar", progressBar);
    return options;
  }

  @Override
  public Map<String, Object> getRealOptions(InAppBrowserActivity inAppBrowserActivity) {
    Map<String, Object> realOptions = toMap();
    return realOptions;
  }
}
