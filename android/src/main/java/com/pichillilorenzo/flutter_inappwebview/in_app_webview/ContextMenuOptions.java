package com.pichillilorenzo.flutter_inappwebview.in_app_webview;

import com.pichillilorenzo.flutter_inappwebview.IWebViewSettings;

import java.util.HashMap;
import java.util.Map;

public class ContextMenuOptions implements IWebViewSettings<Object> {
  public static final String LOG_TAG = "ContextMenuOptions";

  public Boolean hideDefaultSystemContextMenuItems = false;

  public ContextMenuOptions parse(Map<String, Object> options) {
    for (Map.Entry<String, Object> pair : options.entrySet()) {
      String key = pair.getKey();
      Object value = pair.getValue();
      if (value == null) {
        continue;
      }

      switch (key) {
        case "hideDefaultSystemContextMenuItems":
          hideDefaultSystemContextMenuItems = (Boolean) value;
          break;
      }
    }

    return this;
  }

  public Map<String, Object> toMap() {
    Map<String, Object> options = new HashMap<>();
    options.put("hideDefaultSystemContextMenuItems", hideDefaultSystemContextMenuItems);
    return options;
  }

  @Override
  public Map<String, Object> getRealSettings(Object obj) {
    Map<String, Object> realOptions = toMap();
    return realOptions;
  }

}
