package com.pichillilorenzo.flutter_inappwebview.in_app_browser;

import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview.Options;
import com.pichillilorenzo.flutter_inappwebview.R;

import java.util.HashMap;
import java.util.Map;

public class InAppBrowserOptions implements Options<InAppBrowserActivity> {

  public static final String LOG_TAG = "InAppBrowserOptions";

  public Boolean hidden = false;
  public Boolean hideToolbarTop = false;
  @Nullable
  public String toolbarTopBackgroundColor;
  @Nullable
  public String toolbarTopFixedTitle;
  public Boolean hideUrlBar = false;
  public Boolean hideProgressBar = false;

  public Boolean hideTitleBar = false;
  public Boolean closeOnCannotGoBack = true;
  public Boolean allowGoBackWithBackButton = true;
  public Boolean shouldCloseOnBackButtonPressed = false;

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
        case "hideToolbarTop":
          hideToolbarTop = (Boolean) value;
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
        case "hideProgressBar":
          hideProgressBar = (Boolean) value;
          break;
        case "allowGoBackWithBackButton":
          allowGoBackWithBackButton = (Boolean) value;
          break;
        case "shouldCloseOnBackButtonPressed":
          shouldCloseOnBackButtonPressed = (Boolean) value;
          break;
      }
    }

    return this;
  }

  @Override
  public Map<String, Object> toMap() {
    Map<String, Object> options = new HashMap<>();
    options.put("hidden", hidden);
    options.put("hideToolbarTop", hideToolbarTop);
    options.put("toolbarTopBackgroundColor", toolbarTopBackgroundColor);
    options.put("toolbarTopFixedTitle", toolbarTopFixedTitle);
    options.put("hideUrlBar", hideUrlBar);
    options.put("hideTitleBar", hideTitleBar);
    options.put("closeOnCannotGoBack", closeOnCannotGoBack);
    options.put("hideProgressBar", hideProgressBar);
    options.put("allowGoBackWithBackButton", allowGoBackWithBackButton);
    options.put("shouldCloseOnBackButtonPressed", shouldCloseOnBackButtonPressed);
    return options;
  }

  @Override
  public Map<String, Object> getRealOptions(InAppBrowserActivity inAppBrowserActivity) {
    Map<String, Object> realOptions = toMap();
    realOptions.put("hideToolbarTop", !inAppBrowserActivity.actionBar.isShowing());
    realOptions.put("hideUrlBar", !inAppBrowserActivity.menu.findItem(R.id.menu_search).isVisible());
    realOptions.put("hideProgressBar", inAppBrowserActivity.progressBar.getMax() == 0);
    return realOptions;
  }
}
