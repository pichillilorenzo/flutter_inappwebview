package com.pichillilorenzo.flutter_inappbrowser;

import android.util.Log;

import java.lang.reflect.Field;
import java.util.Iterator;
import java.util.Map;
import java.util.HashMap;

public class InAppBrowserOptions {

    public boolean useShouldOverrideUrlLoading = false;
    public boolean clearCache = false;
    public String userAgent = "";
    public boolean javaScriptEnabled = true;
    public boolean javaScriptCanOpenWindowsAutomatically = false;
    public boolean hidden = false;
    public boolean toolbarTop = true;
    public String toolbarTopBackgroundColor = "";
    public String toolbarTopFixedTitle = "";
    public boolean hideUrlBar = false;
    public boolean mediaPlaybackRequiresUserGesture = true;

    public boolean hideTitleBar = false;
    public boolean closeOnCannotGoBack = true;
    public boolean clearSessionCache = false;
    public boolean builtInZoomControls = false;
    public boolean supportZoom = true;
    public boolean databaseEnabled = false;
    public boolean domStorageEnabled = false;
    public boolean useWideViewPort = true;
    public boolean safeBrowsingEnabled = true;
    public boolean progressBar = true;

    public boolean useChromeCustomTabs = false;
    public boolean CCT_addShareButton = true;
    public boolean CCT_showTitle = true;
    public String CCT_toolbarColor = "";
    public boolean CCT_enableUrlBarHiding = false;
    public boolean CCT_instantAppsEnabled = false;

    public void parse(HashMap<String, Object> options) {
        Iterator it = options.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry<String, Object> pair = (Map.Entry<String, Object>)it.next();
            try {
                this.getClass().getDeclaredField(pair.getKey()).set(this, pair.getValue());
            } catch (NoSuchFieldException e) {
                Log.d("InAppBrowserOptions", e.getMessage());
            } catch (IllegalAccessException  e) {
                Log.d("InAppBrowserOptions", e.getMessage());
            }
        }
    }

    public HashMap<String, Object> getHashMap() {
        HashMap<String, Object> options = new HashMap<>();
        for (Field f: this.getClass().getDeclaredFields()) {
            try {
                options.put(f.getName(), f.get(this));
            } catch (IllegalAccessException e) {
                Log.d("InAppBrowserOptions", e.getMessage());
            }
        }
        return options;
    }

}
