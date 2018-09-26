package com.pichillilorenzo.flutter_inappbrowser;

import android.util.Log;

import java.lang.reflect.Field;
import java.util.Iterator;
import java.util.Map;
import java.util.HashMap;

public class Options {

    final static String LOG_TAG = "";

    public void parse(HashMap<String, Object> options) {
        Iterator it = options.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry<String, Object> pair = (Map.Entry<String, Object>)it.next();
            try {
                this.getClass().getDeclaredField(pair.getKey()).set(this, pair.getValue());
            } catch (NoSuchFieldException e) {
                Log.d(LOG_TAG, e.getMessage());
            } catch (IllegalAccessException  e) {
                Log.d(LOG_TAG, e.getMessage());
            }
        }
    }

    public HashMap<String, Object> getHashMap() {
        HashMap<String, Object> options = new HashMap<>();
        for (Field f: this.getClass().getDeclaredFields()) {
            try {
                options.put(f.getName(), f.get(this));
            } catch (IllegalAccessException e) {
                Log.d(LOG_TAG, e.getMessage());
            }
        }
        return options;
    }

}
