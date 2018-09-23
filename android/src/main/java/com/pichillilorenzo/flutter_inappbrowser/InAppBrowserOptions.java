package com.pichillilorenzo.flutter_inappbrowser;

import android.util.Log;

import java.lang.reflect.Field;
import java.util.Iterator;
import java.util.Map;
import java.util.HashMap;

public class InAppBrowserOptions {

    boolean clearCache = false;
    boolean clearSessionCache = false;
    String userAgent = "";
    boolean progressBar = true;
    boolean hidden = false;
    boolean toolbarTop = true;
    String toolbarTopBackgroundColor = "";
    String toolbarTopFixedTitle = "";
    boolean hideUrlBar = false;
    boolean hideTitleBar = false;
    boolean closeOnCannotGoBack = true;
    boolean mediaPlaybackRequiresUserGesture = true;
    boolean javaScriptCanOpenWindowsAutomatically = false;
    boolean javaScriptEnabled = true;
    boolean builtInZoomControls = false;
    boolean supportZoom = true;
    boolean databaseEnabled = true;
    boolean domStorageEnabled = true;
    boolean useWideViewPort = true;
    boolean safeBrowsingEnabled = true;
    boolean useShouldOverrideUrlLoading = false;

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
