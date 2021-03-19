package com.pichillilorenzo.flutter_inappwebview.pull_to_refresh;

import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview.Options;

import java.util.HashMap;
import java.util.Map;

public class PullToRefreshOptions implements Options<PullToRefreshLayout> {
  public static final String LOG_TAG = "PullToRefreshOptions";

  public Boolean enabled = true;
  @Nullable
  public String color;
  @Nullable
  public String backgroundColor;
  @Nullable
  public Integer distanceToTriggerSync;
  @Nullable
  public Integer slingshotDistance;
  @Nullable
  public Integer size;

  public PullToRefreshOptions parse(Map<String, Object> options) {
    for (Map.Entry<String, Object> pair : options.entrySet()) {
      String key = pair.getKey();
      Object value = pair.getValue();
      if (value == null) {
        continue;
      }

      switch (key) {
        case "enabled":
          enabled = (Boolean) value;
          break;
        case "color":
          color = (String) value;
          break;
        case "backgroundColor":
          backgroundColor = (String) value;
          break;
        case "distanceToTriggerSync":
          distanceToTriggerSync = (Integer) value;
          break;
        case "slingshotDistance":
          slingshotDistance = (Integer) value;
          break;
        case "size":
          size = (Integer) value;
          break;
      }
    }

    return this;
  }

  public Map<String, Object> toMap() {
    Map<String, Object> options = new HashMap<>();
    options.put("enabled", enabled);
    options.put("color", color);
    options.put("backgroundColor", backgroundColor);
    options.put("distanceToTriggerSync", distanceToTriggerSync);
    options.put("slingshotDistance", slingshotDistance);
    options.put("size", size);
    return options;
  }

  @Override
  public Map<String, Object> getRealOptions(PullToRefreshLayout pullToRefreshLayout) {
    Map<String, Object> realOptions = toMap();
    return realOptions;
  }

}