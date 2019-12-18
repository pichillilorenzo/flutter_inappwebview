package com.pichillilorenzo.flutter_inappwebview.ChromeCustomTabs;

import com.pichillilorenzo.flutter_inappwebview.Options;

public class ChromeCustomTabsOptions extends Options {

    final static String LOG_TAG = "ChromeCustomTabsOptions";

    public Boolean addDefaultShareMenuItem = true;
    public Boolean showTitle = true;
    public String toolbarBackgroundColor = "";
    public Boolean enableUrlBarHiding = false;
    public Boolean instantAppsEnabled = false;
    public String packageName;
    public Boolean keepAliveEnabled = false;

}
