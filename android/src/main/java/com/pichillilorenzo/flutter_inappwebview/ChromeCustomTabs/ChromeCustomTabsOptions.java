package com.pichillilorenzo.flutter_inappwebview.ChromeCustomTabs;

import com.pichillilorenzo.flutter_inappwebview.Options;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class ChromeCustomTabsOptions implements Options {

    final static String LOG_TAG = "ChromeCustomTabsOptions";

    public boolean addShareButton = true;
    public boolean showTitle = true;
    public String toolbarBackgroundColor = "";
    public boolean enableUrlBarHiding = false;
    public boolean instantAppsEnabled = false;

    ChromeCustomTabsOptions parse(HashMap<String, Object> options) {
        Iterator it = options.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry<String, Object> pair = (Map.Entry<String, Object>) it.next();
            String key = pair.getKey();
            Object value = pair.getValue();
            if (value == null) {
                continue;
            }

            switch (key) {
                case "addShareButton":
                    addShareButton = (boolean) value;
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
            }
        }

        return this;
    }

    @Override
    public HashMap<String, Object> getHashMap() {
        HashMap<String, Object> options = new HashMap<>();
        options.put("addShareButton", addShareButton);
        options.put("showTitle", showTitle);
        options.put("toolbarBackgroundColor", toolbarBackgroundColor);
        options.put("enableUrlBarHiding", enableUrlBarHiding);
        options.put("instantAppsEnabled", instantAppsEnabled);

        return options;
    }
}
