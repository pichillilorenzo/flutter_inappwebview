package com.pichillilorenzo.flutter_inappwebview;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class InAppBrowserOptions implements Options {

  public static final String LOG_TAG = "InAppBrowserOptions";

  public boolean hidden = false;
  public boolean toolbarTop = true;
  public String toolbarTopBackgroundColor = "";
  public String toolbarTopFixedTitle = "";
  public boolean hideUrlBar = false;

  public boolean hideTitleBar = false;
  public boolean closeOnCannotGoBack = true;
  public boolean progressBar = true;

  public InAppBrowserOptions parse(HashMap<String, Object> options) {
    Iterator it = options.entrySet().iterator();
    while (it.hasNext()) {
      Map.Entry<String, Object> pair = (Map.Entry<String, Object>) it.next();
      String key = pair.getKey();
      Object value = pair.getValue();
      if (value == null) {
        continue;
      }

      switch (key) {
        case "hidden":
          hidden = (boolean) value;
          break;
        case "toolbarTop":
          toolbarTop = (boolean) value;
          break;
        case "toolbarTopBackgroundColor":
          toolbarTopBackgroundColor = (String) value;
          break;
        case "toolbarTopFixedTitle":
          toolbarTopFixedTitle = (String) value;
          break;
        case "hideUrlBar":
          hideUrlBar = (boolean) value;
          break;
        case "hideTitleBar":
          hideTitleBar = (boolean) value;
          break;
        case "closeOnCannotGoBack":
          closeOnCannotGoBack = (boolean) value;
          break;
        case "progressBar":
          progressBar = (boolean) value;
          break;
      }
    }

    return this;
  }

  @Override
  public HashMap<String, Object> getHashMap() {
    final HashMap<String, Object> options = new HashMap<>();
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
}
