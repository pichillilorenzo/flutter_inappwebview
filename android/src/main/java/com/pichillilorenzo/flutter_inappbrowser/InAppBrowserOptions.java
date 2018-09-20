package com.pichillilorenzo.flutter_inappbrowser;

import android.os.Build;
import android.support.annotation.RequiresApi;
import android.util.Log;

import java.lang.reflect.Field;
import java.util.Iterator;
import java.util.Map;
import java.util.HashMap;

public class InAppBrowserOptions {

    boolean clearCache = false;
    boolean clearSessionCache = false;
    String userAgent = "";
    boolean spinner = true;
    boolean hidden = false;
    boolean toolbarTop = true;
    String toolbarTopColor = "toolbarTopColor";
    boolean hideUrlBar = false;
    boolean mediaPlaybackRequiresUserGesture = true;
    boolean javaScriptCanOpenWindowsAutomatically = false;
    boolean javaScriptEnabled = true;
    boolean builtInZoomControls = false;
    boolean supportZoom = true;
    boolean databaseEnabled = true;
    boolean domStorageEnabled = true;
    boolean useWideViewPort = true;
    boolean safeBrowsingEnabled = true;

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    public void parse(HashMap<String, Object> options) {
        Iterator it = options.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry<String, Object> pair = (Map.Entry<String, Object>)it.next();
            try {
                this.getClass().getField(pair.getKey()).set(this, pair.getValue());
            } catch (NoSuchFieldException | IllegalAccessException  e) {
                // silent
            }
        }
    }

    public HashMap<String, Object> getHashMap() {
        HashMap<String, Object> options = new HashMap<>();
        for (Field f: this.getClass().getDeclaredFields()) {
            try {
                options.put(f.getName(), f.get(this));
            } catch (IllegalAccessException e) {
                // silent
            }
        }
        return options;
    }

}
