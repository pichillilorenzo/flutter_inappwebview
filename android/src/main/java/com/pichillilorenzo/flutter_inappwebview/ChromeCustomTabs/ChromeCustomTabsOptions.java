package com.pichillilorenzo.flutter_inappwebview.ChromeCustomTabs;

import com.pichillilorenzo.flutter_inappwebview.Options;

import java.util.HashMap;
import java.util.Map;

public class ChromeCustomTabsOptions implements Options {

    final static String LOG_TAG = "ChromeCustomTabsOptions";

    public Boolean addDefaultShareMenuItem = true;
    public Boolean showTitle = true;
    public String toolbarBackgroundColor = "";
    public Boolean enableUrlBarHiding = false;
    public Boolean instantAppsEnabled = false;
    public String packageName;
    public Boolean keepAliveEnabled = false;

    @Override
    public ChromeCustomTabsOptions parse(HashMap<String, Object> options) {
        for (Map.Entry<String, Object> pair : options.entrySet()) {
            String key = pair.getKey();
            Object value = pair.getValue();
            if (value == null) {
                continue;
            }

            switch (key) {
                case "addDefaultShareMenuItem":
                    addDefaultShareMenuItem = (boolean) value;
                    break;
                case "showTitle":
                    showTitle = (boolean) value;
                    break;
                case "toolbarBackgroundColor":
                    toolbarBackgroundColor = (String) value;
                    break;
                case "enableUrlBarHiding":
                    enableUrlBarHiding = (boolean) value;
                    break;
                case "instantAppsEnabled":
                    instantAppsEnabled = (boolean) value;
                    break;
                case "packageName":
                    packageName = (String) value;
                    break;
                case "keepAliveEnabled":
                    keepAliveEnabled = (boolean) value;
                    break;
            }
        }

        return this;
    }

    @Override
    public HashMap<String, Object> getHashMap() {
        HashMap<String, Object> options = new HashMap<>();
        options.put("addDefaultShareMenuItem", addDefaultShareMenuItem);
        options.put("showTitle", showTitle);
        options.put("toolbarBackgroundColor", toolbarBackgroundColor);
        options.put("enableUrlBarHiding", enableUrlBarHiding);
        options.put("instantAppsEnabled", instantAppsEnabled);
        options.put("packageName", packageName);
        options.put("keepAliveEnabled", keepAliveEnabled);
        return options;
    }
}
